<?php
declare(strict_types=1);
namespace App\Domain;

/** Pure protocol rules. Current authorization must be supplied by server-owned services. */
final class MessagingReplayContract
{
    public static function fingerprint(int $receiverId, string $content, array $attachmentIds): string
    {
        if ($receiverId <= 0 || array_filter($attachmentIds, fn ($id) => !is_int($id) || $id <= 0)) {
            throw new \InvalidArgumentException('Invalid message identity');
        }
        return hash('sha256', json_encode(['receiver_id'=>$receiverId,'content'=>$content,
            'attachment_ids'=>array_values($attachmentIds)],
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
    }

    public static function replayDecision(int $storedSender, int $storedPeer, int $actor, int $peer,
        string $storedFingerprint, string $requestedFingerprint, bool $currentlyAuthorized): string
    {
        if (!$currentlyAuthorized || $actor <= 0 || $storedSender !== $actor) return 'UNAVAILABLE';
        if ($storedPeer !== $peer || !hash_equals($storedFingerprint,$requestedFingerprint)) return 'CONFLICT';
        return 'REPLAY';
    }
}
