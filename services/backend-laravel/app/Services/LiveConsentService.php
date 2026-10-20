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

        return in_array($db->getDriverName(), ['mysql', 'mariadb'], true) && in_array([$db->getDatabaseName(), (int) $db->getConfig('port')], [['elitesync_v1007_dev', 43317], ['elitesync_v1008_dev', 43318], ['elitesync_v1009_dev', 43319], ['elitesync_v10_1_1_dev', 43322], ['elitesync_v10_1_2_dev', 43323]], true)
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
        if ($users->count() !== 2 || $users->contains(fn ($u) => $u->disabled || ($u->is_synthetic && ! app(TrustedIdentityService::class)->registered((int) $u->id)))) {
            return null;
        }
        $blocks = UserBlock::where(fn ($q) => $q->where('blocker_id', $actor)->where('blocked_user_id', $peer))
            ->orWhere(fn ($q) => $q->where('blocker_id', $peer)->where('blocked_user_id', $actor));
        if ($lock) {
            $blocks->lockForUpdate();
        }if ($blocks->get()->isNotEmpty()) {
            return null;
        }
        $q = DatingMatch::where('drop_released', true)->whereExists(fn ($p) => $p->selectRaw('1')->from('match_proposals')->whereColumn('match_proposals.dating_match_id', 'dating_matches.id')->where('match_proposals.state', 'MUTUALLY_ACCEPTED'))->where(fn ($q) => $q
            ->where(fn ($q) => $q->where('user_a', $actor)->where('user_b', $peer))
            ->orWhere(fn ($q) => $q->where('user_a', $peer)->where('user_b', $actor)))->orderByDesc('id');
        if ($lock) {
            $q->lockForUpdate();
        }

        return $q->first();
    }

    public function connection(int $actor, int $peer, bool $lock = false): ?object
    {
        if (! $this->enabled() || ! app(SocialPolicy::class)->pairAllowed($actor, $peer)) {
            return null;
        }
        $q = DB::table('product_connections')->where('user_a', min($actor, $peer))->where('user_b', max($actor, $peer));
        if ($lock) {
            $q->lockForUpdate();
        }

        return $q->orderByDesc('id')->first();
    }

    private function acceptedMessage(int $a, int $b): ?object
    {
        return DB::table('social_requests')->where('pair_key', min($a, $b).':'.max($a, $b))->where('purpose', 'message')->where('state', 'ACCEPTED')->orderByDesc('id')->first();
    }

    private function hasContext(int $actor, int $peer, bool $lock = false): bool
    {
        return $this->enabled() && $actor !== $peer && app(SocialPolicy::class)->pairAllowed($actor, $peer)
            && ($this->match($actor, $peer, $lock) || app(SocialPolicy::class)->friendship($actor, $peer) || $this->acceptedMessage($actor, $peer) || $this->connection($actor, $peer, $lock));
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
        $context = $this->hasContext($actor, $peer, true);
        if (! $context) {
            return $denied;
        }
        $cn = $this->connection($actor, $peer, true);
        if (! $cn) {
            return $denied;
        }
        $all = DB::table('messaging_consents')->where('connection_id', $cn->id)->orderBy('id')->lockForUpdate()->get();
        $rows = $all->where('generation', $all->max('generation'))->keyBy('purpose');
        $read = $rows->get(MC::PURPOSE_LIVE_READ);
        $send = $rows->get(MC::PURPOSE_LIVE_SEND);
        if (! $read || ! $send) {
            return $denied;
        }

        $result = MC::evaluateLiveGates($this->identity($cn), [$this->connectionEvidence($cn)],
            $this->consentIdentity($cn, $read), [$this->consentEvidence($cn, $read)],
            $this->consentIdentity($cn, $send), [$this->consentEvidence($cn, $send)]);
        // Locking reads stay current even when an outer transaction already has a snapshot.
        if (User::whereIn('id', [$actor, $peer])->orderBy('id')->lockForUpdate()->get(['moderation_status'])->contains('moderation_status', 'restricted')) {
            $result['live_send_allowed'] = false;
        }

        return $result;
    }

    public function current(int $actor, int $peer): array
    {
        $context = $this->hasContext($actor, $peer);
        abort_unless($context, 404, 'connection unavailable');
        $cn = $this->connection($actor, $peer);
        $mc = $cn ? DB::table('messaging_consents')->where('connection_id', $cn->id)->where('purpose', MC::PURPOSE_LIVE_READ)->orderByDesc('generation')->first() : null;

        return ['connection' => ['id' => $cn->id ?? null, 'generation' => (int) ($cn->lifecycle_generation ?? 1), 'state' => $cn->state ?? CN::STATE_NONE, 'revision' => (int) ($cn->revision ?? 0), 'requester_id' => $cn->requester_id ?? null],
            'consent' => ['id' => $mc->id ?? null, 'generation' => (int) ($mc->generation ?? 1), 'state' => $mc->state ?? MC::STATE_NONE, 'revision' => (int) ($mc->revision ?? 0), 'requester_id' => $mc->requester_id ?? null],
            'peer_id' => $peer, 'gates' => $this->gates($actor, $peer)];
    }

    public function transition(int $actor, int $peer, string $kind, string $action, int $expected, ?int $expectedConnectionId = null, ?int $expectedConsentId = null): array
    {
        return DB::transaction(function () use ($actor, $peer, $kind, $action, $expected, $expectedConnectionId, $expectedConsentId) {
            if ($this->enabled()) {
                app(SocialPolicy::class)->lockPair($actor, $peer);
            }
            abort_unless($this->hasContext($actor, $peer, true), 404, 'connection unavailable');
            $match = $this->match($actor, $peer, true);
            $friend = app(SocialPolicy::class)->friendship($actor, $peer);
            $messageRequest = $this->acceptedMessage($actor, $peer);
            abort_if(in_array($action, ['request', 'accept'], true) && User::whereIn('id', [$actor, $peer])->orderBy('id')->lockForUpdate()->get(['moderation_status'])->contains('moderation_status', 'restricted'), 403, 'restricted interaction');
            $cn = $this->connection($actor, $peer, true);
            $generation = (int) ($cn->lifecycle_generation ?? 1);
            if ($cn && ($generation > 1 || $expectedConnectionId !== null)) {
                abort_unless($expectedConnectionId === (int) $cn->id, 409, 'stale lifecycle');
            }
            if ($cn && $kind === 'connection' && $action === 'request' && in_array($cn->state, [CN::STATE_CLOSED, CN::STATE_DECLINED, CN::STATE_WITHDRAWN, CN::STATE_EXPIRED], true)) {
                abort_unless($expectedConnectionId === (int) $cn->id && $expected === (int) $cn->revision, 409, 'new lifecycle confirmation required');
                abort_unless($match || $friend || $messageRequest, 404, 'new context required');
                $generation++;
                $cn = null;
                $expected = 0;
            }
            if (! $cn) {
                abort_unless($kind === 'connection' && $action === 'request' && $expected === 0, 409, 'invalid transition');
                $id = DB::table('product_connections')->insertGetId(['lifecycle_generation' => $generation, 'match_id' => $match?->id, 'friendship_id' => $match ? null : $friend?->id, 'social_request_id' => ! $match && ! $friend ? $messageRequest?->id : null, 'user_a' => min($actor, $peer), 'user_b' => max($actor, $peer),
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
                $latest = DB::table('messaging_consents')->where('connection_id', $cn->id)->where('purpose', MC::PURPOSE_LIVE_READ)->orderByDesc('generation')->lockForUpdate()->first();
                $generation = (int) ($latest->generation ?? 1);
                if ($latest && ($generation > 1 || $expectedConsentId !== null)) {
                    abort_unless($expectedConsentId === (int) $latest->id, 409, 'stale consent lifecycle');
                }
                if ($action === 'request' && $latest && in_array($latest->state, [MC::STATE_REVOKED, MC::STATE_DECLINED, MC::STATE_WITHDRAWN], true)) {
                    abort_unless($expectedConsentId === (int) $latest->id, 409, 'terminal consent identity required');
                    abort_unless((int) $latest->revision === $expected, 409, 'stale revision');
                    $generation++;
                    $expected = 0;
                }
                foreach ([MC::PURPOSE_LIVE_READ, MC::PURPOSE_LIVE_SEND] as $purpose) {
                    $mc = DB::table('messaging_consents')->where('connection_id', $cn->id)->where('purpose', $purpose)->where('generation', $generation)->lockForUpdate()->first();
                    if (! $mc) {
                        abort_unless($action === 'request' && $expected === 0, 409, 'request required');
                        $id = DB::table('messaging_consents')->insertGetId(['connection_id' => $cn->id, 'purpose' => $purpose, 'generation' => $generation, 'requester_id' => $actor, 'state' => MC::STATE_NONE,
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

    private function transitionEvidence(array $current, string $identity, string $subject, array $participants, string $purpose, string $from, string $to, int $actor, string $kind): array
    {
        $proof = $this->source($identity, $subject, $participants, $purpose, 'TRANSITION', (int) $current['source_evidence']['source_revision']['value'] + 1, $kind.'-transition');
        $proof['required_bindings']['actor'] = 'user:'.$actor;
        $proof['source_evidence']['bindings'] = $proof['required_bindings'];

        return ['transition_identity' => bin2hex(random_bytes(16)), 'participants' => $participants, 'from_state' => $from, 'to_state' => $to,
            'expected_state_revision' => $current['source_evidence']['source_revision']] + $proof;
    }
}
