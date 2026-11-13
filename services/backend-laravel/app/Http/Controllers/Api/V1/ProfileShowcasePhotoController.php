<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use Illuminate\Http\Request;

final class ProfileShowcasePhotoController extends Controller
{
    public function store(Request $request, ShowcaseWorkflow $workflow)
    {
        $data = $request->validate([
            'photo' => ['required', 'file', 'mimetypes:image/jpeg,image/png', 'max:5120'],
            'expected_revision' => ['required', 'integer', 'min:0'],
            'client_upload_id' => ['required', 'uuid'],
            'owner_user_id' => ['prohibited'], 'media_asset_id' => ['prohibited'],
            'public_url' => ['prohibited'], 'storage_key' => ['prohibited'],
        ]);
        return response()->json($workflow->uploadPhoto($request->user(), $request->file('photo'),
            (int) $data['expected_revision'], $data['client_upload_id']))
            ->header('Cache-Control', 'private, no-store');
    }

    public function content(Request $request, int $owner, int $photo, ShowcaseWorkflow $workflow)
    {
        $data = $request->validate(['publication_revision' => ['nullable', 'integer', 'min:0']]);
        return $workflow->photoContent((int) $request->user()->id, $owner, $photo,
            (int) ($data['publication_revision'] ?? 0));
    }
}
