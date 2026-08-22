<?php

namespace Tests\Feature;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileReadinessIntegratedSmokeTest extends TestCase
{
    use RefreshDatabase;

    public function test_disposable_readiness_refresh_publication_separation_and_owner_isolation(): void
    {
        config()->set('questionnaire.required_answer_count', 1);
        $question = QuestionnaireQuestion::query()->create([
            'question_key' => 'r2-smoke',
            'category' => 'readiness',
            'content' => 'r2-smoke',
            'question_type' => 'single',
            'options' => ['a', 'b'],
            'sort_order' => 1,
            'enabled' => true,
            'version' => 1,
        ]);
        $actor = User::factory()->create(['phone' => 'r2-smoke-actor']);
        $outsider = User::factory()->create(['phone' => 'r2-smoke-outsider']);
        Sanctum::actingAs($actor);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', false)
            ->assertJsonPath('profile_readiness.matching_eligibility.reason_code', 'questionnaire_incomplete')
            ->assertJsonPath('profile_readiness.matching_eligibility.next_action_code', 'complete_questionnaire');

        QuestionnaireAnswer::query()->create([
            'user_id' => $actor->id,
            'questionnaire_question_id' => $question->id,
            'answer_payload' => ['value' => 'a'],
            'selected_answer_json' => ['a'],
            'acceptable_answers_json' => ['a'],
            'importance' => 1,
            'version' => 1,
        ]);
        $draft = UserProfileShowcaseDraft::query()->create([
            'user_id' => $actor->id,
            'self_intro' => 'private approved snapshot',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'approved',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
        ]);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', true)
            ->assertJsonPath('profile_readiness.showcase.review_status', 'approved')
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'not_published')
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);

        UserProfileShowcasePublication::query()->create([
            'user_id' => $actor->id,
            'source_draft_id' => $draft->id,
            'source_draft_updated_at' => $draft->updated_at,
            'source_moderation_status' => 'approved',
            'published_payload' => ['self_intro' => 'private approved snapshot'],
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
            'published_at' => now(),
        ]);
        $this->travel(1)->seconds();
        $draft->forceFill(['self_intro' => 'later private edit', 'moderation_status' => 'not_submitted'])->save();

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', true)
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'published')
            ->assertJsonPath('profile_readiness.showcase.published_version_current', false)
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);

        Sanctum::actingAs($outsider);
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', false)
            ->assertJsonPath('profile_readiness.showcase.draft_state', 'none')
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'not_published');
    }
}
