<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;

/** Request authority only. It does not establish love, verification, CN or MC. */
final class RelationshipContactPolicy
{
    public function lockUsers(int $actor, int $peer): void
    {
        abort_if($actor === $peer, 404, 'unavailable');
        $users = User::whereIn('id', [$actor, $peer])->orderBy('id')->lockForUpdate()->get();
        abort_unless($users->count() === 2 && ! $users->contains(fn ($u) => $u->disabled || $u->account_status !== 'active' || $u->moderation_status !== 'normal')
            && app(SocialPolicy::class)->pairAllowed($actor, $peer), 404, 'unavailable');
        app(JourneyStore::class)->users([$actor, $peer], true); // Current session after waiting.
    }

    public function capture(int $actor, int $peer): array
    {
        $pref = DB::table('privacy_preferences')->where('user_id', $peer)->lockForUpdate()->first();
        abort_unless($pref?->requests_enabled, 404, 'unavailable');
        $pair = ['user_a' => min($actor, $peer), 'user_b' => max($actor, $peer)];
        $source = DB::table('friendships')->where($pair)->where('state', 'ACTIVE')->lockForUpdate()->first();
        $kind = 'friendship';
        if (! $source) {
            $kind = 'connection';
            $source = app(LiveConsentService::class)->connection($actor, $peer, true);
            abort_unless($source?->state === 'CN_ACTIVE', 404, 'unavailable');
        }
        abort_unless($source, 404, 'unavailable');
        return ['request_source_kind' => $kind, 'request_source_id' => $source->id,
            'request_source_revision' => $source->revision, 'request_permission_revision' => $pref->requests_revision];
    }

    public function valid(object $r): bool
    {
        if (! $r->request_source_kind || $r->request_permission_revision === null) { return false; }
        $recipient = (int) $r->user_a === (int) $r->requester_id ? (int) $r->user_b : (int) $r->user_a;
        $pref = DB::table('privacy_preferences')->where('user_id', $recipient)->lockForUpdate()->first();
        if (! $pref?->requests_enabled || (int) $pref->requests_revision !== (int) $r->request_permission_revision) { return false; }
        $source = match ($r->request_source_kind) {
            'friendship' => app(SocialPolicy::class)->friendship((int) $r->user_a, (int) $r->user_b),
            'connection' => app(LiveConsentService::class)->connection((int) $r->user_a, (int) $r->user_b, true),
            default => null,
        };
        $state = $r->request_source_kind === 'friendship' ? 'ACTIVE' : 'CN_ACTIVE';

        return $source && $source->state === $state
            && (string) $source->id === (string) $r->request_source_id
            && (int) $source->revision === (int) $r->request_source_revision;
    }

    public function throttle(int $actor, int $peer): void
    {
        $last = DB::table('formal_relationships')->where('user_a', min($actor, $peer))->where('user_b', max($actor, $peer))
            ->orderByDesc('created_at')->orderByDesc('updated_at')->lockForUpdate()->first();
        if ($last && $last->state === 'DECLINED' && (int) $last->requester_id === $actor) { abort(404, 'unavailable'); }
        if ($last && in_array($last->state, ['ENDED', 'DECLINED', 'WITHDRAWN'], true)) {
            abort_if(\Illuminate\Support\Carbon::parse($last->updated_at)->addHours((int) config('social.retry_hours', 24))->isFuture(), 404, 'unavailable');
        }
        $recipients = DB::table('social_requests')->where('sender_id', $actor)->where('created_at', '>', now()->subDay())->lockForUpdate()->get(['recipient_id'])->pluck('recipient_id');
        $formal = DB::table('formal_relationships')->where('requester_id', $actor)->where('created_at', '>', now()->subDay())->lockForUpdate()->get(['user_a', 'user_b']);
        $recipients = $recipients->merge($formal->map(fn ($r) => (int) $r->user_a === $actor ? (int) $r->user_b : (int) $r->user_a))->unique();
        abort_if(! $recipients->contains($peer) && $recipients->count() >= (int) config('social.daily_distinct_recipients', 5), 429, 'request quota');
    }
}
