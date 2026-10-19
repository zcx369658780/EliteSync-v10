<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\MediaAsset;
use App\Models\StatusPost;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\MediaAssetService;
use App\Services\PrivateVideoValidator;
use App\Services\SocialPolicy;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Throwable;

class MediaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = MediaAsset::query()
            ->where('owner_user_id', $request->user()->id)
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'items' => $items,
            'total' => $items->count(),
            'states' => ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
        ]);
    }

    public function store(Request $request, MediaAssetService $service): JsonResponse
    {
        if (in_array(config('media.disk'), ['v1009', 'v1011_relationship'], true)) {
            abort_unless(app(LiveConsentService::class)->enabled(), 404);
        }
        if (app(LiveConsentService::class)->enabled()) {
            abort_unless(in_array(config('media.disk'), ['v1007', 'v1009', 'v1011_relationship'], true), 422, 'private media configuration required');
            $request->validate(['media_type' => 'required|in:image,video', 'file' => 'required|file', 'storage_key' => 'prohibited', 'public_url' => 'prohibited']);
            if ($request->input('media_type') === 'video') {
                abort_unless(in_array(config('media.disk'), ['v1009', 'v1011_relationship'], true), 422, 'private video configuration required');
            } else {
                $request->validate(['file' => 'required|image|max:5120']);
            }
        }
        $data = $request->validate([
            'media_type' => ['required', 'string', 'max:24'],
            'file' => ['nullable', 'file'],
            'original_name' => ['nullable', 'string', 'max:255'],
            'mime_type' => ['nullable', 'string', 'max:128'],
            'size_bytes' => ['nullable', 'integer', 'min:0'],
            'width' => ['nullable', 'integer', 'min:0'],
            'height' => ['nullable', 'integer', 'min:0'],
            'duration_ms' => ['nullable', 'integer', 'min:0'],
            'sha256' => ['nullable', 'string', 'size:64'],
            'storage_key' => ['nullable', 'string', 'max:255'],
            'public_url' => ['nullable', 'string', 'max:512'],
            'metadata' => ['nullable', 'array'],
        ]);

        if (app(LiveConsentService::class)->enabled() && $request->input('media_type') === 'video') {
            $data = array_merge($data, app(PrivateVideoValidator::class)->validate($request->file('file')));
        }

        try {
            if ($request->hasFile('file')) {
                $file = $request->file('file');
                $private = app(LiveConsentService::class)->enabled();
                $data['mime_type'] = (string) ($private ? $file?->getMimeType() : ($data['mime_type'] ?? $file?->getMimeType() ?? ''));
                $data['size_bytes'] = (int) ($private ? $file?->getSize() : ($data['size_bytes'] ?? $file?->getSize() ?? 0));

                $asset = $service->registerUploaded($request->user(), $file, $data);
            } else {
                $asset = $service->registerDraft($request->user(), $data);
            }
        } catch (Throwable $e) {
            Log::error('media_upload_failed', [
                'owner_user_id' => (int) $request->user()->id,
                'media_type' => (string) ($data['media_type'] ?? 'file'),
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'ok' => false,
                'domain' => 'media',
                'message' => 'media upload failed',
            ], 500);
        }

        Log::info('media_asset_saved', [
            'asset_id' => (int) $asset->id,
            'owner_user_id' => (int) $request->user()->id,
            'media_type' => (string) $asset->media_type,
            'storage_disk' => (string) $asset->storage_disk,
        ]);

        if (in_array((string) $asset->error_code, ['mime_not_allowed', 'upload_too_large'], true)) {
            return response()->json([
                'ok' => false,
                'domain' => 'media',
                'message' => (string) ($asset->error_message ?? 'media upload rejected'),
                'asset' => $asset,
                'states' => ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
            ], 422);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'asset' => $asset,
            'states' => ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
        ]);
    }

    public function show(Request $request, int $assetId): JsonResponse
    {
        $asset = MediaAsset::query()
            ->where('owner_user_id', $request->user()->id)
            ->find($assetId);

        if (! $asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'asset' => $asset,
        ]);
    }

    public function content(Request $request, int $assetId)
    {
        $asset = MediaAsset::query()->find($assetId);
        if ($asset && in_array($asset->storage_disk, ['v1007', 'v1009', 'v1011_relationship'], true)) {
            return $this->privateContent($request, $assetId, (int) $asset->owner_user_id);
        }

        if (! $asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        if ((int) $asset->owner_user_id !== (int) $request->user()?->id) {
            return response()->json(['message' => 'media asset unavailable'], 404);
        }
        if (! $asset->isBackingObjectAvailable()) {
            return response()->json([
                'message' => 'media asset unavailable',
            ], 404);
        }

        try {
            $disk = Storage::disk((string) $asset->storage_disk);
            $storageKey = (string) $asset->storage_key;

            if ($storageKey !== '') {
                $path = method_exists($disk, 'path') ? $disk->path($storageKey) : null;
                if (is_string($path) && $path !== '' && is_file($path)) {
                    return response()->file($path, [
                        'Content-Type' => (string) ($asset->mime_type ?? 'application/octet-stream'),
                        'Cache-Control' => $asset->storage_disk === 'v1007' ? 'private, no-store' : 'private, no-store',
                    ]);
                }

                if (method_exists($disk, 'response')) {
                    return $disk->response($storageKey, null, [
                        'Content-Type' => (string) ($asset->mime_type ?? 'application/octet-stream'),
                        'Cache-Control' => 'private, no-store',
                    ]);
                }
            }
        } catch (Throwable $e) {
            Log::warning('media_content_stream_failed', [
                'asset_id' => (int) $asset->id,
                'message' => $e->getMessage(),
            ]);
        }

        return response()->json([
            'message' => 'media asset unavailable',
        ], 404);
    }

    private function privateContent(Request $request, int $id, int $owner)
    {
        $viewer = auth('sanctum')->user();
        $service = app(LiveConsentService::class);
        if (! $viewer || ! $service->enabled()) {
            return response()->json(['message' => 'media asset unavailable'], 404);
        }

        return DB::transaction(function () use ($viewer, $service, $id, $owner) {
            // Discover all trusted participants before taking any user lock.
            $linked = ChatMessage::whereHas('attachments', fn ($q) => $q->where('media_asset_id', $id))->get(['sender_id', 'receiver_id']);
            $participants = $linked->flatMap(fn ($m) => [$m->sender_id, $m->receiver_id])
                ->push($viewer->id, $owner)->unique()->sort()->values()->all();
            $users = User::whereIn('id', $participants)->orderBy('id')->lockForUpdate()->get()->keyBy('id');
            if (! $users->get($viewer->id) || $users->get($viewer->id)->disabled || ! $users->get($owner) || $users->get($owner)->disabled) {
                return response()->json(['message' => 'media asset unavailable'], 404);
            }
            $allowed = $linked->isEmpty() && (int) $viewer->id === $owner;
            if (app(SocialPolicy::class)->pairAllowed((int) $viewer->id, $owner)) {
                $post = StatusPost::where('cover_media_asset_id', $id)->where('author_user_id', $owner)->where('is_deleted', false)->first();
                if ($post && ((int) $viewer->id === $owner || ($post->audience === 'FRIENDS' && app(SocialPolicy::class)->friendship((int) $viewer->id, $owner)))) {
                    $allowed = true;
                }
            }

            foreach ($linked as $m) {
                if ((int) $m->sender_id === (int) $viewer->id || (int) $m->receiver_id === (int) $viewer->id) {
                    $peer = (int) ($m->sender_id == $viewer->id ? $m->receiver_id : $m->sender_id);
                    $allowed = $allowed || ($service->gates((int) $viewer->id, $peer)['live_read_allowed'] ?? false);
                }
            }
            $asset = MediaAsset::whereKey($id)->lockForUpdate()->first();
            if (! $allowed || ! $asset || ! in_array($asset->storage_disk, ['v1007', 'v1009', 'v1011_relationship'], true)
                || (in_array($asset->storage_disk, ['v1009', 'v1011_relationship'], true) && $asset->status !== 'ready') || ! $asset->isBackingObjectAvailable()) {
                return response()->json(['message' => 'media asset unavailable'], 404);
            }
            $response = response()->file(Storage::disk($asset->storage_disk)->path($asset->storage_key), ['Content-Type' => $asset->mime_type, 'X-Content-Type-Options' => 'nosniff']);
            $response->setPrivate();
            $response->headers->set('Cache-Control', 'private, no-store, max-age=0');
            $response->headers->set('Accept-Ranges', 'bytes');
            $response->headers->set('Vary', 'Authorization, Cookie');

            return $response;
        });
    }
}
