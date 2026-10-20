<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

final class FormalRelationshipService
{
    private const TERMINAL = ['ENDED', 'DECLINED', 'WITHDRAWN'];

    public function request(int $actor, int $peer, string $key): array
    {
        abort_if($actor === $peer, 422, 'distinct participants required');
        return DB::transaction(function () use ($actor, $peer, $key) {
            app(JourneyStore::class)->users([$actor, $peer]);
            return app(JourneyStore::class)->command($actor, $key, ['relationship_request', $peer], function () use ($actor, $peer) {
                $a = min($actor, $peer); $b = max($actor, $peer);
                abort_if(DB::table('formal_relationships')->where('user_a', $a)->where('user_b', $b)->whereNotIn('state', self::TERMINAL)->lockForUpdate()->exists(), 409, 'relationship lifecycle already open');
                $id = (string) Str::uuid();
                DB::table('formal_relationships')->insert(['id' => $id, 'user_a' => $a, 'user_b' => $b, 'requester_id' => $actor, 'state' => 'PENDING_MUTUAL', 'revision' => 1, 'confirmation_generation' => 1, 'confirmed_a' => false, 'confirmed_b' => false, 'test_only' => true, 'created_at' => now(), 'updated_at' => now()]);
                app(JourneyStore::class)->audit($actor, $id, 'REQUEST', ['state' => 'PENDING_MUTUAL']);
                return $this->project(DB::table('formal_relationships')->where('id', $id)->lockForUpdate()->first(), $actor);
            });
        });
    }

    private function locate(string $id, int $actor): object
    {
        $r = DB::table('formal_relationships')->where('id', $id)->first();
        abort_unless($r && in_array($actor, [(int) $r->user_a, (int) $r->user_b], true), 404, 'unavailable');
        return $r;
    }

    /** Called only after both user coordination locks; always reads current facts. */
    public function reconcile(object $r): object
    {
        $allowed = app(SocialPolicy::class)->pairAllowed((int) $r->user_a, (int) $r->user_b);
        $users = User::whereIn('id', [$r->user_a, $r->user_b])->lockForUpdate()->get();
        $allowed = $allowed && $users->count() === 2 && ! $users->contains(fn ($u) => $u->disabled || $u->account_status !== 'active' || $u->moderation_status !== 'normal');
        $next = null;
        if (! in_array($r->state, self::TERMINAL, true) && ! $allowed) {
            $next = 'ENDED';
        } elseif (in_array($r->state, ['ACTIVE','PENDING_MUTUAL'], true) && ($r->confirmed_a || $r->confirmed_b) && (! $r->credential_a || ! $r->credential_b || ! app(TrustedIdentityService::class)->valid((int) $r->user_a, $r->credential_a) || ! app(TrustedIdentityService::class)->valid((int) $r->user_b, $r->credential_b))) {
            $next = 'SUSPENDED_REVERIFY';
        }
        if ($next !== null) {
            $this->change($r, $next, false, false);
            app(JourneyStore::class)->audit(null, $r->id, 'AUTHORITY_INVALIDATED', ['state' => $next]);
        }
        return $r;
    }

    private function change(object $r, string $state, bool $a, bool $b): void
    {
        $r->state = $state; $r->confirmed_a = $a; $r->confirmed_b = $b; $r->revision++;
        if ($state !== 'ACTIVE') { DB::table('formal_relationship_slots')->where('relationship_id', $r->id)->delete(); }
        DB::table('formal_relationships')->where('id', $r->id)->update(['state' => $state, 'confirmed_a' => $a, 'confirmed_b' => $b, 'revision' => $r->revision, 'confirmation_generation' => $r->confirmation_generation, 'credential_a' => $r->credential_a ?? null, 'credential_b' => $r->credential_b ?? null, 'updated_at' => now()]);
    }

