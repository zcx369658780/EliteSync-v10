<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserBlock;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/** Shared current-fact policy. Client relationship/verification flags are never authority. */
final class SocialPolicy
{
    public function pairAllowed(int $a, int $b): bool
    {
        if ($a === $b) {
            return User::whereKey($a)->where('disabled', false)->exists();
        }

        return User::whereIn('id', [$a, $b])->where('disabled', false)->count() === 2
            && ! UserBlock::where(fn ($q) => $q->where('blocker_id', $a)->where('blocked_user_id', $b))
                ->orWhere(fn ($q) => $q->where('blocker_id', $b)->where('blocked_user_id', $a))->exists();
    }

    public function friendship(int $a, int $b): ?object
    {
        if (! Schema::hasTable('friendships')) {
            return null;
        }

        return DB::table('friendships')->where('user_a', min($a, $b))->where('user_b', max($a, $b))->where('state', 'ACTIVE')->first();
    }

    public function lockPair(int $a, int $b): void
    {
        User::whereIn('id', [$a, $b])->orderBy('id')->lockForUpdate()->get();
        abort_unless($a !== $b && $this->pairAllowed($a, $b), 404, 'unavailable');
    }

    public function profile(int $viewer, int $owner): array
    {
        abort_unless($this->pairAllowed($viewer, $owner), 404, 'unavailable');
        $u = User::findOrFail($owner);
        if ($viewer !== $owner) {
            $context = $this->friendship($viewer, $owner) || app(LiveConsentService::class)->match($viewer, $owner)
                || DB::table('social_requests')->where(function ($q) use ($viewer, $owner) {
                    $q->where(fn ($p) => $p->where('sender_id', $viewer)->where('recipient_id', $owner))->orWhere(fn ($p) => $p->where('sender_id', $owner)->where('recipient_id', $viewer));
                })->whereIn('state', ['PENDING', 'ACCEPTED'])->where('expires_at', '>', now())->exists();
            abort_unless($context, 404, 'unavailable');
        }
        $result = ['public_id' => 'ES-'.$u->id, 'avatar' => null];
        if ($viewer === $owner) {
            $result += ['birthday' => optional($u->birthday)->format('Y-m-d'), 'interests' => $u->public_personality, 'resume' => null, 'zodiac' => $u->public_zodiac_sign];
        }

        // No formal-relationship writer exists in this version: intention alone cannot disclose deep fields.
        return $result;
    }

    public function revokePair(int $a, int $b): void
    {
        if (! Schema::hasTable('friendships')) {
            return;
        }
        DB::table('friendships')->where('user_a', min($a, $b))->where('user_b', max($a, $b))->update(['state' => 'REVOKED', 'revision' => DB::raw('revision+1'), 'updated_at' => now()]);
        DB::table('social_requests')->where('pair_key', min($a, $b).':'.max($a, $b))->whereIn('state', ['PENDING', 'ACCEPTED'])->update(['state' => 'REVOKED', 'updated_at' => now()]);
        DB::table('social_invitations')->where(fn ($q) => $q->where('recipient_id', $a)->where('sender_id', $b))
            ->orWhere(fn ($q) => $q->where('recipient_id', $b)->where('sender_id', $a))->update(['revoked_at' => now()]);
        $ids = DB::table('product_connections')->where('user_a', min($a, $b))->where('user_b', max($a, $b))->pluck('id');
        DB::table('product_connections')->whereIn('id', $ids)->whereNotIn('state', ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED'])->update(['state' => 'CN_CLOSED', 'revision' => DB::raw('revision+1'), 'updated_at' => now()]);
        DB::table('messaging_consents')->whereIn('connection_id', $ids)->whereIn('state', ['MC_ACTIVE', 'MC_PENDING'])->update(['state' => 'MC_REVOKED', 'revision' => DB::raw('revision+1'), 'updated_at' => now()]);
    }

    public function revokeUser(int $id): void
    {
        if (! Schema::hasTable('friendships')) {
            return;
        }
        $peers = DB::table('product_connections')->where('user_a', $id)->orWhere('user_b', $id)->get()
            ->merge(DB::table('friendships')->where('user_a', $id)->orWhere('user_b', $id)->get());
        foreach ($peers as $p) {
            $this->revokePair($id, (int) ($p->user_a == $id ? $p->user_b : $p->user_a));
        }
        DB::table('social_requests')->where(fn ($q) => $q->where('sender_id', $id)->orWhere('recipient_id', $id))->whereIn('state', ['PENDING', 'ACCEPTED'])->update(['state' => 'REVOKED', 'updated_at' => now()]);
        DB::table('social_invitations')->where(fn ($q) => $q->where('recipient_id', $id)->orWhere('sender_id', $id))->update(['revoked_at' => now()]);
    }
}
