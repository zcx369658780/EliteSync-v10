<?php

namespace Tests\Feature;

use App\Models\StatusPost;
use App\Models\MediaAsset;
use App\Models\AppNotificationItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

final class V2PhaseBContentTest extends TestCase
{
    use RefreshDatabase;

    public function test_creation_defaults_and_audience_expansion_requires_current_confirmed_preview(): void
    {
        config(['restoration.enabled' => true]);
        $owner = User::factory()->create(['phone' => (string) \Illuminate\Support\Str::uuid()]);
        $other = User::factory()->create(['phone' => (string) \Illuminate\Support\Str::uuid()]);
        $this->actingAs($owner, 'sanctum');
        $this->postJson('/api/v1/status/posts', ['title' => 'Default', 'body' => 'Body'])
            ->assertCreated()->assertJsonPath('item.audience', 'FRIENDS')
            ->assertJsonPath('item.comment_policy', 'FRIENDS_ONLY');
        $post = $this->postJson('/api/v1/status/posts', ['title' => 'Private', 'body' => 'Body', 'audience' => 'SELF'])
            ->assertCreated()->assertJsonPath('item.comment_policy', 'OFF')->json('item.id');
        $url = "/api/v1/status/posts/$post/audience";
        $this->putJson($url, ['audience' => 'FRIENDS'])->assertConflict();
        $this->getJson("$url?audience=FRIENDS")->assertOk()->assertJsonPath('comment_policy', 'FRIENDS_ONLY');
        $this->putJson($url, ['audience' => 'FRIENDS', 'confirm' => true, 'expected_revision' => 1])
            ->assertOk()->assertJsonPath('comment_policy', 'FRIENDS_ONLY');
        $this->putJson($url, ['audience' => 'PUBLIC_AUTHENTICATED', 'confirm' => true, 'expected_revision' => 1])->assertConflict();
        $this->putJson($url, ['audience' => 'PUBLIC_AUTHENTICATED', 'confirm' => true, 'expected_revision' => 2])->assertOk();
        $this->actingAs($other, 'sanctum')->getJson("/api/v1/status/posts/$post")->assertOk();
        $this->postJson("/api/v1/status-posts/$post/comments", ['body' => 'No access', 'idempotency_key' => 'stranger'])->assertForbidden();
    }

