<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileShowcasePublicationController extends Controller
{
    public function show(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        return response()->json($workflow->ownerPublication((int) $request->user()->id))
            ->header('Cache-Control', 'private, no-store');
    }

    public function store(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        $data = $request->validate([
            'expected_revision' => ['required', 'integer', 'min:1'],
            'publication_revision' => ['required', 'integer', 'min:0'],
            'confirm_public_display' => ['required', 'accepted'],
        ] + array_fill_keys([
            'user_id', 'target_user_id', 'owner_id', 'role', 'admin', 'source', 'visibility',
            'visibility_intent', 'draft_status', 'moderation_status', 'source_type',
            'public_display_eligible', 'matching_scoring_eligible', 'copy_state',
            'published_payload', 'public_fields', 'audit_note', 'reviewer_id',
            'reviewer_identity', 'provider', 'generated_tags', 'questionnaire',
            'astrology_payload', 'private_matching_payload',
        ], ['prohibited']));
        return response()->json($workflow->publish((int) $request->user()->id,
            (int) $data['expected_revision'], (int) $data['publication_revision']))
            ->header('Cache-Control', 'private, no-store');
    }

    public function destroy(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        $data = $request->validate(['expected_revision' => ['required', 'integer', 'min:1']]);
        return response()->json($workflow->withdraw((int) $request->user()->id, (int) $data['expected_revision']))
            ->header('Cache-Control', 'private, no-store');
    }

    public function detail(Request $request, int $owner, ShowcaseWorkflow $workflow): JsonResponse
    {
        return response()->json($workflow->detail((int) $request->user()->id, $owner))
            ->header('Cache-Control', 'private, no-store');
    }
}
