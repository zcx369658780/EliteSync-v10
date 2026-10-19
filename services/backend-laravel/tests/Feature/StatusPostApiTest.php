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

class StatusPostApiTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(array $overrides = []): User
    {
        return User::create(array_merge([
            'name' => 'SmokeUser',
            'phone' => '17000000000',
            'password' => 'password',
            'role' => 'user',
            'account_type' => 'normal',
            'verify_status' => 'approved',
            'realname_verified' => true,
            'disabled' => false,
            'moderation_status' => 'normal',
            'is_synthetic' => false,
            'synthetic_batch' => null,
            'is_match_eligible' => true,
            'is_square_visible' => true,
            'exclude_from_metrics' => false,
            'banned_reason' => null,
            'birthday' => '1996-08-18',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ], $overrides));
    }

    public function test_store_list_and_delete_status_post(): void
    {
        $user = $this->makeUser([
            'phone' => '17000000001',
            'account_type' => 'test',
            'is_synthetic' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/status/posts', [
                'title' => '今晚想散步',
                'body' => '在南阳找个轻松话题开始聊天。',
                'audience' => 'SELF',
            ])
            ->assertCreated()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('item.title', '今晚想散步');

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/status/posts')
            ->assertOk()
            ->assertJsonPath('items.0.title', '今晚想散步')
            ->assertJsonPath('items.0.audience', 'SELF')
            ->assertJsonMissingPath('items.0.author.phone');

        $postId = (int) StatusPost::query()->firstOrFail()->id;

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/status/posts/{$postId}")
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->assertTrue((bool) StatusPost::query()->firstOrFail()->is_deleted);
    }

    public function test_admin_can_delete_any_status_post(): void
    {
        config(['app.admin_phones' => ['17000000099']]);
        $author = $this->makeUser(['phone' => '17000000002']);
        $admin = $this->makeUser([
            'phone' => '17000000099',
            'role' => 'admin',
            'account_type' => 'normal',
        ]);

        $post = StatusPost::create([
            'author_user_id' => (int) $author->id,
            'title' => '测试状态',
            'body' => '管理员可删除。',
            'location_name' => '南阳',
            'visibility' => 'public',
            'is_deleted' => false,
        ]);

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/v1/status/posts/{$post->id}", ['reason' => 'Reviewed public fixture', 'expected_revision' => 0, 'confirm' => true])
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->assertTrue((bool) $post->fresh()->is_deleted);
    }

    public function test_single_image_status_like_report_and_author_page_flow(): void
    {
        config([
            'app.url' => 'http://127.0.0.1:8012',
            'restoration.enabled' => true,
        ]);
        Storage::fake('v1011_relationship');

        $author = $this->makeUser([
            'phone' => '17000000003',
            'name' => 'Author',
        ]);
        $viewer = $this->makeUser([
            'phone' => '17000000004',
            'name' => 'Viewer',
        ]);

        DB::table('friendships')->insert(['user_a' => min($author->id, $viewer->id), 'user_b' => max($author->id, $viewer->id), 'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $asset = MediaAsset::create([
            'owner_user_id' => $author->id,
            'media_type' => 'image',
            'storage_provider' => 'local',
            'storage_disk' => 'v1011_relationship',
            'storage_key' => 'status-media/'.$author->id.'/cover.jpg',
            'original_name' => 'cover.jpg',
            'mime_type' => 'image/jpeg',
            'size_bytes' => 1024,
            'status' => 'ready',
            'public_url' => null,
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);
        Storage::disk('v1011_relationship')->put($asset->storage_key, 'cover-bytes');

        $expectedUrl = 'http://127.0.0.1:8012/api/v1/media/'.$asset->id.'/content';

        Sanctum::actingAs($author);
        $created = $this->postJson('/api/v1/status/posts', [
            'title' => '今晚想散步',
            'body' => '单图动态测试。',
            'audience' => 'FRIENDS',
            'cover_media_asset_id' => $asset->id,
        ])
            ->assertCreated()
            ->assertJsonPath('item.cover_media.public_url', $expectedUrl)
            ->json('item');

        $postId = (int) $created['id'];

        Sanctum::actingAs($viewer);
        $this->getJson('/api/v1/status/posts/'.$postId)
            ->assertOk()
            ->assertJsonPath('item.id', $postId)
            ->assertJsonPath('item.media.0', $expectedUrl);

        $content = $this->get('/api/v1/media/'.$asset->id.'/content')->assertOk();
        $this->assertSame('cover-bytes', file_get_contents($content->baseResponse->getFile()->getPathname()));

        $this->postJson('/api/v1/status/posts/'.$postId.'/likes')
            ->assertOk()
            ->assertJsonPath('item.likes_count', 1)
            ->assertJsonPath('item.liked_by_viewer', true);

        $this->deleteJson('/api/v1/status/posts/'.$postId.'/likes')
            ->assertOk()
            ->assertJsonPath('item.likes_count', 0)
            ->assertJsonPath('item.liked_by_viewer', false);

        $this->postJson('/api/v1/status/posts/'.$postId.'/report', [
            'reason_code' => 'spam',
            'detail' => 'demo report',
        ])
            ->assertOk()
            ->assertJsonPath('report.status', 'new');

        $this->assertDatabaseHas('moderation_reports', [
            'target_user_id' => $author->id,
            'target_status_post_id' => $postId,
            'category' => 'status_post',
            'reason_code' => 'spam',
        ]);

        $this->getJson('/api/v1/status/authors/'.$author->id)
            ->assertOk()
            ->assertJsonPath('author.id', $author->id)
            ->assertJsonPath('items.0.id', $postId);
    }

    public function test_blocked_author_is_filtered_from_status_feed(): void
    {
        $viewer = $this->makeUser([
            'phone' => '17000000005',
            'name' => 'Viewer2',
        ]);
        $author = $this->makeUser([
            'phone' => '17000000006',
            'name' => 'BlockedAuthor',
        ]);

        StatusPost::create([
            'author_user_id' => (int) $author->id,
            'title' => '被屏蔽状态',
            'body' => '应该不会出现在 viewer 流里。',
            'location_name' => '南阳',
            'visibility' => 'public',
            'is_deleted' => false,
        ]);

        UserBlock::create([
            'blocker_id' => $viewer->id,
            'blocked_user_id' => $author->id,
        ]);

        Sanctum::actingAs($viewer);
        $this->getJson('/api/v1/status/posts')
            ->assertOk()
            ->assertJsonCount(0, 'items');
    }

    public function test_missing_cover_preserves_status_post_and_reference_without_media_url(): void
    {
        Storage::fake('public');
        $author = $this->makeUser(['phone' => '17000000007']);
        $asset = MediaAsset::create([
            'owner_user_id' => $author->id,
            'media_type' => 'image',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'status-media/missing-cover.jpg',
            'status' => 'ready',
            'public_url' => 'http://localhost/storage/status-media/missing-cover.jpg',
        ]);
        $post = StatusPost::create([
            'author_user_id' => $author->id,
            'title' => '保留的动态',
            'body' => '封面丢失时正文仍可读。',
            'visibility' => 'public',
            'is_deleted' => false,
            'cover_media_asset_id' => $asset->id,
        ]);

        Sanctum::actingAs($author);
        $this->getJson('/api/v1/status/posts/'.$post->id)
            ->assertOk()
            ->assertJsonPath('item.id', $post->id)
            ->assertJsonPath('item.cover_media_asset_id', $asset->id)
            ->assertJsonPath('item.cover_media', [])
            ->assertJsonCount(0, 'item.media');
    }

    public function test_legacy_public_and_oss_assets_cannot_be_shared_and_old_posts_omit_media_urls(): void
    {
        $author = $this->makeUser(['phone' => '17000000008']);
        Sanctum::actingAs($author);
        foreach (['public', 'oss'] as $disk) {
            Storage::fake($disk);
            $legacyUrl = 'https://legacy.invalid/'.$disk.'/cover.jpg';
            $asset = MediaAsset::create([
                'owner_user_id' => $author->id, 'media_type' => 'image',
                'storage_provider' => $disk === 'oss' ? 'oss' : 'local',
                'storage_disk' => $disk, 'storage_key' => 'status-media/'.$disk.'-legacy-cover.jpg',
                'status' => 'ready', 'public_url' => $legacyUrl,
            ]);
            Storage::disk($disk)->put($asset->storage_key, 'legacy-cover-bytes');
            $before = StatusPost::count();
            $this->postJson('/api/v1/status/posts', [
                'title' => 'Rejected legacy cover', 'body' => 'Legacy asset remains retained.',
                'audience' => 'FRIENDS', 'cover_media_asset_id' => $asset->id,
            ])->assertStatus(422)->assertJsonPath('message', 'private cover media required');
            $this->assertSame($before, StatusPost::count());
            $this->assertDatabaseHas('media_assets', ['id' => $asset->id, 'storage_disk' => $disk, 'public_url' => $legacyUrl]);
            Storage::disk($disk)->assertExists($asset->storage_key);

            $post = StatusPost::create([
                'author_user_id' => $author->id, 'title' => 'Retained legacy post',
                'body' => 'Original content retained.', 'visibility' => 'public',
                'audience' => 'SELF', 'is_deleted' => false, 'cover_media_asset_id' => $asset->id,
            ]);
            $this->getJson('/api/v1/status/posts/'.$post->id)->assertOk()
                ->assertJsonPath('item.cover_media_asset_id', $asset->id)
                ->assertJsonPath('item.cover_media', [])->assertJsonCount(0, 'item.media')
                ->assertDontSee($legacyUrl, false);
            $this->assertDatabaseHas('status_posts', ['id' => $post->id, 'cover_media_asset_id' => $asset->id, 'is_deleted' => false]);
        }
    }
}
