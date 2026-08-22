<?php

namespace Tests\Feature;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use App\Services\ProfileReadinessService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileReadinessTruthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile_basic_exposes_canonical_matching_eligibility_and_missing_action(): void
    {
        config()->set('questionnaire.required_answer_count', 2);
        $user = User::factory()->create(['phone' => 'readiness-incomplete']);
        $question = $this->question('readiness-one');
        QuestionnaireAnswer::query()->create([
            'user_id' => $user->id,
            'questionnaire_question_id' => $question->id,
            'answer_payload' => ['value' => 'a'],
            'selected_answer_json' => ['a'],
            'acceptable_answers_json' => ['a'],
            'importance' => 1,
            'version' => 1,
        ]);
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.contract_version', 'profile_readiness_v1')
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', false)
            ->assertJsonPath('profile_readiness.matching_eligibility.reason_code', 'questionnaire_incomplete')
            ->assertJsonPath('profile_readiness.matching_eligibility.missing_answer_count', 1)
            ->assertJsonPath('profile_readiness.matching_eligibility.next_action_code', 'complete_questionnaire')
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);
        $this->assertFalse(
            app(ProfileReadinessService::class)->eligibleUsersQuery()->whereKey($user->id)->exists()
        );
    }

    public function test_profile_basic_refreshes_to_eligible_without_publication(): void
    {
        config()->set('questionnaire.required_answer_count', 1);
        $user = User::factory()->create(['phone' => 'readiness-eligible']);
        $question = $this->question('readiness-complete');
        QuestionnaireAnswer::query()->create([
            'user_id' => $user->id,
            'questionnaire_question_id' => $question->id,
            'answer_payload' => ['value' => 'a'],
            'selected_answer_json' => ['a'],
            'acceptable_answers_json' => ['a'],
            'importance' => 1,
            'version' => 1,
        ]);
        UserProfileShowcaseDraft::query()->create([
            'user_id' => $user->id,
            'self_intro' => 'private',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'pending',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', true)
            ->assertJsonPath('profile_readiness.matching_eligibility.reason_code', 'eligible')
            ->assertJsonPath('profile_readiness.showcase.review_status', 'pending')
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'not_published')
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);
        $this->assertTrue(
            app(ProfileReadinessService::class)->eligibleUsersQuery()->whereKey($user->id)->exists()
        );
    }

    public function test_profile_basic_distinguishes_published_snapshot_from_later_private_edits(): void
    {
        config()->set('questionnaire.required_answer_count', 1);
        $user = User::factory()->create(['phone' => 'readiness-publication']);
        $draft = UserProfileShowcaseDraft::query()->create([
            'user_id' => $user->id,
            'self_intro' => 'approved snapshot',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'approved',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
        ]);
        UserProfileShowcasePublication::query()->create([
            'user_id' => $user->id,
            'source_draft_id' => $draft->id,
            'source_draft_updated_at' => $draft->updated_at,
            'source_moderation_status' => 'approved',
            'published_payload' => ['self_intro' => 'approved snapshot'],
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
            'published_at' => now(),
        ]);
        $this->travel(1)->seconds();
        $draft->forceFill(['self_intro' => 'later private edit', 'moderation_status' => 'not_submitted'])->save();
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'published')
            ->assertJsonPath('profile_readiness.showcase.published_version_current', false)
            ->assertJsonPath('profile_readiness.showcase.review_status', 'not_submitted')
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);
    }

    private function question(string $key): QuestionnaireQuestion
    {
        return QuestionnaireQuestion::query()->create([
            'question_key' => $key,
            'category' => 'readiness',
            'content' => $key,
            'question_type' => 'single',
            'options' => ['a', 'b'],
            'sort_order' => 1,
            'enabled' => true,
            'version' => 1,
        ]);
    }
}
