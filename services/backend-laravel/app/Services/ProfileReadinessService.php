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
        $query = User::query()->where('disabled',false)->where('is_synthetic',false)
            ->where('verify_status','approved')->where('moderation_status','normal')
            ->where('account_status','active')->where('is_match_eligible',true);
        $ids = (clone $query)->pluck('id')->filter(fn($id)=>app(CurrentQuestionnaire::class)->validCount((int)$id)>=$required);
        return $query->whereIn('id',$ids);

    }

    public function forUser(User $user): array
    {
        $required = $this->requiredAnswerCount();
        $answered = app(CurrentQuestionnaire::class)->validCount((int)$user->id);
        $enabledQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();

        [$eligible, $reasonCode, $nextActionCode] = match (true) {
            (bool) $user->disabled => [false, 'account_disabled', 'contact_support'],
            ($user->moderation_status ?? 'normal') === 'restricted' => [false, 'account_restricted', 'contact_support'],
            ($user->moderation_status ?? '') !== 'normal' || ($user->account_status ?? '') !== 'active' => [false, 'account_state_unavailable', 'contact_support'],
            ! (bool) $user->is_match_eligible => [false, 'matching_participation_excluded', 'contact_support'],
            ($user->verify_status ?? 'pending') !== 'approved' => [false, 'operational_review_'.($user->verify_status ?? 'pending'), 'wait_for_review'],
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
            'operational_review' => ['status'=>$user->verify_status ?? 'pending','reason'=>$user->verify_reason ?? '', 'revision'=>(int)$user->verify_revision,'scope'=>'运营参与资格，非实名认证'],
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
