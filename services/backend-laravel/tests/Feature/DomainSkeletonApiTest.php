<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\DatingMatch;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DomainSkeletonApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_conversation_and_media_skeleton_routes_are_available(): void
    {
        $user = User::create([
            'phone' => '13800000021',
            'name' => 'Skeleton',
            'password' => 'secret123',
        ]);
        $peer = User::create([
            'phone' => '13800000022',
            'name' => 'Peer',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('domain', 'conversation')
            ->assertJsonPath('items', [])
            ->assertJsonPath('total', 0)
            ->assertJsonPath('note', '4.0A conversation domain skeleton only');

        $match = DatingMatch::query()->create([
            'week_tag' => 'legacy-skeleton',
            'user_a' => $user->id,
            'user_b' => $peer->id,
            'drop_released' => true,
        ]);

        $eligible = $this->postJson('/api/v1/conversations', [
            'peer_user_id' => $peer->id,
            'title' => 'demo',
        ])->assertOk()
            ->assertJsonPath('domain', 'conversation')
            ->assertJsonPath('conversation.room_key', '1_2')
            ->assertJsonPath('conversation.entry_kind', 'eligible_match')
            ->assertJsonPath('conversation.conversation_id', null)
            ->assertJsonPath('conversation.peer_user_id', $peer->id);
        $this->assertDatabaseCount('conversations', 0);
        $this->assertDatabaseCount('conversation_members', 0);
        $this->assertDatabaseCount('conversation_match_links', 0);
        $this->assertDatabaseCount('chat_messages', 0);

        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $peer->id,
            'content' => 'first message',
        ])->assertOk()->assertJsonPath('idempotent_replay', false);
        $conversationId = (int) $send->json('conversation_id');

        $this->postJson('/api/v1/conversations', ['peer_user_id' => $peer->id])
            ->assertOk()
            ->assertJsonPath('conversation.entry_kind', 'conversation')
            ->assertJsonPath('conversation.conversation_id', $conversationId)
            ->assertJsonPath('conversation.match_id', $match->id);

        $this->getJson("/api/v1/conversations/{$conversationId}")
            ->assertOk()
            ->assertJsonPath('domain', 'conversation')
            ->assertJsonPath('conversation.room_key', '1_2')
            ->assertJsonPath('conversation.conversation_id', $conversationId);

        $this->getJson('/api/v1/media')
            ->assertOk()
            ->assertJsonPath('domain', 'media')
            ->assertJsonPath('states.0', 'pending');

        $mediaResponse = $this->postJson('/api/v1/media', [
            'media_type' => 'image',
            'original_name' => 'sample.png',
            'mime_type' => 'image/png',
        ])->assertOk()
            ->assertJsonPath('domain', 'media')
            ->assertJsonPath('asset.media_type', 'image');

        $assetId = (int) $mediaResponse->json('asset.id');

        $this->getJson("/api/v1/media/{$assetId}")
            ->assertOk()
            ->assertJsonPath('domain', 'media');

        $this->getJson('/api/v1/relationships')
            ->assertOk()
            ->assertJsonPath('total', 0);

        $this->postJson('/api/v1/relationships', [
            'subject_user_id' => $peer->id,
            'event_type' => 'follow',
        ])->assertOk()
            ->assertJsonPath('event.subject_user_id', $peer->id);

        $this->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonPath('total', 0)
            ->assertJsonPath('unread_total', 0);
    }
}
