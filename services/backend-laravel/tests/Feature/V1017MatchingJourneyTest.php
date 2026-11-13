<?php

namespace Tests\Feature;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\RoundState;
use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserBlock;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use App\Services\MatchingEngineService;
use App\Services\MatchingInputService;
use App\Services\MatchingRoundService;
use App\Services\MatchingRunService;
use App\Services\ProfileReadinessService;
use App\Services\SlowDatingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/** Named fixtures for affected rules. Ordinary APP/Web/MariaDB evidence is recorded separately. */
class V1017MatchingJourneyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'questionnaire.required_answer_count' => 1,
            'matching.foundation.digest_key' => 'v1017-isolated-fixture-key',
            'matching.foundation.execution_enabled' => true]);
        $this->travelTo(now()->setDate(2026, 11, 13)->setTime(12, 0));
    }

    private function input(array $replace = []): array
    {
        return array_replace(['revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02',
            'gender' => 'male', 'city_key' => '上海', 'relationship_goal' => 'marriage',
            'age_mode' => 'adult_any', 'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city',
            'height_cm' => null, 'education' => null, 'occupation' => null, 'marital_history' => null,
            'children_status' => null, 'children_intention' => null], $replace);
    }

    private function subject(string $gender = 'male', array $input = []): User
    {
        $user = User::factory()->state(['phone' => '17'.random_int(100000000,999999999)])->create(['verify_status' => 'approved', 'gender' => $gender]);
        app(MatchingInputService::class)->save($user->id, $this->input(['gender' => $gender] + $input));
        $q = QuestionnaireQuestion::firstOrCreate(['question_key' => 'v1017-current'], [
            'category' => 'lifestyle', 'content' => 'Fixture preference', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A'], ['option_id' => 'B']], 'enabled' => true, 'version' => 1]);
        QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $q->id,
            'answer_payload' => ['selected_answer' => ['A']], 'selected_answer_json' => ['A'],
            'acceptable_answers_json' => ['A'], 'importance' => 3, 'version' => 1]);
        return $user->fresh();
    }

    private function enroll(User ...$users): void
    {
        foreach ($users as $user) {
            app(SlowDatingService::class)->participate($user->id, 'opt_in', 0, 'Fixture explicit participation');
        }
    }

    private function generate(User $a, User $b): array
    {
        $this->enroll($a, $b);
        $round = app(MatchingRoundService::class)->prepare('default', 'v1017-test', now()->subMinutes(2), now()->subMinute(), 'test', null);
        $run = app(MatchingRunService::class)->request($round, 'v1017-request', 'test', null);
        $this->artisan('app:matching:execute-pending', ['--once' => true, '--run-id' => $run->id])->assertSuccessful();
        $this->assertSame(1, $run->fresh()->pair_count, json_encode(app(ProfileReadinessService::class)->forUser($a)));
        $projection = app(\App\Services\MatchRoundProjectionService::class)->currentForUser($a->id)['data'];
        $this->assertSame('awaiting_reveal', $projection['reason_code']);
        $this->assertNull($projection['result']);
        return [$round->fresh(), $run->fresh()];
    }

    private function reveal($round, bool $stale = false): void
    {
        if (! $stale) {
            $run = \App\Models\MatchingRun::findOrFail($round->active_run_id);
            $fingerprint = new \ReflectionMethod(MatchingRunService::class, 'inputFingerprint');
            $this->assertSame($run->config_version, $fingerprint->invoke(app(MatchingRunService::class)), 'config');
            foreach (\App\Models\MatchingRunCandidate::where('matching_run_id', $run->id)->get() as $candidate) {
                $this->assertSame($candidate->matching_input_digest, app(MatchingInputService::class)->sourceDigest(User::findOrFail($candidate->user_id)), 'user digest');
            }
        }
        app(MatchingRoundService::class)->transition($round, RoundState::Revealed, $round->state_version,
            'test', null, OperationAction::Reveal, 'v1017-reveal');
        if ($round->fresh()->state === RoundState::Revealed) { $this->assertDatabaseCount('match_proposals', 1); }
    }

    public function test_input_save_clear_read_and_revision_are_private_and_do_not_enroll(): void
    {
        $user = User::factory()->state(['phone' => '17'.random_int(100000000,999999999)])->create();
        $this->actingAs($user, 'sanctum')->getJson('/api/v1/matching-inputs')->assertOk()->assertHeader('Cache-Control', 'no-store, private')->assertJsonPath('confirmed', false);
        $this->putJson('/api/v1/matching-inputs', $this->input(['occupation' => 'Fixture profession', 'height_cm' => 172]))
            ->assertOk()->assertJsonPath('revision', 1)->assertJsonPath('confirmed', true)->assertJsonPath('age_min', 18);
        $this->putJson('/api/v1/matching-inputs', $this->input(['revision' => 1]))
            ->assertOk()->assertJsonPath('occupation', null)->assertJsonPath('height_cm', null);
        $this->putJson('/api/v1/matching-inputs', $this->input(['revision' => 1]))->assertConflict();
        $this->assertDatabaseCount('matching_participations', 0);
        $this->assertDatabaseCount('user_profile_showcase_publications', 0);
        $this->assertDatabaseCount('user_astro_profiles', 0);
    }

    public function test_invalid_input_and_unconfirmed_legacy_profile_cannot_supply_matching_consent(): void
    {
        $user = User::factory()->state(['phone' => '17'.random_int(100000000,999999999)])->create(['relationship_goal' => 'dating', 'city' => 'Legacy free text']);
        $this->actingAs($user, 'sanctum')->putJson('/api/v1/matching-inputs', $this->input(['age_mode' => 'range', 'age_min' => 17, 'age_max' => 16]))->assertUnprocessable();
        $this->putJson('/api/v1/matching-inputs', $this->input(['region_mode' => 'unknown']))->assertUnprocessable();
        $this->assertSame('matching_inputs_unconfirmed', app(MatchingInputService::class)->readinessReason($user));
        $this->assertFalse(app(MatchingInputService::class)->read($user)['confirmed']);
    }

    public function test_adult_business_date_and_friendship_are_participation_only_gates(): void
    {
        $user = $this->subject('female', ['birthday' => '2008-11-14']);
        $this->assertSame('adult_self_report_required', app(MatchingInputService::class)->readinessReason($user));
        $this->travelTo(now()->addDay());
        $this->assertNull(app(MatchingInputService::class)->readinessReason($user));
        app(MatchingInputService::class)->save($user->id, $this->input(['revision' => 1, 'relationship_goal' => 'friendship']));
        $this->assertSame('friendship_only', app(MatchingInputService::class)->readinessReason($user->fresh()));
        $this->actingAs($user, 'sanctum')->putJson('/api/v1/journey/participation', ['action' => 'draft', 'revision' => 0, 'intent' => 'Text remains usable'])->assertOk();
    }

    public function test_both_age_ranges_and_locality_must_pass_and_marriage_dating_can_pair(): void
    {
        $a = $this->subject('male', ['age_mode' => 'range', 'age_min' => 25, 'age_max' => 35]);
        $b = $this->subject('female', ['city_key' => '北京', 'relationship_goal' => 'dating', 'region_mode' => 'long_distance']);
        $inputs = app(MatchingInputService::class);
        $this->assertFalse($inputs->pairAllowed($a, $b));
        $inputs->save($a->id, $this->input(['revision' => 1, 'region_mode' => 'long_distance', 'age_mode' => 'range', 'age_min' => 25, 'age_max' => 35]));
        $this->assertTrue($inputs->pairAllowed($a->fresh(), $b));
        $inputs->save($b->id, $this->input(['revision' => 1, 'gender' => 'female', 'city_key' => '北京', 'region_mode' => 'long_distance', 'age_mode' => 'range', 'age_min' => 18, 'age_max' => 25]));
        $this->assertFalse($inputs->pairAllowed($a->fresh(), $b->fresh()));
    }

    public function test_questionnaire_order_is_real_deterministic_and_legacy_astro_environment_cannot_change_it(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); $c = $this->subject('female');
        QuestionnaireAnswer::where('user_id', $b->id)->update(['selected_answer_json' => json_encode(['B'])]);
        config(['matching.core_weights.astro' => 999, 'matching.fairness.buckets' => [['min' => 0, 'multiplier' => 999]]]);
        $this->mock(\App\Services\AstroCompatibilityService::class)->shouldNotReceive('score');
        $pairs = app(MatchingEngineService::class)->buildPairs([$c->id => [], $a->id => [], $b->id => []]);
        $this->assertSame($c->id, $pairs[0]['user_b']);
        $this->assertSame(1.0, $pairs[0]['match_reasons']['rank_score']);
        QuestionnaireAnswer::where('user_id', $b->id)->update(['selected_answer_json' => json_encode(['A'])]);
        $this->assertSame($b->id, app(MatchingEngineService::class)->buildPairs([$c->id => [], $a->id => [], $b->id => []])[0]['user_b']);
    }

    public function test_zero_weight_or_no_current_shared_answers_is_neutral_and_disabled_options_are_excluded(): void
    {
        $a = $this->subject(); $b = $this->subject('female');
        QuestionnaireAnswer::query()->update(['importance' => 0]);
        $this->assertSame(0.5, app(MatchingEngineService::class)->buildPairs([$a->id => [], $b->id => []])[0]['match_reasons']['rank_score']);
        QuestionnaireQuestion::query()->update(['enabled' => false]);
        $this->assertSame([], app(\App\Services\CurrentQuestionnaire::class)->answers($a->id));
        $this->assertSame(0.5, app(MatchingEngineService::class)->buildPairs([$a->id => [], $b->id => []])[0]['match_reasons']['rank_score']);
    }

    public function test_old_goal_answer_stays_historical_and_current_goal_has_one_derived_meaning(): void
    {
        $user = $this->subject();
        $q = QuestionnaireQuestion::create(['question_key' => 'old-goal', 'category' => 'relationship_goals',
            'content' => 'Old goal', 'question_type' => 'single_choice', 'options' => [['option_id' => 'casual'], ['option_id' => 'long_term'], ['option_id' => 'marriage']], 'enabled' => true]);
        $answer = QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $q->id,
            'answer_payload' => ['value' => 'casual'], 'selected_answer_json' => ['casual'], 'acceptable_answers_json' => ['long_term'], 'importance' => 2]);
        $this->assertSame('matching_inputs_unconfirmed', app(MatchingInputService::class)->readinessReason($user));
        app(MatchingInputService::class)->save($user->id, $this->input(['revision' => 1, 'relationship_goal' => 'dating']));
        $this->assertSame(['long_term'], app(\App\Services\CurrentQuestionnaire::class)->answers($user->id)[$q->id]['selected']);
        $this->assertSame(['casual'], $answer->fresh()->selected_answer_json);
    }

    public function test_same_second_input_revision_invalidates_frozen_result(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); $this->enroll($a, $b);
        $round = app(MatchingRoundService::class)->prepare('default', 'freeze', now(), now(), 'test', null);
        $runs = app(MatchingRunService::class);
        $run = $runs->request($round, 'freeze-key', 'test', null);
        $run = $runs->claimNext('fixture-worker', 120);
        $runs->freezeCandidates($run, collect([$a, $b]), 'fixture-worker', $run->fencing_token);
        app(MatchingInputService::class)->save($a->id, $this->input(['revision' => 1, 'region_mode' => 'long_distance']));
        $this->expectExceptionMessage('input_changed');
        $runs->finalize($run, 'fixture-worker', $run->fencing_token, [$a->id, $b->id], []);
    }

    public function test_changed_input_before_reveal_has_recoverable_failed_state_and_retry_lineage(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round, $run] = $this->generate($a, $b);
        app(MatchingInputService::class)->save($a->id, $this->input(['revision' => 1, 'region_mode' => 'long_distance']));
        $this->reveal($round, true);
        $this->assertSame('failed', $round->fresh()->state->value);
        $this->assertSame('input_changed_before_reveal', $run->fresh()->error_code);
        $this->assertDatabaseCount('match_proposals', 0);
        $retry = app(MatchingRunService::class)->retry($run->fresh(), 'retry-key', 'test', null);
        $this->assertSame($run->id, $retry->supersedes_run_id);
        $this->artisan('app:matching:execute-pending', ['--once' => true, '--run-id' => $retry->id])->assertSuccessful();
        $this->reveal($round->fresh());
        $this->assertSame('PENDING', app(SlowDatingService::class)->proposal($a->id)['state']);
        $this->assertDatabaseCount('dating_matches', 2);
        $this->assertSame(1, DatingMatch::where('drop_released', true)->count());
    }

    public function test_pause_preserves_proposal_disallows_decision_and_requires_withdraw_before_reenroll(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $service = app(SlowDatingService::class); $proposal = $service->proposal($a->id);
        $service->participate($a->id, 'pause', 1, '');
        $paused = $service->proposal($a->id);
        $this->assertSame('PENDING', $paused['state']);
        $this->assertFalse($paused['decision_available']);
        $this->assertTrue($paused['withdraw_available']);
        $this->assertSame($proposal['expires_at'], $paused['expires_at']);
        $this->actingAs($a, 'sanctum')->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 2, 'intent' => ''])->assertConflict();
        $this->postJson('/api/v1/journey/proposals/'.$proposal['id'].'/decision', ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'paused-accept'])->assertConflict();
        $service->decision($a->id, $proposal['id'], 'withdraw', 1, 'paused-withdraw');
        $this->assertSame(2, $service->participate($a->id, 'opt_in', 2, '')['generation']);
    }

    public function test_history_is_self_scoped_persistent_and_current_audience_is_never_bypassed(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $payload = ['self_intro' => 'Restricted fixture text', 'interest_tags' => ['fixture'], 'audiences' => ['friends']];
        $draft = UserProfileShowcaseDraft::create(['user_id' => $b->id] + $payload);
        $publication = UserProfileShowcasePublication::create(['user_id' => $b->id, 'source_draft_id' => $draft->id, 'source_moderation_status' => 'approved',
            'published_payload' => $payload, 'publication_status' => 'published', 'public_display_eligible' => true, 'revision' => 1, 'published_at' => now()]);
        $proposal = app(SlowDatingService::class)->proposal($a->id);
        $this->assertNull($proposal['showcase']);
        $this->assertTrue($proposal['decision_available']);
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/journey/history?per_page=1')->assertOk()->assertJsonPath('total', 1)->assertJsonPath('data.0.showcase', null)->assertJsonPath('data.0.decision_available', false);
        $outsider = User::factory()->state(['phone' => '17'.random_int(100000000,999999999)])->create();
        $this->actingAs($outsider, 'sanctum')->getJson('/api/v1/journey/history/'.$proposal['id'])->assertNotFound();
        app(SlowDatingService::class)->decision($a->id, $proposal['id'], 'accept', 1, 'history-a-accept');
        app(SlowDatingService::class)->decision($b->id, $proposal['id'], 'accept', 2, 'history-b-accept');
        $publication->update(['published_payload' => array_replace($payload, ['audiences' => ['contacts']])]);
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/journey/history/'.$proposal['id'])->assertOk()->assertJsonPath('showcase.summary', 'Restricted fixture text');
        $publication->update(['publication_status' => 'withdrawn', 'public_display_eligible' => false]);
        $this->getJson('/api/v1/journey/history/'.$proposal['id'])->assertOk()->assertJsonPath('showcase', null);
        $this->getJson('/api/v1/profile/showcase/'.$b->id)->assertNotFound();
    }

    public function test_expiry_and_block_release_slot_without_fabricating_decline(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        UserBlock::create(['blocker_id' => $a->id, 'blocked_user_id' => $b->id]);
        $proposal = app(SlowDatingService::class)->proposal($a->id);
        $this->assertSame('WITHDRAWN', $proposal['state']);
        $this->assertSame('PENDING', $proposal['decision_peer']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
    }

    public function test_consumer_keeps_one_active_slot_and_both_independent_accepts_persist(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $service = app(SlowDatingService::class); $proposal = $service->proposal($a->id);
        $one = $service->decision($a->id, $proposal['id'], 'accept', 1, 'a-accept');
        $this->assertSame('ACCEPTED_BY_ONE', $one['state']);
        $this->assertSame($one, $service->decision($a->id, $proposal['id'], 'accept', 1, 'a-accept'));
        $both = $service->decision($b->id, $proposal['id'], 'accept', 2, 'b-accept');
        $this->assertSame('MUTUALLY_ACCEPTED', $both['state']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->assertDatabaseCount('friendships', 0);
        $this->assertSame('MUTUALLY_ACCEPTED', $service->history($a->id, 1, 20)['data'][0]['state']);
    }

    public function test_decline_exit_and_expiry_keep_distinct_process_facts(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $service = app(SlowDatingService::class); $proposal = $service->proposal($a->id);
        $this->travelTo(now()->addHours(168));
        $this->assertSame('EXPIRED', $service->proposal($a->id)['state']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->assertSame('PENDING', $service->history($a->id, 1, 20)['data'][0]['decision_me']);
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/journey/proposals/'.$proposal['id'].'/decision',
            ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'late-accept'])->assertConflict();
    }

    public function test_decline_is_independent_and_exit_releases_slot_without_peer_rejection(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $service = app(SlowDatingService::class); $proposal = $service->proposal($a->id);
        $result = $service->decision($a->id, $proposal['id'], 'decline', 1, 'explicit-decline');
        $this->assertSame('DECLINED', $result['state']);
        $this->assertSame('DECLINED', $result['decision_me']);
        $this->assertSame('PENDING', $result['decision_peer']);
        $service->participate($b->id, 'exit', 1, '');
        $this->assertSame('DECLINED', $service->history($a->id, 1, 20)['data'][0]['state']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
    }

    public function test_unresolved_slot_is_excluded_from_future_candidate_pool(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $this->assertSame([], app(ProfileReadinessService::class)->eligibleUsersQuery()->pluck('id')->all());
        app(SlowDatingService::class)->participate($a->id, 'exit', 1, '');
        $this->assertSame('WITHDRAWN', app(SlowDatingService::class)->history($b->id, 1, 20)['data'][0]['state']);
        $this->assertSame('PENDING', app(SlowDatingService::class)->history($b->id, 1, 20)['data'][0]['decision_me']);
        $this->assertSame([$b->id], app(ProfileReadinessService::class)->eligibleUsersQuery()->pluck('id')->all());
    }

    public function test_block_before_reveal_ends_in_recoverable_failure_without_releasing_old_result(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round, $run] = $this->generate($a, $b);
        UserBlock::create(['blocker_id' => $a->id, 'blocked_user_id' => $b->id]);
        $this->reveal($round, true);
        $this->assertSame('failed', $round->fresh()->state->value);
        $this->assertSame('input_changed_before_reveal', $run->fresh()->error_code);
        $this->assertDatabaseCount('match_proposals', 0);
        $this->assertSame(0, DatingMatch::where('drop_released', true)->count());
    }

    public function test_business_midnight_age_change_rechecks_bilateral_range_before_reveal(): void
    {
        $a = $this->subject('male', ['age_mode' => 'range', 'age_min' => 18, 'age_max' => 30]);
        $b = $this->subject('female', ['birthday' => '1995-11-14']); [$round] = $this->generate($a, $b);
        $this->travelTo(\Carbon\CarbonImmutable::parse('2026-11-14 00:00:00', 'Asia/Shanghai'));
        $this->reveal($round, true);
        $this->assertSame('failed', $round->fresh()->state->value);
        $this->assertDatabaseCount('match_proposals', 0);
    }

    public function test_second_accept_rechecks_qualification_after_the_pre_read(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round] = $this->generate($a, $b); $this->reveal($round);
        $service = app(SlowDatingService::class); $proposal = $service->proposal($a->id);
        $service->decision($a->id, $proposal['id'], 'accept', 1, 'first-independent-accept');
        $armed = true;
        // Deterministic race fixture changes qualification after pre-read reconciliation.
        DB::listen(function ($query) use (&$armed, $b) {
            if ($armed && str_contains($query->sql, 'select * from "user_profile_showcase_publications"')) {
                $armed = false;
                User::whereKey($b->id)->update(['relationship_goal' => 'friendship']);
            }
        });
        try {
            $service->decision($b->id, $proposal['id'], 'accept', 2, 'racing-second-accept');
            $this->fail('A changed qualification must prevent the second acceptance.');
        } catch (\Symfony\Component\HttpKernel\Exception\HttpException $failure) {
            $this->assertSame(409, $failure->getStatusCode());
        }
        $this->assertFalse($armed);
        $this->assertDatabaseMissing('match_proposals', ['id' => $proposal['id'], 'state' => 'MUTUALLY_ACCEPTED']);
    }

    public function test_removed_retry_participant_waits_for_configured_reveal_before_no_candidate(): void
    {
        $a = $this->subject(); $b = $this->subject('female'); [$round, $run] = $this->generate($a, $b);
        $round->forceFill(['reveal_at' => now()->addHour()])->save();
        app(SlowDatingService::class)->participate($b->id, 'exit', 1, '');
        $this->reveal($round->fresh(), true);
        $retry = app(MatchingRunService::class)->retry($run->fresh(), 'removed-peer-retry', 'test', null);
        $this->artisan('app:matching:execute-pending', ['--once' => true, '--run-id' => $retry->id])->assertSuccessful();
        $before = app(\App\Services\MatchRoundProjectionService::class)->currentForUser($b->id)['data'];
        $this->assertNotSame('no_candidate', $before['state']);
        $this->assertNull($before['result']);
        $this->travelTo(now()->addHour());
        $current = $round->fresh();
        app(MatchingRoundService::class)->transition($current, RoundState::NoCandidate, $current->state_version,
            'test', null, OperationAction::Reveal, 'removed-peer-reveal');
        $this->assertSame('no_candidate', app(\App\Services\MatchRoundProjectionService::class)->currentForUser($b->id)['data']['state']);
        $this->assertDatabaseCount('match_proposals', 0);
    }
}
