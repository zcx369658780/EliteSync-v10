<?php

namespace App\Services;

use App\Models\ChatMessage;
use App\Models\Conversation;
use App\Models\ConversationMatchLink;
use App\Models\ConversationMember;
use App\Models\MediaAsset;
use App\Models\MessageAttachment;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class ConversationAtomicSendService
{
    public function __construct(
        private readonly ConversationCapabilityService $capabilities,
        private readonly ConversationDomainService $domain,
        private readonly EventLogger $events,
        private readonly NotificationService $notifications,
    ) {}

    public function fingerprint(int $receiverId, string $content, array $attachmentIds): string
    {
        return hash('sha256', json_encode([
            'receiver_id' => $receiverId,
            'content' => $content,
            'attachment_ids' => array_values($attachmentIds),
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
    }

    /** @return array<string, mixed>|null */
    public function replay(int $senderId, string $clientMessageId, string $fingerprint): ?array
    {
        $message = ChatMessage::query()
            ->where('sender_id', $senderId)
            ->where('client_message_id', $clientMessageId)
            ->first();

        return $message ? $this->replayResult($message, $fingerprint) : null;
    }

    /** @return array<string, mixed> */
    public function preflightAttachments(int $senderId, array $attachmentIds): array
    {
        if ($attachmentIds === []) {
            return ['ok' => true];
        }

        $assets = MediaAsset::query()->whereIn('id', $attachmentIds)->get()->keyBy('id');
        foreach ($attachmentIds as $id) {
            $asset = $assets->get($id);
            if (!$asset || (int) $asset->owner_user_id !== $senderId) {
                return ['ok' => false, 'status' => 422, 'code' => 'attachment_unavailable'];
            }
        }
        foreach ($attachmentIds as $id) {
            if ((string) $assets->get($id)->status !== 'ready') {
                return ['ok' => false, 'status' => 409, 'code' => 'attachment_not_ready', 'retry_safe' => true];
            }
        }

        return ['ok' => true];
    }

    /** @return array<string, mixed> */
    public function send(
        User $sender,
        int $receiverId,
        string $content,
        array $attachmentIds,
        ?string $clientMessageId,
        ?string $fingerprint,
        string $appVersion,
        string $sourcePage,
    ): array {
        return DB::transaction(function () use ($sender, $receiverId, $content, $attachmentIds, $clientMessageId, $fingerprint, $appVersion, $sourcePage) {
            if ($clientMessageId !== null) {
                $replay = $this->replay((int) $sender->id, $clientMessageId, (string) $fingerprint);
                if ($replay) {
                    return $replay;
                }
            }

            $authorization = $this->capabilities->authorizeSend((int) $sender->id, $receiverId, true);
            if (!$authorization['allowed']) {
                return ['ok' => false, 'status' => 404, 'message' => 'chat unavailable'];
            }

            $assetsResult = $this->lockedReadyAssets((int) $sender->id, $attachmentIds);
            if (!$assetsResult['ok']) {
                return $assetsResult;
            }

            $roomKey = $this->domain->roomKey((int) $sender->id, $receiverId);
            Conversation::query()->firstOrCreate(
                ['room_key' => $roomKey],
                [
                    'room_type' => 'direct',
                    'title' => null,
                    'status' => 'active',
                    'created_by' => (int) $sender->id,
                ],
            );
            $conversation = Conversation::query()
                ->where('room_key', $roomKey)
                ->lockForUpdate()
                ->firstOrFail();

            foreach ([(int) $sender->id, $receiverId] as $memberId) {
                ConversationMember::query()->firstOrCreate(
                    ['conversation_id' => $conversation->id, 'user_id' => $memberId],
                    ['role' => 'member', 'joined_at' => now(), 'left_at' => null],
                );
                $member = ConversationMember::query()
                    ->where('conversation_id', $conversation->id)
                    ->where('user_id', $memberId)
                    ->lockForUpdate()
                    ->firstOrFail();
                if ($member->left_at !== null) {
                    throw new RuntimeException('departed conversation member');
                }
            }

            $matchId = (int) $authorization['dating_match_id'];
            ConversationMatchLink::query()->firstOrCreate(
                ['dating_match_id' => $matchId],
                ['conversation_id' => $conversation->id, 'linked_at' => now()],
            );
            $link = ConversationMatchLink::query()
                ->where('dating_match_id', $matchId)
                ->lockForUpdate()
                ->firstOrFail();
            if ((int) $link->conversation_id !== (int) $conversation->id) {
                throw new RuntimeException('match link conversation invariant violation');
            }

            if ($clientMessageId === null) {
                $message = ChatMessage::query()->create([
                    'room_id' => $roomKey,
                    'sender_id' => (int) $sender->id,
                    'receiver_id' => $receiverId,
                    'content' => $content,
                    'client_message_id' => $clientMessageId,
                    'request_fingerprint' => $fingerprint,
                ]);
            } else {
                $message = ChatMessage::query()->firstOrCreate(
                    ['sender_id' => (int) $sender->id, 'client_message_id' => $clientMessageId],
                    [
                        'room_id' => $roomKey,
                        'receiver_id' => $receiverId,
                        'content' => $content,
                        'request_fingerprint' => $fingerprint,
                    ],
                );
                if (!$message->wasRecentlyCreated) {
                    return $this->replayResult($message, (string) $fingerprint);
                }
            }

            foreach ($attachmentIds as $index => $assetId) {
                $asset = $assetsResult['assets']->get($assetId);
                MessageAttachment::query()->create([
                    'message_id' => $message->id,
                    'media_asset_id' => $asset->id,
                    'attachment_type' => $this->attachmentType((string) $asset->media_type),
                    'sort_order' => $index,
                    'metadata' => ['media_type' => (string) $asset->media_type, 'status' => (string) $asset->status],
                ]);
            }

            $conversation->forceFill([
                'last_message_id' => $message->id,
                'last_sender_id' => (int) $sender->id,
                'last_message_at' => $message->created_at ?? now(),
            ])->save();
            ConversationMember::query()
                ->where('conversation_id', $conversation->id)
                ->where('user_id', $sender->id)
                ->update(['last_read_message_id' => $message->id, 'last_read_at' => $message->created_at ?? now()]);

            $this->events->log(
                eventName: 'message_sent',
                actorUserId: (int) $sender->id,
                targetUserId: $receiverId,
                matchId: $matchId,
                payload: [
                    'message_id' => (int) $message->id,
                    'conversation_id' => (int) $conversation->id,
                    'dating_match_id' => $matchId,
                    'attachment_count' => count($attachmentIds),
                    'app_version' => $appVersion,
                    'source_page' => $sourcePage,
                ],
            );

            $senderName = trim((string) ($sender->nickname ?? $sender->name ?? $sender->phone ?? '有人'));
            $message->load('attachments.mediaAsset');
            $this->notifications->createForUser(
                userId: $receiverId,
                kind: 'message',
                title: "{$senderName} 发来一条消息",
                body: $this->notificationBody($message),
                payload: [
                    'route_name' => 'chat_room',
                    'route_args' => ['conversation_id' => (string) $conversation->id, 'title' => $senderName],
                    'message_id' => (int) $message->id,
                    'peer_user_id' => (int) $sender->id,
                    'source' => 'message',
                ],
            );

            return [
                'ok' => true,
                'message' => $message,
                'conversation_id' => (int) $conversation->id,
                'client_message_id' => $clientMessageId,
                'idempotent_replay' => false,
            ];
        });
    }

    /** @return array<string, mixed> */
    private function lockedReadyAssets(int $senderId, array $attachmentIds): array
    {
        if ($attachmentIds === []) {
            return ['ok' => true, 'assets' => collect()];
        }
        $assets = MediaAsset::query()->whereIn('id', $attachmentIds)->lockForUpdate()->get()->keyBy('id');
        foreach ($attachmentIds as $id) {
            $asset = $assets->get($id);
            if (!$asset || (int) $asset->owner_user_id !== $senderId) {
                return ['ok' => false, 'status' => 422, 'code' => 'attachment_unavailable'];
            }
        }
        foreach ($attachmentIds as $id) {
            if ((string) $assets->get($id)->status !== 'ready') {
                return ['ok' => false, 'status' => 409, 'code' => 'attachment_not_ready', 'retry_safe' => true];
            }
        }
        return ['ok' => true, 'assets' => $assets];
    }

    /** @return array<string, mixed> */
    private function replayResult(ChatMessage $message, string $fingerprint): array
    {
        if (!hash_equals((string) $message->request_fingerprint, $fingerprint)) {
            return [
                'ok' => false,
                'status' => 409,
                'message' => 'client message id payload mismatch',
                'code' => 'client_message_id_payload_mismatch',
            ];
        }
        $conversation = Conversation::query()->where('room_key', $message->room_id)->first();
        if (!$conversation) {
            throw new RuntimeException('idempotent message conversation missing');
        }
        return [
            'ok' => true,
            'message' => $message->load('attachments.mediaAsset'),
            'conversation_id' => (int) $conversation->id,
            'client_message_id' => (string) $message->client_message_id,
            'idempotent_replay' => true,
        ];
    }

    private function attachmentType(string $mediaType): string
    {
        return str_starts_with($mediaType, 'video') || $mediaType === 'video'
            ? 'video'
            : (str_starts_with($mediaType, 'image') || $mediaType === 'image' ? 'image' : 'media');
    }

    private function notificationBody(ChatMessage $message): string
    {
        $content = trim((string) $message->content);
        if ($content !== '') {
            return mb_strimwidth($content, 0, 90, '…', 'UTF-8');
        }
        $types = $message->attachments->map(fn ($item) => (string) ($item->mediaAsset?->media_type ?? ''));
        if ($types->contains(fn ($type) => str_starts_with($type, 'video') || $type === 'video')) {
            return '发送了一条视频消息';
        }
        if ($types->contains(fn ($type) => str_starts_with($type, 'image') || $type === 'image')) {
            return '发送了一条图片消息';
        }
        return $types->isNotEmpty() ? '发送了一条多媒体消息' : '发送了一条新消息';
    }
}
