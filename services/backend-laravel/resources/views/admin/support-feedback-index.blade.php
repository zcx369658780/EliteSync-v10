@extends('admin.layout')
@section('title', '支持反馈')
@section('content')
<h1>支持反馈</h1>
<section class="panel">
<div class="table-scroll" role="region" aria-label="支持反馈记录" tabindex="0">
<table>
<thead><tr><th scope="col">反馈</th><th scope="col">提交者</th><th scope="col">类别</th><th scope="col">处理状态</th><th scope="col">更新时间</th></tr></thead>
<tbody>
@forelse($feedback as $item)
<tr>
    <td><a href="{{ route('admin.support-feedback.show', $item->id) }}">反馈 #{{ $item->id }}</a></td>
    <td>用户 #{{ $item->user_id }}</td>
    <td>@include('admin.support-feedback-label', ['kind' => 'category', 'value' => $item->category])</td>
    <td><span class="status-badge status-{{ $item->status }}">@include('admin.support-feedback-label', ['value' => $item->status])</span></td>
    <td>{{ $item->updated_at }}</td>
</tr>
@empty
<tr><td colspan="5">暂无反馈。</td></tr>
@endforelse
</tbody></table></div>
{{ $feedback->links() }}
</section>
@endsection
