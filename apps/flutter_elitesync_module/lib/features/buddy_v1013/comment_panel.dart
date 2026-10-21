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

class _CommentsState extends SessionBoundPage<_CommentBody> {
  @override
  String get resource => '/status-posts/${widget.postId}/comments';
  final _draft = TextEditingController();
  int _localGeneration = 0;

  void _clear() {
    _localGeneration++;
    _draft.clear();
  }

  @override
  void onIdentityChanged() => _clear();
  @override
  void onAuthorityChanged() => _clear();

  @override
  void dispose() {
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
    setState(() => _draft.clear());
  }

  @override
  Widget build(BuildContext context) {
    final items = rows(data?['items']);
    final meta = objectMap(data?['meta']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '好友一级评论',
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
        const Text('只在当前动态受众内交流；不含私信附件或多级回复。'),
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
                    if (comment['body'] is String) ...[
                      Text('ES-${comment['author_id']}'),
                      Text(comment['body'] as String),
                    ] else
                      const Text('此评论已删除或不可见。'),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (comment['can_delete'] == true &&
                            comment['id'] is String &&
                            comment['revision'] is int)
                          TextButton(
                            key: ValueKey('comment-delete-${comment['id']}'),
                            onPressed: busy
                                ? null
                                : () async {
                                    if (!await confirm(
                                      '删除这条评论？',
                                      '保留最小删除记录，不再向读者显示正文。',
                                    )) {
                                      return;
                                    }
                                    await _write(
                                      'DELETE',
                                      '$resource/${Uri.encodeComponent(comment['id'] as String)}',
                                      {'revision': comment['revision']},
                                    );
                                  },
                            child: const Text('删除评论'),
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
          const SizedBox(height: 12),
          TextField(
            key: const Key('comment-draft'),
            controller: _draft,
            enabled: !busy,
            maxLength: 280,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '一级评论',
              helperText: '不填写链接、联系方式、私聊内容或附件；每10分钟最多5次。',
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
                    await _write('POST', resource, {
                      'body': body,
                      'idempotency_key': requestKey(),
                    });
                  },
            child: const Text('提交评论'),
          ),
        ],
        if (data == null && !busy && error == null)
          const Text('评论尚未取得当前账号授权，请刷新或重新登录。'),
      ],
    );
  }
}
