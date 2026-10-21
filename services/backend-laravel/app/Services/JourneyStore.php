<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;

/** All user-facing mutations lock current users BEFORE any consistent reads. */
final class JourneyStore
{
    public function users(array $ids, bool $allowUnavailable = false): void
    {
        $ids = array_values(array_unique(array_map('intval', $ids)));
        sort($ids, SORT_NUMERIC);
        $users = User::whereIn('id', $ids)->orderBy('id')->lockForUpdate()->get();
        abort_unless($users->count() === count($ids), 404, 'unavailable');
        $actor = request()->user();
        if ($actor && in_array((int) $actor->id, $ids, true)) {
            $currentActor = $users->firstWhere('id', $actor->id);
            abort_unless($currentActor && ! $currentActor->disabled && $currentActor->account_status === 'active', 403, 'account unavailable');
            $token = $actor->currentAccessToken();
            if ($token instanceof \Laravel\Sanctum\PersonalAccessToken && $token->getKey()) {
                $current = \Laravel\Sanctum\PersonalAccessToken::whereKey($token->id)->lockForUpdate()->first();
                abort_unless($current && (int)$current->tokenable_id === (int)$actor->id && $current->tokenable_type === $actor->getMorphClass() && $current->can('*') && (! $current->expires_at || $current->expires_at->isFuture()), 401, 'SESSION_REVOKED');
                if ($current->device_session_id) {
                    abort_unless(DB::table('device_sessions')->where('id', $current->device_session_id)->where('user_id', $actor->id)->whereNull('revoked_at')->lockForUpdate()->exists(), 401, 'SESSION_REVOKED');
                }
            }
        }
        if (! $allowUnavailable) {
            abort_if($users->contains(fn ($u) => $u->disabled || $u->account_status !== 'active' || $u->moderation_status !== 'normal'), 403, 'account unavailable');
            if (count($ids) === 2) {
                abort_unless(app(SocialPolicy::class)->pairAllowed($ids[0], $ids[1]), 404, 'unavailable');
            }
        }
    }

    public function command(int $actor, string $key, array $input, callable $work): array
    {
        $fingerprint = hash('sha256', json_encode($input, JSON_THROW_ON_ERROR));
        $old = DB::table('journey_commands')->where('actor_id', $actor)->where('idempotency_key', $key)->lockForUpdate()->first();
        if ($old) {
            abort_unless(hash_equals($old->fingerprint, $fingerprint), 409, 'idempotency conflict');
            $response = json_decode($old->response, true, 512, JSON_THROW_ON_ERROR);
            if (isset($response['id'], $response['revision'])) {
                $table = str_starts_with((string)($input[0] ?? ''), 'proposal_') ? 'match_proposals' : 'formal_relationships';
                $current = DB::table($table)->where('id', $response['id'])->lockForUpdate()->first();
                abort_unless($current && (int)$current->revision === (int)$response['revision'], 409, 'replayed command has superseded authority');
                if ($table === 'match_proposals') { return app(SlowDatingService::class)->projectLocked($current, $actor); }
            }
            return $response;
        }
        $result = $work();
        DB::table('journey_commands')->insert(['actor_id' => $actor, 'idempotency_key' => $key, 'fingerprint' => $fingerprint, 'response' => json_encode(array_diff_key($result, array_flip(['showcase','explanation']))), 'created_at' => now(), 'updated_at' => now()]);
        return $result;
    }

    public function audit(?int $actor, string $id, string $action, array $facts): void
    {
        DB::table('journey_audits')->insert(['actor_id' => $actor, 'aggregate_id' => $id, 'action' => $action, 'facts' => json_encode($facts), 'created_at' => now(), 'updated_at' => now()]);
    }
}
