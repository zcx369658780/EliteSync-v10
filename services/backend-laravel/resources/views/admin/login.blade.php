@extends('admin.layout')

@section('title', '管理员登录')

@section('content')
<section class="panel login" aria-labelledby="login-title">
    <h1 id="login-title">管理员登录</h1>
    <p class="muted">请使用已授权的管理员账号。普通账号不能进入管理面板。</p>
    <form method="post" action="{{ route('admin.authenticate') }}">
        @csrf
        <div class="field">
            <label for="phone">手机号</label>
            <input id="phone" name="phone" type="tel" autocomplete="username" value="{{ old('phone') }}" required>
        </div>
        <div class="field">
            <label for="password">密码</label>
            <input id="password" name="password" type="password" autocomplete="current-password" required>
        </div>
        <button type="submit">登录管理端</button>
    </form>
</section>
@endsection
