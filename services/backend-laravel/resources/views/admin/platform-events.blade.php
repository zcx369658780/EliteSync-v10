@extends('admin.layout')
@section('title', '平台活动与Safety')
@section('content')
<h1>平台合成活动与内部Safety</h1>
<div class="notice">
    <strong>DEV_SYNTHETIC_EVENT · NOT_REAL_BOOKING</strong>
    <p>仅供虚构开发演练：没有真实招募、场地预订、支付或线下到场认定。预算只在管理端模拟；报名不建立好友、私信或恋爱关系。</p>
</div>
@if (session('issued_token'))
<section class="panel" aria-label="本次活动邀请凭据">
    <h2>本次新邀请凭据（仅显示一次）</h2>
    <p>48小时、单次兑换，可在对应活动中撤销。只交给明确受邀的合成开发用户；勿放入截图、日志或公开材料。</p>
    <code style="overflow-wrap:anywhere">{{ session('issued_token') }}</code>
</section>
@endif

<section class="panel" style="margin:1.5rem 0">
    <h2>创建合成活动草稿</h2>
    <p class="muted">名称、城市及虚构场所均须以“TEST_ONLY ”开头，不填写联系方式、精确地址、坐标或真实预订信息。草稿须完成模拟预算审批后才能开放。</p>
    <form method="post" action="/admin/platform-events">
        @csrf
        <input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}">
        <div class="field"><label for="event-title">活动名称</label><input id="event-title" name="title" value="{{ old('title', 'TEST_ONLY 开发活动') }}" maxlength="100" required>@error('title')<p role="alert">{{ $message }}</p>@enderror</div>
        <div class="field"><label for="event-city">合成城市</label><input id="event-city" name="city" value="{{ old('city', 'TEST_ONLY 合成城市') }}" maxlength="40" required>@error('city')<p role="alert">{{ $message }}</p>@enderror</div>
        <div class="field"><label for="event-venue">虚构公共场所（未核实）</label><input id="event-venue" name="venue" value="{{ old('venue', 'TEST_ONLY 合成咖啡厅') }}" maxlength="100" required>@error('venue')<p role="alert">{{ $message }}</p>@enderror</div>
        <div class="field"><label for="event-start">开始时间（UTC）</label><input id="event-start" name="start_at" type="datetime-local" value="{{ old('start_at', now()->utc()->addDay()->format('Y-m-d\TH:i')) }}" required></div>
        <div class="field"><label for="event-end">结束时间（UTC，90天内）</label><input id="event-end" name="end_at" type="datetime-local" value="{{ old('end_at', now()->utc()->addDay()->addHours(2)->format('Y-m-d\TH:i')) }}" required></div>
        <div class="field"><label for="event-capacity">名额上限（2–8）</label><input id="event-capacity" name="capacity" type="number" min="2" max="8" value="{{ old('capacity', 2) }}" required></div>
        <div class="field"><label for="create-reason">具名创建理由</label><input id="create-reason" name="reason" minlength="5" maxlength="500" value="{{ old('reason') }}" required></div>
        <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认仅创建合成开发草稿，不产生真实预订、付款或安全保障承诺。</label>
        <button type="submit">保存活动草稿</button>
    </form>
</section>

<h2>受控活动（最多30项）</h2>
@forelse ($events as $event)
@php
    $budget = $event['budget'];
    $eventId = $event['id'];
    $state = $event['state'];
    $budgetEdges = ['DRAFT'=>['DRAFT','REVIEWED','VOID'], 'REVIEWED'=>['DRAFT','APPROVED_FOR_DEV_SIMULATION','VOID'], 'APPROVED_FOR_DEV_SIMULATION'=>['VOID'], 'VOID'=>[]];
    $lifecycle = match ($state) { 'DRAFT'=>['open'=>'开放报名','cancel'=>'取消活动'], 'OPEN'=>['close'=>'关闭报名','cancel'=>'取消活动'], 'CLOSED'=>['complete'=>'排程完成','cancel'=>'取消活动'], default=>[] };
