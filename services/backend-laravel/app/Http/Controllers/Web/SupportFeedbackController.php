<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\SupportFeedback;
use App\Services\Accounts\AdminAccess;
use App\Services\SupportFeedbackService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

final class SupportFeedbackController extends Controller
{
    public function index(Request $request)
    {
        abort_unless(app(AdminAccess::class)->allows($request->user()?->fresh()), 403);
        $feedback = SupportFeedback::orderByDesc('id')->paginate(20);

        return response()->view('admin.support-feedback-index', compact('feedback'))
            ->header('Cache-Control', 'private, no-store');
    }

    public function show(Request $request, int $id)
    {
        abort_unless(app(AdminAccess::class)->allows($request->user()?->fresh()), 403);
        $feedback = SupportFeedback::findOrFail($id);
        $updates = DB::table('support_feedback_updates')->where('feedback_id', $id)->orderByDesc('id')->paginate(20);

        return response()->view('admin.support-feedback', compact('feedback', 'updates'))
            ->header('Cache-Control', 'private, no-store');
    }

    public function update(Request $request, int $id, SupportFeedbackService $service)
    {
        $data = $request->validate([
            'expected_revision' => 'required|integer|min:1', 'request_key' => 'required|uuid',
            'category' => ['required', Rule::in(SupportFeedbackService::CATEGORIES)],
            'status' => ['required', Rule::in(SupportFeedbackService::STATUSES)],
            'public_reply' => 'nullable|string|max:2000', 'internal_note' => 'nullable|string|max:2000',
            'confirm' => 'required|accepted',
        ]);
        $service->review($request->user(), $id, $data);

        return redirect()->route('admin.support-feedback.show', $id)->with('status', '反馈处理已保存。');
    }
}
