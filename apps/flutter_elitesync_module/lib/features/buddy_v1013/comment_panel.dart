import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';

/// Changing posts remounts the guarded body, invalidating its in-flight requests.
class CommentPanel extends ConsumerStatefulWidget {
  const CommentPanel({super.key, required this.postId});
  final int postId;

  @override
  ConsumerState<CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends ConsumerState<CommentPanel> {
  @override
  Widget build(BuildContext context) =>
      _CommentBody(key: ValueKey(widget.postId), postId: widget.postId);
}

class _CommentBody extends ConsumerStatefulWidget {
  const _CommentBody({super.key, required this.postId});
  final int postId;

  @override
  ConsumerState<_CommentBody> createState() => _CommentsState();
}

class _CommentsState extends SessionBoundPage<_CommentBody>
    with WidgetsBindingObserver {
  @override
  String get resource => '/status-posts/${widget.postId}/comments';
  final _draft = TextEditingController();
  int _localGeneration = 0;
  String? _replyTo;
  Map<String, dynamic>? _pendingComment;
  bool _verifiedNotApplied = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    invalidatePendingProjection();
    if (_foreground) refresh();
  }

  void _clear() {
    _localGeneration++;
    _draft.clear();
    _replyTo = null;
    _verifiedNotApplied = false;
  }

  @override
  void onIdentityChanged() {
    _clear();
    _pendingComment = null;
  }

