<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProfileShowcaseDraftController extends Controller
{
    private function ownershipRules(): array
    {
        return array_fill_keys([
            'user_id', 'target_user_id', 'owner_id', 'role', 'admin', 'source', 'visibility',
            'visibility_intent', 'draft_status', 'moderation_status', 'source_type',
            'public_display_eligible', 'matching_scoring_eligible', 'copy_state',
        ], ['prohibited']);
    }

    public function show(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        return response()->json($workflow->ownerPayload((int) $request->user()->id))
            ->header('Cache-Control', 'private, no-store');
    }

    public function update(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        $data = $request->validate($this->ownershipRules() + [
            'expected_revision' => ['required', 'integer', 'min:0'],
            'display_name' => ['nullable', 'string', 'max:80'],
            'city' => ['nullable', 'string', 'max:80'],
            'relationship_goal' => ['nullable', 'string', 'max:80'],
            'self_intro' => ['nullable', 'string', 'max:500'],
            'interest_tags' => ['nullable', 'array', 'max:10'],
            'interest_tags.*' => ['string', 'max:24', 'distinct:strict'],
            'lifestyle_tags' => ['nullable', 'array', 'max:10'],
            'lifestyle_tags.*' => ['string', 'max:24', 'distinct:strict'],
            'opener_note' => ['nullable', 'string', 'max:280'],
            'photo_ids' => ['nullable', 'array', 'max:6'],
            'photo_ids.*' => ['integer', 'min:1', 'distinct'],
            'audiences' => ['nullable', 'array', 'max:3'],
            'audiences.*' => [Rule::in(['friends', 'contacts', 'relationship']), 'distinct:strict'],
        ]);
        return response()->json($workflow->saveDraft((int) $request->user()->id, $data, (int) $data['expected_revision']))
            ->header('Cache-Control', 'private, no-store');
    }

    public function destroy(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        $data = $request->validate($this->ownershipRules() + ['expected_revision' => ['required', 'integer', 'min:0']]);
        return response()->json($workflow->clearDraft((int) $request->user()->id, (int) $data['expected_revision']))
            ->header('Cache-Control', 'private, no-store');
    }

    public function submitForReview(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        $data = $request->validate($this->ownershipRules() + ['expected_revision' => ['required', 'integer', 'min:0']]);
        return response()->json($workflow->submit((int) $request->user()->id, (int) $data['expected_revision']))
            ->header('Cache-Control', 'private, no-store');
    }
}
