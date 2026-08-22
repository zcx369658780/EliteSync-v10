<?php

namespace App\Domain\Matching;

enum RunState: string
{
    case Pending = 'pending';
    case Running = 'running';
    case Succeeded = 'succeeded';
    case Failed = 'failed';
    case Cancelled = 'cancelled';

    public function canTransitionTo(self $next): bool
    {
        return in_array($next, match ($this) {
            self::Pending => [self::Running, self::Cancelled],
            self::Running => [self::Succeeded, self::Failed],
            self::Succeeded, self::Failed, self::Cancelled => [],
        }, true);
    }
}
