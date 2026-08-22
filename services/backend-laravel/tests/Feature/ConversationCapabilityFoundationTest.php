<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\Conversation;
use App\Models\ConversationMember;
use App\Models\ConversationMatchLink;
use App\Models\ChatMessage;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\ConversationCapabilityService;
use App\Services\ConversationDomainService;
use App\Services\ChatWebsocketAuthorizationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Database\QueryException;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ConversationCapabilityFoundationTest extends TestCase
{
    use RefreshDatabase;

    public function test_conversation_persists_append_only_match_link_history(): void
    {
        $actor = User::factory()->create(['phone' => 'link-a']);
        $peer = User::factory()->create(['phone' => 'link-b']);
        $otherPeer = User::factory()->create(['phone' => 'link-c']);
        $firstMatch = DatingMatch::query()->create(['week_tag' => 'link-1', 'user_a' => $actor->id, 'user_b' => $peer->id, 'drop_released' => true]);
        $secondMatch = DatingMatch::query()->create(['week_tag' => 'link-2', 'user_a' => $actor->id, 'user_b' => $peer->id, 'drop_released' => true]);
        $conversation = app(ConversationDomainService::class)->ensureDirectConversation($actor->id, $peer->id);
        $otherConversation = app(ConversationDomainService::class)->ensureDirectConversation($actor->id, $otherPeer->id);

        $this->assertDatabaseCount('conversation_match_links', 0);
        $firstLink = ConversationMatchLink::query()->create([
            'conversation_id' => $conversation->id,
            'dating_match_id' => $firstMatch->id,
            'linked_at' => now()->subMinute(),
        ]);
        $secondLink = ConversationMatchLink::query()->create([
            'conversation_id' => $conversation->id,
            'dating_match_id' => $secondMatch->id,
            'linked_at' => now(),
        ]);

        $this->assertDatabaseCount('conversation_match_links', 2);
        $this->assertSame($conversation->id, $firstLink->conversation->id);
        $this->assertSame($conversation->id, $secondLink->conversation->id);
        $this->assertCount(2, $conversation->fresh()->matchLinks);
        $this->assertSame($firstLink->id, $firstMatch->fresh()->conversationMatchLink->id);
        $this->assertInstanceOf(Carbon::class, $firstLink->linked_at);

        try {
            ConversationMatchLink::query()->create([
                'conversation_id' => $otherConversation->id,
                'dating_match_id' => $firstMatch->id,
                'linked_at' => now(),
            ]);
            $this->fail('A dating match must not link to two conversations.');
        } catch (QueryException $exception) {
            $this->assertStringContainsString('unique', strtolower($exception->getMessage()));
        }

        try {
            ConversationMatchLink::query()->create([
                'conversation_id' => $conversation->id,
                'dating_match_id' => $secondMatch->id,
                'linked_at' => now(),
            ]);
            $this->fail('A conversation and dating match link must not duplicate.');
        } catch (QueryException $exception) {
            $this->assertStringContainsString('unique', strtolower($exception->getMessage()));
        }

        $this->assertDatabaseCount('conversation_match_links', 2);
    }

    public function test_unmatched_creation_is_opaque_and_released_match_can_create(): void
    {
        $a = User::factory()->create(['phone' => 'cap-a']); $b = User::factory()->create(['phone' => 'cap-b']); Sanctum::actingAs($a);
        $this->postJson('/api/v1/conversations', ['peer_user_id' => $b->id])->assertNotFound()->assertJsonMissing(['peer_user_id' => $b->id]);
        DatingMatch::query()->create(['week_tag' => 'legacy', 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true]);
        $this->postJson('/api/v1/conversations', ['peer_user_id' => $b->id])
            ->assertOk()->assertJsonPath('conversation.conversation_id', null);
        $this->assertFalse(app(ConversationCapabilityService::class)->canWebSocket($a->id, $b->id));
        $this->assertDatabaseCount('conversations', 0);
    }

    public function test_block_denies_mutation_but_preserves_historical_read(): void
    {
        $a = User::factory()->create(['phone' => 'cap-a']); $b = User::factory()->create(['phone' => 'cap-b']);
        DatingMatch::query()->create(['week_tag' => 'legacy', 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true]);
        $conversation = app(ConversationDomainService::class)->ensureDirectConversation($a->id, $b->id);
        UserBlock::query()->create(['blocker_id' => $a->id, 'blocked_user_id' => $b->id]);
        $capability = app(ConversationCapabilityService::class)->evaluate($a->id, $b->id);
        $this->assertTrue($capability['can_read']);
        $this->assertFalse($capability['can_send']);
        $this->assertFalse($capability['can_ws']);
        Sanctum::actingAs($a);
        $this->getJson('/api/v1/conversations/'.$conversation->id)
            ->assertOk()
            ->assertJsonPath('conversation.entry_kind', 'conversation')
            ->assertJsonPath('conversation.conversation_id', $conversation->id)
            ->assertJsonPath('conversation.peer_user_id', $b->id);
        $this->postJson('/api/v1/messages', ['receiver_id' => $b->id, 'content' => 'not persisted'])->assertNotFound();
        $this->assertDatabaseMissing('chat_messages', ['sender_id' => $a->id, 'receiver_id' => $b->id]);
    }

    public function test_list_separates_stored_and_eligible_identity_without_creating_rows(): void
    {
        $actor = User::factory()->create(['phone' => 'identity-a']);
        $storedPeer = User::factory()->create(['phone' => 'identity-b']);
        $eligiblePeer = User::factory()->create(['phone' => 'identity-c']);
        $storedMatch = DatingMatch::query()->create(['week_tag' => 'stored', 'user_a' => $actor->id, 'user_b' => $storedPeer->id, 'drop_released' => true]);
        $olderEligibleMatch = DatingMatch::query()->create(['week_tag' => 'eligible-older', 'user_a' => $actor->id, 'user_b' => $eligiblePeer->id, 'drop_released' => true]);
        $eligibleMatch = DatingMatch::query()->create(['week_tag' => 'eligible-newer', 'user_a' => $actor->id, 'user_b' => $eligiblePeer->id, 'drop_released' => true]);
        $this->assertGreaterThan($olderEligibleMatch->id, $eligibleMatch->id);
        $conversation = app(ConversationDomainService::class)->ensureDirectConversation($actor->id, $storedPeer->id);
        $before = [Conversation::count(), ConversationMember::count(), ChatMessage::count(), ConversationMatchLink::count()];

        Sanctum::actingAs($actor);
        $response = $this->getJson('/api/v1/conversations')->assertOk();
        $items = collect($response->json('items'));
        $stored = $items->firstWhere('peer_user_id', $storedPeer->id);
        $eligible = $items->firstWhere('peer_user_id', $eligiblePeer->id);

        $this->assertSame('conversation', $stored['entry_kind']);
        $this->assertSame($conversation->id, $stored['conversation_id']);
        $this->assertSame((string) $storedPeer->id, $stored['id']);
        $this->assertSame('eligible_match', $eligible['entry_kind']);
        $this->assertNull($eligible['conversation_id']);
        $this->assertSame($eligibleMatch->id, $eligible['match_id']);
        $this->assertCount(1, $items->where('peer_user_id', $eligiblePeer->id));
        $this->assertCount(1, $items->where('peer_user_id', $storedPeer->id));
        $this->assertSame($before, [Conversation::count(), ConversationMember::count(), ChatMessage::count(), ConversationMatchLink::count()]);
        $this->assertNotNull($storedMatch->id);
    }

    public function test_object_and_peer_routes_have_distinct_identity_and_are_read_only(): void
    {
        $actor = User::factory()->create(['phone' => 'routes-a']);
        $peer = User::factory()->create(['phone' => 'routes-b']);
        $outsider = User::factory()->create(['phone' => 'routes-c']);
        $eligiblePeer = User::factory()->create(['phone' => 'routes-d']);
        DatingMatch::query()->create(['week_tag' => 'stored', 'user_a' => $actor->id, 'user_b' => $peer->id, 'drop_released' => true]);
        $eligibleMatch = DatingMatch::query()->create(['week_tag' => 'eligible', 'user_a' => $actor->id, 'user_b' => $eligiblePeer->id, 'drop_released' => true]);
        $conversation = app(ConversationDomainService::class)->ensureDirectConversation($actor->id, $peer->id);
        $before = [Conversation::count(), ConversationMember::count(), ChatMessage::count(), ConversationMatchLink::count()];

        Sanctum::actingAs($actor);
        $this->getJson('/api/v1/conversations/'.$conversation->id)
            ->assertOk()
            ->assertJsonPath('conversation.conversation_id', $conversation->id)
            ->assertJsonPath('conversation.peer_user_id', $peer->id);
        if ($peer->id !== $conversation->id) {
            $this->getJson('/api/v1/conversations/'.$peer->id)->assertNotFound();
        }
        $this->getJson('/api/v1/conversation-peers/'.$peer->id)
            ->assertOk()
            ->assertJsonPath('conversation.entry_kind', 'conversation')
            ->assertJsonPath('conversation.conversation_id', $conversation->id);
        $this->getJson('/api/v1/conversation-peers/'.$eligiblePeer->id)
            ->assertOk()
            ->assertJsonPath('conversation.entry_kind', 'eligible_match')
            ->assertJsonPath('conversation.conversation_id', null)
            ->assertJsonPath('conversation.match_id', $eligibleMatch->id);

        Sanctum::actingAs($outsider);
        $this->getJson('/api/v1/conversations/'.$conversation->id)
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation not found']);
        $this->assertSame($before, [Conversation::count(), ConversationMember::count(), ChatMessage::count(), ConversationMatchLink::count()]);
    }

    public function test_peer_denials_are_response_equivalent(): void
    {
        $a = User::factory()->create(['phone' => 'opaque-a']);
        $unmatched = User::factory()->create(['phone' => 'opaque-b']);
        $blocked = User::factory()->create(['phone' => 'opaque-c']);
        DatingMatch::query()->create(['week_tag' => 'legacy', 'user_a' => $a->id, 'user_b' => $blocked->id, 'drop_released' => true]);
        UserBlock::query()->create(['blocker_id' => $a->id, 'blocked_user_id' => $blocked->id]);
        Sanctum::actingAs($a);
        $responses = [
            $this->postJson('/api/v1/conversations', ['peer_user_id' => 999999]),
            $this->postJson('/api/v1/conversations', ['peer_user_id' => $unmatched->id]),
            $this->postJson('/api/v1/conversations', ['peer_user_id' => $blocked->id]),
        ];
        foreach ($responses as $response) $response->assertNotFound()->assertExactJson(['message' => 'conversation unavailable']);
        foreach ([999999, $unmatched->id, $blocked->id] as $peerId) {
            $this->postJson('/api/v1/messages', ['receiver_id' => $peerId, 'content' => 'opaque'])->assertNotFound()->assertExactJson(['message' => 'chat unavailable']);
        }
        foreach ([999999, $unmatched->id] as $peerId) {
            $this->getJson('/api/v1/messages?peer_id='.$peerId)->assertNotFound()->assertExactJson(['message' => 'chat unavailable']);
        }
    }

    public function test_websocket_authorization_requires_token_actor_peer_scope_and_live_capability(): void
    {
        config()->set('matching.foundation.websocket_capability_enabled', true);
        $a = User::factory()->create(['phone' => 'ws-a']); $b = User::factory()->create(['phone' => 'ws-b']);
        DatingMatch::query()->create(['week_tag' => 'legacy', 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true]);
        app(ConversationDomainService::class)->ensureDirectConversation($a->id, $b->id);
        $createdToken = $a->createToken('ws-test', ['chat:ws']);
        $plainToken = $createdToken->plainTextToken;
        $service = app(ChatWebsocketAuthorizationService::class);
        $this->assertNull($service->authorize('', $a->id, $b->id));
        $this->assertNull($service->authorize('Bearer '.$plainToken, $b->id, $a->id));
        $this->assertSame($a->id, $service->authorize('Bearer '.$plainToken, $a->id, $b->id)['actor_id']);
        $tokenId = $createdToken->accessToken->id;
        $this->assertTrue($service->reauthorize($tokenId, $a->id, $b->id));
        UserBlock::query()->create(['blocker_id' => $a->id, 'blocked_user_id' => $b->id]);
        $this->assertNull($service->authorize('Bearer '.$plainToken, $a->id, $b->id));
        UserBlock::query()->delete();
        $createdToken->accessToken->forceFill(['expires_at' => now()->subMinute()])->save();
        $this->assertNull($service->authorize('Bearer '.$plainToken, $a->id, $b->id));
        $this->assertFalse($service->reauthorize($tokenId, $a->id, $b->id));
        $createdToken->accessToken->delete();
        $this->assertFalse($service->reauthorize($tokenId, $a->id, $b->id));
    }

    public function test_websocket_gateway_is_default_off(): void
    {
        config()->set('matching.foundation.websocket_capability_enabled', false);
        $this->artisan('chat:ws')->assertFailed();
    }

    public function test_structured_send_authorization_selects_newest_match_and_denies_departed_members(): void
    {
        $actor = User::factory()->create(['phone' => 'structured-a']);
        $peer = User::factory()->create(['phone' => 'structured-b']);
        DatingMatch::query()->create([
            'week_tag' => 'structured-old', 'user_a' => $actor->id, 'user_b' => $peer->id,
            'drop_released' => true, 'released_at' => now()->subDay(),
        ]);
        $newest = DatingMatch::query()->create([
            'week_tag' => 'structured-new', 'user_a' => $actor->id, 'user_b' => $peer->id,
            'drop_released' => true, 'released_at' => now(),
        ]);

        $service = app(ConversationCapabilityService::class);
        $authorization = $service->authorizeSend($actor->id, $peer->id);
        $this->assertTrue($authorization['allowed']);
        $this->assertSame($newest->id, $authorization['dating_match_id']);
        $this->assertNull($authorization['conversation_id']);

        Sanctum::actingAs($actor);
        $this->postJson('/api/v1/messages', ['receiver_id' => $peer->id, 'content' => 'create'])
            ->assertOk();
        $member = ConversationMember::query()->where('user_id', $actor->id)->firstOrFail();
        $member->forceFill(['left_at' => now()])->save();
        $this->assertFalse($service->authorizeSend($actor->id, $peer->id)['allowed']);
        $this->postJson('/api/v1/messages', ['receiver_id' => $peer->id, 'content' => 'denied'])
            ->assertNotFound()->assertExactJson(['message' => 'chat unavailable']);
        $this->assertNotNull($member->fresh()->left_at);
        $this->assertDatabaseCount('chat_messages', 1);
    }
}
