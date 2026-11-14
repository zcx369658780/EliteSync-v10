@extends('admin.layout')
@section('title', '处理支持反馈')
@section('content')
<h1>反馈 #{{ $feedback->id }}</h1>
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
            <option value="{{ $category }}" @selected($feedback->category === $category)>{{ $category }}</option>
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
    <div class="field"><label for="internal_note">内部处理备注</label><textarea id="internal_note" name="internal_note" maxlength="2000" rows="3" style="width:100%"></textarea></div>
    <label class="confirmation"><input type="checkbox" name="confirm" value="1" required>确认保存本次处理和公开回复</label>
    <button type="submit">保存处理</button>
</form>
</section>
<h2>处理记录</h2>
@foreach($updates as $update)
<section class="panel">
    <p>{{ $update->created_at }} · 管理员 #{{ $update->actor_user_id }} · {{ $update->previous_status }} → {{ $update->status }} · 版本 {{ $update->revision }}</p>
    <p style="white-space: pre-wrap">给提交者的回复 {{ $update->public_reply }}</p>
    <p style="white-space: pre-wrap">内部备注 {{ $update->internal_note }}</p>
</section>
@endforeach
{{ $updates->links() }}
@endsection
