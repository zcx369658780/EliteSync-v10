@extends('admin.layout')
@section('title', '处理支持反馈')
@section('content')
<h1>反馈 #{{ $feedback->id }}</h1>
<p><span class="status-badge status-{{ $feedback->status }}">@include('admin.support-feedback-label', ['value' => $feedback->status])</span> · 版本 {{ $feedback->revision }}</p>
<section class="panel">
<p>提交者 #{{ $feedback->user_id }} · 来源 {{ $feedback->source }} · 提交 {{ $feedback->created_at }}</p>
<p style="white-space: pre-wrap">{{ $feedback->content }}</p>
<form method="post" action="{{ route('admin.support-feedback.update', $feedback->id) }}">
    @csrf
    <input type="hidden" name="expected_revision" value="{{ $feedback->revision }}">
    <input type="hidden" name="request_key" value="{{ Illuminate\Support\Str::uuid() }}">
    <div class="field"><label for="category">类别</label>
        <select id="category" name="category">
        @foreach(App\Services\SupportFeedbackService::CATEGORIES as $category)
            <option value="{{ $category }}" @selected($feedback->category === $category)>@include('admin.support-feedback-label', ['kind' => 'category', 'value' => $category])</option>
        @endforeach
        </select>
    </div>
    <div class="field"><label for="status">处理状态</label>
        <select id="status" name="status">
        @foreach(['OPEN' => '已接收', 'IN_REVIEW' => '处理中', 'RESOLVED' => '已解决', 'CLOSED' => '已关闭'] as $status => $label)
            <option value="{{ $status }}" @selected($feedback->status === $status)>{{ $label }}</option>
        @endforeach
        </select>
    </div>
    <div class="field"><label for="public_reply">给提交者的回复</label><textarea id="public_reply" name="public_reply" maxlength="2000" rows="4" style="width:100%">{{ $feedback->public_reply }}</textarea></div>
    <div class="field internal-note"><label for="internal_note">内部处理备注</label><p id="internal-note-help" class="muted">仅管理端可见，提交者回执只显示公开回复与处理状态。</p><textarea id="internal_note" name="internal_note" aria-describedby="internal-note-help" maxlength="2000" rows="3"></textarea></div>
    <label class="confirmation"><input type="checkbox" name="confirm" value="1" required>确认保存本次处理和公开回复</label>
    <button type="submit">保存处理</button>
</form>
</section>
<h2>处理记录</h2>
@foreach($updates as $update)
<section class="panel">
    <p>{{ $update->created_at }} · 管理员 #{{ $update->actor_user_id }} · @include('admin.support-feedback-label', ['value' => $update->previous_status]) → @include('admin.support-feedback-label', ['value' => $update->status]) · 版本 {{ $update->revision }}</p>
    <p style="white-space: pre-wrap">给提交者的回复 {{ $update->public_reply }}</p>
    <p style="white-space: pre-wrap">内部备注 {{ $update->internal_note }}</p>
</section>
@endforeach
{{ $updates->links() }}
@endsection
