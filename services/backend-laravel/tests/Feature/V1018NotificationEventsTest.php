<?php

namespace Tests\Feature;

use App\Domain\NotificationDeliveryContract;
use App\Models\AppNotificationItem;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\NotificationService;
use App\Services\MatchingInputService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use PHPUnit\Framework\Attributes\DataProvider;
use RuntimeException;
use Tests\TestCase;

/** Isolated fixtures exercise ordinary business writers; device/media evidence is separate. */
final class V1018NotificationEventsTest extends TestCase
{
    use RefreshDatabase;

    private User $a;
    private User $b;
    private User $outsider;
    private string $proposalId;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'questionnaire.required_answer_count' => 1,
            'rtc_guard.enabled' => true]);
        $this->a = $this->eligibleUser('19900001811', 'male');
        $this->b = $this->eligibleUser('19900001812', 'female');
        $this->outsider = User::factory()->create(['phone' => '19900001813', 'disabled' => false]);
        $this->proposalId = $this->pendingProposalFixture();
    }

    private function eligibleUser(string $phone, string $gender): User
    {
        $user = User::factory()->create(['phone' => $phone, 'disabled' => false, 'is_synthetic' => false,
            'verify_status' => 'approved', 'moderation_status' => 'normal', 'account_status' => 'active',
            'is_match_eligible' => true]);
        $question = QuestionnaireQuestion::firstOrCreate(['question_key' => 'v1018-notification-current'], [
            'category' => 'lifestyle', 'content' => 'Isolated notification fixture preference',
            'question_type' => 'single_choice', 'options' => [['option_id' => 'A']], 'enabled' => true, 'version' => 1]);
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

    /** Same pending main-proposal fixture shape as CreatesAcceptedMainMatch, before decisions. */
    private function pendingProposalFixture(): string
    {
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        DB::table('dating_round_channels')->insert(['channel_key' => 'v1018-notice-fixture'] + $stamp);
        $round = DB::table('dating_rounds')->insertGetId(['round_key' => (string) Str::uuid(),
            'channel_key' => 'v1018-notice-fixture', 'cadence_key' => (string) Str::uuid(),
            'state' => 'revealed', 'created_by_type' => 'test', 'source' => 'test'] + $stamp);
        $run = DB::table('matching_runs')->insertGetId(['round_id' => $round, 'run_key' => (string) Str::uuid(),
            'idempotency_key' => (string) Str::uuid(), 'correlation_id' => (string) Str::uuid(),
            'attempt_no' => 1, 'state' => 'succeeded', 'trigger_source' => 'test', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'test', 'config_version' => 'test'] + $stamp);
        $match = DB::table('dating_matches')->insertGetId(['week_tag' => 'v1018-notice-fixture',
            'round_id' => $round, 'matching_run_id' => $run, 'user_a' => $this->a->id,
            'user_b' => $this->b->id, 'drop_released' => true] + $stamp);
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert(['id' => $id, 'dating_match_id' => $match, 'round_id' => $round,
            'run_id' => $run, 'user_a' => $this->a->id, 'user_b' => $this->b->id,
            'generation_a' => 1, 'generation_b' => 1, 'revealed_at' => now(), 'expires_at' => now()->addHours(168)] + $stamp);
        foreach ([$this->a, $this->b] as $user) {
            DB::table('matching_participations')->insert(['user_id' => $user->id, 'state' => 'ACTIVE',
                'generation' => 1, 'revision' => 1, 'opted_in_at' => now()] + $stamp);
            DB::table('match_proposal_slots')->insert(['user_id' => $user->id, 'proposal_id' => $id]);
        }
        return $id;
    }

    private function proposalDecision(User $actor, string $action, int $revision, string $key): array
    {
        Sanctum::actingAs($actor);
        return $this->postJson('/api/v1/journey/proposals/'.$this->proposalId.'/decision',
            ['action' => $action, 'revision' => $revision, 'idempotency_key' => $key])->assertOk()->json();
    }

    private function acceptedProposal(): void
    {
        $this->proposalDecision($this->a, 'accept', 1, 'notice-fixture-accept-a');
        $this->proposalDecision($this->b, 'accept', 2, 'notice-fixture-accept-b');
    }

    private function transition(User $actor, User $peer, string $kind, string $action, int $revision): array
    {
        $noticeKind = $kind === 'connection' ? 'consent_connection' : 'consent_message';
        $before = AppNotificationItem::where('kind', $noticeKind)->count();
        $result = app(LiveConsentService::class)->transition($actor->id, $peer->id, $kind, $action, $revision);
        $event = DB::table('live_consent_events')->latest('id')->first();
        $this->assertSame($before + 1, AppNotificationItem::where('kind', $noticeKind)->count());
        $notice = AppNotificationItem::where('source_event_key', 'consent-event:'.$event->id)->sole();
        $this->assertSame($peer->id, (int) $notice->user_id);
        $this->assertSame($noticeKind, $notice->kind);
        $this->assertSame('system', NotificationDeliveryContract::category($notice->kind));
        $this->assertSame((int) $event->connection_id, $notice->payload['connection_id']);
        return $result;
    }

    public static function connectionTerminals(): array
    {
        return [['decline'], ['withdraw'], ['close']];
    }

    #[DataProvider('connectionTerminals')]
    public function test_connection_lifecycle_notifies_the_other_participant_once(string $terminal): void
    {
        $this->acceptedProposal();
        $this->transition($this->a, $this->b, 'connection', 'request', 0);
        if ($terminal === 'close') {
            $this->transition($this->b, $this->a, 'connection', 'accept', 1);
            $this->transition($this->a, $this->b, 'connection', 'close', 2);
        } else {
            $actor = $terminal === 'withdraw' ? $this->a : $this->b;
            $peer = $terminal === 'withdraw' ? $this->b : $this->a;
            $this->transition($actor, $peer, 'connection', $terminal, 1);
        }
        $notice = AppNotificationItem::where('kind', 'consent_connection')->latest('id')->firstOrFail();
        $projection = app(NotificationService::class)->presentationForUser($notice, (int) $notice->user_id);
        $this->assertSame('connection_current', $projection['payload']['route_name']);
    }

    public static function messageConsentTerminals(): array
    {
        return [['decline', 'MC_DECLINED'], ['withdraw', 'MC_WITHDRAWN'], ['revoke', 'MC_REVOKED']];
    }

    #[DataProvider('messageConsentTerminals')]
    public function test_dual_purpose_message_consent_emits_one_notice_per_user_action(string $terminal, string $state): void
    {
        $this->acceptedProposal();
        $this->transition($this->a, $this->b, 'connection', 'request', 0);
        $cn = $this->transition($this->b, $this->a, 'connection', 'accept', 1);
        $this->transition($this->a, $this->b, 'consent', 'request', 0);
        if ($terminal === 'revoke') {
            $this->transition($this->b, $this->a, 'consent', 'accept', 1);
            $this->transition($this->a, $this->b, 'consent', 'revoke', 2);
        } else {
            $actor = $terminal === 'withdraw' ? $this->a : $this->b;
            $peer = $terminal === 'withdraw' ? $this->b : $this->a;
            $this->transition($actor, $peer, 'consent', $terminal, 1);
        }
        $this->assertSame(2, DB::table('messaging_consents')->where('connection_id', $cn['connection']['id'])
            ->where('state', $state)->count());
        $this->assertSame($terminal === 'revoke' ? 3 : 2, AppNotificationItem::where('kind', 'consent_message')->count());
    }

    public function test_business_rollback_leaves_neither_state_change_nor_notice(): void
    {
        $this->acceptedProposal();
        $before = AppNotificationItem::count();
        try {
            DB::transaction(function () {
                app(LiveConsentService::class)->transition($this->a->id, $this->b->id, 'connection', 'request', 0);
                throw new RuntimeException('named fixture rollback');
            });
            $this->fail('Fixture must roll back');
        } catch (RuntimeException $error) {
            $this->assertSame('named fixture rollback', $error->getMessage());
        }
        $this->assertSame($before, AppNotificationItem::count());
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('live_consent_events', 0);
    }

    public function test_stable_event_identity_survives_time_and_notification_ids_are_owner_scoped(): void
    {
        $service = app(NotificationService::class);
        $first = $service->createForUser($this->a->id, 'system', 'Fixture event', sourceEventKey: 'fixture:event:version:1');
        $this->travel(6)->minutes();
        $again = $service->createForUser($this->a->id, 'system', 'Replayed event', sourceEventKey: 'fixture:event:version:1');
        $otherRecipient = $service->createForUser($this->b->id, 'system', 'Same event, other recipient', sourceEventKey: 'fixture:event:version:1');
        $this->assertSame($first->id, $again->id);
        $this->assertNotSame($first->id, $otherRecipient->id);
        $this->assertSame(2, AppNotificationItem::where('source_event_key', 'fixture:event:version:1')->count());
        Sanctum::actingAs($this->a);
        $this->getJson('/api/v1/notifications/'.$first->id)->assertOk()->assertJsonPath('item.is_read', false);
        $this->getJson('/api/v1/notifications/'.$otherRecipient->id)->assertNotFound();
        $this->postJson('/api/v1/notifications/'.$otherRecipient->id.'/read')->assertNotFound();
        $this->assertNull($otherRecipient->fresh()->read_at);
        $this->travelBack();
    }

    public static function proposalActions(): array
    {
        return [['accept'], ['decline'], ['withdraw']];
    }

    #[DataProvider('proposalActions')]
    public function test_proposal_decisions_notify_peer_and_replay_has_no_second_event(string $action): void
    {
        $this->proposalDecision($this->a, $action, 1, 'fixture-notice-decision');
        $notice = AppNotificationItem::where('kind', 'match_decision')->sole();
        $this->assertSame($this->b->id, (int) $notice->user_id);
        $this->assertSame('proposal:'.$this->proposalId.':2', $notice->source_event_key);
        $this->assertSame('match', NotificationDeliveryContract::category($notice->kind));
        $this->proposalDecision($this->a, $action, 1, 'fixture-notice-decision');
        $this->assertSame(1, AppNotificationItem::where('kind', 'match_decision')->count());
        $projection = app(NotificationService::class)->presentationForUser($notice, $this->b->id);
        $this->assertSame('match_result', $projection['payload']['route_name']);
        $this->assertArrayNotHasKey('showcase', $projection['payload']);
    }

    public static function reviewResults(): array
    {
        return [['approved'], ['rejected'], ['needs_revision']];
    }

    #[DataProvider('reviewResults')]
    public function test_web_showcase_review_notifies_owner_without_publication_or_sensitive_feedback(string $result): void
    {
        $fields = ['display_name' => 'Fictional showcase', 'city' => 'Development City', 'relationship_goal' => 'marriage',
            'self_intro' => 'Isolated reviewed introduction', 'interest_tags' => ['阅读'], 'lifestyle_tags' => [],
            'opener_note' => '', 'photo_ids' => [], 'audiences' => ['friends']];
        $this->actingAs($this->a, 'sanctum')->putJson('/api/v1/profile/showcase/draft',
            ['expected_revision' => 0] + $fields)->assertOk();
        $submission = $this->postJson('/api/v1/profile/showcase/draft/submit-review', ['expected_revision' => 1])
            ->assertOk()->json('submission');
        $this->assertSame(0, AppNotificationItem::where('kind', 'showcase_review')->count());
        $admin = User::factory()->create(['phone' => '19900001814', 'role' => 'admin', 'disabled' => false]);
        config(['app.admin_phones' => [$admin->phone]]);
        $this->actingAs($admin, 'web')->post('/admin/showcase/'.$submission['id'], ['expected_revision' => 1,
            'result' => $result, 'reason' => 'PRIVATE_FIXTURE_REVIEW_FEEDBACK', 'confirm' => '1'])
            ->assertRedirect('/admin/showcase/'.$submission['id']);
        $notice = AppNotificationItem::where('kind', 'showcase_review')->sole();
        $this->assertSame($this->a->id, (int) $notice->user_id);
        $this->assertSame('showcase-review:'.$submission['id'], $notice->source_event_key);
        $this->assertSame('system', NotificationDeliveryContract::category($notice->kind));
        $this->assertStringNotContainsString('PRIVATE_FIXTURE', json_encode([$notice->title, $notice->body, $notice->payload]));
        $this->actingAs($this->a, 'sanctum')->getJson('/api/v1/notifications/'.$notice->id)
            ->assertOk()->assertJsonPath('item.route_name', 'showcase_current');
        $this->getJson('/api/v1/profile/showcase/publication')->assertOk()->assertJsonPath('publication', null);
        $this->assertDatabaseHas('profile_showcase_submissions', ['id' => $submission['id'], 'state' => $result]);
    }

    public function test_terminal_rtc_notices_and_old_invite_resolve_to_read_only_result(): void
    {
        $this->acceptedProposal();
        $this->transition($this->a, $this->b, 'connection', 'request', 0);
        $this->transition($this->b, $this->a, 'connection', 'accept', 1);
        $this->transition($this->a, $this->b, 'consent', 'request', 0);
        $this->transition($this->b, $this->a, 'consent', 'accept', 1);
        Sanctum::actingAs($this->a);
        $id = (int) $this->postJson('/api/v1/rtc/calls', ['peer_user_id' => $this->b->id, 'mode' => 'voice'])
            ->assertOk()->json('session.id');
        $invite = AppNotificationItem::where('kind', 'rtc_call_invite')->sole();
        Sanctum::actingAs($this->b);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/reject')->assertOk();
        $results = AppNotificationItem::where('kind', 'rtc_call_result')->get();
        $this->assertSame(2, $results->count());
        $this->assertSame([$this->a->id, $this->b->id], $results->pluck('user_id')->map(fn ($value) => (int) $value)->sort()->values()->all());
        foreach ($results as $notice) {
            $this->assertSame('rtc:'.$id.':rtc_call_result', $notice->source_event_key);
            $this->assertSame('rtc', NotificationDeliveryContract::category($notice->kind));
            $projection = app(NotificationService::class)->presentationForUser($notice, (int) $notice->user_id);
            $this->assertSame('rtc_call_result', $projection['payload']['route_name']);
        }
        $this->getJson('/api/v1/notifications/'.$invite->id)->assertOk()->assertJsonPath('item.route_name', 'rtc_call_result');
        $this->postJson('/api/v1/rtc/calls/'.$id.'/accept')->assertStatus(409);
        $this->assertSame(2, AppNotificationItem::where('kind', 'rtc_call_result')->count());
        Sanctum::actingAs($this->outsider);
        $this->getJson('/api/v1/notifications/'.$invite->id)->assertNotFound();
    }
}
