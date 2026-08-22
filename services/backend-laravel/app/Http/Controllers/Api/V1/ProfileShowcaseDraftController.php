<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserProfileShowcaseDraft;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileShowcaseDraftController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $draft = UserProfileShowcaseDraft::query()
            ->where('user_id', (int) $request->user()->id)
            ->first();

        return response()->json($this->responsePayload($draft));
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'self_intro' => ['nullable', 'string', 'max:500'],
            'interest_tags' => ['nullable', 'array', 'max:10'],
            'interest_tags.*' => ['string', 'max:24', 'distinct:strict'],
            'lifestyle_tags' => ['nullable', 'array', 'max:10'],
            'lifestyle_tags.*' => ['string', 'max:24', 'distinct:strict'],
            'opener_note' => ['nullable', 'string', 'max:280'],
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
        ]);

        $draft = UserProfileShowcaseDraft::query()->updateOrCreate(
            ['user_id' => (int) $request->user()->id],
            [
                'self_intro' => $this->cleanText($data['self_intro'] ?? null),
                'interest_tags' => $this->cleanTags($data['interest_tags'] ?? null),
                'lifestyle_tags' => $this->cleanTags($data['lifestyle_tags'] ?? null),
                'opener_note' => $this->cleanText($data['opener_note'] ?? null),
                'visibility_intent' => 'private_draft',
                'draft_status' => 'draft',
                'moderation_status' => 'not_submitted',
                'source_type' => 'user_confirmed',
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
            ]
        );

        return response()->json($this->responsePayload($draft, 'saved_private_draft'));
    }

    public function destroy(Request $request): JsonResponse
    {
        $draft = UserProfileShowcaseDraft::query()
            ->where('user_id', (int) $request->user()->id)
            ->first();

        if ($draft !== null) {
            $draft->fill([
                'self_intro' => null,
                'interest_tags' => null,
                'lifestyle_tags' => null,
                'opener_note' => null,
                'visibility_intent' => 'private_draft',
                'draft_status' => 'cleared',
                'moderation_status' => 'not_submitted',
                'source_type' => 'user_confirmed',
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
            ])->save();
        }

        return response()->json($this->responsePayload(null, 'cleared_private_draft'));
    }

    public function submitForReview(Request $request): JsonResponse
    {
        $request->validate([
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
        ]);

        $draft = UserProfileShowcaseDraft::query()
            ->where('user_id', (int) $request->user()->id)
            ->where('draft_status', '!=', 'cleared')
            ->first();

        if ($draft === null) {
            return response()->json([
                'ok' => false,
                'error' => [
                    'code' => 'private_draft_required',
                    'message' => 'Save a private draft before submitting it for review.',
                ],
            ], 422);
        }

        $draft->fill([
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'pending',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ])->save();

        return response()->json($this->responsePayload($draft, 'submitted_for_review_pending'));
    }

    private function responsePayload(?UserProfileShowcaseDraft $draft, string $saveLabel = 'private_draft'): array
    {
        $visibleDraft = $draft !== null && $draft->draft_status !== 'cleared';
        $moderationStatus = $this->safeModerationStatus($draft?->moderation_status);

        return [
            'ok' => true,
            'draft' => $visibleDraft ? [
                'id' => (int) $draft->id,
                'self_intro' => $draft->self_intro,
                'interest_tags' => $draft->interest_tags ?? [],
                'lifestyle_tags' => $draft->lifestyle_tags ?? [],
                'opener_note' => $draft->opener_note,
                'visibility_intent' => 'private_draft',
                'draft_status' => 'draft',
                'moderation_status' => $moderationStatus,
                'source_type' => 'user_confirmed',
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
                'updated_at' => optional($draft->updated_at)->toIso8601String(),
            ] : null,
            'copy_state' => [
                'save_label' => $saveLabel,
                'moderation_status' => $moderationStatus,
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
            ],
        ];
    }

    private function safeModerationStatus(?string $value): string
    {
        $status = (string) $value;
        $allowed = [
            'not_submitted',
            'pending',
            'approved',
            'rejected',
            'needs_revision',
            'manual_review_required',
        ];

        return in_array($status, $allowed, true) ? $status : 'error';
    }

    private function cleanText(?string $value): ?string
    {
        $value = trim((string) $value);

        return $value === '' ? null : $value;
    }

    private function cleanTags(?array $tags): ?array
    {
        if ($tags === null) {
            return null;
        }

        $cleaned = [];
        foreach ($tags as $tag) {
            $value = trim((string) $tag);
            if ($value === '' || in_array($value, $cleaned, true)) {
                continue;
            }
            $cleaned[] = $value;
        }

        return $cleaned === [] ? null : array_values($cleaned);
    }
}
