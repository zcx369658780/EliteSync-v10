<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcaseReviewAudit;
use App\Services\ProfileShowcase\InternalManualReviewAction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use InvalidArgumentException;
use RuntimeException;
use Tests\TestCase;

class ProfileShowcaseInternalManualReviewActionTest extends TestCase
{
    use RefreshDatabase;

    public function test_internal_reviewer_can_set_review_result_with_audit_without_public_or_scoring_eligibility(): void
    {
        $draft = $this->pendingDraft();

        $audit = app(InternalManualReviewAction::class)->apply($draft, [
            'type' => 'internal_manual_reviewer',
            'id' => 'reviewer-7',
            'user_id' => 999,
        ], 'approved', [
            'reason_code' => 'manual_review_passed',
            'note' => 'Bounded internal note',
            'correlation_id' => 'cs-i8-test-1',
        ]);

        $draft->refresh();

        $this->assertSame('approved', $draft->moderation_status);
        $this->assertSame('private_draft', $draft->visibility_intent);
        $this->assertSame('draft', $draft->draft_status);
        $this->assertFalse((bool) $draft->public_display_eligible);
        $this->assertFalse((bool) $draft->matching_scoring_eligible);

        $this->assertSame($draft->id, $audit->draft_id);
        $this->assertSame($draft->user_id, $audit->user_id);
        $this->assertSame('internal_manual_reviewer', $audit->actor_type);
        $this->assertSame('reviewer-7', $audit->actor_id);
        $this->assertSame('pending', $audit->previous_moderation_status);
        $this->assertSame('approved', $audit->new_moderation_status);
        $this->assertSame('manual_review_passed', $audit->reason_code);
        $this->assertSame('Bounded internal note', $audit->note);
        $this->assertNotEmpty($audit->reviewed_fields_hash);

        $this->assertDatabaseCount('user_profile_showcase_review_audits', 1);
        $this->assertDatabaseMissing('user_profile_showcase_review_audits', [
            'note' => $draft->self_intro,
        ]);
    }

    public function test_strict_test_harness_can_set_non_public_review_results(): void
    {
        foreach (['rejected', 'needs_revision', 'manual_review_required'] as $idx => $result) {
            $draft = $this->pendingDraft('1380000131' . $idx);

            app(InternalManualReviewAction::class)->apply($draft, [
                'type' => 'strict_test_harness',
                'id' => 'contract-test',
            ], $result, [
                'reason_code' => 'manual_boundary_check',
            ]);

            $draft->refresh();

            $this->assertSame($result, $draft->moderation_status);
            $this->assertFalse((bool) $draft->public_display_eligible);
            $this->assertFalse((bool) $draft->matching_scoring_eligible);
        }

        $this->assertDatabaseCount('user_profile_showcase_review_audits', 3);
    }

    public function test_draft_owner_self_review_is_forbidden_and_no_audit_is_written(): void
    {
        $draft = $this->pendingDraft();

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('profile_showcase_review_owner_self_review_forbidden');

        try {
            app(InternalManualReviewAction::class)->apply($draft, [
                'type' => 'internal_manual_reviewer',
                'id' => 'same-user',
                'user_id' => $draft->user_id,
            ], 'approved', [
                'reason_code' => 'owner_attempt',
            ]);
        } finally {
            $draft->refresh();
            $this->assertSame('pending', $draft->moderation_status);
            $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
        }
    }

    public function test_forbidden_actor_result_and_non_pending_draft_do_not_write_audit(): void
    {
        $draft = $this->pendingDraft();
        $action = app(InternalManualReviewAction::class);

        try {
            $action->apply($draft, [
                'type' => 'draft_owner',
                'id' => 'owner',
            ], 'approved', [
                'reason_code' => 'owner_attempt',
            ]);
            $this->fail('Draft owner actor should be forbidden.');
        } catch (InvalidArgumentException $exception) {
            $this->assertSame('profile_showcase_review_actor_type_forbidden', $exception->getMessage());
        }

        try {
            $action->apply($draft, [
                'type' => 'internal_manual_reviewer',
                'id' => 'reviewer-7',
            ], 'published', [
                'reason_code' => 'bad_status',
            ]);
            $this->fail('Published result should be forbidden.');
        } catch (InvalidArgumentException $exception) {
            $this->assertSame('profile_showcase_review_result_forbidden', $exception->getMessage());
        }

        $draft->forceFill(['moderation_status' => 'not_submitted'])->save();

        try {
            $action->apply($draft, [
                'type' => 'internal_manual_reviewer',
                'id' => 'reviewer-7',
            ], 'approved', [
                'reason_code' => 'not_pending',
            ]);
            $this->fail('Non-pending draft should be forbidden.');
        } catch (RuntimeException $exception) {
            $this->assertSame('profile_showcase_review_requires_pending_draft', $exception->getMessage());
        }

        $draft->refresh();
        $this->assertSame('not_submitted', $draft->moderation_status);
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
    }

    public function test_audit_metadata_is_bounded_and_reason_is_required(): void
    {
        $draft = $this->pendingDraft();
        $action = app(InternalManualReviewAction::class);

        try {
            $action->apply($draft, [
                'type' => 'internal_manual_reviewer',
                'id' => 'reviewer-7',
            ], 'approved', [
                'reason_code' => '',
            ]);
            $this->fail('Reason code should be required.');
        } catch (InvalidArgumentException $exception) {
            $this->assertSame('profile_showcase_review_reason_required', $exception->getMessage());
        }

        try {
            $action->apply($draft, [
                'type' => 'internal_manual_reviewer',
                'id' => 'reviewer-7',
            ], 'approved', [
                'reason_code' => 'manual_review_passed',
                'note' => str_repeat('x', 241),
            ]);
            $this->fail('Oversized note should be forbidden.');
        } catch (InvalidArgumentException $exception) {
            $this->assertSame('profile_showcase_review_metadata_too_long', $exception->getMessage());
        }

        $draft->refresh();
        $this->assertSame('pending', $draft->moderation_status);
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
    }

    private function pendingDraft(string $phone = '13800001300'): UserProfileShowcaseDraft
    {
        $user = User::factory()->create([
            'phone' => $phone,
        ]);

        return UserProfileShowcaseDraft::query()->create([
            'user_id' => $user->id,
            'self_intro' => '想先提交审核，但仍保持私有。',
            'interest_tags' => ['阅读'],
            'lifestyle_tags' => ['周末慢生活'],
            'opener_note' => '可以从最近读到的一本书聊起。',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'pending',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);
    }
}
