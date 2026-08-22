<?php

namespace App\Services;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\UserRoundState;
use App\Models\DatingMatch;
use App\Models\DatingRound;
use App\Models\DatingRoundChannel;
use App\Models\DatingRoundUserState;
use App\Models\MatchingOperationAudit;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MatchingRoundService
{
    public function prepare(string $channelKey, string $cadenceKey, ?\DateTimeInterface $scheduledFor, ?\DateTimeInterface $revealAt, string $actorType, ?int $actorId, string $source = 'admin', ?int $expectedChannelVersion = null, ?string $idempotencyKey = null): DatingRound
    {
        return DB::transaction(function () use ($channelKey, $cadenceKey, $scheduledFor, $revealAt, $actorType, $actorId, $source, $expectedChannelVersion, $idempotencyKey) {
            DatingRoundChannel::query()->firstOrCreate(['channel_key' => $channelKey], ['state_version' => 1]);
            $channel = DatingRoundChannel::query()->whereKey($channelKey)->lockForUpdate()->firstOrFail();
            $existing = DatingRound::query()->where('channel_key', $channelKey)->where('cadence_key', $cadenceKey)->first();
            if ($existing) {
                return $existing;
            }
            if ($expectedChannelVersion !== null && $channel->state_version !== $expectedChannelVersion) {
                throw new \DomainException('stale_state_version');
            }
            if ($channel->active_round_id !== null) {
                throw new \DomainException('active_round_exists');
            }
            if ($scheduledFor && $revealAt && $revealAt < $scheduledFor) {
                throw new \InvalidArgumentException('reveal_at_before_scheduled_for');
            }

            $round = DatingRound::query()->create([
                'round_key' => (string) Str::uuid(), 'channel_key' => $channelKey, 'cadence_key' => $cadenceKey,
                'state' => RoundState::Preparing, 'state_version' => 1, 'scheduled_for' => $scheduledFor,
                'reveal_at' => $revealAt, 'created_by_type' => $actorType, 'created_by_id' => $actorId, 'source' => $source,
            ]);
            $channel->forceFill(['active_round_id' => $round->id, 'state_version' => $channel->state_version + 1])->save();
            $this->audit($round, OperationAction::Schedule, $actorType, $actorId, ['state' => RoundState::Preparing->value], $idempotencyKey);

            return $round->fresh();
        });
    }

    public function transition(DatingRound $round, RoundState $next, int $expectedVersion, string $actorType, ?int $actorId, OperationAction $action, ?string $idempotencyKey = null): DatingRound
    {
        return DB::transaction(function () use ($round, $next, $expectedVersion, $actorType, $actorId, $action, $idempotencyKey) {
            $locked = DatingRound::query()->whereKey($round->id)->lockForUpdate()->firstOrFail();
            if ($locked->state_version !== $expectedVersion) {
                throw new \DomainException('stale_state_version');
            }
            if (! $locked->state->canTransitionTo($next)) {
                throw new \DomainException('forbidden_round_transition');
            }
            $before = ['state' => $locked->state->value, 'state_version' => $locked->state_version];
            $values = ['state' => $next, 'state_version' => $locked->state_version + 1];
            if (in_array($next, [RoundState::Revealed, RoundState::NoCandidate], true)) {
                if (! $locked->reveal_at || $locked->reveal_at->isFuture()) {
                    throw new \DomainException('round_not_reveal_eligible');
                }
                $matchedCount = DatingRoundUserState::query()->where('round_id', $locked->id)->whereNotNull('dating_match_id')->count();
                if ($next === RoundState::NoCandidate && $matchedCount > 0) {
                    throw new \DomainException('round_has_matches');
                }
                if ($next === RoundState::Revealed && $matchedCount === 0) {
                    throw new \DomainException('round_has_no_matches');
                }
                DatingRoundUserState::query()->where('round_id', $locked->id)->where('state', UserRoundState::Waiting->value)->whereNotNull('dating_match_id')->update(['state' => UserRoundState::Revealed->value, 'conversation_eligible' => true, 'reason_code' => 'match_revealed', 'next_action_code' => 'open_conversation', 'projection_version' => DB::raw('projection_version + 1')]);
                DatingRoundUserState::query()->where('round_id', $locked->id)->where('state', UserRoundState::Waiting->value)->whereNull('dating_match_id')->update(['state' => UserRoundState::NoCandidate->value, 'conversation_eligible' => false, 'reason_code' => 'no_candidate', 'next_action_code' => 'wait_next_round', 'projection_version' => DB::raw('projection_version + 1')]);
                DatingMatch::query()->where('round_id', $locked->id)->update(['drop_released' => true, 'released_at' => now()->utc()]);
                $values['revealed_at'] = now()->utc();
            }
            if ($next === RoundState::Closed) {
                $values['closed_at'] = now()->utc();
            }
            $locked->forceFill($values)->save();
            if ($next === RoundState::Closed) {
                DatingRoundUserState::query()->where('round_id', $locked->id)->update(['state' => UserRoundState::Closed->value, 'projection_version' => DB::raw('projection_version + 1')]);
                DatingRoundChannel::query()->whereKey($locked->channel_key)->where('active_round_id', $locked->id)->update(['active_round_id' => null, 'state_version' => DB::raw('state_version + 1')]);
            }
            $this->audit($locked, $action, $actorType, $actorId, ['before' => $before, 'after' => ['state' => $next->value, 'state_version' => $locked->state_version]], $idempotencyKey);

            return $locked->fresh();
        });
    }

    private function audit(DatingRound $round, OperationAction $action, string $actorType, ?int $actorId, array $after, ?string $idempotencyKey = null): void
    {
        MatchingOperationAudit::query()->create(['round_id' => $round->id, 'action' => $action, 'actor_type' => $actorType, 'actor_id' => $actorId, 'idempotency_key' => $idempotencyKey, 'after_state' => $after, 'source_channel' => $round->source ?? 'system']);
    }
}
