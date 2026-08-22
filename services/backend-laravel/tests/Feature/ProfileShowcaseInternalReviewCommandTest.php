<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class ProfileShowcaseInternalReviewCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_internal_command_calls_review_action_without_public_or_scoring_eligibility(): void
    {
        $draft = $this->pendingDraft();

        $code = Artisan::call('app:internal:profile-showcase-review', [
            'draft_id' => $draft->id,
            'result' => 'needs_revision',
            '--actor-type' => 'internal_manual_reviewer',
            '--actor-id' => 'reviewer-command-1',
            '--actor-user-id' => 999,
            '--reason-code' => 'profile_needs_revision',
            '--note' => 'Bounded command note',
            '--correlation-id' => 'cs-i9-command-test',
        ]);

        $this->assertSame(0, $code, Artisan::output());

        $draft->refresh();
        $this->assertSame('needs_revision', $draft->moderation_status);
        $this->assertSame('private_draft', $draft->visibility_intent);
        $this->assertFalse((bool) $draft->public_display_eligible);
        $this->assertFalse((bool) $draft->matching_scoring_eligible);

        $this->assertDatabaseHas('user_profile_showcase_review_audits', [
            'draft_id' => $draft->id,
            'user_id' => $draft->user_id,
            'actor_type' => 'internal_manual_reviewer',
            'actor_id' => 'reviewer-command-1',
            'previous_moderation_status' => 'pending',
            'new_moderation_status' => 'needs_revision',
            'reason_code' => 'profile_needs_revision',
            'note' => 'Bounded command note',
            'correlation_id' => 'cs-i9-command-test',
        ]);

        $this->assertDatabaseCount('user_profile_showcase_review_audits', 1);
    }

    public function test_command_forbids_draft_owner_self_review_without_audit_write(): void
    {
        $draft = $this->pendingDraft();

        $code = Artisan::call('app:internal:profile-showcase-review', [
            'draft_id' => $draft->id,
            'result' => 'approved',
            '--actor-type' => 'internal_manual_reviewer',
            '--actor-id' => 'owner-attempt',
            '--actor-user-id' => $draft->user_id,
            '--reason-code' => 'owner_attempt',
        ]);

        $this->assertSame(1, $code);
        $this->assertStringContainsString('profile_showcase_review_owner_self_review_forbidden', Artisan::output());

        $draft->refresh();
        $this->assertSame('pending', $draft->moderation_status);
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
    }

    public function test_command_rejects_non_pending_draft_and_invalid_result(): void
    {
        $draft = $this->pendingDraft();
        $draft->forceFill(['moderation_status' => 'not_submitted'])->save();

        $nonPendingCode = Artisan::call('app:internal:profile-showcase-review', [
            'draft_id' => $draft->id,
            'result' => 'approved',
            '--actor-type' => 'internal_manual_reviewer',
            '--actor-id' => 'reviewer-command-1',
            '--reason-code' => 'not_pending',
        ]);

        $this->assertSame(1, $nonPendingCode);
        $this->assertStringContainsString('profile_showcase_review_requires_pending_draft', Artisan::output());

        $draft->forceFill(['moderation_status' => 'pending'])->save();

        $invalidResultCode = Artisan::call('app:internal:profile-showcase-review', [
            'draft_id' => $draft->id,
            'result' => 'published',
            '--actor-type' => 'internal_manual_reviewer',
            '--actor-id' => 'reviewer-command-1',
            '--reason-code' => 'bad_result',
        ]);

        $this->assertSame(1, $invalidResultCode);
        $this->assertStringContainsString('profile_showcase_review_result_forbidden', Artisan::output());

        $draft->refresh();
        $this->assertSame('pending', $draft->moderation_status);
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
    }

    public function test_command_requires_existing_draft_and_actor_metadata(): void
    {
        $missingDraftCode = Artisan::call('app:internal:profile-showcase-review', [
            'draft_id' => 999999,
            'result' => 'approved',
            '--actor-type' => 'internal_manual_reviewer',
            '--actor-id' => 'reviewer-command-1',
            '--reason-code' => 'missing_draft',
        ]);

        $this->assertSame(1, $missingDraftCode);
        $this->assertStringContainsString('profile_showcase_review_draft_not_found', Artisan::output());

        $draft = $this->pendingDraft();

        $missingActorCode = Artisan::call('app:internal:profile-showcase-review', [
            'draft_id' => $draft->id,
            'result' => 'approved',
            '--actor-type' => 'internal_manual_reviewer',
            '--reason-code' => 'missing_actor',
        ]);

        $this->assertSame(1, $missingActorCode);
        $this->assertStringContainsString('profile_showcase_review_actor_required', Artisan::output());
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
    }

    private function pendingDraft(string $phone = '13800001400'): UserProfileShowcaseDraft
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
