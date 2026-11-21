<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\LiveConsentService;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007R1NotificationPrivacyTest extends TestCase
{
    use \Tests\Support\CreatesAcceptedMainMatch;
    use RefreshDatabase;

    private User $sender;

    private User $recipient;

    private int $messageId;

    private int $conversationId;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true]);
        $this->sender = User::factory()->create(['phone' => '19900000791', 'name' => 'PRIVATE SENDER IDENTITY', 'disabled' => false, 'is_synthetic' => false]);
        $this->recipient = User::factory()->create(['phone' => '19900000792', 'disabled' => false, 'is_synthetic' => false]);
        $this->createAcceptedMatchContext($this->sender, $this->recipient);
        $s = app(LiveConsentService::class);
        $s->transition($this->sender->id, $this->recipient->id, 'connection', 'request', 0);
        $s->transition($this->recipient->id, $this->sender->id, 'connection', 'accept', 1);
        $s->transition($this->sender->id, $this->recipient->id, 'consent', 'request', 0);
        $s->transition($this->recipient->id, $this->sender->id, 'consent', 'accept', 1);
        // Mark the preparation receipts before asserting unread message counts.
        Sanctum::actingAs($this->recipient);
        $this->postJson('/api/v1/notifications/read-all')->assertOk();
        Sanctum::actingAs($this->sender);
        $r = $this->postJson('/api/v1/messages', ['receiver_id' => $this->recipient->id, 'content' => 'PRIVATE MESSAGE BODY NEVER IN NOTIFICATIONS', 'client_message_id' => '423e4567-e89b-42d3-a456-426614174001'])->assertOk();
        $this->messageId = (int) $r->json('id');
        $this->conversationId = (int) $r->json('conversation_id');
        Sanctum::actingAs($this->recipient);
    }

    private function legacy(): AppNotificationItem
    {
        return AppNotificationItem::create(['user_id' => $this->recipient->id, 'kind' => 'message', 'title' => 'PRIVATE SENDER IDENTITY', 'body' => 'PRIVATE MESSAGE BODY NEVER IN NOTIFICATIONS',
            'payload' => ['message_id' => $this->messageId, 'route_name' => 'chat_room', 'route_args' => ['conversation_id' => '999999', 'title' => 'PRIVATE SENDER IDENTITY'],
                'peer_user_id' => $this->sender->id, 'leaked' => 'PRIVATE MESSAGE BODY NEVER IN NOTIFICATIONS']]);
    }

    private function projection(bool $allowed): void
    {
        $ids = AppNotificationItem::query()->where('kind', 'message')
            ->where('user_id', $this->recipient->id)->pluck('id');
        $this->assertNotEmpty($ids);
        $r = $this->getJson('/api/v1/notifications?channel='.($allowed ? 'current' : 'history'))->assertOk();
        $this->assertStringNotContainsString('PRIVATE MESSAGE BODY', $r->getContent());
        $this->assertStringNotContainsString('PRIVATE SENDER IDENTITY', $r->getContent());
        $messages = collect($r->json('items'))->whereIn('id', $ids);
        $this->assertCount($ids->count(), $messages);
        if (! $allowed) {
            $current = $this->getJson('/api/v1/notifications')->assertOk()->json('items');
            $this->assertEmpty(collect($current)->whereIn('id', $ids));
        }
        foreach ($messages as $item) {
            if ($allowed) {
                $this->assertSame(NotificationService::MESSAGE_TITLE, $item['title']);
                $this->assertSame('chat_room', $item['route_name']);
                $this->assertSame((string) $this->conversationId, $item['route_args']['conversation_id']);
            } else {
                $this->assertSame(NotificationService::UNAVAILABLE_TITLE, $item['title']);
                $this->assertSame('', $item['route_name']);
                $this->assertArrayNotHasKey('route_args', $item);
                $this->assertSame([], $item['payload']);
                $this->getJson('/api/v1/notifications/'.$item['id'])->assertOk()->assertJsonPath('item.payload', []);
            }
        }
    }

    public function test_new_storage_minimizes_private_content_and_legal_navigation_is_derived(): void
    {
        $n = AppNotificationItem::where('kind', 'message')->sole();
        $this->assertSame(NotificationService::MESSAGE_TITLE, $n->title);
        $this->assertSame(NotificationService::MESSAGE_BODY, $n->body);
        $this->assertSame(['source' => 'message', 'message_id' => $this->messageId], $n->payload);
        $this->assertSame('PRIVATE MESSAGE BODY NEVER IN NOTIFICATIONS', ChatMessage::findOrFail($this->messageId)->content);
        $this->legacy();
        $this->projection(true);
        $this->postJson('/api/v1/notifications/'.$n->id.'/read')->assertOk();
        $this->getJson('/api/v1/notifications/unread-count')->assertOk()->assertJsonPath('unread_total', 1);
        $this->postJson('/api/v1/notifications/read-all')->assertOk()->assertJsonPath('affected', 1);
        $this->getJson('/api/v1/notifications/unread-count')->assertJsonPath('unread_total', 0);
        $this->assertSame(2, AppNotificationItem::where('kind', 'message')->count());
    }

    public function test_revoked_old_notifications_do_not_expose_content_identity_or_navigation(): void
    {
        $old = $this->legacy();
        $this->projection(true);
        app(LiveConsentService::class)->transition($this->recipient->id, $this->sender->id, 'consent', 'revoke', 2);
        $this->projection(false);
        $this->getJson('/api/v1/messages?peer_id='.$this->sender->id)->assertNotFound();
        $this->postJson('/api/v1/notifications/'.$old->id.'/read')->assertOk();
        $this->assertSame('PRIVATE MESSAGE BODY NEVER IN NOTIFICATIONS', $old->fresh()->body); // Original legacy evidence is not silently rewritten.
    }

    public function test_blocked_disabled_and_unknown_authority_fail_closed(): void
    {
        $this->legacy();
        $block = UserBlock::create(['blocker_id' => $this->recipient->id, 'blocked_user_id' => $this->sender->id, 'reason_code' => 'r1']);
        $this->projection(false);
        $block->delete();
        $this->sender->forceFill(['disabled' => true])->save();
        $this->projection(false);
        $this->sender->forceFill(['disabled' => false])->save();
        config(['restoration.enabled' => false]);
        $this->projection(false);
        config(['restoration.enabled' => true]);
        $this->recipient->forceFill(['disabled' => true])->save();
        $this->getJson('/api/v1/notifications')->assertForbidden();
    }

    public function test_spoofed_legacy_pointer_cannot_borrow_other_receivers_authority(): void
    {
        $third = User::factory()->create(['phone' => '19900000793', 'disabled' => false]);
        $n = $this->legacy();
        $n->forceFill(['user_id' => $third->id])->save();
        Sanctum::actingAs($third);
        $this->getJson('/api/v1/notifications/'.$n->id)->assertOk()->assertJsonPath('item.payload', []);
        $n->forceFill(['payload' => ['message_id' => 999999, 'route_name' => 'chat_room']])->save();
        $this->getJson('/api/v1/notifications/'.$n->id)->assertOk()->assertJsonPath('item.availability', 'history')
            ->assertJsonPath('item.route_name', '')->assertJsonPath('item.payload', []);
    }
}
