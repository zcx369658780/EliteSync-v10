<?php

namespace App\Domain\Matching;

enum RoundState: string
{
    case Preparing = 'preparing';
    case Waiting = 'waiting';
    case Revealed = 'revealed';
    case NoCandidate = 'no_candidate';
    case Failed = 'failed';
    case Closed = 'closed';

    public function canTransitionTo(self $next): bool
    {
        return in_array($next, match ($this) {
            self::Preparing => [self::Waiting, self::Failed],
            self::Waiting => [self::Revealed, self::NoCandidate],
            self::Revealed, self::NoCandidate => [self::Closed],
            self::Failed => [self::Preparing, self::Closed],
            self::Closed => [],
        }, true);
    }
}
