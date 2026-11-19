<?php

namespace Tests\Feature;

use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

final class V2CommentAudienceTest extends TestCase
{
    use RefreshDatabase;

    public function test_legacy_unknown_audience_and_new_friend_do_not_inherit_comment_body(): void
    {
        config(['restoration.enabled' => true]);
        $owner = User::factory()->create(['phone' => 'phase-a-comment-owner']);
        $author = User::factory()->create(['phone' => 'phase-a-comment-author']);
        $newFriend = User::factory()->create(['phone' => 'phase-a-comment-new']);
        $friend = fn ($a, $b) => DB::table('friendships')->insert(['user_a' => min($a, $b), 'user_b' => max($a, $b),
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $friend($owner->id, $author->id);
        $post = StatusPost::create(['author_user_id' => $owner->id, 'title' => 'Fixture', 'body' => 'Fixture post',
            'visibility' => 'visible', 'audience' => 'FRIENDS', 'is_deleted' => false]);
        $legacy = (string) Str::uuid();
        DB::table('status_post_comments')->insert(['id' => $legacy, 'status_post_id' => $post->id,
            'author_id' => $author->id, 'body' => 'Legacy private body', 'state' => 'ACTIVE', 'revision' => 1,
            'idempotency_key' => 'legacy', 'created_at' => now(), 'updated_at' => now()]);
        $url = '/api/v1/status-posts/'.$post->id.'/comments';
        $this->actingAs($owner, 'sanctum')->getJson($url.'/'.$legacy)->assertNotFound();
        $id = $this->actingAs($author, 'sanctum')->postJson($url, ['body' => 'New private body',
            'idempotency_key' => 'new'])->assertCreated()->json('id');
        $this->actingAs($owner, 'sanctum')->getJson($url.'/'.$id)->assertOk()->assertJsonPath('body', 'New private body');
        $friend($owner->id, $newFriend->id);
        $this->actingAs($newFriend, 'sanctum')->getJson($url.'/'.$id)->assertNotFound();
        $this->getJson($url)->assertOk()->assertJsonCount(0, 'items')->assertJsonPath('meta.has_more', false);
        DB::table('friendships')->where('user_a', min($owner->id, $author->id))->where('user_b', max($owner->id, $author->id))->update(['state' => 'REMOVED']);
        $this->actingAs($author, 'sanctum')->getJson($url.'/'.$id)->assertNotFound();
    }
}
