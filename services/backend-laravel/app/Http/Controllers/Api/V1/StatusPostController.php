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
use App\Services\PostAudience;
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

        $query->where('is_deleted', false)->whereHas('author', fn ($q) => $q->where('disabled', false)
                ->where('account_status', 'active')->where('moderation_status', 'normal'))
            ->where(function ($q) use ($viewerId) {
                $q->where('author_user_id', $viewerId ?? 0);
                if ($viewerId !== null) {
                    $q->orWhere('audience', PostAudience::PUBLIC_AUTHENTICATED)->orWhere(function ($f) use ($viewerId) {
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
        $coverMedia = $viewerId !== null && $post->cover_media_asset_id
            && app(PostAudience::class)->coverAllowedLocked($post, $viewerId)
            ? $post->coverMediaAsset : null;
        if ($coverMedia && (int) $coverMedia->owner_user_id !== (int) $post->author_user_id) {
            $coverMedia = null;
        }
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
            'audience_revision' => (int) ($post->audience_revision ?? 1),
            'comment_policy' => app(PostAudience::class)->commentPolicy($post),
            'is_deleted' => (bool) $post->is_deleted,
            'can_delete' => $canDelete,
            'likes_count' => (int) ($post->likes_count ?? 0),
            'liked_by_viewer' => (bool) ((int) ($post->viewer_liked_count ?? 0) > 0),
            'favorited_by_viewer' => $viewerId !== null && DB::table('status_post_favorites')
                ->where('user_id', $viewerId)->where('status_post_id', $post->id)->exists(),
            'cover_media_asset_id' => $coverMedia ? (int) $coverMedia->id : null,
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

    private function channelQuery(Builder $query, ?string $channel, array $recommended): Builder
    {
        return match ($channel) {
            'friends' => $query->where('audience', PostAudience::FRIENDS),
            'featured' => $query->where(fn ($q) => $q->where('audience', PostAudience::PUBLIC_AUTHENTICATED)
                ->orWhere(fn ($eligible) => $eligible->where('audience', PostAudience::FRIENDS)->whereIn('id', $recommended))),
            default => $query,
        };
    }

    public function index(Request $request, PostAudience $policy): JsonResponse
    {
        $filters = $request->validate([
            'channel' => 'sometimes|in:featured,friends',
            'q' => 'sometimes|nullable|string|max:80',
            'cursor' => 'sometimes|nullable|integer|min:0',
            'limit' => 'sometimes|integer|min:1|max:20',
        ]);
        $viewer = (int) $request->user()->id;
        $limit = (int) ($filters['limit'] ?? 20);
        $cursor = (int) ($filters['cursor'] ?? 0);
        $channel = $filters['channel'] ?? null;
        $term = trim($filters['q'] ?? '');
        $recommended = array_values(array_filter(config('home_content.editor_recommendations', []), 'is_int'));
        $query = $this->channelQuery($this->visibleFeedQuery($viewer, false), $channel, $recommended);
        if ($term !== '') {
            $query->where(fn ($q) => $q->whereLike('title', "%{$term}%")->orWhereLike('body', "%{$term}%"));
        }
        // Re-read after getting the current locks so search and feed candidates
        // cannot return a stale body or a recommendation for a retracted post.
        $ids = $query->skip($cursor)->take($limit + 1)->pluck('id');
        $items = [];
        foreach ($ids->take($limit) as $id) {
            $value = $policy->run($viewer, (int) $id, function (StatusPost $post) use ($viewer, $channel, $recommended) {
                $fresh = $this->channelQuery($this->visibleStatusQueryForPost($post->id, $viewer, false), $channel, $recommended)->first();
                if (! $fresh) {
                    return null;
                }

                return $this->shapePost($fresh, $viewer) + [
                    'editor_recommended' => $channel === 'featured' && in_array((int) $fresh->id, $recommended, true),
                ];
            }, optional: true);
            if ($value !== null) {
                $items[] = $value;
            }
        }
        $more = $ids->count() > $limit;

        return response()->json(['items' => $items, 'meta' => [
            'next_cursor' => $more ? (string) ($cursor + $limit) : null,
            'has_more' => $more, 'total' => count($items),
        ]]);
    }

    public function show(Request $request,int $postId): JsonResponse
    {
        $viewer=(int)$request->user()->id;return app(\App\Services\PostAudience::class)->run($viewer,$postId,function($p)use($viewer){$post=$this->visibleStatusQueryForPost($p->id,$viewer,false)->firstOrFail();return response()->json(['ok'=>true,'item'=>$this->shapePost($post,$viewer,false)]);});
    }
    public function author(Request $request,int $userId): JsonResponse
    {
        $data = $request->validate(['limit' => 'sometimes|integer|min:1|max:20', 'cursor' => 'nullable|integer|min:1']);
        $viewer = (int) $request->user()->id;
        return DB::transaction(function () use ($viewer, $userId, $data) {
            app(\App\Services\JourneyStore::class)->users([$viewer, $userId], true);
            abort_unless(app(SocialPolicy::class)->pairAllowed($viewer, $userId)
                && ($viewer === $userId || app(SocialPolicy::class)->friendship($viewer, $userId)), 404, 'unavailable');
            $limit = $data['limit'] ?? 20;
            $ids = $this->visibleFeedQuery($viewer, false)->where('author_user_id', $userId)
                ->when(isset($data['cursor']), fn ($q) => $q->where('id', '<', $data['cursor']))
                ->limit($limit + 1)->pluck('id');
            $items = [];
            foreach ($ids->take($limit) as $id) {
                $post = StatusPost::whereKey($id)->lockForUpdate()->first();
                if ($post && app(\App\Services\PostAudience::class)->allowedLocked($post, $viewer)) {
                    $fresh = $this->visibleStatusQueryForPost($id, $viewer, false)->first();
                    if ($fresh) $items[] = $this->shapePost($fresh, $viewer, false);
                }
            }
            $more = $ids->count() > $limit;
            return response()->json(['ok' => true, 'author' => ['id' => $userId, 'public_id' => 'ES-'.$userId,
                'name' => 'ES-'.$userId, 'avatar' => null], 'items' => $items, 'total' => count($items),
                'meta' => ['has_more' => $more, 'next_cursor' => $more ? (string) $ids[$limit - 1] : null]]);
        }, 3);
    }

    public function favorite(Request $request, int $postId): JsonResponse
    {
        $data = $request->validate(['favorited' => 'required|boolean']);
        $viewer = (int) $request->user()->id;
        if (! $data['favorited']) {
            return DB::transaction(function () use ($viewer, $postId) {
                app(\App\Services\JourneyStore::class)->users([$viewer], true);
                DB::table('status_post_favorites')->where('user_id', $viewer)->where('status_post_id', $postId)->delete();
                return response()->json(['post_id' => $postId, 'favorited' => false]);
            }, 3);
        }
        return app(\App\Services\PostAudience::class)->run($viewer, $postId, function () use ($viewer, $postId) {
            DB::table('status_post_favorites')->insertOrIgnore(['user_id' => $viewer, 'status_post_id' => $postId,
                'created_at' => now(), 'updated_at' => now()]);
            return response()->json(['post_id' => $postId, 'favorited' => true]);
        });
    }

    public function favorites(Request $request): JsonResponse
    {
        $data = $request->validate(['limit' => 'sometimes|integer|min:1|max:20', 'cursor' => 'nullable|integer|min:1']);
        $viewer = (int) $request->user()->id;
        DB::transaction(fn () => app(\App\Services\JourneyStore::class)->users([$viewer], true));
        $limit = $data['limit'] ?? 20;
        $saved = DB::table('status_post_favorites')->where('user_id', $viewer)
            ->when(isset($data['cursor']), fn ($q) => $q->where('id', '<', $data['cursor']))
            ->orderByDesc('id')->limit($limit + 1)->get();
        $items = [];
        foreach ($saved->take($limit) as $favorite) {
            $post = app(\App\Services\PostAudience::class)->run($viewer, (int) $favorite->status_post_id,
                function () use ($viewer, $favorite) {
                    $current = $this->visibleStatusQueryForPost((int) $favorite->status_post_id, $viewer, false)->first();
                    return $current ? $this->shapePost($current, $viewer, false) : null;
                }, [], true);
            $items[] = ['favorite_id' => (int) $favorite->id, 'post_id' => (int) $favorite->status_post_id,
                'saved_at' => $favorite->created_at, 'available' => $post !== null, 'post' => $post];
        }
        $more = $saved->count() > $limit;
        return response()->json(['items' => $items, 'meta' => ['has_more' => $more,
            'next_cursor' => $more ? (string) $saved[$limit - 1]->id : null]]);
    }

    public function store(Request $request): JsonResponse
    {
        return DB::transaction(function () use ($request): JsonResponse {
            $user = User::query()->whereKey($request->user()?->id)->lockForUpdate()->first();
            app(\App\Services\JourneyStore::class)->users([(int)$request->user()->id],true);
            if (! $user || ($user->disabled ?? false) || in_array(($user?->moderation_status ?? 'normal'), ['banned', 'restricted'], true)) {
                return response()->json(['message' => 'account blocked'], 403);
            }

            $data = $request->validate([
                'title' => ['required', 'string', 'max:120'],
                'body' => ['required', 'string', 'max:500'],
                'location_name' => ['nullable', 'string', 'max:120'],
                'visibility' => ['nullable', 'string', 'in:public,square,private'],
                'audience' => ['sometimes', 'in:SELF,FRIENDS,PUBLIC_AUTHENTICATED'],
                'comment_policy' => ['sometimes', 'in:OFF,FRIENDS_ONLY,ALL_ELIGIBLE'],
                'confirm' => ['sometimes', 'accepted'],
                'request_key' => ['sometimes', 'uuid'],
                'cover_media_asset_id' => ['nullable', 'integer', 'exists:media_assets,id'],
            ]);

            $audience = $data['audience'] ?? PostAudience::FRIENDS;
            abort_if($audience === PostAudience::PUBLIC_AUTHENTICATED && ! isset($data['confirm']), 409, 'confirm public publication');
            abort_if($audience === PostAudience::SELF && isset($data['comment_policy']) && $data['comment_policy'] !== 'OFF', 422, 'SELF comments must be off');
            $key = isset($data['request_key']) ? strtolower($data['request_key']) : null;
            $hash = $key ? hash('sha256', json_encode([
                trim($data['title']), trim($data['body']), $audience, $data['comment_policy'] ?? null,
                isset($data['cover_media_asset_id']) ? (int) $data['cover_media_asset_id'] : null,
                trim($data['location_name'] ?? ''),
            ], JSON_THROW_ON_ERROR)) : null;
            if ($key) {
                $previous = StatusPost::where('author_user_id', $user->id)->where('request_key', $key)->lockForUpdate()->first();
                if ($previous) {
                    abort_unless($previous->request_hash === $hash && ! $previous->is_deleted, 409, 'publication changed or unavailable');
                    $fresh = $this->visibleStatusQueryForPost($previous->id, (int) $user->id, false)->firstOrFail();

                    return response()->json(['ok' => true, 'item' => $this->shapePost($fresh, (int) $user->id)]);
                }
            }

            // A public user work can carry an independently friends-only cover.
            // Never grant more than the author granted to the asset itself.
            $location = trim((string) ($data['location_name'] ?? ''));
            if ($location === '') {
                $location = trim((string) ($user?->city ?? ''));
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

                $isVideo = $coverAsset->media_type === 'video';
                if (! str_starts_with((string) $coverAsset->media_type, 'image') && ! $isVideo) {
                    return response()->json(['message' => 'main media must be an image or video'], 422);
                }

                if ($isVideo && (! in_array($coverAsset->storage_disk, ['v1009', 'v1011_relationship'], true)
                    || $coverAsset->status !== 'ready' || $coverAsset->mime_type !== 'video/mp4'
                    || ($coverAsset->metadata['validation'] ?? null) !== 'ffprobe-mp4-h264-v1'
                    || $coverAsset->size_bytes <= 0 || $coverAsset->size_bytes > 25 * 1024 * 1024
                    || $coverAsset->duration_ms <= 0 || $coverAsset->duration_ms > 30000)) {
                    return response()->json(['message' => 'ready validated private MP4 required'], 422);
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
                'audience' => $audience,
                'comment_policy' => $data['comment_policy'] ?? ($audience === PostAudience::SELF ? 'OFF' : 'FRIENDS_ONLY'),
                'comment_policy_source' => isset($data['comment_policy']) ? 'AUTHOR' : 'DEFAULT',
                'request_key' => $key,
                'request_hash' => $hash,
                'cover_audience' => $coverMediaAssetId ? ($audience === PostAudience::SELF ? PostAudience::SELF : PostAudience::FRIENDS) : null,
                'cover_original_viewer_ids' => $coverMediaAssetId && $audience !== PostAudience::SELF
                    ? app(PostAudience::class)->originalViewersLocked((int) $user->id, (int) $user->id) : null,
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

    public function publicationResult(Request $request, string $key): JsonResponse
    {
        $actor = (int) $request->user()->id;

        return DB::transaction(function () use ($actor, $key) {
            app(\App\Services\JourneyStore::class)->users([$actor]);
            $post = StatusPost::where('author_user_id', $actor)->where('request_key', strtolower($key))->lockForUpdate()->first();

            return response()->json(match (true) {
                $post === null => ['state' => 'NOT_APPLIED'],
                $post->is_deleted => ['state' => 'UNAVAILABLE'],
                default => ['state' => 'APPLIED', 'id' => (int) $post->id],
            });
        }, 3);
    }

    public function audience(Request $request, int $id, PostAudience $policy): JsonResponse
    {
        $data = $request->validate([
            'audience' => 'required|in:SELF,FRIENDS,PUBLIC_AUTHENTICATED',
            'comment_policy' => 'sometimes|in:OFF,FRIENDS_ONLY,ALL_ELIGIBLE',
            'confirm' => 'sometimes|accepted',
            'expected_revision' => 'sometimes|integer|min:1',
        ]);
        $actor = (int) $request->user()->id;

        return $policy->run($actor, $id, function (StatusPost $post) use ($request, $data, $actor, $policy) {
            abort_unless($actor === (int) $post->author_user_id, 404, 'unavailable');
            $target = $data['audience'];
            $expands = PostAudience::AUDIENCE_ORDER[$target] > (PostAudience::AUDIENCE_ORDER[$post->audience] ?? 0);
            $revision = (int) $post->audience_revision;
            $explicit = $data['comment_policy'] ?? null;
            abort_if($target === PostAudience::SELF && $explicit !== null && $explicit !== 'OFF', 422, 'SELF comments must be off');

            $source = $post->comment_policy_source;
            $next = $policy->commentPolicy($post);
            if ($explicit !== null) {
                $next = $explicit;
                $source = 'AUTHOR';
            } elseif ($target === PostAudience::SELF) {
                // Only an author-selected OFF survives narrowing as explicit OFF.
                $source = $source === 'AUTHOR' && $next === 'OFF' ? 'AUTHOR'
                    : ($source === null ? null : 'DEFAULT');
                $next = 'OFF';
            } elseif ($post->audience === PostAudience::SELF && $source === 'DEFAULT') {
                $next = 'FRIENDS_ONLY';
            }

            $preview = [
                'id' => (int) $post->id,
                'audience' => $target,
                'comment_policy' => $next,
                'audience_revision' => $revision,
                'expands' => $expands,
                'cover_keeps_original_audience' => (bool) $post->cover_media_asset_id,
                'cover_owner_only' => $post->cover_media_asset_id && ($target === PostAudience::SELF
                    || $post->cover_audience === PostAudience::SELF
                    || ($post->cover_audience === null && $target !== $post->audience)),
            ];
            if ($request->isMethod('GET')) {
                return response()->json($preview);
            }
            if ($expands || $explicit !== null || isset($data['expected_revision'])) {
                abort_unless(($data['confirm'] ?? false) && (int) ($data['expected_revision'] ?? 0) === $revision, 409, 'preview and confirm the current revision');
            }
            if ($post->audience !== $target || $explicit !== null) {
                if ($post->cover_media_asset_id && $post->cover_audience === null && $post->audience !== $target) {
                    // Pre-B covers have no original viewer snapshot.
                    $post->cover_audience = PostAudience::SELF;
                }
                $post->audience = $target;
                $post->comment_policy = $next;
                $post->comment_policy_source = $source;
                $post->audience_revision = ++$revision;
                $post->save();
            }

            return response()->json(array_replace($preview, ['audience_revision' => $revision]));
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
        // Pure candidate lookup outside the transaction: waiting for a user
        // lock must not preserve a pre-revocation REPEATABLE READ snapshot.
        $owner = StatusPost::whereKey($postId)->value('author_user_id');
        if ($owner === null) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        return DB::transaction(function () use ($request, $postId, $owner, $liked, $events, $notifications) {
            $users = User::whereIn('id', [$request->user()->id, $owner])->orderBy('id')->lockForUpdate()->get()->keyBy('id');
            $user = $users->get($request->user()->id);
            $author = $users->get($owner);
            $current = StatusPost::whereKey($postId)->lockForUpdate()->first();
            if (! $user || $user->disabled || ! $author || $author->disabled
                || ! $current || (int) $current->author_user_id !== (int) $owner || $current->is_deleted) {
                return response()->json(['message' => 'status post not found'], 404);
            }
            app(\App\Services\JourneyStore::class)->users([(int)$user->id,(int)$owner],true);
            abort_unless(app(\App\Services\PostAudience::class)->allowedLocked($current,(int)$user->id),404,'unavailable');
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
                    body: '请在当前权限允许时查看',
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
        return app(\App\Services\PostAudience::class)->run((int)$request->user()->id,$postId,function()use($request,$postId,$events){
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
        });
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
            $owner = (int) $post->author_user_id;
            $post = DB::transaction(function () use ($user, $postId, $owner, $data) {
                $users = User::whereIn('id', [$user->id, $owner])->orderBy('id')->lockForUpdate()->get()->keyBy('id');
                $actor = $users->get($user->id);
                abort_unless(app(AdminAccess::class)->allows($actor), 403);
                $locked = StatusPost::query()->whereKey($postId)->lockForUpdate()->firstOrFail();
                abort_unless((int) $locked->author_user_id === $owner, 404);
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
            // Serialize owner deletion with cover/interaction authorization,
            // audience edits, friendship revocation and account closure.
            $post = DB::transaction(function () use ($user, $postId) {
                $actor = User::whereKey($user->id)->lockForUpdate()->firstOrFail();
                app(\App\Services\JourneyStore::class)->users([(int)$user->id],true);
                abort_if($actor->disabled, 403);
                $locked = StatusPost::whereKey($postId)->where('author_user_id', $actor->id)->lockForUpdate()->firstOrFail();
                $locked->is_deleted = true;
                $locked->deleted_by_user_id = (int) $actor->id;
                $locked->deleted_at = now();
                $locked->save();

                return $locked;
            });
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
