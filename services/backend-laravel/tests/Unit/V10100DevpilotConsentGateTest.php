<?php

namespace Tests\Unit;

use App\Services\LiveConsentService;
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Mockery;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class V10100DevpilotConsentGateTest extends TestCase
{
    #[DataProvider('gateCases')]
    public function test_consent_uses_fixed_database_and_port_pairs(array $overrides, bool $expected): void
    {
        $case = array_replace([
            'environment' => 'local', 'enabled' => true, 'driver' => 'mariadb',
            'database' => 'elitesync_v1010_devpilot', 'host' => '127.0.0.1',
            'unix_socket' => '', 'url' => null, 'port' => 43330, 'approved_port' => 43330,
        ], $overrides);
        $this->app->instance('env', $case['environment']);
        config([
            'restoration.enabled' => $case['enabled'],
            'restoration.port' => $case['approved_port'],
            'database.default' => 'consent_gate',
            'database.connections.consent_gate' => [
                'driver' => $case['driver'], 'url' => $case['url'],
            ],
        ]);

        // Metadata only: no PDO, queries, transactions, or consent transitions are used.
        $connection = Mockery::mock(Connection::class);
        $connection->shouldReceive('getDriverName')->andReturn($case['driver']);
        $connection->shouldReceive('getDatabaseName')->andReturn($case['database']);
        foreach (['host', 'unix_socket', 'port'] as $key) {
            $connection->shouldReceive('getConfig')->with($key)->andReturn($case[$key]);
        }
        if ($case['url'] || ! $case['enabled'] || ! in_array($case['environment'], ['local', 'testing'], true)) {
            DB::shouldReceive('connection')->never();
        } else {
            DB::shouldReceive('connection')->andReturn($connection);
        }

        $this->assertSame($expected, (new LiveConsentService)->enabled());
    }

    public static function gateCases(): array
    {
        return [
            'cloud mariadb pair' => [[], true],
            'cloud mysql pair' => [['driver' => 'mysql'], true],
            'old v1007 pair' => [['database' => 'elitesync_v1007_dev', 'port' => 43317, 'approved_port' => 43317], true],
            'old v1008 pair' => [['database' => 'elitesync_v1008_dev', 'port' => 43318, 'approved_port' => 43318], true],
            'old v1009 pair' => [['database' => 'elitesync_v1009_dev', 'port' => 43319, 'approved_port' => 43319], true],
            'cloud database cannot use old port' => [['port' => 43319, 'approved_port' => 43319], false],
            'old database cannot use cloud port' => [['database' => 'elitesync_v1009_dev'], false],
            'unknown database' => [['database' => 'unknown_dev'], false],
            'production database' => [['database' => 'elitesync'], false],
            'default database port' => [['port' => 3306, 'approved_port' => 3306], false],
            'historical evidence port' => [['port' => 43316, 'approved_port' => 43316], false],
            'unapproved cloud port' => [['approved_port' => 43317], false],
            'remote host' => [['host' => '192.0.2.1'], false],
            'localhost alias' => [['host' => 'localhost'], false],
            'socket override' => [['unix_socket' => '/tmp/other-db.sock'], false],
            'URL override' => [['url' => 'mysql://example.invalid/elitesync'], false],
            'production environment' => [['environment' => 'production'], false],
            'unknown environment' => [['environment' => 'staging'], false],
            'disabled restoration' => [['enabled' => false], false],
            'unsupported driver' => [['driver' => 'pgsql'], false],
            'testing sqlite unchanged' => [['environment' => 'testing', 'driver' => 'sqlite'], true],
            'testing mariadb remains denied' => [['environment' => 'testing'], false],
        ];
    }
}
