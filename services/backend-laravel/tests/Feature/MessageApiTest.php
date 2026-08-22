<?php

namespace Tests\Feature;

use App\Models\ChatMessage;
use App\Models\AppEvent;
use App\Models\AppNotificationItem;
use App\Models\Conversation;
use App\Models\ConversationMatchLink;
use App\Models\ConversationMember;
use App\Models\DatingMatch;
use App\Models\MediaAsset;
use App\Models\MessageAttachment;
use App\Models\User;
use App\Http\Controllers\Api\V1\MessageController;
use App\Services\NotificationService;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MessageApiTest extends TestCase
{
    use RefreshDatabase;

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    private function mediaAsset(User $owner, string $status, string $type = 'image'): MediaAsset
    {
        return MediaAsset::query()->create([
            'owner_user_id' => $owner->id,
            'media_type' => $type,
            'storage_provider' => 's3',
            'storage_disk' => 'public',
            'storage_key' => 'atomic-tests/'.$owner->id.'/'.uniqid('', true),
            'status' => $status,
        ]);
    }

    public function test_message_idempotency_fields_preserve_legacy_nulls_and_enforce_sender_scoped_uniqueness(): void
    {
        $sender = User::factory()->create(['phone' => '13800000021']);
        $otherSender = User::factory()->create(['phone' => '13800000022']);
        $receiver = User::factory()->create(['phone' => '13800000023']);
        $clientMessageId = '123e4567-e89b-42d3-a456-426614174000';
        $requestFingerprint = str_repeat('a', 64);

        ChatMessage::query()->create([
            'room_id' => "{$sender->id}_{$receiver->id}",
            'sender_id' => $sender->id,
            'receiver_id' => $receiver->id,
            'content' => 'legacy one',
        ]);
        ChatMessage::query()->create([
            'room_id' => "{$sender->id}_{$receiver->id}",
            'sender_id' => $sender->id,
            'receiver_id' => $receiver->id,
            'content' => 'legacy two',
        ]);

        $keyed = ChatMessage::query()->create([
            'room_id' => "{$sender->id}_{$receiver->id}",
            'sender_id' => $sender->id,
            'receiver_id' => $receiver->id,
            'content' => 'keyed message',
            'client_message_id' => $clientMessageId,
            'request_fingerprint' => $requestFingerprint,
        ]);

        $this->assertNull(ChatMessage::query()->first()->client_message_id);
        $this->assertSame($clientMessageId, $keyed->fresh()->client_message_id);
        $this->assertSame($requestFingerprint, $keyed->fresh()->request_fingerprint);
        $this->assertSame(3, ChatMessage::query()->count());

        try {
            ChatMessage::query()->create([
                'room_id' => "{$sender->id}_{$otherSender->id}",
                'sender_id' => $sender->id,
                'receiver_id' => $otherSender->id,
                'content' => 'different duplicate payload',
                'client_message_id' => $clientMessageId,
                'request_fingerprint' => str_repeat('b', 64),
            ]);
            $this->fail('The same sender and client message ID must be unique.');
        } catch (QueryException $exception) {
            $this->assertStringContainsString('unique', strtolower($exception->getMessage()));
        }

        $this->assertSame(3, ChatMessage::query()->count());

        ChatMessage::query()->create([
            'room_id' => "{$otherSender->id}_{$receiver->id}",
            'sender_id' => $otherSender->id,
            'receiver_id' => $receiver->id,
            'content' => 'same key different sender',
            'client_message_id' => $clientMessageId,
            'request_fingerprint' => $requestFingerprint,
        ]);

        $this->assertSame(4, ChatMessage::query()->count());
        $this->assertDatabaseCount('conversations', 0);
        $this->assertDatabaseCount('conversation_members', 0);
        $this->assertDatabaseCount('conversation_match_links', 0);
        $this->assertDatabaseCount('app_events', 0);
        $this->assertDatabaseCount('notifications', 0);
    }

    public function test_send_list_and_mark_read_message_flow(): void
    {
        $userA = User::create([
            'phone' => '13800000011',
            'name' => 'A',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000012',
            'name' => 'B',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'hello',
        ])->assertOk()->assertJsonPath('ok', true)->json();
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'message_sent',
            'actor_user_id' => $userA->id,
            'target_user_id' => $userB->id,
        ]);

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.content', 'hello');

        $this->postJson('/api/v1/messages/read/'.$messageId)
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('items.0.is_read', true);
    }

    public function test_image_attachment_can_be_bound_to_message_and_listed(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);
        Storage::fake('public');

        $userA = User::create([
            'phone' => '13800000015',
            'name' => 'A3',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000016',
            'name' => 'B3',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $userA->id,
            'media_type' => 'image',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/'.$userA->id.'/image/test.jpg',
            'original_name' => 'test.jpg',
            'mime_type' => 'image/jpeg',
            'size_bytes' => 1024,
            'width' => 640,
            'height' => 480,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/chat-media/'.$userA->id.'/image/test.jpg',
            'metadata' => ['kind' => 'image'],
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);
        Storage::disk('public')->put($asset->storage_key, 'image-bytes');

        $expectedImageUrl = 'http://localhost:8080/api/v1/media/'.$asset->id.'/content';

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => '',
            'attachment_ids' => [$asset->id],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('message.has_attachments', true)
            ->assertJsonPath('message.attachments.0.media_asset.public_url', $expectedImageUrl)
            ->json();

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.last_message', '图片消息');

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.message_type', 'image')
            ->assertJsonPath('items.0.attachments.0.media_asset.id', $asset->id);
    }

    public function test_video_attachment_can_be_bound_to_message_and_listed(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);
        Storage::fake('public');

        $userA = User::create([
            'phone' => '13800000017',
            'name' => 'A4',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000018',
            'name' => 'B4',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $userA->id,
            'media_type' => 'video',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/'.$userA->id.'/video/test.mp4',
            'original_name' => 'test.mp4',
            'mime_type' => 'video/mp4',
            'size_bytes' => 2048,
            'width' => 1280,
            'height' => 720,
            'duration_ms' => 65000,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/chat-media/'.$userA->id.'/video/test.mp4',
            'metadata' => ['kind' => 'video'],
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);
        Storage::disk('public')->put($asset->storage_key, 'video-bytes');

        $expectedVideoUrl = 'http://localhost:8080/api/v1/media/'.$asset->id.'/content';

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => '',
            'attachment_ids' => [$asset->id],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('message.has_attachments', true)
            ->assertJsonPath('message.attachments.0.media_asset.public_url', $expectedVideoUrl)
            ->json();

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.last_message', '视频消息');

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.message_type', 'video')
            ->assertJsonPath('items.0.attachments.0.media_asset.id', $asset->id)
            ->assertJsonPath('items.0.attachments.0.media_asset.duration_ms', 65000);
    }

    public function test_missing_attachment_preserves_message_reference_with_empty_public_url(): void
    {
        Storage::fake('public');
        $asset = new MediaAsset([
            'owner_user_id' => 10,
            'media_type' => 'image',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/missing.png',
            'status' => 'ready',
            'public_url' => 'http://localhost/storage/chat-media/missing.png',
        ]);
        $asset->id = 20;
        $attachment = new MessageAttachment(['attachment_type' => 'image', 'sort_order' => 0]);
        $attachment->id = 30;
        $attachment->setRelation('mediaAsset', $asset);
        $message = new ChatMessage([
            'room_id' => '10_11', 'sender_id' => 10, 'receiver_id' => 11, 'content' => '',
        ]);
        $message->id = 40;
        $message->setRelation('attachments', collect([$attachment]));

        $method = new \ReflectionMethod(MessageController::class, 'shapeMessage');
        $projection = $method->invoke(app(MessageController::class), $message);

        $this->assertSame(40, $projection['id']);
        $this->assertTrue($projection['has_attachments']);
        $this->assertSame(30, $projection['attachments'][0]['id']);
        $this->assertSame(20, $projection['attachments'][0]['media_asset']['id']);
        $this->assertSame('', $projection['attachments'][0]['media_asset']['public_url']);
    }

    public function test_video_attachment_preview_takes_priority_over_content(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);

        $userA = User::create([
            'phone' => '13800000019',
            'name' => 'A5',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000020',
            'name' => 'B5',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $userA->id,
            'media_type' => 'video',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/'.$userA->id.'/video/test-priority.mp4',
            'original_name' => 'test-priority.mp4',
            'mime_type' => 'video/mp4',
            'size_bytes' => 4096,
            'width' => 1280,
            'height' => 720,
            'duration_ms' => 5000,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/chat-media/'.$userA->id.'/video/test-priority.mp4',
            'metadata' => ['kind' => 'video'],
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'video caption should not win',
            'attachment_ids' => [$asset->id],
        ])->assertOk()->assertJsonPath('ok', true);

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.last_message', '视频消息');
    }

    public function test_list_auto_marks_incoming_messages_as_read(): void
    {
        $userA = User::create([
            'phone' => '13800000013',
            'name' => 'A2',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000014',
            'name' => 'B2',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'auto read check',
        ])->assertOk()->json();
        $messageId = (int) $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.is_read', true);
    }

    public function test_atomic_keyed_send_replay_mismatch_and_newest_match_truth(): void
    {
        $sender = User::factory()->create(['phone' => 'atomic-a', 'name' => 'Atomic A']);
        $receiver = User::factory()->create(['phone' => 'atomic-b']);
        DatingMatch::query()->create([
            'week_tag' => 'atomic-old', 'user_a' => $sender->id, 'user_b' => $receiver->id,
            'drop_released' => true, 'released_at' => now()->subHour(),
        ]);
        $newest = DatingMatch::query()->create([
            'week_tag' => 'atomic-new', 'user_a' => $receiver->id, 'user_b' => $sender->id,
            'drop_released' => true, 'released_at' => now(),
        ]);
        $key = '123e4567-e89b-42d3-a456-426614174000';
        Sanctum::actingAs($sender);

        $first = $this->postJson('/api/v1/messages', [
            'receiver_id' => $receiver->id, 'content' => '  hello 世界  ', 'client_message_id' => $key,
        ])->assertOk()
            ->assertJsonPath('client_message_id', $key)
            ->assertJsonPath('idempotent_replay', false)
            ->assertJsonPath('message.client_message_id', $key)
            ->json();
        $conversationId = (int) $first['conversation_id'];
        $counts = [
            Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(),
            ChatMessage::count(), AppEvent::count(), AppNotificationItem::count(),
        ];
        $this->assertSame([1, 2, 1, 1, 1, 1], $counts);
        $this->assertDatabaseHas('conversation_match_links', [
            'conversation_id' => $conversationId, 'dating_match_id' => $newest->id,
        ]);

        $replay = $this->postJson('/api/v1/messages', [
            'receiver_id' => $receiver->id, 'content' => 'hello 世界', 'client_message_id' => $key,
        ])->assertOk()->assertJsonPath('idempotent_replay', true)->json();
        $this->assertSame($first['id'], $replay['id']);
        $this->assertSame($conversationId, $replay['conversation_id']);
        $this->assertSame($counts, [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);

        $this->postJson('/api/v1/messages', [
            'receiver_id' => $receiver->id, 'content' => 'different', 'client_message_id' => $key,
        ])->assertStatus(409)->assertExactJson([
            'message' => 'client message id payload mismatch', 'code' => 'client_message_id_payload_mismatch',
        ]);
        $this->assertSame($counts, [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);

        $notification = AppNotificationItem::query()->firstOrFail();
        $this->assertSame((string) $conversationId, $notification->payload['route_args']['conversation_id']);
        $this->assertSame($sender->id, $notification->payload['peer_user_id']);
        $this->assertSame($first['id'], $notification->payload['message_id']);
    }

    public function test_key_validation_and_attachment_failure_contracts_have_no_writes(): void
    {
        $sender = User::factory()->create(['phone' => 'media-a']);
        $receiver = User::factory()->create(['phone' => 'media-b']);
        $foreign = User::factory()->create(['phone' => 'media-c']);
        DatingMatch::query()->create(['week_tag' => 'media', 'user_a' => $sender->id, 'user_b' => $receiver->id, 'drop_released' => true]);
        $foreignAsset = $this->mediaAsset($foreign, 'ready');
        $pendingAsset = $this->mediaAsset($sender, 'pending');
        Sanctum::actingAs($sender);

        foreach (['123E4567-E89B-42D3-A456-426614174000', '123e4567-e89b-12d3-a456-426614174000'] as $invalid) {
            $this->postJson('/api/v1/messages', ['receiver_id' => $receiver->id, 'content' => 'x', 'client_message_id' => $invalid])
                ->assertUnprocessable();
        }
        $this->postJson('/api/v1/messages', ['receiver_id' => $receiver->id, 'attachment_ids' => [999999]])
            ->assertStatus(422)->assertJsonPath('code', 'attachment_unavailable');
        $this->postJson('/api/v1/messages', ['receiver_id' => $receiver->id, 'attachment_ids' => [$foreignAsset->id]])
            ->assertStatus(422)->assertJsonPath('code', 'attachment_unavailable');
        $this->postJson('/api/v1/messages', ['receiver_id' => $receiver->id, 'attachment_ids' => [$pendingAsset->id]])
            ->assertStatus(409)->assertJsonPath('code', 'attachment_not_ready')->assertJsonPath('retry_safe', true);
        $this->assertSame([0, 0, 0, 0, 0, 0], [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);
    }

    public function test_ready_attachment_request_order_replays_and_notification_failure_rolls_back(): void
    {
        $sender = User::factory()->create(['phone' => 'order-a']);
        $receiver = User::factory()->create(['phone' => 'order-b']);
        DatingMatch::query()->create(['week_tag' => 'order', 'user_a' => $sender->id, 'user_b' => $receiver->id, 'drop_released' => true]);
        $firstAsset = $this->mediaAsset($sender, 'ready', 'image');
        $secondAsset = $this->mediaAsset($sender, 'ready', 'video');
        Sanctum::actingAs($sender);
        $key = '223e4567-e89b-42d3-a456-426614174000';
        $payload = ['receiver_id' => $receiver->id, 'attachment_ids' => [$secondAsset->id, $firstAsset->id], 'client_message_id' => $key];
        $this->postJson('/api/v1/messages', $payload)->assertOk()->assertJsonPath('idempotent_replay', false);
        $this->assertSame([$secondAsset->id, $firstAsset->id], MessageAttachment::query()->orderBy('sort_order')->pluck('media_asset_id')->all());
        $this->postJson('/api/v1/messages', $payload)->assertOk()->assertJsonPath('idempotent_replay', true);
        $this->assertDatabaseCount('message_attachments', 2);

        $other = User::factory()->create(['phone' => 'rollback-b']);
        DatingMatch::query()->create(['week_tag' => 'rollback', 'user_a' => $sender->id, 'user_b' => $other->id, 'drop_released' => true]);
        $before = [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()];
        $this->app->instance(NotificationService::class, new class extends NotificationService {
            public function createForUser(int $userId, string $kind, string $title, ?string $body = null, array $payload = [], ?string $expiresAt = null): AppNotificationItem
            {
                throw new \RuntimeException('injected notification failure');
            }
        });
        $this->withoutExceptionHandling();
        try {
            $this->postJson('/api/v1/messages', ['receiver_id' => $other->id, 'content' => 'rollback']);
            $this->fail('Notification failure must escape the transaction.');
        } catch (\RuntimeException $exception) {
            $this->assertSame('injected notification failure', $exception->getMessage());
        }
        $this->assertSame($before, [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);
    }

    public function test_atomic_send_reuses_resolved_foundation_winners_and_preserves_departed_members(): void
    {
        $sender = User::factory()->create(['phone' => 'winner-a']);
        $receiver = User::factory()->create(['phone' => 'winner-b']);
        $match = DatingMatch::query()->create([
            'week_tag' => 'winner-match', 'user_a' => $sender->id, 'user_b' => $receiver->id,
            'drop_released' => true, 'released_at' => now(),
        ]);
        $conversation = Conversation::query()->create([
            'room_key' => min($sender->id, $receiver->id).'_'.max($sender->id, $receiver->id),
            'room_type' => 'direct', 'status' => 'active', 'created_by' => $sender->id,
        ]);
        $senderMember = ConversationMember::query()->create([
            'conversation_id' => $conversation->id, 'user_id' => $sender->id,
            'role' => 'member', 'joined_at' => now(), 'left_at' => null,
        ]);
        $link = ConversationMatchLink::query()->create([
            'conversation_id' => $conversation->id, 'dating_match_id' => $match->id, 'linked_at' => now(),
        ]);
        Sanctum::actingAs($sender);
        $payload = [
            'receiver_id' => $receiver->id,
            'content' => 'winner reuse',
            'client_message_id' => '423e4567-e89b-42d3-a456-426614174000',
        ];

        $first = $this->postJson('/api/v1/messages', $payload)
            ->assertOk()->assertJsonPath('conversation_id', $conversation->id)
            ->assertJsonPath('idempotent_replay', false)->json();
        $this->assertSame($senderMember->id, ConversationMember::query()->where('user_id', $sender->id)->value('id'));
        $this->assertSame($link->id, ConversationMatchLink::query()->where('dating_match_id', $match->id)->value('id'));
        $this->assertDatabaseCount('conversations', 1);
        $this->assertDatabaseCount('conversation_members', 2);
        $this->assertDatabaseCount('conversation_match_links', 1);
        $this->assertDatabaseCount('chat_messages', 1);
        $this->assertDatabaseCount('app_events', 1);
        $this->assertDatabaseCount('notifications', 1);
        $counts = [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()];

        $this->postJson('/api/v1/messages', $payload)
            ->assertOk()->assertJsonPath('id', $first['id'])->assertJsonPath('idempotent_replay', true);
        $this->assertSame($counts, [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);

        $senderMember->forceFill(['left_at' => now()])->save();
        $leftAt = $senderMember->fresh()->left_at;
        $this->postJson('/api/v1/messages', ['receiver_id' => $receiver->id, 'content' => 'must deny'])
            ->assertNotFound()->assertExactJson(['message' => 'chat unavailable']);
        $this->assertTrue($leftAt->equalTo($senderMember->fresh()->left_at));
        $this->assertSame($counts, [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);
    }

    public function test_cross_conversation_match_link_winner_throws_and_rolls_back_attempted_send(): void
    {
        $sender = User::factory()->create(['phone' => 'invariant-a']);
        $receiver = User::factory()->create(['phone' => 'invariant-b']);
        $other = User::factory()->create(['phone' => 'invariant-c']);
        $match = DatingMatch::query()->create([
            'week_tag' => 'invariant-match', 'user_a' => $sender->id, 'user_b' => $receiver->id,
            'drop_released' => true, 'released_at' => now(),
        ]);
        $otherConversation = Conversation::query()->create([
            'room_key' => min($sender->id, $other->id).'_'.max($sender->id, $other->id),
            'room_type' => 'direct', 'status' => 'active', 'created_by' => $sender->id,
        ]);
        ConversationMatchLink::query()->create([
            'conversation_id' => $otherConversation->id, 'dating_match_id' => $match->id, 'linked_at' => now(),
        ]);
        $before = [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()];
        Sanctum::actingAs($sender);
        $this->withoutExceptionHandling();

        try {
            $this->postJson('/api/v1/messages', ['receiver_id' => $receiver->id, 'content' => 'must roll back']);
            $this->fail('Cross-conversation match-link ownership must fail closed.');
        } catch (\RuntimeException $exception) {
            $this->assertSame('match link conversation invariant violation', $exception->getMessage());
        }

        $this->assertSame($before, [Conversation::count(), ConversationMember::count(), ConversationMatchLink::count(), ChatMessage::count(), AppEvent::count(), AppNotificationItem::count()]);
        $this->assertDatabaseMissing('conversations', [
            'room_key' => min($sender->id, $receiver->id).'_'.max($sender->id, $receiver->id),
        ]);
    }
}
