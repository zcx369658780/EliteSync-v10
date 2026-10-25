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

    private User $a;

    private User $b;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true]);
        $this->a = User::factory()->create(['phone' => '19900000702', 'disabled' => false, 'is_synthetic' => false]);
        $this->b = User::factory()->create(['phone' => '19900000703', 'disabled' => false, 'is_synthetic' => false]);
        DatingMatch::create(['week_tag' => 'v1007-test', 'user_a' => $this->a->id, 'user_b' => $this->b->id, 'drop_released' => true]);
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
        $this->friendshipContext();
        $this->act('connection', 'request', 0, $this->a)->assertOk()->assertJsonPath('connection.state', 'CN_PENDING');
        $this->act('connection', 'accept', 1, $this->b)->assertOk()->assertJsonPath('connection.state', 'CN_ACTIVE');
        $this->act('consent', 'request', 0, $this->a)->assertOk()->assertJsonPath('consent.state', 'MC_PENDING');
        $this->act('consent', 'accept', 1, $this->b)->assertOk()->assertJsonPath('consent.state', 'MC_ACTIVE');
    }

    private function friendshipContext(): void
    {
        \Illuminate\Support\Facades\DB::table('friendships')->insert(['user_a' => min($this->a->id, $this->b->id),
            'user_b' => max($this->a->id, $this->b->id), 'state' => 'ACTIVE', 'revision' => 1,
            'created_at' => now(), 'updated_at' => now()]);
    }

    public function test_bare_match_is_unavailable_and_single_party_consent_cannot_grant_messages(): void
    {
        $this->getJson('/api/v1/messages?peer_id='.$this->b->id)->assertNotFound();
        $this->act('connection', 'request', 0, $this->a)->assertNotFound();
        $this->assertDatabaseCount('product_connections', 0);
        $this->friendshipContext();
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

    public function test_a_second_authorized_peer_cannot_replay_a_revoked_peers_message(): void
    {
        $this->active();
        Sanctum::actingAs($this->a);
        $first = $this->b;
        $payload = ['receiver_id' => $first->id, 'content' => 'bound to B', 'client_message_id' => '123e4567-e89b-42d3-a456-426614174101'];
        $this->postJson('/api/v1/messages', $payload)->assertOk();
        $this->act('consent', 'revoke', 2, $first)->assertOk();
        $this->b = User::factory()->create(['phone' => '19900000706', 'disabled' => false, 'is_synthetic' => false]);
        DatingMatch::create(['week_tag' => 'second-peer', 'user_a' => $this->a->id, 'user_b' => $this->b->id, 'drop_released' => true]);
        $this->active();
        Sanctum::actingAs($this->a);
        $this->postJson('/api/v1/messages',$payload + ['peer_id' => $this->b->id])->assertNotFound();
        $this->assertDatabaseCount('chat_messages',1);
    }
}
