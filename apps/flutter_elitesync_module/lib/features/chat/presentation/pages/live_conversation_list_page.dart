import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';

class LiveConversationListPage extends ConsumerStatefulWidget {
  const LiveConversationListPage({super.key});
  @override
  ConsumerState<LiveConversationListPage> createState() =>
      _LiveConversationListPageState();
}

class _LiveConversationListPageState
    extends ConsumerState<LiveConversationListPage>
    with WidgetsBindingObserver {
  SessionState? _session;
  List<Map<String, dynamic>> _items = [];
  bool _busy = false;
  String? _error;
  int _epoch = 0;
  bool _hiddenOnly = false;
  bool _offlineReadOnly = false;
  bool _trustedContextLocked = false;
  bool _foreground = true;
  String? _cacheStatus;
  Timer? _retentionTimer;
  PrivateCacheService get _cache =>
      PrivateCacheService.forStorage(ref.read(secureStorageProvider));
  String get _cacheObject =>
      'live-conversations:${_hiddenOnly ? 'hidden' : 'visible'}';
  late final ProviderSubscription<int> _authoritySubscription;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _retentionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_checkRetention()),
    );
    _authoritySubscription = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, next) {
        _cache.beginOnlineRevalidation();
        setState(() {
          _epoch++;
          _busy = false;
          _items = [];
          _error = null;
          _offlineReadOnly = false;
          _cacheStatus = null;
        });
        Future.microtask(_refresh);
      },
    );
    Future.microtask(_refresh);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retentionTimer?.cancel();
    _authoritySubscription.close();
    _epoch++;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _foreground = true);
      unawaited(_refresh());
    } else {
      setState(() {
        _epoch++;
        _busy = false;
        _foreground = false;
        _items = [];
      });
    }
  }

  void _lockDisplay(String message) {
    _items = [];
    _offlineReadOnly = false;
    _trustedContextLocked = true;
    _cacheStatus = message;
    _error = null;
  }

  Future<void> _checkRetention() async {
    final session = _session;
    final epoch = _epoch;
    if (session == null) return;
    final purge = await _cache.purgeExpired();
    if (!_current(session, epoch)) return;
    if (!_cache.isUnlocked ||
        purge.status == PrivateCachePurgeStatus.completed ||
        purge.status == PrivateCachePurgeStatus.failed) {
      setState(() => _lockDisplay(_purgeMessage(purge)));
      return;
    }
    final saved = _cache.isOffline
        ? await _cache.readOffline(_cacheObject)
        : await _cache.readOnlineAuthorized(_cacheObject);
    if (!_current(session, epoch)) return;
    if (saved == null) {
      setState(() => _lockDisplay('当前私有内容的读取资格已失效，请重新核验或在线登录。'));
    }
  }

  String _purgeMessage(PrivateCachePurgeReceipt receipt) =>
      switch (receipt.status) {
        PrivateCachePurgeStatus.completed => '私有缓存已到期并完成清理，请重新在线登录。',
        PrivateCachePurgeStatus.failed => '私有缓存清理失败，内容已锁定，请重新在线登录后重试清理。',
        _ => '无法确认可信登录与设备时间，私有内容已锁定，请重新在线登录。',
      };

  bool _transportUnavailable(NetworkFailure<Map<String, dynamic>> failure) {
    if (failure.statusCode != null) return false;
    final error = failure.error;
    return error is DioException &&
        const {
          DioExceptionType.connectionError,
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
        }.contains(error.type);
  }

  Map<String, dynamic> _savedItem(Map<String, dynamic> item) => {
    'peer_user_id': item['peer_user_id'],
    'conversation_id': _conversationId(item),
    'name': (item['name'] ?? '会话对象').toString(),
    'last_message': (item['last_message'] ?? '').toString(),
    'unread': 0,
  };

  Future<void> _showOwnedOfflineCopy(SessionState session, int epoch) async {
    _cache.enterOffline();
    final purge = await _cache.purgeExpired();
    final saved = await _cache.readOffline(_cacheObject);
    if (!_current(session, epoch)) return;
    if (!_cache.isUnlocked ||
        purge.status == PrivateCachePurgeStatus.completed ||
        purge.status == PrivateCachePurgeStatus.failed) {
      _lockDisplay(_purgeMessage(purge));
      return;
    }
    if (saved == null || saved['items'] is! List) {
      _items = [];
      _error = '当前离线，没有本次可信登录并经服务端核验后保存的加密会话。';
      return;
    }
    final decoded = <Map<String, dynamic>>[];
    for (final raw in saved['items'] as List) {
      if (raw is! Map ||
          raw['peer_user_id'] is! int ||
          (raw['peer_user_id'] as int) <= 0) {
        _cache.lock();
        _lockDisplay('私有缓存校验失败，内容已锁定，请重新在线登录。');
        return;
      }
      decoded.add(_savedItem(Map<String, dynamic>.from(raw)));
    }
    _items = decoded;
    _trustedContextLocked = false;
    _offlineReadOnly = true;
    _error = null;
    _cacheStatus = '离线只读：仅显示本次在线核验后加密保存的内容；不能实时得知远端撤权，联网后须先重新核验。';
  }

  Future<void> _visibility(Map<String, dynamic> item) async {
    if (_offlineReadOnly || _trustedContextLocked || !_foreground) return;
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
      _offlineReadOnly = false;
    });
    SessionState? started;
    try {
      final session = await ref.read(sessionProvider.future);
      started = session;
      if (!_current(session, epoch)) return;
      if (!session.isLoggedIn) throw StateError('请登录后读取会话。');
      _session = session;
      if (_trustedContextLocked && !_cache.isUnlocked) return;
      final purge = await _cache.purgeExpired();
      if (!_current(session, epoch)) return;
      if (purge.status == PrivateCachePurgeStatus.completed ||
          purge.status == PrivateCachePurgeStatus.failed) {
        _lockDisplay(_purgeMessage(purge));
        return;
      }
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
        if (_transportUnavailable(response)) {
          await _showOwnedOfflineCopy(session, epoch);
          return;
        }
        _cache.revokeObject(_cacheObject);
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
      _cache.beginOnlineRevalidation();
      final saved = await _cache.saveAuthorized(
        _cacheObject,
        {'items': items.map(_savedItem).toList()},
        expectedAccountId: session.user?.id,
        isCurrent: () => _current(session, epoch),
      );
      if (!_current(session, epoch)) return;
      if (!saved || !_cache.isUnlocked) {
        _lockDisplay('加密私有缓存未能确认保存或可信登录已失效，内容已锁定，请重新在线登录。');
        return;
      }
      _trustedContextLocked = false;
      _offlineReadOnly = false;
      _cacheStatus = '当前会话已按账户和设备加密保存。';
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
        final current = next.asData?.value;
        if (current?.isLoggedIn != true ||
            _cache.accountId != current?.user?.id) {
          _cache.lock();
        }
        setState(() {
          _epoch++;
          _session = null;
          _items = [];
          _error = null;
          _busy = false;
          _offlineReadOnly = false;
          _cacheStatus = null;
        });
        if (current?.isLoggedIn == true) Future.microtask(_refresh);
      }
    });
    final session = ref.watch(sessionProvider).asData?.value;
    final items =
        _foreground &&
            !_trustedContextLocked &&
            session?.isLoggedIn == true &&
            identical(session, _session)
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
          if (_cacheStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _cacheStatus!,
                key: const ValueKey('live-private-cache-status'),
              ),
            ),
          if (!_foreground) const Text('应用返回前台后将先重新核验。'),
          if (_offlineReadOnly) const Text('离线只读：不可打开新会话、发送、隐藏或修改。'),
          SwitchListTile(
            title: const Text('查看我隐藏的会话'),
            subtitle: const Text('隐藏只影响本人入口，不删除消息，也不改变联系授权。'),
            value: _hiddenOnly,
            onChanged: _busy || _offlineReadOnly || _trustedContextLocked
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
          if (!_busy &&
              _error == null &&
              !_trustedContextLocked &&
              items.isEmpty)
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
                  if (!_offlineReadOnly && _conversationId(item) != null)
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
              onLongPress: _offlineReadOnly || _conversationId(item) == null
                  ? null
                  : () => _visibility(item),
              onTap: _hiddenOnly || _offlineReadOnly
                  ? null
                  : () => context.push('/live-chat/${item['peer_user_id']}'),
            ),
        ],
      ),
    );
  }
}
