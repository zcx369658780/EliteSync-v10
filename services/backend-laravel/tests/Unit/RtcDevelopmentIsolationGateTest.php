<?php

namespace Tests\Unit;

use App\Services\RtcAuthorityService;
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Mockery;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class RtcDevelopmentIsolationGateTest extends TestCase
{
    #[DataProvider('gateCases')]
    public function test_only_qualified_development_connection_is_enabled(
        string $environment, bool $rtcFlag, bool $consentFlag, string $driver,
        string $database, string $host, string $socket, int $actualPort,
        int $approvedPort, bool $expected,
    ): void {
        $this->app->instance('env', $environment);
        config([
            'rtc_guard.enabled' => $rtcFlag,
            'restoration.enabled' => $consentFlag,
            'restoration.port' => $approvedPort,
        ]);
        // Only metadata is observed; this mock never creates a PDO connection.
        // LiveConsentService itself remains real, including its own isolation gate.
        $connection = Mockery::mock(Connection::class);
        $connection->shouldReceive('getDriverName')->andReturn($driver);
        $connection->shouldReceive('getDatabaseName')->andReturn($database);
        $connection->shouldReceive('getConfig')->with('host')->andReturn($host);
        $connection->shouldReceive('getConfig')->with('unix_socket')->andReturn($socket);
        $connection->shouldReceive('getConfig')->with('port')->andReturn($actualPort);
        DB::shouldReceive('connection')->andReturn($connection);

        $this->assertSame($expected, (new RtcAuthorityService)->enabled());
    }

    public static function gateCases(): array
    {
        $local = ['local', true, true, 'mysql', 'elitesync_v10_1_5_dev', '127.0.0.1', '', 43326, 43326, true];
        $case = static fn (array $changes) => array_replace($local, $changes);

        return [
            'v1015 isolated mysql' => $local,
            'v1015 isolated mariadb' => $case([3 => 'mariadb']),
            'rtc feature flag off' => $case([1 => false, 9 => false]),
            'live consent feature flag off' => $case([2 => false, 9 => false]),
            'production denied even when configured' => $case([0 => 'production', 9 => false]),
            'staging denied' => $case([0 => 'staging', 9 => false]),
            'localhost alias denied' => $case([5 => 'localhost', 9 => false]),
            'remote host denied' => $case([5 => '192.0.2.1', 9 => false]),
            'v1015 database with old version port denied' => $case([7 => 43323, 8 => 43323, 9 => false]),
            'old version database with v1015 port denied' => $case([4 => 'elitesync_v10_1_2_dev', 9 => false]),
            'configured and actual ports must match' => $case([8 => 43323, 9 => false]),
            'unix socket bypass denied' => $case([6 => '/fictional/mysql.sock', 9 => false]),
            'local sqlite denied by live consent gate' => $case([3 => 'sqlite', 9 => false]),
            'existing testing sqlite behavior preserved' => $case([0 => 'testing', 3 => 'sqlite']),
            'testing mysql remains denied' => $case([0 => 'testing', 9 => false]),
        ];
    }
}
