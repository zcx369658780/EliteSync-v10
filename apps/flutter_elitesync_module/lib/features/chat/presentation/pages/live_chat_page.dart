import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/private_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_attempt.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';

final liveChatMediaGatewayProvider = Provider<ChatMediaGateway>(
  (ref) => PlatformChatMediaGateway(apiClient: ref.watch(apiClientProvider)),
);

class LiveChatPage extends ConsumerStatefulWidget {
  const LiveChatPage({super.key, required this.peerId});
  final int peerId;
  @override
  ConsumerState<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends ConsumerState<LiveChatPage>
    with WidgetsBindingObserver {
  ChatSendAttempt? _attempt;
  int? _retryAsset;
  String? _sendStatus;
  bool _foreground = true;
  bool _offline = false;
  bool _sessionChanged = false;
  bool _timeLocked = false;
  bool _hadTrustedCache = false;
  bool _picking = false;
  StreamSubscription? _socket;
  String get _cacheKey => 'live-chat:${widget.peerId}';
  PrivateCacheService get _cache =>
      PrivateCacheService.forStorage(ref.read(secureStorageProvider));
  bool _transportUnavailable(NetworkFailure result) {
    final error = result.error;
    return error is SocketException ||
        error is TimeoutException ||
        (error is DioException &&
            const {
              DioExceptionType.connectionError,
              DioExceptionType.connectionTimeout,
              DioExceptionType.receiveTimeout,
              DioExceptionType.sendTimeout,
            }.contains(error.type));
  }

  final _text = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  Map<int, Uint8List> _images = {};
  String? _error;
  bool _busy = false;
  bool _loading = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_load);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _retentionTick();
      if (mounted &&
          _foreground &&
          !_offline &&
          !_sessionChanged &&
          !_timeLocked) {
        await _load();
      }
    });
  }

  Future<void> _retentionTick() async {
    if (_timeLocked || (!_hadTrustedCache && _messages.isEmpty)) return;
    final epoch = _epoch;
    final session = _session;
    final receipt = await _cache.purgeExpired();
    final saved = _offline
        ? await _cache.readOffline(_cacheKey)
        : await _cache.readOnlineAuthorized(_cacheKey);
    if (!mounted || epoch != _epoch || !identical(_session, session)) return;
    if ((saved == null && (_messages.isNotEmpty || _images.isNotEmpty)) ||
        receipt.status != PrivateCachePurgeStatus.notDue ||
        !_cache.isUnlocked) {
      _reject(
        receipt.status == PrivateCachePurgeStatus.completed
            ? '30天期限已到，本账户离线缓存已清理。'
            : '可信时间或缓存校验失效，私密内容已锁定。',
      );
      setState(() => _timeLocked = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSocket();
    _timer?.cancel();
    _uploadCancellation.cancel('Page disposed');
    _text.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      _offline = false;
      _cache.beginOnlineRevalidation();
      _load();
    } else {
      _cancelSocket();
      _foreground = false;
      // Cancellation does not prove that the server did not commit this POST.
      _reject('返回应用后需联网重新验证会话。', preserveAttempt: _picking || _attempt != null);
    }
  }

  SessionState? _session;
  int _epoch = 0;
  CancelToken _uploadCancellation = CancelToken();

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _epoch &&
      _foreground &&
      !_sessionChanged &&
      identical(ref.read(sessionProvider).asData?.value, session);

  void _cancelSocket() {
    final socket = _socket;
    _socket = null;
    if (socket != null) unawaited(socket.cancel());
  }

  void _reject(String message, {bool preserveAttempt = false}) {
    _cancelSocket();
    if (!mounted) return;
    setState(() {
      _epoch++;
      _uploadCancellation.cancel('Request session invalidated');
      _uploadCancellation = CancelToken();
      _messages = [];
      _images = {};
      if (!preserveAttempt) {
        _text.clear();
        _attempt = null;
        _retryAsset = null;
        _sendStatus = null;
      }
      _error = message;
      _loading = false;
      _busy = false;
    });
  }

  Future<void> _load() async {
    if (_loading ||
        !mounted ||
        !_foreground ||
        _sessionChanged ||
        _timeLocked) {
      return;
    }
    _loading = true;
    final epoch = _epoch;
    SessionState? started;
    try {
      final session = await ref.read(sessionProvider.future);
      started = session;
      if (!_current(session, epoch)) return;
      if (!session.isLoggedIn) {
        _reject('当前无法读取对话，请检查登录、连接与双方消息同意。');
        return;
      }
      _session = session;
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/messages',
            query: {'peer_id': widget.peerId, 'limit': 100},
            cancelToken: _uploadCancellation,
            options: Options(
              extra: {requestSessionGuardKey: () => _current(session, epoch)},
            ),
          );
      if (!_current(session, epoch)) return;
      if (response is! NetworkSuccess<Map<String, dynamic>>) {
        if (response is NetworkFailure<Map<String, dynamic>> &&
            response.statusCode == null &&
            _transportUnavailable(response)) {
          _cache.enterOffline();
          final saved = await _cache.readOffline(_cacheKey);
          if (!_current(session, epoch)) return;
          if (saved != null) {
            setState(() {
              _messages = (saved['messages'] as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
              _images = {
                for (final e in (saved['images'] as Map? ?? {}).entries)
                  int.parse(e.key.toString()): base64Decode(e.value.toString()),
              };
              _offline = true;
              _busy = false;
              _error = '离线只读：仅显示已加密保存且此前有权读取的内容，不能发送或编辑。';
            });
            return;
          }
        }
        _cache.revokeObject(_cacheKey);
        _reject(
          '当前无法读取对话，请检查登录、连接与双方消息同意。',
          preserveAttempt:
              response is NetworkFailure<Map<String, dynamic>> &&
              (_transportUnavailable(response) ||
                  response.statusCode == null ||
                  response.statusCode! >= 500 ||
                  response.statusCode == 408 ||
                  response.statusCode == 429),
        );
        return;
      }
      final items = (response.data['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final images = <int, Uint8List>{};
      for (final message in items) {
        for (final attachment in (message['attachments'] as List? ?? [])) {
          final asset = attachment['media_asset'];
          if (asset is! Map || asset['media_type'] != 'image') continue;
          final id = (asset['id'] as num).toInt();
          final data = await ref
              .read(dioProvider)
              .get<List<int>>(
                '/api/v1/media/$id/content',
                cancelToken: _uploadCancellation,
                options: Options(
                  responseType: ResponseType.bytes,
                  extra: {
                    requestSessionGuardKey: () => _current(session, epoch),
                  },
                ),
              );
          if (!_current(session, epoch)) return;
          images[id] = Uint8List.fromList(data.data ?? []);
        }
      }
      if (!_current(session, epoch)) return;
      _hadTrustedCache = await _cache.saveAuthorized(
        _cacheKey,
        {
          'messages': items,
          'images': {
            for (final e in images.entries) '${e.key}': base64Encode(e.value),
          },
        },
        expectedAccountId: session.user?.id,
        isCurrent: () => _current(session, epoch),
      );
      if (!_current(session, epoch)) return;
      if (!_hadTrustedCache || !_cache.isUnlocked) {
        _reject('可信登录或加密保存未能核验，私密内容已锁定，请重新在线登录。');
        setState(() => _timeLocked = true);
        return;
      }
      setState(() {
        _messages = items;
        _images = images;
        _error = null;
        _offline = false;
        // A current read may observe this message while its POST response is
        // still pending. Keep the attempt until that POST (or its same-key
        // retry) acknowledges it; a later timeout must not create a new key
        // for the unchanged draft.
      });
      if (_current(session, epoch) &&
          _socket == null &&
          session.accessToken?.isNotEmpty == true) {
        _socket = ref
            .read(chatSocketDataSourceProvider)
            .observe('${widget.peerId}')
            .listen(
              (_) {
                if (_current(session, epoch) && !_offline && !_timeLocked) {
                  _load();
                }
              },
              onError: (_) {},
              onDone: () {
                // A terminal old-generation callback must not erase a new handle.
                if (_current(session, epoch)) _socket = null;
              },
            );
      }
    } catch (_) {
      if (started != null && _current(started, epoch)) {
        _reject('当前无法读取消息或附件，请检查登录、连接与双方消息同意。');
      }
    } finally {
      if (epoch == _epoch) _loading = false;
    }
  }

  Future<void> _post(SessionState session, int epoch, {int? asset}) async {
    if (!_current(session, epoch) || _offline) return;
    // An unconfirmed POST owns its immutable payload and idempotency key.
    // A changed controller value must never replace that logical attempt.
    final attempt =
        _attempt ??
        ChatSendAttempt.create(
          peerUserId: widget.peerId,
          content: _text.text.trim(),
          attachmentIds: asset == null ? <int>[] : [asset],
        );
    if (attempt.content.isEmpty && attempt.attachmentIds.isEmpty) return;
    _attempt = attempt;
    _retryAsset = asset;
    setState(() => _sendStatus = '发送中，等待服务器确认');
    final result = await ref
        .read(apiClientProvider)
        .post(
          '/api/v1/messages',
          cancelToken: _uploadCancellation,
          options: Options(
            extra: {requestSessionGuardKey: () => _current(session, epoch)},
          ),
          body: {
            'receiver_id': attempt.peerUserId,
            'content': attempt.content,
            'client_message_id': attempt.clientMessageId,
            if (attempt.attachmentIds.isNotEmpty)
              'attachment_ids': attempt.attachmentIds,
          },
        );
    if (!_current(session, epoch)) return;
    if (result is! NetworkSuccess<Map<String, dynamic>>) {
      final unknown =
          result is NetworkFailure<Map<String, dynamic>> &&
          (result.statusCode == null ||
              result.statusCode! >= 500 ||
              result.statusCode == 408 ||
              result.statusCode == 429);
      _reject('发送未完成，服务器未授权或当前会话已失效。', preserveAttempt: unknown);
      setState(
        () => _sendStatus = unknown
            ? '发送结果尚未确认，请按重试；将使用同一个消息编号。'
            : '服务器拒绝了此消息，请重新验证当前权限。',
      );
      return;
    }
    if (result.data['client_message_id'] != attempt.clientMessageId ||
        result.data['id'] is! num) {
      _reject('服务器确认身份不符，不能标记已发送；请按原编号重试。', preserveAttempt: true);
      return;
    }
    _attempt = null;
    _retryAsset = null;
    setState(() => _sendStatus = '服务器已确认此消息');
    _text.clear();
    await _load();
    if (!_current(session, epoch)) return;
  }

  Future<void> _send({int? asset}) async {
    if (_busy ||
        !mounted ||
        _offline ||
        !_foreground ||
        _sessionChanged ||
        _timeLocked) {
      return;
    }
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null || !session.isLoggedIn) {
      _reject('发送未完成，服务器未授权或当前会话已失效。');
      return;
    }
    _session = session;
    final epoch = _epoch;
    setState(() => _busy = true);
    try {
      await _post(session, epoch, asset: asset);
    } catch (_) {
      if (_current(session, epoch)) {
        setState(() {
          _sendStatus = '发送结果尚未确认，请按重试；将使用同一个消息编号。';
        });
      }
    } finally {
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  Future<void> _picture() => _attachment(ChatAttachmentKind.image);
  Future<void> _video() => _attachment(ChatAttachmentKind.video);

  Future<void> _attachment(ChatAttachmentKind kind) async {
    if (_busy ||
        _attempt != null ||
        !mounted ||
        _offline ||
        _sessionChanged ||
        _timeLocked) {
      return;
    }
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null || !session.isLoggedIn) {
      _reject('附件上传或处理未完成，仅支持25MiB内、30秒内的MP4/H.264视频或图片。');
      return;
    }
    _session = session;
    var epoch = _epoch;
    setState(() => _busy = true);
    try {
      final gateway = ref.read(liveChatMediaGatewayProvider);
      _picking = true;
      final picked = await gateway.pick(kind);
      _picking = false;
      if (!mounted ||
          !_foreground ||
          _sessionChanged ||
          !identical(ref.read(sessionProvider).asData?.value, session) ||
          picked == null) {
        return;
      }
      // A native picker crosses pause/resume. Never reuse its former authority;
      // obtain a fresh current read under the new foreground epoch before upload.
      epoch = _epoch;
      final check = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/messages',
            query: {'peer_id': widget.peerId, 'limit': 1},
            options: Options(
              extra: {requestSessionGuardKey: () => _current(session, epoch)},
            ),
          );
      if (!_current(session, epoch) ||
          check is! NetworkSuccess<Map<String, dynamic>>) {
        return;
      }
      setState(() => _busy = true);
      if (gateway is! SessionBoundChatMediaGateway) {
        throw StateError('附件上传缺少会话保护');
      }
      final uploaded = await gateway.uploadForSession(
        kind,
        picked,
        isCurrent: () => _current(session, epoch),
        cancelToken: _uploadCancellation,
      );
      if (!_current(session, epoch)) return;
      if (uploaded.assetId == null || uploaded.status != 'ready') {
        throw StateError('附件尚未就绪');
      }
      await _post(session, epoch, asset: uploaded.assetId);
      if (!_current(session, epoch)) return;
    } catch (_) {
      if (_current(session, epoch)) {
        _reject('附件上传或处理未完成，仅支持25MiB内、30秒内的MP4/H.264视频或图片。');
      }
    } finally {
      _picking = false;
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  Future<void> _call(String mode) async {
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null ||
        !session.isLoggedIn ||
        _busy ||
        _offline ||
        _timeLocked ||
        _sessionChanged) {
      return;
    }
    final epoch = _epoch;
    setState(() => _busy = true);
    try {
      final call = await ref
          .read(rtcRemoteDataSourceProvider)
          .createCall(peerUserId: widget.peerId, mode: mode);
      if (!mounted || !_current(session, epoch)) return;
      final route = call.isTerminal
          ? AppRouteNames.rtcCallResult
          : AppRouteNames.rtcCall;
      await context.push('$route/${call.id}');
    } catch (_) {
      if (_current(session, epoch)) {
        setState(() => _error = '当前无法通话，请检查双方连接、消息同意及账号状态。');
      }
    } finally {
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  void _openVideo(int assetId) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrivateVideoPlayer(assetId: assetId),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(relationshipAuthorityEpochProvider, (_, next) {
      _cache.revokeObject(_cacheKey);
      _reject('授权已变化，请联网重新验证。');
    });
    ref.listen(sessionProvider, (previous, next) {
      if (_session != null && !identical(_session, next.asData?.value)) {
        _cancelSocket();
        setState(() {
          _epoch++;
          _uploadCancellation.cancel('Request session invalidated');
          _uploadCancellation = CancelToken();
          _session = null;
          _sessionChanged = true;
          _attempt = null;
          _retryAsset = null;
          _sendStatus = null;
          _messages = [];
          _images = {};
          _loading = false;
          _busy = false;
          _text.clear();
          _error = '账号已变化，请重新打开对话。';
        });
      }
    });
    if (!_foreground || _sessionChanged || _timeLocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('会话已锁定')),
        body: Center(child: Text(_error ?? '请从当前账号重新打开')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('对话'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: _busy ? null : () => _call('voice'),
            tooltip: '语音通话',
            icon: const Icon(Icons.call_outlined),
          ),
          IconButton(
            onPressed: _busy ? null : () => _call('video'),
            tooltip: '视频通话',
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
          if (_sendStatus != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_sendStatus!),
            ),
          if (_attempt != null && !_offline)
            TextButton(
              onPressed: _busy ? null : () => _send(asset: _retryAsset),
              child: const Text('使用原消息编号重试'),
            ),
          Expanded(
            child: ListView(
              children: _messages
                  .map(
                    (m) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['content']?.toString() ?? ''),
                            for (final a in (m['attachments'] as List? ?? []))
                              if (a['media_asset'] is Map)
                                if (_images[(a['media_asset']['id'] as num)
                                        .toInt()]
                                    case final bytes?)
                                  Image.memory(bytes, height: 140),
                            for (final a in (m['attachments'] as List? ?? []))
                              if (a['media_asset'] is Map &&
                                  a['media_asset']['media_type'] == 'video')
                                TextButton.icon(
                                  onPressed: () => _openVideo(
                                    (a['media_asset']['id'] as num).toInt(),
                                  ),
                                  icon: const Icon(Icons.play_circle_outline),
                                  label: const Text('播放私有视频'),
                                ),
                            Text(
                              m['is_read'] == true ? '已读' : '未读',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      _busy || _attempt != null || _offline || _timeLocked
                      ? null
                      : _picture,
                  icon: const Icon(Icons.image),
                  tooltip: '发送图片',
                ),
                IconButton(
                  onPressed:
                      _busy || _attempt != null || _offline || _timeLocked
                      ? null
                      : _video,
                  icon: const Icon(Icons.video_library_outlined),
                  tooltip: '发送短视频',
                ),
                Expanded(
                  child: TextField(
                    readOnly:
                        _busy || _attempt != null || _offline || _timeLocked,
                    controller: _text,
                    decoration: const InputDecoration(hintText: '输入消息'),
                  ),
                ),
                TextButton(
                  onPressed:
                      _busy || _attempt != null || _offline || _timeLocked
                      ? null
                      : () => _send(),
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
