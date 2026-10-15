<?php

namespace App\Services;

use App\Domain\CommonAuthorityEvidenceContract as Evidence;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as MC;
use App\Domain\ProductConnectionStateTransitionEvaluator as CN;
use App\Models\DatingMatch;
use App\Models\User;
use App\Models\UserBlock;
use Illuminate\Support\Facades\DB;

/** Trusted local writer/current reader. Request headers and UI projections never grant authority. */
final class LiveConsentService
{
    public function enabled(): bool
    {
        if (! config('restoration.enabled') || ! app()->environment(['local', 'testing'])) {
            return false;
        }
        if (app()->environment('testing')) {
            return DB::connection()->getDriverName() === 'sqlite';
        }
        $db = DB::connection();

        return in_array($db->getDriverName(), ['mysql', 'mariadb'], true) && $db->getDatabaseName() === 'elitesync_v1007_dev'
            && $db->getConfig('host') === '127.0.0.1' && ! $db->getConfig('unix_socket')
            && (int) $db->getConfig('port') === (int) config('restoration.port')
            && ! in_array((int) $db->getConfig('port'), [3306, 43316], true);
    }

    public function match(int $actor, int $peer, bool $lock = false): ?DatingMatch
    {
        if (! $this->enabled() || $actor === $peer) {
            return null;
        }
        $users = User::whereIn('id', [$actor, $peer])->orderBy('id');
        if ($lock) {
            $users->lockForUpdate();
        }
        $users = $users->get();
        if ($users->count() !== 2 || $users->contains(fn ($u) => $u->disabled || $u->is_synthetic)) {
            return null;
        }
        $blocks = UserBlock::where(fn ($q) => $q->where('blocker_id', $actor)->where('blocked_user_id', $peer))
            ->orWhere(fn ($q) => $q->where('blocker_id', $peer)->where('blocked_user_id', $actor));
        if ($lock) {
            $blocks->lockForUpdate();
        }if ($blocks->get()->isNotEmpty()) {
            return null;
        }
        $q = DatingMatch::where('drop_released', true)->where(fn ($q) => $q
            ->where(fn ($q) => $q->where('user_a', $actor)->where('user_b', $peer))
            ->orWhere(fn ($q) => $q->where('user_a', $peer)->where('user_b', $actor)))->orderByDesc('id');
        if ($lock) {
            $q->lockForUpdate();
        }

return $q->first();
    }

    private function identity(object $cn): array
    {
        return ['connection_identity' => 'cn:'.$cn->id, 'participants' => ['user:'.$cn->user_a, 'user:'.$cn->user_b],
            'protected_use_scope' => 'LOCAL_V1007_CONNECTION'];
    }

    private function source(string $identity, string $subject, array $participants, string $purpose, string $state, int $revision, string $kind): array
    {
        $terminal = in_array($state, ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED', 'MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true);
        $bindings = ['authority_owner' => 'laravel-v1007', 'authority_scope' => $kind, 'actor' => 'laravel-writer',
            'actor_role' => 'server-current-reader', 'subject' => $subject, 'participants' => $participants, 'audience' => 'participants',
            'purpose' => $purpose, 'aggregate_context' => $identity, 'lifecycle_identity' => $identity, 'terminal' => $terminal];

        return ['required_bindings' => $bindings, 'source_evidence' => Evidence::evidence($bindings, Evidence::CONDITION_PRESENT,
            Evidence::sourceRevision('laravel-v1007', $kind, $identity, $identity, $revision), true, true, Evidence::OUTCOME_COMMITTED)];
    }

    private function connectionEvidence(object $cn): array
    {
        $c = $this->identity($cn);

        return ['state_evidence_identity' => 'cn-state:'.$cn->id.':'.$cn->revision, 'connection_identity' => $c['connection_identity'],
            'participants' => $c['participants'], 'state' => $cn->state] + $this->source($c['connection_identity'], $c['connection_identity'],
                $c['participants'], $c['protected_use_scope'], $cn->state, (int) $cn->revision, 'connection');
    }

    private function consentIdentity(object $cn, object $mc): array
    {
        $c = $this->identity($cn);
        $requester = 'user:'.$mc->requester_id;

        return ['consent_identity' => 'mc:'.$mc->id, 'connection_identity' => $c['connection_identity'], 'participants' => $c['participants'],
            'requester' => $requester, 'recipient' => $requester === $c['participants'][0] ? $c['participants'][1] : $c['participants'][0], 'purpose' => $mc->purpose];
    }

