<?php

namespace App\Services;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use Illuminate\Database\Eloquent\Builder;

class ProfileReadinessService
{
    public function eligibleUsersQuery(): Builder
    {
        $required = $this->requiredAnswerCount();
        $eligible = QuestionnaireAnswer::query()
            ->select('user_id')
            ->groupBy('user_id')
            ->havingRaw('COUNT(DISTINCT questionnaire_question_id) >= ?', [$required]);

        return User::query()
            ->where('disabled', false)
            ->where('is_synthetic', false)
            ->whereIn('id', $eligible);
    }

    public function forUser(User $user): array
    {
        $required = $this->requiredAnswerCount();
        $answered = QuestionnaireAnswer::query()
            ->where('user_id', (int) $user->id)
            ->distinct()
            ->count('questionnaire_question_id');
        $enabledQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();

        [$eligible, $reasonCode, $nextActionCode] = match (true) {
            (bool) $user->disabled => [false, 'account_disabled', 'contact_support'],
            (bool) $user->is_synthetic => [false, 'synthetic_account_excluded', 'contact_support'],
            $enabledQuestions === 0 => [false, 'questionnaire_unavailable', 'wait_for_service'],
            $answered < $required => [false, 'questionnaire_incomplete', 'complete_questionnaire'],
            default => [true, 'eligible', 'wait_for_matching'],
        };

        $draft = UserProfileShowcaseDraft::query()
            ->where('user_id', (int) $user->id)
            ->where('draft_status', '!=', 'cleared')
            ->first();
        $publication = UserProfileShowcasePublication::query()
            ->where('user_id', (int) $user->id)
            ->first();
        $publishedVersionCurrent = $publication !== null && (
            $draft === null || (
                (int) $publication->source_draft_id === (int) $draft->id
                && $publication->source_draft_updated_at?->equalTo($draft->updated_at)
            )
        );

        return [
            'contract_version' => 'profile_readiness_v1',
            'matching_eligibility' => [
                'eligible' => $eligible,
                'reason_code' => $reasonCode,
                'required_answer_count' => $required,
                'answered_answer_count' => $answered,
                'missing_answer_count' => max(0, $required - $answered),
                'next_action_code' => $nextActionCode,
            ],
            'showcase' => [
                'draft_state' => $draft === null ? 'none' : 'private_draft',
                'review_status' => $draft?->moderation_status ?? 'not_submitted',
                'publication_status' => $publication === null ? 'not_published' : 'published',
                'published_version_current' => $publishedVersionCurrent,
                'affects_matching_eligibility' => false,
            ],
        ];
    }

    private function requiredAnswerCount(): int
    {
        return max(1, (int) config('questionnaire.required_answer_count', 10));
    }
}
