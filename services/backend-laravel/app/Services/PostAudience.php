<?php

namespace App\Services;

use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/** Shared current authorization for posts, comments and private covers. */
final class PostAudience
{
    public const SELF = 'SELF';

    public const FRIENDS = 'FRIENDS';

    public const PUBLIC_AUTHENTICATED = 'PUBLIC_AUTHENTICATED';

    public const AUDIENCE_ORDER = [self::SELF => 0, self::FRIENDS => 1, self::PUBLIC_AUTHENTICATED => 2];

    public function commentPolicy(StatusPost $post): string
    {
        if ($post->audience === self::SELF) {
            return 'OFF';
        }

        // Pre-B friends works already admitted current friends. A legacy SELF
        // publication gains no comment permission when its audience changes.
        return $post->comment_policy ?? ($post->audience === self::FRIENDS ? 'FRIENDS_ONLY' : 'OFF');
    }

    public function mayCommentLocked(StatusPost $post, int $actor): bool
    {
        return match ($this->commentPolicy($post)) {
            'ALL_ELIGIBLE' => true,
            'FRIENDS_ONLY' => $actor === (int) $post->author_user_id
                || (bool) app(SocialPolicy::class)->friendship($actor, (int) $post->author_user_id),
            default => false,
        };
    }

    public function commentAudience(StatusPost $post): string
    {
        return $post->audience === self::PUBLIC_AUTHENTICATED && $this->commentPolicy($post) === 'ALL_ELIGIBLE'
            ? self::PUBLIC_AUTHENTICATED : self::FRIENDS;
    }

    public function coverAllowedLocked(StatusPost $post, int $viewer): bool
    {
        $owner = (int) $post->author_user_id;
        $basis = $post->cover_audience;

        return $this->allowedLocked($post, $viewer) && ($viewer === $owner
            || ($basis === self::FRIENDS
                && in_array($viewer, $post->cover_original_viewer_ids ?? [], true)
                && app(SocialPolicy::class)->friendship($viewer, $owner)));
    }

    /** Capture only the original finite audience; current post permission is still mandatory on every read. */
    public function commentViewersLocked(StatusPost $post, int $actor): array
    {
        return $this->originalViewersLocked((int) $post->author_user_id, $actor,
            $this->commentAudience($post) === self::PUBLIC_AUTHENTICATED);
    }

    public function originalViewersLocked(int $owner, int $actor, bool $public = false): array
    {
        $users = User::where('disabled', false)->where('account_status', 'active')->where('moderation_status', 'normal');
        if (! $public) {
            $friends = DB::table('friendships')->where('state', 'ACTIVE')
                ->where(fn ($q) => $q->where('user_a', $owner)->orWhere('user_b', $owner))->lockForUpdate()->get();
            $ids = $friends->map(fn ($friend) => (int) ($friend->user_a == $owner ? $friend->user_b : $friend->user_a))->push($owner);
            $users->whereIn('id', $ids);
        }
        foreach (array_unique([$owner, $actor]) as $person) {
            $users->whereNotExists(function ($q) use ($person) {
                $q->selectRaw('1')->from('user_blocks')->where(fn ($pair) => $pair
                    ->where(fn ($a) => $a->where('blocker_id', $person)->whereColumn('blocked_user_id', 'users.id'))
                    ->orWhere(fn ($b) => $b->where('blocked_user_id', $person)->whereColumn('blocker_id', 'users.id')));
            });
        }

        return $users->pluck('id')->map(fn ($id) => (int) $id)->all();
    }

    public function allowedLocked(StatusPost $post, int $viewer): bool
    {
        if ($post->is_deleted) {
            return false;
        }
        $users = User::whereIn('id', [$viewer, (int) $post->author_user_id])->orderBy('id')->lockForUpdate()->get();
        if ($users->count() !== count(array_unique([$viewer, (int) $post->author_user_id])) || $users->contains(fn ($u) => $u->disabled || $u->account_status !== 'active' || $u->moderation_status !== 'normal')) {
            return false;
        }

        return app(SocialPolicy::class)->pairAllowed($viewer, (int) $post->author_user_id) && ($viewer === (int) $post->author_user_id || $post->audience === self::PUBLIC_AUTHENTICATED || ($post->audience === self::FRIENDS && app(SocialPolicy::class)->friendship($viewer, (int) $post->author_user_id)));
    }

    public function run(int $viewer, int $id, callable $work, array $extra = [], bool $optional = false): mixed
    {
        $owner = StatusPost::whereKey($id)->value('author_user_id');
        if ($owner === null) {
            return $optional ? null : abort(404, 'unavailable');
        }

        return DB::transaction(function () use ($viewer, $id, $owner, $work, $extra, $optional) {
            app(JourneyStore::class)->users([$viewer, (int) $owner, ...$extra], true);
            $post = StatusPost::whereKey($id)->lockForUpdate()->first();
            if (! $post || (int) $post->author_user_id !== (int) $owner || ! $this->allowedLocked($post, $viewer)) {
                return $optional ? null : abort(404, 'unavailable');
            }

return $work($post);
        }, 3);
    }
}
