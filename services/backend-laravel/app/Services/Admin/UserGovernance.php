<?php

namespace App\Services\Admin;

use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Accounts\DisableUser;
use App\Services\CurrentQuestionnaire;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

final class UserGovernance
{
    private const FIELDS = ['disabled', 'moderation_status', 'account_status', 'visibility_scope',
        'is_match_eligible', 'is_square_visible', 'exclude_from_metrics'];

    public function target(User $actor, int $id): User
    {
        // Shared with status deletion/read authorization: never actor-first
        // when the target may have a lower id.
        $users = User::whereIn('id', [$actor->id, $id])->orderBy('id')->lockForUpdate()->get()->keyBy('id');
        $trusted = $users->get($actor->id);
        abort_unless(app(AdminAccess::class)->allows($trusted), 403);
        $user = $users->get($id);
        abort_unless($user, 404);
        abort_unless($user->role === 'user' && $user->id !== $actor->id, 403);

        return $user;
    }

    private function version(User $user, int $expected): void
    {
        abort_unless((int) $user->admin_revision === $expected, 409, 'stale user revision');
    }

    private function reason(string $reason): void
    {
        abort_unless(trim($reason) !== '' && mb_strlen($reason) <= 1000, 422, 'reason required');
    }

    public function review(User $actor, int $id, string $status, string $reason, int $expected): void
    {
        $this->reason($reason);
        abort_unless(in_array($status, ['pending', 'approved', 'rejected'], true), 422);
        DB::transaction(function () use ($actor, $id, $status, $reason, $expected) {
            app(CurrentQuestionnaire::class)->lock();
            $user = $this->target($actor, $id);
            abort_unless((int) $user->verify_revision === $expected, 409, 'stale verification revision');
            $before = ['status' => $user->verify_status, 'revision' => (int) $user->verify_revision];
            $user->forceFill(['verify_status' => $status, 'verify_reason' => $reason, 'verify_revision' => $expected + 1])->save();
            OperationAudit::record($actor->id, 'user.review', 'user', $id, $reason, $expected,
                $before, ['status' => $status, 'revision' => $expected + 1]);
        });
    }

    public function punish(User $actor, int $id, string $kind, string $reason, int $expected, ?int $report = null): int
    {
        $this->reason($reason);
        abort_unless(in_array($kind, ['restrict', 'banned'], true), 422);

        return DB::transaction(function () use ($actor, $id, $kind, $reason, $expected, $report) {
            app(CurrentQuestionnaire::class)->lock();
            $user = $this->target($actor, $id);
            $this->version($user, $expected);
            $before = $this->summary($user);
            $active = $this->activeSanctions($id);
            if ($user->disabled && ! $active->contains(fn ($s) => in_array($s->kind, ['banned', 'external_ban'], true))) {
                DB::table('admin_sanctions')->insert(['user_id' => $id, 'report_id' => null,
                    'kind' => 'external_ban', 'active' => true, 'actor_user_id' => $actor->id,
                    'reason' => 'Pre-existing independent disable; not restorable through this action',
                    'created_at' => now(), 'updated_at' => now()]);
                $active = $this->activeSanctions($id);
            }
            $prior = $this->baseline($user, $active);
            if ($kind === 'banned') {
                app(DisableUser::class)->execute($id);
                $user->refresh();
                $this->revokeConsent($id, $actor->id);
            } else {
                if (! $user->disabled) {
                    $user->moderation_status = 'restricted';
                }
                $user->is_match_eligible = false;
            }
            $user->admin_revision = $expected + 1;
            $user->save();
            $sid = DB::table('admin_sanctions')->insertGetId(['user_id' => $id, 'report_id' => $report,
                'kind' => $kind, 'active' => true, 'actor_user_id' => $actor->id, 'reason' => $reason,
                'prior_state' => $this->encodeState($prior),
                'applied_state' => $this->encodeState($this->attributes($user),
                    $kind === 'banned' ? $this->disableFingerprint($user) : null),
                'created_at' => now(), 'updated_at' => now()]);
            OperationAudit::record($actor->id, 'user.'.$kind, 'user', $id, $reason, $expected,
                $before, $this->summary($user) + ['sanction_id' => $sid]);

            return $sid;
        });
    }

    public function restore(User $actor, int $id, int $sanction, string $reason, int $expected, ?int $report = null): void
    {
        $this->reason($reason);
        DB::transaction(function () use ($actor, $id, $sanction, $reason, $expected, $report) {
            app(CurrentQuestionnaire::class)->lock();
            $user = $this->target($actor, $id);
            $this->version($user, $expected);
            $active = $this->activeSanctions($id);
            $selected = $active->firstWhere('id', $sanction);
            abort_unless($selected && in_array($selected->kind, ['restrict', 'banned'], true)
                && ($report === null || (int) $selected->report_id === $report), 409, 'active sanction ownership required');
            $prior = $this->baseline($user, $active);
            $before = $this->summary($user);
            $remaining = $active->reject(fn ($row) => (int) $row->id === $sanction);
            $applied = $this->overlay($prior, $active);
            $desired = $this->overlay($prior, $remaining);
            $current = $this->attributes($user);
            foreach (self::FIELDS as $field) {
                // An independently changed value belongs to its own writer, not this sanction.
                if ($current[$field] === $applied[$field]) {
                    $user->{$field} = $desired[$field];
                }
            }
            if ($user->disabled) {
                $user->is_match_eligible = false;
            }
            // Never weaken any remaining tracked restriction, including pre-existing external bans.
            if ($remaining->contains(fn ($row) => in_array($row->kind, ['banned', 'external_ban'], true))) {
                $user->forceFill($this->overlay($this->attributes($user), $remaining));
            } elseif ($remaining->contains('kind', 'restrict')) {
                $user->is_match_eligible = false;
                if (! $user->disabled) {
                    $user->moderation_status = 'restricted';
                }
            }
            DB::table('admin_sanctions')->where('id', $sanction)->update(['active' => false,
                'restored_by' => $actor->id, 'restored_at' => now(), 'updated_at' => now()]);
            $user->admin_revision = $expected + 1;
            $user->save();
            $this->revokeConsent($id, $actor->id);
            OperationAudit::record($actor->id, 'user.restore', 'user', $id, $reason, $expected,
                $before, $this->summary($user) + ['sanction_id' => $sanction]);
        });
    }

