@extends('admin.layout')
@section('title', '内部Safety案卷')
@section('content')
@php
    $caseId = $case['id'];
    $caseState = $case['state'];
    $reviewOnly = (bool) ($review_only ?? false);
    $edges = ['OPEN'=>['triage'=>'分流登记','dismiss'=>'驳回未证举报','due'=>'设置复核提醒'], 'TRIAGED'=>['investigate'=>'进入人工调查','dismiss'=>'驳回未证举报','due'=>'设置复核提醒'], 'INVESTIGATING'=>['dismiss'=>'驳回未证举报','substantiate'=>'记录人工认定','due'=>'设置复核提醒'], 'SUBSTANTIATED'=>['restrict'=>'具名限制账号','banned'=>'具名禁用账号','due'=>'设置复核提醒'], 'ACTIONED'=>['close'=>'结案','due'=>'设置复核提醒'], 'DISMISSED'=>['close'=>'结案'], 'CLOSED'=>['due'=>'设置复核提醒']];
@endphp
<p><a href="/admin/platform-events">返回平台活动与Safety</a></p>
<h1>内部Safety案卷</h1>
<div class="notice">
    <strong>{{ $reviewOnly ? '仅合成开发演练 · 本人申诉最小工作台' : '仅合成开发演练 · ADVISORY_ONLY' }}</strong>
    @if ($reviewOnly)
    <p>此入口只保留精确处罚的本人申诉复核权益，不读取原指控、规则提示、证据或案卷决定正文；原活动或证据撤权不等于剥夺合法申诉。</p>
    @else
    <p>举报只是指控；规则不核实事实、不自动处罚。取消、不回复、主动拉黑或到场自述缺失，均不足以单独认定违规。内部案卷不向好友、Match或公众展示。</p>
    @endif
</div>
<section class="panel">
    <h2>当前案卷</h2>
    <p><code>{{ $caseId }}</code> · {{ $caseState }} · revision {{ $case['revision'] }}</p>
    <p>分类 {{ $case['category'] }} · 复核到期 {{ $case['review_due_at'] }} UTC。到期仅提醒，不自动定罪、销毁或解除限制。</p>
    @if (\Illuminate\Support\Carbon::parse($case['review_due_at'])->isPast())<p role="status"><strong>已超期，待人工复核。</strong></p>@endif
    @if (!$reviewOnly)
    <h3>当事人陈述（未经核实）</h3>
    <p style="white-space:pre-wrap">{{ $claim }}</p>
    <h3>固定版本规则提示</h3>
    <p>{{ $advisory->rule_version }} · {{ $advisory->classification }} · <strong>{{ $advisory->status }}</strong></p>
    <p>{{ $advisory->uncertainty }}</p>
    <h3>限本案的历史参与来源核对</h3>
    <p>HISTORICAL_AUTHORIZED_FACT 只证明收案时经校验的最小参与记录，不证明当前仍有参与资格、线下行为或真实到场。旧活动、私聊、附件与资料的普通权限不恢复。本次访问目的及当前案卷版本已审计；仅合成开发存证窗口为30天，过期或完整性不足显示 CURRENT_SOURCE_UNAVAILABLE，可具名调查或驳回，不凭历史参与认定违规。</p>
    @foreach ($evidence as $source)
    <dl>
        <dt>来源状态</dt><dd>{{ $source['status'] }} / {{ $source['current_status'] ?? 'CURRENT_SOURCE_UNAVAILABLE' }}</dd>
        @if (isset($source['source_id']))
        <dt>来源</dt><dd>{{ $source['source_type'] }} / <code>{{ $source['source_id'] }}</code></dd>
        <dt>版本及用途</dt><dd>{{ $source['source_revision'] }} / {{ $source['scope'] }}</dd>
        <dt>提交时来源hash</dt><dd><code style="overflow-wrap:anywhere">{{ $source['hash'] }}</code></dd>
        <dt>留存的历史参与状态</dt><dd>{{ $source['participation_state'] }}；到场 {{ $source['attendance'] }}（不能证明行为）</dd>
        <dt>合成开发存证读窗截止</dt><dd>{{ $source['retain_until'] }}</dd>
        @else
        <dt>调查限制</dt><dd>INSUFFICIENT_EVIDENCE：没有可核验的本案最小历史来源，不显示旧私密资料。</dd>
        @endif
    </dl>
    @endforeach
    @endif
</section>

