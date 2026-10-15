@extends('admin.layout')

@section('title', '用户管理')

@section('content')
<section class="panel" aria-labelledby="users-title">
    <h1 id="users-title">用户管理</h1>
    <p class="muted">查询账号并查看当前禁用状态。禁用会阻止该账号继续访问业务，并使其登录凭据失效。</p>
    <form class="search" method="get" action="{{ route('admin.users') }}">
        <div class="field">
            <label for="q">查询用户（ID、姓名或手机号）</label>
            <input id="q" name="q" type="search" value="{{ request('q') }}">
        </div>
        <label>运营审核<select name="verify_status"><option value="">全部</option><option>pending</option><option>approved</option><option>rejected</option></select></label><label>处罚<select name="moderation_status"><option value="">全部</option><option>normal</option><option>restricted</option><option>banned</option></select></label><button type="submit">查询</button>
        <a href="{{ route('admin.users') }}">清除查询</a>
    </form>
    <div class="table-scroll" tabindex="0" role="region" aria-label="用户查询结果">
        <table>
            <caption>当前查询结果，共 {{ $users->total() }} 个账号</caption>
            <thead><tr><th scope="col">ID</th><th scope="col">姓名</th><th scope="col">手机号</th><th scope="col">状态</th><th scope="col">操作</th></tr></thead>
            <tbody>
            @forelse ($users as $user)
                <tr>
                    <th scope="row">{{ $user->id }} <a href="{{ route('admin.user',$user->id) }}">详情/审核</a></th>
                    <td>{{ $user->name ?: '未设置' }}</td>
                    <td>{{ $user->phone }}</td>
                    <td>{{ $user->disabled ? '已禁用' : '正常' }}</td>
                    <td class="actions">
                        @if ($user->disabled)
                            <span class="muted">已禁用，无需重复操作</span>
                        @elseif ($user->role !== 'user' || (string) $user->id === (string) auth()->id())
                            <span class="muted">此处仅可禁用普通用户，不能禁用当前账号</span>
                        @else
                            <form method="post" action="{{ route('admin.disable', ['userId' => $user->id]) }}">
                                @csrf
<input type="hidden" name="expected_revision" value="{{ $user->admin_revision }}"><label>原因<input name="reason" required maxlength="1000"></label>
                                <label class="confirmation" for="confirm-{{ $user->id }}">
                                    <input id="confirm-{{ $user->id }}" name="confirm_disable" type="checkbox" value="1" required>
                                    <span>确认禁用账号 #{{ $user->id }}</span>
                                </label>
                                <button class="danger" type="submit">禁用账号 #{{ $user->id }}</button>
                            </form>
                        @endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="5">没有找到符合条件的账号。</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    @if ($users->hasPages())
        <nav aria-label="分页">
            @if ($users->onFirstPage())
                <span>上一页</span>
            @else
                <a href="{{ $users->appends(request()->only('q'))->previousPageUrl() }}">上一页</a>
            @endif
            <span>第 {{ $users->currentPage() }} / {{ $users->lastPage() }} 页</span>
            @if ($users->hasMorePages())
                <a href="{{ $users->appends(request()->only('q'))->nextPageUrl() }}">下一页</a>
            @else
                <span>下一页</span>
            @endif
        </nav>
    @endif
</section>
@endsection
