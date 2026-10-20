<?php

namespace Tests\Feature;

use App\Jobs\ProcessMediaAssetJob;
use App\Models\MediaAsset;
use App\Models\RtcSession;
use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use App\Services\MediaCacheService;
use App\Services\RtcAuthorityService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class V1011RevocationTest extends TestCase
{
    use RefreshDatabase;

    public function test_stale_call_objects_do_not_overwrite_other_device_bindings(): void
    {
        $a = User::factory()->create(['phone' => '13880000001']);
        $b = User::factory()->create(['phone' => '13880000002']);
        $sessions = app(DeviceSessions::class);
        $one = $sessions->issue($a);
        $two = $sessions->issue($b);
        $other = $sessions->issue($a);
        $call = RtcSession::create(['call_key' => 'controlled-call', 'room_key' => 'controlled-room', 'initiator_user_id' => $a->id, 'peer_user_id' => $b->id, 'mode' => 'voice', 'status' => 'connecting', 'expires_at' => now()->addMinute(), 'metadata' => []]);
        $staleA = $call->fresh();
        $staleB = $call->fresh();
        $policy = app(RtcAuthorityService::class);
        $policy->bindDevice($staleA, $a->id, $one['session_id']);
        $policy->bindDevice($staleB, $b->id, $two['session_id']);
        $this->assertCount(2, $call->fresh()->metadata['device_sessions']);
        $sessions->revoke($a, $other['session_id']);
        $this->assertSame('connecting', $call->fresh()->status);
        $sessions->revoke($b, $two['session_id']);
        $this->assertSame('ended', $call->fresh()->status);
    }

    public function test_old_media_job_does_not_restore_deleted_asset_or_cache(): void
    {
        $u = User::factory()->create(['phone' => '13880000003']);
        $asset = MediaAsset::create(['owner_user_id' => $u->id, 'media_type' => 'image', 'storage_provider' => 'local', 'storage_disk' => 'v1011_relationship', 'storage_key' => 'erased/1', 'mime_type' => 'image/png', 'status' => 'deleted']);
        app()->call([new ProcessMediaAssetJob($asset->id), 'handle']);
        $this->assertSame('deleted', $asset->fresh()->status);
        $this->assertNull(Cache::get(app(MediaCacheService::class)->assetSnapshotKey($asset->id)));
    }

    public function test_refresh_only_credential_cannot_fetch_private_media(): void
    {
        $u = User::factory()->create(['phone' => '13880000004']);
        $s = app(DeviceSessions::class)->issue($u);
        $asset = MediaAsset::create(['owner_user_id' => $u->id, 'media_type' => 'image', 'storage_provider' => 'local', 'storage_disk' => 'v1011_relationship', 'storage_key' => 'fiction.png', 'status' => 'ready']);
        $this->withToken($s['refresh_token'])->get('/api/v1/media/'.$asset->id.'/content')->assertForbidden();
    }
}
