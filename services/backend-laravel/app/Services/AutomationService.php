<?php

namespace App\Services;

use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/** A single DB-backed whitelist task, driven by the existing Laravel scheduler. */
final class AutomationService
{
    public function tick(string $worker, int $limit = 25): int
    {
        $limit = max(1, min(100, $limit));
        $this->schedule($limit);
        $count = 0;
        while ($count < $limit && ($claim = $this->claim($worker))) {
            try {
                $this->apply($claim);
                $this->complete($claim);
            } catch (\Throwable) {
                // A commit acknowledgement can be lost. Reconcile before retrying.
                DB::table('automation_tasks')->where('id', $claim->id)
                    ->where('fencing_token', $claim->fencing_token)->where('state', 'RUNNING')
                    ->where('lease_owner', $claim->lease_owner)->update([
                        'state' => 'UNKNOWN', 'error_code' => 'EXECUTION_UNCERTAIN',
                        'reconciliation' => 'REQUIRED', 'lease_expires_at' => now(),
                        'available_at' => now()->addSeconds(30), 'updated_at' => now(),
                    ]);
            }
            $count++;
        }
        return $count;
    }

    public function schedule(int $limit = 25): void
    {
        $ids = DB::table('automation_authorizations')->where('scope_key', AutomationAuthorizationService::SCOPE)
            ->whereIn('state', ['ACTIVE', 'PAUSED'])->orderBy('last_checked_at')->orderBy('id')
            ->limit(max(1, min(100, $limit)))->pluck('user_id');
        foreach ($ids as $userId) {
            DB::transaction(function () use ($userId) {
                app(CurrentQuestionnaire::class)->lock();
                $user = User::whereKey($userId)->lockForUpdate()->first();
                if (! $user) { return; }
                $auth = app(AutomationAuthorizationService::class);
                $grant = $auth->row((int) $userId, true);
                if (! $grant) { return; }
                DB::table('automation_authorizations')->where('id', $grant->id)->update(['last_checked_at' => now()]);
                if ($auth->effectiveState($grant) === 'EXPIRED' && $grant->state !== 'EXPIRED') {
                    DB::table('automation_authorizations')->where('id', $grant->id)->update([
                        'state' => 'EXPIRED', 'revision' => $grant->revision + 1, 'updated_at' => now(),
                    ]);
                    $auth->cancelTasks((int) $userId, 'EXPIRED');
                    $auth->pauseParticipation((int) $userId);
                    $auth->audit((int) $userId, null, 'AUTHORIZATION_EXPIRED');
                    return;
                }
                if ($auth->effectiveState($grant) !== 'ACTIVE') { return; }
                $round = $this->round();
                $cycle = $round ? 'round:'.$round->round_key : 'waiting:'.$grant->revision;
                $fingerprint = $this->fingerprint($user, $grant, $round);
                $task = DB::table('automation_tasks')->where('user_id', $userId)
                    ->where('scope_key', AutomationAuthorizationService::SCOPE)->where('cycle_key', $cycle)->lockForUpdate()->first();
                if ($task && (in_array($task->state, ['RUNNING', 'UNKNOWN', 'QUEUED'], true)
                    || ($task->authorization_revision === $grant->revision
                        && ($task->state !== 'SKIPPED' || hash_equals($task->condition_fingerprint, $fingerprint))))) {
                    return;
                }
                $values = ['authorization_id' => $grant->id, 'authorization_revision' => $grant->revision,
                    'round_id' => $round->id ?? null, 'condition_fingerprint' => $fingerprint,
                    'state' => 'QUEUED', 'attempt_count' => 0, 'max_attempts' => (int) config('user_automation.max_attempts'),
                    'available_at' => now(), 'started_at' => null, 'finished_at' => null,
                    'lease_owner' => null, 'lease_expires_at' => null, 'fencing_token' => ($task->fencing_token ?? 0) + 1,
                    'result_code' => null, 'error_code' => null, 'reconciliation' => 'NONE', 'updated_at' => now()];
                if ($task) {
                    DB::table('automation_tasks')->where('id', $task->id)->update($values);
                    $taskId = $task->id;
                } else {
                    $taskId = DB::table('automation_tasks')->insertGetId($values + ['user_id' => $userId,
                        'scope_key' => AutomationAuthorizationService::SCOPE, 'cycle_key' => $cycle,
                        'idempotency_key' => hash('sha256', $userId.'|'.AutomationAuthorizationService::SCOPE.'|'.$cycle),
                        'correlation_id' => (string) Str::uuid(), 'created_at' => now()]);
                }
                $auth->audit((int) $userId, $taskId, 'TASK_QUEUED');
            });
        }
    }

