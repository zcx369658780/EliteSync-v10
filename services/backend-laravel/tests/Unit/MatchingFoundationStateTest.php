<?php

namespace Tests\Unit;

use App\Domain\Matching\PairKey;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunState;
use App\Domain\Matching\UserRoundState;
use PHPUnit\Framework\TestCase;

class MatchingFoundationStateTest extends TestCase
{
    public function test_round_and_projection_transitions_are_explicit(): void
    {
        $this->assertTrue(RoundState::Preparing->canTransitionTo(RoundState::Waiting));
        $this->assertTrue(RoundState::Failed->canTransitionTo(RoundState::Preparing));
        $this->assertFalse(RoundState::Closed->canTransitionTo(RoundState::Waiting));
        $this->assertTrue(UserRoundState::Waiting->canTransitionTo(UserRoundState::NoCandidate));
        $this->assertFalse(UserRoundState::NoCandidate->canTransitionTo(UserRoundState::Revealed));
    }

    public function test_terminal_run_cannot_resume_and_failure_is_not_an_outcome(): void
    {
        $this->assertTrue(RunState::Pending->canTransitionTo(RunState::Running));
        $this->assertTrue(RunState::Running->canTransitionTo(RunState::Failed));
        $this->assertFalse(RunState::Failed->canTransitionTo(RunState::Running));
    }

    public function test_pair_key_is_symmetric_and_versioned(): void
    {
        $this->assertSame(PairKey::forUsers(2, 19), PairKey::forUsers(19, 2));
        $this->assertSame('32220019c081a36cc4b3d0ff4fec3dfc3a0867c9705187cca2123e6bd6d97d4f', PairKey::forUsers(2, 19));
        $this->assertSame(64, strlen(PairKey::forUsers(2, 19)));
        $this->assertSame(1, PairKey::VERSION);
    }

    public function test_every_round_and_run_transition_pair_matches_the_frozen_matrix(): void
    {
        $roundAllowed = ['preparing' => ['waiting','failed'], 'waiting' => ['revealed','no_candidate'], 'revealed' => ['closed'], 'no_candidate' => ['closed'], 'failed' => ['preparing','closed'], 'closed' => []];
        foreach (RoundState::cases() as $from) foreach (RoundState::cases() as $to) $this->assertSame(in_array($to->value, $roundAllowed[$from->value], true), $from->canTransitionTo($to));
        $runAllowed = ['pending' => ['running','cancelled'], 'running' => ['succeeded','failed'], 'succeeded' => [], 'failed' => [], 'cancelled' => []];
        foreach (RunState::cases() as $from) foreach (RunState::cases() as $to) $this->assertSame(in_array($to->value, $runAllowed[$from->value], true), $from->canTransitionTo($to));
        $this->assertFalse(in_array('no_round', array_map(fn ($state) => $state->value, RoundState::cases()), true));
    }
}
