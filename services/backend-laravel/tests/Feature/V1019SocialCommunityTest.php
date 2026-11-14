<?php

namespace Tests\Feature;

use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class V1019SocialCommunityTest extends TestCase
{
    use RefreshDatabase;

    private function people(): array
    {
        config(['restoration.enabled' => true]);
        return array_map(fn () => User::factory()->create(['is_synthetic' => true,
            'phone' => fake()->unique()->numerify('199########')]), range(1, 3));
    }

    private function friend(User $a, User $b): void
    {
        DB::table('friendships')->insert(['user_a' => min($a->id, $b->id), 'user_b' => max($a->id, $b->id),
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    }

    private function postFixture(User $author): StatusPost
    {
        return StatusPost::create(['author_user_id' => $author->id, 'title' => '好友动态',
            'body' => 'PRIVATE_FAVORITE_SENTINEL', 'audience' => 'FRIENDS', 'visibility' => 'private', 'is_deleted' => false]);
    }

    public function test_favorite_is_explicit_idempotent_private_and_reprojects_after_audience_loss(): void
    {
        [$a, $b, $other] = $this->people();
        $this->friend($a, $b);
        $post = $this->postFixture($a);
        $this->actingAs($b, 'sanctum')->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => true])->assertOk();
        $this->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => true])->assertOk();
        $this->assertDatabaseCount('status_post_favorites', 1);
        $this->assertDatabaseCount('notifications', 0);
        $this->getJson('/api/v1/status/favorites')->assertOk()->assertJsonPath('items.0.post.body', 'PRIVATE_FAVORITE_SENTINEL');
        $this->actingAs($other, 'sanctum')->getJson('/api/v1/status/favorites')->assertOk()->assertJsonCount(0, 'items');
        $this->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => true])->assertNotFound();
        $post->update(['audience' => 'SELF']);
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/status/favorites')->assertOk()
            ->assertJsonPath('items.0.available', false)->assertJsonPath('items.0.post', null)
            ->assertDontSee('PRIVATE_FAVORITE_SENTINEL');
        $this->getJson('/api/v1/status/posts/'.$post->id)->assertNotFound();
        $this->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => true])->assertNotFound();
        $this->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => false])->assertOk();
        $this->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => false])->assertOk();
        $this->assertDatabaseCount('status_post_favorites', 0);
    }

    public function test_author_and_favorites_have_stable_bounded_cursors_without_showcase_authority(): void
    {
        [$a, $b] = $this->people();
        $this->friend($a, $b);
        for ($i = 0; $i < 23; $i++) {
            $post = $this->postFixture($a);
            $this->actingAs($b, 'sanctum')->putJson('/api/v1/status/posts/'.$post->id.'/favorite', ['favorited' => true])->assertOk();
        }
        $page = $this->getJson('/api/v1/status/favorites')->assertOk()->assertJsonCount(20, 'items')->json();
        $tail = $this->getJson('/api/v1/status/favorites?cursor='.$page['meta']['next_cursor'])->assertOk()->assertJsonCount(3, 'items')->json();
        $this->assertEmpty(array_intersect(array_column($page['items'], 'favorite_id'), array_column($tail['items'], 'favorite_id')));
        $author = $this->getJson('/api/v1/status/authors/'.$a->id)->assertOk()->assertJsonCount(20, 'items')->json();
        $this->getJson('/api/v1/status/authors/'.$a->id.'?cursor='.$author['meta']['next_cursor'])->assertOk()->assertJsonCount(3, 'items');
        $this->getJson('/api/v1/status/favorites?limit=21')->assertStatus(422);
        $this->getJson('/api/v1/status/authors/'.$a->id.'?limit=21')->assertStatus(422);
        DB::table('friendships')->update(['state' => 'REVOKED']);
        $this->getJson('/api/v1/status/favorites')->assertOk()->assertJsonPath('items.0.post', null);
        $this->getJson('/api/v1/status/authors/'.$a->id)->assertNotFound();
    }

    public function test_contacts_are_purpose_limited_and_do_not_create_consent(): void
    {
        [$a, $b, $stranger] = $this->people();
        $this->friend($a, $b);
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/social/contacts?purpose=buddy_invite')->assertOk()->assertJsonCount(0, 'items');
        foreach ([$a, $b, $stranger] as $u) {
            DB::table('buddy_preferences')->insert(['user_id' => $u->id, 'enabled' => true, 'revision' => 1]);
        }
        $page = $this->getJson('/api/v1/social/contacts?purpose=buddy_invite')->assertOk()->assertJsonCount(1, 'items')
            ->assertJsonPath('items.0.peer_id', $b->id)->assertJsonPath('items.0.avatar', null)->json();
        $this->assertSame(['buddy_invite'], $page['items'][0]['allowed_actions']);
        $this->getJson('/api/v1/social/contacts?purpose=buddy_invite&query=not-present')->assertOk()->assertJsonCount(0, 'items');
        $this->getJson('/api/v1/social/contacts?purpose=chat')->assertOk()->assertJsonCount(0, 'items');
        $this->getJson('/api/v1/social/contacts?purpose=connection')->assertOk()->assertJsonCount(1, 'items');
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
        $this->getJson('/api/v1/social/contacts?purpose=directory')->assertStatus(422);
        DB::table('friendships')->update(['state' => 'REVOKED']);
        $this->getJson('/api/v1/social/contacts?purpose=buddy_invite')->assertOk()->assertJsonCount(0, 'items');
    }
}
