@extends('admin.layout')
@section('content')<h1>举报处理</h1><p>仅展示个案所需元数据，不提供私信全文浏览。</p><table><tr><th>ID</th><th>类别</th><th>目标账号</th><th>状态</th></tr>@foreach($reports as $r)<tr><td><a href="{{ route('admin.report',$r->id) }}">举报#{{ $r->id }}</a></td><td>{{ $r->category }}</td><td>#{{ $r->target_user_id }}</td><td>{{ $r->status }}</td></tr>@endforeach</table>{{ $reports->links() }}@endsection