    public function test_explicit_and_unknown_self_off_are_preserved(): void
    {
        $owner = User::factory()->create(['phone' => (string) \Illuminate\Support\Str::uuid()]);
        $this->actingAs($owner, 'sanctum');
        $explicit = $this->postJson('/api/v1/status/posts', [
            'title' => 'Explicit', 'body' => 'Body', 'audience' => 'SELF', 'comment_policy' => 'OFF',
        ])->assertCreated()->json('item.id');
        $legacy = StatusPost::create(['author_user_id' => $owner->id, 'title' => 'Legacy',
            'body' => 'Body', 'audience' => 'SELF', 'visibility' => 'private']);
        foreach ([$explicit, $legacy->id] as $id) {
            $url = "/api/v1/status/posts/$id/audience";
            $this->getJson("$url?audience=FRIENDS")->assertOk()->assertJsonPath('comment_policy', 'OFF');
            $this->putJson($url, ['audience' => 'FRIENDS', 'confirm' => true, 'expected_revision' => 1])
                ->assertOk()->assertJsonPath('comment_policy', 'OFF');
        }
    }
    public function test_distinct_comment_controls_and_safe_independent_replies(): void
    {
        config(['restoration.enabled' => true]);
        [$owner, $author, $replyAuthor] = collect(range(1, 3))->map(
            fn () => User::factory()->create(['phone' => (string) Str::uuid()])
        );
        foreach ([$author, $replyAuthor] as $friend) {
            DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $friend->id,
                'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        }
        $post = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts',
            ['title' => 'Friends work', 'body' => 'Body'])->assertCreated()->json('item.id');
        $url = "/api/v1/status-posts/$post/comments";
        $parent = $this->actingAs($author, 'sanctum')->postJson($url,
            ['body' => 'Parent secret', 'idempotency_key' => 'parent'])->assertCreated()->json('id');
        $this->actingAs($replyAuthor, 'sanctum');
        $ordinary = $this->postJson($url, ['body' => 'Parent secret', 'parent_id' => $parent,
            'idempotency_key' => 'ordinary'])->assertCreated()->json('id');
        $safe = $this->postJson($url, ['independent_response' => 'THANKS', 'parent_id' => $parent,
            'idempotency_key' => 'safe'])->assertCreated()->json('id');
        $this->patchJson("$url/$parent/display", ['action' => 'HIDE', 'revision' => 1])->assertNotFound();
        $this->actingAs($owner, 'sanctum')->patchJson("$url/$parent/display", ['action' => 'HIDE', 'revision' => 1])
            ->assertOk()->assertJsonPath('state', 'UNAVAILABLE');
        $this->getJson("$url/$parent")->assertNotFound();
        $this->getJson("$url/$ordinary")->assertNotFound();
        $this->getJson("$url/$safe")->assertOk()->assertJsonPath('thread_context', 'UNAVAILABLE')
            ->assertJsonPath('parent_id', null)->assertJsonMissing(['body' => 'Parent secret']);
        $this->actingAs($author, 'sanctum')->getJson("$url/$parent")
            ->assertOk()->assertExactJson(['id' => $parent, 'state' => 'UNAVAILABLE', 'revision' => 2, 'can_withdraw' => true]);
        $this->patchJson("$url/$parent/display", ['action' => 'WITHDRAW', 'revision' => 2])->assertOk();
        $this->assertDatabaseHas('status_post_comments', ['id' => $parent, 'body' => 'Parent secret',
            'withdrawn' => true, 'hidden_by_owner' => true]);
        $this->actingAs($owner, 'sanctum')->putJson("$url/$safe/display", ['action' => 'HIDE', 'revision' => 1])->assertOk();
        $this->actingAs($replyAuthor, 'sanctum')->getJson("$url/$safe")->assertOk()
            ->assertJsonPath('can_withdraw', true)->assertJsonMissingPath('parent_id');
        $this->putJson("$url/$safe/display", ['action' => 'WITHDRAW', 'revision' => 2])->assertOk();
        $this->putJson("$url/$ordinary/display", ['action' => 'WITHDRAW', 'revision' => 1])->assertOk();
        $this->assertDatabaseHas('status_post_comments', ['id' => $ordinary, 'body' => 'Parent secret', 'withdrawn' => true]);
    }

    public function test_home_separates_official_guest_content_from_user_channels_and_search(): void
    {
        $owner = User::factory()->create(['phone' => (string) Str::uuid()]);
        $viewer = User::factory()->create(['phone' => (string) Str::uuid()]);
        $make = fn ($audience) => StatusPost::create(['author_user_id' => $owner->id,
            'title' => 'Searchable '.$audience, 'body' => 'Body', 'audience' => $audience, 'visibility' => 'private']);
        $friends = $make('FRIENDS');
        $public = $make('PUBLIC_AUTHENTICATED');
        $self = $make('SELF');
        config(['home_content.public_editorial' => [
            'permitted' => ['title' => 'Official fixture', 'body' => 'Official body', 'source_ref' => 'fixture-consent',
                'audience' => 'PUBLIC_EDITORIAL', 'guest_read_approved' => true, 'media' => ['private-thumb']],
            'unapproved' => ['title' => 'Unapproved fixture', 'body' => 'Secret', 'audience' => 'PUBLIC_EDITORIAL'],
        ], 'home_content.editor_recommendations' => [$friends->id, $self->id]]);
        $this->getJson('/api/v1/home/editorial')->assertOk()->assertJsonCount(1, 'items')
            ->assertJsonPath('items.0.title', 'Official fixture')->assertJsonMissingPath('items.0.media');
        $this->getJson('/api/v1/home/editorial/unapproved')->assertNotFound();
        $this->getJson('/api/v1/status/posts?channel=featured')->assertUnauthorized();
        $this->getJson('/api/v1/status/posts/'.$public->id)->assertUnauthorized();

        $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/status/posts?channel=featured&q=Searchable')
            ->assertOk()->assertJsonCount(1, 'items')->assertJsonPath('items.0.id', $public->id);
        DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $viewer->id,
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $this->getJson('/api/v1/status/posts?channel=featured')->assertOk()
            ->assertJsonCount(2, 'items')->assertJsonPath('items.1.id', $friends->id)
            ->assertJsonPath('items.1.editor_recommended', true);
        $this->getJson('/api/v1/status/posts?channel=friends')->assertOk()
            ->assertJsonCount(1, 'items')->assertJsonPath('items.0.id', $friends->id);
        DB::table('user_blocks')->insert(['blocker_id' => $owner->id, 'blocked_user_id' => $viewer->id, 'created_at' => now()]);
        $this->getJson('/api/v1/status/posts?channel=featured&q=Searchable')->assertOk()->assertJsonCount(0, 'items');
        $this->getJson('/api/v1/status/posts/'.$public->id)->assertNotFound();
    }