    public function action(int $actor, string $id, string $action, int $revision, string $key): array
    {
        $this->view($actor, $id); // Persist a lapse before evaluating a potentially rejected command.
        $hint = $this->locate($id, $actor); // Locator outside transaction is never authority.
        return DB::transaction(function () use ($actor, $id, $action, $revision, $key, $hint) {
            app(JourneyStore::class)->users([(int) $hint->user_a, (int) $hint->user_b], true);
            $r = DB::table('formal_relationships')->where('id', $id)->lockForUpdate()->first();
            abort_unless($r && $r->user_a === $hint->user_a && $r->user_b === $hint->user_b && in_array($actor, [(int) $r->user_a, (int) $r->user_b], true), 404);
            $this->reconcile($r);
            return app(JourneyStore::class)->command($actor, $key, ['relationship_action', $id, $action, $revision], function () use ($actor, $r, $action, $revision) {
                abort_unless((int) $r->revision === $revision, 409, 'stale relationship revision');
                abort_if(in_array($r->state, self::TERMINAL, true), 409, 'terminal relationship');
                $a = (bool) $r->confirmed_a; $b = (bool) $r->confirmed_b;
                $next = $r->state;
                if (in_array($action, ['end','pause'], true)) {
                    $next = $action === 'end' ? 'ENDED' : 'PAUSED'; $a = $b = false;
                } elseif (in_array($action, ['decline','withdraw'], true)) {
                    abort_unless($r->state === 'PENDING_MUTUAL' && ($action === 'withdraw' ? (int) $r->requester_id === $actor : (int) $r->requester_id !== $actor), 409, 'invalid relationship action');
                    $next = $action === 'withdraw' ? 'WITHDRAWN' : 'DECLINED'; $a = $b = false;
                } elseif ($action === 'resume') {
                    app(JourneyStore::class)->users([(int) $r->user_a, (int) $r->user_b]);
                    abort_unless(in_array($r->state, ['PAUSED','SUSPENDED_REVERIFY'], true), 409, 'not resumable');
                    $r->confirmation_generation++; $r->credential_a = $r->credential_b = null; $next = 'PENDING_MUTUAL'; $a = $b = false;
                } elseif ($action === 'confirm') {
                    app(JourneyStore::class)->users([(int) $r->user_a, (int) $r->user_b]);
                    abort_unless($r->state === 'PENDING_MUTUAL', 409, 'confirmation unavailable');
                    abort_unless(app(TrustedIdentityService::class)->valid((int) $r->user_a) && app(TrustedIdentityService::class)->valid((int) $r->user_b), 403, 'PROVIDER_NOT_CONFIGURED_OR_REVERIFY_REQUIRED');
                    abort_if((int)$r->user_a === $actor ? $a : $b, 409, 'already confirmed in this generation');
                    $r->credential_a = app(TrustedIdentityService::class)->credential((int) $r->user_a);
                    $r->credential_b = app(TrustedIdentityService::class)->credential((int) $r->user_b);
                    abort_unless($r->credential_a && $r->credential_b && app(TrustedIdentityService::class)->valid((int)$r->user_a, $r->credential_a) && app(TrustedIdentityService::class)->valid((int)$r->user_b, $r->credential_b), 403, 'bound credentials unavailable');
                    if ((int) $r->user_a === $actor) { $a = true; } else { $b = true; }
                    if ($a && $b) {
                        // Unique user slots plus ordered user locks serialize overlapping pairs.
                        abort_if(DB::table('formal_relationship_slots')->whereIn('user_id', [$r->user_a, $r->user_b])->lockForUpdate()->exists(), 409, 'active relationship already exists');
                        foreach ([$r->user_a, $r->user_b] as $u) { DB::table('formal_relationship_slots')->insert(['user_id' => $u, 'relationship_id' => $r->id]); }
                        $next = 'ACTIVE';
                    }
                } else { abort(422, 'unknown relationship action'); }
                $this->change($r, $next, $a, $b);
                app(JourneyStore::class)->audit($actor, $r->id, strtoupper($action), ['state' => $next, 'revision' => $r->revision, 'confirmation_generation' => $r->confirmation_generation]);
                return $this->project($r, $actor);
            });
        });
    }

    public function view(int $actor, string $id): array
    {
        $hint = $this->locate($id, $actor);
        return DB::transaction(function () use ($actor, $hint, $id) {
            app(JourneyStore::class)->users([(int) $hint->user_a, (int) $hint->user_b], true);
            $r = DB::table('formal_relationships')->where('id', $id)->lockForUpdate()->first();
            abort_unless($r && $r->user_a === $hint->user_a && $r->user_b === $hint->user_b, 404);
            return $this->project($this->reconcile($r), $actor);
        });
    }

    public function listing(int $actor): array
    {
        $ids = DB::table('formal_relationships')->where('user_a', $actor)->orWhere('user_b', $actor)->orderByDesc('created_at')->pluck('id');
        return ['identity' => app(TrustedIdentityService::class)->status($actor), 'relationships' => $ids->map(fn ($id) => $this->view($actor, $id))->all()];
    }

    private function project(object $r, int $actor): array
    {
        $isA = (int) $r->user_a === $actor;
        return ['id' => $r->id, 'peer_id' => (int) ($isA ? $r->user_b : $r->user_a), 'state' => $r->state, 'revision' => (int) $r->revision, 'confirmation_generation' => (int) $r->confirmation_generation, 'confirmed_me' => (bool) ($isA ? $r->confirmed_a : $r->confirmed_b), 'confirmed_peer' => (bool) ($isA ? $r->confirmed_b : $r->confirmed_a), 'test_only' => (bool) $r->test_only];
    }

    public function sharingAllowed(int $a, int $b): bool
    {
        $r = DB::table('formal_relationships')->where('user_a', min($a, $b))->where('user_b', max($a, $b))->where('state', 'ACTIVE')->lockForUpdate()->first();
        if (! $r) { return false; }
        $this->reconcile($r);
        return $r->state === 'ACTIVE' && $r->confirmed_a && $r->confirmed_b;
    }

    public function suspendCredential(int $actor, string $credential): void
    {
        foreach (DB::table('formal_relationships')->where(fn ($q) => $q->where('user_a', $actor)->orWhere('user_b', $actor))->where(fn($q) => $q->where('credential_a', $credential)->orWhere('credential_b', $credential))->whereIn('state', ['ACTIVE','PENDING_MUTUAL'])->lockForUpdate()->get() as $r) {
            $this->change($r, 'SUSPENDED_REVERIFY', false, false);
            app(JourneyStore::class)->audit($actor, $r->id, 'CREDENTIAL_REVOKED', ['state'=>'SUSPENDED_REVERIFY']);
        }
    }

    public function invalidatePair(int $a, int $b): void
    {
        foreach (DB::table('formal_relationships')->where('user_a', min($a, $b))->where('user_b', max($a, $b))->whereNotIn('state', self::TERMINAL)->lockForUpdate()->get() as $r) {
            $this->change($r, 'ENDED', false, false);
            app(JourneyStore::class)->audit(null, $r->id, 'BLOCK_OR_ACCOUNT_ENDED', ['state' => 'ENDED']);
        }
    }
}
