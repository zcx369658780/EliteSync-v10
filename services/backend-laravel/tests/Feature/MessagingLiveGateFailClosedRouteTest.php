<?php

namespace Tests\Feature;

use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use App\Services\ConversationAtomicSendService;
use App\Services\ConversationDomainService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class MessagingLiveGateFailClosedRouteTest extends TestCase
{
    use RefreshDatabase;

    public function test_seven_private_routes_deny_before_private_reads_or_writes_including_replay(): void
    {
        $actor = User::create(['phone' => '90123457011', 'password' => 'synthetic123']);
        $peer = User::create(['phone' => '90123457012', 'password' => 'synthetic123']);
        DatingMatch::query()->create([
            'week_tag' => 'synthetic-route-guard',
            'user_a' => $actor->id,
            'user_b' => $peer->id,
            'drop_released' => true,
        ]);
        $domain = app(ConversationDomainService::class);
        $conversation = $domain->ensureDirectConversation($actor->id, $peer->id);
        $roomKey = $domain->roomKey($actor->id, $peer->id);
        $incoming = ChatMessage::query()->create([
            'room_id' => $roomKey,
            'sender_id' => $peer->id,
            'receiver_id' => $actor->id,
            'content' => 'synthetic private content',
            'is_read' => false,
        ]);
        $clientMessageId = '123e4567-e89b-42d3-a456-426614174011';
        $replayContent = 'synthetic replay content';
        ChatMessage::query()->create([
            'room_id' => $roomKey,
            'sender_id' => $actor->id,
            'receiver_id' => $peer->id,
            'content' => $replayContent,
            'client_message_id' => $clientMessageId,
            'request_fingerprint' => app(ConversationAtomicSendService::class)->fingerprint($peer->id, $replayContent, []),
        ]);

        $before = [
            'messages' => DB::table('chat_messages')->count(),
            'events' => DB::table('app_events')->count(),
            'notifications' => DB::table('notifications')->count(),
            'member_read_id' => DB::table('conversation_members')
                ->where('conversation_id', $conversation->id)->where('user_id', $actor->id)
                ->value('last_read_message_id'),
        ];
        Sanctum::actingAs($actor);

        $responses = [
            $this->getJson('/api/v1/messages?peer_id='.$peer->id),
            $this->postJson('/api/v1/messages', ['receiver_id' => $peer->id, 'content' => 'synthetic new content']),
            $this->postJson('/api/v1/messages/read/'.$incoming->id),
            $this->getJson('/api/v1/conversations'),
            $this->postJson('/api/v1/conversations', ['peer_user_id' => $peer->id]),
            $this->getJson('/api/v1/conversations/'.$conversation->id),
            $this->getJson('/api/v1/conversation-peers/'.$peer->id),
            $this->postJson('/api/v1/messages', [
                'receiver_id' => $peer->id,
                'content' => $replayContent,
                'client_message_id' => $clientMessageId,
            ], ['X-Live-Gate-Allowed' => 'true']),
        ];
        foreach ($responses as $response) {
            $response->assertNotFound()->assertExactJson(['message' => 'conversation unavailable']);
        }

        self::assertSame($before['messages'], DB::table('chat_messages')->count());
        self::assertSame($before['events'], DB::table('app_events')->count());
        self::assertSame($before['notifications'], DB::table('notifications')->count());
        self::assertSame($before['member_read_id'], DB::table('conversation_members')
            ->where('conversation_id', $conversation->id)->where('user_id', $actor->id)
            ->value('last_read_message_id'));
        self::assertFalse((bool) $incoming->fresh()->is_read);
        self::assertNull($incoming->fresh()->read_at);
    }

    public function test_websocket_stub_is_not_covered_by_private_route_guard(): void
    {
        $actor = User::create(['phone' => '90123457013', 'password' => 'synthetic123']);
        Sanctum::actingAs($actor);
        config()->set('matching.foundation.websocket_capability_enabled', false);

        $this->getJson('/api/v1/messages/ws/'.$actor->id)
            ->assertStatus(503)
            ->assertJsonPath('retry_safe', true);
    }
}