@endphp
<section class="panel" style="margin:1rem 0" aria-labelledby="event-heading-{{ $eventId }}">
    <h3 id="event-heading-{{ $eventId }}">{{ $event['title'] }}</h3>
    <p><code>{{ $eventId }}</code> · {{ $state }} · revision {{ $event['revision'] }}</p>
    <p>{{ $event['city'] }} / {{ $event['venue'] }} · PUBLIC_VENUE_UNVERIFIED</p>
    <p>{{ $event['start_at'] }} — {{ $event['end_at'] }} UTC · 确认 {{ $event['confirmed'] }} / {{ $event['capacity'] }} 席</p>
    <p class="muted">排程完成不代表任何人实际到场；到场自述只能是SELF_REPORTED，未经独立核实。取消、缺席、不回复或拉黑本身不构成Finding。</p>

    <details>
        <summary>内部模拟预算：{{ $budget->state }} / revision {{ $budget->revision }}</summary>
        <p>{{ $budget->currency_code }} 最小货币单位：场所 {{ $budget->venue_cost }}，材料 {{ $budget->materials_cost }}，交通 {{ $budget->travel_cost }}；总计 {{ $budget->total }}。</p>
        <p><strong>APPROVED_FOR_DEV_SIMULATION只表示开发模拟审批，绝非实际付款或Owner财务批准。</strong></p>
        @if ($state === 'DRAFT' && count($budgetEdges[$budget->state] ?? []) > 0)
        <form method="post" action="/admin/platform-events/{{ $eventId }}/actions">
            @csrf
            <input type="hidden" name="action" value="budget"><input type="hidden" name="revision" value="{{ $event['revision'] }}">
            <input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}"><input type="hidden" name="budget_revision" value="{{ $budget->revision }}">
            <div class="field"><label>预算目标状态 <select name="budget_state" required>@foreach ($budgetEdges[$budget->state] as $next)<option value="{{ $next }}">{{ $next }}</option>@endforeach</select></label></div>
            @foreach (['venue_cost'=>'场所预计费用','materials_cost'=>'材料预计费用','travel_cost'=>'交通预计费用'] as $field=>$label)
            <div class="field"><label>{{ $label }}（整数最小单位）<input name="{{ $field }}" type="number" min="0" max="1000000" step="1" value="{{ $budget->$field }}" required></label></div>
            @endforeach
            <p class="muted">更改金额须选择DRAFT；REVIEWED和模拟批准只接受当前已存金额。</p>
            <div class="field"><label>本次预算操作理由<input name="reason" minlength="5" maxlength="500" required></label></div>
            <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>我确认这只是具名模拟预算操作，无支付或供应商调用。</label>
            <button type="submit">保存预算版本</button>
        </form>
        @endif
    </details>

    @if (count($lifecycle) > 0)
    <details style="margin-top:1rem"><summary>活动生命周期操作</summary>
        <form method="post" action="/admin/platform-events/{{ $eventId }}/actions">
            @csrf
            <input type="hidden" name="revision" value="{{ $event['revision'] }}"><input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}">
            <div class="field"><label>操作理由<input name="reason" minlength="5" maxlength="500" required></label></div>
            <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认当前版本与操作；开放仅在预算已模拟批准时生效，完成不是实际到场证明。</label>
            @foreach ($lifecycle as $action=>$label)<button type="submit" name="action" value="{{ $action }}" @class(['danger'=>$action==='cancel'])>{{ $label }}</button>@endforeach
        </form>
    </details>
    @endif

    @if ($state === 'OPEN')
    <details style="margin-top:1rem"><summary>定向邀请合成用户</summary>
        <form method="post" action="/admin/platform-events/{{ $eventId }}/actions">
            @csrf
            <input type="hidden" name="action" value="invite"><input type="hidden" name="revision" value="{{ $event['revision'] }}"><input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}">
            <div class="field"><label>明确受邀合成用户ID<input name="recipient_id" type="number" min="1" required></label></div>
            <div class="field"><label>邀请理由<input name="reason" minlength="5" maxlength="500" required></label></div>
            <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认仅邀请明确指定的开发合成用户；由用户自主报名。</label>
            <button type="submit">发出定向邀请</button>
        </form>
    </details>
    <details style="margin-top:1rem"><summary>签发单次限时邀请凭据</summary>
        <form method="post" action="/admin/platform-events/{{ $eventId }}/actions">
            @csrf
            <input type="hidden" name="action" value="token"><input type="hidden" name="revision" value="{{ $event['revision'] }}"><input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}">
            <div class="field"><label>签发理由<input name="reason" minlength="5" maxlength="500" required></label></div>
            <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认48小时单次凭据，仅交给受控合成用户，不公开分发。</label>
            <button type="submit">签发新凭据</button>
        </form>
    </details>
    @endif

    <details style="margin-top:1rem"><summary>邀请与撤销</summary>
        @forelse ($event['grants'] as $grant)
        <div style="border-top:1px solid #d6dce6;padding:1rem 0">
            <p>邀请 <code>{{ $grant->id }}</code> · {{ $grant->state }} · 接收人 {{ $grant->recipient_id ?? '待持有人主动兑换' }} · 到期 {{ $grant->expires_at }} UTC</p>
            @if ($grant->state !== 'REVOKED')
            <form method="post" action="/admin/platform-events/{{ $eventId }}/actions">
                @csrf
                <input type="hidden" name="action" value="revoke"><input type="hidden" name="grant_id" value="{{ $grant->id }}"><input type="hidden" name="revision" value="{{ $event['revision'] }}"><input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}">
                <div class="field"><label>撤销该邀请的理由<input name="reason" minlength="5" maxlength="500" required></label></div>
                <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认只撤销这条具名邀请及其当前报名来源，不产生处罚。</label>
                <button type="submit" class="danger">撤销该邀请</button>
            </form>
            @endif
        </div>
        @empty<p>尚无受控邀请。</p>@endforelse
    </details>

    <details style="margin-top:1rem"><summary>报名与候补名额管理</summary>
        @forelse ($event['registrations'] as $registration)
        <div style="border-top:1px solid #d6dce6;padding:1rem 0">
            <p>报名 <code>{{ $registration['id'] }}</code> · 合成用户 {{ $registration['user_id'] }} · {{ $registration['state'] }} · revision {{ $registration['revision'] }} · 候补序号 {{ $registration['wait_order'] ?? '—' }} · 到场自述 {{ $registration['attendance'] }}（未独立核实）</p>
            @if ($state === 'OPEN' && in_array($registration['state'], ['APPLIED','WAITLISTED'], true))
            <form method="post" action="/admin/platform-events/{{ $eventId }}/actions">
                @csrf
                <input type="hidden" name="action" value="{{ $registration['state'] === 'WAITLISTED' ? 'promote' : 'confirm' }}"><input type="hidden" name="registration_id" value="{{ $registration['id'] }}"><input type="hidden" name="revision" value="{{ $event['revision'] }}"><input type="hidden" name="idempotency_key" value="{{ (string) \Illuminate\Support\Str::uuid() }}">
                <div class="field"><label>具名名额处理理由<input name="reason" minlength="5" maxlength="500" required></label></div>
                <label class="confirmation"><input name="confirm" type="checkbox" value="1" required>确认只管理已自愿报名者名额，不代替用户参加；候补按服务端顺序且须有空位。</label>
                <button type="submit">{{ $registration['state'] === 'WAITLISTED' ? '按序候补转正' : '确认该报名名额' }}</button>
            </form>
            @endif
        </div>
        @empty<p>尚无已报名或候补参与者；发出邀请不等于用户已报名。</p>@endforelse
    </details>
