<?php

namespace App\Services;

use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

final class AutomationAuthorizationService
{
    public const SCOPE = 'weekly_slow_dating_participation';

    public function effectiveState(?object $row): string
    {
        if (! $row) { return 'OFF'; }
        if (in_array($row->state, ['ACTIVE', 'PAUSED'], true)
            && ($row->policy_version !== config('user_automation.policy_version')
                || $row->consent_version !== config('user_automation.consent_version')
                || ($row->expires_at && CarbonImmutable::parse($row->expires_at)->lte(now())))) {
            return 'EXPIRED';
        }
        return $row->state;
    }

    public function row(int $userId, bool $lock = false): ?object
    {
        return DB::table('automation_authorizations')->where('user_id', $userId)->where('scope_key', self::SCOPE)
            ->when($lock, fn ($query) => $query->lockForUpdate())->first();
    }

    public function read(int $userId): array
    {
        $row = $this->row($userId, DB::transactionLevel() > 0);
        $task = DB::table('automation_tasks')->where('user_id', $userId)->orderByDesc('updated_at')->orderByDesc('id')->first();
        return [
            'code' => $this->effectiveState($row), 'scope_key' => self::SCOPE,
            'policy_version' => config('user_automation.policy_version'),
            'consent_version' => config('user_automation.consent_version'),
            'source_revision' => (int) ($row->revision ?? 0), 'source_updated_at' => $row->updated_at ?? null,
            'granted_at' => $row->granted_at ?? null, 'paused_at' => $row->paused_at ?? null,
            'revoked_at' => $row->revoked_at ?? null, 'expires_at' => $row->expires_at ?? null,
            'last_checked_at' => $row->last_checked_at ?? null,
            'duration_code' => $row?->expires_at ? 'UNTIL_EXPIRY' : 'UNTIL_PAUSE_REVOKE_OR_POLICY_CHANGE',
            'recent_task' => $task ? ['id' => $task->id, 'code' => $task->state,
                'result_code' => $task->result_code, 'error_code' => $task->error_code,
                'attempt_count' => $task->attempt_count, 'max_attempts' => $task->max_attempts,
                'reconciliation' => $task->reconciliation, 'updated_at' => $task->updated_at] : null,
            'next_planned_at' => $this->effectiveState($row) === 'ACTIVE'
                ? DB::table('automation_tasks')->where('user_id', $userId)->where('state', 'QUEUED')->min('available_at') : null,
        ];
    }

    public function eligible(User $user): ?string
    {
        if (! app(LifestyleDiscoveryService::class)->completed((int) $user->id, DB::transactionLevel() > 0)) {
            return 'LIFESTYLE_INCOMPLETE';
        }
        $readiness = app(ProfileReadinessService::class)->forUser($user)['matching_eligibility'];
        return $readiness['eligible'] ? null : $readiness['reason_code'];
    }