    private function activeSanctions(int $id): Collection
    {
        return DB::table('admin_sanctions')->where('user_id', $id)->where('active', true)
            ->orderBy('id')->lockForUpdate()->get();
    }

    private function attributes(User $user): array
    {
        return $user->only(self::FIELDS);
    }

    private function encodeState(array $attributes, ?string $fingerprint = null): string
    {
        return json_encode(['version' => 1, 'attributes' => $attributes,
            'disable_fingerprint' => $fingerprint], JSON_THROW_ON_ERROR);
    }

    private function decodeState(?string $encoded): array
    {
        $state = json_decode($encoded ?? '', true);
        abort_unless(is_array($state) && ($state['version'] ?? null) === 1
            && is_array($state['attributes'] ?? null)
            && count($state['attributes']) === count(self::FIELDS)
            && array_diff(self::FIELDS, array_keys($state['attributes'])) === [], 409, 'sanction prior state unavailable');

        return $state;
    }

    private function baseline(User $user, Collection $active): array
    {
        $tracked = $active->filter(fn ($row) => in_array($row->kind, ['restrict', 'banned'], true));
        if ($tracked->isEmpty()) {
            return $this->attributes($user);
        }
        foreach ($tracked as $row) {
            $this->decodeState($row->prior_state);
            $this->decodeState($row->applied_state);
        }
        // Each overlapping sanction carries the unpunished baseline, not the previous ban's effects.
        $base = $this->decodeState($tracked->last()->prior_state)['attributes'];
        $expected = $this->overlay($base, $active);
        $current = $this->attributes($user);
        foreach (self::FIELDS as $field) {
            if ($current[$field] !== $expected[$field]) {
                $base[$field] = $current[$field];
            }
        }
        $latestBan = $tracked->contains('kind', 'banned')
            ? DB::table('admin_sanctions')->where('user_id', $user->id)->where('kind', 'banned')->orderByDesc('id')->first()
            : null;
        if ($latestBan) {
            $fingerprint = $this->decodeState($latestBan->applied_state)['disable_fingerprint'] ?? null;
            abort_unless(is_string($fingerprint) && hash_equals($fingerprint, $this->disableFingerprint($user)),
                409, 'independent disable or credential change requires review');
        }

        return $base;
    }

    private function overlay(array $base, Collection $sanctions): array
    {
        if ($sanctions->contains(fn ($row) => in_array($row->kind, ['banned', 'external_ban'], true))) {
            return array_replace($base, ['disabled' => true, 'moderation_status' => 'banned',
                'account_status' => 'disabled', 'visibility_scope' => 'hidden', 'is_match_eligible' => false,
                'is_square_visible' => false, 'exclude_from_metrics' => true]);
        }
        if ($sanctions->contains('kind', 'restrict')) {
            $base['is_match_eligible'] = false;
            if (! $base['disabled']) {
                $base['moderation_status'] = 'restricted';
            }
        }

        return $base;
    }

    private function disableFingerprint(User $user): string
    {
        // Keep raw credentials out of snapshots and audits; detect a later independent DisableUser rotation.
        return hash_hmac('sha256', (string) $user->remember_token, (string) config('app.key'));
    }

    private function summary(User $user): array
    {
        return ['disabled' => (bool) $user->disabled, 'moderation_status' => $user->moderation_status,
            'revision' => (int) $user->admin_revision];
    }

    private function revokeConsent(int $id, int $actor): void
    {
        $connections = DB::table('product_connections')->where('user_a', $id)->orWhere('user_b', $id)
            ->orderBy('id')->lockForUpdate()->get();
        foreach ($connections as $connection) {
            $rows = DB::table('messaging_consents')->where('connection_id', $connection->id)
                ->orderBy('id')->lockForUpdate()->get();
            $generation = (int) ($rows->max('generation') ?? 1);
            $current = $rows->where('generation', $generation);
            if ($current->isEmpty()) {
                continue;
            }
            $revision = (int) $current->max('revision') + 1;
            DB::table('messaging_consents')->where('connection_id', $connection->id)->where('generation', $generation)
                ->whereNotIn('state', ['MC_REVOKED', 'MC_DECLINED', 'MC_WITHDRAWN'])
                ->update(['state' => 'MC_REVOKED', 'revision' => $revision, 'updated_at' => now()]);
            DB::table('live_consent_events')->insert(['connection_id' => $connection->id, 'kind' => 'sanction',
                'actor_id' => $actor, 'from_state' => 'CURRENT', 'to_state' => 'MC_REVOKED',
                'revision' => $revision, 'created_at' => now()]);
        }
    }
}
