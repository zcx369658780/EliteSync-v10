<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\User;
use App\Services\Accounts\AccountClosure;
use App\Services\LiveConsentService;
use App\Services\NotificationService;
use App\Services\RtcSessionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V1011NoticeRevocationTest extends TestCase
{
    use RefreshDatabase;

    private function authorizedPair(): array
    {
        config(['restoration.enabled' => true, 'rtc_guard.enabled' => true]);
        $a = User::factory()->create(['phone' => '13820000001', 'role' => 'user', 'password' => 'Password123']);
        $b = User::factory()->create(['phone' => '13820000002', 'role' => 'user', 'password' => 'Password123']);
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $token = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json('token');
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', [
            'purpose' => 'friendship', 'invitation_token' => $token, 'idempotency_key' => 'notice-fixture-friendship',
        ])->assertCreated()->json('id');
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/social/requests/$id/accept")->assertOk();
        foreach (['connection', 'consent'] as $kind) {
            app(LiveConsentService::class)->transition($a->id, $b->id, $kind, 'request', 0);
            app(LiveConsentService::class)->transition($b->id, $a->id, $kind, 'accept', 1);
        }
        $this->assertTrue(app(LiveConsentService::class)->gates($a->id, $b->id)['live_read_allowed']);

        return [$a, $b];
    }

    private function notices(User $sender, User $recipient): array
    {
        $this->actingAs($sender, 'sanctum')->postJson('/api/v1/messages', [
            'receiver_id' => $recipient->id, 'content' => 'controlled private body',
            'client_message_id' => '12121212-1212-4212-8212-121212121212',
        ])->assertSuccessful();
        $message = ChatMessage::where('sender_id', $sender->id)->where('receiver_id', $recipient->id)->firstOrFail();
        $messageNotice = app(NotificationService::class)->createForUser($recipient->id, 'message', 'legacy name', 'private body', ['message_id' => $message->id]);
        $call = app(RtcSessionService::class)->createCall($sender->id, $recipient->id);
        $rtcNotice = AppNotificationItem::where('user_id', $recipient->id)->where('kind', 'rtc_call_invite')->firstOrFail();
        $postId = $this->actingAs($recipient, 'sanctum')->postJson('/api/v1/status/posts', [
            'title' => 'Controlled post', 'body' => 'Controlled content', 'audience' => 'FRIENDS',
        ])->assertCreated()->json('item.id');
        $this->actingAs($sender, 'sanctum')->postJson("/api/v1/status/posts/$postId/likes")->assertSuccessful();
        $like = AppNotificationItem::where('user_id', $recipient->id)->where('kind', 'status_like')->firstOrFail();

        return [[$messageNotice->id, $rtcNotice->id, $like->id], $postId];
    }

    private function assertVisible(User $viewer, array $ids): void
    {
        $response = $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/notifications')->assertOk();
        foreach ($ids as $id) {
            $this->assertContains($id, array_column($response->json('items'), 'id'));
        }
        $this->assertGreaterThanOrEqual(count($ids), $this->getJson('/api/v1/notifications/unread-count')->assertOk()->json('unread_total'));
    }

    private function assertUnavailableButRetained(User $viewer, array $ids): void
    {
        $response = $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/notifications')->assertOk();
        foreach ($ids as $id) {
            $this->assertNotContains($id, array_column($response->json('items'), 'id'));
            $this->assertDatabaseHas('notifications', ['id' => $id, 'user_id' => $viewer->id, 'read_at' => null]);
        }
        $response->assertJsonPath('unread_total', 0);
        $this->getJson('/api/v1/notifications/unread-count')->assertOk()->assertJsonPath('unread_total', 0);
    }

    public function test_block_hides_message_rtc_and_like_notices_and_counts_without_deleting_internal_rows(): void
    {
        [$a, $b] = $this->authorizedPair();
        [$ids] = $this->notices($a, $b);
        $this->assertVisible($b, $ids);
        $this->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $a->id])->assertOk();
        $this->assertUnavailableButRetained($b, $ids);
    }

    public function test_peer_closure_invalidates_message_rtc_and_like_notices_but_preserves_evidence(): void
    {
        [$a, $b] = $this->authorizedPair();
        [$ids] = $this->notices($a, $b);
        $this->assertVisible($b, $ids);
        app(AccountClosure::class)->request($a, 'Password123', 'notice-source-closure-key');
        $this->assertUnavailableButRetained($b, $ids);
        $this->assertDatabaseHas('chat_messages', ['sender_id' => $a->id, 'receiver_id' => $b->id]);
    }

    public function test_deleted_post_removes_only_like_notice_from_list_and_unread_count_preserving_row(): void
    {
        [$a, $b] = $this->authorizedPair();
        [$ids, $postId] = $this->notices($a, $b);
        $this->assertVisible($b, $ids);
        $before = $this->getJson('/api/v1/notifications/unread-count')->assertOk()->json('unread_total');
        $this->deleteJson("/api/v1/status/posts/$postId")->assertSuccessful();
        $response = $this->getJson('/api/v1/notifications')->assertOk();
        $this->assertNotContains($ids[2], array_column($response->json('items'), 'id'));
        foreach (array_slice($ids, 0, 2) as $id) {
            $this->assertContains($id, array_column($response->json('items'), 'id'));
        }
        $this->getJson('/api/v1/notifications/unread-count')->assertOk()->assertJsonPath('unread_total', $before - 1);
        $this->assertDatabaseHas('notifications', ['id' => $ids[2], 'read_at' => null]);
    }

    public function test_self_audience_removes_only_like_notice_from_list_and_unread_count_preserving_row(): void
    {
        [$a, $b] = $this->authorizedPair();
        [$ids, $postId] = $this->notices($a, $b);
        $this->assertVisible($b, $ids);
        $before = $this->getJson('/api/v1/notifications/unread-count')->assertOk()->json('unread_total');

        $this->putJson("/api/v1/status/posts/$postId/audience", ['audience' => 'SELF'])->assertOk();

        $response = $this->getJson('/api/v1/notifications')->assertOk();
        $this->assertNotContains($ids[2], array_column($response->json('items'), 'id'));
        foreach (array_slice($ids, 0, 2) as $id) {
            $this->assertContains($id, array_column($response->json('items'), 'id'));
        }
        $response->assertJsonPath('unread_total', $before - 1);
        $this->getJson('/api/v1/notifications/unread-count')->assertOk()->assertJsonPath('unread_total', $before - 1);
        $this->assertDatabaseHas('notifications', ['id' => $ids[2], 'user_id' => $b->id, 'read_at' => null]);
        $this->assertDatabaseHas('status_posts', ['id' => $postId, 'audience' => 'SELF', 'is_deleted' => false]);
    }

    public function test_new_mc_generation_requires_terminal_identity_and_rejects_old_generation_replay(): void
    {
        [$a, $b] = $this->authorizedPair();
        $current = app(LiveConsentService::class)->current($a->id, $b->id);
        $oldId = $current['consent']['id'];
        $revoked = $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/consent", [
            'action' => 'revoke', 'expected_revision' => $current['consent']['revision'], 'expected_consent_id' => $oldId,
        ])->assertOk()->assertJsonPath('gates.live_send_allowed', false)->json('consent');
        $this->postJson("/api/v1/connections/{$b->id}/consent", [
            'action' => 'request', 'expected_revision' => $revoked['revision'],
        ])->assertConflict();
        $new = $this->postJson("/api/v1/connections/{$b->id}/consent", [
            'action' => 'request', 'expected_revision' => $revoked['revision'], 'expected_consent_id' => $oldId,
        ])->assertOk()->json('consent');
        $this->assertNotSame($oldId, $new['id']);
        $this->assertSame(2, $new['generation']);
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/consent", [
            'action' => 'accept', 'expected_revision' => $new['revision'], 'expected_consent_id' => $oldId,
        ])->assertConflict();
        $this->postJson("/api/v1/connections/{$a->id}/consent", [
            'action' => 'accept', 'expected_revision' => $new['revision'], 'expected_consent_id' => $new['id'],
        ])->assertOk()->assertJsonPath('gates.live_send_allowed', true);
        $this->assertDatabaseHas('messaging_consents', ['id' => $oldId, 'state' => 'MC_REVOKED']);
    }
}
