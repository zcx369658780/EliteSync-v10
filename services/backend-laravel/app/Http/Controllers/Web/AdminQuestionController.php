<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\QuestionnaireQuestion;
use App\Services\Admin\QuestionOperations;
use Illuminate\Http\Request;

final class AdminQuestionController extends Controller
{
    public function index(Request $request)
    {
        return $this->page($request);
    }

    public function preview(Request $request, QuestionOperations $operations)
    {
        $data = $this->selection($request);

        return $this->page($request, $operations->preview($data['ids'], $data['enabled']));
    }

    public function apply(Request $request, QuestionOperations $operations)
    {
        $data = $this->selection($request);
        $validated = $request->validate([
            'expected_revision' => 'required|integer|min:0', 'preview_signature' => 'required|string|size:64',
            'confirm' => 'required|accepted', 'reason' => 'required|string|max:500',
        ]);
        $result = $operations->apply($data['ids'], $data['enabled'], (int) $validated['expected_revision'],
            $validated['preview_signature'], $validated['reason'], (int) $request->user()->id);

        return redirect()->route('admin.questions')->with('status', '已更新 '.$result['updated'].' 题，题库版本 '.$result['revision'].'。历史记录保持不变。');
    }

    private function selection(Request $request): array
    {
        $data = $request->validate([
            'ids' => 'nullable|array|max:500', 'ids.*' => 'required|integer|min:1|distinct',
            'question_ids' => 'nullable|string|max:5000', 'enabled' => 'required|boolean',
        ]);
        $typed = preg_split('/[\s,，]+/u', trim($data['question_ids'] ?? ''), -1, PREG_SPLIT_NO_EMPTY);
        $ids = array_values(array_unique(array_merge($data['ids'] ?? [], $typed)));
        validator(['ids' => $ids], ['ids' => 'required|array|min:1|max:500', 'ids.*' => 'integer|min:1'])->validate();

        return ['ids' => $ids, 'enabled' => (bool) $data['enabled']];
    }

    private function page(Request $request, ?array $preview = null)
    {
        $questions = QuestionnaireQuestion::query()->where('quality_tag', 'low_drop')->orderBy('id')
            ->paginate(25, ['id', 'question_key', 'quality_reason', 'enabled', 'version'])->withQueryString();
        $stats = QuestionnaireQuestion::query()->selectRaw('quality_tag, enabled, COUNT(*) AS total')
            ->groupBy('quality_tag', 'enabled')->orderBy('quality_tag')->get();

        return view('admin.questions', compact('questions', 'stats', 'preview'));
    }
}
