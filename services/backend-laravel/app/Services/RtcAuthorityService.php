<?php
namespace App\Services;

use App\Models\RtcSession;
use Illuminate\Support\Facades\DB;
use Throwable;

/** Every RTC use point reads the same current persisted CN/MC authority. */
final class RtcAuthorityService
{
    public function enabled(): bool
    {
        if (!config('rtc_guard.enabled') || !app()->environment(['local', 'testing'])) return false;
        if (app()->environment('testing')) return DB::connection()->getDriverName() === 'sqlite';
        $db = DB::connection();
        return app(LiveConsentService::class)->enabled() && $db->getDatabaseName() === 'elitesync_v1009_dev'
            && (int)$db->getConfig('port') === 43319 && $db->getConfig('host') === '127.0.0.1';
    }

    public function signature(int $a, int $b): ?string
    {
        if (!$this->enabled()) return null;
        $service = app(LiveConsentService::class);
        $gates = $service->gates($a, $b);
        if (!($gates['live_read_allowed'] ?? false) || !($gates['live_send_allowed'] ?? false)) return null;
        $match = $service->match($a, $b, true);
        if (!$match) return null;
        $cn = DB::table('product_connections')->where('match_id', $match->id)->lockForUpdate()->first();
        if (!$cn) return null;
        $rows = DB::table('messaging_consents')->where('connection_id', $cn->id)->orderBy('id')->lockForUpdate()->get();
        return hash('sha256', json_encode([$match->id, $cn->id, $cn->revision, $rows->map(fn($r) => [$r->id, $r->generation, $r->revision, $r->state, $r->connection_revision])->all()], JSON_THROW_ON_ERROR));
    }

    public function authorized(RtcSession $call, ?int $actor = null, bool $join = false): bool
    {
        try {
            return DB::transaction(function () use ($call, $actor, $join) {
                $locked = RtcSession::whereKey($call->id)->lockForUpdate()->first();
                if (!$locked) return false;
                $call->setRawAttributes($locked->getAttributes(), true);
                $call = app(RtcSessionService::class)->refreshExpiredSession($call);
                if ($actor !== null && !in_array($actor, [(int)$call->initiator_user_id, (int)$call->peer_user_id], true)) return false;
                $signature = $this->signature((int)$call->initiator_user_id, (int)$call->peer_user_id);
                $expected = (string)($call->metadata['authority_signature'] ?? '');
                if (!$signature || !$expected || !hash_equals($expected, $signature)) return false;
                if ($join && (!in_array($call->status, ['connecting', 'in_call'], true) || !$call->accepted_at || !$call->expires_at?->isFuture())) return false;
                return true;
            });
        } catch (Throwable) { return false; }
    }

    public function identity(RtcSession $call, int $actor): string
    {
        return 'p-'.substr(hash('sha256', $call->call_key.':'.$actor), 0, 32);
    }

    public function invalidate(RtcSession $call, string $reason): void
    {
        DB::transaction(function () use ($call, $reason) {
            $fresh = RtcSession::whereKey($call->id)->lockForUpdate()->first();
            if (!$fresh || in_array($fresh->status, ['ended','failed','rejected','missed','busy'], true)) return;
            $fresh->forceFill(['status'=>'ended','ended_at'=>now(),'failure_code'=>$reason,'failure_message'=>'通话权限已失效'])->save();
            $fresh->events()->create(['event_name'=>'authority_invalidated','payload'=>['reason'=>$reason]]);
        });
    }
}
