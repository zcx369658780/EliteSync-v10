<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Models\ModerationReport;
use App\Models\StatusPost;
use App\Models\StatusPostLike;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Admin\OperationAudit;
use App\Services\EventLogger;
use App\Services\NotificationService;
use App\Services\SocialPolicy;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Query\Expression;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StatusPostController extends Controller
{
    /**
     * Build a safe author projection that tolerates older schemas where the
     * 3.1 account-layer columns may not exist yet.
     *
     * @param  array<string, mixed>  $fallbacks
     * @return array<int, string|Expression>
     */
    private function safeAuthorSelect(array $fallbacks = []): array
    {
        $columns = ['id', 'phone', 'name'];

        foreach ($fallbacks as $column => $fallback) {
            if (Schema::hasColumn('users', $column)) {
                $columns[] = $column;

                continue;
            }

            $columns[] = DB::raw($this->sqlLiteral($fallback).' as '.$column);
        }

        return $columns;
    }

    private function sqlLiteral(mixed $value): string
    {
        if ($value === null) {
            return 'NULL';
        }

        if (is_bool($value)) {
            return $value ? '1' : '0';
        }

        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }

        return DB::connection()->getPdo()->quote((string) $value);
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeMediaAsset(?MediaAsset $asset): array
    {
        if (! $asset || ! in_array($asset->storage_disk, ['v1007', 'v1009', 'v1011_relationship'], true)) {
            return [];
        }

        return [
            'id' => (int) $asset->id,
            'media_type' => (string) $asset->media_type,
            'storage_provider' => (string) $asset->storage_provider,
            'storage_disk' => (string) $asset->storage_disk,
            'storage_key' => '',
            'mime_type' => (string) ($asset->mime_type ?? ''),
            'size_bytes' => (int) ($asset->size_bytes ?? 0),
            'status' => (string) $asset->status,
            'error_code' => (string) ($asset->error_code ?? ''),
            'error_message' => (string) ($asset->error_message ?? ''),
            'public_url' => rtrim((string) config('app.url'), '/').'/api/v1/media/'.$asset->id.'/content',
            'width' => $asset->width,
            'height' => $asset->height,
            'duration_ms' => $asset->duration_ms,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeAuthor(?User $author): array
    {
        return ['id' => (int) ($author?->id ?? 0), 'public_id' => 'ES-'.($author?->id ?? 0), 'name' => 'ES-'.($author?->id ?? 0), 'avatar' => null];
    }

    /**
     * @return Builder<StatusPost>
     */
    private function visibleFeedQuery(?int $viewerId, bool $viewerIsAdmin, bool $includeHidden = false): Builder
    {
        $query = StatusPost::query()
            ->with([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'nickname' => '',
                        'city' => '',
                        'relationship_goal' => '',
                        'public_mbti' => '',
                        'public_personality' => null,
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_synthetic' => false,
                        'is_square_visible' => true,
                    ]));
                },
                'coverMediaAsset',
            ])
            ->withCount('likes')
            ->withCount([
                'likes as viewer_liked_count' => function ($query) use ($viewerId) {
                    if ($viewerId !== null) {
                        $query->where('user_id', $viewerId);
                    } else {
                        $query->whereRaw('1 = 0');
                    }
                },
            ])
            ->orderByDesc('id');

        $query->where('is_deleted', false)->whereHas('author', fn ($q) => $q->where('disabled', false))
            ->where(function ($q) use ($viewerId) {
                $q->where('author_user_id', $viewerId ?? 0);
                if ($viewerId !== null) {
                    $q->orWhere(function ($f) use ($viewerId) {
                        $f->where('audience', 'FRIENDS')->whereExists(function ($sub) use ($viewerId) {
                            $sub->select(DB::raw(1))->from('friendships')->where('state', 'ACTIVE')->where(function ($pair) use ($viewerId) {
                                $pair->where(fn ($p) => $p->where('user_a', $viewerId)->whereColumn('user_b', 'status_posts.author_user_id'))
                                    ->orWhere(fn ($p) => $p->where('user_b', $viewerId)->whereColumn('user_a', 'status_posts.author_user_id'));
                            });
                        });
                    });
                }
            });

        if ($viewerId !== null) {
            $query
                ->whereNotExists(function ($sub) use ($viewerId) {
                    $sub->select(DB::raw(1))
                        ->from('user_blocks as blocker')
                        ->whereColumn('blocker.blocker_id', 'status_posts.author_user_id')
                        ->where('blocker.blocked_user_id', $viewerId);
                })
                ->whereNotExists(function ($sub) use ($viewerId) {
                    $sub->select(DB::raw(1))
                        ->from('user_blocks as blocked')
                        ->where('blocked.blocker_id', $viewerId)
                        ->whereColumn('blocked.blocked_user_id', 'status_posts.author_user_id');
                });
        }

        return $query;
    }

    private function shapePost(StatusPost $post, ?int $viewerId = null, bool $viewerIsAdmin = false): array
    {
        $author = $post->author;
        $coverMedia = $post->coverMediaAsset;
        $canDelete = $viewerIsAdmin || ($viewerId !== null && (int) $author?->id === $viewerId);

        $media = [];
        if ($coverMedia && in_array($coverMedia->storage_disk, ['v1007', 'v1009', 'v1011_relationship'], true)) {
            $media[] = rtrim((string) config('app.url'), '/').'/api/v1/media/'.$coverMedia->id.'/content';
        }

        return [
            'id' => (int) $post->id,
            'title' => (string) $post->title,
            'body' => (string) $post->body,
            'location_name' => '',
            'visibility' => (string) ($post->visibility ?? 'private'),
            'audience' => $post->audience ?? 'SELF',
            'is_deleted' => (bool) $post->is_deleted,
            'can_delete' => $canDelete,
            'likes_count' => (int) ($post->likes_count ?? 0),
            'liked_by_viewer' => (bool) ((int) ($post->viewer_liked_count ?? 0) > 0),
            'cover_media_asset_id' => $post->cover_media_asset_id ? (int) $post->cover_media_asset_id : null,
            'media' => $media,
            'cover_media' => $this->shapeMediaAsset($coverMedia),
            'created_at' => optional($post->created_at)?->toIso8601String(),
            'updated_at' => optional($post->updated_at)?->toIso8601String(),
            'deleted_at' => optional($post->deleted_at)?->toIso8601String(),
            'author' => $this->shapeAuthor($author),
        ];
    }

    private function visibleStatusQueryForPost(int $postId, ?int $viewerId, bool $viewerIsAdmin): Builder
    {
        return $this->visibleFeedQuery($viewerId, $viewerIsAdmin)
            ->where('id', $postId);
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $viewerId = $user?->id !== null ? (int) $user->id : null;
        $viewerIsAdmin = app(AdminAccess::class)->allows($user);
        $limit = max(1, min((int) $request->query('limit', 20), 50));
        $cursor = max(0, (int) $request->query('cursor', 0));
        $includeHidden = $viewerIsAdmin && $request->boolean('include_hidden', false);

        $query = $this->visibleFeedQuery($viewerId, $viewerIsAdmin, $includeHidden);

        $countQuery = clone $query;
        $total = $countQuery->count();

        $items = $query
            ->skip($cursor)
            ->take($limit)
            ->get()
            ->map(fn (StatusPost $post) => $this->shapePost($post, $viewerId, $viewerIsAdmin))
            ->values();

        $nextCursor = ($cursor + $items->count()) < $total ? (string) ($cursor + $items->count()) : null;

        return response()->json([
            'items' => $items,
            'meta' => [
                'next_cursor' => $nextCursor,
                'has_more' => $nextCursor !== null,
                'total' => $total,
            ],
        ]);
    }

    public function show(Request $request, int $postId): JsonResponse
    {
        $user = $request->user();
        $viewerId = $user?->id !== null ? (int) $user->id : null;
        $viewerIsAdmin = app(AdminAccess::class)->allows($user);

        $post = $this->visibleStatusQueryForPost($postId, $viewerId, $viewerIsAdmin)
            ->first();

        if (! $post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost($post, $viewerId, $viewerIsAdmin),
        ]);
    }

    public function author(Request $request, int $userId): JsonResponse
    {
        $viewer = $request->user();
        $viewerId = $viewer?->id !== null ? (int) $viewer->id : null;
        $viewerIsAdmin = app(AdminAccess::class)->allows($viewer);

        $author = User::query()
            ->select($this->safeAuthorSelect([
                'nickname' => '',
                'city' => '',
                'relationship_goal' => '',
                'public_mbti' => '',
                'public_personality' => null,
                'role' => 'user',
                'account_type' => 'normal',
                'is_synthetic' => false,
                'is_square_visible' => true,
            ]))
            ->find($userId);

        app(SocialPolicy::class)->profile((int) $viewerId, $userId);
        if (! app(SocialPolicy::class)->pairAllowed((int) $viewerId, $userId)) {
            return response()->json(['message' => 'author not found'], 404);
        }
        if (! $author) {
            return response()->json(['message' => 'author not found'], 404);
        }

        if (! $viewerIsAdmin && (bool) $author->disabled) {
            return response()->json(['message' => 'author not found'], 404);
        }

        if (! $viewerIsAdmin && $viewerId !== $userId && ! (bool) ($author->is_square_visible ?? true)) {
            return response()->json(['message' => 'author not found'], 404);
        }

        $postsQuery = $this->visibleFeedQuery($viewerId, $viewerIsAdmin)
            ->where('author_user_id', $userId);

        $items = $postsQuery
            ->orderByDesc('id')
            ->limit(10)
            ->get()
            ->map(fn (StatusPost $post) => $this->shapePost($post, $viewerId, $viewerIsAdmin))
            ->values();

        return response()->json([
            'ok' => true,
            'author' => $this->shapeAuthor($author),
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        return DB::transaction(function () use ($request): JsonResponse {
            $user = User::query()->whereKey($request->user()?->id)->lockForUpdate()->first();
            if (! $user || ($user->disabled ?? false) || in_array(($user?->moderation_status ?? 'normal'), ['banned', 'restricted'], true)) {
                return response()->json(['message' => 'account blocked'], 403);
            }

            $data = $request->validate([
                'title' => ['required', 'string', 'max:120'],
                'body' => ['required', 'string', 'max:500'],
                'location_name' => ['nullable', 'string', 'max:120'],
                'visibility' => ['nullable', 'string', 'in:public,square,private'],
                'audience' => ['required', 'in:SELF,FRIENDS'],
                'cover_media_asset_id' => ['nullable', 'integer', 'exists:media_assets,id'],
            ]);

            $location = trim((string) ($data['location_name'] ?? ''));
            if ($location === '') {
                $location = trim((string) ($user?->city ?? $user?->private_birth_place ?? ''));
            }

            $coverMediaAssetId = null;
            if (! empty($data['cover_media_asset_id'])) {
                $coverAsset = MediaAsset::query()
                    ->where('id', (int) $data['cover_media_asset_id'])
                    ->where('owner_user_id', (int) $user->id)
                    ->lockForUpdate()
                    ->first();

                if (! $coverAsset) {
                    return response()->json(['message' => 'cover media not found'], 422);
                }

                if (! in_array($coverAsset->storage_disk, ['v1007', 'v1009', 'v1011_relationship'], true)) {
                    return response()->json(['message' => 'private cover media required'], 422);
                }

                if (! str_starts_with((string) $coverAsset->media_type, 'image')) {
                    return response()->json(['message' => 'cover media must be an image'], 422);
                }

                if (! in_array((string) $coverAsset->status, ['uploaded', 'ready'], true)) {
                    return response()->json(['message' => 'cover media is not ready'], 422);
                }

                $coverMediaAssetId = (int) $coverAsset->id;
            }

            $post = StatusPost::create([
                'author_user_id' => (int) $user->id,
                'cover_media_asset_id' => $coverMediaAssetId,
                'title' => trim($data['title']),
                'body' => trim($data['body']),
                'location_name' => $location === '' ? null : $location,
                'visibility' => 'private',
                'audience' => $data['audience'],
                'is_deleted' => false,
                'deleted_by_user_id' => null,
                'deleted_at' => null,
            ])->load([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'nickname' => '',
                        'city' => '',
                        'relationship_goal' => '',
                        'public_mbti' => '',
                        'public_personality' => null,
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_synthetic' => false,
                        'is_square_visible' => true,
                    ]));
                },
                'coverMediaAsset',
            ]);

            return response()->json([
                'ok' => true,
                'item' => $this->shapePost($post, (int) $user->id, app(AdminAccess::class)->allows($user)),
            ], 201);
        });
    }

    public function audience(Request $request, int $id): JsonResponse
    {
        $d = $request->validate(['audience' => 'required|in:SELF,FRIENDS']);

        return DB::transaction(function () use ($request, $id, $d) {
            User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $post = StatusPost::whereKey($id)->where('author_user_id', $request->user()->id)->where('is_deleted', false)->lockForUpdate()->firstOrFail();
            $post->audience = $d['audience'];
            $post->save();

            return response()->json(['id' => $post->id, 'audience' => $post->audience]);
        });
    }

    public function like(Request $request, int $postId, EventLogger $events, NotificationService $notifications): JsonResponse
    {
        return $this->toggleLike($request, $postId, true, $events, $notifications);
    }

    public function unlike(Request $request, int $postId, EventLogger $events, NotificationService $notifications): JsonResponse
    {
        return $this->toggleLike($request, $postId, false, $events, $notifications);
    }

    private function toggleLike(
        Request $request,
        int $postId,
        bool $liked,
        EventLogger $events,
        NotificationService $notifications
    ): JsonResponse {
        return DB::transaction(function () use ($request, $postId, $liked, $events, $notifications) {
            $owner = StatusPost::whereKey($postId)->value('author_user_id');
            User::whereIn('id', [$request->user()->id, $owner])->orderBy('id')->lockForUpdate()->get();
            $user = $request->user();
            $viewerId = (int) $user->id;
            $post = $this->visibleStatusQueryForPost($postId, $viewerId, app(AdminAccess::class)->allows($user))->first();
            if (! $post) {
                return response()->json(['message' => 'status post not found'], 404);
            }

            if ($liked) {
                StatusPostLike::query()->firstOrCreate([
                    'status_post_id' => (int) $post->id,
                    'user_id' => $viewerId,
                ]);
            } else {
                StatusPostLike::query()
                    ->where('status_post_id', (int) $post->id)
                    ->where('user_id', $viewerId)
                    ->delete();
            }

            $events->log(
                eventName: $liked ? 'status_post_like' : 'status_post_unlike',
                actorUserId: $viewerId,
                targetUserId: (int) $post->author_user_id,
                payload: [
                    'status_post_id' => (int) $post->id,
                    'liked' => $liked,
                    'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                    'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
                ]
            );

            if ($liked && (int) $post->author_user_id !== $viewerId) {
                $actorName = 'ES-'.$user->id;
                $notifications->createForUser(
                    userId: (int) $post->author_user_id,
                    kind: 'status_like',
                    title: "{$actorName} 赞了你的动态",
                    body: trim((string) $post->title) !== '' ? mb_strimwidth(trim((string) $post->title), 0, 60, '…', 'UTF-8') : '你的动态获得了新的互动',
                    payload: [
                        'route_name' => 'status_author',
                        'route_args' => [
                            'user_id' => (int) $post->author_user_id,
                            'name' => 'ES-'.$post->author_user_id,
                        ],
                        'status_post_id' => (int) $post->id,
                        'actor_user_id' => $viewerId,
                        'source' => 'status_like',
                    ]
                );
            }

            $fresh = $this->visibleStatusQueryForPost($postId, $viewerId, app(AdminAccess::class)->allows($user))->firstOrFail();

            return response()->json([
                'ok' => true,
                'item' => $this->shapePost($fresh, $viewerId, app(AdminAccess::class)->allows($user)),
            ]);
        });
    }

    public function report(Request $request, int $postId, EventLogger $events): JsonResponse
    {
        $user = $request->user();
        $viewerId = (int) $user->id;
        $post = $this->visibleStatusQueryForPost($postId, $viewerId, app(AdminAccess::class)->allows($user))->first();
        if (! $post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        $data = $request->validate([
            'reason_code' => ['required', 'string', 'max:64'],
            'detail' => ['nullable', 'string', 'max:2000'],
        ]);

        $report = ModerationReport::create([
            'reporter_id' => $viewerId,
            'target_user_id' => (int) $post->author_user_id,
            'target_status_post_id' => (int) $post->id,
            'category' => 'status_post',
            'reason_code' => $data['reason_code'],
            'detail' => $data['detail'] ?? null,
            'status' => 'new',
            'appeal_status' => 'none',
        ]);

        $events->log(
            eventName: 'status_post_report',
            actorUserId: $viewerId,
            targetUserId: (int) $post->author_user_id,
            payload: [
                'status_post_id' => (int) $post->id,
                'reason_code' => (string) $data['reason_code'],
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        return response()->json([
            'ok' => true,
            'report' => [
                'id' => $report->id,
                'status' => $report->status,
                'appeal_status' => $report->appeal_status,
            ],
        ]);
    }

    public function destroy(Request $request, int $postId): JsonResponse
    {
        $user = $request->user();
        $post = StatusPost::query()
            ->with([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'nickname' => '',
                        'city' => '',
                        'relationship_goal' => '',
                        'public_mbti' => '',
                        'public_personality' => null,
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_synthetic' => false,
                        'is_square_visible' => true,
                    ]));
                },
                'coverMediaAsset',
            ])
            ->find($postId);

        if (! $post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        $viewerIsAdmin = app(AdminAccess::class)->allows($user);
        $isOwner = (int) $post->author_user_id === (int) $user?->id;
        if (! $viewerIsAdmin && ! $isOwner) {
            return response()->json(['message' => 'forbidden'], 403);
        }

        if (! $isOwner) {
            $data = $request->validate([
                'reason' => ['required', 'string', 'max:1000'],
                'expected_revision' => ['required', 'integer', 'min:0'],
                'confirm' => ['required', 'accepted'],
            ]);
            abort_if(trim($data['reason']) === '', 422, 'reason required');
            $post = DB::transaction(function () use ($user, $postId, $data) {
                $actor = User::query()->whereKey($user->id)->lockForUpdate()->first();
                abort_unless(app(AdminAccess::class)->allows($actor), 403);
                $locked = StatusPost::query()->whereKey($postId)->lockForUpdate()->firstOrFail();
                // This operation only moderates public content. Private authors retain their own delete flow.
                abort_unless(in_array($locked->visibility, ['public', 'square'], true), 403);
                // The delete lifecycle is revision 0 (present) -> 1 (soft-deleted).
                // Recheck the locked row, including deletes performed through report operations.
                abort_if((int) $data['expected_revision'] !== 0 || $locked->is_deleted, 409, 'stale post deletion revision');
                $before = ['is_deleted' => false, 'revision' => 0];
                $locked->is_deleted = true;
                $locked->deleted_by_user_id = $actor->id;
                $locked->deleted_at = now();
                $locked->save();
                OperationAudit::record($actor->id, 'status_post.remove', 'status_post',
                    $locked->id, trim($data['reason']), 0, $before,
                    ['is_deleted' => true, 'revision' => 1, 'deleted_by_user_id' => $actor->id]);

                return $locked;
            });
        } else {
            $post->is_deleted = true;
            $post->deleted_by_user_id = (int) $user->id;
            $post->deleted_at = now();
            $post->save();
        }

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost(
                $post->fresh([
                    'author' => function ($query) {
                        $query->select($this->safeAuthorSelect([
                            'nickname' => '',
                            'city' => '',
                            'relationship_goal' => '',
                            'public_mbti' => '',
                            'public_personality' => null,
                            'role' => 'user',
                            'account_type' => 'normal',
                            'is_synthetic' => false,
                            'is_square_visible' => true,
                        ]));
                    },
                    'coverMediaAsset',
                ]),
                (int) $user->id,
                $viewerIsAdmin
            ),
        ]);
    }
}
