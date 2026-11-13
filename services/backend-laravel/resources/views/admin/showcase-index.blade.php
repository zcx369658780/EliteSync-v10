@extends('admin.layout')
@section('title', '展示资料审核')
@section('content')
<h1>展示资料审核</h1>
<p>每条提交绑定内容版本。通过后由本人明确选择发布。</p>
<section class="panel">
@forelse($submissions as $submission)
<p><a href="{{ route('admin.showcase.show', $submission->id) }}">提交 #{{ $submission->id }} · 用户 #{{ $submission->user_id }} · 版本 {{ $submission->content_revision }}</a> · {{ $submission->state }}</p>
@empty
<p>暂无提交。</p>
@endforelse
{{ $submissions->links() }}
</section>
@endsection
