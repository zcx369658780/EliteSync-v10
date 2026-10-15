import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class LiveConnectionPage extends ConsumerStatefulWidget {
  const LiveConnectionPage({super.key, this.peerId});
  final int? peerId;
  @override
  ConsumerState<LiveConnectionPage> createState() => _LiveConnectionPageState();
}

class _LiveConnectionPageState extends ConsumerState<LiveConnectionPage> {
  SessionState? _session;
  int? _peer;
  Map<String, dynamic>? _server;
  String? _error;
  bool _busy = false;
  int _epoch = 0;
  CancelToken _requestCancellation = CancelToken();

  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  @override
  void dispose() {
    _requestCancellation.cancel('Page disposed');
    super.dispose();
  }

  Options _options(SessionState session, int epoch) =>
      Options(extra: {requestSessionGuardKey: () => _current(session, epoch)});

  Map<String, dynamic> _data(NetworkResult<Map<String, dynamic>> result) {
    if (result is NetworkSuccess<Map<String, dynamic>>) return result.data;
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw StateError('${failure.message}（HTTP ${failure.statusCode ?? "未知"}）');
  }

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _epoch &&
      identical(ref.read(sessionProvider).asData?.value, session);

  Future<void> _read(SessionState session, int epoch) async {
    final client = ref.read(apiClientProvider);
    int? peer = _peer ?? widget.peerId;
    if (peer == null) {
      final match = _data(
        await client.get(
          '/api/v1/matches/current',
          cancelToken: _requestCancellation,
          options: _options(session, epoch),
        ),
      );
      if (!_current(session, epoch)) return;
      peer = (match['partner_id'] as num?)?.toInt();
    }
    if (peer == null || peer <= 0) throw StateError('暂无已发布匹配对象。');
    final data = _data(
      await client.get(
        '/api/v1/connections/$peer',
        cancelToken: _requestCancellation,
        options: _options(session, epoch),
      ),
    );
    if (!_current(session, epoch)) return;
    for (final kind in ['connection', 'consent']) {
      final value = data[kind];
      if (value is! Map ||
          value['state'] is! String ||
          value['revision'] is! int ||
          (value['revision'] as int) < 0) {
        throw StateError('服务端状态格式无效。');
      }
    }
    if (data['gates'] is! Map) throw StateError('服务端权限状态缺失。');
    _peer = peer;
    _server = data;
  }

  Future<void> _refresh() =>
      _request((session, epoch) => _read(session, epoch));

  Future<void> _action(String kind, String action, int revision) => _request((
    session,
    epoch,
  ) async {
    final peer = _peer;
    if (peer == null) throw StateError('请刷新当前连接。');
    // Discard the projection while writing, and always confirm with a fresh GET.
    _server = null;
    _data(
      await ref
          .read(apiClientProvider)
          .post(
            '/api/v1/connections/$peer/$kind',
            cancelToken: _requestCancellation,
            options: _options(session, epoch),
            body: {'action': action, 'expected_revision': revision},
          ),
    );
    if (!_current(session, epoch)) return;
    await _read(session, epoch);
  });

  Future<void> _request(Future<void> Function(SessionState, int) action) async {
    if (!mounted || _busy) return;
    _requestCancellation.cancel('Previous request completed');
    _requestCancellation = CancelToken();
    final epoch = _epoch;
    setState(() {
      _busy = true;
      _error = null;
    });
    SessionState? session;
    try {
      final started = await ref.read(sessionProvider.future);
      session = started;
      if (!_current(started, epoch)) return;
      if (!started.isLoggedIn) throw StateError('请登录后读取连接。');
      if (!identical(_session, started)) {
        _peer = null;
        _server = null;
      }
      _session = started;
      await action(started, epoch);
    } catch (error) {
      if (mounted &&
          epoch == _epoch &&
          (session == null || _current(session, epoch))) {
        _server = null;
        _error = error.toString();
        _requestCancellation.cancel('Request not confirmed');
      }
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  List<String> _actions(String kind, Map state, int? actor) {
    final name = state['state'];
    if (kind == 'consent' &&
        (_server?['connection'] as Map?)?['state'] != 'CN_ACTIVE') {
      return [];
    }
    if (name == 'CN_NONE' || name == 'MC_NONE') return ['request'];
    if (name == 'CN_PENDING' || name == 'MC_PENDING') {
      final requester = (state['requester_id'] as num?)?.toInt();
      if (actor == null || requester == null) return [];
      return actor == requester ? ['withdraw'] : ['accept', 'decline'];
    }
    if (name == 'CN_ACTIVE') return ['close'];
    if (name == 'CN_PAUSED') return ['close'];
    if (name == 'MC_ACTIVE') return ['revoke'];
    return [];
  }

  String _label(String kind, String action) {
    final subject = kind == 'connection' ? '连接' : '消息同意';
    return switch (action) {
      'request' => '请求$subject',
      'accept' => '接受$subject',
      'decline' => '拒绝$subject',
      'withdraw' => '撤回$subject请求',
      'close' => '关闭连接',
      'revoke' => '撤销消息同意',
      _ => action,
    };
  }

  Widget _card(String kind, String title, Map state, int? actor) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text('服务端状态：${state['state']}；版本：${state['revision']}'),
          for (final action in _actions(kind, state, actor))
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _action(kind, action, state['revision'] as int),
              child: Text(_label(kind, action)),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      final current = next.asData?.value;
      if (_session != null && !identical(_session, current)) {
        setState(() {
          _requestCancellation.cancel('Request session invalidated');
          _epoch++;
          _session = null;
          _peer = null;
          _server = null;
          _error = null;
          _busy = false;
        });
      }
    });
    final session = ref.watch(sessionProvider).asData?.value;
    final confirmed =
        session?.isLoggedIn == true && identical(session, _session);
    final data = confirmed ? _server : null;
    final gates = data?['gates'] as Map?;
    final canChat =
        gates?['live_read_allowed'] == true &&
        gates?['live_send_allowed'] == true;
    return AppScaffold(
      appBar: const AppTopBar(title: '连接与消息同意', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('匹配 ≠ 连接 ≠ 消息同意。双方须独立决定，消息读取和发送均由服务端当前权限验证。'),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(
              '操作未确认：$_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (confirmed && _peer != null) Text('对象 ID：$_peer'),
          if (data != null) ...[
            _card(
              'connection',
              '独立 Connection',
              data['connection'] as Map,
              session?.user?.id,
            ),
            _card(
              'consent',
              '独立 Messaging Consent',
              data['consent'] as Map,
              session?.user?.id,
            ),
          ],
          OutlinedButton(
            onPressed: _busy ? null : _refresh,
            child: const Text('刷新当前状态'),
          ),
          FilledButton(
            onPressed: !_busy && canChat && _peer != null
                ? () => context.push('/live-chat/$_peer')
                : null,
            child: const Text('进入消息'),
          ),
        ],
      ),
    );
  }
}
