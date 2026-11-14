<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\SupportFeedback;
use App\Services\SupportFeedbackService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

final class SupportFeedbackController extends Controller
{
    public function index(Request $request)
    {
        $data = $request->validate(['before_id' => 'nullable|integer|min:1']);
        $rows = SupportFeedback::where('user_id', $request->user()->id)
            ->when($data['before_id'] ?? null, fn ($query, $id) => $query->where('id', '<', $id))
            ->orderByDesc('id')->limit(21)->get(['id', 'source', 'category', 'status', 'revision', 'created_at', 'updated_at']);
        $items = $rows->take(20)->values();

        return response()->json(['items' => $items, 'next_before_id' => $rows->count() > 20 ? $items->last()->id : null])
            ->header('Cache-Control', 'private, no-store');
    }

    public function store(Request $request, SupportFeedbackService $service)
    {
        $data = $request->validate([
            'request_key' => 'required|uuid', 'source' => ['required', Rule::in(SupportFeedbackService::SOURCES)],
            'category' => ['required', Rule::in(SupportFeedbackService::CATEGORIES)],
            'content' => 'required|string|max:800',
        ]);
        $data['content'] = trim($data['content']);
        abort_if($data['content'] === '', 422, '请填写反馈内容。');
        [$feedback, $created] = $service->submit($request->user(), $data);

        return $this->detail($feedback, $created ? 201 : 200);
    }

    public function show(Request $request, int $id)
    {
        $feedback = SupportFeedback::where('user_id', $request->user()->id)->whereKey($id)->firstOrFail();

        return $this->detail($feedback);
    }

    private function detail(SupportFeedback $feedback, int $status = 200)
    {
        $public = DB::transaction(function () use ($feedback) {
            $snapshot = SupportFeedback::whereKey($feedback->id)->where('user_id', $feedback->user_id)
                ->lockForUpdate()->firstOrFail();
            $public = $snapshot->only(['id', 'source', 'category', 'content', 'status', 'public_reply', 'revision', 'created_at', 'updated_at']);
            $public['updates'] = DB::table('support_feedback_updates')->where('feedback_id', $snapshot->id)
                ->orderByDesc('id')->limit(20)->get(['category', 'status', 'public_reply', 'revision', 'created_at']);

            return $public;
        });

        return response()->json(['feedback' => $public], $status)->header('Cache-Control', 'private, no-store');
    }
}
