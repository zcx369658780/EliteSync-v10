<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\MediaAsset;
use App\Models\User;
use App\Services\ChatWebsocketAuthorizationService;
use App\Services\LiveConsentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class ConversationGenerationIsolationTest extends TestCase
{
    use RefreshDatabase;

    private const PNG = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a2ioAAAAASUVORK5CYII=';
    private const FIRST_SEND = '12121212-1212-4212-8212-121212121212';

    public static function blockActors(): array
    {
        return ['A blocks B' => [false], 'B blocks A' => [true]];
    }

    #[DataProvider('blockActors')]
    public function test_new_connection_only_exposes_its_own_messages_and_attachments(bool $reverse): void
    {
        config(['restoration.enabled' => true, 'media.disk' => 'v1007']);
        Storage::fake('v1007');
        $a = User::factory()->create(['phone' => '19900004201']);
        $b = User::factory()->create(['phone' => '19900004202']);
        $this->befriend($a, $b, 'generation-friendship-first');
        $oldState = $this->activate($a, $b);
        $legacy = ChatMessage::create([
            'room_id' => min($a->id, $b->id).'_'.max($a->id, $b->id),
            'sender_id' => $a->id, 'receiver_id' => $b->id, 'content' => 'unscoped fixture',
        ]);
        $oldAsset = $this->upload($a);
        $oldA = $this->send($a, $b, 'first generation A', [
            'attachment_ids' => [$oldAsset], 'client_message_id' => self::FIRST_SEND,
        ]);
        $oldB = $this->send($b, $a, 'first generation B');
        $oldMessageId = $oldA['id'];
        $oldRoomId = $oldA['conversation_id'];
        $oldKey = $oldA['message']['room_id'];
        $this->assertSame($oldRoomId, $oldB['conversation_id']);
        $oldRows = DB::table('chat_messages')->whereIn('id', [$legacy->id, $oldMessageId, $oldB['id']])->orderBy('id')->get()->toJson();
        $oldNotice = AppNotificationItem::where('user_id', $b->id)->where('source_event_key', 'message:'.$oldMessageId)->firstOrFail();

        $ws = app(ChatWebsocketAuthorizationService::class);
        $token = $a->createToken('generation-ws', ['chat:ws']);
        $socket = $ws->authorize('Bearer '.$token->plainTextToken, $a->id, $b->id);
        $this->assertSame($oldKey, $socket['room_key'] ?? null);
        Sanctum::actingAs($b);
        $this->get('/api/v1/media/'.$oldAsset.'/content')->assertOk();
        $this->getJson('/api/v1/notifications/'.$oldNotice->id)->assertOk()
            ->assertJsonPath('item.availability', 'current');

        [$blocker, $blocked] = $reverse ? [$b, $a] : [$a, $b];
        Sanctum::actingAs($blocker);
        $this->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $blocked->id])->assertOk();
        $this->assertDatabaseHas('product_connections', ['id' => $oldState['connection']['id'], 'state' => 'CN_CLOSED']);
        $this->assertDatabaseHas('messaging_consents', ['id' => $oldState['consent']['id'], 'state' => 'MC_REVOKED']);
        foreach ([[$a, $b], [$b, $a]] as [$viewer, $peer]) {
            Sanctum::actingAs($viewer);
            $this->getJson('/api/v1/messages?peer_id='.$peer->id)->assertNotFound();
        }
        Sanctum::actingAs($blocker);
        $this->deleteJson('/api/v1/moderation/blocks/'.$blocked->id)->assertOk();
        $this->befriend($a, $b, 'generation-friendship-second');
        $closed = app(LiveConsentService::class)->current($a->id, $b->id)['connection'];
        $newState = $this->activate($a, $b, $closed);
        $this->assertNotSame($oldState['connection']['id'], $newState['connection']['id']);
        $this->assertTrue($newState['gates']['live_read_allowed']);
        $this->assertFalse($ws->reauthorize($socket['token_id'], $a->id, $b->id, $oldKey));

        Sanctum::actingAs($a);
        $this->postJson('/api/v1/messages', [
            'receiver_id' => $b->id, 'content' => 'first generation A',
            'attachment_ids' => [$oldAsset], 'client_message_id' => self::FIRST_SEND,
        ])->assertNotFound();
        $this->postJson('/api/v1/messages', [
            'receiver_id' => $b->id, 'attachment_ids' => [$oldAsset],
        ])->assertUnprocessable()->assertJsonPath('code', 'attachment_unavailable');
        $this->postJson('/api/v1/messages', [
            'receiver_id' => $b->id, 'content' => 'reply to closed conversation', 'reply_to_message_id' => $oldB['id'],
        ])->assertUnprocessable()->assertJsonPath('code', 'reply_unavailable');

        $newAsset = $this->upload($a);
        $newA = $this->send($a, $b, 'second generation A', ['attachment_ids' => [$newAsset]]);
        $newB = $this->send($b, $a, 'second generation B', ['reply_to_message_id' => $newA['id']]);
        $this->assertNotSame($oldRoomId, $newA['conversation_id']);
        $this->assertNotSame($oldKey, $newA['message']['room_id']);
        $this->assertSame($newA['conversation_id'], $newB['conversation_id']);
        $this->assertTrue($ws->reauthorize($socket['token_id'], $a->id, $b->id, $newA['message']['room_id']));

        foreach ([[$a, $b, $oldB, $newB], [$b, $a, $oldA, $newA]] as [$viewer, $peer, $oldIncoming, $newIncoming]) {
            Sanctum::actingAs($viewer);
            $messages = '/api/v1/messages?peer_id='.$peer->id;
            $this->getJson($messages)->assertOk()->assertJsonCount(2, 'items')
                ->assertJsonPath('items.0.id', $newA['id'])->assertJsonPath('items.1.id', $newB['id'])
                ->assertJsonPath('items.1.reply.available', true);
            $this->getJson($messages.'&latest=1&limit=1')->assertOk()->assertJsonPath('items.0.id', $newB['id'])
                ->assertJsonPath('has_more', true);
            $this->getJson($messages.'&before_id='.$newA['id'])->assertOk()->assertJsonCount(0, 'items');
            $this->getJson($messages.'&after_id='.$oldIncoming['id'])->assertOk()->assertJsonCount(2, 'items');
            $this->getJson('/api/v1/messages/search?peer_id='.$peer->id.'&query=first')->assertOk()->assertJsonCount(0, 'items');
            $this->getJson('/api/v1/messages/search?peer_id='.$peer->id.'&query=second')->assertOk()->assertJsonCount(2, 'items');
            $this->getJson('/api/v1/conversations/'.$oldRoomId)->assertNotFound();
            $this->getJson('/api/v1/conversations')->assertOk()->assertJsonCount(1, 'items')
                ->assertJsonPath('items.0.conversation_id', $newA['conversation_id'])
                ->assertJsonPath('items.0.last_message', 'second generation B')->assertJsonPath('items.0.unread', 1);
            $this->postJson('/api/v1/messages/ack', ['peer_id' => $peer->id, 'message_ids' => [$oldIncoming['id']]])->assertNotFound();
            $this->postJson('/api/v1/messages/ack', ['peer_id' => $peer->id, 'message_ids' => [$newIncoming['id']]])
                ->assertOk()->assertJsonPath('updated', 1);
            $this->get('/api/v1/media/'.$oldAsset.'/content')->assertNotFound();
            $this->get('/api/v1/media/'.$newAsset.'/content')->assertOk();
        }

        Sanctum::actingAs($b);
        $this->getJson('/api/v1/notifications/'.$oldNotice->id)->assertOk()
            ->assertJsonPath('item.availability', 'history')->assertJsonPath('item.payload', []);
        $this->getJson('/api/v1/notifications?channel=history')->assertOk()->assertJsonPath('unread_total', 0);
        $this->assertSame($oldRows, DB::table('chat_messages')->whereIn('id', [$legacy->id, $oldMessageId, $oldB['id']])->orderBy('id')->get()->toJson());
        $this->assertDatabaseHas('message_attachments', ['message_id' => $oldMessageId, 'media_asset_id' => $oldAsset]);
        $this->assertDatabaseHas('conversations', ['id' => $oldRoomId, 'room_key' => $oldKey]);
        $this->assertSame(base64_decode(self::PNG), Storage::disk('v1007')->get(MediaAsset::findOrFail($oldAsset)->storage_key));
    }

    public function test_rotated_consent_does_not_reopen_history_on_the_same_connection(): void
    {
        config(['restoration.enabled' => true]);
        $a = User::factory()->create(['phone' => '19900004201']);
        $b = User::factory()->create(['phone' => '19900004202']);
        $this->befriend($a, $b, 'generation-consent-scope');
        $old = $this->activate($a, $b);
        $connectionId = $old['connection']['id'];
        $oldConsent = $old['consent'];
        $oldMessage = $this->send($a, $b, 'prior consent');
        $service = app(LiveConsentService::class);
        $revoked = $service->transition($a->id, $b->id, 'consent', 'revoke',
            $oldConsent['revision'], $connectionId, $oldConsent['id'])['consent'];
        $next = $service->transition($a->id, $b->id, 'consent', 'request',
            $revoked['revision'], $connectionId, $revoked['id'])['consent'];
        $current = $service->transition($b->id, $a->id, 'consent', 'accept',
            $next['revision'], $connectionId, $next['id']);
        $this->assertSame($connectionId, $current['connection']['id']);
        $this->assertNotSame($oldConsent['id'], $current['consent']['id']);

        Sanctum::actingAs($b);
        $this->getJson('/api/v1/messages?peer_id='.$a->id)->assertOk()->assertJsonCount(0, 'items')
            ->assertJsonPath('room_key', $current['room_key']);
        $newMessage = $this->send($b, $a, 'current consent');
        $this->assertNotSame($oldMessage['conversation_id'], $newMessage['conversation_id']);
        Sanctum::actingAs($a);
        $this->getJson('/api/v1/messages?peer_id='.$b->id)->assertOk()->assertJsonCount(1, 'items')
            ->assertJsonPath('items.0.id', $newMessage['id']);
        $this->assertDatabaseHas('chat_messages', ['id' => $oldMessage['id'], 'room_id' => $old['room_key']]);
    }

    private function befriend(User $a, User $b, string $key): void
    {
        Sanctum::actingAs($b);
        $this->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $token = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json('token');
        Sanctum::actingAs($a);
        $id = $this->postJson('/api/v1/social/requests', [
            'purpose' => 'friendship', 'invitation_token' => $token, 'idempotency_key' => $key,
        ])->assertCreated()->json('id');
        Sanctum::actingAs($b);
        $this->postJson('/api/v1/social/requests/'.$id.'/accept')->assertOk();
    }

    private function activate(User $a, User $b, ?array $prior = null): array
    {
        $service = app(LiveConsentService::class);
        $pending = $service->transition($a->id, $b->id, 'connection', 'request', $prior['revision'] ?? 0, $prior['id'] ?? null);
        $connectionId = $pending['connection']['id'];
        $service->transition($b->id, $a->id, 'connection', 'accept', 1, $connectionId);
        $service->transition($a->id, $b->id, 'consent', 'request', 0, $connectionId);
        $service->transition($b->id, $a->id, 'consent', 'accept', 1, $connectionId);

        return $service->current($a->id, $b->id);
    }

    private function upload(User $owner): int
    {
        Sanctum::actingAs($owner);
        $upload = UploadedFile::fake()->createWithContent('fixture.png', base64_decode(self::PNG));

        return $this->post('/api/v1/media', ['media_type' => 'image', 'file' => $upload], ['Accept' => 'application/json'])
            ->assertOk()->json('asset.id');
    }

    private function send(User $actor, User $peer, string $text, array $extra = []): array
    {
        Sanctum::actingAs($actor);

        return $this->postJson('/api/v1/messages', ['receiver_id' => $peer->id, 'content' => $text] + $extra)
            ->assertOk()->json();
    }
}
