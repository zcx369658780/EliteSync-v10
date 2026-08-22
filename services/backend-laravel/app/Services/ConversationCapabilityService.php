<?php

namespace App\Services;

use App\Models\Conversation;
use App\Models\DatingMatch;
use App\Models\User;
use App\Models\UserBlock;

class ConversationCapabilityService
{
    /**
     * @return array<string, mixed>
     */
    public function authorizeSend(int $actorId, int $peerId, bool $lockMatch = false): array
    {
        $blocked = UserBlock::query()->where(fn ($q) => $q->where('blocker_id', $actorId)->where('blocked_user_id', $peerId))
            ->orWhere(fn ($q) => $q->where('blocker_id', $peerId)->where('blocked_user_id', $actorId))->exists();
        $syntheticDenied = !app(MatchingDebugModeService::class)->includeSyntheticUsers()
            && (bool) User::query()->whereKey($peerId)->value('is_synthetic');
        $conversation = Conversation::query()
            ->where('room_key', app(ConversationDomainService::class)->roomKey($actorId, $peerId))
            ->first();

        $matchQuery = DatingMatch::query()
            ->where('drop_released', true)
            ->where(fn ($q) => $q
                ->where(fn ($pair) => $pair->where('user_a', $actorId)->where('user_b', $peerId))
                ->orWhere(fn ($pair) => $pair->where('user_a', $peerId)->where('user_b', $actorId)))
            ->orderByRaw('CASE WHEN released_at IS NULL THEN 1 ELSE 0 END')
            ->orderByDesc('released_at')
            ->orderByDesc('id');
        if ($lockMatch) {
            $matchQuery->lockForUpdate();
        }
        $match = $matchQuery->first();

        $departed = false;
        if ($conversation) {
            $departed = $conversation->members()
                ->whereIn('user_id', [$actorId, $peerId])
                ->whereNotNull('left_at')
                ->exists();
        }

        $allowed = !$blocked && !$syntheticDenied && $match !== null && !$departed;

        return [
            'allowed' => $allowed,
            'reason_code' => $blocked
                ? 'moderation_blocked'
                : ($syntheticDenied || !$match || $departed ? 'relationship_unavailable' : null),
            'actor_user_id' => $actorId,
            'peer_user_id' => $peerId,
            'dating_match_id' => $allowed ? (int) $match->id : null,
            'conversation_id' => $conversation ? (int) $conversation->id : null,
        ];
    }

    public function evaluate(int $actorId, int $peerId, ?int $requiredMatchId = null): array
    {
        $blocked = UserBlock::query()->where(fn ($q) => $q->where('blocker_id', $actorId)->where('blocked_user_id', $peerId))
            ->orWhere(fn ($q) => $q->where('blocker_id', $peerId)->where('blocked_user_id', $actorId))->exists();
        $conversation = Conversation::query()->where('room_key', app(ConversationDomainService::class)->roomKey($actorId, $peerId))
            ->whereHas('members', fn ($q) => $q->where('user_id', $actorId)->whereNull('left_at'))->first();
        $releasedMatchQuery = DatingMatch::query()->where('drop_released', true)->where(fn ($q) => $q
            ->where(fn ($pair) => $pair->where('user_a', $actorId)->where('user_b', $peerId))
            ->orWhere(fn ($pair) => $pair->where('user_a', $peerId)->where('user_b', $actorId)));
        if ($requiredMatchId !== null) {
            $releasedMatchQuery->whereKey($requiredMatchId);
        }
        $releasedMatch = $releasedMatchQuery->exists();
        $syntheticDenied = !app(MatchingDebugModeService::class)->includeSyntheticUsers()
            && (bool) User::query()->whereKey($peerId)->value('is_synthetic');

        $canRead = $conversation !== null || $releasedMatch;
        $canMutate = !$blocked && !$syntheticDenied && $releasedMatch;

        return [
            'can_list' => true,
            'can_read' => $canRead,
            'can_create' => $canMutate,
            'can_send' => $canMutate,
            'can_ws' => $canMutate && $conversation !== null,
            'reason_code' => $blocked ? 'moderation_blocked' : ($syntheticDenied ? 'relationship_unavailable' : (!$releasedMatch ? 'relationship_unavailable' : null)),
        ];
    }

    public function canCreate(int $actorId, int $peerId): bool { return $this->evaluate($actorId, $peerId)['can_create']; }
    public function canRead(int $actorId, int $peerId): bool { return $this->evaluate($actorId, $peerId)['can_read']; }
    public function canSend(int $actorId, int $peerId): bool { return $this->evaluate($actorId, $peerId)['can_send']; }
    public function canWebSocket(int $actorId, int $peerId): bool { return $this->evaluate($actorId, $peerId)['can_ws']; }
}
