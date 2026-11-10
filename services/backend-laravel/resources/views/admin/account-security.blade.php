@extends('admin.layout')
@section('title', '账号安全审计')
@section('content')
<section class="panel" aria-labelledby="security-title">
    <h1 id="security-title">账号安全审计</h1>
    <p class="muted">本页仅供管理员核查处理状态。账号注销即时停止使用；共享历史、必要审计、争议记录和备份按现行访问规则保留。未知环境的数据保留政策仍待确认。</p>
    <h2>注销处理</h2>
    <div class="table-scroll" tabindex="0" role="region" aria-label="注销处理状态">
        <table>
            <thead><tr><th>请求</th><th>账号</th><th>状态</th><th>处理次数</th><th>保留分类</th><th>更新时间</th></tr></thead>
            <tbody>
            @forelse ($closures as $closure)
                <tr><td>{{ $closure->id }}</td><td>#{{ $closure->user_id }}</td><td>{{ $closure->status }}</td>
                    <td>{{ $closure->attempts }}</td><td>{{ implode('、', $closure->retained_categories) ?: '等待处理回执' }}</td><td>{{ $closure->updated_at }}</td></tr>
            @empty
                <tr><td colspan="6">暂无注销请求。</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    @if ($closures->hasPages())
        <nav aria-label="注销记录分页">
            @if ($closures->previousPageUrl()) <a href="{{ $closures->previousPageUrl() }}">上一页</a> @endif
            <span>第 {{ $closures->currentPage() }} / {{ $closures->lastPage() }} 页</span>
            @if ($closures->nextPageUrl()) <a href="{{ $closures->nextPageUrl() }}">下一页</a> @endif
        </nav>
    @endif
    <h2>近期关系请求记录</h2>
    <p class="muted">仅展示请求用途与生命周期状态；好友、联系授权和消息同意分别生效。</p>
    <div class="table-scroll" tabindex="0" role="region" aria-label="近期关系请求记录">
        <table>
            <thead><tr><th>请求</th><th>发起账号</th><th>接收账号</th><th>用途</th><th>状态</th><th>更新时间</th></tr></thead>
            <tbody>
            @forelse ($requests as $entry)
                <tr><td>#{{ $entry->id }}</td><td>#{{ $entry->sender_id }}</td><td>#{{ $entry->recipient_id }}</td>
                    <td>{{ $entry->purpose }}</td><td>{{ $entry->state }}</td><td>{{ $entry->updated_at }}</td></tr>
            @empty
                <tr><td colspan="6">暂无请求记录。</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</section>
@endsection
