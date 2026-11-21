<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>EliteSync 管理员账号激活</title>
</head>
<body>
<main>
    <h1>管理员账号激活</h1>
    @if ($done)
        <p>新密码已设置。现在可以用原手机号和新密码登录 V2。</p>
        <p><a href="{{ route('admin.login') }}">前往管理员登录</a></p>
    @else
        <p>输入收到的一次性激活码，并为 V2 设置新密码。</p>
        @if ($error)
            <p role="alert">{{ $error }}</p>
        @endif
        <form method="post" action="{{ route('admin.legacy-activate.submit') }}" autocomplete="off">
            @csrf
            <p><label>激活码 <input type="password" name="activation_code" autocomplete="off" required maxlength="64"></label></p>
            <p><label>新密码 <input type="password" name="new_password" autocomplete="new-password" required minlength="12"></label></p>
            <p><label>确认新密码 <input type="password" name="new_password_confirmation" autocomplete="new-password" required minlength="12"></label></p>
            <button type="submit">设置新密码</button>
        </form>
    @endif
</main>
</body>
</html>
