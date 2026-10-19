<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\Conversation;
use App\Models\User;
use App\Services\LiveConsentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V1011SocialTest extends TestCase
{
    use RefreshDatabase;

    private function users(): array
    {
        config(['restoration.enabled' => true]);

        return [User::factory()->create(['phone' => '13810000001']), User::factory()->create(['phone' => '13810000002']), User::factory()->create(['phone' => '13810000003'])];
    }

    private function friends(User $a, User $b): void
    {
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $token = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json('token');
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', ['purpose' => 'friendship', 'invitation_token' => $token, 'idempotency_key' => 'friendship-'.random_int(1, 9999999)])->assertCreated()->json('id');
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/social/requests/$id/accept")->assertOk();
    }

    public function test_client_authored_legacy_relationship_events_cannot_contact_strangers(): void
    {
        [$a,$b] = $this->users();
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/relationships', ['subject_user_id' => $b->id, 'event_type' => 'message', 'status' => 'relationship_confirmed', 'metadata' => ['text' => 'untrusted']])->assertStatus(410);
        $this->assertDatabaseCount('user_relationship_events', 0);
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/relationships')->assertOk()->assertJsonCount(0, 'items');
    }

    public function test_friends_require_both_consents_and_hide_is_only_a_view(): void
    {
        [$a,$b,$c] = $this->users();
        $this->friends($a, $b);
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/messages', ['receiver_id' => $b->id, 'content' => 'before'])->assertNotFound();
        foreach (['connection', 'consent'] as $kind) {
            $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/$kind", ['action' => 'request', 'expected_revision' => 0])->assertOk();
            $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/$kind", ['action' => 'accept', 'expected_revision' => 1])->assertOk();
        }
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/messages', ['receiver_id' => $b->id, 'content' => 'after', 'client_message_id' => '11111111-1111-4111-8111-111111111111'])->assertSuccessful();
        $conversation = Conversation::firstOrFail();
        $this->postJson("/api/v1/conversations/{$conversation->id}/visibility", ['hidden' => true])->assertOk();
        $this->getJson('/api/v1/conversations')->assertOk()->assertJsonCount(0, 'items');
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/conversations')->assertOk()->assertJsonCount(1, 'items');
        $this->postJson('/api/v1/messages', ['receiver_id' => $a->id, 'content' => 'new', 'client_message_id' => '22222222-2222-4222-8222-222222222222'])->assertSuccessful();
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/conversations')->assertOk()->assertJsonCount(1, 'items');
        $this->deleteJson("/api/v1/social/friends/{$b->id}")->assertOk();
        $this->getJson("/api/v1/connections/{$b->id}")->assertJsonPath('gates.live_send_allowed', true);
        $this->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $b->id])->assertOk();
        $this->deleteJson("/api/v1/moderation/blocks/{$b->id}")->assertOk();
        $this->postJson('/api/v1/messages', ['receiver_id' => $b->id, 'content' => 'must not resurrect'])->assertNotFound();
    }

    public function test_privacy_posts_and_revocation_do_not_disclose_deep_fields(): void
    {
        [$a,$b,$c] = $this->users();
        $this->friends($a, $b);
        $p = $this->actingAs($a, 'sanctum')->postJson('/api/v1/status/posts', ['title' => 'fiction', 'body' => 'controlled', 'audience' => 'FRIENDS'])->assertCreated()->json('item.id');
        $this->actingAs($b, 'sanctum')->getJson("/api/v1/status/posts/$p")->assertOk()->assertJsonMissing(['phone' => $a->phone]);
        $this->getJson("/api/v1/profile-peers/{$a->id}")->assertOk()->assertJsonMissingPath('profile.birthday');
        $this->getJson("/api/v1/profile-peers/{$a->id}?as_partner=true")->assertUnprocessable();
        $this->actingAs($c, 'sanctum')->getJson("/api/v1/status/posts/$p")->assertNotFound();
        $this->getJson("/api/v1/profile-peers/{$a->id}")->assertNotFound();
        $this->getJson("/api/v1/status/authors/{$a->id}")->assertNotFound();
        $fields = ['birthday' => 'RELATIONSHIP_SHARED', 'interests' => 'SELF', 'resume' => 'SELF', 'zodiac' => 'SELF'];
        $this->actingAs($a, 'sanctum')->putJson('/api/v1/privacy', ['fields' => $fields, 'expected_revision' => 0])->assertOk()->assertJsonPath('revision', 1);
        $this->putJson('/api/v1/privacy', ['fields' => $fields, 'expected_revision' => 0])->assertConflict();
        $this->getJson('/api/v1/privacy/preview?audience=partner')->assertOk()->assertJsonMissingPath('projection.birthday')->assertJsonPath('formal_relationship_available', false);
        $this->deleteJson("/api/v1/social/friends/{$b->id}")->assertOk();
        $this->actingAs($b, 'sanctum')->getJson("/api/v1/status/posts/$p")->assertNotFound();
    }

    public function test_new_lifecycle_after_block_requires_explicit_new_identity(): void
    {
        [$a,$b] = $this->users();
        $this->friends($a, $b);
        foreach (['connection', 'consent'] as $kind) {
            app(LiveConsentService::class)->transition($a->id, $b->id, $kind, 'request', 0);
            app(LiveConsentService::class)->transition($b->id, $a->id, $kind, 'accept', 1);
        }
        $old = app(LiveConsentService::class)->current($a->id, $b->id)['connection']['id'];
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $b->id])->assertOk();
        $this->getJson('/api/v1/moderation/blocks')->assertOk()->assertJsonMissing(['blocked_user_phone' => $b->phone]);
        $this->deleteJson("/api/v1/moderation/blocks/{$b->id}")->assertOk();
        $this->friends($a, $b);
        $current = $this->actingAs($a, 'sanctum')->getJson("/api/v1/connections/{$b->id}")->assertOk()->json('connection');
        $this->postJson("/api/v1/connections/{$b->id}/connection", ['action' => 'request', 'expected_revision' => $current['revision']])->assertConflict();
        $new = $this->postJson("/api/v1/connections/{$b->id}/connection", ['action' => 'request', 'expected_revision' => $current['revision'], 'expected_connection_id' => $old])->assertOk()->json('connection.id');
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/connection", ['action' => 'accept', 'expected_revision' => 1, 'expected_connection_id' => $old])->assertConflict();
        $this->postJson("/api/v1/connections/{$a->id}/connection", ['action' => 'accept', 'expected_revision' => 1, 'expected_connection_id' => $new])->assertOk();
        $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/consent", ['action' => 'request', 'expected_revision' => 0, 'expected_connection_id' => $old])->assertConflict();
        $this->postJson("/api/v1/connections/{$b->id}/consent", ['action' => 'request', 'expected_revision' => 0, 'expected_connection_id' => $new])->assertOk();
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/consent", ['action' => 'accept', 'expected_revision' => 1, 'expected_connection_id' => $new])->assertOk()->assertJsonPath('gates.live_send_allowed', true);
        $this->assertDatabaseHas('product_connections', ['id' => $old, 'state' => 'CN_CLOSED']);
    }

    public function test_legacy_like_notification_is_reprojected_and_revoked(): void
    {
        [$a,$b] = $this->users();
        $this->friends($a, $b);
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/status/posts', ['title' => 'test', 'body' => 'test', 'audience' => 'FRIENDS'])->assertCreated()->json('item.id');
        AppNotificationItem::create(['user_id' => $a->id, 'kind' => 'status_like', 'title' => $b->phone, 'body' => $b->name, 'payload' => ['actor_user_id' => $b->id, 'status_post_id' => $id, 'route_args' => ['name' => $b->phone]]]);
        $response = $this->getJson('/api/v1/notifications')->assertOk();
        $this->assertStringNotContainsString($b->phone, $response->getContent());
        $this->deleteJson("/api/v1/social/friends/{$b->id}")->assertOk();
        $this->getJson('/api/v1/notifications')->assertOk()->assertJsonCount(0, 'items')->assertJsonPath('unread_total', 0);
    }

    public function test_quota_counts_distinct_recipients_across_both_purposes(): void
    {
        [$sender] = $this->users();
        for ($i = 0; $i < 6; $i++) {
            $peer = User::factory()->create(['phone' => '1391000000'.$i]);
            $this->actingAs($peer, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
            $purpose = $i % 2 ? 'message' : 'friendship';
            $token = $this->postJson('/api/v1/social/invites', ['purpose' => $purpose])->assertCreated()->json('token');
            $response = $this->actingAs($sender, 'sanctum')->postJson('/api/v1/social/requests', ['purpose' => $purpose, 'invitation_token' => $token, 'idempotency_key' => 'quota-'.$i]);
            if ($i < 5) {
                $response->assertCreated();
            } else {
                $response->assertStatus(429);
            }
        }
        $this->assertDatabaseCount('social_requests', 5);
    }

    public function test_accepted_message_request_is_only_a_source_for_separate_cn_and_mc(): void
    {
        [$a,$b] = $this->users();
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $token = $this->postJson('/api/v1/social/invites', ['purpose' => 'message'])->assertCreated()->json('token');
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', ['purpose' => 'message', 'invitation_token' => $token, 'idempotency_key' => 'message-request'])->assertCreated()->json('id');
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/social/requests/$id/accept")->assertOk();
        $this->assertDatabaseCount('friendships', 0);
        $this->assertDatabaseCount('product_connections', 0);
        $this->postJson('/api/v1/messages', ['receiver_id' => $a->id, 'content' => 'no automatic grant'])->assertNotFound();
        foreach (['connection', 'consent'] as $kind) {
            $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/$kind", ['action' => 'request', 'expected_revision' => 0])->assertOk();
            $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/$kind", ['action' => 'accept', 'expected_revision' => 1])->assertOk();
        }
        $this->assertDatabaseHas('product_connections', ['social_request_id' => $id, 'match_id' => null, 'friendship_id' => null]);
        $this->postJson('/api/v1/messages', ['receiver_id' => $a->id, 'content' => 'separately authorized'])->assertSuccessful();
    }

    public function test_revoked_invite_expiry_and_withdrawal_cooldown(): void
    {
        [$a,$b] = $this->users();
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true]);
        $invite = $this->postJson('/api/v1/social/invites', ['purpose' => 'message'])->assertCreated()->json();
        $this->deleteJson('/api/v1/social/invites/'.$invite['id'])->assertOk();
        $body = ['purpose' => 'message', 'invitation_token' => $invite['token'], 'idempotency_key' => 'revoked'];
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertNotFound();
        $this->actingAs($b, 'sanctum');
        $token = $this->postJson('/api/v1/social/invites', ['purpose' => 'message'])->json('token');
        $body['invitation_token'] = $token;
        $body['idempotency_key'] = 'withdraw';
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertCreated()->json('id');
        $this->postJson("/api/v1/social/requests/$id/withdraw")->assertOk();
        $body['idempotency_key'] = 'too-soon';
        $this->postJson('/api/v1/social/requests', $body)->assertConflict();
        $this->travel(25)->hours();
        $body['idempotency_key'] = 'expired-invite';
        $this->postJson('/api/v1/social/requests', $body)->assertNotFound();
        $this->actingAs($b, 'sanctum');
        $body['invitation_token'] = $this->postJson('/api/v1/social/invites', ['purpose' => 'message'])->json('token');
        $body['idempotency_key'] = 'new-lifecycle';
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertCreated()->json('id');
        $this->travel(8)->days();
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/social')->assertOk();
        $this->postJson("/api/v1/social/requests/$id/accept")->assertConflict();
        $this->assertDatabaseHas('social_requests', ['id' => $id, 'state' => 'EXPIRED']);
    }

    public function test_invitation_is_not_friendship_or_messaging_authority(): void
    {
        $a = User::factory()->create(['phone' => '138'.random_int(10000000, 99999999)]);
        $b = User::factory()->create(['phone' => '138'.random_int(10000000, 99999999)]);
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $invite = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json('token');
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', ['invitation_token' => $invite, 'purpose' => 'friendship', 'idempotency_key' => 'request-1'])->assertCreated()->json('id');
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/social/requests/$id/accept")->assertOk();
        $this->assertDatabaseCount('friendships', 1);
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', ['invitation_token' => $invite, 'purpose' => 'friendship', 'idempotency_key' => 'request-1'])->assertOk()->assertJsonPath('id', $id);
        $this->postJson('/api/v1/social/requests', ['invitation_token' => $invite, 'purpose' => 'message', 'idempotency_key' => 'request-1'])->assertStatus(409);
    }

    public function test_default_closed_decline_and_block_deny_requests(): void
    {
        $a = User::factory()->create(['phone' => '138'.random_int(10000000, 99999999)]);
        $b = User::factory()->create(['phone' => '138'.random_int(10000000, 99999999)]);
        $invite = $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json('token');
        $body = ['invitation_token' => $invite, 'purpose' => 'friendship', 'idempotency_key' => 'closed'];
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertNotFound();
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertCreated()->json('id');
        $this->postJson("/api/v1/social/requests/$id/accept")->assertNotFound();
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/social/requests/$id/decline")->assertOk();
        $body['idempotency_key'] = 'retry';
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertStatus(409);
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $a->id])->assertOk();
        $invite = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->json('token');
        $body['invitation_token'] = $invite;
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', $body)->assertNotFound();
    }
}
