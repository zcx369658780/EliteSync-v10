<?php

namespace Tests\Unit;

use App\Services\RtcAuthorityService;
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Mockery;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class V10100DevpilotRtcGateTest extends TestCase
{
    #[DataProvider('gateCases')]
    public function test_rtc_keeps_the_consent_gate_and_fixed_database_port_pairs(array $overrides, bool $expected): void
    {
        $case = array_replace([
            'environment' => 'local', 'rtc_enabled' => true, 'consent_enabled' => true,
            'driver' => 'mariadb', 'database' => 'elitesync_v1010_devpilot',
            'host' => '127.0.0.1', 'unix_socket' => '', 'url' => null,
            'port' => 43330, 'approved_port' => 43330,
        ], $overrides);
        $this->app->instance('env', $case['environment']);
        config([
            'rtc_guard.enabled' => $case['rtc_enabled'],
            'restoration.enabled' => $case['consent_enabled'],
            'restoration.port' => $case['approved_port'],
            'database.default' => 'rtc_gate',
            'database.connections.rtc_gate' => ['driver' => $case['driver'], 'url' => $case['url']],
        ]);

        // Both RTC and the real Consent gate inspect only this mocked connection metadata.
        $connection = Mockery::mock(Connection::class);
        $connection->shouldReceive('getDriverName')->andReturn($case['driver']);
        $connection->shouldReceive('getDatabaseName')->andReturn($case['database']);
        foreach (['host', 'unix_socket', 'port'] as $key) {
            $connection->shouldReceive('getConfig')->with($key)->andReturn($case[$key]);
        }
        DB::shouldReceive('connection')->andReturn($connection);

        $this->assertSame($expected, (new RtcAuthorityService)->enabled());
    }

    public static function gateCases(): array
    {
        return [
            'cloud mariadb' => [[], true],
            'cloud mysql' => [['driver' => 'mysql'], true],
            'original rtc pair' => [['database' => 'elitesync_v1009_dev', 'port' => 43319, 'approved_port' => 43319], true],
            'cloud database with old port' => [['port' => 43319, 'approved_port' => 43319], false],
            'old database with cloud port' => [['database' => 'elitesync_v1009_dev'], false],
            'older consent pair is not rtc pair' => [['database' => 'elitesync_v1008_dev', 'port' => 43318, 'approved_port' => 43318], false],
            'unknown database' => [['database' => 'unknown_dev'], false],
            'production database' => [['database' => 'elitesync'], false],
            'wrong approved consent port' => [['approved_port' => 43319], false],
            'default database port' => [['port' => 3306, 'approved_port' => 3306], false],
            'nonloopback host' => [['host' => '192.0.2.1'], false],
            'localhost alias' => [['host' => 'localhost'], false],
            'URL override rejected by consent' => [['url' => 'mysql://example.invalid/elitesync'], false],
            'socket override rejected by consent' => [['unix_socket' => '/tmp/other-db.sock'], false],
            'disabled consent gate' => [['consent_enabled' => false], false],
            'disabled rtc flag' => [['rtc_enabled' => false], false],
            'production environment' => [['environment' => 'production'], false],
            'unknown environment' => [['environment' => 'staging'], false],
            'unsupported driver' => [['driver' => 'pgsql'], false],
            'testing sqlite unchanged' => [['environment' => 'testing', 'driver' => 'sqlite'], true],
            'testing mariadb denied' => [['environment' => 'testing'], false],
        ];
    }
}
