<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\DatingMatch;
use App\Models\User;
use App\Services\NotificationService;
use App\Http\Middleware\DenyUnverifiedMessagingLiveAccess;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_notifications_index_and_unread_count_and_mark_read_flow(): void
    {
        $user = User::create([
            'phone' => '13800000031',
            'name' => 'Notifier',
            'password' => 'secret123',
        ]);
        $other = User::create([
            'phone' => '13800000032',
            'name' => 'Peer',
            'password' => 'secret123',
        ]);

        config(['restoration.enabled'=>true]);
        \Illuminate\Support\Facades\DB::table('friendships')->insert(['user_a'=>min($user->id,$other->id),'user_b'=>max($user->id,$other->id),'state'=>'ACTIVE','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
        $consent=app(\App\Services\LiveConsentService::class);
        foreach ([[$other,$user,'connection','request',0],[$user,$other,'connection','accept',1],[$other,$user,'consent','request',0],[$user,$other,'consent','accept',1]] as [$a,$b,$kind,$action,$revision]) $consent->transition($a->id,$b->id,$kind,$action,$revision);
        Sanctum::actingAs($other);
        $this->postJson('/api/v1/messages',['receiver_id'=>$user->id,'content'=>'synthetic notification flow','client_message_id'=>(string)\Illuminate\Support\Str::uuid()])->assertOk();
        $post=\App\Models\StatusPost::create(['author_user_id'=>$user->id,'title'=>'synthetic','body'=>'synthetic','visibility'=>'public','audience'=>'FRIENDS','is_deleted'=>false]);
        AppNotificationItem::query()->create([
            'user_id' => $user->id,
            'kind' => 'status_like',
            'title' => 'Peer 赞了你的动态',
            'body' => 'nice',
            'payload' => [
                'actor_user_id'=>$other->id,'status_post_id'=>$post->id,
                'route_name' => 'status_author',
                'route_args' => ['user_id' => $other->id],
            ],
            'read_at' => now(),
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonPath('total', 2)
            ->assertJsonPath('unread_total', 1)
            ->assertJsonPath('items.0.kind', 'status_like')
            ->assertJsonPath('items.1.kind', 'message');

        $this->getJson('/api/v1/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('unread_total', 1);

        $notificationId = (int) AppNotificationItem::query()
            ->where('user_id', $user->id)
            ->where('kind', 'message')
            ->value('id');

        $this->postJson("/api/v1/notifications/{$notificationId}/read")
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('unread_total', 0);

        $otherNotificationId = (int) AppNotificationItem::query()
            ->where('user_id', $user->id)
            ->where('kind', 'status_like')
            ->value('id');

        $this->postJson('/api/v1/notifications/read-all')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('affected', 0);

        $this->assertDatabaseHas('notifications', [
            'id' => $otherNotificationId,
            'user_id' => $user->id,
            'kind' => 'status_like',
        ]);
    }

    public function test_create_for_user_deduplicates_same_payload_within_window(): void
    {
        $service = app(NotificationService::class);
        $user = User::create([
            'phone' => '13800000033',
            'name' => 'DedupUser',
            'password' => 'secret123',
        ]);

        $item1 = $service->createForUser(
            $user->id,
            'message',
            'Peer 发来一条消息',
            'hello',
            [
                'route_name' => 'chat_room',
                'route_args' => ['conversation_id' => '88'],
            ],
        );
        $item2 = $service->createForUser(
            $user->id,
            'message',
            'Peer 发来一条消息',
            'hello',
            [
                'route_name' => 'chat_room',
                'route_args' => ['conversation_id' => '88'],
            ],
        );

        $this->assertSame($item1->id, $item2->id);
        $this->assertSame(1, AppNotificationItem::query()->where('user_id', $user->id)->count());
    }

    public function test_message_notification_keeps_private_pointer_and_replay_does_not_duplicate(): void
    {
        // This replay check exercises legacy internals, not v10 live messaging authority.
        $this->withoutMiddleware(DenyUnverifiedMessagingLiveAccess::class);

        $sender = User::factory()->create(['phone' => 'notify-sender']);
        $receiver = User::factory()->create(['phone' => 'notify-receiver']);
        DatingMatch::query()->create([
            'week_tag' => 'notify-runtime',
            'user_a' => $sender->id,
            'user_b' => $receiver->id,
            'drop_released' => true,
        ]);
        Sanctum::actingAs($sender);
        $payload = [
            'receiver_id' => $receiver->id,
            'content' => 'notification truth',
            'client_message_id' => '323e4567-e89b-42d3-a456-426614174000',
        ];
        $send = $this->postJson('/api/v1/messages', $payload)->assertOk()->json();
        $this->postJson('/api/v1/messages', $payload)
            ->assertOk()->assertJsonPath('idempotent_replay', true);

        $this->assertDatabaseCount('notifications', 1);
        $notification = AppNotificationItem::query()->firstOrFail();
        $this->assertSame(\App\Services\NotificationService::MESSAGE_TITLE, $notification->title);
        $this->assertSame(\App\Services\NotificationService::MESSAGE_BODY, $notification->body);
        $this->assertArrayNotHasKey('peer_user_id', $notification->payload);
        $this->assertArrayNotHasKey('route_args', $notification->payload);
        $storedMessage = \App\Models\ChatMessage::findOrFail($notification->payload['message_id']);
        $storedConversation = \App\Models\Conversation::where('room_key', $storedMessage->room_id)->firstOrFail();
        $this->assertSame((int) $send['conversation_id'], (int) $storedConversation->id);
        $this->assertSame($sender->id, (int) $storedMessage->sender_id);
        $this->assertSame($send['id'], $notification->payload['message_id']);
    }
}
