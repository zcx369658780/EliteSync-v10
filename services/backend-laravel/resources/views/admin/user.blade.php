@extends('admin.layout')
@section('title','账号与运营资格')
@section('content')
<h1>账号 #{{ $user->id }} {{ $user->name }}</h1>
<p>状态：{{ $user->disabled?'禁用':$user->moderation_status }}；运营审核：{{ $user->verify_status }}。运营参与资格不代表实名认证。</p>
@if($user->role === 'user')
<section class="panel"><h2>运营参与资格</h2><p>当前原因：{{ $user->verify_reason }}</p>
<form method="post" action="{{ route('admin.review',$user->id) }}">@csrf
<input type="hidden" name="expected_revision" value="{{ $user->verify_revision }}"><select name="status"><option>pending</option><option>approved</option><option>rejected</option></select>
<label>原因（勿填写私密内容）<input name="reason" required maxlength="1000"></label><label><input type="checkbox" name="confirm" value="1" required>确认审核</label><button>保存审核</button></form></section>
<section class="panel"><h2>分级处罚与受控恢复</h2><p>restrict保留登录与当前合法历史只读；恢复不会复活旧凭据/同意。</p>
<form method="post" action="{{ route('admin.punishment',$user->id) }}">@csrf<input type="hidden" name="expected_revision" value="{{ $user->admin_revision }}">
<select name="action"><option>restrict</option><option>banned</option><option>restore</option></select>
<label>待解除处罚ID（仅restore）<input name="sanction_id" type="number"></label><label>原因<input name="reason" required maxlength="1000"></label><label><input type="checkbox" name="confirm" value="1" required>确认处理</label><button>执行处罚操作</button></form>
@foreach($sanctions as $s)<p>处罚#{{ $s->id }} {{ $s->kind }} {{ $s->active?'有效':'已解除' }} 报告#{{ $s->report_id }}</p>@endforeach</section>
@endif
@endsection
