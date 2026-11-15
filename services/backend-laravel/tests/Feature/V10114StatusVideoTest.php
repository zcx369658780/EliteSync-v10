<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\StatusPost;
use App\Models\User;
use App\Models\UserBlock;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V10114StatusVideoTest extends TestCase
{
    use RefreshDatabase;

    private function asset(User $owner, array $overrides = []): MediaAsset
    {
        $key = 'status/'.\Illuminate\Support\Str::uuid().'.mp4';
        Storage::disk('v1009')->put($key, 'test-video-range-bytes');
        return MediaAsset::create(array_replace([
            'owner_user_id' => $owner->id,
            'media_type' => 'video',
            'mime_type' => 'video/mp4',
            'storage_disk' => 'v1009',
            'storage_provider' => 'local',
            'storage_key' => $key,
            'status' => 'ready',
            'size_bytes' => 21,
            'duration_ms' => 2500,
            'metadata' => ['validation' => 'ffprobe-mp4-h264-v1'],
        ], $overrides));
    }

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'media.disk' => 'v1009']);
        Storage::fake('v1009');
    }

    public function test_video_post_uses_existing_single_media_and_current_audience(): void
    {
        [$author, $friend, $outsider] = User::factory()->count(3)->sequence(['phone' => '19900114001'], ['phone' => '19900114002'], ['phone' => '19900114003'])->create(['disabled' => false])->all();
        DB::table('friendships')->insert(['user_a' => min($author->id, $friend->id),
            'user_b' => max($author->id, $friend->id), 'state' => 'ACTIVE', 'revision' => 1,
            'created_at' => now(), 'updated_at' => now()]);
        $asset = $this->asset($author);
        Sanctum::actingAs($author);
        $postId = $this->postJson('/api/v1/status/posts', ['title' => 'Quiet water',
            'body' => 'Original QA caption', 'audience' => 'FRIENDS', 'cover_media_asset_id' => $asset->id])
            ->assertCreated()->assertJsonPath('item.cover_media.media_type', 'video')
            ->json('item.id');
        Sanctum::actingAs($friend);
        $this->getJson('/api/v1/status/posts/'.$postId)->assertOk();
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertStatus(206);
        Sanctum::actingAs($outsider);
        $this->getJson('/api/v1/status/posts/'.$postId)->assertNotFound();
        $this->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
        Sanctum::actingAs($author);
        $this->putJson('/api/v1/status/posts/'.$postId.'/audience', ['audience' => 'SELF'])->assertOk();
        Sanctum::actingAs($friend);
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertNotFound();
        Sanctum::actingAs($author);
        $this->putJson('/api/v1/status/posts/'.$postId.'/audience', ['audience' => 'FRIENDS'])->assertOk();
        Sanctum::actingAs($friend);
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertStatus(206);
        Sanctum::actingAs($author);
        $this->deleteJson('/api/v1/status/posts/'.$postId)->assertOk();
        Sanctum::actingAs($friend);
        $this->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertNotFound();
    }

    public function test_only_owned_ready_verified_private_video_can_be_published(): void
    {
        $author = User::factory()->create(['phone' => '19900114006', 'disabled' => false]);
        $other = User::factory()->create(['phone' => '19900114007', 'disabled' => false]);
        Sanctum::actingAs($author);
        foreach ([['status' => 'uploaded'], ['metadata' => []], ['storage_disk' => 'v1007'],
            ['mime_type' => 'video/webm'], ['owner_user_id' => $other->id], ['duration_ms' => 30001],
            ['size_bytes' => 26 * 1024 * 1024], ['media_type' => 'audio']] as $invalid) {
            $asset = $this->asset($author, $invalid);
            $this->postJson('/api/v1/status/posts', ['title' => 'Invalid asset', 'body' => 'QA',
                'audience' => 'SELF', 'cover_media_asset_id' => $asset->id])->assertUnprocessable();
        }
        $this->assertDatabaseCount('status_posts', 0);
    }

    public function test_video_media_is_denied_after_block_or_account_disable(): void
    {
        [$author, $friend] = User::factory()->count(2)->sequence(['phone' => '19900114004'], ['phone' => '19900114005'])->create(['disabled' => false])->all();
        DB::table('friendships')->insert(['user_a' => min($author->id, $friend->id),
            'user_b' => max($author->id, $friend->id), 'state' => 'ACTIVE', 'revision' => 1,
            'created_at' => now(), 'updated_at' => now()]);
        $asset = $this->asset($author);
        StatusPost::create(['author_user_id' => $author->id, 'cover_media_asset_id' => $asset->id,
            'title' => 'QA', 'body' => 'QA', 'audience' => 'FRIENDS', 'visibility' => 'private']);
        Sanctum::actingAs($friend);
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertStatus(206);
        $block = UserBlock::create(['blocker_id' => $author->id, 'blocked_user_id' => $friend->id]);
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertNotFound();
        $block->delete();
        $author->forceFill(['disabled' => true])->save();
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertNotFound();
    }
}
