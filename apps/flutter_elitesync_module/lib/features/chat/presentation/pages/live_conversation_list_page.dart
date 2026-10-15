import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class LiveConversationListPage extends ConsumerStatefulWidget {
  const LiveConversationListPage({super.key});
  @override
  ConsumerState<LiveConversationListPage> createState() =>
      _LiveConversationListPageState();
}

class _LiveConversationListPageState
    extends ConsumerState<LiveConversationListPage> {
  SessionState? _session;
  List<Map<String, dynamic>> _items = [];
  bool _busy = false;
  String? _error;
  int _epoch = 0;
  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _epoch &&
      identical(ref.read(sessionProvider).asData?.value, session);
  Future<void> _refresh() async {
    if (!mounted || _busy) return;
    final epoch = _epoch;
    setState(() {
      _busy = true;
      _error = null;
      _items = [];
    });
    SessionState? started;
    try {
      final session = await ref.read(sessionProvider.future);
      started = session;
      if (!_current(session, epoch)) return;
      if (!session.isLoggedIn) throw StateError('请登录后读取会话。');
      _session = session;
      final response = await ref
          .read(apiClientProvider)
          .get('/api/v1/conversations');
      if (!_current(session, epoch)) return;
      if (response is NetworkFailure<Map<String, dynamic>>) {
        throw StateError(
          '${response.message}（HTTP ${response.statusCode ?? "未知"}）',
        );
      }
      final data = (response as NetworkSuccess<Map<String, dynamic>>).data;
      if (data['ok'] != true || data['items'] is! List) {
        throw StateError('会话响应未确认。');
      }
      final items = <Map<String, dynamic>>[];
      for (final raw in data['items'] as List) {
        if (raw is! Map ||
            raw['peer_user_id'] is! int ||
            (raw['peer_user_id'] as int) <= 0) {
          throw StateError('会话对象身份无效。');
        }
        items.add(Map<String, dynamic>.from(raw));
      }
      _items = items;
    } catch (error) {
      if (mounted &&
          epoch == _epoch &&
          (started == null || _current(started, epoch))) {
        _items = [];
        _error = error.toString();
      }
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (_session != null && !identical(_session, next.asData?.value)) {
        setState(() {
          _epoch++;
          _session = null;
          _items = [];
          _error = null;
          _busy = false;
        });
      }
    });
    final session = ref.watch(sessionProvider).asData?.value;
    final items = session?.isLoggedIn == true && identical(session, _session)
        ? _items
        : <Map<String, dynamic>>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新会话',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('仅显示服务端当前允许读取的会话。连接与消息同意各有独立生命周期，进入聊天后仍逐次验证权限。'),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(
              '会话读取未确认：$_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (!_busy && _error == null && items.isEmpty)
            const Text('暂无服务端可读取会话，请刷新或先完成双方连接和消息同意。'),
          for (final item in items)
            ListTile(
              title: Text(
                (item['name'] ?? '会话对象 ${item['peer_user_id']}').toString(),
              ),
              subtitle: Text((item['last_message'] ?? '').toString()),
              trailing: Text('未读 ${(item['unread'] as num?)?.toInt() ?? 0}'),
              onTap: () => context.push('/live-chat/${item['peer_user_id']}'),
            ),
        ],
      ),
    );
  }
}
