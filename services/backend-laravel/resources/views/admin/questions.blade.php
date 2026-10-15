@extends('admin.layout')
@section('title', '问卷质量运营')
@section('content')
<section class="panel" aria-labelledby="questions-title">
    <h1 id="questions-title">问卷质量运营</h1>
    <p>停用仅适用于 low_drop 题目；恢复仅适用于本版有停用审计且版本一致的题。历史答卷、attempt 和已发布匹配保留，新匹配以当前启用题的有效覆盖判断资格。</p>
    <h2>质量统计</h2>
    <div class="table-scroll"><table><caption>全题库按质量标签和状态统计</caption>
        <thead><tr><th>质量标签</th><th>状态</th><th>题数</th></tr></thead><tbody>
        @foreach ($stats as $stat)
            <tr><td>{{ $stat->quality_tag ?: '未分类' }}</td><td>{{ $stat->enabled ? '启用' : '停用' }}</td><td>{{ $stat->total }}</td></tr>
        @endforeach
        </tbody></table></div>
    <form method="post" action="{{ route('admin.questions.preview') }}" aria-label="具名题目预览">
        @csrf
        <h2>选择题目并预览</h2>
        <div class="field"><label for="question-ids">题目 ID（逗号或空格分隔，可与勾选合并）</label>
            <input id="question-ids" name="question_ids" value="{{ old('question_ids') }}" maxlength="5000"></div>
        <div class="field"><label for="enabled">目标状态</label><select id="enabled" name="enabled"><option value="0">停用</option><option value="1">恢复启用</option></select></div>
        <div class="table-scroll"><table><caption>low_drop 题目，共 {{ $questions->total() }} 题</caption>
            <thead><tr><th>选择</th><th>ID / key</th><th>质量原因</th><th>状态 / 版本</th></tr></thead><tbody>
            @forelse ($questions as $question)
                <tr><td><input type="checkbox" name="ids[]" value="{{ $question->id }}" aria-label="选择题目 {{ $question->id }}"></td>
                    <td>{{ $question->id }} / {{ $question->question_key }}</td><td>{{ $question->quality_reason }}</td>
                    <td>{{ $question->enabled ? '启用' : '停用' }} / {{ $question->version }}</td></tr>
            @empty
                <tr><td colspan="4">暂无 low_drop 题目。</td></tr>
            @endforelse
            </tbody></table></div>
        <button type="submit">仅预览影响（dry-run）</button>
    </form>
    <nav aria-label="分页">
        @if ($questions->previousPageUrl())<a href="{{ $questions->previousPageUrl() }}">上一页</a>@endif
        <span>第 {{ $questions->currentPage() }} / {{ $questions->lastPage() }} 页</span>
        @if ($questions->nextPageUrl())<a href="{{ $questions->nextPageUrl() }}">下一页</a>@endif
    </nav>
    @if ($preview)
        <section aria-labelledby="preview-title">
            <h2 id="preview-title">预览：{{ $preview['enabled'] ? '恢复启用' : '停用' }} {{ $preview['candidates'] }} 题</h2>
            <p>题库版本 {{ $preview['expected_revision'] }}。影响数量截至本次预览；确认时再次核验题库状态。活跃轮次与运行数量按全部活跃项保守列示，不修改已冻结输入。</p>
            <ul><li>历史答案：{{ $preview['impact']['answers'] }}</li><li>历史 attempt：{{ $preview['impact']['attempts'] }}</li>
                <li>涉及草稿：{{ $preview['impact']['drafts'] }}</li><li>活跃运行：{{ $preview['impact']['active_matching_runs'] }}</li>
                <li>未关闭轮次：{{ $preview['impact']['active_rounds'] }}</li></ul>
            <div class="table-scroll"><table><caption>本次具名变更清单</caption><thead><tr><th>ID</th><th>key</th><th>当前状态</th><th>当前版本</th></tr></thead><tbody>
            @foreach ($preview['questions'] as $question)
                <tr><td>{{ $question['id'] }}</td><td>{{ $question['key'] }}</td><td>{{ $question['enabled'] ? '启用' : '停用' }}</td><td>{{ $question['version'] }}</td></tr>
            @endforeach
            </tbody></table></div>
            <form method="post" action="{{ route('admin.questions.apply') }}" aria-label="确认题目变更">
                @csrf
                @foreach ($preview['questions'] as $question)<input type="hidden" name="ids[]" value="{{ $question['id'] }}">@endforeach
                <input type="hidden" name="enabled" value="{{ (int) $preview['enabled'] }}">
                <input type="hidden" name="expected_revision" value="{{ $preview['expected_revision'] }}">
                <input type="hidden" name="preview_signature" value="{{ $preview['preview_signature'] }}">
                <div class="field"><label for="reason">变更理由</label><input id="reason" name="reason" required maxlength="500"></div>
                <label class="confirmation"><input type="checkbox" name="confirm" value="1" required><span>确认按上述清单执行；当前有效覆盖不足的用户需要补答后才能进入新匹配。</span></label>
                <button class="danger" type="submit">确认执行并写审计</button>
            </form>
        </section>
    @endif
</section>
@endsection
