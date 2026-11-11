<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ProfileAvatarService;
use Illuminate\Http\Request;

final class ProfileAvatarController extends Controller
{
    public function show(Request $r, int $owner, ProfileAvatarService $avatars)
    {
        return response()->json($avatars->show((int) $r->user()->id, $owner))->header('Cache-Control', 'private, no-store');
    }

    public function store(Request $r, ProfileAvatarService $avatars)
    {
        $d = $r->validate(['file' => 'required|file|mimetypes:image/jpeg,image/png|max:5120', 'expected_revision' => 'required|integer|min:0',
            'owner_user_id' => 'prohibited', 'media_asset_id' => 'prohibited', 'public_url' => 'prohibited', 'storage_key' => 'prohibited']);
        return response()->json($avatars->replace($r->user(), $r->file('file'), (int) $d['expected_revision']))->header('Cache-Control', 'private, no-store');
    }

    public function destroy(Request $r, ProfileAvatarService $avatars)
    {
        $d = $r->validate(['expected_revision' => 'required|integer|min:0']);
        return response()->json($avatars->remove((int) $r->user()->id, (int) $d['expected_revision']))->header('Cache-Control', 'private, no-store');
    }

    public function content(Request $r, int $owner, int $revision, ProfileAvatarService $avatars)
    {
        return $avatars->content((int) $r->user()->id, $owner, $revision);
    }
}
