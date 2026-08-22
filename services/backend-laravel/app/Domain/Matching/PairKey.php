<?php

namespace App\Domain\Matching;

final class PairKey
{
    public const VERSION = 1;

    public static function forUsers(int $firstUserId, int $secondUserId): string
    {
        $low = min($firstUserId, $secondUserId);
        $high = max($firstUserId, $secondUserId);
        $payload = "elitesync:dating-pair:v1\0".pack('J', $low).pack('J', $high);

        return hash('sha256', $payload);
    }
}
