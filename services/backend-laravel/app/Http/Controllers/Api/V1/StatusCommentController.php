<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\StatusPost;
use App\Services\JourneyStore;
use App\Services\NotificationService;
use App\Services\PostAudience;
use App\Services\StatusCommentAudience;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class StatusCommentController extends Controller
{
    public function __construct(private PostAudience $posts, private StatusCommentAudience $comments) {}

    private function actor(Request $request): int
    {
        foreach (['actor_id', 'author_id', 'user_id', 'reply_to', 'quote', 'attachment', 'attachments', 'media', 'media_id'] as $key) {
            abort_if($request->exists($key), 422, 'unsupported comment field');
        }

        return (int) $request->user()->id;
    }

    private function shape(StatusPost $post, object $row, int $viewer, array $context): array
    {
        $own = (int) $row->author_id === $viewer;
        $owner = (int) $post->author_user_id === $viewer;
        $authorMayAct = $own && ! $row->withdrawn;
        $ownerMayAct = $owner && ! $own && ! $row->hidden_by_owner;

        return [
            'id' => $row->id, 'state' => 'ACTIVE', 'revision' => (int) $row->revision,
            'author_id' => (int) $row->author_id, 'body' => $row->body,
            'can_withdraw' => $authorMayAct, 'can_hide' => $ownerMayAct,
            'can_report' => ! $own,
            'can_reply' => $row->parent_id === null && $this->posts->mayCommentLocked($post, $viewer),
            'created_at' => $row->created_at,
        ] + $context;
    }

    private function row(int $post, string $id): ?object
    {
        return DB::table('status_post_comments')->where('status_post_id', $post)->where('id', $id)
            ->lockForUpdate()->first();
    }

    public function index(Request $request, int $postId)
    {
        $actor = $this->actor($request);
        $offset = max(0, (int) $request->query('cursor', 0));
        $query = DB::table('status_post_comments as comment')
            ->leftJoin('status_post_comments as parent', fn ($join) => $join->on('parent.id', '=', 'comment.parent_id')
                ->on('parent.status_post_id', '=', 'comment.status_post_id'))
            ->where('comment.status_post_id', $postId)->whereJsonContains('comment.original_viewer_ids', $actor)
            ->where(fn ($query) => $query->where(fn ($visible) => $visible->where('comment.state', 'ACTIVE')
                ->where('comment.withdrawn', false)->where('comment.hidden_by_owner', false))
                ->orWhere('comment.author_id', $actor))
            ->orderBy('comment.created_at')->orderBy('comment.id')
            ->select('comment.id', 'comment.author_id', 'parent.author_id as parent_author_id');

        // The visible cursor never counts a hidden row. Scan candidates in
        // bounded transactions, then revalidate the page together before
        // returning bodies or indicating that another authorized item exists.
        $selected = collect();
        $visible = 0;
        $query->chunk(40, function ($batch) use ($actor, $postId, $offset, &$visible, $selected) {
            $eligible = $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $batch) {
                return $batch->filter(function ($candidate) use ($actor, $post) {
                    $row = $this->row((int) $post->id, $candidate->id);

                    return $row && $this->projection($post, $row, $actor) !== null;
                });
            }, $this->authors($batch));
            foreach ($eligible as $candidate) {
                if ($visible++ >= $offset) {
                    $selected->push($candidate);
                    if ($selected->count() > 20) {
                        return false;
                    }
                }
            }

            return true;
        });

        return $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $offset, $selected) {
            $items = [];
            foreach ($selected as $candidate) {
                $row = $this->row((int) $post->id, $candidate->id);
                $item = $row ? $this->projection($post, $row, $actor) : null;
                if ($item !== null) {
                    $items[] = $item;
                }
            }
            $more = count($items) > 20;

            return response()->json([
                'items' => array_slice($items, 0, 20),
                'can_comment' => $this->posts->mayCommentLocked($post, $actor),
                'meta' => ['next_cursor' => $more ? (string) ($offset + 20) : null, 'has_more' => $more],
            ]);
        }, $this->authors($selected));
    }

    private function authors(Collection $candidates): array
    {
        return $candidates->flatMap(fn ($row) => [(int) $row->author_id, (int) $row->parent_author_id])
            ->filter()->unique()->all();
    }

    private function projection(StatusPost $post, object $row, int $actor): ?array
    {
        if ($this->comments->displayed($row) && ($context = $this->comments->presentation($post, $row, $actor)) !== null) {
            return $this->shape($post, $row, $actor, $context);
        }
        if ((int) $row->author_id === $actor && $this->comments->contextAllows($post, $row, $actor)) {
            return ['id' => $row->id, 'state' => 'UNAVAILABLE', 'revision' => (int) $row->revision,
                'can_withdraw' => ! $row->withdrawn];
        }

        return null;
    }

    public function show(Request $request, int $postId, string $commentId)
    {
        $actor = $this->actor($request);
        $authors = $this->comments->commentAuthors($postId, $commentId);
        abort_if($authors === [], 404, 'unavailable');

        return $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $commentId) {
            $row = $this->row((int) $post->id, $commentId);
            $projection = $row ? $this->projection($post, $row, $actor) : null;
            abort_unless($projection, 404, 'unavailable');

            return response()->json($projection);
        }, $authors);
    }

    public function commandResult(Request $request, int $postId)
    {
        $actor = $this->actor($request);
        $data = $request->validate(['request_key' => 'required|string|max:80']);

        return $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $data) {
            $applied = DB::table('status_post_comments')->where('status_post_id', $post->id)
                ->where('author_id', $actor)->where('idempotency_key', $data['request_key'])->lockForUpdate()->exists();

            return response()->json(['state' => $applied ? 'APPLIED' : 'NOT_APPLIED']);
        });
    }

    public function store(Request $request, int $postId)
    {
        $actor = $this->actor($request);
        $data = $request->validate([
            'body' => 'required_without:independent_response|prohibits:independent_response|string|max:280',
            'parent_id' => 'required_with:independent_response|uuid',
            'independent_response' => ['sometimes', Rule::in(array_keys(StatusCommentAudience::INDEPENDENT_RESPONSES))],
            'idempotency_key' => 'required|string|max:80',
        ]);
        $parentId = $data['parent_id'] ?? null;
        $independent = $data['independent_response'] ?? null;
        $body = trim($independent ? StatusCommentAudience::INDEPENDENT_RESPONSES[$independent] : $data['body']);
        abort_if($body === '' || preg_match('/https?:|www\.|@|\d{5,}|微信|手机号|身份证|wechat/i', $body), 422, 'comments do not support links or contact details');
        $authors = $parentId ? $this->comments->commentAuthors($postId, $parentId) : [];

        return $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $data, $body, $parentId, $independent) {
            abort_unless($this->posts->mayCommentLocked($post, $actor), 403, 'comments are closed for this viewer');
            $parent = $parentId ? $this->row((int) $post->id, $parentId) : null;
            if ($parentId) {
                abort_unless($parent && ! $parent->parent_id && $this->comments->displayed($parent)
                    && $this->comments->contextAllows($post, $parent, $actor), 404, 'unavailable');
            }

            $existing = DB::table('status_post_comments')->where('author_id', $actor)
                ->where('idempotency_key', $data['idempotency_key'])->lockForUpdate()->first();
            if ($existing) {
                abort_unless((int) $existing->status_post_id === (int) $post->id && $existing->body === $body
                    && $existing->parent_id === $parentId && $existing->independent_response === $independent
                    && $this->comments->displayed($existing)
                    && ($context = $this->comments->presentation($post, $existing, $actor)) !== null, 409, 'idempotency conflict');

                return response()->json($this->shape($post, $existing, $actor, $context));
            }
            abort_if(DB::table('status_post_comments')->where('author_id', $actor)
                ->where('created_at', '>', now()->subMinutes(10))->count() >= 5, 429, 'comment limit');

            $viewers = $this->posts->commentViewersLocked($post, $actor);
            if ($parent) {
                $viewers = array_values(array_intersect($viewers, json_decode($parent->original_viewer_ids, true)));
            }
            abort_unless(in_array($actor, $viewers, true), 404, 'unavailable');
            $id = (string) Str::uuid();
            DB::table('status_post_comments')->insert([
                'id' => $id, 'status_post_id' => $post->id, 'author_id' => $actor, 'body' => $body,
                'original_viewer_ids' => json_encode($viewers, JSON_THROW_ON_ERROR),
                'original_audience' => $this->posts->commentAudience($post),
                'parent_id' => $parentId, 'independent_response' => $independent,
                'state' => 'ACTIVE', 'revision' => 1, 'idempotency_key' => $data['idempotency_key'],
                'created_at' => now(), 'updated_at' => now(),
            ]);
            $owner = (int) $post->author_user_id;
            if ($owner !== $actor && in_array($owner, $viewers, true) && ! $parentId) {
                app(NotificationService::class)->createForUser($owner, 'status_comment', '动态有新互动',
                    '请在当前权限允许时查看', ['status_post_id' => $post->id, 'status_comment_id' => $id, 'actor_user_id' => $actor]);
            }
            $row = $this->row((int) $post->id, $id);

            return response()->json($this->shape($post, $row, $actor,
                ['parent_id' => $parentId, 'thread_context' => $parentId ? 'REPLY' : null]), 201);
        }, $authors);
    }

    public function destroy(Request $request, int $postId, string $commentId)
    {
        return $this->changeDisplay($request, $postId, $commentId, true);
    }

    public function display(Request $request, int $postId, string $commentId)
    {
        return $this->changeDisplay($request, $postId, $commentId, false);
    }

    private function changeDisplay(Request $request, int $postId, string $commentId, bool $legacy)
    {
        $actor = $this->actor($request);
        $data = $request->validate(['revision' => 'required|integer|min:1',
            'action' => $legacy ? 'prohibited' : 'required|in:WITHDRAW,HIDE']);
        $action = $data['action'] ?? (DB::table('status_post_comments')->where('status_post_id', $postId)
            ->where('id', $commentId)->where('author_id', $actor)->exists() ? 'WITHDRAW' : 'HIDE');
        $revision = (int) $data['revision'];
        if ($action === 'WITHDRAW') {
            // The author controls their own display even after losing post read
            // access. This never grants access to the post, parent or reply.
            return DB::transaction(function () use ($actor, $postId, $commentId, $revision) {
                app(JourneyStore::class)->users([$actor]);
                $row = DB::table('status_post_comments')->where('status_post_id', $postId)->where('id', $commentId)
                    ->where('author_id', $actor)->lockForUpdate()->first();
                abort_unless($row, 404, 'unavailable');

                return $this->saveDisplayControl($row, 'withdrawn', $revision);
            }, 3);
        }

        $authors = $this->comments->commentAuthors($postId, $commentId);
        abort_if($authors === [], 404, 'unavailable');

        return $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $commentId, $revision) {
            $row = $this->row((int) $post->id, $commentId);
            abort_unless($row && $actor === (int) $post->author_user_id && $actor !== (int) $row->author_id
                && $this->comments->contextAllows($post, $row, $actor), 404, 'unavailable');
            abort_unless($row->state === 'ACTIVE', 409, 'stale comment');

            return $this->saveDisplayControl($row, 'hidden_by_owner', $revision);
        }, $authors);
    }

    private function saveDisplayControl(object $row, string $field, int $revision)
    {
        abort_unless(! $row->$field && (int) $row->revision === $revision, 409, 'stale comment');
        DB::table('status_post_comments')->where('id', $row->id)
            ->update([$field => true, 'revision' => $revision + 1, 'updated_at' => now()]);

        return response()->json(['id' => $row->id, 'state' => 'UNAVAILABLE', 'revision' => $revision + 1]);
    }

    public function report(Request $request, int $postId, string $commentId)
    {
        $actor = $this->actor($request);
        $data = $request->validate(['reason_code' => 'required|string|max:64', 'detail' => 'nullable|string|max:1000']);
        $authors = $this->comments->commentAuthors($postId, $commentId);
        abort_if($authors === [], 404, 'unavailable');

        return $this->posts->run($actor, $postId, function (StatusPost $post) use ($actor, $commentId, $data) {
            $row = $this->row((int) $post->id, $commentId);
            abort_unless($row && $this->comments->displayed($row) && (int) $row->author_id !== $actor
                && $this->comments->presentation($post, $row, $actor) !== null, 404, 'unavailable');
            $old = DB::table('moderation_reports')->where('reporter_id', $actor)
                ->where('target_status_comment_id', $commentId)->where('status', 'new')->first();
            $id = $old?->id ?? DB::table('moderation_reports')->insertGetId([
                'reporter_id' => $actor, 'target_user_id' => $row->author_id, 'target_status_post_id' => $post->id,
                'target_status_comment_id' => $commentId, 'category' => 'status_comment', 'reason_code' => $data['reason_code'],
                'detail' => $data['detail'] ?? null, 'status' => 'new', 'appeal_status' => 'none',
                'created_at' => now(), 'updated_at' => now(),
            ]);

            return response()->json(['id' => $id, 'status' => 'new']);
        }, $authors);
    }
}
