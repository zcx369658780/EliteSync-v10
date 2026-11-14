@extends('admin.layout')
@section('title', '搭子审计与评论举报')
@section('content')
<div class="panel"><h2>当前发现发布</h2><p>撤下后停止新申请，已成立参与继续按原授权处理。</p>
@forelse($publications as $publication)
<article><p>{{ $publication->author_label }} · {{ $publication->type }} · {{ $publication->subject }} · 到期 {{ $publication->expires_at }}</p>
<form method="post" action="{{ route('admin.buddy-community.discovery.withdraw', $publication->id) }}">@csrf
<input type="hidden" name="revision" value="{{ $publication->revision }}">
<label>撤下理由<input name="reason" required maxlength="500"></label>
<label><input type="checkbox" name="confirm" value="1" required>确认从发现撤下</label><button>撤下发现发布</button></form></article>
@empty<p>当前无公开卡</p>@endforelse</div>
<div class="panel"><a href="{{ route('admin.users') }}">返回管理</a><h1>搭子审计与评论举报</h1><p>只读搭子状态审计；不能代双方确认或建立连接。仅审核已被当前有权用户具名举报的评论；普通取消/拒绝不会产生Safety记录。</p><h2>已举报评论</h2>@forelse($comments as $c)<article><p>举报 #{{ $c->report_id }} / {{ $c->report_status }} · 评论 {{ $c->state }}</p>@if($c->state==='ACTIVE')<p>{{ $c->body }}</p>@if($c->report_status==='new')<form method="post" action="{{ route('admin.buddy-community.hide', $c->report_id) }}">@csrf<input type="hidden" name="revision" value="{{ $c->revision }}"><label>审核理由<input name="reason" required maxlength="500"></label><label><input type="checkbox" name="confirm" value="1" required>确认只隐藏该条已举报评论</label><button>隐藏评论</button></form>@endif @else<p>内容已不可用</p>@endif</article>@empty<p>无评论举报</p>@endforelse<h2>最近50条搭子最小审计</h2>@forelse($audits as $a)<p>#{{ $a->id }} / {{ $a->activity_id }} / {{ $a->action }} / {{ $a->facts }}</p>@empty<p>暂无审计</p>@endforelse</div>
@endsection
