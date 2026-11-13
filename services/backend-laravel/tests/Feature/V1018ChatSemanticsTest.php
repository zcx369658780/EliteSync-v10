<?php

namespace Tests\Feature;

use App\Domain\MessagingReplayContract;
use App\Models\ChatMessage;
use App\Models\MediaAsset;
use App\Models\MessageAttachment;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\MatchingInputService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** Isolated fixtures exercise the real HTTP controllers and current consent middleware. */
final class V1018ChatSemanticsTest extends TestCase
{
    use RefreshDatabase;
    use \Tests\Support\CreatesAcceptedMainMatch;

    private User $a;
    private User $b;
    private User $outsider;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'questionnaire.required_answer_count' => 1]);
        $this->a = $this->eligibleFixtureUser('19900001801', 'male');
        $this->b = $this->eligibleFixtureUser('19900001802', 'female');
        $this->outsider = User::factory()->create(['phone' => '19900001803', 'disabled' => false, 'is_synthetic' => false]);
        $this->createAcceptedMatchContext($this->a, $this->b);
        foreach ([[$this->a, $this->b, 'connection', 'request', 0], [$this->b, $this->a, 'connection', 'accept', 1],
            [$this->a, $this->b, 'consent', 'request', 0], [$this->b, $this->a, 'consent', 'accept', 1]] as [$actor, $peer, $kind, $action, $revision]) {
            Sanctum::actingAs($actor);
            $this->postJson('/api/v1/connections/'.$peer->id.'/'.$kind,
                ['action' => $action, 'expected_revision' => $revision])->assertOk();
        }
    }

    private function eligibleFixtureUser(string $phone, string $gender): User
    {
        // v10.1.7 made current inputs and questionnaire readiness prerequisites
        // for accepting the proposal fixture. These are isolated test data.
        $user = User::factory()->create(['phone' => $phone, 'disabled' => false, 'is_synthetic' => false,
            'verify_status' => 'approved', 'moderation_status' => 'normal', 'account_status' => 'active',
            'is_match_eligible' => true]);
        $question = QuestionnaireQuestion::firstOrCreate(['question_key' => 'v1018-chat-current'], [
            'category' => 'lifestyle', 'content' => 'Isolated chat fixture preference', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A'], ['option_id' => 'B']], 'enabled' => true, 'version' => 1]);
        QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $question->id,
            'answer_payload' => ['selected_answer' => ['A']], 'selected_answer_json' => ['A'],
            'acceptable_answers_json' => ['A'], 'importance' => 3, 'version' => 1]);
        app(MatchingInputService::class)->save($user->id, [
            'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02', 'gender' => $gender,
            'city_key' => '上海', 'relationship_goal' => 'marriage', 'age_mode' => 'adult_any',
            'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city', 'height_cm' => null,
            'education' => null, 'occupation' => null, 'marital_history' => null,
            'children_status' => null, 'children_intention' => null,
        ]);
        return $user->fresh();
    }

    private function send(User $sender, User $receiver, string $content, array $extra = []): int
    {
        Sanctum::actingAs($sender);
        return (int) $this->postJson('/api/v1/messages', $extra + ['receiver_id' => $receiver->id,
            'content' => $content, 'client_message_id' => (string) Str::uuid()])->assertOk()->json('id');
    }

    private function fixtureMessage(User $sender, User $receiver, string $content): ChatMessage
    {
        return ChatMessage::create(['room_id' => min($sender->id, $receiver->id).'_'.max($sender->id, $receiver->id),
            'sender_id' => $sender->id, 'receiver_id' => $receiver->id, 'content' => $content, 'is_read' => false]);
    }

    private function search(string $query, ?int $cursor = null)
    {
        return $this->getJson('/api/v1/messages/search?'.http_build_query(array_filter([
            'peer_id' => $this->a->id, 'query' => $query, 'before_id' => $cursor,
        ], fn ($value) => $value !== null)));
    }

    public function test_history_prefetch_search_and_own_send_preserve_unpresented_inbound_rows(): void
    {
        $first = $this->send($this->a, $this->b, '尚未呈现的旧消息');
        $second = $this->send($this->a, $this->b, '当前窗口消息');
        Sanctum::actingAs($this->b);
        $this->getJson('/api/v1/messages?peer_id='.$this->a->id.'&latest=1&limit=1')
            ->assertOk()->assertJsonPath('items.0.id', $second)->assertJsonPath('items.0.is_read', false);
        $this->getJson('/api/v1/conversations')->assertOk()->assertJsonPath('items.0.unread', 2);
        $this->search('消息')->assertOk()->assertJsonCount(2, 'items');
        $this->assertDatabaseHas('chat_messages', ['id' => $first, 'is_read' => false, 'read_at' => null]);
        $this->postJson('/api/v1/messages/ack', ['peer_id' => $this->a->id, 'message_ids' => [$second]])
            ->assertOk()->assertJsonPath('updated', 1);
        $this->send($this->b, $this->a, '本人发送不能清旧入站');
        $this->getJson('/api/v1/conversations')->assertOk()->assertJsonPath('items.0.unread', 1);
        $this->assertDatabaseHas('chat_messages', ['id' => $first, 'is_read' => false, 'read_at' => null]);
    }

    public function test_ack_is_exact_and_preserves_first_read_time_on_batch_and_single_replay(): void
    {
        $first = $this->send($this->a, $this->b, '保留间隙');
        $second = $this->send($this->a, $this->b, '明确呈现');
        Sanctum::actingAs($this->b);
        $this->postJson('/api/v1/messages/ack', ['peer_id' => $this->a->id, 'message_ids' => [$second]])
            ->assertOk()->assertJsonPath('acknowledged.0', $second)->assertJsonPath('updated', 1);
        $readAt = ChatMessage::findOrFail($second)->read_at->toISOString();
        $this->travel(10)->seconds();
        $this->postJson('/api/v1/messages/ack', ['peer_id' => $this->a->id, 'message_ids' => [$second]])
            ->assertOk()->assertJsonPath('updated', 0);
        $this->postJson('/api/v1/messages/read/'.$second)->assertOk()->assertJsonPath('updated', 0);
        $this->assertSame($readAt, ChatMessage::findOrFail($second)->read_at->toISOString());
        $this->assertDatabaseHas('chat_messages', ['id' => $first, 'is_read' => false]);
        $this->travelBack();
    }

    public function test_mixed_foreign_room_or_outbound_ack_ids_reject_the_whole_batch(): void
    {
        $valid = $this->send($this->a, $this->b, '合法入站');
        $foreign = $this->fixtureMessage($this->outsider, $this->b, '另一会话');
        $outbound = $this->send($this->b, $this->a, '本人出站');
        Sanctum::actingAs($this->b);
        foreach ([$foreign->id, $outbound] as $invalid) {
            $this->postJson('/api/v1/messages/ack', ['peer_id' => $this->a->id, 'message_ids' => [$valid, $invalid]])
                ->assertNotFound();
            $this->assertDatabaseHas('chat_messages', ['id' => $valid, 'is_read' => false, 'read_at' => null]);
        }
        Sanctum::actingAs($this->outsider);
        $this->postJson('/api/v1/messages/ack', ['peer_id' => $this->a->id, 'message_ids' => [$valid]])->assertNotFound();
    }

    public function test_search_scan_window_advances_over_zero_hits_and_does_not_mark_read(): void
    {
        $oldest = $this->fixtureMessage($this->a, $this->b, '中文Needle旧消息');
        for ($i = 0; $i < 205; $i++) {
            $this->fixtureMessage($this->a, $this->b, '无关记录 '.$i);
        }
        Sanctum::actingAs($this->b);
        $page = $this->search('中文needle')->assertOk()->assertJsonPath('scanned', 200)
            ->assertJsonCount(0, 'items')->assertJsonPath('has_more', true)->json();
        $this->search('中文NEEDLE', (int) $page['next_before_id'])->assertOk()
            ->assertJsonPath('scanned', 6)->assertJsonPath('items.0.id', $oldest->id)->assertJsonPath('has_more', false);
        $this->assertSame(206, ChatMessage::where('receiver_id', $this->b->id)->where('is_read', false)->count());
        $this->assertStringNotContainsString('中文Needle', $oldest->getRawOriginal('content'));
    }

    public function test_search_hit_limit_cursor_is_last_scanned_row_and_skips_no_hits(): void
    {
        $ids = [];
        for ($i = 0; $i < 25; $i++) {
            $ids[] = $this->fixtureMessage($this->a, $this->b, 'Match中文 '.$i)->id;
        }
        Sanctum::actingAs($this->b);
        $page = $this->search('match中文')->assertOk()->assertJsonPath('scanned', 20)
            ->assertJsonCount(20, 'items')->assertJsonPath('next_before_id', $ids[5])->assertJsonPath('has_more', true)->json();
        $next = $this->search('MATCH中文', (int) $page['next_before_id'])->assertOk()
            ->assertJsonCount(5, 'items')->assertJsonPath('has_more', false)->json();
        $this->assertSame(array_reverse($ids), array_column(array_merge($page['items'], $next['items']), 'id'));
        $this->search('')->assertUnprocessable();
        $this->search(str_repeat('长', 101))->assertUnprocessable();
    }

    public function test_search_and_reply_replay_recheck_current_permission(): void
    {
        $original = $this->send($this->a, $this->b, '当前权限内容');
        $key = (string) Str::uuid();
        $this->send($this->b, $this->a, '引用回复', ['client_message_id' => $key, 'reply_to_message_id' => $original]);
        UserBlock::create(['blocker_id' => $this->a->id, 'blocked_user_id' => $this->b->id]);
        Sanctum::actingAs($this->b);
        $this->search('内容')->assertNotFound();
        $this->postJson('/api/v1/messages', ['receiver_id' => $this->a->id, 'content' => '引用回复',
            'client_message_id' => $key, 'reply_to_message_id' => $original])->assertNotFound();
        $this->postJson('/api/v1/messages/ack', ['peer_id' => $this->a->id, 'message_ids' => [$original]])->assertNotFound();
        $this->assertDatabaseHas('chat_messages', ['id' => $original, 'is_read' => false]);
    }

    public function test_same_room_replies_are_bounded_and_media_quotes_expose_only_type(): void
    {
        $text = $this->send($this->a, $this->b, str_repeat('原文', 100));
        $reply = $this->send($this->b, $this->a, '文字引用', ['reply_to_message_id' => $text]);
        Sanctum::actingAs($this->a);
        $this->getJson('/api/v1/messages?peer_id='.$this->b->id.'&after_id='.($reply - 1))
            ->assertOk()->assertJsonPath('items.0.reply.id', $text)
            ->assertJsonPath('items.0.reply.summary', str_repeat('原文', 60));

        // Isolated media reference fixture. This checks quote projection, not binary playback.
        $mediaMessage = $this->fixtureMessage($this->a, $this->b, '');
        $asset = MediaAsset::create(['owner_user_id' => $this->a->id, 'media_type' => 'image',
            'storage_provider' => 'local', 'storage_disk' => 'v1007', 'storage_key' => 'private/quote.png',
            'mime_type' => 'image/png', 'status' => 'ready', 'public_url' => 'https://private.invalid/secret']);
        MessageAttachment::create(['message_id' => $mediaMessage->id, 'media_asset_id' => $asset->id,
            'attachment_type' => 'image', 'sort_order' => 0]);
        $mediaReply = $this->send($this->b, $this->a, '媒体引用', ['reply_to_message_id' => $mediaMessage->id]);
        Sanctum::actingAs($this->a);
        $projection = $this->getJson('/api/v1/messages?peer_id='.$this->b->id.'&after_id='.($mediaReply - 1))
            ->assertOk()->assertJsonPath('items.0.reply.summary', '[图片]')->json('items.0.reply');
        $this->assertSame(['id', 'available', 'summary'], array_keys($projection));
        $this->assertStringNotContainsString('http', json_encode($projection));
    }

    public function test_cross_room_reply_is_rejected_and_reply_identity_is_part_of_replay_fingerprint(): void
    {
        $first = $this->send($this->a, $this->b, '第一条');
        $second = $this->send($this->a, $this->b, '第二条');
        $foreign = $this->fixtureMessage($this->outsider, $this->b, '跨会话');
        Sanctum::actingAs($this->b);
        $countBeforeRejectedReply = ChatMessage::count();
        $this->postJson('/api/v1/messages', ['receiver_id' => $this->a->id, 'content' => '非法引用',
            'reply_to_message_id' => $foreign->id])->assertUnprocessable();
        $this->assertSame($countBeforeRejectedReply, ChatMessage::count());
        $key = (string) Str::uuid();
        $body = ['receiver_id' => $this->a->id, 'content' => '同一逻辑回复', 'client_message_id' => $key,
            'reply_to_message_id' => $first];
        $saved = $this->postJson('/api/v1/messages', $body)->assertOk()->json('id');
        $this->postJson('/api/v1/messages', $body)->assertOk()->assertJsonPath('id', $saved)
            ->assertJsonPath('idempotent_replay', true);
        $this->postJson('/api/v1/messages', array_replace($body, ['reply_to_message_id' => $second]))
            ->assertStatus(409)->assertJsonPath('code', 'client_message_id_payload_mismatch');
        $this->assertSame(1, ChatMessage::where('sender_id', $this->b->id)->where('client_message_id', $key)->count());
        $this->assertSame($countBeforeRejectedReply + 1, ChatMessage::count());
    }

    public function test_absent_reply_preserves_the_preexisting_fingerprint_bytes(): void
    {
        $legacy = hash('sha256', json_encode(['receiver_id' => 17, 'content' => '旧载荷', 'attachment_ids' => [8, 3]],
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
        $this->assertSame($legacy, MessagingReplayContract::fingerprint(17, '旧载荷', [8, 3]));
        $this->assertSame($legacy, MessagingReplayContract::fingerprint(17, '旧载荷', [8, 3], null));
        $this->assertNotSame($legacy, MessagingReplayContract::fingerprint(17, '旧载荷', [8, 3], 42));
    }
}
