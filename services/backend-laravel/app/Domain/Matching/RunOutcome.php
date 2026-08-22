<?php

namespace App\Domain\Matching;

enum RunOutcome: string
{
    case MatchesCreated = 'matches_created';
    case NoCandidate = 'no_candidate';
}
