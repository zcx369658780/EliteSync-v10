<?php

namespace Tests\Feature;

use App\Console\Commands\ChatWebsocketServerCommand;
use App\Services\LunarPhpBaziEngine;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Psr7\Response;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;
use Workerman\Connection\TcpConnection;
use Workerman\Worker;

/** Dependency API compatibility only; no real vendor calls or websocket listener. */
final class FrameworkDependencyCompatibilityTest extends TestCase
{
    public function test_laravel_http_client_uses_the_locked_guzzle_transport_api(): void
    {
        $handler = HandlerStack::create(new MockHandler([
            new Response(200, ['Content-Type' => 'application/json'], '{"test_only":true}'),
            new Response(403, ['Content-Type' => 'application/json'], '{"denied":true}'),
        ]));
        $client = Http::withOptions([])->setHandler($handler);
        $response = $client->post('http://127.0.0.1/never-dispatched', ['synthetic' => true]);
        self::assertTrue($response->successful());
        self::assertTrue($response->json('test_only'));
        self::assertSame(403, $client->get('http://127.0.0.1/never-dispatched')->status());
    }

    public function test_workerman_callback_api_loads_without_starting_a_listener(): void
    {
        $worker = new Worker();
        $callback = static function (TcpConnection $connection, mixed $message): void {};
        $worker->onMessage = $callback;
        self::assertSame($callback, $worker->onMessage);
        self::assertInstanceOf(ChatWebsocketServerCommand::class, app(ChatWebsocketServerCommand::class));
        config(['matching.foundation.websocket_capability_enabled' => false]);
        self::assertSame(1, Artisan::call('chat:ws'));
        self::assertStringContainsString('disabled', Artisan::output());
    }

    public function test_locked_lunar_library_runs_the_application_adapter_without_fallback(): void
    {
        $result = app(LunarPhpBaziEngine::class)->canonicalize([
            'birthday' => '1990-01-01', 'birth_time' => '12:00', 'gender' => 'female',
        ]);
        self::assertContains('canonical_source:lunar_php', $result['notes']);
        self::assertContains('time_source:birth_time', $result['notes']);
        self::assertCount(4, $result['bazi_details']['pillars']);
        self::assertNotEmpty($result['bazi']);
        self::assertLessThanOrEqual(0.65, $result['confidence']);
        foreach ($result['notes'] as $note) {
            self::assertStringNotContainsString('canonical_fallback:', $note);
        }
    }

    public function test_missing_lunar_input_preserves_the_explicit_fallback_boundary(): void
    {
        $result = app(LunarPhpBaziEngine::class)->canonicalize([]);
        self::assertContains('canonical_fallback:missing_birthday_or_birth_time', $result['notes']);
    }
}
