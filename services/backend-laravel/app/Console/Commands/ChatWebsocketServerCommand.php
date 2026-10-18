<?php

namespace App\Console\Commands;

use App\Models\ChatMessage;
use App\Services\ChatWebsocketAuthorizationService;
use App\Services\ConversationCapabilityService;
use Illuminate\Console\Command;
use Throwable;
use Workerman\Connection\TcpConnection;
use Workerman\Timer;
use Workerman\Worker;

class ChatWebsocketServerCommand extends Command
{
    protected $signature = 'chat:ws {--host=0.0.0.0} {--port=8081} {--poll=2}';

    protected $description = 'Run lightweight chat websocket gateway based on DB polling';

    private function prepareWorkermanArgv(): void
    {
        $argv = $_SERVER['argv'] ?? [];
        if (!is_array($argv)) {
            $argv = [];
        }

        $lifecycleCommands = ['start', 'stop', 'restart', 'reload', 'status', 'connections'];
        $hasLifecycle = false;
        foreach ($argv as $arg) {
            if (in_array((string) $arg, $lifecycleCommands, true)) {
                $hasLifecycle = true;
                break;
            }
        }

        // Workerman requires a lifecycle command; default to foreground start for systemd.
        if (!$hasLifecycle) {
            $patched = [$argv[0] ?? 'artisan', 'start'];
            $_SERVER['argv'] = $patched;
            $_SERVER['argc'] = 2;
            $GLOBALS['argv'] = $patched;
            $GLOBALS['argc'] = 2;
        }
    }

    public function handle(): int
    {
        if (!(bool) config('matching.foundation.websocket_capability_enabled', false)) {
            $this->error('Chat websocket capability gateway is disabled.');
            return self::FAILURE;
        }
        $host = (string) $this->option('host');
        $port = (int) $this->option('port');
        $pollInterval = max(1, (int) $this->option('poll'));

        $gateway = new Worker("websocket://{$host}:{$port}");
        $gateway->count = 1;
        $gateway->name = 'EliteSyncChatGateway';

        $gateway->onConnect = function (TcpConnection $connection): void {
            $connection->userId = null;
            $connection->peerId = null;
            $connection->tokenId = null;
            $connection->lastSeenId = 0;
        };

        $gateway->onWebSocketConnect = function (TcpConnection $connection, $request): void {
            $authorizationResult = app(ChatWebsocketAuthorizationService::class)->authorizeRequest($request);
            if (!$authorizationResult) {
                $connection->close();

                return;
            }

            $userId = (int) $authorizationResult['actor_id'];
            $peerId = (int) $authorizationResult['peer_id'];
            $connection->userId = $userId;
            $connection->peerId = $peerId;
            $connection->tokenId = (int) $authorizationResult['token_id'];
            $connection->lastSeenId = (int) (ChatMessage::query()
                ->where('receiver_id', $userId)->where('sender_id', $peerId)
                ->max('id') ?? 0);

            $connection->send(json_encode([
                'type' => 'connected',
                'user_id' => $userId,
                'last_seen_id' => $connection->lastSeenId,
            ], JSON_UNESCAPED_UNICODE));
        };

        $gateway->onMessage = function (TcpConnection $connection, string $payload): void {
            if (trim($payload) === 'ping') {
                $connection->send('pong');
            }
        };

        $gateway->onWorkerStart = function () use ($gateway, $pollInterval): void {
            Timer::add($pollInterval, function () use ($gateway): void {
                /** @var TcpConnection $connection */
                foreach ($gateway->connections as $connection) {
                    $userId = (int) ($connection->userId ?? 0);
                    $peerId = (int) ($connection->peerId ?? 0);
                    $tokenId = (int) ($connection->tokenId ?? 0);
                    if ($userId <= 0 || $peerId <= 0 || $tokenId <= 0 || !app(ChatWebsocketAuthorizationService::class)->reauthorize($tokenId, $userId, $peerId)) {
                        $connection->close();
                        continue;
                    }

                    try {
                        $messages = ChatMessage::query()
                            ->where('receiver_id', $userId)
                            ->where('sender_id', $peerId)
                            ->where('id', '>', (int) ($connection->lastSeenId ?? 0))
                            ->orderBy('id')
                            ->limit(50)
                            ->get(['id', 'sender_id', 'receiver_id', 'content', 'created_at']);
                    } catch (Throwable) {
                        continue;
                    }

                    foreach ($messages as $message) {
                        $connection->send(json_encode([
                            'type' => 'message',
                            'id' => $message->id,
                            'sender_id' => $message->sender_id,
                            'receiver_id' => $message->receiver_id,
                            'content' => $message->content,
                            'created_at' => optional($message->created_at)->toIso8601String(),
                        ], JSON_UNESCAPED_UNICODE));
                        $connection->lastSeenId = $message->id;
                    }
                }
            });
        };

        $this->info("Chat websocket gateway running at ws://{$host}:{$port}");
        $this->info('Authenticated scoped path: /api/v1/messages/ws/{userId}?peer_id={peerId}');
        $this->prepareWorkermanArgv();
        Worker::$pidFile = storage_path('logs/chat-gateway.pid');
        Worker::$logFile = storage_path('logs/chat-gateway.log');
        Worker::$stdoutFile = storage_path('logs/chat-gateway.stdout.log');
        Worker::runAll();

        return self::SUCCESS;
    }
}