@if (!$reviewOnly && count($edges[$caseState] ?? []) > 0)
<section class="panel" style="margin-top:1.5rem">
    <h2>具名人工处理</h2>
    <p class="muted">处理必须基于当前案卷版本。认定需先分别访问当前主案和同活动、同被举报人、不同举报人的独立佐证案；单方陈述或规则输出不能直接变成Finding。</p>
    @foreach ($edges[$caseState] as $action=>$label)
    <details style="margin:1rem 0"><summary>{{ $label }}</summary>
        <form method="post" action="/admin/safety-cases/{{ $caseId }}/decisions">
            @csrf
            <input type="hidden" name="action" value="{{ $action }}"><input type="hidden" name="revision" value="{{ $case['revision'] }}">
            @if ($action === 'substantiate')
            <div class="field"><label>已分别读取的独立佐证案卷UUID<input name="corroborating_case_id" required></label></div>
            <div class="field"><label>明确人工认定及其证据边界（20–400字）<textarea name="manual_finding" rows="5" minlength="20" maxlength="400" required style="width:100%"></textarea></label></div>
            <label class="confirmation"><input name="evidence_checked" type="checkbox" value="1" required>我已检查当前合法来源与独立佐证；这是具名人工判断，不是AI核实或线下真实事实证明。</label>
            @endif
            @if (in_array($action, ['restrict','banned'], true))
            <input type="hidden" name="user_revision" value="{{ $subject_revision }}">
            <p>被处理账号当前治理revision：{{ $subject_revision }}。只调用既有具名处罚源；请先确认已读取本版本证据。</p>
            @endif
            @if ($action === 'due')
            <div class="field"><label>下次人工复核提醒（UTC，90天内）<input name="review_due_at" type="datetime-local" value="{{ now()->utc()->addDays(7)->format('Y-m-d\TH:i') }}" required></label></div>
            @endif
            <div class="field"><label>本次具名处理理由（规则建议可不同意，须说明）<textarea name="reason" rows="3" minlength="5" maxlength="500" required style="width:100%"></textarea></label></div>
            <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认本次人工选择、理由与当前版本；不将未回复、取消或单方声明直接当作违规。</label>
            <button type="submit" @class(['danger'=>in_array($action, ['restrict','banned'], true)])>{{ $label }}</button>
        </form>
    </details>
    @endforeach
</section>
@endif

<section class="panel" style="margin-top:1.5rem">
    <h2>被处罚本人申诉与具名复核</h2>
    <p>此处处理的是对应sanction的本人申诉，不是举报人对结果的异议。推翻或纠错只恢复该具名处罚；其它独立限制、Block、旧CN/MC及历史关系不被暗恢复。</p>
    @forelse ($appeals as $appeal)
    <div style="border-top:1px solid #d6dce6;padding:1rem 0">
        <p>申诉 #{{ $appeal->id }} · {{ $appeal->status }} · revision {{ $appeal->revision }} · sanction #{{ $appeal->sanction_id }} · 结果 {{ $appeal->review_outcome ?? '待人工复核' }}</p>
        <p style="white-space:pre-wrap">{{ $appeal->note }}</p>
        @if (in_array($caseState, ['ACTIONED','CLOSED'], true) && ($appeal->status === 'submitted' || $appeal->review_outcome === 'UPHELD'))
        <form method="post" action="/admin/safety-cases/{{ $caseId }}/reviews">
            @csrf
            <input type="hidden" name="revision" value="{{ $case['revision'] }}"><input type="hidden" name="appeal_id" value="{{ $appeal->id }}"><input type="hidden" name="appeal_revision" value="{{ $appeal->revision }}"><input type="hidden" name="user_revision" value="{{ $subject_revision }}">
            <div class="field"><label>人工复核结果 <select name="outcome" required>
                @if ($appeal->status === 'submitted')<option value="UPHELD">UPHELD · 维持对应处罚</option>@endif
                <option value="OVERTURNED">OVERTURNED · 推翻并恢复对应处罚</option><option value="CORRECTED">CORRECTED · 纠错并恢复对应处罚</option>
            </select></label></div>
            <div class="field"><label>具名复核理由<textarea name="reason" rows="3" minlength="5" maxlength="500" required style="width:100%"></textarea></label></div>
            <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>已核对申诉、对应sanction与当前版本；只作本次有界人工复核。</label>
            <button type="submit">提交具名申诉复核</button>
        </form>
        @endif
    </div>
    @empty<p>尚无被处罚本人提交的具名申诉；不能由管理员代其提交。</p>@endforelse
</section>

@if (!$reviewOnly)
<section class="panel" style="margin-top:1.5rem">
    <h2>案卷具名决定历史</h2>
    @forelse ($decisions as $decision)
    <div style="border-top:1px solid #d6dce6;padding:1rem 0">
        <p>{{ $decision->created_at }} · {{ $decision->action }} · reviewer {{ $decision->reviewer_id }} · 操作前revision {{ $decision->expected_revision }}</p>
        <p style="white-space:pre-wrap">{{ $decision->reason }}</p>
        <p class="muted">{{ $decision->rule_version }} / {{ $decision->rule_class }} / {{ $decision->rule_status }}；{{ $decision->rule_uncertainty }}</p>
    </div>
    @empty<p>尚无人工决定；当前举报不构成Finding或处罚。</p>@endforelse
</section>
@endif
@endsection
