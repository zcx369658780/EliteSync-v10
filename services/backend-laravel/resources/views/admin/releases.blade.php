@extends('admin.layout')
@section('title', '开发渠道版本发布')
@section('content')
<h1>Android 开发渠道版本</h1>
<p>仅管理 development 渠道；创建后需单独激活。当前列表修订号 {{ $revision }}。</p>
<section class="panel">
<h2>{{ $editing ? '编辑版本 #'.$editing->id : '创建版本' }}</h2>
<form method="post" action="/admin/releases">
    @csrf
    <input type="hidden" name="action" value="upsert">
    <input type="hidden" name="expected_revision" value="{{ $revision }}">
    @if($editing)<input type="hidden" name="id" value="{{ $editing->id }}">@endif
    @foreach(['version_name' => '发布版本（如 0.01.05）', 'version_code' => '版本代码（正整数）', 'min_supported_version_name' => '最低支持版本', 'download_url' => '下载 URL（HTTPS 或本地 :8000 HTTP）', 'sha256' => 'SHA256（64位十六进制）'] as $name => $label)
        <div class="field"><label for="{{ $name }}">{{ $label }}</label><input id="{{ $name }}" name="{{ $name }}" value="{{ old($name, $editing?->$name) }}" required @if($name === 'version_code') type="number" min="1" @endif></div>
    @endforeach
    <div class="field"><label for="changelog">更新说明</label><textarea id="changelog" name="changelog" rows="4" maxlength="20000" style="width:100%">{{ old('changelog', $editing?->changelog) }}</textarea></div>
    <label class="confirmation"><input type="checkbox" name="force_update" value="1" @checked(old('force_update', $editing?->force_update))>标记需要更新（仅开发渠道）</label>
    <div class="field"><label for="reason">操作理由</label><input id="reason" name="reason" required maxlength="500"></div>
    <label class="confirmation"><input type="checkbox" name="confirm" value="1" required>确认保存此版本元数据</label>
    <button type="submit">保存</button> <a href="/admin/releases">清除编辑</a>
</form>
</section>
<div class="table-scroll"><table><thead><tr><th>版本</th><th>状态与内容</th><th>操作</th></tr></thead><tbody>
@forelse($releases as $release)
<tr><td>#{{ $release->id }} {{ $release->version_name }} ({{ $release->version_code }})<br>最低 {{ $release->min_supported_version_name }}</td>
<td>{{ $release->is_active ? '已激活' : '已停用' }}<br>{{ $release->download_url }}<br>{{ $release->sha256 }}<br>{{ $release->changelog }}</td>
<td class="actions"><a href="/admin/releases?edit={{ $release->id }}">编辑</a>
<form method="post" action="/admin/releases">@csrf
<input type="hidden" name="id" value="{{ $release->id }}"><input type="hidden" name="expected_revision" value="{{ $revision }}">
<input type="hidden" name="action" value="{{ $release->is_active ? 'deactivate' : 'activate' }}">
<label for="reason-{{ $release->id }}">操作理由</label><input id="reason-{{ $release->id }}" name="reason" required maxlength="500">
<label class="confirmation"><input type="checkbox" name="confirm" value="1" required>确认{{ $release->is_active ? '停用' : '激活' }}此版本</label>
<button type="submit">{{ $release->is_active ? '停用' : '激活' }}</button></form></td></tr>
@empty<tr><td colspan="3">暂无开发渠道版本。</td></tr>@endforelse
</tbody></table></div>
{{ $releases->links() }}
@endsection
