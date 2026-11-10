<?php

namespace Tests\Feature;

use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Testing\TestResponse;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007LiveConsentTest extends TestCase
{
    use RefreshDatabase;
    use \Tests\Support\CreatesAcceptedMainMatch;

    private User $a;

    private User $b;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true]);
        $this->a = User::factory()->create(['phone' => '19900000702', 'disabled' => false, 'is_synthetic' => false]);
        $this->b = User::factory()->create(['phone' => '19900000703', 'disabled' => false, 'is_synthetic' => false]);
        $this->createAcceptedMatchContext($this->a, $this->b);
        Sanctum::actingAs($this->a);
    }

    private function act(string $kind, string $action, int $revision, User $actor): TestResponse
    {
        Sanctum::actingAs($actor);
        $peer = $actor->id === $this->a->id ? $this->b->id : $this->a->id;

        return $this->postJson('/api/v1/connections/'.$peer.'/'.$kind, [
            'peer_id' => $actor->id === $this->a->id ? $this->b->id : $this->a->id,
            'action' => $action, 'expected_revision' => $revision,
        ]);
    }

    private function active(): void
    {
        $this->act('connection', 'request', 0, $this->a)->assertOk()->assertJsonPath('connection.state', 'CN_PENDING');
        $this->act('connection', 'accept', 1, $this->b)->assertOk()->assertJsonPath('connection.state', 'CN_ACTIVE');
        $this->act('consent', 'request', 0, $this->a)->assertOk()->assertJsonPath('consent.state', 'MC_PENDING');
        $this->act('consent', 'accept', 1, $this->b)->assertOk()->assertJsonPath('consent.state', 'MC_ACTIVE');
    }

    public function test_match_alone_and_single_party_do_not_grant_messages(): void
    {
        $this->getJson('/api/v1/messages?peer_id='.$this->b->id)->assertNotFound();
        $this->act('connection', 'request', 0, $this->a)->assertOk();
        $this->act('connection', 'accept', 1, $this->a)->assertStatus(409);
        $this->act('connection', 'accept', 0, $this->b)->assertStatus(409);
        $this->act('connection', 'accept', 1, $this->b)->assertOk();
        $this->getJson('/api/v1/messages?peer_id='.$this->a->id)->assertNotFound();
        $this->act('consent', 'request', 0, $this->a)->assertOk();
        $this->getJson('/api/v1/messages?peer_id='.$this->b->id)->assertNotFound();
    }

    public function test_legal_send_replay_read_and_revocation_check_current_server_state(): void
    {
        $this->active();
        Sanctum::actingAs($this->a);
        $payload = ['receiver_id' => $this->b->id, 'content' => 'v1007 text', 'client_message_id' => '123e4567-e89b-42d3-a456-426614174100'];
        $sent = $this->postJson('/api/v1/messages', $payload)->assertOk();
        $this->postJson('/api/v1/messages', $payload)->assertOk()->assertJsonPath('idempotent_replay', true);
        Sanctum::actingAs($this->b);
        $this->getJson('/api/v1/messages?peer_id='.$this->a->id)->assertOk()->assertJsonPath('items.0.content', 'v1007 text');
        $this->assertTrue(ChatMessage::find($sent->json('id'))->is_read);
        $this->act('consent', 'revoke', 2, $this->b)->assertOk();
        $this->getJson('/api/v1/messages?peer_id='.$this->a->id)->assertNotFound();
        Sanctum::actingAs($this->a);
        $this->postJson('/api/v1/messages', $payload)->assertNotFound();
        $this->assertDatabaseCount('chat_messages', 1);
    }

    public function test_unknown_actor_disabled_peer_and_unconfigured_environment_deny(): void
    {
        $this->active();
        Sanctum::actingAs(User::factory()->create(['phone' => '19900000704']));
        $this->getJson('/api/v1/conversation-peers/'.$this->b->id)->assertNotFound();
        $this->b->forceFill(['disabled' => true])->save();
        Sanctum::actingAs($this->a);
        $this->postJson('/api/v1/messages', ['receiver_id' => $this->b->id, 'content' => 'denied'])->assertNotFound();
        config(['restoration.enabled' => false]);
        $this->getJson('/api/v1/conversations')->assertNotFound();
    }

    public function test_latest_message_window_keeps_new_messages_and_legacy_cursor_order(): void
    {
        $this->active();
        $ids = [];
        for ($i = 1; $i <= 105; $i++) {
            $ids[] = ChatMessage::create([
                'room_id' => min($this->a->id, $this->b->id).'_'.max($this->a->id, $this->b->id),
                'sender_id' => $this->a->id, 'receiver_id' => $this->b->id,
                'content' => 'fictional history '.$i,
            ])->id;
        }
        Sanctum::actingAs($this->b);
        $url = '/api/v1/messages?peer_id='.$this->a->id.'&limit=100';
        $this->assertSame(array_slice($ids, 0, 100), $this->getJson($url)->assertOk()->json('items.*.id'));
        $this->assertSame(array_slice($ids, -100), $this->getJson($url.'&latest=1')->assertOk()->json('items.*.id'));
        $this->assertSame(array_slice($ids, 100), $this->getJson($url.'&after_id='.$ids[99])->assertOk()->json('items.*.id'));
        $this->getJson($url.'&latest=1&after_id='.$ids[99])->assertUnprocessable();
        $this->act('consent', 'revoke', 2, $this->b)->assertOk();
        $this->getJson($url.'&latest=1')->assertNotFound();
    }

    public function test_older_message_pages_are_nearest_chronological_and_exclusive(): void
    {
        $this->active();
        $ids = [];
        for ($i = 1; $i <= 7; $i++) {
            $ids[] = ChatMessage::create([
                'room_id' => min($this->a->id, $this->b->id).'_'.max($this->a->id, $this->b->id),
                'sender_id' => $this->a->id, 'receiver_id' => $this->b->id,
                'content' => 'fictional history '.$i,
            ])->id;
        }
        // Rows belonging to a different room must never enter this history.
        ChatMessage::create([
            'room_id' => 'unrelated_room', 'sender_id' => $this->a->id,
            'receiver_id' => $this->b->id, 'content' => 'other room',
        ]);
        Sanctum::actingAs($this->b);
        $url = '/api/v1/messages?peer_id='.$this->a->id.'&limit=3';
        $latest = $this->getJson($url.'&latest=1')->assertOk()->assertJsonPath('has_more', true);
        $this->assertSame(array_slice($ids, 4), $latest->json('items.*.id'));
        $middle = $this->getJson($url.'&before_id='.$ids[4])->assertOk()->assertJsonPath('has_more', true);
        $this->assertSame(array_slice($ids, 1, 3), $middle->json('items.*.id'));
        $first = $this->getJson($url.'&before_id='.$ids[1])->assertOk()->assertJsonPath('has_more', false);
        $this->assertSame([$ids[0]], $first->json('items.*.id'));
        $this->getJson($url.'&before_id='.$ids[0])->assertOk()->assertJsonPath('items', [])->assertJsonPath('has_more', false);
        $this->getJson($url.'&before_id='.$ids[4].'&after_id=0')->assertUnprocessable();
        $this->getJson($url.'&before_id='.$ids[4].'&latest=1')->assertUnprocessable();
        $this->getJson($url.'&before_id=0')->assertUnprocessable();
        $this->act('consent', 'revoke', 2, $this->b)->assertOk();
        $this->getJson($url.'&before_id='.$ids[4])->assertNotFound();
    }

    public function test_a_second_authorized_peer_cannot_replay_a_revoked_peers_message(): void
    {
        $this->active();
        Sanctum::actingAs($this->a);
        $first = $this->b;
        $payload = ['receiver_id' => $first->id, 'content' => 'bound to B', 'client_message_id' => '123e4567-e89b-42d3-a456-426614174101'];
        $this->postJson('/api/v1/messages', $payload)->assertOk();
        $this->act('consent', 'revoke', 2, $first)->assertOk();
        $this->b = User::factory()->create(['phone' => '19900000706', 'disabled' => false, 'is_synthetic' => false]);
        $this->createAcceptedMatchContext($this->a, $this->b);
        $this->active();
        Sanctum::actingAs($this->a);
        $this->postJson('/api/v1/messages',$payload + ['peer_id' => $this->b->id])->assertNotFound();
        $this->assertDatabaseCount('chat_messages',1);
    }
}