    private function round(): ?object
    {
        $id = DB::table('dating_round_channels')->where('channel_key', 'default')->value('active_round_id');
        return $id ? DB::table('dating_rounds')->where('id', $id)
            ->when(DB::transactionLevel() > 0, fn ($query) => $query->lockForUpdate())->first() : null;
    }

    private function fingerprint(User $user, object $grant, ?object $round): string
    {
        $proposal = DB::table('match_proposals')->join('match_proposal_slots', 'match_proposal_slots.proposal_id', '=', 'match_proposals.id')
            ->where('match_proposal_slots.user_id', $user->id)->first(['match_proposals.revision', 'match_proposals.expires_at']);
        return hash('sha256', json_encode([$grant->revision, $user->updated_at?->toISOString(),
            app(AutomationAuthorizationService::class)->eligible($user),
            app(MatchingInputService::class)->sourceDigest($user),
            DB::table('admin_versions')->where('key', 'questionnaire')->value('revision'),
            DB::table('lifestyle_discoveries')->where('user_id', $user->id)->value('revision'),
            DB::table('matching_participations')->where('user_id', $user->id)->value('revision'),
            DB::table('match_proposal_slots')->where('user_id', $user->id)->value('proposal_id'),
            $proposal->revision ?? null, $proposal ? CarbonImmutable::parse($proposal->expires_at)->lte(now()) : null,
            $round->state_version ?? null], JSON_THROW_ON_ERROR));
    }

    public function claim(string $worker): ?object
    {
        $eligible = function ($query) {
            $query->where(fn ($q) => $q->whereIn('state', ['QUEUED', 'UNKNOWN'])->where('available_at', '<=', now()))
                ->orWhere(fn ($q) => $q->where('state', 'RUNNING')->where('lease_expires_at', '<=', now()));
        };
        // Locator outside the transaction, then the same User -> task order as cancellation.
        $hint = DB::table('automation_tasks')->where('scope_key', AutomationAuthorizationService::SCOPE)
            ->where($eligible)->orderBy('available_at')->orderBy('id')->first();
        if (! $hint) { return null; }
        return DB::transaction(function () use ($worker, $hint, $eligible) {
            User::whereKey($hint->user_id)->lockForUpdate()->firstOrFail();
            $task = DB::table('automation_tasks')->where('id', $hint->id)
                ->where('scope_key', AutomationAuthorizationService::SCOPE)->where($eligible)->lockForUpdate()->first();
            if (! $task) { return null; }
            $unknown = in_array($task->state, ['RUNNING', 'UNKNOWN'], true);
            $changes = ['state' => $unknown ? 'UNKNOWN' : 'RUNNING',
                'attempt_count' => $task->attempt_count + ($unknown ? 0 : 1),
                'reconciliation' => $unknown ? 'REQUIRED' : $task->reconciliation,
                'lease_owner' => mb_substr($worker, 0, 100), 'fencing_token' => $task->fencing_token + 1,
                'lease_expires_at' => now()->addSeconds((int) config('user_automation.lease_seconds')),
                'available_at' => now()->addSeconds((int) config('user_automation.lease_seconds')),
                'started_at' => $task->started_at ?? now(), 'updated_at' => now()];
            DB::table('automation_tasks')->where('id', $task->id)->update($changes);
            app(AutomationAuthorizationService::class)->audit((int) $task->user_id, $task->id, $unknown ? 'RECONCILIATION_CLAIMED' : 'TASK_CLAIMED');
            return DB::table('automation_tasks')->where('id', $task->id)->first();
        });
    }

    private function owns(object $task, object $claim): bool
    {
        return in_array($task->state, ['RUNNING', 'UNKNOWN'], true)
            && (int) $task->fencing_token === (int) $claim->fencing_token
            && $task->lease_owner === $claim->lease_owner && $task->lease_expires_at
            && CarbonImmutable::parse($task->lease_expires_at)->isFuture();
    }

