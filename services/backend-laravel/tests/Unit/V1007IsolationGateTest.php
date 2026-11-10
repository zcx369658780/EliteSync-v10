<?php

namespace Tests\Unit;

use App\Services\LiveConsentService;
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Mockery;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class V1007IsolationGateTest extends TestCase
{
    #[DataProvider('gateCases')]
    public function test_only_explicit_isolated_runtime_is_enabled(
        string $environment, bool $flag, string $driver, string $database,
        string $host, string $socket, int $actualPort, int $approvedPort, bool $expected,
    ): void {
        $this->app->instance('env', $environment);
        config(['restoration.enabled' => $flag, 'restoration.port' => $approvedPort]);
        // No PDO is created: all observed connection metadata comes from this mock.
        $connection = Mockery::mock(Connection::class);
        $connection->shouldReceive('getDriverName')->andReturn($driver);
        $connection->shouldReceive('getDatabaseName')->andReturn($database);
        $connection->shouldReceive('getConfig')->with('host')->andReturn($host);
        $connection->shouldReceive('getConfig')->with('unix_socket')->andReturn($socket);
        $connection->shouldReceive('getConfig')->with('port')->andReturn($actualPort);
        DB::shouldReceive('connection')->andReturn($connection);
        $this->assertSame($expected, (new LiveConsentService)->enabled());
    }

    public static function gateCases(): array
    {
        $local = ['local', true, 'mysql', 'elitesync_v1007_dev', '127.0.0.1', '', 43317, 43317, true];
        $case = static fn (array $changes) => array_replace($local, $changes);

        return [
            'isolated local mysql' => $local,
            'isolated local mariadb' => $case([2 => 'mariadb']),
            'production even configured' => $case([0 => 'production', 8 => false]),
            'unknown environment' => $case([0 => 'staging', 8 => false]),
            'local feature flag off' => $case([1 => false, 8 => false]),
            'testing sqlite' => $case([0 => 'testing', 2 => 'sqlite']),
            'testing mysql denied' => $case([0 => 'testing', 8 => false]),
            'testing flag off' => $case([0 => 'testing', 1 => false, 2 => 'sqlite', 8 => false]),
            'local sqlite denied' => $case([2 => 'sqlite', 8 => false]),
            'wrong database' => $case([3 => 'elitesync_v1006_dev', 8 => false]),
            'wrong host' => $case([4 => 'localhost', 8 => false]),
            'remote host' => $case([4 => '192.0.2.1', 8 => false]),
            'unix socket bypass' => $case([5 => '/fixture/mysql.sock', 8 => false]),
            'real database port denied' => $case([6 => 3306, 7 => 3306, 8 => false]),
            'accepted evidence port denied' => $case([6 => 43316, 7 => 43316, 8 => false]),
            'unapproved actual port' => $case([6 => 43318, 8 => false]),
            'approved metadata mismatch' => $case([7 => 43318, 8 => false]),
        ];
    }
}
