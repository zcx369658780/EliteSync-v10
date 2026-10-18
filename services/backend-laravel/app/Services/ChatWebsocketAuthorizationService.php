<?php

namespace App\Services;

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;
use Workerman\Protocols\Http\Request;

class ChatWebsocketAuthorizationService
{
    public function authorizeRequest(Request $request): ?array
    {
        $uri = $request->uri();
        $path = parse_url($uri, PHP_URL_PATH) ?: '/';
        if (!preg_match('#^/(?:api/v1/messages/ws|ws)/(\d+)$#', $path, $match)) return null;
        $userId = (int) $match[1];
        if ($userId <= 0) return null;
        parse_str((string) parse_url($uri, PHP_URL_QUERY), $query);

        return $this->authorize((string) $request->header('authorization'), $userId, (int) ($query['peer_id'] ?? 0));
    }

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
