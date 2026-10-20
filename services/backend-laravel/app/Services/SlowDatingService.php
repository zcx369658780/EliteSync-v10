<?php

namespace App\Services;

use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

final class SlowDatingService
{
    public function participation(int $id): array
    {
        $r = DB::table('matching_participations')->where('user_id', $id)->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())->first();
        return ['state' => $r->state ?? 'NOT_ENROLLED', 'revision' => (int) ($r->revision ?? 0), 'generation' => (int) ($r->generation ?? 0), 'intent' => $r->intent ?? '', 'opted_in_at' => $r->opted_in_at ?? null];
    }

    public function enrolled(int $id, ?int $generation = null): bool
    {
        return DB::table('matching_participations')->where('user_id', $id)->where('state', 'ACTIVE')->when($generation !== null, fn ($q) => $q->where('generation', $generation))->lockForUpdate()->exists();
    }

    public function participate(int $id, string $action, int $revision, string $intent): array
    {
        return DB::transaction(function () use ($id, $action, $revision, $intent) {
            // Same ordering as questionnaire/round writers. No ordinary SQL before locks.
            app(CurrentQuestionnaire::class)->lock();
            app(JourneyStore::class)->users([$id]);
            $p = DB::table('matching_participations')->where('user_id', $id)->lockForUpdate()->first();
            abort_unless((int) ($p->revision ?? 0) === $revision, 409, 'stale participation revision');
            $state = $p->state ?? 'NOT_ENROLLED'; $generation = (int) ($p->generation ?? 0);
            if ($action === 'opt_in') {
                abort_unless(app(ProfileReadinessService::class)->forUser(User::findOrFail($id))['matching_eligibility']['eligible'], 422, 'preparation incomplete');
                if ($state !== 'ACTIVE') {
                    foreach ($this->pendingFor($id) as $old) {
                        $this->expire($old);
                        abort_if(in_array($old->state, ['PENDING', 'ACCEPTED_BY_ONE'], true), 409, 'withdraw current proposal before new participation generation');
                    }
                    $generation++;
                }
                $state = 'ACTIVE';
            } elseif ($action === 'pause') { $state = 'PAUSED';
            } elseif ($action === 'exit') { $state = 'EXITED';
            } else { abort_unless($action === 'draft', 422); }
            DB::table('matching_participations')->updateOrInsert(['user_id' => $id], ['state' => $state, 'generation' => $generation, 'revision' => $revision + 1, 'intent' => $intent, 'opted_in_at' => $action === 'opt_in' ? now() : ($p->opted_in_at ?? null), 'created_at' => $p->created_at ?? now(), 'updated_at' => now()]);
            if ($action === 'exit') {
                foreach ($this->pendingFor($id) as $old) {
                    $this->finish($old, 'WITHDRAWN');
                    app(JourneyStore::class)->audit($id, $old->id, 'PARTICIPATION_EXIT_WITHDRAWAL', ['state' => 'WITHDRAWN', 'revision' => $old->revision]);
                }
            }
            app(JourneyStore::class)->audit($id, 'participation:'.$id, $action, ['state' => $state, 'generation' => $generation, 'revision' => $revision + 1]);
            return $this->participation($id);
        });
    }

    /** Caller holds questionnaire lock and all sorted participant User locks. */
    public function reveal(DatingMatch $m): void
    {
        if (DB::table('match_proposals')->where('dating_match_id', $m->id)->lockForUpdate()->exists()) { return; }
        $a = (int) $m->user_a; $b = (int) $m->user_b;
        abort_unless(app(SocialPolicy::class)->pairAllowed($a, $b) && $this->enrolled($a) && $this->enrolled($b), 409, 'participation changed before reveal');
        foreach ([$a, $b] as $u) {
            $slot = DB::table('match_proposal_slots')->where('user_id', $u)->lockForUpdate()->first();
            if ($slot) {
                $old = DB::table('match_proposals')->where('id', $slot->proposal_id)->lockForUpdate()->first();
                $this->expire($old);
                $this->reconcilePending($old);
                abort_if(DB::table('match_proposal_slots')->where('user_id', $u)->exists(), 409, 'unresolved proposal exists');
            }
        }
        $pa = $this->participation($a); $pb = $this->participation($b);
        foreach ([$a => $pa, $b => $pb] as $userId => $participation) {
            $frozen = DB::table('matching_run_candidates')->where('matching_run_id', $m->matching_run_id)->where('user_id', $userId)->lockForUpdate()->first();
            abort_unless($frozen && (int)$frozen->participation_generation === $participation['generation'], 409, 'participation generation changed before reveal');
        }
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert(['id' => $id, 'dating_match_id' => $m->id, 'round_id' => $m->round_id, 'run_id' => $m->matching_run_id, 'user_a' => $a, 'user_b' => $b, 'generation_a' => $pa['generation'], 'generation_b' => $pb['generation'], 'state' => 'PENDING', 'decision_a' => 'PENDING', 'decision_b' => 'PENDING', 'revision' => 1, 'revealed_at' => now()->utc(), 'expires_at' => now()->utc()->addHours((int) config('journey.proposal_hours', 168)), 'created_at' => now(), 'updated_at' => now()]);
        foreach ([$a, $b] as $u) { DB::table('match_proposal_slots')->insert(['user_id' => $u, 'proposal_id' => $id]); }
        app(JourneyStore::class)->audit(null, $id, 'REVEALED', ['round_id' => $m->round_id, 'run_id' => $m->matching_run_id, 'expiry_source' => 'journey.proposal_hours:168']);
    }

    private function finish(object $p, string $state): void
    {
        $p->state = $state; $p->revision++;
        DB::table('match_proposals')->where('id', $p->id)->update(['state' => $state, 'revision' => $p->revision, 'decision_a' => $p->decision_a, 'decision_b' => $p->decision_b, 'updated_at' => now()]);
        if (! in_array($state, ['PENDING','ACCEPTED_BY_ONE'], true)) { DB::table('match_proposal_slots')->where('proposal_id', $p->id)->delete(); }
    }

    private function expire(?object $p): void
    {
        if ($p && in_array($p->state, ['PENDING','ACCEPTED_BY_ONE'], true) && Carbon::parse($p->expires_at, 'UTC')->lte(now()->utc())) {
            $this->finish($p, 'EXPIRED');
            app(JourneyStore::class)->audit(null, $p->id, 'EXPIRED', []);
        }
    }

    private function pendingFor(int $actor): \Illuminate\Support\Collection
    {
        return DB::table('match_proposals')->where(fn ($q) => $q->where('user_a', $actor)->orWhere('user_b', $actor))
            ->whereIn('state', ['PENDING', 'ACCEPTED_BY_ONE'])->orderBy('id')->lockForUpdate()->get();
    }

    /** Actor User lock serializes EXIT with every pair reader; no peer lock is acquired late. */
    private function reconcilePending(?object $p): void
    {
        if (! $p || ! in_array($p->state, ['PENDING', 'ACCEPTED_BY_ONE'], true)) { return; }
        $a = $this->participation((int) $p->user_a); $b = $this->participation((int) $p->user_b);
        if ($a['state'] === 'EXITED' || $b['state'] === 'EXITED'
            || $a['generation'] !== (int) $p->generation_a || $b['generation'] !== (int) $p->generation_b) {
            $this->finish($p, 'WITHDRAWN');
            app(JourneyStore::class)->audit(null, $p->id, 'PARTICIPATION_AUTHORITY_INVALIDATED', ['state' => 'WITHDRAWN', 'reason' => 'exit_or_generation_changed', 'revision' => $p->revision]);
        }
    }

    public function proposalContextActive(object $p): bool
    {
        return $this->enrolled((int) $p->user_a, (int) $p->generation_a)
            && $this->enrolled((int) $p->user_b, (int) $p->generation_b);
    }

    public function proposal(int $actor, ?string $id = null): ?array
    {
        // Immutable locator only, outside transaction. Revalidated after ordered user locks.
        $hint = DB::table('match_proposals')->where(fn ($q) => $q->where('user_a', $actor)->orWhere('user_b', $actor))->when($id !== null, fn ($q) => $q->where('id', $id))->orderByDesc('created_at')->first();
        if (! $hint) { return null; }
        return DB::transaction(function () use ($actor, $hint) {
            app(JourneyStore::class)->users([(int) $hint->user_a, (int) $hint->user_b], true);
            $p = DB::table('match_proposals')->where('id', $hint->id)->lockForUpdate()->first();
            abort_unless($p && $p->user_a === $hint->user_a && $p->user_b === $hint->user_b, 404);
            $this->expire($p);
            return $this->projectLocked($p, $actor);
        });
    }

    public function projectLocked(object $p, int $actor): array
    {
        $this->expire($p);
        $this->reconcilePending($p);
        $isA = (int) $p->user_a === $actor; $peer = (int) ($isA ? $p->user_b : $p->user_a);
        $out = ['id' => $p->id, 'match_id' => (int) $p->dating_match_id, 'round_id' => (int) $p->round_id, 'run_id' => (int) $p->run_id, 'revision' => (int) $p->revision, 'state' => $p->state, 'decision_me' => $isA ? $p->decision_a : $p->decision_b, 'decision_peer' => $isA ? $p->decision_b : $p->decision_a, 'peer_id' => $peer, 'revealed_at' => $p->revealed_at, 'expires_at' => $p->expires_at, 'showcase' => null, 'explanation' => null, 'connection_eligible' => false];
        $pending = in_array($p->state, ['PENDING', 'ACCEPTED_BY_ONE'], true);
        $current = $this->proposalContextActive($p);
        $out += ['decision_available' => $pending && $current, 'withdraw_available' => $pending, 'availability_reason' => $current ? null : 'participation_paused_or_changed'];
        $allowed = app(SocialPolicy::class)->pairAllowed($actor, $peer)
            && User::whereIn('id', [$actor, $peer])->where('disabled', false)->where('account_status', 'active')->where('moderation_status', 'normal')->count() === 2;
        if (! $allowed || ! $current || Carbon::parse($p->expires_at, 'UTC')->lte(now()->utc()) || ! in_array($p->state, ['PENDING','ACCEPTED_BY_ONE','MUTUALLY_ACCEPTED'], true)) { return $out; }
        $publication = DB::table('user_profile_showcase_publications')->where('user_id', $peer)->where('public_display_eligible', true)->lockForUpdate()->first();
        // No raw payload, questions, exact birth inputs, internal scores or Safety facts.
        $payload = $publication ? json_decode($publication->published_payload, true) : [];
        $out['showcase'] = ['public_id' => 'ES-'.$peer, 'summary' => $payload['self_intro'] ?? null, 'interest_tags' => $payload['interest_tags'] ?? [], 'lifestyle_tags' => $payload['lifestyle_tags'] ?? []];
        $out['explanation'] = ['categories' => ['questionnaire_preferences'], 'source' => 'existing_matching_run', 'uncertainty' => '候选来自有限自填输入，不保证相处效果', 'non_goals' => ['不构成实人认证或恋爱事实','不授予连接、消息或通话同意']];
        $out['connection_eligible'] = $p->state === 'MUTUALLY_ACCEPTED';
        return $out;
    }

    public function decision(int $actor, string $id, string $action, int $revision, string $key): array
    {
        $hint = DB::table('match_proposals')->where('id', $id)->first();
        abort_unless($hint && in_array($actor, [(int) $hint->user_a, (int) $hint->user_b], true), 404, 'unavailable');
        // Persist expiry independently, so a rejected stale mutation cannot roll it back.
        $this->proposal($actor, $id);
        return DB::transaction(function () use ($actor, $id, $action, $revision, $key, $hint) {
            app(JourneyStore::class)->users([(int) $hint->user_a, (int) $hint->user_b]);
            $p = DB::table('match_proposals')->where('id', $id)->lockForUpdate()->first();
            abort_unless($p && $p->user_a === $hint->user_a && $p->user_b === $hint->user_b, 404);
            return app(JourneyStore::class)->command($actor, $key, ['proposal_decision', $id, $action, $revision], function () use ($actor, $p, $action, $revision) {
                abort_unless((int) $p->revision === $revision, 409, 'stale proposal revision');
                abort_unless(in_array($p->state, ['PENDING','ACCEPTED_BY_ONE'], true) && Carbon::parse($p->expires_at, 'UTC')->gt(now()->utc()), 409, 'proposal terminal or expired');
                $isA = (int) $p->user_a === $actor;
                $generation = (int) ($isA ? $p->generation_a : $p->generation_b);
                if ($action !== 'withdraw') { abort_unless($this->enrolled((int)$p->user_a, (int)$p->generation_a) && $this->enrolled((int)$p->user_b, (int)$p->generation_b), 409, 'participation generation unavailable'); }
                if ($action === 'accept') {
                    $field = $isA ? 'decision_a' : 'decision_b';
                    abort_unless($p->$field === 'PENDING', 409, 'already decided');
                    $p->$field = 'ACCEPTED';
                    $next = $p->decision_a === 'ACCEPTED' && $p->decision_b === 'ACCEPTED' ? 'MUTUALLY_ACCEPTED' : 'ACCEPTED_BY_ONE';
                } elseif (in_array($action, ['decline','withdraw'], true)) { $next = $action === 'decline' ? 'DECLINED' : 'WITHDRAWN';
                } else { abort(422, 'unknown proposal action'); }
                $this->finish($p, $next);
                app(JourneyStore::class)->audit($actor, $p->id, strtoupper($action), ['state' => $next, 'revision' => $p->revision]);
                return $this->projectLocked($p, $actor);
            });
        });
    }

    public function journey(int $actor): array
    {
        $readiness = app(ProfileReadinessService::class)->forUser(User::findOrFail($actor));
        return ['readiness' => $readiness + $readiness['matching_eligibility'], 'participation' => $this->participation($actor), 'round' => app(MatchRoundProjectionService::class)->currentForUser($actor)['data'], 'proposal' => $this->proposal($actor), 'identity' => app(TrustedIdentityService::class)->status($actor), 'cadence_source' => 'dating_round_channels / dating_rounds.cadence_key', 'consent' => 'Match、CN、MC、正式Relationship、逐字段分享分别同意'];
    }
}