    public function test_publication_result_lookup_is_private_and_same_key_cannot_duplicate(): void
    {
        $owner = User::factory()->create(['phone' => (string) Str::uuid()]);
        $other = User::factory()->create(['phone' => (string) Str::uuid()]);
        $key = (string) Str::uuid();
        $result = "/api/v1/status/posts/command-result/$key";
        $this->actingAs($owner, 'sanctum')->getJson($result)->assertOk()->assertJsonPath('state', 'NOT_APPLIED');
        $body = ['title' => 'Lost response', 'body' => 'Once only', 'request_key' => $key];
        $id = $this->postJson('/api/v1/status/posts', $body)->assertCreated()->json('item.id');
        $this->getJson($result)->assertOk()->assertJsonPath('state', 'APPLIED')->assertJsonPath('id', $id);
        $this->postJson('/api/v1/status/posts', $body)->assertOk()->assertJsonPath('item.id', $id);
        $this->postJson('/api/v1/status/posts', array_replace($body, ['title' => 'Different']))->assertConflict();
        $this->actingAs($other, 'sanctum')->getJson($result)->assertOk()->assertJsonPath('state', 'NOT_APPLIED')
            ->assertJsonMissingPath('id');
        $this->assertDatabaseCount('status_posts', 1);
    }

    public function test_public_body_never_expands_old_cover_comment_or_notification_authority(): void
    {
        config(['restoration.enabled' => true]);
        Storage::fake('v1011_relationship');
        [$owner, $oldFriend, $newFriend] = collect(range(1, 3))->map(
            fn () => User::factory()->create(['phone' => (string) Str::uuid()])
        );
        $addFriend = fn ($peer) => DB::table('friendships')->insert([
            'user_a' => $owner->id, 'user_b' => $peer->id, 'state' => 'ACTIVE',
            'revision' => 1, 'created_at' => now(), 'updated_at' => now(),
        ]);
        $addFriend($oldFriend);
        $cover = MediaAsset::create([
            'owner_user_id' => $owner->id, 'media_type' => 'image', 'storage_provider' => 'local',
            'storage_disk' => 'v1011_relationship', 'storage_key' => 'phase-b/cover.jpg',
            'status' => 'ready', 'mime_type' => 'image/jpeg', 'size_bytes' => 5, 'original_name' => 'cover.jpg',
        ]);
        Storage::disk('v1011_relationship')->put($cover->storage_key, 'cover');
        $postId = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts', [
            'title' => 'Private cover', 'body' => 'Body', 'cover_media_asset_id' => $cover->id,
        ])->assertCreated()->json('item.id');
        $url = "/api/v1/status/posts/$postId";
        $comments = "/api/v1/status-posts/$postId/comments";
        $bytes = "/api/v1/media/$cover->id/content";
        $comment = $this->actingAs($oldFriend, 'sanctum')->postJson($comments, [
            'body' => 'Old comment', 'idempotency_key' => 'old',
        ])->assertCreated()->json('id');
        $this->getJson("$comments/command-result?request_key=old")->assertOk()->assertJsonPath('state', 'APPLIED');
        $this->get($bytes)->assertOk();
        $notice = AppNotificationItem::where('kind', 'status_comment')->firstOrFail();
        $noticeUrl = "/api/v1/notifications/$notice->id";
        $this->actingAs($owner, 'sanctum')->getJson($noticeUrl)->assertOk()->assertJsonPath('item.payload.status_post_id', $postId);
        $this->putJson("$url/audience", ['audience' => 'PUBLIC_AUTHENTICATED',
            'comment_policy' => 'ALL_ELIGIBLE', 'confirm' => true, 'expected_revision' => 1])->assertOk();
        $this->actingAs($newFriend, 'sanctum')->getJson($url)
            ->assertOk()->assertHeader('Cache-Control', 'no-store, private')
            ->assertJsonPath('item.cover_media_asset_id', null)->assertJsonPath('item.media', []);
        $this->get($bytes)->assertNotFound();
        $this->postJson("$url/likes")->assertOk();
        $this->postJson("$url/likes")->assertOk();
        $this->assertSame(1, AppNotificationItem::where('kind', 'status_like')->count());
        $newLike = AppNotificationItem::where('kind', 'status_like')->firstOrFail();
        $this->actingAs($owner, 'sanctum')->getJson("/api/v1/notifications/$newLike->id")
            ->assertOk()->assertJsonPath('item.payload.status_post_id', $postId);
        $this->actingAs($newFriend, 'sanctum')->deleteJson("$url/likes")->assertOk();
        $this->actingAs($owner, 'sanctum')->getJson("/api/v1/notifications/$newLike->id")
            ->assertOk()->assertJsonPath('item.payload', []);
        $this->actingAs($newFriend, 'sanctum');
        $addFriend($newFriend);
        $this->get($bytes)->assertNotFound();
        $this->getJson("$comments/$comment")->assertNotFound();
        $this->getJson("$comments/command-result?request_key=old")->assertOk()->assertJsonPath('state', 'NOT_APPLIED');
        $new = $this->postJson($comments, ['body' => 'New public context', 'idempotency_key' => 'new'])
            ->assertCreated()->json('id');
        $later = User::factory()->create(['phone' => (string) Str::uuid()]);
        $this->actingAs($later, 'sanctum')->getJson($url)->assertOk();
        $this->getJson("$comments/$new")->assertNotFound();
        $this->actingAs($owner, 'sanctum')->getJson("$comments/$new")->assertOk();
        $this->putJson("$comments/$comment/display", ['action' => 'HIDE', 'revision' => 1])->assertOk();
        $this->getJson($noticeUrl)->assertOk()->assertJsonPath('item.payload', []);
        $this->putJson("$url/audience", ['audience' => 'PUBLIC_AUTHENTICATED',
            'comment_policy' => 'OFF', 'confirm' => true, 'expected_revision' => 2])->assertOk();
        $this->getJson("$comments/$new")->assertOk()->assertJsonPath('can_reply', false);
    }

    public function test_rollback_hides_new_display_controls_and_public_history_from_phase_a_readers(): void
    {
        $owner = User::factory()->create(['phone' => (string) Str::uuid()]);
        $post = StatusPost::create(['author_user_id' => $owner->id, 'title' => 'Rollback',
            'body' => 'Body', 'audience' => 'PUBLIC_AUTHENTICATED', 'visibility' => 'private']);
        $hidden = (string) Str::uuid();
        DB::table('status_post_comments')->insert([
            'id' => $hidden, 'status_post_id' => $post->id, 'author_id' => $owner->id,
            'body' => 'Preserved content', 'state' => 'ACTIVE', 'hidden_by_owner' => true,
            'original_audience' => 'PUBLIC_AUTHENTICATED', 'original_viewer_ids' => json_encode([$owner->id]),
            'revision' => 1, 'idempotency_key' => 'rollback', 'created_at' => now(), 'updated_at' => now(),
        ]);

        foreach (['2026_11_20_110000_add_status_publication_command_receipts',
            '2026_11_20_100000_add_comment_display_controls', '2026_11_20_090000_add_status_post_content_authority'] as $migration) {
            (require database_path("migrations/$migration.php"))->down();
        }
        $this->assertDatabaseHas('status_posts', ['id' => $post->id, 'audience' => 'SELF']);
        $this->assertDatabaseHas('status_post_comments', ['id' => $hidden, 'state' => 'HIDDEN',
            'original_viewer_ids' => null, 'body' => 'Preserved content']);
    }

    public function test_only_independent_cover_grants_can_open_a_reused_asset(): void
    {
        config(['restoration.enabled' => true]);
        Storage::fake('v1011_relationship');
        [$owner, $friend] = collect(range(1, 2))->map(fn () => User::factory()->create(['phone' => (string) Str::uuid()]));
        $cover = MediaAsset::create(['owner_user_id' => $owner->id, 'media_type' => 'image',
            'storage_provider' => 'local', 'storage_disk' => 'v1011_relationship', 'storage_key' => 'phase-b/old.jpg',
            'status' => 'ready', 'mime_type' => 'image/jpeg', 'size_bytes' => 5, 'original_name' => 'old.jpg']);
        Storage::disk('v1011_relationship')->put($cover->storage_key, 'cover');
        $legacy = StatusPost::create(['author_user_id' => $owner->id, 'title' => 'Legacy', 'body' => 'Body',
            'audience' => 'FRIENDS', 'visibility' => 'private', 'cover_media_asset_id' => $cover->id]);
        DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $friend->id,
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $mediaUrl = "/api/v1/media/$cover->id/content";
        $this->actingAs($friend, 'sanctum')->getJson("/api/v1/status/posts/$legacy->id")
            ->assertOk()->assertJsonPath('item.cover_media_asset_id', null);
        $this->get($mediaUrl)->assertNotFound();
        $new = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts', [
            'title' => 'New explicit attachment', 'body' => 'Body', 'cover_media_asset_id' => $cover->id,
        ])->assertCreated()->json('item.id');
        $this->actingAs($friend, 'sanctum')->getJson("/api/v1/status/posts/$new")
            ->assertOk()->assertJsonPath('item.cover_media_asset_id', $cover->id);
        $this->get($mediaUrl)->assertOk();
        $this->actingAs($owner, 'sanctum')->putJson("/api/v1/status/posts/$new/audience", ['audience' => 'SELF'])->assertOk();
        $this->actingAs($friend, 'sanctum')->get($mediaUrl)->assertNotFound();
    }

    public function test_comment_pagination_counts_only_currently_readable_rows_across_batches(): void
    {
        [$owner, $viewer, $blocked] = collect(range(1, 3))->map(fn () => User::factory()->create(['phone' => (string) Str::uuid()]));
        $post = StatusPost::create(['author_user_id' => $owner->id, 'title' => 'Thread', 'body' => 'Body',
            'audience' => 'PUBLIC_AUTHENTICATED', 'visibility' => 'private']);
        DB::table('user_blocks')->insert(['blocker_id' => $blocked->id, 'blocked_user_id' => $viewer->id, 'created_at' => now()]);
        for ($i = 0; $i < 61; $i++) {
            DB::table('status_post_comments')->insert([
                'id' => (string) Str::uuid(), 'status_post_id' => $post->id,
                'author_id' => $i < 40 ? $blocked->id : $owner->id, 'body' => $i < 40 ? 'Restricted' : "Visible $i",
                'state' => 'ACTIVE', 'idempotency_key' => "row-$i", 'original_audience' => 'PUBLIC_AUTHENTICATED',
                'original_viewer_ids' => json_encode([$viewer->id]), 'created_at' => now()->addSeconds($i), 'updated_at' => now(),
            ]);
        }
        $this->actingAs($viewer, 'sanctum')->getJson("/api/v1/status-posts/$post->id/comments")
            ->assertOk()->assertJsonCount(20, 'items')->assertJsonPath('items.0.body', 'Visible 40')
            ->assertJsonPath('meta.next_cursor', '20')->assertJsonMissing(['body' => 'Restricted']);
        $this->getJson("/api/v1/status-posts/$post->id/comments?cursor=20")->assertOk()
            ->assertJsonCount(1, 'items')->assertJsonPath('items.0.body', 'Visible 60')->assertJsonPath('meta.has_more', false);
    }

    public function test_author_can_withdraw_own_known_comment_without_regaining_post_read_access(): void
    {
        [$owner, $author, $viewer] = collect(range(1, 3))->map(fn () => User::factory()->create(['phone' => (string) Str::uuid()]));
        foreach ([$author, $viewer] as $friend) {
            DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $friend->id,
                'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        }
        $post = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts',
            ['title' => 'Friends work', 'body' => 'Body'])->assertCreated()->json('item.id');
        $url = "/api/v1/status-posts/$post/comments";
        $comment = $this->actingAs($author, 'sanctum')->postJson($url, [
            'body' => 'Own words', 'idempotency_key' => 'withdrawal',
        ])->assertCreated()->json('id');
        DB::table('friendships')->where('user_a', $owner->id)->where('user_b', $author->id)
            ->update(['state' => 'REVOKED']);
        $this->actingAs($viewer, 'sanctum')->getJson("$url/$comment")->assertOk();
        $this->actingAs($author, 'sanctum')->getJson("$url/$comment")->assertNotFound();
        $this->putJson("$url/$comment/display", ['action' => 'WITHDRAW', 'revision' => 1])->assertOk()
            ->assertExactJson(['id' => $comment, 'state' => 'UNAVAILABLE', 'revision' => 2]);
        $this->getJson("/api/v1/status/posts/$post")->assertNotFound();
        $this->actingAs($viewer, 'sanctum')->getJson("$url/$comment")->assertNotFound();
    }

}
