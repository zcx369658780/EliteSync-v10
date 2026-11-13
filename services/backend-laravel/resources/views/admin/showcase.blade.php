@extends('admin.layout')
@section('title', '展示资料提交')
@section('content')
<h1>提交 #{{ $record->id }} · 用户 #{{ $record->user_id }}</h1>
<p><a href="{{ route('admin.showcase.index') }}">返回提交列表</a> · <a href="{{ route('admin.user', $record->user_id) }}">账号与运营资格</a></p>
<p>内容版本 {{ $record->content_revision }} · {{ $record->state }} · {{ $current ? '当前草稿版本' : '已有更新的草稿，本提交仅供回看' }}</p>
<section class="panel">
@foreach(['display_name'=>'展示昵称', 'city'=>'城市', 'relationship_goal'=>'关系意向', 'self_intro'=>'自我介绍', 'opener_note'=>'开场介绍'] as $key => $label)
<h2>{{ $label }}</h2><p style="white-space:pre-wrap;overflow-wrap:anywhere">{{ $snapshot[$key] ?? '未填写' }}</p>
@endforeach
@foreach(['interest_tags'=>'兴趣', 'lifestyle_tags'=>'生活方式', 'audiences'=>'选择的展示范围'] as $key => $label)
<h2>{{ $label }}</h2><p>{{ implode('、', $snapshot[$key] ?? []) }}</p>
@endforeach
<h2>展示照片</h2>
@forelse(($snapshot['photo_ids'] ?? []) as $photo)
<img src="{{ route('admin.showcase.photo', ['submission'=>$record->id, 'photo'=>$photo]) }}" alt="提交照片 {{ $loop->iteration }}" style="max-width:16rem;max-height:16rem">
@empty
<p>未选择照片。</p>
@endforelse
</section>
<section class="panel">
<h2>审核反馈</h2>
<p style="white-space:pre-wrap;overflow-wrap:anywhere">{{ $record->reason ?? '尚未处理' }}</p>
@if($record->state === 'pending' && $current)
<form method="post" action="{{ route('admin.showcase.review', $record->id) }}">
@csrf
<input type="hidden" name="expected_revision" value="{{ $record->content_revision }}">
<label for="showcase-result">结果</label>
<select id="showcase-result" name="result" required>
<option value="needs_revision">需要修改</option><option value="approved">通过</option><option value="rejected">驳回</option>
</select>
<label for="showcase-reason">反馈</label>
<textarea id="showcase-reason" name="reason" required maxlength="1000" rows="4" style="width:100%">{{ old('reason') }}</textarea>
<label><input type="checkbox" name="confirm" value="1" required>确认处理此内容版本</label>
<button>保存审核反馈</button>
</form>
@endif
</section>
@endsection
