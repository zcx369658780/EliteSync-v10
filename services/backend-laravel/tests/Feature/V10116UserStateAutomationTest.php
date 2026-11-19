<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\AutomationService;
use App\Services\MatchingInputService;
use App\Services\MatchingRoundService;
use App\Services\SlowDatingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class V10116UserStateAutomationTest extends TestCase
{
    use RefreshDatabase;

    private const URL = '/api/v1/automations/weekly_slow_dating_participation';

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'questionnaire.required_answer_count' => 1]);
        Sanctum::actingAs(User::factory()->create(['phone' => 'b2-'.Str::lower(Str::random(16)), 'disabled' => false]));
    }

    private function ready(): User
    {
        $user = auth()->user();
        $this->authorizeTestParticipation($user);
        $user->update(['verify_status' => 'approved']);
        app(MatchingInputService::class)->save($user->id, [
            'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02', 'gender' => 'male',
            'city_key' => '上海', 'relationship_goal' => 'marriage', 'age_mode' => 'adult_any',
            'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city',
        ]);
        $q = QuestionnaireQuestion::create(['question_key' => 'b2-fixture',
            'category' => 'test', 'content' => 'Fixture', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A']], 'enabled' => true, 'version' => 1]);
        QuestionnaireAnswer::create(['user_id' => $user->id,
            'questionnaire_question_id' => $q->id, 'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        $this->completeLifestyleFixture($user->id);

        return $user->fresh();
    }

    private function command(string $action, int $revision, array $extra = []): array
    {
        return array_merge(['action' => $action, 'expected_revision' => $revision,
            'policy_version' => 'weekly_participation_v1', 'consent_version' => 'weekly_consent_v1',
            'request_key' => (string) Str::uuid()], $extra);
    }

    /** Existing FK facts for controlled proposal tests, without a matching consumer. */
    private function proposalFixture(User $user, object $round, mixed $expiresAt): string
    {
        $peer = User::factory()->create(['phone' => 'b2-peer-'.Str::lower(Str::random(16)), 'name' => 'PEER_PRIVATE_B2']);
        $this->authorizeTestParticipation($peer);
        $run = DB::table('matching_runs')->insertGetId(['round_id' => $round->id,
            'run_key' => (string) Str::uuid(), 'idempotency_key' => (string) Str::uuid(),
            'correlation_id' => (string) Str::uuid(), 'attempt_no' => 1, 'state' => 'succeeded',
            'trigger_source' => 'controlled-fixture', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'fixture', 'config_version' => 'fixture',
            'created_at' => now(), 'updated_at' => now()]);
        $match = DatingMatch::create(['round_id' => $round->id, 'matching_run_id' => $run,
            'week_tag' => 'b2-fixture', 'user_a' => $user->id, 'user_b' => $peer->id, 'drop_released' => true]);
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert(['id' => $id, 'dating_match_id' => $match->id,
            'round_id' => $round->id, 'run_id' => $run, 'user_a' => $user->id, 'user_b' => $peer->id,
            'generation_a' => 1, 'generation_b' => 0, 'state' => 'PENDING', 'decision_a' => 'PENDING',
            'decision_b' => 'PENDING', 'revision' => 1, 'revealed_at' => now(), 'expires_at' => $expiresAt,
            'created_at' => now(), 'updated_at' => now()]);
        DB::table('match_proposal_slots')->insert(['user_id' => $user->id, 'proposal_id' => $id]);

        return $id;
    }

    public function test_state_is_private_read_only_minimal_and_tracks_sources(): void
    {
        $user = auth()->user();
        $user->update(['name' => 'PRIVATE-NAME-B2', 'private_birth_place' => 'PRIVATE-PLACE-B2']);
        $before = DB::table('users')->where('id', $user->id)->first();
        $reply = $this->getJson('/api/v1/user-state')->assertOk()
            ->assertHeader('Cache-Control', 'no-store, private')
            ->assertJsonPath('contract_version', 'user_state_v1')
            ->assertJsonPath('subject_user_id', $user->id)
            ->assertJsonPath('domains.readiness.questionnaire_revision', 0)
            ->assertJsonPath('domains.automation.code', 'OFF')
            ->assertJsonPath('domains.lifestyle.code', 'not_started');
        $this->assertStringNotContainsString('PRIVATE-NAME-B2', $reply->getContent());
        $this->assertStringNotContainsString('PRIVATE-PLACE-B2', $reply->getContent());
        $this->assertEquals($before, DB::table('users')->where('id', $user->id)->first());
        $this->assertDatabaseCount('automation_authorizations', 0);
        $this->assertDatabaseCount('automation_tasks', 0);
        $this->getJson('/api/v1/user-state?user_id=999')->assertUnprocessable();
        $this->completeLifestyleFixture($user->id);
        $this->getJson('/api/v1/user-state')->assertJsonPath('domains.lifestyle.code', 'completed')
            ->assertJsonPath('domains.lifestyle.source_revision', 5);
        Sanctum::actingAs(User::factory()->create(['phone' => 'b2-other', 'disabled' => false]));
        $this->getJson('/api/v1/user-state')->assertJsonPath('domains.lifestyle.code', 'not_started');
    }

    public function test_authorization_default_off_cas_retry_and_lifecycle(): void
    {
        $this->getJson('/api/v1/automations')->assertOk()->assertJsonPath('code', 'OFF');
        $this->putJson(self::URL, $this->command('grant', 0))->assertForbidden();
        $this->ready();
        $body = $this->command('grant', 0);
        $this->putJson(self::URL, $body)->assertOk()->assertJsonPath('code', 'ACTIVE')
            ->assertJsonPath('source_revision', 1)->assertJsonPath('expires_at', null);
        $this->putJson(self::URL, $body)->assertOk()->assertJsonPath('source_revision', 1);
        $this->putJson(self::URL, array_replace($body, ['action' => 'revoke']))->assertConflict();
        $this->putJson(self::URL, $this->command('pause', 0))->assertConflict();
        $this->putJson(self::URL, $this->command('pause', 1))->assertOk()->assertJsonPath('code', 'PAUSED');
        $this->putJson(self::URL, $this->command('resume', 2))->assertOk()->assertJsonPath('code', 'ACTIVE');
        $this->putJson(self::URL, $this->command('revoke', 3))->assertOk()->assertJsonPath('code', 'REVOKED');
        $this->putJson(self::URL, $this->command('resume', 4))->assertConflict();
        $this->assertDatabaseCount('matching_participations', 0);
    }

    public function test_rejects_forged_scope_commands_and_policy_versions(): void
    {
        $this->ready();
        foreach ([['policy_version' => 'future'], ['consent_version' => 'future'], ['user_id' => 1],
            ['command' => 'run-matching'], ['url' => 'https://example.com'], ['action' => 'execute']] as $extra) {
            $this->putJson(self::URL, array_replace($this->command('grant', 0), $extra))->assertUnprocessable();
        }
        $this->putJson('/api/v1/automations/arbitrary', $this->command('grant', 0))->assertNotFound();
        $this->assertDatabaseCount('automation_authorizations', 0);
    }

    public function test_tick_waits_for_existing_round_and_executes_once_without_matching_run(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        $service = app(AutomationService::class);
        $service->tick('b2-worker', 10);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'SKIPPED', 'result_code' => 'NO_OPEN_ROUND']);
        $this->assertDatabaseCount('matching_participations', 0);
        app(MatchingRoundService::class)->prepare('default', 'b2-controlled-fixture', now(), now()->addHour(), 'test', null);
        $service->tick('b2-worker', 10);
        $this->assertDatabaseHas('matching_participations', ['user_id' => $user->id, 'state' => 'ACTIVE', 'revision' => 2]);
        $this->assertDatabaseCount('automation_effects', 1);
        $service->tick('b2-worker', 10);
        $this->assertSame(2, DB::table('matching_participations')->where('user_id', $user->id)->value('revision'));
        $this->assertDatabaseCount('automation_effects', 1);
        foreach (['matching_runs', 'match_proposals', 'product_connections', 'messaging_consents', 'formal_relationships'] as $table) {
            $this->assertDatabaseCount($table, 0);
        }
        $this->assertDatabaseCount('dating_rounds', 1);
    }

    public function test_revoke_after_claim_fences_worker_and_pauses_only_participation(): void
    {
        $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'b2-race-fixture', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->schedule(10);
        $claim = $service->claim('b2-worker');
        $this->assertNotNull($claim);
        $this->putJson(self::URL, $this->command('revoke', 1))->assertOk();
        $service->apply($claim);
        $this->assertDatabaseCount('automation_effects', 0);
        $this->assertDatabaseCount('matching_participations', 0);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'CANCELLED']);
    }

    public function test_lost_ack_reconciles_committed_effect_without_repeating_participation(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'b2-unknown-fixture', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->schedule(10);
        $claim = $service->claim('old-worker');
        $service->apply($claim);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'RUNNING']);
        $this->assertDatabaseCount('automation_effects', 1);
        $this->travel(2)->minutes();
        $service->tick('recovery-worker', 10);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'SUCCEEDED', 'result_code' => 'RECONCILED_EFFECT']);
        $this->assertSame(2, DB::table('matching_participations')->where('user_id', $user->id)->value('revision'));
        $service->complete($claim);
        $this->assertDatabaseCount('automation_effects', 1);
    }

    public function test_expiry_and_manual_pause_stop_future_delegated_participation(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0, ['expires_at' => now()->addMinute()->toISOString()]))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'b2-expiry-fixture', now(), now()->addHour(), 'test', null);
        app(AutomationService::class)->tick('worker', 10);
        $this->assertTrue(app(SlowDatingService::class)->enrolled($user->id));
        $this->travel(2)->minutes();
        $this->assertFalse(app(SlowDatingService::class)->enrolled($user->id));
        $this->getJson('/api/v1/automations')->assertJsonPath('code', 'EXPIRED');
        app(AutomationService::class)->tick('worker', 10);
        $this->assertDatabaseHas('matching_participations', ['user_id' => $user->id, 'state' => 'PAUSED']);
        $this->putJson(self::URL, $this->command('grant', 2))->assertOk();
        app(SlowDatingService::class)->participate($user->id, 'pause', 3, '');
        $this->getJson('/api/v1/automations')->assertJsonPath('code', 'PAUSED');
    }

    public function test_draft_keeps_delegated_expiry_and_round_binding(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0, ['expires_at' => now()->addMinute()->toISOString()]))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'draft-binding', now(), now()->addHour(), 'test', null);
        app(AutomationService::class)->tick('worker', 10);
        app(SlowDatingService::class)->participate($user->id, 'draft', 2, 'Private intent');
        $this->assertNotNull(DB::table('matching_participations')->where('user_id', $user->id)->value('automation_authorization_id'));
        $this->travel(2)->minutes();
        $this->assertFalse(app(SlowDatingService::class)->enrolled($user->id));
    }

    #[DataProvider('acknowledgements')]
    public function test_same_cycle_resume_recoordinates_current_authority_once(bool $acknowledged): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'resume-binding', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->schedule(10);
        $claim = $service->claim('worker');
        $service->apply($claim);
        if ($acknowledged) {
            $service->complete($claim);
        }
        $this->putJson(self::URL, $this->command('pause', 1))->assertOk();
        $this->putJson(self::URL, $this->command('resume', 2))->assertOk();
        $service->tick('resumed-worker', 10);
        $service->complete($claim);
        $this->assertDatabaseHas('matching_participations', ['user_id' => $user->id, 'state' => 'ACTIVE', 'generation' => 2, 'revision' => 5]);
        $this->assertDatabaseCount('automation_tasks', 1);
        $this->assertDatabaseCount('automation_effects', 1);
        $this->assertSame(3, DB::table('automation_effects')->value('authorization_revision'));
        $service->tick('repeat-worker', 10);
        $this->assertSame(5, DB::table('matching_participations')->where('user_id', $user->id)->value('revision'));
    }

    public static function acknowledgements(): array
    {
        return [[true], [false]];
    }

    public function test_unknown_without_effect_reconciles_before_bounded_retry_and_fences_old_worker(): void
    {
        $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'bounded-retries', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->schedule(10);
        $stale = null;
        for ($attempt = 1; $attempt <= 3; $attempt++) {
            $claim = $service->claim('attempt-'.$attempt);
            $this->assertSame($attempt, $claim->attempt_count);
            $this->travel(2)->minutes();
            $recovery = $service->claim('reconcile-'.$attempt);
            $this->assertSame('UNKNOWN', $recovery->state);
            $service->apply($claim);
            $this->assertDatabaseCount('automation_effects', 0);
            $service->apply($recovery);
            $stale = $claim;
            $this->travel(3)->minutes();
        }
        $service->tick('final-worker', 10);
        $service->apply($stale);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'FAILED', 'attempt_count' => 3,
            'result_code' => 'RETRY_EXHAUSTED', 'reconciliation' => 'NO_EFFECT_CONFIRMED']);
        $this->assertDatabaseCount('automation_effects', 0);
    }

    public function test_policy_change_invalidates_existing_authority_without_silent_new_grant(): void
    {
        $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        config(['user_automation.policy_version' => 'weekly_participation_v2']);
        $this->getJson('/api/v1/automations')->assertJsonPath('code', 'EXPIRED');
        app(AutomationService::class)->tick('worker', 10);
        $this->assertDatabaseHas('automation_authorizations', ['state' => 'EXPIRED', 'revision' => 2]);
        $this->assertDatabaseCount('automation_effects', 0);
        $this->putJson(self::URL, $this->command('resume', 2))->assertUnprocessable();
    }

    public function test_read_only_state_preserves_expired_proposal_and_filters_peer_fields(): void
    {
        $user = $this->ready();
        $round = app(MatchingRoundService::class)->prepare('default', 'b2-pure-read', now(), now()->addHour(), 'test', null);
        $id = $this->proposalFixture($user, $round, now()->subMinute());
        DB::table('dating_rounds')->where('id', $round->id)->update(['state' => 'revealed']);
        $before = DB::table('match_proposals')->where('id', $id)->first();
        $audits = DB::table('journey_audits')->count();
        $reply = $this->getJson('/api/v1/user-state')->assertOk()
            ->assertJsonPath('domains.proposal.code', 'RECONCILIATION_REQUIRED');
        $this->assertStringNotContainsString('PEER_PRIVATE_B2', $reply->getContent());
        $this->assertJsonStringEqualsJsonString(json_encode($before), json_encode(DB::table('match_proposals')->where('id', $id)->first()));
        $this->assertDatabaseCount('match_proposal_slots', 1);
        $this->assertDatabaseCount('journey_audits', $audits);
    }

    public function test_natural_proposal_expiry_allows_next_cycle_without_user_get(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        $old = app(MatchingRoundService::class)->prepare('default', 'b2-old-cycle', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->tick('first-worker', 10);
        $proposal = $this->proposalFixture($user, $old, now()->addMinute());
        // Controlled archived-round fixture. No administrator operation is executed by automation.
        DB::table('dating_rounds')->where('id', $old->id)->update(['state' => 'closed']);
        DB::table('dating_round_channels')->where('channel_key', 'default')->update(['active_round_id' => null]);
        $next = app(MatchingRoundService::class)->prepare('default', 'b2-next-cycle', now(), now()->addHour(), 'test', null);
        $this->assertFalse(app(SlowDatingService::class)->enrolled($user->id));
        $service->tick('second-worker', 10);
        $this->assertDatabaseHas('automation_tasks', ['round_id' => $next->id, 'state' => 'SKIPPED', 'result_code' => 'EXISTING_PROPOSAL']);
        $this->travel(2)->minutes();
        $service->tick('deadline-worker', 10);
        $this->assertDatabaseHas('match_proposals', ['id' => $proposal, 'state' => 'EXPIRED']);
        $this->assertDatabaseHas('automation_tasks', ['round_id' => $next->id, 'state' => 'SUCCEEDED']);
        $this->assertTrue(app(SlowDatingService::class)->enrolled($user->id));
        $this->assertDatabaseCount('automation_effects', 2);
        $this->assertDatabaseCount('matching_runs', 1);
    }

    public function test_existing_manual_participant_stays_off_across_migration_rollback_and_upgrade(): void
    {
        $user = $this->ready();
        app(SlowDatingService::class)->participate($user->id, 'opt_in', 0, 'Fictional intent');
        $before = app(SlowDatingService::class)->participation($user->id);
        $migration = require database_path('migrations/2026_11_15_220000_create_user_automation.php');
        $migration->down();
        $this->assertFalse(Schema::hasTable('automation_authorizations'));
        $migration->up();
        $this->getJson('/api/v1/user-state')->assertOk()->assertJsonPath('domains.automation.code', 'OFF')
            ->assertJsonPath('domains.participation.code', 'ACTIVE')
            ->assertJsonPath('domains.participation.delegated', false);
        app(AutomationService::class)->tick('legacy-worker', 10);
        $this->assertDatabaseCount('automation_authorizations', 0);
        $this->assertDatabaseCount('automation_tasks', 0);
        $this->assertEquals($before, app(SlowDatingService::class)->participation($user->id));
    }

    public function test_changed_qualification_is_checked_after_claim_before_effect(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'qualification-race', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->schedule(10);
        $claim = $service->claim('qualification-worker');
        $user->update(['is_match_eligible' => false]);
        $service->apply($claim);
        $service->complete($claim);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'SKIPPED', 'result_code' => 'matching_participation_excluded']);
        $this->assertDatabaseCount('automation_effects', 0);
        $this->assertDatabaseCount('matching_participations', 0);
        $this->getJson('/api/v1/user-state')->assertOk()
            ->assertJsonPath('domains.readiness.code', 'matching_participation_excluded');
        $user->update(['is_match_eligible' => true]);
        $service->tick('qualification-restored-worker', 10);
        $this->assertDatabaseHas('automation_tasks', ['state' => 'SUCCEEDED']);
        $this->assertDatabaseCount('automation_effects', 1);
    }

    public function test_paused_authority_does_not_schedule_or_change_current_proposal(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        $round = app(MatchingRoundService::class)->prepare('default', 'pause-proposal', now(), now()->addHour(), 'test', null);
        $proposal = $this->proposalFixture($user, $round, now()->addHour());
        $before = DB::table('match_proposals')->where('id', $proposal)->first();
        $this->putJson(self::URL, $this->command('pause', 1))->assertOk();
        app(AutomationService::class)->tick('paused-worker', 10);
        $this->assertDatabaseCount('automation_tasks', 0);
        $this->assertEquals($before, DB::table('match_proposals')->where('id', $proposal)->first());
        $this->assertDatabaseCount('match_proposal_slots', 1);
        $this->putJson(self::URL, $this->command('revoke', 2))->assertOk();
        app(AutomationService::class)->tick('revoked-worker', 10);
        $this->assertDatabaseCount('automation_tasks', 0);
        $this->assertEquals($before, DB::table('match_proposals')->where('id', $proposal)->first());
    }

    #[DataProvider('r1StopActions')]
    public function test_r1_unbound_manual_participation_survives_authorization_stop(string $action): void
    {
        $user = $this->ready();
        $this->putJson('/api/v1/journey/participation', [
            'action' => 'opt_in', 'revision' => 0, 'intent' => 'R1 independent manual intent',
        ])->assertOk();
        $before = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $extra = $action === 'expiry' ? ['expires_at' => now()->addMinute()->toISOString()] : [];
        $this->putJson(self::URL, $this->command('grant', 0, $extra))->assertOk();
        $this->travel(2)->minutes();
        if (in_array($action, ['pause', 'revoke'], true)) {
            $this->putJson(self::URL, $this->command($action, 1))->assertOk();
        } else {
            if ($action === 'policy') {
                config(['user_automation.policy_version' => 'weekly_participation_v2']);
            }
            app(AutomationService::class)->tick('r1-manual-expiry', 10);
            $this->getJson('/api/v1/automations')->assertJsonPath('code', 'EXPIRED');
        }
        $this->assertEquals($before, DB::table('matching_participations')->where('user_id', $user->id)->first());
        $this->assertDatabaseCount('automation_effects', 0);
        $this->getJson('/api/v1/user-state')->assertOk()
            ->assertJsonPath('domains.participation.code', 'ACTIVE')
            ->assertJsonPath('domains.participation.delegated', false)
            ->assertJsonPath('domains.participation.source_revision', $before->revision);
    }

    #[DataProvider('r1StopActions')]
    public function test_r1_bound_participation_stops_but_preserves_proposal(string $action): void
    {
        $user = $this->ready();
        $extra = $action === 'expiry' ? ['expires_at' => now()->addMinute()->toISOString()] : [];
        $this->putJson(self::URL, $this->command('grant', 0, $extra))->assertOk();
        $round = app(MatchingRoundService::class)->prepare('default', 'r1-delegated-stop', now(), now()->addHour(), 'test', null);
        $service = app(AutomationService::class);
        $service->tick('r1-bound-worker', 10);
        $before = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->assertNotNull($before->automation_authorization_id);
        $proposal = $this->proposalFixture($user, $round, now()->addHour());
        $peer = User::findOrFail(DB::table('match_proposals')->where('id', $proposal)->value('user_b'));
        $peer->update(['verify_status' => 'approved']);
        app(MatchingInputService::class)->save($peer->id, [
            'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02', 'gender' => 'female',
            'city_key' => '上海', 'relationship_goal' => 'marriage', 'age_mode' => 'adult_any',
            'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city',
        ]);
        $question = QuestionnaireQuestion::where('question_key', 'b2-fixture')->firstOrFail();
        QuestionnaireAnswer::create(['user_id' => $peer->id, 'questionnaire_question_id' => $question->id,
            'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        $this->completeLifestyleFixture($peer->id);
        DB::table('matching_participations')->insert(['user_id' => $peer->id, 'state' => 'ACTIVE',
            'generation' => 1, 'revision' => 1, 'intent' => 'R1 peer fixture', 'created_at' => now(), 'updated_at' => now()]);
        DB::table('match_proposals')->where('id', $proposal)->update(['generation_b' => 1]);
        DB::table('match_proposal_slots')->insert(['user_id' => $peer->id, 'proposal_id' => $proposal]);
        $proposalBefore = DB::table('match_proposals')->where('id', $proposal)->first();
        $slotBefore = DB::table('match_proposal_slots')->where('user_id', $user->id)->first();
        $this->travel(2)->minutes();
        if (in_array($action, ['pause', 'revoke'], true)) {
            $this->putJson(self::URL, $this->command($action, 1))->assertOk();
        } else {
            if ($action === 'policy') {
                config(['user_automation.policy_version' => 'weekly_participation_v2']);
            }
            $service->tick('r1-bound-expiry', 10);
        }
        $after = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->assertSame('PAUSED', $after->state);
        $this->assertSame($before->revision + 1, $after->revision);
        $this->assertSame($before->generation, $after->generation);
        $this->assertEquals($proposalBefore, DB::table('match_proposals')->where('id', $proposal)->first());
        $this->assertEquals($slotBefore, DB::table('match_proposal_slots')->where('user_id', $user->id)->first());
        $service->tick('r1-stopped-repeat', 10);
        $this->assertEquals($after, DB::table('matching_participations')->where('user_id', $user->id)->first());
        $this->assertDatabaseCount('automation_tasks', 1);
        $this->assertDatabaseCount('automation_effects', 1);
        $this->postJson('/api/v1/journey/proposals/'.$proposal.'/decision', [
            'action' => 'accept', 'revision' => 1, 'idempotency_key' => 'r1-paused-accept',
        ])->assertConflict();
        $this->postJson('/api/v1/journey/proposals/'.$proposal.'/decision', [
            'action' => 'withdraw', 'revision' => 1, 'idempotency_key' => 'r1-explicit-withdraw',
        ])->assertOk()->assertJsonPath('state', 'WITHDRAWN');
    }

    public static function r1StopActions(): array
    {
        return [['pause'], ['revoke'], ['expiry'], ['policy']];
    }

    public function test_r1_manual_opt_in_clears_binding_and_survives_later_revoke(): void
    {
        $user = $this->ready();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        app(MatchingRoundService::class)->prepare('default', 'r1-manual-takeover', now(), now()->addHour(), 'test', null);
        app(AutomationService::class)->tick('r1-worker', 10);
        $bound = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->travel(5)->seconds();
        $this->putJson('/api/v1/journey/participation', [
            'action' => 'opt_in', 'revision' => $bound->revision, 'intent' => 'R1 new independent intent',
        ])->assertOk()->assertJsonPath('revision', $bound->revision + 1);
        $manual = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->assertNull($manual->automation_authorization_id);
        $this->assertGreaterThan($bound->updated_at, $manual->updated_at);
        $this->putJson(self::URL, $this->command('revoke', 1))->assertOk();
        $this->assertEquals($manual, DB::table('matching_participations')->where('user_id', $user->id)->first());
    }

    public function test_r1_binding_changes_advance_source_revision_and_final_effect_receipt(): void
    {
        $user = $this->ready();
        $this->putJson('/api/v1/journey/participation', [
            'action' => 'opt_in', 'revision' => 0, 'intent' => 'R1 retained manual intent',
        ])->assertOk();
        $manual = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->putJson(self::URL, $this->command('grant', 0))->assertOk();
        $old = app(MatchingRoundService::class)->prepare('default', 'r1-binding-first', now(), now()->addHour(), 'test', null);
        $this->travel(5)->seconds();
        $service = app(AutomationService::class);
        $service->tick('r1-first-binding', 10);
        $bound = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->assertSame($manual->revision + 1, $bound->revision);
        $this->assertSame($manual->generation, $bound->generation);
        $this->assertSame($manual->intent, $bound->intent);
        $this->assertGreaterThan($manual->updated_at, $bound->updated_at);
        $this->assertSame($bound->revision, DB::table('automation_effects')->value('participation_revision'));
        $this->getJson('/api/v1/user-state')->assertOk()
            ->assertJsonPath('domains.participation.delegated', true)
            ->assertJsonPath('domains.participation.source_revision', $bound->revision)
            ->assertJsonPath('domains.participation.source_updated_at', $bound->updated_at);
        $this->travel(5)->seconds();
        $service->tick('r1-repeat-binding', 10);
        $this->assertEquals($bound, DB::table('matching_participations')->where('user_id', $user->id)->first());
        // A new existing round is a controlled fixture, never a worker-created round.
        DB::table('dating_rounds')->where('id', $old->id)->update(['state' => 'closed']);
        DB::table('dating_round_channels')->where('channel_key', 'default')->update(['active_round_id' => null]);
        $next = app(MatchingRoundService::class)->prepare('default', 'r1-binding-next', now(), now()->addHour(), 'test', null);
        $service->tick('r1-new-round-binding', 10);
        $rebound = DB::table('matching_participations')->where('user_id', $user->id)->first();
        $this->assertSame($bound->revision + 1, $rebound->revision);
        $this->assertSame($bound->generation, $rebound->generation);
        $this->assertSame($next->id, $rebound->automation_round_id);
        $this->assertGreaterThan($bound->updated_at, $rebound->updated_at);
        $task = DB::table('automation_tasks')->where('round_id', $next->id)->first();
        $this->assertSame($rebound->revision, DB::table('automation_effects')->where('task_id', $task->id)->value('participation_revision'));
        $this->assertDatabaseCount('matching_runs', 0);
    }
}