    public function command(User $actor, array $data): array
    {
        abort_unless($data['policy_version'] === config('user_automation.policy_version')
            && $data['consent_version'] === config('user_automation.consent_version'), 422, 'automation policy changed');
        $hash = hash('sha256', json_encode([$data['action'], (int) $data['expected_revision'],
            $data['policy_version'], $data['consent_version'], $data['expires_at'] ?? null], JSON_THROW_ON_ERROR));
        return DB::transaction(function () use ($actor, $data, $hash) {
            app(CurrentQuestionnaire::class)->lock();
            app(JourneyStore::class)->users([(int) $actor->id]);
            $user = User::findOrFail($actor->id);
            $row = $this->row((int) $user->id, true);
            $old = DB::table('automation_commands')->where('user_id', $user->id)->where('request_key', $data['request_key'])->lockForUpdate()->first();
            if ($old) {
                abort_unless(hash_equals($old->request_hash, $hash), 409, 'automation request key reused');
                return $this->read((int) $user->id);
            }
            $revision = (int) ($row->revision ?? 0);
            abort_unless($revision === (int) $data['expected_revision'], 409, 'automation revision changed');
            $action = $data['action'];
            $effective = $this->effectiveState($row);
            if (in_array($action, ['grant', 'resume'], true)) {
                abort_unless($this->eligible($user) === null, 422, 'automation preparation incomplete');
            }
            $state = match ($action) {
                'grant' => 'ACTIVE',
                'pause' => 'PAUSED',
                'resume' => 'ACTIVE',
                'revoke' => 'REVOKED',
            };
            if ($action === 'grant') {
                abort_unless(in_array($effective, ['OFF', 'REVOKED', 'EXPIRED'], true), 409, 'automation already authorized');
            }
            if ($action !== 'grant') {
                abort_unless($row && ($action === 'resume' ? $effective === 'PAUSED'
                    : in_array($effective, ['ACTIVE', 'PAUSED', 'EXPIRED'], true)), 409, 'automation action unavailable');
            }
            DB::table('automation_authorizations')->updateOrInsert(['user_id' => $user->id, 'scope_key' => self::SCOPE], [
                'policy_version' => $data['policy_version'], 'consent_version' => $data['consent_version'],
                'state' => $state, 'revision' => $revision + 1,
                'granted_at' => $action === 'grant' ? now() : $row->granted_at,
                'paused_at' => $action === 'pause' ? now() : null,
                'revoked_at' => $action === 'revoke' ? now() : null,
                'expires_at' => $action === 'grant' ? ($data['expires_at'] ?? null) : $row->expires_at,
                'created_at' => $row->created_at ?? now(), 'updated_at' => now(),
            ]);
            $this->cancelTasks((int) $user->id, $state === 'EXPIRED' ? 'EXPIRED' : 'CANCELLED');
            if (in_array($state, ['PAUSED', 'REVOKED'], true)) { $this->pauseParticipation((int) $user->id); }
            DB::table('automation_commands')->insert(['user_id' => $user->id, 'request_key' => $data['request_key'],
                'request_hash' => $hash, 'action' => $action, 'applied_revision' => $revision + 1, 'created_at' => now()]);
            $this->audit((int) $user->id, null, 'AUTHORIZATION_'.strtoupper($action));
            return $this->read((int) $user->id);
        });
    }

    public function cancelTasks(int $userId, string $state): void
    {
        DB::table('automation_tasks')->where('user_id', $userId)->whereIn('state', ['QUEUED', 'RUNNING', 'UNKNOWN'])
            ->update(['state' => $state, 'result_code' => 'AUTHORIZATION_CHANGED',
                'fencing_token' => DB::raw('fencing_token + 1'), 'finished_at' => now(), 'updated_at' => now()]);
    }

    public function pauseParticipation(int $userId): void
    {
        $participation = app(SlowDatingService::class)->participation($userId);
        if ($participation['state'] === 'ACTIVE') {
            app(SlowDatingService::class)->participate($userId, 'pause', $participation['revision'], $participation['intent']);
        }
    }

    /** Called inside the existing manual participation transaction. */
    public function suspendFromParticipation(int $userId, string $action): void
    {
        $row = $this->row($userId, true);
        if (! $row || ! in_array($row->state, ['ACTIVE', 'PAUSED'], true)) { return; }
        $state = $action === 'exit' ? 'REVOKED' : 'PAUSED';
        if ($row->state === $state) { return; }
        DB::table('automation_authorizations')->where('id', $row->id)->update([
            'state' => $state, 'revision' => $row->revision + 1,
            'paused_at' => $state === 'PAUSED' ? now() : $row->paused_at,
            'revoked_at' => $state === 'REVOKED' ? now() : null, 'updated_at' => now(),
        ]);
        $this->cancelTasks($userId, 'CANCELLED');
        $this->audit($userId, null, 'MANUAL_PARTICIPATION_'.strtoupper($action));
    }

    public function delegatedParticipationAllowed(object $participation): bool
    {
        if (! ($participation->automation_authorization_id ?? null)) { return true; }
        $row = $this->row((int) $participation->user_id, DB::transactionLevel() > 0);
        return $row && (int) $row->id === (int) $participation->automation_authorization_id
            && (int) $row->revision === (int) $participation->automation_authorization_revision
            && $this->effectiveState($row) === 'ACTIVE';
    }

    public function roundAllowed(int $userId, int $roundId): bool
    {
        $participation = DB::table('matching_participations')->where('user_id', $userId)
            ->when(DB::transactionLevel() > 0, fn ($query) => $query->lockForUpdate())->first();
        return ! ($participation->automation_authorization_id ?? null)
            || ((int) $participation->automation_round_id === $roundId && $this->delegatedParticipationAllowed($participation));
    }

    public function audit(int $userId, ?int $taskId, string $action): void
    {
        DB::table('automation_audits')->insert(['user_id' => $userId, 'task_id' => $taskId,
            'action' => $action, 'created_at' => now()]);
    }
}
