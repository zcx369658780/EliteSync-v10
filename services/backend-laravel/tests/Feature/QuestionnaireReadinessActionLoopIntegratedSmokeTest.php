<?php

namespace Tests\Feature;

use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class QuestionnaireReadinessActionLoopIntegratedSmokeTest extends TestCase
{
    use RefreshDatabase;

    public function test_submission_moves_only_the_owner_from_incomplete_to_fresh_eligible_truth(): void
    {
        config()->set('questionnaire.required_answer_count', 2);
        $first = $this->question('r3-smoke-first', 1);
        $second = $this->question('r3-smoke-second', 2);
        $actor = User::factory()->create(['phone' => 'r3-smoke-actor']);
        $outsider = User::factory()->create(['phone' => 'r3-smoke-outsider']);
        $draft = UserProfileShowcaseDraft::query()->create([
            'user_id' => $actor->id,
            'self_intro' => 'published but unrelated',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'approved',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
        ]);
        UserProfileShowcasePublication::query()->create([
            'user_id' => $actor->id,
            'source_draft_id' => $draft->id,
            'source_draft_updated_at' => $draft->updated_at,
            'source_moderation_status' => 'approved',
            'published_payload' => ['self_intro' => 'published but unrelated'],
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
            'published_at' => now(),
        ]);
        Sanctum::actingAs($actor);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.reason_code', 'questionnaire_incomplete')
            ->assertJsonPath('profile_readiness.matching_eligibility.missing_answer_count', 2)
            ->assertJsonPath('profile_readiness.matching_eligibility.next_action_code', 'complete_questionnaire')
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'published')
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);

        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [['question_id' => $first->id, 'answer' => 'a']],
        ])->assertOk();
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', false)
            ->assertJsonPath('profile_readiness.matching_eligibility.missing_answer_count', 1);

        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [['question_id' => $second->id, 'answer' => 'a']],
        ])->assertOk();
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', true)
            ->assertJsonPath('profile_readiness.matching_eligibility.reason_code', 'eligible')
            ->assertJsonPath('profile_readiness.showcase.affects_matching_eligibility', false);

        Sanctum::actingAs($outsider);
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('profile_readiness.matching_eligibility.eligible', false)
            ->assertJsonPath('profile_readiness.matching_eligibility.missing_answer_count', 2)
            ->assertJsonPath('profile_readiness.showcase.publication_status', 'not_published');
    }

    private function question(string $key, int $sortOrder): QuestionnaireQuestion
    {
        return QuestionnaireQuestion::query()->create([
            'question_key' => $key,
            'category' => 'readiness',
            'content' => $key,
            'question_type' => 'single',
            'options' => ['a', 'b'],
            'sort_order' => $sortOrder,
            'enabled' => true,
            'version' => 1,
        ]);
    }
}
