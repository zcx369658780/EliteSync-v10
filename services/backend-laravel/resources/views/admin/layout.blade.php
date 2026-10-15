<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', '管理面板') · EliteSync</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: #f5f7fb; color: #172033; font: 1rem/1.6 system-ui, sans-serif; }
        header, main { max-width: 72rem; margin: auto; padding: 1.25rem; }
        header { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 1rem; }
        h1 { font-size: 1.75rem; line-height: 1.3; }
        h2 { font-size: 1.25rem; }
        a { color: #2146ac; }
        .panel { background: white; border: 1px solid #d6dce6; border-radius: .75rem; padding: 1.5rem; }
        .login { max-width: 30rem; margin: auto; }
        .field { margin: 1rem 0; }
        label { display: block; font-weight: 600; }
        input:not([type=checkbox]) { width: 100%; padding: .7rem; border: 1px solid #7a879b; border-radius: .35rem; font: inherit; }
        button { min-height: 2.75rem; padding: .5rem 1rem; background: #2146ac; color: white; border: 0; border-radius: .35rem; font: inherit; cursor: pointer; }
        button.danger { background: #a51f2b; }
        :focus-visible { outline: 3px solid #d68c00; outline-offset: 3px; }
        .notice { padding: 1rem; margin-bottom: 1rem; border-left: .3rem solid #23774d; background: #eaf7ef; }
        .errors { border-color: #a51f2b; background: #fff0f0; }
        .muted { color: #526078; }
        .search { display: flex; flex-wrap: wrap; align-items: end; gap: 1rem; margin-bottom: 1.5rem; }
        .search .field { flex: 1; min-width: 14rem; margin: 0; }
        .table-scroll { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: .8rem; text-align: left; border-bottom: 1px solid #d6dce6; vertical-align: top; overflow-wrap: anywhere; }
        th { background: #f5f7fb; }
        .confirmation { display: flex; gap: .5rem; align-items: flex-start; font-weight: 400; margin-bottom: .75rem; }
        .confirmation input { margin-top: .35rem; }
        .actions { min-width: 13rem; }
        nav[aria-label="分页"] { display: flex; flex-wrap: wrap; gap: 1rem; margin-top: 1.5rem; }
        @media (max-width: 40rem) { header, main { padding: 1rem; } .panel { padding: 1rem; } }
    </style>
</head>
<body>
<header>
    <strong>EliteSync 管理面板</strong>
    @auth
<nav aria-label="管理模块"><a href="/admin">用户/审核</a> · <a href="/admin/reports">举报</a> · <a href="/admin/matching">匹配运营</a> · <a href="/admin/questions">问卷</a> · <a href="/admin/releases">开发版本</a> · <a href="/admin/audits">审计</a></nav>
        <form method="post" action="{{ route('admin.logout') }}">
            @csrf
            <button type="submit">退出管理端</button>
        </form>
    @endauth
</header>
<main>
    @if (session('status'))
        <div class="notice" role="status">{{ session('status') }}</div>
    @endif
    @if ($errors->any())
        <div class="notice errors" role="alert">
            <strong>操作未完成，请检查：</strong>
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif
    @yield('content')
</main>
</body>
</html>
