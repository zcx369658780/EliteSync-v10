<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\NotificationService;
use App\Services\SocialPolicy;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class SocialController extends Controller
{
    public function index(Request $r)
    {
        $id = (int) $r->user()->id;
        DB::table('social_requests')->where(fn ($q) => $q->where('sender_id', $id)->orWhere('recipient_id', $id))->where('state', 'PENDING')->where('expires_at', '<=', now())->update(['state' => 'EXPIRED', 'updated_at' => now()]);

        return response()->json(['requests_enabled' => (bool) DB::table('privacy_preferences')->where('user_id', $id)->value('requests_enabled'),
            'requests' => DB::table('social_requests')->where(fn ($q) => $q->where('sender_id', $id)->orWhere('recipient_id', $id))->orderByDesc('id')->get(['id', 'sender_id', 'recipient_id', 'purpose', 'state', 'expires_at'])->map(fn ($row) => (array) $row + ['peer' => ['public_id' => 'ES-'.($row->sender_id === $id ? $row->recipient_id : $row->sender_id), 'avatar' => null]]),
            'friends' => DB::table('friendships')->where(fn ($q) => $q->where('user_a', $id)->orWhere('user_b', $id))->where('state', 'ACTIVE')->get()->map(fn ($f) => ['id' => $f->id, 'peer_id' => $f->user_a === $id ? $f->user_b : $f->user_a, 'revision' => $f->revision, 'peer' => ['public_id' => 'ES-'.($f->user_a === $id ? $f->user_b : $f->user_a), 'avatar' => null]]),
            'invites' => DB::table('social_invitations')->where('recipient_id', $id)->whereNull('revoked_at')->where('expires_at', '>', now())->get(['id', 'purpose', 'sender_id', 'expires_at'])]);
    }

    public function preferences(Request $r)
    {
        $d = $r->validate(['requests_enabled' => 'required|boolean']);
        DB::transaction(function () use ($r, $d) {
            User::whereKey($r->user()->id)->lockForUpdate()->firstOrFail();
            $pref = DB::table('privacy_preferences')->where('user_id', $r->user()->id)->lockForUpdate()->first();
            $epoch = (int) ($pref->requests_revision ?? 0) + ((bool) ($pref->requests_enabled ?? false) !== (bool) $d['requests_enabled'] ? 1 : 0);
            DB::table('privacy_preferences')->updateOrInsert(['user_id' => $r->user()->id], ['requests_enabled' => $d['requests_enabled'], 'requests_revision' => $epoch, 'updated_at' => now(), 'created_at' => $pref->created_at ?? now()]);
        });

        return response()->json(['requests_enabled' => $d['requests_enabled']]);
    }

    public function invite(Request $r)
    {
        $d = $r->validate(['purpose' => 'required|in:friendship,message']);
        $token = bin2hex(random_bytes(32));
        $id = DB::table('social_invitations')->insertGetId(['recipient_id' => $r->user()->id, 'token_hash' => hash('sha256', $token), 'purpose' => $d['purpose'], 'expires_at' => now()->addHours(config('social.invitation_hours')), 'created_at' => now(), 'updated_at' => now()]);

        return response()->json(['id' => $id, 'token' => $token, 'purpose' => $d['purpose']], 201);
    }

    public function revokeInvite(Request $r, int $id)
    {
        abort_unless(DB::table('social_invitations')->where('id', $id)->where('recipient_id', $r->user()->id)->update(['revoked_at' => now()]), 404);

        return response()->json(['ok' => true]);
    }

    public function store(Request $r, SocialPolicy $policy)
    {
        $d = $r->validate(['purpose' => 'required|in:friendship,message', 'invitation_token' => 'nullable|string|max:128', 'peer_id' => 'nullable|integer', 'idempotency_key' => 'required|string|max:100',
            'body' => 'prohibited', 'text' => 'prohibited', 'attachment' => 'prohibited', 'actor_id' => 'prohibited', 'is_admin' => 'prohibited']);
        $actor = (int) $r->user()->id;
        // Resolve the candidate before opening the transaction. An invitation
        // read inside it would establish a stale REPEATABLE READ snapshot before
        // lockPair finishes waiting for a concurrent sender/recipient operation.
        // The invitation is re-read under a lock below before granting anything.
        $invite = isset($d['invitation_token']) ? DB::table('social_invitations')->where('token_hash', hash('sha256', $d['invitation_token']))->first() : null;
        $peer = (int) ($invite->recipient_id ?? $d['peer_id'] ?? 0);

        return DB::transaction(function () use ($d, $actor, $policy, $invite, $peer) {
            $policy->lockPair($actor, $peer);
            $hash = hash('sha256', json_encode([$peer, $d['purpose'], $d['invitation_token'] ?? null]));
            $old = DB::table('social_requests')->where('sender_id', $actor)->where('idempotency_key', $d['idempotency_key'])->first();
            if ($old) {
                abort_unless(hash_equals($old->input_hash, $hash), 409, 'idempotency conflict');

                return response()->json(['id' => $old->id, 'state' => $old->state]);
            }
            abort_if(User::whereIn('id', [$actor, $peer])->where('moderation_status', 'restricted')->exists(), 403, 'unavailable');
            abort_unless(DB::table('privacy_preferences')->where('user_id', $peer)->value('requests_enabled'), 404, 'unavailable');
            if ($invite) {
                $invite = DB::table('social_invitations')->where('id', $invite->id)->lockForUpdate()->first();
                abort_unless(! $invite->revoked_at && $invite->expires_at > now() && $invite->purpose === $d['purpose'] && (! $invite->sender_id || (int) $invite->sender_id === $actor), 404, 'unavailable');
            } else {
                abort_unless($policy->friendship($actor, $peer) || app(LiveConsentService::class)->match($actor, $peer), 404, 'unavailable');
            }
            $pair = min($actor, $peer).':'.max($actor, $peer);
            DB::table('social_requests')->where('pair_key', $pair)->where('state', 'PENDING')->where('expires_at', '<=', now())->update(['state' => 'EXPIRED', 'updated_at' => now()]);
            abort_if(DB::table('social_requests')->where('pair_key', $pair)->where('state', 'PENDING')->exists(), 409, 'pending request');
            $last = DB::table('social_requests')->where('sender_id', $actor)->where('recipient_id', $peer)->orderByDesc('id')->first();
            if ($last) {
                if ($last->state === 'DECLINED') {
                    abort_unless($invite && $invite->created_at > $last->updated_at, 409, 'recipient invitation required');
                }
                if (in_array($last->state, ['WITHDRAWN', 'EXPIRED'], true)) {
                    abort_if(Carbon::parse($last->updated_at)->addHours(config('social.retry_hours'))->isFuture(), 409, 'retry interval');
                }
            }
            $recipients = DB::table('social_requests')->where('sender_id', $actor)->where('created_at', '>', now()->subDay())->distinct()->pluck('recipient_id');
            $formal = DB::table('formal_relationships')->where('requester_id', $actor)->where('created_at', '>', now()->subDay())->lockForUpdate()->get(['user_a', 'user_b']);
            $recipients = $recipients->merge($formal->map(fn ($row) => (int) $row->user_a === $actor ? (int) $row->user_b : (int) $row->user_a))->unique();
            abort_if(! $recipients->contains($peer) && $recipients->count() >= config('social.daily_distinct_recipients'), 429, 'request quota');
            if ($invite) {
                DB::table('social_invitations')->where('id', $invite->id)->update(['sender_id' => $actor, 'updated_at' => now()]);
            }
            $id = DB::table('social_requests')->insertGetId(['sender_id' => $actor, 'recipient_id' => $peer, 'pair_key' => $pair, 'purpose' => $d['purpose'], 'state' => 'PENDING', 'invitation_id' => $invite->id ?? null, 'idempotency_key' => $d['idempotency_key'], 'input_hash' => $hash, 'expires_at' => now()->addDays(config('social.pending_days')), 'created_at' => now(), 'updated_at' => now()]);

            app(NotificationService::class)->createForUser($peer, 'social_request', '有一条新的联系请求', '请在关系请求中心查看', ['social_request_id' => $id]);

            return response()->json(['id' => $id, 'state' => 'PENDING'], 201);
        }, 3);
    }

    public function transition(Request $r, int $id, string $action, SocialPolicy $policy)
    {
        abort_unless(in_array($action, ['accept', 'decline', 'withdraw'], true), 404);
        $candidate = DB::table('social_requests')->find($id);
        abort_unless($candidate, 404);
        $actor = (int) $r->user()->id;
        abort_unless($actor === (int) ($action === 'withdraw' ? $candidate->sender_id : $candidate->recipient_id), 404);

        return DB::transaction(function () use ($candidate, $actor, $id, $action, $policy) {
            $policy->lockPair((int) $candidate->sender_id, (int) $candidate->recipient_id);
            $row = DB::table('social_requests')->where('id', $id)->lockForUpdate()->first();
            abort_unless($row && (int) $row->sender_id === (int) $candidate->sender_id && (int) $row->recipient_id === (int) $candidate->recipient_id
                && $actor === (int) ($action === 'withdraw' ? $row->sender_id : $row->recipient_id), 404);
            abort_unless($row->state === 'PENDING' && $row->expires_at > now(), 409, 'terminal request');
            if ($action === 'accept') {
                abort_unless(DB::table('privacy_preferences')->where('user_id', $row->recipient_id)->value('requests_enabled'), 404, 'unavailable');
                abort_if(User::whereIn('id', [$row->sender_id, $row->recipient_id])->where('moderation_status', 'restricted')->exists(), 403);
                if ($row->invitation_id) {
                    $inv = DB::table('social_invitations')->where('id', $row->invitation_id)->lockForUpdate()->first();
                    abort_unless($inv && ! $inv->revoked_at && $inv->expires_at > now(), 404, 'unavailable');
                } else {
                    abort_unless($policy->friendship($row->sender_id, $row->recipient_id) || app(LiveConsentService::class)->match($row->sender_id, $row->recipient_id), 404);
                }
                if ($row->purpose === 'friendship') {
                    $pair = ['user_a' => min($row->sender_id, $row->recipient_id), 'user_b' => max($row->sender_id, $row->recipient_id)];
                    $friend = DB::table('friendships')->where($pair)->first();
                    DB::table('friendships')->updateOrInsert($pair, ['state' => 'ACTIVE', 'revision' => ($friend->revision ?? 0) + 1, 'created_at' => $friend->created_at ?? now(), 'updated_at' => now()]);
                }
            }
            $state = match ($action) {
                'accept' => 'ACCEPTED','decline' => 'DECLINED','withdraw' => 'WITHDRAWN'
            };
            DB::table('social_requests')->where('id', $id)->update(['state' => $state, 'updated_at' => now()]);

            return response()->json(['id' => $id, 'state' => $state]);
        }, 3);
    }

    public function unfriend(Request $r, int $peer, SocialPolicy $policy)
    {
        return DB::transaction(function () use ($r, $peer, $policy) {
            $id = (int) $r->user()->id;
            $policy->lockPair($id, $peer);
            DB::table('friendships')->where('user_a', min($id, $peer))->where('user_b', max($id, $peer))->update(['state' => 'REMOVED', 'revision' => DB::raw('revision+1'), 'updated_at' => now()]);
            app(\App\Services\BuddyService::class)->revokePair($id, $peer, true);

            return response()->json(['ok' => true, 'connection_and_consent' => 'UNCHANGED']);
        });
    }
}
