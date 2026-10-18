<?php

namespace Tests\Unit;

use App\Services\ChatWebsocketAuthorizationService;
use Mockery;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;
use Workerman\Protocols\Http\Request;

final class V10100WorkermanHandshakeTest extends TestCase
{
    #[DataProvider('acceptedPaths')]
    public function test_real_workerman_handshake_passes_header_actor_and_peer_to_existing_authorization(string $path): void
    {
        $expected = ['actor_id' => 41, 'peer_id' => 72, 'token_id' => 9];
        $service = Mockery::mock(ChatWebsocketAuthorizationService::class)->makePartial();
        $service->shouldReceive('authorize')->once()
            ->with('Bearer fixture-ws-only', 41, 72)->andReturn($expected);

        $this->assertSame($expected, $service->authorizeRequest($this->handshake($path)));
    }

    #[DataProvider('rejectedPaths')]
    public function test_unknown_or_invalid_path_is_rejected_before_token_or_database_lookup(string $path): void
    {
        $service = Mockery::mock(ChatWebsocketAuthorizationService::class)->makePartial();
        $service->shouldNotReceive('authorize');

        $this->assertNull($service->authorizeRequest($this->handshake($path)));
    }

    public function test_existing_authorization_rejection_is_not_bypassed_by_valid_handshake_shape(): void
    {
        $service = Mockery::mock(ChatWebsocketAuthorizationService::class)->makePartial();
        $service->shouldReceive('authorize')->once()
            ->with('Bearer fixture-ws-only', 41, 72)->andReturnNull();

        $this->assertNull($service->authorizeRequest($this->handshake('/api/v1/messages/ws/41?peer_id=72')));
    }

    public function test_query_token_does_not_replace_the_authorization_header(): void
    {
        $service = Mockery::mock(ChatWebsocketAuthorizationService::class)->makePartial();
        $service->shouldReceive('authorize')->once()->with('', 41, 72)->andReturnNull();

        $request = $this->handshake('/api/v1/messages/ws/41?peer_id=72&token=fixture-ws-only', false);
        $this->assertNull($service->authorizeRequest($request));
    }

    public static function acceptedPaths(): array
    {
        return [
            'scoped API path' => ['/api/v1/messages/ws/41?peer_id=72'],
            'existing short path' => ['/ws/41?peer_id=72'],
        ];
    }

    public static function rejectedPaths(): array
    {
        return [
            'root' => ['/?peer_id=72'],
            'unrelated path' => ['/api/v1/messages/41?peer_id=72'],
            'nonnumeric actor' => ['/api/v1/messages/ws/unknown?peer_id=72'],
            'zero actor' => ['/api/v1/messages/ws/0?peer_id=72'],
            'additional path segment' => ['/api/v1/messages/ws/41/extra?peer_id=72'],
        ];
    }

    private function handshake(string $path, bool $authorization = true): Request
    {
        return new Request("GET {$path} HTTP/1.1\r\n"
            ."Host: example.invalid\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
            ."Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n"
            .($authorization ? "Authorization: Bearer fixture-ws-only\r\n" : '')
            ."\r\n");
    }
}
