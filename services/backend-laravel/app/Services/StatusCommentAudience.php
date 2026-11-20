<?php

namespace App\Services;

use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Support\Facades\DB;

final class StatusCommentAudience
{
    public const INDEPENDENT_RESPONSES = [
        'THANKS' => '谢谢分享这个话题。',
        'REFLECT' => '这个话题值得再想一想。',
    ];

    /** Call inside the authorized post transaction. */
    public function contextAllows(StatusPost $post, object $comment, int $viewer): bool
    {
        $author = (int) $comment->author_id;
        $ids = json_decode($comment->original_viewer_ids ?? '[]', true);
        $social = app(SocialPolicy::class);
        $audience = $comment->original_audience ?? PostAudience::FRIENDS;
        if (! is_array($ids) || ! in_array($viewer, $ids, true)
            || ! in_array($audience, [PostAudience::FRIENDS, PostAudience::PUBLIC_AUTHENTICATED], true)
            || ! User::whereKey($author)->where('account_status', 'active')->where('moderation_status', 'normal')
                ->where('disabled', false)->lockForUpdate()->exists()
            || ! $social->pairAllowed($viewer, $author)) {
            return false;
        }

        $owner = (int) $post->author_user_id;

        return $audience === PostAudience::PUBLIC_AUTHENTICATED || $viewer === $owner
            || (bool) $social->friendship($viewer, $owner);
    }

    public function displayed(object $comment): bool
    {
        return $comment->state === 'ACTIVE' && ! $comment->withdrawn && ! $comment->hidden_by_owner;
    }

    /** Null means the entire comment is unavailable. */
    public function presentation(StatusPost $post, object $comment, int $viewer): ?array
    {
        if (! $this->contextAllows($post, $comment, $viewer)) {
            return null;
        }
        if (! $comment->parent_id) {
            return $this->displayed($comment) ? ['parent_id' => null, 'thread_context' => null] : null;
        }

        $parent = DB::table('status_post_comments')->where('status_post_id', $post->id)
            ->where('id', $comment->parent_id)->lockForUpdate()->first();
        if (! $parent || $parent->parent_id || ! $this->contextAllows($post, $parent, $viewer)) {
            return null;
        }
        if ($this->displayed($parent)) {
            return ['parent_id' => $parent->id, 'thread_context' => 'REPLY'];
        }
        $safeText = self::INDEPENDENT_RESPONSES[$comment->independent_response] ?? null;
        if (! $safeText || $comment->body !== $safeText || ! $this->displayed($comment)
            || $parent->state !== 'ACTIVE' || (int) $parent->author_id === (int) $comment->author_id) {
            return null;
        }

        return ['parent_id' => null, 'thread_context' => 'UNAVAILABLE'];
    }

    public function commentAuthors(int $postId, string $id): array
    {
        $row = DB::table('status_post_comments as comment')
            ->leftJoin('status_post_comments as parent', fn ($join) => $join->on('parent.id', '=', 'comment.parent_id')
                ->on('parent.status_post_id', '=', 'comment.status_post_id'))
            ->where('comment.status_post_id', $postId)->where('comment.id', $id)
            ->first(['comment.author_id', 'parent.author_id as parent_author_id']);

        return $row ? array_values(array_filter([(int) $row->author_id, (int) $row->parent_author_id])) : [];
    }
}
