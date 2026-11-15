<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\LifestyleDiscoveryService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V10115LifestyleDiscoveryTest extends TestCase
{
    use RefreshDatabase;

    private const URL = '/api/v1/profile/lifestyle-discovery';

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true]);
        Sanctum::actingAs(User::factory()->create(['phone' => (string) Str::uuid(), 'disabled' => false]));
    }

    private function command(string $action, int $revision, array $extra = []): array
    {
        return array_merge(['action' => $action, 'expected_revision' => $revision,
            'questionnaire_version' => 'lifestyle_v1', 'request_key' => (string) Str::uuid()], $extra);
    }

    public function test_registration_returns_device_bound_trusted_session_without_extra_identity_inputs(): void
    {
        $reply = $this->postJson('/api/v1/auth/register', ['phone' => '19900115001',
            'password' => 'Fictional115pass', 'device_id' => 'b1-fictional-device'])->assertCreated();
        $this->assertNotEmpty($reply->json('access_token'));
        $this->assertSame('b1-fictional-device', $reply->json('session_retention.device_id'));
        $this->assertNotNull($reply->json('session_retention.login_at'));
        $this->assertNull($reply->json('user.birthday'));
        $this->assertFalse((bool) $reply->json('user.realname_verified'));
    }

    public function test_new_and_legacy_accounts_start_private_without_completion(): void
    {
        $this->getJson(self::URL)->assertOk()->assertJsonPath('status', 'not_started')
            ->assertJsonPath('revision', 0)->assertJsonCount(5, 'bank.scenes');
        $this->assertDatabaseCount('lifestyle_discoveries', 0);
        $this->getJson('/api/v1/status/posts')->assertOk();
    }

    public function test_every_option_has_traceable_projection_and_modifications_recompute(): void
    {
        $bank = $this->getJson(self::URL)->assertOk()->json('bank');
        $revision = 0;
        foreach ($bank['scenes'] as $scene) {
            foreach ($scene['options'] as $option) {
                $reply = $this->putJson(self::URL, $this->command('answer', $revision,
                    ['scene_id' => $scene['id'], 'option_id' => $option['id']]))->assertOk();
                $revision++;
                $reply->assertJsonPath('revision', $revision)
                    ->assertJsonPath('answers.'.$scene['id'].'.option_id', $option['id'])
                    ->assertJsonPath('derived_preferences.'.$scene['dimension'].'.value', $option['value'])
                    ->assertJsonPath('derived_preferences.'.$scene['dimension'].'.rule_id', $option['rule_id'])
                    ->assertJsonPath('derived_preferences.'.$scene['dimension'].'.answer_revision', $revision);
            }
        }
        $this->getJson(self::URL)->assertJsonPath('status', 'completed')->assertJsonPath('revision', 15);
        $this->assertNotNull(DB::table('lifestyle_discoveries')->value('completed_at'));
    }

    public function test_retry_cas_skip_reset_and_cross_account_isolation(): void
    {
        $command = $this->command('answer', 0, ['scene_id' => 'home_atmosphere', 'option_id' => 'quiet']);
        $this->putJson(self::URL, $command)->assertOk()->assertJsonPath('revision', 1);
        $this->putJson(self::URL, $command)->assertOk()->assertJsonPath('revision', 1);
        $this->putJson(self::URL, array_replace($command, ['option_id' => 'situational']))->assertConflict();
        $this->putJson(self::URL, $this->command('skip', 0))->assertConflict();
        $this->putJson(self::URL, $this->command('skip', 1))->assertOk()->assertJsonPath('status', 'skipped')
            ->assertJsonPath('completed_at', null)->assertJsonPath('answers.home_atmosphere.option_id', 'quiet');
        $this->putJson(self::URL, $command)->assertOk()->assertJsonPath('revision', 2)->assertJsonPath('status', 'skipped');
        $this->putJson(self::URL, $this->command('reset', 2))->assertOk()->assertJsonPath('status', 'not_started');
        $this->putJson(self::URL, $command)->assertConflict();
        $this->getJson(self::URL)->assertJsonCount(0, 'answers')->assertJsonCount(0, 'derived_preferences');
        Sanctum::actingAs(User::factory()->create(['phone' => (string) Str::uuid(), 'disabled' => false]));
        $this->getJson(self::URL)->assertOk()->assertJsonPath('revision', 0);
        $this->assertDatabaseCount('lifestyle_discoveries', 1);
    }

    public function test_rejects_forged_completion_unknown_fields_versions_and_options(): void
    {
        foreach ([['status' => 'completed'], ['user_id' => 1], ['derived_preferences' => []],
            ['questionnaire_version' => 'future'], ['scene_id' => 'missing', 'option_id' => 'quiet'],
            ['scene_id' => 'home_atmosphere', 'option_id' => 'missing']] as $invalid) {
            $this->putJson(self::URL, array_replace($this->command('answer', 0,
                ['scene_id' => 'home_atmosphere', 'option_id' => 'quiet']), $invalid))->assertUnprocessable();
        }
        $this->assertDatabaseCount('lifestyle_discoveries', 0);
    }

    public function test_new_run_freeze_and_finalize_recheck_completion_after_reset(): void
    {
        $user = auth()->user();
        $user->update(['verify_status' => 'approved']);
        config(['questionnaire.required_answer_count' => 1, 'matching.foundation.digest_key' => 'b1-test-key']);
        app(\App\Services\MatchingInputService::class)->save($user->id, [
            'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02', 'gender' => 'male',
            'city_key' => '上海', 'relationship_goal' => 'marriage', 'age_mode' => 'adult_any',
            'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city',
        ]);
        $question = \App\Models\QuestionnaireQuestion::create(['question_key' => 'b1-fixture',
            'category' => 'test', 'content' => 'Fixture', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A']], 'enabled' => true, 'version' => 1]);
        \App\Models\QuestionnaireAnswer::create(['user_id' => $user->id,
            'questionnaire_question_id' => $question->id, 'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        $round = app(\App\Services\MatchingRoundService::class)->prepare('default', 'b1-test', now(), now()->addHour(), 'test', null);
        $runs = app(\App\Services\MatchingRunService::class);
        $runs->request($round, 'b1-run', 'test', null);
        $run = $runs->claimNext('b1-worker', 120);
        try {
            $runs->freezeCandidates($run, collect([$user]), 'b1-worker', $run->fencing_token);
            $this->fail('Incomplete direct freeze must fail');
        } catch (\DomainException $error) {
            $this->assertSame('lifestyle_discovery_incomplete', $error->getMessage());
        }
        $revision = 0;
        foreach ($this->getJson(self::URL)->json('bank.scenes') as $scene) {
            $this->putJson(self::URL, $this->command('answer', $revision++, [
                'scene_id' => $scene['id'], 'option_id' => $scene['options'][0]['id']]))->assertOk();
        }
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 0, 'intent' => 'QA'])->assertOk();
        $this->assertTrue(app(\App\Services\ProfileReadinessService::class)->eligibleUsersQuery()->whereKey($user->id)->exists());
        $runs->freezeCandidates($run, collect([$user->fresh()]), 'b1-worker', $run->fencing_token);
        $this->putJson(self::URL, $this->command('reset', 5))->assertOk();
        $this->assertFalse(app(\App\Services\ProfileReadinessService::class)->eligibleUsersQuery()->whereKey($user->id)->exists());
        $this->assertTrue(app(\App\Services\ProfileReadinessService::class)->forUser($user->fresh())['matching_eligibility']['eligible']);
        $this->assertFalse($runs->revealInputsCurrent($run->fresh(), collect([$user->fresh()])->keyBy('id')));
        try {
            $runs->finalize($run->fresh(), 'b1-worker', $run->fencing_token, [$user->id], []);
            $this->fail('Reset after freeze must fail finalize');
        } catch (\DomainException $error) {
            $this->assertSame('eligibility_changed', $error->getMessage());
        }
        $this->assertDatabaseCount('dating_matches', 0);
    }

    public function test_additive_migration_rolls_back_only_b1_tables_and_reapplies(): void
    {
        $userId = auth()->id();
        $this->putJson(self::URL, $this->command('start', 0))->assertOk();
        $migration = require database_path('migrations/2026_11_15_190000_create_lifestyle_discoveries.php');
        $migration->down();
        $this->assertDatabaseHas('users', ['id' => $userId]);
        $this->assertTrue(\Illuminate\Support\Facades\Schema::hasTable('match_proposals'));
        $migration->up();
        $this->getJson(self::URL)->assertOk()->assertJsonPath('revision', 0);
    }

    public function test_weekly_gate_rejects_skip_but_preserves_ordinary_social_and_other_eligibility(): void
    {
        $this->putJson(self::URL, $this->command('skip', 0))->assertOk();
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 0, 'intent' => 'QA'])
            ->assertUnprocessable()->assertJsonPath('error.message', 'lifestyle_discovery_incomplete');
        $this->getJson('/api/v1/status/posts')->assertOk();
        $this->getJson('/api/v1/buddy')->assertOk();
        $revision = 1;
        foreach ($this->getJson(self::URL)->json('bank.scenes') as $scene) {
            $this->putJson(self::URL, $this->command('answer', $revision++, [
                'scene_id' => $scene['id'], 'option_id' => $scene['options'][0]['id']]))->assertOk();
        }
        $this->assertTrue(app(LifestyleDiscoveryService::class)->completed((int) auth()->id()));
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 0, 'intent' => 'QA'])
            ->assertUnprocessable()->assertJsonPath('error.message', 'preparation incomplete');
        $this->assertDatabaseCount('match_proposals', 0);
    }
}
