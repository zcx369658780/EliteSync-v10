<?php

namespace Tests\Feature;

use App\Jobs\ProcessMediaAssetJob;
use App\Models\MediaAsset;
use App\Models\MediaProcessingJob;
use App\Models\User;
use App\Services\MediaCacheService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MediaProcessingPipelineTest extends TestCase
{
    use RefreshDatabase;

    public function test_internal_media_processing_job_drives_pipeline_and_cache(): void
    {
        $user = User::create([
            'phone' => '13800000031',
            'name' => 'Media',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $register = $this->postJson('/api/v1/media', [
            'media_type' => 'image',
            'original_name' => 'demo.png',
            'mime_type' => 'image/png',
            'size_bytes' => 1024,
            'storage_key' => 'chat-media/demo.png',
            'public_url' => null,
            'metadata' => ['source' => 'test'],
        ])->assertOk()->json();

        $assetId = (int) $register['asset']['id'];

        ProcessMediaAssetJob::dispatchSync($assetId);

        $asset = MediaAsset::query()->findOrFail($assetId);
        $this->assertSame('ready', $asset->status);
        $this->assertNotNull($asset->processed_at);

        $this->assertDatabaseHas('media_processing_jobs', [
            'media_asset_id' => $assetId,
            'job_type' => 'normalize',
            'status' => 'succeeded',
        ]);

        $cache = app(MediaCacheService::class);
        $snapshot = cache()->get($cache->assetSnapshotKey($assetId));
        $this->assertIsArray($snapshot);
        $this->assertSame('ready', $snapshot['status']);
        $this->assertSame('oss', $snapshot['storage_provider']);
    }

    public function test_ordinary_process_demo_route_is_unavailable_without_processing_side_effect(): void
    {
        $user = User::create([
            'phone' => '13800000032',
            'name' => 'Media Route Containment',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $register = $this->postJson('/api/v1/media', [
            'media_type' => 'image',
            'original_name' => 'contained.png',
            'mime_type' => 'image/png',
            'size_bytes' => 1024,
            'storage_key' => 'chat-media/contained.png',
            'public_url' => null,
            'metadata' => ['source' => 'test'],
        ])->assertOk()->json();

        $assetId = (int) $register['asset']['id'];
        $assetBefore = MediaAsset::query()->findOrFail($assetId);
        $statusBefore = $assetBefore->status;
        $processedAtBefore = $assetBefore->processed_at;
        $normalizeJobsBefore = MediaProcessingJob::query()
            ->where('media_asset_id', $assetId)
            ->where('job_type', 'normalize')
            ->count();
        $cache = app(MediaCacheService::class);
        $snapshotBefore = cache()->get($cache->assetSnapshotKey($assetId));

        $this->postJson("/api/v1/media/{$assetId}/process-demo")
            ->assertNotFound();

        $assetAfter = MediaAsset::query()->findOrFail($assetId);
        $this->assertSame($statusBefore, $assetAfter->status);
        $this->assertEquals($processedAtBefore, $assetAfter->processed_at);
        $this->assertSame(
            $normalizeJobsBefore,
            MediaProcessingJob::query()
                ->where('media_asset_id', $assetId)
                ->where('job_type', 'normalize')
                ->count()
        );
        $this->assertSame($snapshotBefore, cache()->get($cache->assetSnapshotKey($assetId)));
    }
}
