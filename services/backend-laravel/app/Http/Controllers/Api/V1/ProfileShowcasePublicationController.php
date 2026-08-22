<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use App\Models\UserProfileShowcasePublicationAudit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileShowcasePublicationController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $publication = UserProfileShowcasePublication::query()
            ->where('user_id', $userId)
            ->first();

        if ($publication !== null) {
            return response()->json($this->publishedPayload($publication));
        }

        $draft = $this->ownerDraft($userId);
        $status = $draft !== null && $draft->moderation_status !== 'approved'
            ? 'unavailable'
            : 'not_published';

        return response()->json($this->emptyPayload($status));
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'confirm_public_display' => ['nullable', 'boolean'],
            'user_id' => ['prohibited'],
            'target_user_id' => ['prohibited'],
            'owner_id' => ['prohibited'],
            'role' => ['prohibited'],
            'admin' => ['prohibited'],
            'source' => ['prohibited'],
            'visibility' => ['prohibited'],
            'visibility_intent' => ['prohibited'],
            'draft_status' => ['prohibited'],
            'moderation_status' => ['prohibited'],
            'source_type' => ['prohibited'],
            'public_display_eligible' => ['prohibited'],
            'matching_scoring_eligible' => ['prohibited'],
            'copy_state' => ['prohibited'],
            'published_payload' => ['prohibited'],
            'public_fields' => ['prohibited'],
            'audit_note' => ['prohibited'],
            'reviewer_id' => ['prohibited'],
            'reviewer_identity' => ['prohibited'],
            'provider' => ['prohibited'],
            'generated_tags' => ['prohibited'],
            'questionnaire' => ['prohibited'],
            'astrology_payload' => ['prohibited'],
            'private_matching_payload' => ['prohibited'],
        ]);

        if ($request->boolean('confirm_public_display') !== true) {
            return $this->error('profile_showcase_publication_requires_owner_confirmation');
        }

        $userId = (int) $request->user()->id;
        $draft = $this->ownerDraft($userId);

        if ($draft === null) {
            return $this->error('profile_showcase_publication_draft_missing');
        }

        if ($draft->moderation_status !== 'approved' || $draft->visibility_intent !== 'private_draft') {
            return $this->error('profile_showcase_publication_requires_approved_draft');
        }

        $publication = DB::transaction(function () use ($draft, $userId): UserProfileShowcasePublication {
            /** @var UserProfileShowcaseDraft $lockedDraft */
            $lockedDraft = UserProfileShowcaseDraft::query()
                ->whereKey($draft->id)
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->firstOrFail();

            if ($lockedDraft->moderation_status !== 'approved' || $lockedDraft->visibility_intent !== 'private_draft') {
                throw new \RuntimeException('profile_showcase_publication_requires_approved_draft');
            }

            $payload = $this->publicFields($lockedDraft);
            $publishedAt = now();

            /** @var UserProfileShowcasePublication|null $existing */
            $existing = UserProfileShowcasePublication::query()
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->first();

            $sameSourceSnapshot = $existing !== null
                && (int) $existing->source_draft_id === (int) $lockedDraft->id
                && optional($existing->source_draft_updated_at)->equalTo($lockedDraft->updated_at)
                && $existing->source_moderation_status === 'approved';

            if ($sameSourceSnapshot) {
                return $existing;
            }

            $previousStatus = $existing === null ? 'not_published' : 'published';

            $publication = UserProfileShowcasePublication::query()->updateOrCreate(
                ['user_id' => $userId],
                [
                    'source_draft_id' => (int) $lockedDraft->id,
                    'source_draft_updated_at' => $lockedDraft->updated_at,
                    'source_moderation_status' => 'approved',
                    'published_payload' => $payload,
                    'public_display_eligible' => true,
                    'matching_scoring_eligible' => false,
                    'published_at' => $publishedAt,
                ]
            );

            UserProfileShowcasePublicationAudit::query()->create([
                'publication_id' => (int) $publication->id,
                'user_id' => $userId,
                'source_draft_id' => (int) $lockedDraft->id,
                'actor_type' => 'draft_owner',
                'actor_id' => (string) $userId,
                'action' => 'owner_publish_confirmed',
                'previous_publication_status' => $previousStatus,
                'new_publication_status' => 'published',
            ]);

            return $publication;
        });

        return response()->json($this->publishedPayload($publication));
    }

    private function ownerDraft(int $userId): ?UserProfileShowcaseDraft
    {
        return UserProfileShowcaseDraft::query()
            ->where('user_id', $userId)
            ->where('draft_status', '!=', 'cleared')
            ->first();
    }

    private function publishedPayload(UserProfileShowcasePublication $publication): array
    {
        $publicFields = (array) ($publication->published_payload ?? []);

        return [
            'ok' => true,
            'publication' => [
                'id' => (int) $publication->id,
                'publication_status' => 'published',
                'source_draft_id' => (int) $publication->source_draft_id,
                'moderation_status' => 'approved',
                'public_display_eligible' => true,
                'matching_scoring_eligible' => false,
                'public_fields' => [
                    'self_intro' => $publicFields['self_intro'] ?? null,
                    'interest_tags' => $publicFields['interest_tags'] ?? [],
                    'lifestyle_tags' => $publicFields['lifestyle_tags'] ?? [],
                    'opener_note' => $publicFields['opener_note'] ?? null,
                ],
                'published_at' => optional($publication->published_at)->toIso8601String(),
                'updated_at' => optional($publication->updated_at)->toIso8601String(),
            ],
            'copy_state' => [
                'publication_status' => 'published',
                'public_display_eligible' => true,
                'matching_scoring_eligible' => false,
            ],
        ];
    }

    private function emptyPayload(string $status): array
    {
        return [
            'ok' => true,
            'publication' => null,
            'copy_state' => [
                'publication_status' => $status,
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
            ],
        ];
    }

    private function publicFields(UserProfileShowcaseDraft $draft): array
    {
        return [
            'self_intro' => $draft->self_intro,
            'interest_tags' => $draft->interest_tags ?? [],
            'lifestyle_tags' => $draft->lifestyle_tags ?? [],
            'opener_note' => $draft->opener_note,
        ];
    }

    private function error(string $code): JsonResponse
    {
        return response()->json([
            'ok' => false,
            'error' => [
                'code' => $code,
            ],
        ], 422);
    }
}
