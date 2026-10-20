import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

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
  bool _hiddenOnly = false;
  late final ProviderSubscription<int> _authoritySubscription;
  @override
  void initState() {
    super.initState();
    _authoritySubscription = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, next) {
        setState(() {
          _epoch++;
          _busy = false;
          _items = [];
          _error = null;
        });
        Future.microtask(_refresh);
      },
    );
    Future.microtask(_refresh);
  }

  @override
  void dispose() {
    _authoritySubscription.close();
    _epoch++;
    super.dispose();
  }

  Future<void> _visibility(Map<String, dynamic> item) async {
    final session = _session;
    final epoch = _epoch;
    if (session == null || !_current(session, epoch)) return;
    final id = _conversationId(item);
    if (id == null) {
      setState(() => _error = '服务端未提供会话身份，未执行隐藏。');
      return;
    }
    try {
      await ref.read(relationshipApiProvider).call(
        'POST',
        '/conversations/$id/visibility',
        {'hidden': !_hiddenOnly},
      );
      if (!_current(session, epoch)) return;
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    } catch (e) {
      if (_current(session, epoch)) setState(() => _error = '$e');
    }
  }

  int? _conversationId(Map<String, dynamic> item) {
    final id = int.tryParse('${item['conversation_id']}');
    return id != null && id > 0 ? id : null;
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
          .get(
            '/api/v1/conversations',
            query: {'hidden_only': _hiddenOnly ? 1 : 0},
            options: Options(
              extra: {requestSessionGuardKey: () => _current(session, epoch)},
            ),
          );
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
          SwitchListTile(
            title: const Text('查看我隐藏的会话'),
            subtitle: const Text('隐藏只影响本人入口，不删除消息，也不改变联系授权。'),
            value: _hiddenOnly,
            onChanged: _busy
                ? null
                : (value) {
                    setState(() {
                      _hiddenOnly = value;
                      _items = [];
                    });
                    _refresh();
                  },
          ),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('未读 ${(item['unread'] as num?)?.toInt() ?? 0}'),
                  if (_conversationId(item) != null)
                    PopupMenuButton<String>(
                      onSelected: (_) => _visibility(item),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'visibility',
                          child: Text(_hiddenOnly ? '找回会话入口' : '仅对我隐藏'),
                        ),
                      ],
                    ),
                ],
              ),
              onLongPress: _conversationId(item) == null
                  ? null
                  : () => _visibility(item),
              onTap: _hiddenOnly
                  ? null
                  : () => context.push('/live-chat/${item['peer_user_id']}'),
            ),
        ],
      ),
    );
  }
}
