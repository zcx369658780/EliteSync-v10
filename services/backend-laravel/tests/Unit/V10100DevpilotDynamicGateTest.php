<?php

namespace Tests\Unit;

use App\Http\Middleware\PrivateDynamicCharts;
use App\Services\DynamicChartService;
use Illuminate\Http\Request;
use PHPUnit\Framework\Attributes\DataProvider;
use RuntimeException;
use Tests\TestCase;

class V10100DevpilotDynamicGateTest extends TestCase
{
    #[DataProvider('gateCases')]
    public function test_gate_before_any_calculation_or_database_access(array $overrides, string $expected): void
    {
        $this->configureGate($overrides);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage($expected);
        // Empty input stops admitted cases at runtime identity, before Process is constructed.
        app(DynamicChartService::class)->compute([]);
    }

    #[DataProvider('gateCases')]
    public function test_get_collection_and_item_share_the_calculation_gate(array $overrides, string $expected): void
    {
        $this->configureGate($overrides);
        $admitted = $expected === 'dynamic_runtime_unavailable';

        foreach (['/api/v1/profile/dynamic', '/api/v1/profile/dynamic/123'] as $path) {
            $reachedHandler = false;
            $response = app(PrivateDynamicCharts::class)->handle(Request::create($path, 'GET'),
                function () use (&$reachedHandler) {
                    $reachedHandler = true;

                    return response()->json(['test_handler' => true]);
                });

            $this->assertSame($admitted, $reachedHandler, $path);
            $this->assertSame($admitted ? 200 : 403, $response->getStatusCode());
            $this->assertTrue($response->headers->hasCacheControlDirective('private'));
            $this->assertTrue($response->headers->hasCacheControlDirective('no-store'));
            if (! $admitted) {
                $this->assertSame(['code' => 'dynamic_environment_not_admitted'],
                    json_decode($response->getContent(), true));
            }
        }
    }

    private function configureGate(array $overrides): void
    {
        $this->app->instance('env', $overrides['environment'] ?? 'local');
        unset($overrides['environment']);
        config([
            'dynamic_charts.enabled' => true,
            'dynamic_charts.database' => 'elitesync_v1011_dev',
            'database.default' => 'dynamic_gate',
            'database.connections.dynamic_gate' => [
                'driver' => 'mysql', 'database' => 'elitesync_v1011_dev',
                'host' => '127.0.0.1', 'url' => null, 'unix_socket' => '',
            ],
        ]);
        config($overrides);
    }

    public static function gateCases(): array
    {
        $cloud = [
            'dynamic_charts.database' => 'elitesync_v1010_devpilot',
            'database.connections.dynamic_gate.database' => 'elitesync_v1010_devpilot',
            'database.connections.dynamic_gate.driver' => 'mariadb',
        ];
        $databaseDenied = 'dynamic_database_not_admitted';
        $runtimeDenied = 'dynamic_runtime_not_admitted';
        $admitted = 'dynamic_runtime_unavailable';

        return [
            'original development database' => [[], $admitted],
            'cloud development database' => [$cloud, $admitted],
            'cloud database requires explicit selection' => [[
                'database.connections.dynamic_gate.database' => 'elitesync_v1010_devpilot',
            ], $databaseDenied],
            'unknown database cannot authorize itself' => [[
                'dynamic_charts.database' => 'unknown_dev',
                'database.connections.dynamic_gate.database' => 'unknown_dev',
            ], $databaseDenied],
            'production database cannot authorize itself' => [[
                'dynamic_charts.database' => 'elitesync',
                'database.connections.dynamic_gate.database' => 'elitesync',
            ], $databaseDenied],
            'cloud selection cannot admit production database' => [[...$cloud,
                'database.connections.dynamic_gate.database' => 'elitesync_production',
            ], $databaseDenied],
            'remote host' => [[...$cloud,
                'database.connections.dynamic_gate.host' => '192.0.2.1',
            ], $databaseDenied],
            'localhost alias is not explicit loopback' => [[...$cloud,
                'database.connections.dynamic_gate.host' => 'localhost',
            ], $databaseDenied],
            'connection URL cannot override checked identity' => [[...$cloud,
                'database.connections.dynamic_gate.url' => 'mysql://example.invalid/elitesync',
            ], $databaseDenied],
            'socket cannot override checked host' => [[...$cloud,
                'database.connections.dynamic_gate.unix_socket' => '/tmp/other-db.sock',
            ], $databaseDenied],
            'unsupported driver' => [[...$cloud,
                'database.connections.dynamic_gate.driver' => 'pgsql',
            ], $databaseDenied],
            'disabled cloud runtime' => [[...$cloud, 'dynamic_charts.enabled' => false], $runtimeDenied],
            'production environment' => [[...$cloud, 'environment' => 'production'], $runtimeDenied],
            'unknown environment' => [[...$cloud, 'environment' => 'staging'], $runtimeDenied],
            'testing in-memory sqlite contract' => [[
                'environment' => 'testing',
                'database.connections.dynamic_gate' => ['driver' => 'sqlite', 'database' => ':memory:'],
            ], $admitted],
            'local sqlite is refused' => [[
                'database.connections.dynamic_gate' => ['driver' => 'sqlite', 'database' => ':memory:'],
            ], $databaseDenied],
            'testing cannot admit an unknown real database' => [[
                'environment' => 'testing',
                'dynamic_charts.database' => 'unknown_dev',
                'database.connections.dynamic_gate.database' => 'unknown_dev',
            ], $databaseDenied],
        ];
    }
}
