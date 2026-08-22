<?php

namespace App\Services;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\PairKey;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunOutcome;
use App\Domain\Matching\RunState;
use App\Domain\Matching\UserRoundState;
use App\Models\Conversation;
use App\Models\ConversationMember;
use App\Models\DatingMatch;
use App\Models\DatingRound;
use App\Models\DatingRoundChannel;
use App\Models\DatingRoundUserState;
use App\Models\MatchingOperationAudit;
use App\Models\MatchingRun;
use App\Models\MatchingRunCandidate;
use App\Models\QuestionnaireAnswer;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class C2LocalMatchScenarioService
{
    public const TAG = 'c2_local';

    public const USER_PHONE = '10000000001';

    public const PEER_PHONE = '10000000002';

    public const ADMIN_PHONE = '10000000003';

    public function assertSafeEnvironment(): void
    {
        if (! app()->environment(['local', 'testing']) || ! (bool) config('matching.c2.local_integration_enabled', false)) {
            throw new \RuntimeException('c2_local_integration_disabled');
        }
        if (DB::getDriverName() !== 'sqlite') {
            throw new \RuntimeException('c2_requires_sqlite');
        }
        $database = (string) config('database.connections.sqlite.database');
        if ($database !== ':memory:' && ! str_contains(strtolower(str_replace('\\', '/', $database)), 'elitesync_c2_')) {
            throw new \RuntimeException('c2_requires_ephemeral_tagged_database');
        }
    }

    public function build(string $scenario): array
    {
        $this->assertSafeEnvironment();
        $allowed = ['no_round', 'preparing', 'waiting', 'revealed', 'no_candidate', 'failed', 'closed'];
        if (! in_array($scenario, $allowed, true)) {
            throw new \InvalidArgumentException('unsupported_c2_scenario');
        }
        $this->reset();
        [$user, $peer, $admin] = $this->users();
        if ($scenario === 'no_round') {
            return $this->summary($scenario, $user, $peer, $admin, null);
        }

        $round = app(MatchingRoundService::class)->prepare('default', 'c2-'.$scenario.'-'.now()->format('YmdHis'), now()->subMinute(), now()->addMinutes(30), 'system', $admin->id, self::TAG);
        if ($scenario === 'preparing') {
            return $this->summary($scenario, $user, $peer, $admin, $round);
        }

        $runState = $scenario === 'failed' ? RunState::Failed : RunState::Succeeded;
        $outcome = in_array($scenario, ['no_candidate'], true) ? RunOutcome::NoCandidate : RunOutcome::MatchesCreated;
        $run = MatchingRun::query()->create([
            'round_id' => $round->id, 'run_key' => (string) Str::uuid(), 'idempotency_key' => 'c2-'.$scenario.'-'.Str::uuid(),
            'correlation_id' => (string) Str::uuid(), 'attempt_no' => 1, 'state' => $runState, 'outcome' => $runState === RunState::Failed ? null : $outcome,
            'trigger_source' => self::TAG, 'actor_type' => 'system', 'actor_id' => $admin->id, 'reason_code' => 'c2_scenario',
            'eligibility_cutoff_at' => now()->utc(), 'algorithm_version' => 'c2-fixture-no-algorithm', 'config_version' => 'c2-local',
            'eligible_count' => 2, 'candidate_count' => 2, 'pair_count' => $outcome === RunOutcome::MatchesCreated ? 1 : 0,
            'no_candidate_count' => $outcome === RunOutcome::NoCandidate ? 2 : 0, 'finished_at' => now()->utc(),
            'error_code' => $runState === RunState::Failed ? 'c2_synthetic_failure' : null,
            'error_summary' => $runState === RunState::Failed ? 'Local synthetic run failed for recovery evidence.' : null,
        ]);
        $round->forceFill(['active_run_id' => $run->id])->save();
        foreach ([$user, $peer] as $candidate) {
            MatchingRunCandidate::query()->create(['matching_run_id' => $run->id, 'user_id' => $candidate->id, 'profile_version_at' => $candidate->updated_at]);
        }

        $match = null;
        if ($outcome === RunOutcome::MatchesCreated && $runState !== RunState::Failed) {
            $match = DatingMatch::query()->create([
                'round_id' => $round->id, 'matching_run_id' => $run->id, 'pair_key' => PairKey::forUsers($user->id, $peer->id),
                'pair_key_version' => PairKey::VERSION, 'week_tag' => $round->cadence_key, 'user_a' => $user->id, 'user_b' => $peer->id,
                'highlights' => '你们都愿意从一次轻松对话开始。', 'drop_released' => in_array($scenario, ['revealed', 'closed'], true),
                'released_at' => in_array($scenario, ['revealed', 'closed'], true) ? now()->utc() : null,
            ]);
        }

        $roundState = match ($scenario) {
            'waiting' => RoundState::Waiting,
            'revealed' => RoundState::Revealed,
            'no_candidate' => RoundState::NoCandidate,
            'failed' => RoundState::Failed,
            'closed' => RoundState::Closed,
            default => RoundState::Preparing,
        };
        $userState = match ($scenario) {
            'waiting' => UserRoundState::Waiting,
            'revealed' => UserRoundState::Revealed,
            'no_candidate' => UserRoundState::NoCandidate,
            'failed' => UserRoundState::Failed,
            'closed' => UserRoundState::Closed,
            default => UserRoundState::Preparing,
        };
        $round->forceFill([
            'state' => $roundState, 'state_version' => $round->state_version + 1,
            'reveal_at' => $scenario === 'waiting' ? now()->addMinutes(30)->utc() : now()->subMinute()->utc(),
            'revealed_at' => in_array($scenario, ['revealed', 'no_candidate', 'closed'], true) ? now()->utc() : null,
            'closed_at' => $scenario === 'closed' ? now()->utc() : null,
            'failure_code' => $scenario === 'failed' ? 'c2_synthetic_failure' : null,
            'failure_summary' => $scenario === 'failed' ? 'Local synthetic failure.' : null,
        ])->save();
        foreach ([$user, $peer] as $candidate) {
            DatingRoundUserState::query()->create([
                'round_id' => $round->id, 'user_id' => $candidate->id, 'state' => $userState,
                'dating_match_id' => $match?->id, 'reason_code' => match ($scenario) {
                    'waiting' => 'match_pending_reveal', 'revealed' => 'match_revealed', 'no_candidate' => 'no_candidate',
                    'failed' => 'temporary_failure', 'closed' => 'round_closed', default => 'round_preparing',
                },
                'next_action_code' => match ($scenario) {
                    'revealed' => 'open_conversation', 'no_candidate' => 'wait_next_round', 'failed' => 'retry_later',
                    'closed' => 'return_home', default => 'wait_for_reveal',
                },
                'reveal_eligible_at' => $round->reveal_at, 'conversation_eligible' => $scenario === 'revealed',
            ]);
        }
        MatchingOperationAudit::query()->create([
            'round_id' => $round->id, 'matching_run_id' => $run->id, 'action' => OperationAction::Execute,
            'actor_type' => 'system', 'actor_id' => $admin->id, 'reason_code' => 'c2_scenario',
            'after_state' => ['round' => $roundState->value, 'run' => $runState->value, 'outcome' => $run->outcome?->value],
            'aggregate_summary' => ['eligible_count' => 2, 'pair_count' => $run->pair_count, 'no_candidate_count' => $run->no_candidate_count],
            'source_channel' => self::TAG,
        ]);

        return $this->summary($scenario, $user, $peer, $admin, $round->fresh());
    }

    public function reset(): void
    {
        $this->assertSafeEnvironment();
        DB::transaction(function () {
            $roundIds = DatingRound::query()->where('source', self::TAG)->pluck('id');
            $runIds = MatchingRun::query()->whereIn('round_id', $roundIds)->pluck('id');
            $userIds = User::query()->where('synthetic_batch', self::TAG)->pluck('id');
            ConversationMember::query()->whereIn('user_id', $userIds)->delete();
            Conversation::query()->where('room_key', 'like', 'c2_%')->delete();
            DatingRoundUserState::query()->whereIn('round_id', $roundIds)->delete();
            DatingMatch::query()->whereIn('round_id', $roundIds)->delete();
            MatchingRunCandidate::query()->whereIn('matching_run_id', $runIds)->delete();
            MatchingOperationAudit::query()->whereIn('round_id', $roundIds)->delete();
            DatingRound::query()->whereIn('id', $roundIds)->update(['active_run_id' => null]);
            MatchingRun::query()->whereIn('id', $runIds)->update(['supersedes_run_id' => null]);
            MatchingRun::query()->whereIn('id', $runIds)->delete();
            DatingRoundChannel::query()->whereIn('active_round_id', $roundIds)->update(['active_round_id' => null]);
            DatingRound::query()->whereIn('id', $roundIds)->delete();
            QuestionnaireAnswer::query()->whereIn('user_id', $userIds)->delete();
        });
    }

    private function users(): array
    {
        $password = (string) config('matching.c2.local_password');
        if ($password === '') {
            throw new \RuntimeException('c2_local_password_required');
        }
        $base = ['password' => Hash::make($password), 'disabled' => false, 'is_synthetic' => true, 'synthetic_batch' => self::TAG, 'exclude_from_metrics' => true, 'city' => 'C2 Local City', 'relationship_goal' => 'serious'];
        $user = User::query()->updateOrCreate(['phone' => self::USER_PHONE], $base + ['name' => 'C2 用户 A', 'gender' => 'female', 'role' => 'user']);
        $peer = User::query()->updateOrCreate(['phone' => self::PEER_PHONE], $base + ['name' => 'C2 用户 B', 'gender' => 'male', 'role' => 'user']);
        $admin = User::query()->updateOrCreate(['phone' => self::ADMIN_PHONE], $base + ['name' => 'C2 运营员', 'gender' => 'other', 'role' => 'admin']);

        return [$user, $peer, $admin];
    }

    private function summary(string $scenario, User $user, User $peer, User $admin, ?DatingRound $round): array
    {
        return ['scenario' => $scenario, 'actor_phone' => $user->phone, 'peer_phone' => $peer->phone, 'admin_phone' => $admin->phone, 'round_key' => $round?->round_key, 'database_guard' => 'sqlite_ephemeral_c2', 'synthetic_only' => true];
    }
}
