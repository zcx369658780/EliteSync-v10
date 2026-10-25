<?php

namespace Tests\Feature;

use App\Services\LiveConsentService;
use App\Services\PlatformAccess;
use App\Services\RtcAuthorityService;
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Mockery;
use PHPUnit\Framework\Attributes\DataProvider;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Tests\TestCase;

/** Configuration-only guard tests: never connect to a simulated database. */
final class V1015LocalEnvironmentTest extends TestCase
{
    public static function selectors(): array
    {
        return [
            'owned exact pair' => [[], 'local', true, true],
            'unknown database' => [['database' => 'unowned'], 'local', false, false],
            'wrong pair port' => [['port' => 43329], 'local', false, false],
            'old server port' => [['port' => 3306], 'local', false, false],
            'non loopback' => [['host' => '192.0.2.1'], 'local', false, false],
            'socket supplied' => [['unix_socket' => 'unowned.sock'], 'local', false, false],
            'production environment' => [[], 'production', false, false],
            'restoration port mismatch' => [[], 'local', false, true, 43329],
        ];
    }

    #[DataProvider('selectors')]
    public function test_exact_owned_selector_and_rejection_boundaries(array $changes, string $environment,
        bool $liveAllowed, bool $platformAllowed, int $restorationPort = 43328): void
    {
        $selector = array_replace(['driver' => 'mysql', 'database' => 'elitesync_v1015_long_dev',
            'port' => 43328, 'host' => '127.0.0.1', 'url' => null, 'unix_socket' => ''], $changes);
        $connection = Mockery::mock(Connection::class);
        $connection->shouldReceive('getDriverName')->andReturn($selector['driver']);
        $connection->shouldReceive('getDatabaseName')->andReturn($selector['database']);
        $connection->shouldReceive('getConfig')->andReturnUsing(fn ($key) => $selector[$key] ?? null);
        DB::shouldReceive('connection')->andReturn($connection);
        $this->app['env'] = $environment;
        config(['restoration.enabled' => true, 'restoration.port' => $restorationPort, 'rtc_guard.enabled' => true]);

        $this->assertSame($liveAllowed, app(LiveConsentService::class)->enabled());
        $this->assertSame($liveAllowed, app(RtcAuthorityService::class)->enabled());
        try {
            app(PlatformAccess::class)->gate();
            $this->assertTrue($platformAllowed);
        } catch (HttpExceptionInterface $error) {
            $this->assertFalse($platformAllowed);
            $this->assertSame(404, $error->getStatusCode());
        }
    }

    public function test_platform_url_override_is_rejected(): void
    {
        $connection = Mockery::mock(Connection::class);
        $connection->shouldReceive('getDriverName')->andReturn('mysql');
        $connection->shouldReceive('getDatabaseName')->andReturn('elitesync_v1015_long_dev');
        $connection->shouldReceive('getConfig')->andReturnUsing(fn ($key) => [
            'port' => 43328, 'host' => '127.0.0.1', 'url' => 'mysql://invalid.example/unowned', 'unix_socket' => '',
        ][$key] ?? null);
        DB::shouldReceive('connection')->andReturn($connection);
        $this->app['env'] = 'local';
        $this->expectException(HttpExceptionInterface::class);
        app(PlatformAccess::class)->gate();
    }
}
