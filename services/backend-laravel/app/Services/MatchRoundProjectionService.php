<?php

namespace App\Services;

use App\Models\DatingMatch;
use App\Models\DatingRound;
use App\Models\DatingRoundChannel;
use App\Models\DatingRoundUserState;
use App\Models\User;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunState;

class MatchRoundProjectionService
{
    public function currentForUser(int $userId, string $channelKey = 'default'): array
    {
        $channel = DatingRoundChannel::query()->whereKey($channelKey)->first();
        if (! $channel?->active_round_id) {
            return $this->envelope('no_round');
        }
        $round = DatingRound::query()->find($channel->active_round_id);
        if (! $round) {
            return $this->envelope('no_round');
        }
        $round->loadMissing('activeRun');
        $userState = DatingRoundUserState::query()->where('round_id', $round->id)->where('user_id', $userId)->first();
        $state = $this->publicState($round, $userState);
        $result = null;
        $capability = null;
        $projectionFailureCode = null;
        if ($state === 'revealed') {
            $match = $userState?->dating_match_id ? DatingMatch::query()->find($userState->dating_match_id) : null;
            if ($match && (int) $match->round_id === (int) $round->id && in_array($userId, [(int) $match->user_a, (int) $match->user_b], true)) {
                if (! $match->drop_released) {
                    $state = 'failed';
                    $projectionFailureCode = 'current_match_not_released';
                } else {
                    $peerId = (int) ((int) $match->user_a === $userId ? $match->user_b : $match->user_a);
                    $peer = User::query()->find($peerId);
                    $result = [
                        'match_id' => (int) $match->id,
                        'partner_id' => $peerId,
                        'partner_nickname' => $peer?->name,
                        'headline' => trim((string) $match->highlights) ?: '本轮匹配已揭晓',
                    ];
                    $capability = app(ConversationCapabilityService::class)->evaluate($userId, $peerId, (int) $match->id);
                }
            } else {
                $state = 'no_candidate';
            }
        }

        return $this->envelope($state, [
            'round_id' => (int) $round->id,
            'scheduled_at' => $round->scheduled_for?->toISOString(),
            'next_transition_at' => $this->nextTransitionAt($round, $state),
            'result_id' => $result['match_id'] ?? null,
            'no_candidate_reason_code' => $state === 'no_candidate'
                ? ($userState?->reason_code ?? 'no_candidate')
                : null,
            'failure_code' => $state === 'failed'
                ? ($projectionFailureCode ?? $round->failure_code ?? $userState?->reason_code ?? 'round_failed')
                : null,
            'retry_eligible' => $state === 'failed',
            'user_action' => $this->userAction($state, $capability),
            'projection_version' => (int) ($userState?->projection_version ?? $round->state_version ?? 1),
            'updated_at' => ($userState?->updated_at ?? $round->updated_at)?->toISOString(),
            'round_key' => $round->round_key,
            'state_version' => $round->state_version,
            'scheduled_for' => $round->scheduled_for?->toISOString(),
            'reveal_at' => $round->reveal_at?->toISOString(),
            'reason_code' => $state === 'no_candidate' ? 'no_candidate' : ($userState?->reason_code ?? $round->failure_code),
            'next_action_code' => $state === 'no_candidate' ? 'wait_next_round' : $userState?->next_action_code,
            'result' => $result,
            'conversation_capability' => $capability,
        ]);
    }

    private function publicState(DatingRound $round, ?DatingRoundUserState $userState): string
    {
        $persisted = $userState?->state->value ?? $round->state->value;
        if ($persisted === 'revealed' && ! $userState?->dating_match_id) {
            return 'no_candidate';
        }
        if (in_array($persisted, ['revealed', 'no_candidate', 'failed', 'closed'], true)) {
            return $persisted;
        }
        if ($round->activeRun?->state === RunState::Running) {
            return 'running';
        }
        if ($round->activeRun?->state === RunState::Pending) {
            return 'preparing';
        }
        if ($round->state === RoundState::Waiting || $round->scheduled_for?->isFuture()) {
            return 'scheduled';
        }
        return 'preparing';
    }

    private function nextTransitionAt(DatingRound $round, string $state): ?string
    {
        if (! in_array($state, ['scheduled', 'preparing', 'running'], true)) {
            return null;
        }
        if ($state === 'scheduled' && $round->state === RoundState::Preparing && $round->scheduled_for?->isFuture()) {
            return $round->scheduled_for->toISOString();
        }
        return ($round->reveal_at ?? $round->scheduled_for)?->toISOString();
    }

    private function userAction(string $state, ?array $capability): string
    {
        return match ($state) {
            'revealed' => ($capability['can_create'] ?? false) || ($capability['can_send'] ?? false)
                ? 'open_messages'
                : 'refresh',
            'failed' => 'retry',
            'closed' => 'view_messages',
            'no_round', 'no_candidate' => 'wait_next_round',
            default => 'wait',
        };
    }

    private function envelope(string $state, array $values = []): array
    {
        $serverNow = now()->utc()->toISOString();
        return ['data' => array_merge([
            'round_id' => null,
            'state' => $state,
            'server_now' => $serverNow,
            'scheduled_at' => null,
            'next_transition_at' => null,
            'result_id' => null,
            'no_candidate_reason_code' => null,
            'failure_code' => null,
            'retry_eligible' => false,
            'user_action' => $state === 'no_round' ? 'wait_next_round' : 'wait',
            'projection_version' => 1,
            'updated_at' => $serverNow,
            // Bounded v1 aliases retained for older typed clients.
            'round_key' => null,
            'state_version' => null,
            'server_time' => $serverNow,
            'scheduled_for' => null,
            'reveal_at' => null,
            'reason_code' => null,
            'next_action_code' => null,
            'result' => null,
            'conversation_capability' => null,
        ], $values), 'meta' => ['contract_version' => 'match_round_v2']];
    }
}
