<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Services\Accounts\AdminAccess;
use App\Services\Admin\UserGovernance;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

final class AdminShowcaseController extends Controller
{
    public function index(Request $request)
    {
        abort_unless(app(AdminAccess::class)->allows($request->user()), 403);
        $submissions = DB::table('profile_showcase_submissions')->latest('id')->paginate(20);
        return response()->view('admin.showcase-index', compact('submissions'))
            ->header('Cache-Control', 'private, no-store');
    }

    public function show(Request $request, int $submission)
    {
        $data = DB::transaction(function () use ($request, $submission) {
            $record = DB::table('profile_showcase_submissions')->where('id', $submission)->first();
            abort_unless($record, 404);
            app(UserGovernance::class)->target($request->user(), (int) $record->user_id);
            $draft = UserProfileShowcaseDraft::where('user_id', $record->user_id)->lockForUpdate()->first();
            $snapshot = json_decode($record->snapshot, true, 512, JSON_THROW_ON_ERROR);
            $current = $draft && (int) $draft->revision === (int) $record->content_revision;
            return compact('record', 'snapshot', 'current');
        });
        return response()->view('admin.showcase', $data)->header('Cache-Control', 'private, no-store');
    }

    public function review(Request $request, int $submission, ShowcaseWorkflow $workflow)
    {
        $data = $request->validate([
            'expected_revision' => ['required', 'integer', 'min:1'],
            'result' => ['required', 'in:approved,needs_revision,rejected'],
            'reason' => ['required', 'string', 'max:1000'],
            'confirm' => ['required', 'accepted'],
        ]);
        abort_unless(trim($data['reason']) !== '', 422, '请填写审核反馈。');
        $workflow->review($request->user(), $submission, (int) $data['expected_revision'],
            $data['result'], trim($data['reason']));
        return redirect()->route('admin.showcase.show', $submission)
            ->with('status', '审核已保存，须由本人另行确认发布。');
    }

    public function photo(Request $request, int $submission, int $photo)
    {
        return DB::transaction(function () use ($request, $submission, $photo) {
            $record = DB::table('profile_showcase_submissions')->where('id', $submission)->first();
            abort_unless($record, 404);
            app(UserGovernance::class)->target($request->user(), (int) $record->user_id);
            $snapshot = json_decode($record->snapshot, true, 512, JSON_THROW_ON_ERROR);
            abort_unless(in_array($photo, array_map('intval', $snapshot['photo_ids'] ?? []), true), 404);
            $reference = DB::table('profile_showcase_photos')->where('id', $photo)
                ->where('user_id', $record->user_id)->first();
            $asset = $reference ? MediaAsset::whereKey($reference->media_asset_id)
                ->where('owner_user_id', $record->user_id)->first() : null;
            abort_unless($asset && $asset->storage_disk === 'v1016_showcase' && $asset->isBackingObjectAvailable(), 404);
            return response()->file(Storage::disk('v1016_showcase')->path($asset->storage_key), [
                'Content-Type' => 'image/png', 'Cache-Control' => 'private, no-store',
                'Vary' => 'Cookie', 'X-Content-Type-Options' => 'nosniff',
            ]);
        });
    }
}
