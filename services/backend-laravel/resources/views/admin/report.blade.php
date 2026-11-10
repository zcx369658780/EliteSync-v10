@extends('admin.layout')
@section('content')<h1>举报 #{{ $report->id }}</h1><p>类别 {{ $report->category }}；目标账号#{{ $target->id }}；状态 {{ $report->status }}</p>
<p>用户主动提交说明（访问已留痕）：{{ $report->detail }}</p><p>申诉说明：{{ $report->appeal_note }}</p><p>私信正文及撤销后敏感信息不在此读取。</p>
@if($post)<section class="panel"><h2>公开动态#{{ $post->id }}</h2><p>{{ $post->title }}</p><p>{{ $post->body }}</p><p>{{ $post->is_deleted?'已隐藏':'可见' }}</p></section>@endif
<form method="post" action="{{ route('admin.report.action',$report->id) }}">@csrf<input type="hidden" name="expected_revision" value="{{ $report->admin_revision }}"><input type="hidden" name="expected_user_revision" value="{{ $target->admin_revision }}">
<select name="action">@foreach(['triage','investigate','dismiss','restrict','banned','restore','remove_post','close'] as $a)<option>{{ $a }}</option>@endforeach</select><label>恢复处罚ID<input type="number" name="sanction_id"></label><label>处理原因（不复制私密说明）<input required name="reason" maxlength="1000"></label><label><input type="checkbox" name="confirm" value="1" required>确认当前处理</label><button>提交处理</button></form>
@foreach($sanctions as $s)<p>可追溯处罚#{{ $s->id }} {{ $s->kind }}</p>@endforeach @endsection
