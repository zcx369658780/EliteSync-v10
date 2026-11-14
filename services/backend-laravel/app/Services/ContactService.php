<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;

final class ContactService
{
    private function peers(string $table, int $actor)
    {
        return DB::table($table)->selectRaw('CASE WHEN user_a = ? THEN user_b ELSE user_a END AS peer_id', [$actor])
            ->where(fn ($q) => $q->where('user_a', $actor)->orWhere('user_b', $actor));
    }

    public function listing(int $actor, string $purpose, int $limit = 20, int $cursor = 0, string $query = ''): array
    {
        DB::transaction(fn () => app(JourneyStore::class)->users([$actor]));
        $candidates = $this->peers('friendships', $actor)->where('state', 'ACTIVE')
            ->union($this->peers('product_connections', $actor)->whereIn('state', ['CN_ACTIVE', 'CN_PENDING']))
            ->union($this->peers('dating_matches', $actor)->where('drop_released', true))
            ->union(DB::table('social_requests')->selectRaw('CASE WHEN sender_id = ? THEN recipient_id ELSE sender_id END AS peer_id', [$actor])
                ->where(fn ($q) => $q->where('sender_id', $actor)->orWhere('recipient_id', $actor))
                ->where(fn ($q) => $q->where('state', 'ACCEPTED')->orWhere(fn ($p) => $p->where('state', 'PENDING')->where('expires_at', '>', now()))));
        $ids = User::whereIn('id', $candidates)->where('id', '>', $cursor)->where('id', '<>', $actor)
            ->orderBy('id')->limit(201)->pluck('id');
        $items = [];
        $scanned = 0;
        $last = $cursor;
        foreach ($ids->take(200) as $peer) {
            $last = (int) $peer;
            $scanned++;
            $item = DB::transaction(function () use ($actor, $peer, $purpose) {
                app(JourneyStore::class)->users([$actor, (int) $peer], true);
                if (User::whereIn('id', [$actor, $peer])->where('disabled', false)->where('account_status', 'active')
                    ->where('moderation_status', 'normal')->lockForUpdate()->count() !== 2
                    || ! app(SocialPolicy::class)->pairAllowed($actor, (int) $peer)) return null;
                $friend = app(SocialPolicy::class)->friendship($actor, (int) $peer);
                $actions = [];
                if ($purpose === 'buddy_invite') {
                    if ($friend && app(BuddyService::class)->pref($actor)->enabled && app(BuddyService::class)->pref((int) $peer)->enabled) {
                        $actions[] = 'buddy_invite';
                    }
                } elseif ($purpose === 'friend_request') {
                    $context = $friend || app(LiveConsentService::class)->match($actor, (int) $peer, true);
                    if ($context && DB::table('privacy_preferences')->where('user_id', $peer)->lockForUpdate()->value('requests_enabled')) {
                        $actions[] = $friend ? 'message_request' : 'friend_request';
                    }
                } else {
                    $gates = app(LiveConsentService::class)->gates($actor, (int) $peer);
                    if ($purpose === 'chat' && $gates['live_read_allowed']) $actions[] = 'chat';
                    if ($purpose === 'connection') {
                        $accepted = DB::table('social_requests')->where('pair_key', min($actor, $peer).':'.max($actor, $peer))
                            ->where('purpose', 'message')->where('state', 'ACCEPTED')->lockForUpdate()->exists();
                        if ($friend || $accepted || app(LiveConsentService::class)->match($actor, (int) $peer, true)
                            || app(LiveConsentService::class)->connection($actor, (int) $peer, true)) $actions[] = 'connection';
                    }
                }
                return $actions ? ['peer_id' => (int) $peer, 'label' => 'ES-'.$peer, 'avatar' => null, 'allowed_actions' => $actions] : null;
            }, 3);
            if ($item && ($query === '' || mb_stripos($item['label'], $query) !== false)) $items[] = $item;
            if (count($items) === $limit) break;
        }
        $more = $ids->count() > $scanned;
        return ['purpose' => $purpose, 'items' => $items, 'next_cursor' => $more ? (string) $last : null, 'has_more' => $more];
    }
}
