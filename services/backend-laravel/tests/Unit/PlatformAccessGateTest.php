<?php

namespace Tests\Unit;

use App\Services\PlatformAccess;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class PlatformAccessGateTest extends TestCase
{
    private function connection(string $database, int $port, array $overrides = []): void
    {
        $this->app['env'] = 'local';
        config(['database.default' => 'platform_gate_test', 'database.connections.platform_gate_test' => array_merge([
            'driver' => 'mysql', 'host' => '127.0.0.1', 'port' => $port, 'database' => $database,
            'username' => 'unused', 'password' => '', 'url' => null, 'unix_socket' => null,
        ], $overrides)]);
        DB::purge('platform_gate_test');
    }

    public function test_original_database_and_port_remain_the_defaults(): void
    {
        $this->connection('elitesync_v10_1_4_dev', 43325);
        app(PlatformAccess::class)->gate();
        self::assertTrue(true); // No connection/query occurs: the contract checks configuration only.
    }

    public function test_current_database_requires_explicit_exact_pair(): void
    {
        $this->connection('elitesync_v10_1_5_dev', 43326);
        config(['platform_events.database' => 'elitesync_v10_1_5_dev', 'platform_events.port' => 43326]);
        app(PlatformAccess::class)->gate();
        self::assertTrue(true);
    }

    public function test_new_database_is_denied_without_explicit_configuration(): void
    {
        $this->connection('elitesync_v10_1_5_dev', 43326);
        $this->expectException(HttpException::class);
        app(PlatformAccess::class)->gate();
    }

    public function test_production_wrong_pair_remote_url_and_socket_stay_denied(): void
    {
        config(['platform_events.database' => 'elitesync_v10_1_5_dev', 'platform_events.port' => 43326]);
        foreach ([
            ['production', 'elitesync_v10_1_5_dev', 43326, []],
            ['local', 'elitesync_v10_1_4_dev', 43326, []],
            ['local', 'unrelated_dev', 43326, []],
            ['local', 'elitesync_v10_1_5_dev', 3306, []],
            ['local', 'elitesync_v10_1_5_dev', 43326, ['host' => '192.0.2.1']],
            ['local', 'elitesync_v10_1_5_dev', 43326, ['url' => 'mysql://unused@127.0.0.1:43326/elitesync_v10_1_5_dev']],
            ['local', 'elitesync_v10_1_5_dev', 43326, ['unix_socket' => '/tmp/not-used.sock']],
        ] as [$env, $db, $port, $overrides]) {
            $this->connection($db, $port, $overrides); $this->app['env'] = $env;
            try {
                app(PlatformAccess::class)->gate(); self::fail('Unexpected platform gate grant: '.$env.' '.$db.' '.$port.' '.json_encode($overrides));
            } catch (HttpException $e) { self::assertSame(404, $e->getStatusCode()); }
        }
    }
}
