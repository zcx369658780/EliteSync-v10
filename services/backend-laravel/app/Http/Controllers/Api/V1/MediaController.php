<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Services\MediaAssetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
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
        if(app(\App\Services\LiveConsentService::class)->enabled()){
            abort_unless(config('media.disk')==='v1007',422,'private media configuration required');
            $request->validate(['file'=>'required|image|max:5120','storage_key'=>'prohibited','public_url'=>'prohibited']);
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

        try {
            if ($request->hasFile('file')) {
                $file = $request->file('file');
                $private=app(\App\Services\LiveConsentService::class)->enabled();
                $data['mime_type'] = (string) ($private?$file?->getMimeType():($data['mime_type']??$file?->getMimeType()??''));
                $data['size_bytes'] = (int) ($private?$file?->getSize():($data['size_bytes']??$file?->getSize()??0));

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

        if (!$asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'asset' => $asset,
        ]);
    }

    public function content(Request $request,int $assetId)
    {
        $asset = MediaAsset::query()->find($assetId);
        if($asset && $asset->storage_disk==='v1007')return $this->privateContent($request,$assetId,(int)$asset->owner_user_id);

        if (!$asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        if (!$asset->isBackingObjectAvailable()) {
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
                        'Cache-Control' => $asset->storage_disk==='v1007'?'private, no-store':'public, max-age=300',
                    ]);
                }

                if (method_exists($disk, 'response')) {
                    return $disk->response($storageKey, null, [
                        'Content-Type' => (string) ($asset->mime_type ?? 'application/octet-stream'),
                        'Cache-Control' => 'public, max-age=300',
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

    private function privateContent(Request $request,int $id,int $owner)
    {
        $viewer=auth('sanctum')->user();$service=app(\App\Services\LiveConsentService::class);
        if(!$viewer||!$service->enabled())return response()->json(['message'=>'media asset unavailable'],404);
        return \Illuminate\Support\Facades\DB::transaction(function()use($viewer,$service,$id,$owner){
            // Discover all trusted participants before taking any user lock.
            $linked=\App\Models\ChatMessage::whereHas('attachments',fn($q)=>$q->where('media_asset_id',$id))->get(['sender_id','receiver_id']);
            $participants = $linked->flatMap(fn($m) => [$m->sender_id, $m->receiver_id])
                ->push($viewer->id, $owner)->unique()->sort()->values()->all();
            $users=\App\Models\User::whereIn('id',$participants)->orderBy('id')->lockForUpdate()->get()->keyBy('id');
            if(!$users->get($viewer->id)||$users->get($viewer->id)->disabled||!$users->get($owner)||$users->get($owner)->disabled)return response()->json(['message'=>'media asset unavailable'],404);
            $allowed=$linked->isEmpty()&&(int)$viewer->id===$owner;
            foreach($linked as$m){if((int)$m->sender_id===(int)$viewer->id||(int)$m->receiver_id===(int)$viewer->id){
                $peer=(int)($m->sender_id==$viewer->id?$m->receiver_id:$m->sender_id);
                $allowed=$allowed||($service->gates((int)$viewer->id,$peer)['live_read_allowed']??false);
            }}
            $asset=MediaAsset::whereKey($id)->lockForUpdate()->first();
            if(!$allowed||!$asset||!$asset->isBackingObjectAvailable())return response()->json(['message'=>'media asset unavailable'],404);
            $response=response()->file(Storage::disk('v1007')->path($asset->storage_key),['Content-Type'=>$asset->mime_type,'X-Content-Type-Options'=>'nosniff']);
            $response->setPrivate();$response->headers->set('Cache-Control','private, no-store');return $response;
        });
    }
}