  @override
  void onAuthorityChanged() => _clear();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draft.dispose();
    super.dispose();
  }

  Future<void> _write(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final generation = _localGeneration;
    final result = await run(() async {
      final api = ref.read(relationshipApiProvider);
      await api.call(method, path, body);
      return api.call('GET', resource);
    }, replace: true);
    if (!mounted || result == null || generation != _localGeneration) return;
    setState(_clear);
  }

  Future<void> _sendComment(Map<String, dynamic> command) async {
    final generation = _localGeneration;
    setState(() {
      _pendingComment = command;
      _verifiedNotApplied = false;
    });
    final result = await run(() async {
      final api = ref.read(relationshipApiProvider);
      await api.call('POST', resource, command);
      return api.call('GET', resource);
    }, replace: true);
    if (!mounted || result == null || generation != _localGeneration) return;
    setState(() {
      _pendingComment = null;
      _clear();
    });
  }

  Future<void> _checkCommentResult() async {
    final pending = _pendingComment;
    if (pending == null) return;
    final key = Uri.encodeQueryComponent(pending['idempotency_key'] as String);
    final lookup = await run(
      () => ref
          .read(relationshipApiProvider)
          .call('GET', '$resource/command-result?request_key=$key'),
    );
    if (!mounted || lookup == null || !identical(pending, _pendingComment)) {
      return;
    }
    if (lookup['state'] == 'APPLIED') {
      setState(() => _pendingComment = null);
      await refresh();
    } else if (lookup['state'] == 'NOT_APPLIED') {
      await refresh();
      if (mounted && identical(pending, _pendingComment)) {
        setState(() => _verifiedNotApplied = true);
      }
    }
  }

  Future<void> _changeDisplay(
    Map<String, dynamic> comment,
    String action,
  ) async {
    final withdraw = action == 'WITHDRAW';
    final ok = await confirm(
      withdraw ? '撤回本人评论展示？' : '隐藏第三方评论展示？',
      withdraw ? '此作品中将停止展示你的评论。' : '此作品中将停止展示该评论，其他人的回复按当前权限处理。',
    );
    if (!ok) return;
    final id = Uri.encodeComponent(comment['id'] as String);
    await _write('PUT', '$resource/$id/display', {
      'action': action,
      'revision': comment['revision'],
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_foreground) return const SizedBox.shrink();
    final items = rows(data?['items']);
    final meta = objectMap(data?['meta']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '作品评论',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              key: const Key('comments-refresh'),
              tooltip: '刷新评论',
              onPressed: busy ? null : refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        if (busy) const LinearProgressIndicator(),
        if (error != null) ...[
          Text('评论暂不可读取或操作：$error', key: const Key('comments-error')),
          const Text('旧评论已清除。请检查网络或当前权限后刷新。'),
        ],
        if (data != null) ...[
          if (items.isEmpty)
            const Text('当前没有可见评论。', key: Key('comments-empty')),
          for (final comment in items)
            Card(
              key: ValueKey('comment-${comment['id']}'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comment['thread_context'] == 'UNAVAILABLE')
                      const Text('上文当前不可显示，以下回复可独立阅读。'),
                    if (comment['thread_context'] == 'REPLY') const Text('回复'),
                    if (comment['body'] is String) ...[
                      Text('ES-${comment['author_id']}'),
                      Text(comment['body'] as String),
                    ] else
                      const Text('评论当前不可见。'),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (comment['can_withdraw'] == true &&
                            comment['id'] is String &&
                            comment['revision'] is int)
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => _changeDisplay(comment, 'WITHDRAW'),
                            child: const Text('撤回我的评论'),
                          ),
                        if (comment['can_hide'] == true &&
                            comment['id'] is String &&
                            comment['revision'] is int)
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => _changeDisplay(comment, 'HIDE'),
                            child: const Text('隐藏评论'),
                          ),
                        if (data?['can_comment'] == true &&
                            _pendingComment == null &&
                            comment['can_reply'] == true &&
                            comment['id'] is String)
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => setState(
                                    () => _replyTo = comment['id'] as String,
                                  ),
                            child: const Text('回复'),
                          ),
                        if (comment['can_report'] == true &&
                            comment['body'] is String &&
                            comment['id'] is String)
                          TextButton(
                            key: ValueKey('comment-report-${comment['id']}'),
                            onPressed: busy
                                ? null
                                : () async {
                                    if (!await confirm(
                                      '举报这条评论？',
                                      '只提交待审核事实，不自动处罚。',
                                    )) {
                                      return;
                                    }
                                    await _write(
                                      'POST',
                                      '$resource/${Uri.encodeComponent(comment['id'] as String)}/report',
                                      {'reason_code': 'other'},
                                    );
                                  },
                            child: const Text('举报评论'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (meta['has_more'] == true && meta['next_cursor'] is String)
            OutlinedButton(
              key: const Key('comments-next-page'),
              onPressed: busy
                  ? null
                  : () => run(
                      () => ref
                          .read(relationshipApiProvider)
                          .call(
                            'GET',
                            '$resource?cursor=${Uri.encodeQueryComponent(meta['next_cursor'] as String)}',
                          ),
                      replace: true,
                    ),
              child: const Text('加载下一页（替换当前页）'),
            ),
          if (data?['can_comment'] == true && _pendingComment == null) ...[
            const SizedBox(height: 12),
            if (_replyTo != null) ...[
              Row(
                children: [
                  const Expanded(child: Text('正在回复评论')),
                  TextButton(
                    onPressed: () => setState(() => _replyTo = null),
                    child: const Text('取消回复'),
                  ),
                ],
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => _sendComment({
                        'parent_id': _replyTo,
                        'independent_response': 'THANKS',
                        'idempotency_key': requestKey(),
                      }),
                child: const Text('独立回复：谢谢分享这个话题。'),
              ),
            ],
            TextField(
              key: const Key('comment-draft'),
              controller: _draft,
              enabled: !busy,
              maxLength: 280,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _replyTo == null ? '写评论' : '写回复',
                helperText: '不填写链接、联系方式、私聊内容或附件。',
              ),
            ),
            FilledButton(
              key: const Key('comment-submit'),
              onPressed: busy
                  ? null
                  : () async {
                      final body = _draft.text.trim();
                      if (body.isEmpty) {
                        setState(() => error = '请输入评论。');
                        return;
                      }
                      await _sendComment({
                        'body': body,
                        'parent_id': ?_replyTo,
                        'idempotency_key': requestKey(),
                      });
                    },
              child: Text(_replyTo == null ? '提交评论' : '提交回复'),
            ),
          ] else if (_pendingComment == null)
            const Text('当前账号暂不能发表评论。'),
        ],
        if (_pendingComment != null)
          OutlinedButton(
            onPressed: busy ? null : _checkCommentResult,
            child: const Text('核对上次评论提交'),
          ),
        if (_pendingComment != null &&
            _verifiedNotApplied &&
            data?['can_comment'] == true)
          FilledButton(
            onPressed: busy ? null : () => _sendComment(_pendingComment!),
            child: const Text('重试原请求'),
          ),
        if (data == null && !busy && error == null)
          const Text('评论尚未取得当前账号授权，请刷新或重新登录。'),
      ],
    );
  }
}