    private function consentEvidence(object $cn, object $mc): array
    {
        $c = $this->consentIdentity($cn, $mc);
        $e = ['consent_evidence_identity' => 'mc-state:'.$mc->id.':'.$mc->revision, 'consent_identity' => $c['consent_identity'],
            'connection_identity' => $c['connection_identity'], 'participants' => $c['participants'], 'purpose' => $mc->purpose, 'state' => $mc->state]
            + $this->source($c['consent_identity'], $c['connection_identity'], $c['participants'], $mc->purpose, $mc->state, (int) $mc->revision, 'consent');
        if ((int) $mc->connection_revision !== (int) $cn->revision) {
            $e['source_evidence']['freshness'] = false;
        }

        return $e;
    }

    public function gates(int $actor, int $peer): array
    {
        return DB::transaction(fn () => $this->lockedGates($actor, $peer));
    }

    private function lockedGates(int $actor, int $peer): array
    {
        $denied = ['live_read_allowed' => false, 'live_send_allowed' => false];
        $match = $this->match($actor, $peer, true);
        if (! $match) {
            return $denied;
        }
        $cn = DB::table('product_connections')->where('match_id', $match->id)->lockForUpdate()->first();
        if (! $cn) {
            return $denied;
        }
        $rows = DB::table('messaging_consents')->where('connection_id', $cn->id)->orderBy('id')->lockForUpdate()->get()->keyBy('purpose');
        $read = $rows->get(MC::PURPOSE_LIVE_READ);
        $send = $rows->get(MC::PURPOSE_LIVE_SEND);
        if (! $read || ! $send) {
            return $denied;
        }

        return MC::evaluateLiveGates($this->identity($cn), [$this->connectionEvidence($cn)],
            $this->consentIdentity($cn, $read), [$this->consentEvidence($cn, $read)],
            $this->consentIdentity($cn, $send), [$this->consentEvidence($cn, $send)]);
    }

    public function current(int $actor, int $peer): array
    {
        $match = $this->match($actor, $peer);
        abort_unless($match, 404, 'connection unavailable');
        $cn = DB::table('product_connections')->where('match_id', $match->id)->first();
        $mc = $cn ? DB::table('messaging_consents')->where('connection_id', $cn->id)->where('purpose', MC::PURPOSE_LIVE_READ)->first() : null;

        return ['connection' => ['state' => $cn->state ?? CN::STATE_NONE, 'revision' => (int) ($cn->revision ?? 0), 'requester_id' => $cn->requester_id ?? null],
            'consent' => ['state' => $mc->state ?? MC::STATE_NONE, 'revision' => (int) ($mc->revision ?? 0), 'requester_id' => $mc->requester_id ?? null],
            'peer_id' => $peer, 'gates' => $this->gates($actor, $peer)];
    }

