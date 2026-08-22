<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\MessageAttachment;
use App\Models\User;
use App\Services\ConversationAtomicSendService;
use App\Services\ConversationDomainService;
use App\Services\ConversationCapabilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    private function roomId(int $a, int $b): string
    {
        $x = min($a, $b);
        $y = max($a, $b);

        return "{$x}_{$y}";
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeAttachment(MessageAttachment $attachment): array
    {
        $asset = $attachment->mediaAsset;

        return [
            'id' => (int) $attachment->id,
            'attachment_type' => (string) $attachment->attachment_type,
            'sort_order' => (int) $attachment->sort_order,
            'metadata' => $attachment->metadata ?? null,
            'media_asset' => $asset ? [
                'id' => (int) $asset->id,
                'owner_user_id' => (int) $asset->owner_user_id,
                'media_type' => (string) $asset->media_type,
                'storage_provider' => (string) $asset->storage_provider,
                'storage_disk' => (string) $asset->storage_disk,
                'storage_key' => (string) $asset->storage_key,
                'mime_type' => $asset->mime_type,
                'size_bytes' => (int) $asset->size_bytes,
                'width' => $asset->width,
                'height' => $asset->height,
                'duration_ms' => $asset->duration_ms,
                'status' => (string) $asset->status,
                'error_code' => $asset->error_code,
                'error_message' => $asset->error_message,
                'public_url' => $asset->public_url,
                'metadata' => $asset->metadata ?? null,
                'uploaded_at' => optional($asset->uploaded_at)?->toISOString(),
                'processed_at' => optional($asset->processed_at)?->toISOString(),
            ] : null,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeMessage(ChatMessage $message): array
    {
        $message->loadMissing(['attachments.mediaAsset']);

        $attachments = $message->attachments
            ->sortBy('sort_order')
            ->values()
            ->map(fn (MessageAttachment $attachment) => $this->shapeAttachment($attachment))
            ->all();
        $hasVideoAttachments = collect($attachments)->contains(function (array $attachment): bool {
            $mediaType = (string) ($attachment['media_asset']['media_type'] ?? '');

            return str_starts_with($mediaType, 'video') || $mediaType === 'video';
        });
        $hasImageAttachments = collect($attachments)->contains(function (array $attachment): bool {
            $mediaType = (string) ($attachment['media_asset']['media_type'] ?? '');

            return str_starts_with($mediaType, 'image') || $mediaType === 'image';
        });

        return [
            'id' => (int) $message->id,
            'room_id' => (string) $message->room_id,
            'sender_id' => (int) $message->sender_id,
            'receiver_id' => (int) $message->receiver_id,
            'content' => (string) $message->content,
            'client_message_id' => $message->client_message_id,
            'is_read' => (bool) $message->is_read,
            'read_at' => optional($message->read_at)?->toISOString(),
            'created_at' => optional($message->created_at)?->toISOString(),
            'message_type' => $hasVideoAttachments
                ? 'video'
                : ($hasImageAttachments ? 'image' : (!empty($attachments) ? 'media' : 'text')),
            'has_attachments' => !empty($attachments),
            'attachments' => $attachments,
        ];
    }

    public function send(Request $request, ConversationAtomicSendService $service): JsonResponse
    {
        $data = $request->validate([
            'receiver_id' => ['required', 'integer', 'min:1'],
            'content' => ['nullable', 'string', 'max:5000'],
            'attachment_ids' => ['nullable', 'array'],
            'attachment_ids.*' => ['integer', 'distinct'],
            'client_message_id' => ['nullable', 'string', 'size:36', 'regex:/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/'],
        ]);

        $user = $request->user();
        $receiverId = (int) $data['receiver_id'];
        $content = trim((string) ($data['content'] ?? ''));
        $attachmentIds = array_values(array_unique(array_map('intval', $data['attachment_ids'] ?? [])));
        $clientMessageId = isset($data['client_message_id']) ? (string) $data['client_message_id'] : null;
        $fingerprint = $clientMessageId !== null
            ? $service->fingerprint($receiverId, $content, $attachmentIds)
            : null;

        if ($receiverId === (int) $user->id) {
            return response()->json(['message' => 'cannot message self'], 422);
        }

        if ($clientMessageId !== null) {
            $replay = $service->replay((int) $user->id, $clientMessageId, (string) $fingerprint);
            if ($replay !== null) {
                return $this->sendResponse($replay);
            }
        }

        if ($content === '' && empty($attachmentIds)) {
            return response()->json([
                'message' => 'content or attachment_ids is required',
            ], 422);
        }

        $preflight = $service->preflightAttachments((int) $user->id, $attachmentIds);
        if (!$preflight['ok']) {
            return $this->sendResponse($preflight);
        }

        return $this->sendResponse($service->send(
            sender: $user,
            receiverId: $receiverId,
            content: $content,
            attachmentIds: $attachmentIds,
            clientMessageId: $clientMessageId,
            fingerprint: $fingerprint,
            appVersion: (string) $request->header('X-App-Version', 'unknown'),
            sourcePage: (string) $request->header('X-Source-Page', 'unknown'),
        ));
    }

    /** @param array<string, mixed> $result */
    private function sendResponse(array $result): JsonResponse
    {
        if (!$result['ok']) {
            $body = ['message' => $result['message'] ?? str_replace('_', ' ', (string) $result['code'])];
            if (isset($result['code'])) $body['code'] = $result['code'];
            if (isset($result['retry_safe'])) $body['retry_safe'] = $result['retry_safe'];
            return response()->json($body, (int) $result['status']);
        }

        /** @var ChatMessage $message */
        $message = $result['message'];
        return response()->json([
            'id' => (int) $message->id,
            'ok' => true,
            'conversation_id' => (int) $result['conversation_id'],
            'client_message_id' => $result['client_message_id'],
            'idempotent_replay' => (bool) $result['idempotent_replay'],
            'message' => $this->shapeMessage($message),
        ]);
    }

    public function list(Request $request, ConversationDomainService $conversationService, ConversationCapabilityService $capabilities): JsonResponse
    {
        $data = $request->validate([
            'peer_id' => ['required', 'integer', 'min:1'],
            'after_id' => ['nullable', 'integer', 'min:0'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $user = $request->user();
        $peerId = (int) $data['peer_id'];

        if (!$capabilities->canRead((int) $user->id, $peerId)) {
            return response()->json(['message' => 'chat unavailable'], 404);
        }

        $afterId = (int) ($data['after_id'] ?? 0);
        $limit = (int) ($data['limit'] ?? 50);
        $roomId = $this->roomId((int) $user->id, $peerId);

        // Pulling conversation acts as read receipt for incoming unread messages.
        ChatMessage::query()
            ->where('room_id', $roomId)
            ->where('sender_id', $peerId)
            ->where('receiver_id', (int) $user->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        $lastMessage = ChatMessage::query()
            ->where('room_id', $roomId)
            ->orderByDesc('id')
            ->first();
        if ($lastMessage) {
            $conversationService->markReadForPair((int) $user->id, $peerId, (int) $lastMessage->id);
        }

        $items = ChatMessage::query()
            ->with(['attachments.mediaAsset'])
            ->where('room_id', $roomId)
            ->where('id', '>', $afterId)
            ->orderBy('id')
            ->limit($limit)
            ->get(['id', 'sender_id', 'receiver_id', 'content', 'is_read', 'created_at']);

        return response()->json([
            'items' => $items->map(fn (ChatMessage $message) => $this->shapeMessage($message))->values(),
            'total' => $items->count(),
        ]);
    }

    public function markRead(Request $request, int $messageId, ConversationCapabilityService $capabilities): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $message = ChatMessage::find($messageId);

        if (!$message || (int) $message->receiver_id !== (int) $user->id) {
            return response()->json(['message' => 'message not found'], 404);
        }
        if (!$capabilities->canRead((int) $user->id, (int) $message->sender_id)) {
            return response()->json(['message' => 'message not found'], 404);
        }

        if (!$message->is_read) {
            $message->is_read = true;
            $message->read_at = now();
            $message->save();
        }

        return response()->json(['ok' => true]);
    }

    public function websocketStub(Request $request, int $userId): JsonResponse
    {
        if ((int) $request->user()->id !== $userId) return response()->json(['message' => 'not found'], 404);
        if (!(bool) config('matching.foundation.websocket_capability_enabled', false)) return response()->json(['message' => 'websocket capability unavailable', 'retry_safe' => true], 503);
        return response()->json([
            'message' => 'websocket gateway requires authenticated actor and peer scope',
            'user_id' => $userId,
            'ws_path' => "/api/v1/messages/ws/{$userId}?peer_id={peer_id}",
        ], 501);
    }
}
