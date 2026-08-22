<?php

namespace App\Services;

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;

class ChatWebsocketAuthorizationService
{
    public function authorize(string $authorizationHeader, int $claimedUserId, int $peerId): ?array
    {
        if (!preg_match('/^Bearer\s+(\S+)$/i', trim($authorizationHeader), $match)) return null;
        $accessToken = PersonalAccessToken::findToken($match[1]);
        if (!$this->tokenIsCurrent($accessToken)) return null;
        $actor = $accessToken->tokenable;
        if (!$actor instanceof User || (int) $actor->id !== $claimedUserId || $peerId <= 0 || !$accessToken->can('chat:ws')) return null;
        if (!app(ConversationCapabilityService::class)->canWebSocket((int) $actor->id, $peerId)) return null;
        return ['actor_id' => (int) $actor->id, 'peer_id' => $peerId, 'token_id' => (int) $accessToken->id];
    }

    public function reauthorize(int $tokenId, int $actorId, int $peerId): bool
    {
        $token = PersonalAccessToken::query()->find($tokenId);
        if (!$this->tokenIsCurrent($token) || !$token->can('chat:ws')) return false;
        $actor = $token->tokenable;
        return $actor instanceof User && (int) $actor->id === $actorId
            && app(ConversationCapabilityService::class)->canWebSocket($actorId, $peerId);
    }

    private function tokenIsCurrent(?PersonalAccessToken $token): bool
    {
        if (!$token) return false;
        if ($token->expires_at?->isPast()) return false;
        $expirationMinutes = config('sanctum.expiration');
        if ($expirationMinutes !== null && $token->created_at?->lte(now()->subMinutes((int) $expirationMinutes))) return false;
        return true;
    }
}