</section>
@empty
<p class="panel">尚无平台合成活动，请先保存草稿。</p>
@endforelse

<section class="panel" style="margin-top:2rem">
    <h2>内部Safety复核队列（最多30项）</h2>
    <p>队列只显示最小案卷状态。读取陈述及必要来源前必须填写合法访问理由，并记录访问审计；举报、规则提示、取消与未回复均不是已核实Finding。</p>
    @forelse ($cases as $queued)
    <div style="border-top:1px solid #d6dce6;padding:1rem 0">
        <p><code>{{ $queued['id'] }}</code> · {{ $queued['state'] }} · revision {{ $queued['revision'] }} · 复核到期 {{ $queued['review_due_at'] }} UTC</p>
        @if (\Illuminate\Support\Carbon::parse($queued['review_due_at'])->isPast())<p role="status"><strong>已超期，待人工复核。</strong>此提醒不会自动处罚、销毁证据或解除限制。</p>@else<p class="muted">待人工复核；到期仅作提醒。</p>@endif
        <form method="get" action="/admin/safety-cases/{{ $queued['id'] }}">
            <div class="field"><label>本次必要访问理由<input name="reason" minlength="5" maxlength="500" required></label></div>
            <button type="submit">具名查看当前有权案卷</button>
        </form>
        <form method="get" action="/admin/safety-cases/{{ $queued['id'] }}/appeal-review" style="margin-top:1rem">
            <div class="field"><label>仅访问本人申诉的理由<input name="reason" minlength="5" maxlength="500" required></label></div>
            <p class="muted">仅适用于已有精确具名处罚的本人申诉；不读取原指控或证据。没有对应处罚时入口不可用。</p>
            <button type="submit">仅申诉最小工作台</button>
        </form>
    </div>
    @empty<p>没有待展示的内部Safety案卷。</p>@endforelse
</section>
@endsection
