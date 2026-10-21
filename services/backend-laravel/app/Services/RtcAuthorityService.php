<?php

namespace App\Services;

use App\Models\RtcSession;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Throwable;

/** Every RTC use point reads the same current persisted CN/MC authority. */
final class RtcAuthorityService
{
    public function enabled(): bool
    {
        if (! config('rtc_guard.enabled') || ! app()->environment(['local', 'testing'])) {
            return false;
        }
        if (app()->environment('testing')) {
            return DB::connection()->getDriverName() === 'sqlite';
        }
        $db = DB::connection();

        return app(LiveConsentService::class)->enabled() && in_array([$db->getDatabaseName(), (int) $db->getConfig('port')], [['elitesync_v1009_dev', 43319], ['elitesync_v10_1_1_dev', 43322], ['elitesync_v10_1_2_dev', 43323], ['elitesync_v1015_dev', 43326]], true) && $db->getConfig('host') === '127.0.0.1';
    }

    public function signature(int $a, int $b): ?string
    {
        if (! $this->enabled()) {
            return null;
        }
        $service = app(LiveConsentService::class);
        $gates = $service->gates($a, $b);
        if (! ($gates['live_read_allowed'] ?? false) || ! ($gates['live_send_allowed'] ?? false)) {
            return null;
        }
        $cn = $service->connection($a, $b, true);
        if (! $cn) {
            return null;
        }
        $rows = DB::table('messaging_consents')->where('connection_id', $cn->id)->orderBy('id')->lockForUpdate()->get();

        return hash('sha256', json_encode([$cn->match_id, $cn->id, $cn->revision, $rows->map(fn ($r) => [$r->id, $r->generation, $r->revision, $r->state, $r->connection_revision])->all()], JSON_THROW_ON_ERROR));
    }

    public function authorized(RtcSession $call, ?int $actor = null, bool $join = false): bool
    {
        try {
            return DB::transaction(function () use ($call, $actor, $join) {
                $locked = RtcSession::whereKey($call->id)->lockForUpdate()->first();
                if (! $locked) {
                    return $this->deny($call, 'call_missing');
                }
                $call->setRawAttributes($locked->getAttributes(), true);
                foreach (($call->metadata['device_sessions'] ?? []) as $userId => $family) {
                    $device = DB::table('device_sessions')->where('id', $family)->where('user_id', $userId)->whereNull('revoked_at')->first();
                    if (! $device) {
                        return $this->deny($call, 'device_session_revoked');
                    }
                    if (app(\App\Services\Accounts\DeviceSessions::class)->onlineDeadline($device) <= now()) return $this->deny($call, 'device_session_expired');
                }
                $call = app(RtcSessionService::class)->refreshExpiredSession($call);
                if ($actor !== null && ! in_array($actor, [(int) $call->initiator_user_id, (int) $call->peer_user_id], true)) {
                    return $this->deny($call, 'actor_not_participant');
                }
                $signature = $this->signature((int) $call->initiator_user_id, (int) $call->peer_user_id);
                $expected = (string) ($call->metadata['authority_signature'] ?? '');
                if (! $signature) {
                    return $this->deny($call, 'current_authority_unavailable');
                }
                if (! $expected) {
                    return $this->deny($call, 'stored_signature_missing');
                }
                if (! hash_equals($expected, $signature)) {
                    return $this->deny($call, 'authority_signature_changed');
                }
                if ($join && (! in_array($call->status, ['connecting', 'in_call'], true) || ! $call->accepted_at || ! $call->expires_at?->isFuture())) {
                    return $this->deny($call, 'join_not_active');
                }

                return true;
            }, 3);
        } catch (Throwable $error) {
            $this->deny($call, 'exception', $error);
            // Preserve database errors for the outer transaction's bounded retry.
            // A failed check must never be reported as confirmed revocation.
            throw $error;
        }
    }

    /** Never log exception messages, SQL, bindings, tokens or authority signatures. */
    private function deny(RtcSession $call, string $reason, ?Throwable $error = null): bool
    {
        $context = ['call_id' => (int) $call->id, 'reason' => $reason];
        if ($error) {
            $context['exception_class'] = get_class($error);
            $context['exception_code'] = is_int($error->getCode()) ? $error->getCode() : 'non_numeric';
            if ($error instanceof \PDOException) {
                $info = $error->errorInfo;
                if (is_array($info) && is_string($info[0] ?? null) && preg_match('/\A[A-Z0-9]{5}\z/D', $info[0])) {
                    $context['sqlstate'] = $info[0];
                }
                if (is_array($info) && is_int($info[1] ?? null)) {
                    $context['driver_code'] = $info[1];
                }
            }
        }
        try {
            Log::warning('rtc_authority_denied', $context);
        } catch (Throwable) {
            // Diagnostics must not turn a denial into an exception or an allow.
        }

        return false;
    }

    public function identity(RtcSession $call, int $actor): string
    {
        return 'p-'.substr(hash('sha256', $call->call_key.':'.$actor), 0, 32);
    }

    public function bindDevice(RtcSession $call, int $actor, ?string $family): void
    {
        if (! $family) {
            return;
        }
        DB::transaction(function () use ($call, $actor, $family) {
            $fresh = RtcSession::whereKey($call->id)->lockForUpdate()->firstOrFail();
            abort_unless(in_array($actor, [(int) $fresh->initiator_user_id, (int) $fresh->peer_user_id], true), 404);
            abort_unless(DB::table('device_sessions')->where('id', $family)->where('user_id', $actor)->whereNull('revoked_at')->lockForUpdate()->first(), 401);
            $metadata = $fresh->metadata ?? [];
            $bound = $metadata['device_sessions'][(string) $actor] ?? null;
            abort_if($bound && $bound !== $family, 403, 'call belongs to another device session');
            $metadata['device_sessions'][(string) $actor] = $family;
            $fresh->forceFill(['metadata' => $metadata])->save();
            $call->setRawAttributes($fresh->getAttributes(), true);
        });
    }

    public function revokeDevice(int $userId, ?string $family): void
    {
        if (! Schema::hasTable('rtc_sessions')) {
            return;
        }
        foreach (RtcSession::where(fn ($q) => $q->where('initiator_user_id', $userId)->orWhere('peer_user_id', $userId))->whereIn('status', ['calling', 'ringing', 'connecting', 'in_call'])->get() as $call) {
            if ($family === null || ($call->metadata['device_sessions'][(string) $userId] ?? null) === $family) {
                $this->invalidate($call, 'device_session_revoked');
            }
        }
    }

    public function invalidate(RtcSession $call, string $reason): void
    {
        DB::transaction(function () use ($call, $reason) {
            $fresh = RtcSession::whereKey($call->id)->lockForUpdate()->first();
            if (! $fresh || in_array($fresh->status, ['ended', 'failed', 'rejected', 'missed', 'busy'], true)) {
                return;
            }
            $fresh->forceFill(['status' => 'ended', 'ended_at' => now(), 'failure_code' => $reason, 'failure_message' => '通话权限已失效'])->save();
            $fresh->events()->create(['event_name' => 'authority_invalidated', 'payload' => ['reason' => $reason]]);
        });
    }
}
