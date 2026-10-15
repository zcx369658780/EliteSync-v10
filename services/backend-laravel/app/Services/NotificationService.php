<?php

namespace App\Services;

use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\Conversation;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Throwable;

class NotificationService
{
    public const MESSAGE_TITLE = '有一条新消息';

    public const MESSAGE_BODY = '请打开会话查看，读取前会验证当前权限。';

    private function isPrivateMessage(string $kind, array $payload): bool
    {
        return $kind === 'message' || ($payload['source'] ?? '') === 'message'
            || ($payload['route_name'] ?? '') === 'chat_room' || array_key_exists('message_id', $payload);
    }

    /** Never serialize legacy message text, names or caller-supplied navigation. */
    public function presentationForUser(AppNotificationItem $notification, int $viewerId): array
    {
        $payload = (array) ($notification->payload ?? []);
        if (! $this->isPrivateMessage((string) $notification->kind, $payload)) {
            return ['title' => $notification->title, 'body' => $notification->body ?? '', 'payload' => $payload];
        }
        $safe = ['title' => self::MESSAGE_TITLE, 'body' => self::MESSAGE_BODY, 'payload' => []];
        $messageId = filter_var($payload['message_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        $authority = app(LiveConsentService::class);
        if ((int) $notification->user_id !== $viewerId || ! $messageId || ! $authority->enabled()) {
            return $safe;
        }
        try {
            return DB::transaction(function () use ($messageId, $viewerId, $authority, $safe) {
                $message = ChatMessage::query()->select(['id', 'sender_id', 'receiver_id', 'room_id'])->find($messageId);
                if (! $message || (int) $message->receiver_id !== $viewerId
                    || ! ($authority->gates($viewerId, (int) $message->sender_id)['live_read_allowed'] ?? false)) {
                    return $safe;
                }
                $conversation = Conversation::query()->where('room_key', $message->room_id)->first(['id']);
                if (! $conversation) {
                    return $safe;
                }

                // The immutable message binds receiver, peer and room. The payload cannot grant access.
                return array_replace($safe, ['payload' => ['source' => 'message', 'route_name' => 'chat_room',
                    'route_args' => ['conversation_id' => (string) $conversation->id]]]);
            });
        } catch (Throwable) {
            return $safe; // Unknown/current-reader failures are not notification access grants.
        }
    }

    private function payloadSignature(array $payload): string
    {
        return json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '{}';
    }

    public function createForUser(
        int $userId,
        string $kind,
        string $title,
        ?string $body = null,
        array $payload = [],
        ?string $expiresAt = null,
    ): AppNotificationItem {
        $normalizedKind = mb_substr(trim($kind), 0, 32);
        $normalizedTitle = mb_substr(trim($title), 0, 120);
        $normalizedBody = $body !== null ? trim($body) : null;
        if ($this->isPrivateMessage($normalizedKind, $payload)) {
            $normalizedTitle = self::MESSAGE_TITLE;
            $normalizedBody = self::MESSAGE_BODY;
            $messageId = filter_var($payload['message_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
            $payload = ['source' => 'message'] + ($messageId ? ['message_id' => $messageId] : []);
        }
        $payloadSignature = $this->payloadSignature($payload);

        $existing = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->where('kind', $normalizedKind)
            ->where('title', $normalizedTitle)
            ->where(function ($query) use ($normalizedBody) {
                if ($normalizedBody === null) {
                    $query->whereNull('body');

                    return;
                }
                $query->where('body', $normalizedBody);
            })
            ->whereRaw('payload = ?', [$payloadSignature])
            ->where('created_at', '>=', now()->subMinutes(5))
            ->first();

        if ($existing) {
            return $existing;
        }

        return AppNotificationItem::query()->create([
            'user_id' => $userId,
            'kind' => $normalizedKind,
            'title' => $normalizedTitle,
            'body' => $normalizedBody,
            'payload' => $payload,
            'read_at' => null,
            'expires_at' => $expiresAt,
        ]);
    }

    /**
     * @return Collection<int, AppNotificationItem>
     */
    public function listForUser(int $userId, int $limit = 50): Collection
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->orderByDesc('id')
            ->limit($limit)
            ->get();
    }

    public function unreadCount(int $userId): int
    {
        return (int) AppNotificationItem::query()
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->count();
    }

    public function markRead(int $userId, int $notificationId): ?AppNotificationItem
    {
        $notification = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->find($notificationId);

        if (! $notification) {
            return null;
        }

        if ($notification->read_at === null) {
            $notification->forceFill(['read_at' => now()])->save();
        }

        return $notification;
    }

    public function markAllRead(int $userId): int
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }
}