    public function transition(int $actor, int $peer, string $kind, string $action, int $expected): array
    {
        return DB::transaction(function () use ($actor, $peer, $kind, $action, $expected) {
            $match = $this->match($actor, $peer, true);
            abort_unless($match, 404, 'connection unavailable');
            $cn = DB::table('product_connections')->where('match_id', $match->id)->lockForUpdate()->first();
            if (! $cn) {
                abort_unless($kind === 'connection' && $action === 'request' && $expected === 0, 409, 'invalid transition');
                $id = DB::table('product_connections')->insertGetId(['match_id' => $match->id, 'user_a' => min($actor, $peer), 'user_b' => max($actor, $peer),
                    'requester_id' => $actor, 'state' => CN::STATE_NONE, 'revision' => 0, 'created_at' => now(), 'updated_at' => now()]);
                $cn = DB::table('product_connections')->where('id', $id)->first();
            }
            if ($kind === 'connection') {
                abort_unless((int) $cn->revision === $expected, 409, 'stale revision');
                $next = match ($action) {
                    'request' => CN::STATE_PENDING,'accept' => CN::STATE_ACTIVE,'decline' => CN::STATE_DECLINED,
                    'withdraw' => CN::STATE_WITHDRAWN,'close' => CN::STATE_CLOSED,'pause' => CN::STATE_PAUSED,default => null
                };
                $allowed = match ($cn->state) {
                    CN::STATE_NONE => ['request'],CN::STATE_PENDING => ['accept', 'decline', 'withdraw'],CN::STATE_ACTIVE => ['pause', 'close'],CN::STATE_PAUSED => ['close'],default => []
                };
                abort_unless(in_array($action, $allowed, true), 409, 'invalid transition');
                if (in_array($action, ['accept', 'decline'], true)) {
                    abort_if($actor === (int) $cn->requester_id, 409, 'recipient decision required');
                }
                if ($action === 'withdraw') {
                    abort_unless($actor === (int) $cn->requester_id, 409, 'requester required');
                }
                $from = $cn->state;
                $c = $this->identity($cn);
                $s = $this->connectionEvidence($cn);
                $t = $this->transitionEvidence($s, $c['connection_identity'], $c['connection_identity'], $c['participants'], $c['protected_use_scope'], $from, $next, $actor, 'connection');
                $t += ['connection_identity' => $c['connection_identity']];
                abort_unless(CN::evaluateTransition($c, [$s], [$t])['classification'] === CN::TRANSITION_ADMISSIBLE, 409, 'connection transition rejected');
                DB::table('product_connections')->where('id', $cn->id)->update(['state' => $next, 'revision' => $expected + 1, 'updated_at' => now()]);
                // A changed connection revision invalidates every downstream consent. No hidden reactivation.
                if ($next !== CN::STATE_ACTIVE) {
                    DB::table('messaging_consents')->where('connection_id', $cn->id)->where('state', MC::STATE_ACTIVE)
                        ->update(['state' => MC::STATE_REVOKED, 'revision' => DB::raw('revision+1'), 'updated_at' => now()]);
                }
            } else {
                abort_unless($cn->state === CN::STATE_ACTIVE, 409, 'active connection required');
                $next = match ($action) {
                    'request' => MC::STATE_PENDING,'accept' => MC::STATE_ACTIVE,'decline' => MC::STATE_DECLINED,'withdraw' => MC::STATE_WITHDRAWN,'revoke' => MC::STATE_REVOKED,default => null
                };
                foreach ([MC::PURPOSE_LIVE_READ, MC::PURPOSE_LIVE_SEND] as $purpose) {
                    $mc = DB::table('messaging_consents')->where('connection_id', $cn->id)->where('purpose', $purpose)->lockForUpdate()->first();
                    if (! $mc) {
                        abort_unless($action === 'request' && $expected === 0, 409, 'request required');
                        $id = DB::table('messaging_consents')->insertGetId(['connection_id' => $cn->id, 'purpose' => $purpose, 'requester_id' => $actor, 'state' => MC::STATE_NONE,
                            'revision' => 0, 'connection_revision' => $cn->revision, 'created_at' => now(), 'updated_at' => now()]);
                        $mc = DB::table('messaging_consents')->where('id', $id)->first();
                    }
                    abort_unless((int) $mc->revision === $expected && (int) $mc->connection_revision === (int) $cn->revision, 409, 'stale revision');
                    $allowed = match ($mc->state) {
                        MC::STATE_NONE => ['request'],MC::STATE_PENDING => ['accept', 'decline', 'withdraw'],MC::STATE_ACTIVE => ['revoke'],default => []
                    };
                    abort_unless(in_array($action, $allowed, true), 409, 'invalid transition');
                    if (in_array($action, ['accept', 'decline'], true)) {
                        abort_if($actor === (int) $mc->requester_id, 409, 'recipient decision required');
                    }
                    if ($action === 'withdraw') {
                        abort_unless($actor === (int) $mc->requester_id, 409, 'requester required');
                    }
                    $from = $mc->state;
                    $c = $this->consentIdentity($cn, $mc);
                    $s = $this->consentEvidence($cn, $mc);
                    $t = $this->transitionEvidence($s, $c['consent_identity'], $c['connection_identity'], $c['participants'], $purpose, $from, $next, $actor, 'consent');
                    $t += ['consent_identity' => $c['consent_identity'], 'connection_identity' => $c['connection_identity'], 'purpose' => $purpose, 'actor' => 'user:'.$actor];
                    abort_unless(MC::evaluateTransition($c, $this->identity($cn), [$this->connectionEvidence($cn)], [$s], [$t])['classification'] === MC::TRANSITION_ADMISSIBLE, 409, 'consent transition rejected');
                    DB::table('messaging_consents')->where('id', $mc->id)->update(['state' => $next, 'revision' => $expected + 1, 'updated_at' => now()]);
                }
            }
            DB::table('live_consent_events')->insert(['connection_id' => $cn->id, 'kind' => $kind, 'actor_id' => $actor, 'from_state' => $from, 'to_state' => $next, 'revision' => $expected + 1, 'created_at' => now()]);

            return $this->current($actor, $peer);
        });
    }

    private function transitionEvidence(array $current,string $identity,string $subject,array $participants,string $purpose,string $from,string $to,int $actor,string $kind): array
    {
        $proof = $this->source($identity,$subject,$participants,$purpose,'TRANSITION',(int) $current['source_evidence']['source_revision']['value'] + 1,$kind.'-transition');
        $proof['required_bindings']['actor'] = 'user:'.$actor;
        $proof['source_evidence']['bindings'] = $proof['required_bindings'];

        return ['transition_identity' => bin2hex(random_bytes(16)), 'participants' => $participants, 'from_state' => $from, 'to_state' => $to,
            'expected_state_revision' => $current['source_evidence']['source_revision']] + $proof;
    }
}
