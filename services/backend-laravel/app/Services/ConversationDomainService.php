<?php

namespace App\Services;

use App\Models\ChatMessage;
use App\Models\Conversation;
use App\Models\ConversationMember;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class ConversationDomainService
{
    public function roomKey(int $a, int $b): string
    {
        $x = min($a, $b);
        $y = max($a, $b);

        return "{$x}_{$y}";
    }

    public function ensureDirectConversation(int $selfId, int $peerId, ?string $title = null): Conversation
    {
        $roomKey = $this->roomKey($selfId, $peerId);
        $conversation = Conversation::query()->firstOrCreate(
            ['room_key' => $roomKey],
            [
                'room_type' => 'direct',
                'title' => $title,
                'status' => 'active',
                'created_by' => $selfId,
                'last_message_id' => null,
                'last_sender_id' => null,
                'last_message_at' => null,
                'metadata' => null,
            ]
        );

        ConversationMember::query()->firstOrCreate(
            ['conversation_id' => $conversation->id, 'user_id' => $selfId],
            ['role' => 'member', 'joined_at' => now(), 'left_at' => null]
        );

        ConversationMember::query()->firstOrCreate(
            ['conversation_id' => $conversation->id, 'user_id' => $peerId],
            ['role' => 'member', 'joined_at' => now(), 'left_at' => null]
        );

        return $conversation->fresh(['members.user', 'creator']);
    }

    public function syncFromMessage(ChatMessage $message): void
    {
        $senderId = (int) $message->sender_id;
        $receiverId = (int) $message->receiver_id;
        if ($senderId <= 0 || $receiverId <= 0) {
            return;
        }

        $conversation = $this->ensureDirectConversation($senderId, $receiverId);
        $conversation->forceFill([
            'last_message_id' => (int) $message->id,
            'last_sender_id' => $senderId,
            'last_message_at' => $message->created_at ?? now(),
        ])->save();

        ConversationMember::query()->firstOrCreate(
            ['conversation_id' => $conversation->id, 'user_id' => $senderId],
            ['role' => 'member', 'joined_at' => now()]
        )->forceFill([
            'last_read_message_id' => (int) $message->id,
            'last_read_at' => $message->created_at ?? now(),
        ])->save();

        ConversationMember::query()->firstOrCreate(
            ['conversation_id' => $conversation->id, 'user_id' => $receiverId],
            ['role' => 'member', 'joined_at' => now()]
        );
    }

    public function markReadForPair(int $viewerId, int $peerId, int $messageId): void
    {
        $conversation = $this->findDirectConversation($viewerId, $peerId);
        if (!$conversation) {
            return;
        }

        ConversationMember::query()
            ->where('conversation_id', $conversation->id)
            ->where('user_id', $viewerId)
            ->update([
                'last_read_message_id' => $messageId,
                'last_read_at' => now(),
            ]);
    }

    public function findDirectConversation(int $selfId, int $peerId): ?Conversation
    {
        return Conversation::query()
            ->where('room_key', $this->roomKey($selfId, $peerId))
            ->with(['members.user', 'creator', 'matchLinks'])
            ->first();
    }

    public function findConversationForParticipant(int $conversationId, int $actorId): ?Conversation
    {
        return Conversation::query()
            ->whereKey($conversationId)
            ->whereHas('members', fn ($query) => $query
                ->where('user_id', $actorId)
                ->whereNull('left_at'))
            ->with(['members.user', 'creator'])
            ->first();
    }

    public function peerUserId(Conversation $conversation, int $viewerId): ?int
    {
        $peerMember = $conversation->members
            ->first(fn (ConversationMember $member) => (int) $member->user_id !== $viewerId && $member->left_at === null);

        return $peerMember ? (int) $peerMember->user_id : null;
    }

    public function listForUser(User $user): Collection
    {
        $conversations = Conversation::query()
            ->whereHas('members', function ($query) use ($user) {
                $query->where('user_id', $user->id)->whereNull('left_at');
            })
            ->with(['members.user', 'creator'])
            ->orderByDesc('last_message_at')
            ->get();

        $stored = $conversations->map(function (Conversation $conversation) use ($user) {
            return $this->summarizeConversation($conversation, (int) $user->id);
        });
        $storedPeerIds = $stored->pluck('peer_user_id')->filter()->map(fn ($id) => (int) $id)->all();
        $eligible = $this->fallbackFromMatches($user)
            ->reject(fn (array $entry) => in_array((int) $entry['peer_user_id'], $storedPeerIds, true));

        return $stored->concat($eligible)->values();
    }

    public function summarizeConversation(Conversation $conversation, int $viewerId): array
    {
        $peerMember = $conversation->members->first(fn (ConversationMember $member) => (int) $member->user_id !== $viewerId)
            ?? $conversation->members->firstWhere('user_id', $viewerId);
        $peer = $peerMember?->user;
        $latestMessage = ChatMessage::query()
            ->with(['attachments.mediaAsset'])
            ->where('room_id', $conversation->room_key)
            ->latest('id')
            ->first();
        $viewerMember = $conversation->members->firstWhere('user_id', $viewerId);
        $lastReadMessageId = (int) ($viewerMember?->last_read_message_id ?? 0);
        $matchId = $conversation->relationLoaded('matchLinks')
            ? $conversation->matchLinks->sortByDesc('id')->first()?->dating_match_id
            : $conversation->matchLinks()->latest('id')->value('dating_match_id');
        $unread = ChatMessage::query()
            ->where('room_id', $conversation->room_key)
            ->where('receiver_id', $viewerId)
            ->where('id', '>', $lastReadMessageId)
            ->count();

        return [
            'entry_kind' => 'conversation',
            'conversation_id' => (int) $conversation->id,
            'match_id' => $matchId !== null ? (int) $matchId : null,
            'id' => (string) ($peer?->id ?? $conversation->room_key),
            'peer_user_id' => $peer?->id,
            'room_key' => $conversation->room_key,
            'name' => $conversation->title ?: $this->displayNameForUser($peer),
            'last_message' => $this->previewForMessage($latestMessage) ?? '已建立会话',
            'last_time' => $this->displayTime($latestMessage?->created_at ?? $conversation->last_message_at),
            'unread' => $unread,
            'state' => $conversation->status,
            'members' => $conversation->members->map(fn (ConversationMember $member) => [
                'user_id' => $member->user_id,
                'role' => $member->role,
            ])->values(),
        ];
    }

    public function fallbackFromMatches(User $user): Collection
    {
        return DatingMatch::query()
            ->where('drop_released', true)
            ->where(function ($query) use ($user) {
                $query->where('user_a', $user->id)->orWhere('user_b', $user->id);
            })
            ->orderByRaw('CASE WHEN released_at IS NULL THEN 1 ELSE 0 END')
            ->orderByDesc('released_at')
            ->orderByDesc('id')
            ->limit(20)
            ->get()
            ->map(function (DatingMatch $match) use ($user) {
                $peerId = (int) ($match->user_a == $user->id ? $match->user_b : $match->user_a);
                $peer = User::query()->find($peerId);

                return [
                    'entry_kind' => 'eligible_match',
                    'conversation_id' => null,
                    'id' => (string) $peerId,
                    'peer_user_id' => $peerId,
                    'match_id' => (int) $match->id,
                    'room_key' => $this->roomKey((int) $user->id, $peerId),
                    'name' => $peer ? $this->displayNameForUser($peer) : "匹配对象 #{$peerId}",
                    'last_message' => trim((string) ($match->highlights ?? '')) ?: '已建立匹配，开始聊天吧',
                    'last_time' => '匹配分 ' . (int) ($match->score_final ?? 0),
                    'unread' => 0,
                    'state' => 'matched',
                    'members' => [],
                ];
            })
            ->unique('peer_user_id')
            ->values();
    }

    public function eligibleMatchForPeer(User $user, int $peerId): ?array
    {
        return $this->fallbackFromMatches($user)
            ->firstWhere('peer_user_id', $peerId);
    }

    private function displayNameForUser(?User $user): string
    {
        if (!$user) {
            return '未知会话对象';
        }

        $name = trim((string) ($user->nickname ?? ''));
        if ($name !== '') {
            return $name;
        }

        $name = trim((string) ($user->name ?? ''));
        if ($name !== '') {
            return $name;
        }

        return '用户 #' . (int) $user->id;
    }

    private function displayTime($value): string
    {
        if (!$value) {
            return '刚刚';
        }

        $time = $value instanceof Carbon ? $value : Carbon::parse($value);
        return $time->diffForHumans();
    }

    private function previewForMessage(?ChatMessage $message): ?string
    {
        if (!$message) {
            return null;
        }

        if ($message->attachments->isNotEmpty() || in_array((string) $message->message_type, ['image', 'video'], true)) {
            $messageType = (string) $message->message_type;
            if (str_starts_with($messageType, 'video') || $messageType === 'video') {
                $videoCount = $message->attachments->filter(function ($attachment) {
                    $mediaType = (string) ($attachment->mediaAsset?->media_type ?? '');
                    return str_starts_with($mediaType, 'video') || $mediaType === 'video';
                })->count();
                return $videoCount > 1 ? "视频消息（{$videoCount}条）" : '视频消息';
            }

            if (str_starts_with($messageType, 'image') || $messageType === 'image') {
                $imageCount = $message->attachments->filter(function ($attachment) {
                    $mediaType = (string) ($attachment->mediaAsset?->media_type ?? '');
                    return str_starts_with($mediaType, 'image') || $mediaType === 'image';
                })->count();

                return $imageCount > 1 ? "图片消息（{$imageCount}张）" : '图片消息';
            }

            $videoCount = $message->attachments->filter(function ($attachment) {
                $mediaType = (string) ($attachment->mediaAsset?->media_type ?? '');
                return str_starts_with($mediaType, 'video') || $mediaType === 'video';
            })->count();
            if ($videoCount > 0) {
                return $videoCount > 1 ? "视频消息（{$videoCount}条）" : '视频消息';
            }

            $imageCount = $message->attachments->filter(function ($attachment) {
                $mediaType = (string) ($attachment->mediaAsset?->media_type ?? '');
                return str_starts_with($mediaType, 'image') || $mediaType === 'image';
            })->count();

            if ($imageCount > 0) {
                return $imageCount > 1 ? "图片消息（{$imageCount}张）" : '图片消息';
            }

            return '附件消息';
        }

        $content = trim((string) $message->content);
        if ($content !== '') {
            return $content;
        }

        return '已发送消息';
    }
}
