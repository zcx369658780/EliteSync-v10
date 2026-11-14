@extends('admin.layout')
@section('title', '支持反馈')
@section('content')
<h1>支持反馈</h1>
<section class="panel">
@forelse($feedback as $item)
<p><a href="{{ route('admin.support-feedback.show', $item->id) }}">反馈 #{{ $item->id }} · 用户 #{{ $item->user_id }} · {{ $item->category }}</a> · {{ $item->status }} · {{ $item->updated_at }}</p>
@empty
<p>暂无反馈。</p>
@endforelse
{{ $feedback->links() }}
</section>
@endsection