    public function apply(object $claim): void
    {
        DB::transaction(function () use ($claim) {
            app(CurrentQuestionnaire::class)->lock();
            $user = User::whereKey($claim->user_id)->lockForUpdate()->first();
            if (! $user) { return; }
            $auth = app(AutomationAuthorizationService::class);
            $grant = $auth->row((int) $user->id, true);
            $task = DB::table('automation_tasks')->where('id', $claim->id)->lockForUpdate()->first();
            if (! $task || ! $this->owns($task, $claim)) { return; }
            // The effect receipt and the business write commit in one DB transaction.
            $receipt = DB::table('automation_effects')->where('task_id', $task->id)
                ->where('authorization_revision', $task->authorization_revision)->first();
            if ($receipt) {
                $current = app(SlowDatingService::class)->participation((int) $user->id);
                $sameGeneration = $current['generation'] === (int) $receipt->participation_generation;
                $this->finish($task, 'SUCCEEDED', $sameGeneration ? 'RECONCILED_EFFECT' : 'RECONCILED_EFFECT_SOURCE_CHANGED', 'CONFIRMED');
                return;
            }
            if (! $grant || $auth->effectiveState($grant) !== 'ACTIVE'
                || (int) $grant->revision !== (int) $task->authorization_revision) {
                $this->finish($task, $grant && $auth->effectiveState($grant) === 'EXPIRED' ? 'EXPIRED' : 'CANCELLED', 'AUTHORIZATION_CHANGED');
                return;
            }
            if ($task->state === 'UNKNOWN') {
                if ($task->attempt_count >= $task->max_attempts) {
                    $this->finish($task, 'FAILED', 'RETRY_EXHAUSTED', 'NO_EFFECT_CONFIRMED');
                } else {
                    $backoff = config('user_automation.retry_seconds');
                    DB::table('automation_tasks')->where('id', $task->id)->update([
                        'state' => 'QUEUED', 'reconciliation' => 'NO_EFFECT_CONFIRMED',
                        'fencing_token' => $task->fencing_token + 1, 'lease_owner' => null, 'lease_expires_at' => null,
                        'available_at' => now()->addSeconds($backoff[min($task->attempt_count - 1, count($backoff) - 1)]), 'updated_at' => now(),
                    ]);
                    $auth->audit((int) $user->id, $task->id, 'NO_EFFECT_RETRY_SCHEDULED');
                }
                return;
            }
            $round = $this->round();
            if (! $user->disabled && $user->account_status === 'active' && $round
                && (int) $round->id === (int) $task->round_id && $round->state === 'preparing'
                && $round->active_run_id === null && $auth->eligible($user) === null) {
                app(SlowDatingService::class)->reconcileOwnProposalDeadlines((int) $user->id);
            }
            $reason = match (true) {
                $user->disabled || $user->account_status !== 'active' => 'ACCOUNT_UNAVAILABLE',
                ! $round || ! $task->round_id => 'NO_OPEN_ROUND',
                (int) $round->id !== (int) $task->round_id || $round->state !== 'preparing'
                    || $round->active_run_id !== null => 'ROUND_NOT_OPEN',
                DB::table('match_proposal_slots')->where('user_id', $user->id)->exists() => 'EXISTING_PROPOSAL',
                default => $auth->eligible($user),
            };
            if ($reason !== null) {
                DB::table('automation_tasks')->where('id', $task->id)->update([
                    'condition_fingerprint' => $this->fingerprint($user, $grant, $round),
                ]);
                $this->finish($task, 'SKIPPED', $reason);
                return;
            }
            $participation = app(SlowDatingService::class)->participation((int) $user->id);
            if ($participation['state'] !== 'ACTIVE') {
                $participation = app(SlowDatingService::class)->participate((int) $user->id, 'opt_in', $participation['revision'], $participation['intent']);
            }
            DB::table('matching_participations')->where('user_id', $user->id)->update([
                'automation_authorization_id' => $grant->id, 'automation_authorization_revision' => $grant->revision,
                'automation_round_id' => $round->id,
            ]);
            DB::table('automation_effects')->updateOrInsert(['task_id' => $task->id], ['user_id' => $user->id,
                'authorization_revision' => $task->authorization_revision,
                'participation_revision' => $participation['revision'], 'participation_generation' => $participation['generation'], 'created_at' => now()]);
            $auth->audit((int) $user->id, $task->id, 'EFFECT_COMMITTED');
        });
    }

    public function complete(object $claim): void
    {
        DB::transaction(function () use ($claim) {
            User::whereKey($claim->user_id)->lockForUpdate()->firstOrFail();
            $task = DB::table('automation_tasks')->where('id', $claim->id)->lockForUpdate()->first();
            if ($task && $this->owns($task, $claim)
                && DB::table('automation_effects')->where('task_id', $task->id)
                    ->where('authorization_revision', $task->authorization_revision)->exists()) {
                $this->finish($task, 'SUCCEEDED', 'PARTICIPATION_COORDINATED', 'CONFIRMED');
            }
        });
    }

    private function finish(object $task, string $state, string $code, string $reconciliation = 'NONE'): void
    {
        DB::table('automation_tasks')->where('id', $task->id)->update(['state' => $state,
            'result_code' => $code, 'reconciliation' => $reconciliation, 'finished_at' => now(),
            'lease_owner' => null, 'lease_expires_at' => null, 'updated_at' => now()]);
        app(AutomationAuthorizationService::class)->audit((int) $task->user_id, $task->id, $state.':'.$code);
    }
}
