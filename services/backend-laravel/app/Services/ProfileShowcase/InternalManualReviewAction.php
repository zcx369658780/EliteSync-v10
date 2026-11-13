<?php

namespace App\Services\ProfileShowcase;

use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Services\Admin\UserGovernance;
use App\Models\UserProfileShowcaseReviewAudit;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use RuntimeException;

class InternalManualReviewAction
{
    private const ALLOWED_ACTOR_TYPES = [
        'internal_manual_reviewer',
        'strict_test_harness',
        'web_admin',
    ];

    private const ALLOWED_RESULTS = [
        'approved',
        'rejected',
        'needs_revision',
        'manual_review_required',
    ];

    /**
     * @param array{type?: string, id?: string, user_id?: int|string|null} $actor
     * @param array{reason_code?: string, note?: string|null, correlation_id?: string|null} $metadata
     */
    public function apply(UserProfileShowcaseDraft $draft, array $actor, string $result, array $metadata): UserProfileShowcaseReviewAudit
    {
        $actorType = trim((string) ($actor['type'] ?? ''));
        $actorId = trim((string) ($actor['id'] ?? ''));
        $actorUserId = $actor['user_id'] ?? null;
        $reasonCode = trim((string) ($metadata['reason_code'] ?? ''));
        $note = $this->boundedNullable($metadata['note'] ?? null, 240);
        $correlationId = $this->boundedNullable($metadata['correlation_id'] ?? null, 128);

        $this->assertAllowedActor($draft, $actorType, $actorId, $actorUserId);
        $this->assertAllowedResult($result);
        $expectedRevision = (int) ($metadata['expected_revision'] ?? $draft->revision);
        $expectedFieldsHash = $this->reviewedFieldsHash($draft);

        if ($draft->moderation_status !== 'pending') {
            throw new RuntimeException('profile_showcase_review_requires_pending_draft');
        }

        if ($reasonCode === '') {
            throw new InvalidArgumentException('profile_showcase_review_reason_required');
        }

        return DB::transaction(function () use ($draft, $actorType, $actorId, $actorUserId, $result, $reasonCode, $note, $correlationId, $expectedRevision, $expectedFieldsHash): UserProfileShowcaseReviewAudit {
            if ($actorType === 'web_admin') {
                abort_unless($actorUserId !== null && $actorId === (string) $actorUserId, 403);
                $admin = User::findOrFail((int) $actorUserId);
                app(UserGovernance::class)->target($admin, (int) $draft->user_id);
            }
            /** @var UserProfileShowcaseDraft $lockedDraft */
            $lockedDraft = UserProfileShowcaseDraft::query()
                ->whereKey($draft->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($lockedDraft->moderation_status !== 'pending') {
                throw new RuntimeException('profile_showcase_review_requires_pending_draft');
            }

            abort_unless((int) $lockedDraft->revision === $expectedRevision
                && hash_equals($expectedFieldsHash, $this->reviewedFieldsHash($lockedDraft)),
                409, 'profile_showcase_review_revision_changed');

            $previousStatus = (string) $lockedDraft->moderation_status;

            $lockedDraft->fill([
                'visibility_intent' => 'private_draft',
                'draft_status' => 'draft',
                'moderation_status' => $result,
                'source_type' => 'user_confirmed',
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
            ])->save();

            return UserProfileShowcaseReviewAudit::query()->create([
                'draft_id' => (int) $lockedDraft->id,
                'user_id' => (int) $lockedDraft->user_id,
                'actor_type' => $actorType,
                'actor_id' => $actorId,
                'previous_moderation_status' => $previousStatus,
                'new_moderation_status' => $result,
                'reason_code' => $reasonCode,
                'note' => $note,
                'reviewed_fields_hash' => $this->reviewedFieldsHash($lockedDraft),
                'correlation_id' => $correlationId,
            ]);
        });
    }

    private function assertAllowedActor(UserProfileShowcaseDraft $draft, string $actorType, string $actorId, int|string|null $actorUserId): void
    {
        if (! in_array($actorType, self::ALLOWED_ACTOR_TYPES, true)) {
            throw new InvalidArgumentException('profile_showcase_review_actor_type_forbidden');
        }

        if ($actorId === '') {
            throw new InvalidArgumentException('profile_showcase_review_actor_required');
        }

        if ($actorUserId !== null && (int) $actorUserId === (int) $draft->user_id) {
            throw new InvalidArgumentException('profile_showcase_review_owner_self_review_forbidden');
        }
    }

    private function assertAllowedResult(string $result): void
    {
        if (! in_array($result, self::ALLOWED_RESULTS, true)) {
            throw new InvalidArgumentException('profile_showcase_review_result_forbidden');
        }
    }

    private function boundedNullable(mixed $value, int $max): ?string
    {
        $clean = trim((string) $value);

        if ($clean === '') {
            return null;
        }

        if (mb_strlen($clean) > $max) {
            throw new InvalidArgumentException('profile_showcase_review_metadata_too_long');
        }

        return $clean;
    }

    private function reviewedFieldsHash(UserProfileShowcaseDraft $draft): string
    {
        $payload = app(ShowcaseWorkflow::class)->snapshot($draft);

        return hash('sha256', json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    }
}
