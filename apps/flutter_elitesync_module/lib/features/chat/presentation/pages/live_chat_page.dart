import 'package:flutter_elitesync_module/features/profile/avatar/authenticated_avatar.dart';
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
  bool _draftLoaded = false;
  bool _draftBusy = false;
  String? _draftStatus;
  bool _picking = false;
  int _peerEpoch = 0;
  ChatPickedMedia? _pendingMedia;
  ChatAttachmentKind? _pendingMediaKind;
  int? _readyMediaAsset;
  String? _uploadStatus;
  StreamSubscription? _socket;
  String get _cacheKey => 'live-chat:${widget.peerId}';
  String get _draftKey => 'live-chat-draft:${widget.peerId}';
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
  int? _previewImageId;
  String? _error;
  bool _busy = false;
  bool _loading = false;
  bool _loadingOlder = false;
  int? _queuedHistoryEpoch;
  bool _hasOlder = false;
  bool _historyExpanded = false;
  String? _historyError;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_load);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _retentionTick();
      if (mounted && _foreground && !_sessionChanged && !_timeLocked) {
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
    if (_offline &&
        !_cache.isOffline &&
        _cache.isUnlocked &&
        receipt.status == PrivateCachePurgeStatus.notDue) {
      // Another retained page recovered first. Hide this page's old offline
      // copy until its own current read, instead of treating a mode change as
      // a broken login or expired clock.
      _reject('网络已恢复，正在重新验证对话。', preserveAttempt: true);
      _offline = false;
      return;
    }
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
  void didUpdateWidget(covariant LiveChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.peerId == widget.peerId) return;
    _peerEpoch++;
    _picking = false;
    _reject('正在加载对话。');
    _session = null;
    _offline = false;
    _sessionChanged = false;
    _timeLocked = false;
    _hadTrustedCache = false;
    Future.microtask(_load);
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
      // Duplicate resumed notifications do not start another trust epoch while
      // the current read may still be serializing its authorized cache copy.
      if (_foreground) return;
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
  int _avatarRefresh = 0;
  CancelToken _uploadCancellation = CancelToken();

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _epoch &&
      _foreground &&
      !_sessionChanged &&
      !_timeLocked &&
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
      _previewImageId = null;
      _loadingOlder = false;
      _queuedHistoryEpoch = null;
      _hasOlder = false;
      _historyExpanded = false;
      _historyError = null;
      _pendingMedia = null;
      _pendingMediaKind = null;
      _readyMediaAsset = null;
      _uploadStatus = null;
      _draftLoaded = false;
      _draftStatus = null;
      _draftBusy = false;
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

  Map<String, dynamic> _offlineSnapshot(
    List<Map<String, dynamic>> messages,
    Map<int, Uint8List> images,
  ) {
    // Offline storage is a selected copy, not a prerequisite for keeping every
    // authorized online attachment. Leave headroom for the encrypted envelope.
    const budget = 256 * 1024;
    var bytes = 1024;
    final selected = <Map<String, dynamic>>[];
    // The server returns ascending IDs; prefer the most recent messages.
    for (final message in messages.reversed) {
      final size = utf8.encode(jsonEncode(message)).length + 1;
      if (bytes + size > budget) continue;
      selected.add(message);
      bytes += size;
    }
    final selectedImages = <String, String>{};
    for (final message in selected) {
      for (final attachment in (message['attachments'] as List? ?? [])) {
        final asset = attachment['media_asset'];
        if (asset is! Map || asset['media_type'] != 'image') continue;
        final id = (asset['id'] as num).toInt();
        final image = images[id];
        if (image == null || selectedImages.containsKey('$id')) continue;
        final size = 4 * ((image.length + 2) ~/ 3) + '$id'.length + 6;
        if (bytes + size > budget) continue;
        selectedImages['$id'] = base64Encode(image);
        bytes += size;
      }
    }
    return {'messages': selected.reversed.toList(), 'images': selectedImages};
  }

  bool _restoreTextDraft(Map<String, dynamic>? draft, {required bool offline}) {
    if (!_cache.isUnlocked ||
        (draft != null &&
            (draft['text'] is! String ||
                (draft['text'] as String).length > 5000))) {
      _cache.lock();
      _reject('草稿校验失败，私密内容已锁定，请重新在线登录。');
      setState(() => _timeLocked = true);
      return false;
    }
    if (draft?['pending_attempt'] case final Map pending) {
      try {
        final ids = pending['attachment_ids'];
        if (pending['peer_user_id'] != widget.peerId ||
            pending['content'] != (draft!['text'] as String).trim() ||
            ids is! List ||
            ids.length > 1 ||
            ids.any((id) => id is! int || id <= 0)) {
          throw const FormatException('Invalid submission binding.');
        }
        final attempt = ChatSendAttempt(
          clientMessageId: pending['client_message_id'] as String,
          peerUserId: widget.peerId,
          content: pending['content'] as String,
          attachmentIds: ids.cast<int>(),
        );
        if (_attempt != null &&
            (_attempt!.clientMessageId != attempt.clientMessageId ||
                !_attempt!.hasSamePayload(
                  peerUserId: attempt.peerUserId,
                  content: attempt.content,
                  attachmentIds: attempt.attachmentIds,
                ))) {
          throw const FormatException('Submission changed.');
        }
        _attempt = attempt;
        _text.text = attempt.content;
        _retryAsset = attempt.attachmentIds.firstOrNull;
        _sendStatus = '上次发送尚未完成，请使用原消息编号重试。';
      } catch (_) {
        _cache.lock();
        _reject('草稿发送编号校验失败，私密内容已锁定，请重新在线登录。');
        setState(() => _timeLocked = true);
        return false;
      }
    } else if (draft != null && draft.containsKey('pending_attempt')) {
      _cache.lock();
      _reject('草稿发送编号校验失败，私密内容已锁定，请重新在线登录。');
      setState(() => _timeLocked = true);
      return false;
    }
    if (draft != null && _text.text.isEmpty) {
      _text.text = draft['text'] as String;
      _draftStatus = offline ? '离线草稿只读，重新联网核验后才可编辑。' : '已恢复本人草稿，发送前请确认。';
    }
    _draftLoaded = true;
    return true;
  }

  Future<void> _load() async {
    if (_loading ||
        _loadingOlder ||
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
            query: {'peer_id': widget.peerId, 'limit': 100, 'latest': 1},
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
            if (!_draftLoaded) {
              final draft = await _cache.readOffline(_draftKey);
              if (!_current(session, epoch)) return;
              if (!_restoreTextDraft(draft, offline: true)) return;
            }
            setState(() {
              _messages = (saved['messages'] as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
              _images = {
                for (final e in (saved['images'] as Map? ?? {}).entries)
                  int.parse(e.key.toString()): base64Decode(e.value.toString()),
              };
              if (!_images.containsKey(_previewImageId)) _previewImageId = null;
              _offline = true;
              // The selected offline copy may omit older pages to fit its
              // storage budget. Rebuild the history boundary after reconnect.
              _historyExpanded = false;
              _hasOlder = false;
              _historyError = null;
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
      final keepHistory = _historyExpanded && items.isNotEmpty;
      final additions = <Map<String, dynamic>>[];
      if (keepHistory && _messages.isNotEmpty) {
        var cursor = (_messages.last['id'] as num).toInt();
        final newestWindowStart = (items.first['id'] as num).toInt();
        // A burst can move the live window beyond the loaded tail. Bridge that
        // gap with ascending pages rather than discarding the expanded history.
        while (cursor < newestWindowStart) {
          final delta = await ref
              .read(apiClientProvider)
              .get(
                '/api/v1/messages',
                query: {
                  'peer_id': widget.peerId,
                  'after_id': cursor,
                  'limit': 100,
                },
                cancelToken: _uploadCancellation,
                options: Options(
                  extra: {
                    requestSessionGuardKey: () => _current(session, epoch),
                  },
                ),
              );
          if (!_current(session, epoch)) return;
          if (delta is! NetworkSuccess<Map<String, dynamic>>) {
            if (delta is NetworkFailure<Map<String, dynamic>> &&
                const {401, 403, 404}.contains(delta.statusCode)) {
              _cache.revokeObject(_cacheKey);
              _reject('当前无法读取对话，请检查登录、连接与双方消息同意。');
            } else {
              setState(() => _error = '新消息加载未完成，请刷新重试。');
            }
            return;
          }
          final page = (delta.data['items'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .where((item) => (item['id'] as num).toInt() > cursor)
              .toList();
          if (page.isEmpty) {
            setState(() => _error = '新消息加载未完成，请刷新重试。');
            return;
          }
          additions.addAll(page);
          cursor = (page.last['id'] as num).toInt();
        }
      }
      final fresh = _mergeMessages(additions, items);
      final freshImages = await _messageImages(fresh, session, epoch);
      if (!_current(session, epoch)) return;
      final visible = keepHistory ? _mergeMessages(_messages, fresh) : fresh;
      final images = keepHistory ? {..._images, ...freshImages} : freshImages;
      // Like the conversation list, recover only after this current read; an
      // ordinary online refresh must not invalidate another page's cache write.
      if (_cache.isOffline) _cache.beginOnlineRevalidation();
      _hadTrustedCache = await _cache.saveAuthorized(
        _cacheKey,
        _offlineSnapshot(visible, images),
        expectedAccountId: session.user?.id,
        isCurrent: () => _current(session, epoch),
      );
      if (!_current(session, epoch)) return;
      if (!_hadTrustedCache || !_cache.isUnlocked) {
        _reject('可信登录或加密保存未能核验，私密内容已锁定，请重新在线登录。');
        setState(() => _timeLocked = true);
        return;
      }
      if (!_draftLoaded) {
        final draft = await _cache.readAfterCurrentAuthorization(
          _draftKey,
          expectedAccountId: session.user!.id,
          isCurrent: () => _current(session, epoch),
        );
        if (!_current(session, epoch)) return;
        if (!_restoreTextDraft(draft, offline: false)) return;
      }
      setState(() {
        _messages = visible;
        _images = images;
        if (!images.containsKey(_previewImageId)) _previewImageId = null;
        if (!keepHistory) {
          _historyExpanded = false;
          _hasOlder = response.data['has_more'] as bool? ?? items.length == 100;
        }
        // A newest-window read cannot acknowledge an unread older page.
        if (!_hasOlder) _historyError = null;
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
      if (epoch == _epoch) {
        _loading = false;
        final queued = _queuedHistoryEpoch;
        _queuedHistoryEpoch = null;
        if (queued == epoch && started != null && _current(started, epoch)) {
          unawaited(_loadOlder());
        }
      }
    }
  }

  List<Map<String, dynamic>> _mergeMessages(
    List<Map<String, dynamic>> older,
    List<Map<String, dynamic>> newer,
  ) {
    final byId = <int, Map<String, dynamic>>{
      for (final message in [...older, ...newer])
        (message['id'] as num).toInt(): message,
    };
    return byId.values.toList()
      ..sort((a, b) => (a['id'] as num).compareTo(b['id'] as num));
  }

  Future<Map<int, Uint8List>> _messageImages(
    List<Map<String, dynamic>> messages,
    SessionState session,
    int epoch,
  ) async {
    final images = <int, Uint8List>{};
    for (final message in messages) {
      for (final attachment in (message['attachments'] as List? ?? [])) {
        final asset = attachment['media_asset'];
        if (asset is! Map || asset['media_type'] != 'image') continue;
        final id = (asset['id'] as num).toInt();
        if (images.containsKey(id)) continue;
        final data = await ref
            .read(dioProvider)
            .get<List<int>>(
              '/api/v1/media/$id/content',
              cancelToken: _uploadCancellation,
              options: Options(
                responseType: ResponseType.bytes,
                extra: {requestSessionGuardKey: () => _current(session, epoch)},
              ),
            );
        if (!_current(session, epoch)) return {};
        images[id] = Uint8List.fromList(data.data ?? []);
      }
    }
    return images;
  }

  Future<void> _loadOlder() async {
    if (_loadingOlder || !_hasOlder || _offline || _messages.isEmpty) {
      return;
    }
    final session = _session;
    final epoch = _epoch;
    if (session == null || !_current(session, epoch)) return;
    if (_loading) {
      // Coalesce repeated taps while the live window finishes refreshing.
      _queuedHistoryEpoch = epoch;
      return;
    }
    _queuedHistoryEpoch = null;
    final before = (_messages.first['id'] as num).toInt();
    setState(() {
      _loadingOlder = true;
      _historyError = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/messages',
            query: {
              'peer_id': widget.peerId,
              'before_id': before,
              'limit': 100,
            },
            cancelToken: _uploadCancellation,
            options: Options(
              extra: {requestSessionGuardKey: () => _current(session, epoch)},
            ),
          );
      if (!_current(session, epoch)) return;
      if (response is! NetworkSuccess<Map<String, dynamic>>) {
        if (response is NetworkFailure<Map<String, dynamic>> &&
            const {401, 403, 404}.contains(response.statusCode)) {
          _cache.revokeObject(_cacheKey);
          _reject('当前无法读取对话，请检查登录、连接与双方消息同意。');
        } else {
          setState(() => _historyError = '较早消息加载失败，请重试。');
        }
        return;
      }
      final items = (response.data['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .where((item) => (item['id'] as num).toInt() < before)
          .toList();
      final images = await _messageImages(items, session, epoch);
      if (!_current(session, epoch)) return;
      setState(() {
        _messages = _mergeMessages(items, _messages);
        _images = {...images, ..._images};
        _historyExpanded = true;
        _hasOlder =
            items.isNotEmpty &&
            (response.data['has_more'] as bool? ?? items.length == 100);
      });
    } catch (error) {
      if (!_current(session, epoch)) return;
      if (error is DioException &&
          const {401, 403, 404}.contains(error.response?.statusCode)) {
        _cache.revokeObject(_cacheKey);
        _reject('当前无法读取消息或附件，请重新验证当前权限。');
      } else {
        setState(() => _historyError = '较早消息加载失败，请重试。');
      }
    } finally {
      if (_current(session, epoch)) setState(() => _loadingOlder = false);
    }
  }

  Future<void> _saveDraft({bool clear = false}) async {
    if (_busy || _draftBusy || !_draftLoaded || _offline || _attempt != null) {
      return;
    }
    final session = _session;
    final epoch = _epoch;
    if (session == null || !_current(session, epoch)) return;
    final text = _text.text;
    if (text.length > 5000) {
      setState(() => _draftStatus = '草稿最多保存5000个字符。');
      return;
    }
    setState(() => _draftBusy = true);
    try {
      if (clear || text.isEmpty) {
        if (!await _cache.removeObject(_draftKey)) {
          throw StateError('Draft clear was superseded.');
        }
        if (!_current(session, epoch)) return;
        setState(() {
          _text.clear();
          _draftStatus = '本机草稿已清除。';
        });
      } else {
        final saved = await _cache.saveAuthorized(
          _draftKey,
          {'text': text},
          expectedAccountId: session.user!.id,
          isCurrent: () => _current(session, epoch) && _text.text == text,
        );
        if (!_current(session, epoch)) return;
        if (!saved && !_cache.isUnlocked) {
          _reject('草稿保存未能核验，私密内容已锁定，请重新在线登录。');
          setState(() => _timeLocked = true);
          return;
        }
        setState(
          () => _draftStatus = saved ? '草稿已加密保存在本机，尚未发送。' : '草稿保存未完成，请重新核验后重试。',
        );
      }
    } catch (_) {
      if (_current(session, epoch)) {
        setState(() => _draftStatus = '草稿处理未完成，请重试。');
      }
    } finally {
      if (_current(session, epoch)) setState(() => _draftBusy = false);
    }
  }

  Future<bool> _canStartSubmission(SessionState session, int epoch) async {
    if (_attempt != null || _draftLoaded) return true;
    final indexed = await _cache.hasIndexedObject(
      _draftKey,
      expectedAccountId: session.user!.id,
    );
    if (!_current(session, epoch)) return false;
    if (indexed != false) {
      setState(() => _sendStatus = '请等待当前会话与已存草稿核验后再发送。');
      return false;
    }
    return true;
  }

  Future<void> _post(SessionState session, int epoch, {int? asset}) async {
    if (!_current(session, epoch) || _offline) return;
    if (!await _canStartSubmission(session, epoch) ||
        !_current(session, epoch)) {
      return;
    }
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
    if (attempt.content.length > 5000) {
      setState(() => _sendStatus = '消息最多5000个字符，尚未发送。');
      return;
    }
    if (_attempt == null) {
      final saved = await _cache.saveAuthorized(
        _draftKey,
        {
          'text': attempt.content,
          'pending_attempt': {
            'client_message_id': attempt.clientMessageId,
            'peer_user_id': attempt.peerUserId,
            'content': attempt.content,
            'attachment_ids': attempt.attachmentIds.toList(),
          },
        },
        expectedAccountId: session.user!.id,
        isCurrent: () => _current(session, epoch) && !_offline,
      );
      if (!_current(session, epoch)) return;
      if (!saved) {
        if (!_cache.isUnlocked) {
          _reject('本机发送回执保存失败，消息尚未发送；请重新登录。');
          setState(() => _timeLocked = true);
        } else {
          setState(() => _sendStatus = '本机发送回执保存未完成，消息尚未发送，请重试。');
        }
        return;
      }
    }
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
    try {
      if (!await _cache.removeObject(_draftKey)) {
        throw StateError('Confirmed draft cleanup was superseded.');
      }
    } catch (_) {
      if (!_current(session, epoch)) return;
      _cache.lock();
      _reject('消息已确认，但本机草稿清理未完成；请重新登录后重试清理。');
      setState(() {
        _timeLocked = true;
        _sendStatus = '服务器已确认此消息';
      });
      return;
    }
    if (!_current(session, epoch)) return;
    _draftStatus = null;
    await _load();
    if (!_current(session, epoch)) return;
  }

  Future<void> _send({int? asset}) async {
    if (_busy ||
        _draftBusy ||
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

  void _removePendingMedia() {
    if (_draftBusy) return;
    setState(() {
      _pendingMedia = null;
      _pendingMediaKind = null;
      _readyMediaAsset = null;
      _uploadStatus = null;
    });
  }

  Future<void> _attachment(
    ChatAttachmentKind kind, {
    bool retry = false,
  }) async {
    if (_busy ||
        _draftBusy ||
        _attempt != null ||
        !mounted ||
        !_foreground ||
        _offline ||
        _sessionChanged ||
        _timeLocked) {
      return;
    }
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null || !session.isLoggedIn) {
      _reject('请先登录后再发送附件。');
      return;
    }
    _session = session;
    var epoch = _epoch;
    final peerEpoch = _peerEpoch;
    setState(() => _busy = true);
    try {
      if (!await _canStartSubmission(session, epoch) ||
          !_current(session, epoch)) {
        return;
      }
      final gateway = ref.read(liveChatMediaGatewayProvider);
      ChatPickedMedia? picked;
      if (retry) {
        picked = _pendingMediaKind == kind ? _pendingMedia : null;
      } else {
        _picking = true;
        picked = await gateway.pick(kind);
        if (peerEpoch == _peerEpoch) _picking = false;
      }
      if (!mounted ||
          peerEpoch != _peerEpoch ||
          !_foreground ||
          _sessionChanged ||
          _timeLocked ||
          !identical(ref.read(sessionProvider).asData?.value, session) ||
          picked == null) {
        return;
      }
      // A native picker crosses pause/resume. Obtain a fresh current read for
      // both an initial upload and an explicit retry of the selected file.
      epoch = _epoch;
      setState(() {
        _pendingMedia = picked;
        _pendingMediaKind = kind;
        if (!retry) _readyMediaAsset = null;
        _uploadStatus = '正在准备${kind.label}…';
      });
      final check = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/messages',
            query: {'peer_id': widget.peerId, 'limit': 1},
            cancelToken: _uploadCancellation,
            options: Options(
              extra: {requestSessionGuardKey: () => _current(session, epoch)},
            ),
          );
      if (!_current(session, epoch)) return;
      if (check is! NetworkSuccess<Map<String, dynamic>>) {
        if (check is NetworkFailure<Map<String, dynamic>> &&
            const {401, 403, 404}.contains(check.statusCode)) {
          _cache.revokeObject(_cacheKey);
          _reject('当前无法发送附件，请检查登录与双方消息同意。');
        } else {
          setState(() => _uploadStatus = '暂时无法发送附件，选择和输入已保留，请重试。');
        }
        return;
      }
      setState(() => _busy = true);
      var assetId = _readyMediaAsset;
      if (assetId == null) {
        if (gateway is! SessionBoundChatMediaGateway) {
          throw StateError('Attachment session binding unavailable');
        }
        setState(() => _uploadStatus = '正在上传${kind.label}，请稍候…');
        final uploaded = await gateway.uploadForSession(
          kind,
          picked,
          isCurrent: () => _current(session, epoch),
          cancelToken: _uploadCancellation,
        );
        if (!_current(session, epoch)) return;
        if (uploaded.assetId == null || uploaded.status != 'ready') {
          throw StateError('Attachment not ready');
        }
        assetId = uploaded.assetId!;
        _readyMediaAsset = assetId;
      }
      if (_offline) {
        setState(() => _uploadStatus = '附件已上传，联网后请重试发送。');
        return;
      }
      // Once POST owns the asset, retries belong to its immutable message
      // attempt, not to the upload. Never upload it twice for a lost POST reply.
      _removePendingMedia();
      await _post(session, epoch, asset: assetId);
    } catch (error) {
      if (!_current(session, epoch)) return;
      final status = error is ChatMediaGatewayException
          ? error.statusCode
          : error is DioException
          ? error.response?.statusCode
          : null;
      if (const {401, 403, 404}.contains(status)) {
        _cache.revokeObject(_cacheKey);
        _reject('当前无法发送附件，请检查登录与双方消息同意。');
      } else if (_attempt != null) {
        setState(() => _sendStatus = '发送结果尚未确认，请重试发送。');
      } else {
        setState(() => _uploadStatus = '附件上传或处理未完成，聊天和输入已保留，请重试或移除附件。');
      }
    } finally {
      if (peerEpoch == _peerEpoch) _picking = false;
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  Future<void> _call(String mode) async {
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null ||
        !session.isLoggedIn ||
        _busy ||
        _draftBusy ||
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
          _previewImageId = null;
          _loading = false;
          _loadingOlder = false;
          _hasOlder = false;
          _historyExpanded = false;
          _historyError = null;
          _pendingMedia = null;
          _pendingMediaKind = null;
          _readyMediaAsset = null;
          _uploadStatus = null;
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
    final preview = _images[_previewImageId];
    if (preview != null) {
      // Keep the preview in this page's authority/lifecycle. Clearing the
      // conversation also removes the full image, without a detached route.
      return PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) setState(() => _previewImageId = null);
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('图片预览'),
            leading: IconButton(
              tooltip: '返回对话',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _previewImageId = null),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => InteractiveViewer(
              maxScale: 5,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Image.memory(preview, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_error == null && !_offline)
              AuthenticatedAvatar(
                ownerId: widget.peerId,
                refreshKey: (_epoch, _avatarRefresh),
                size: 32,
              ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text('对话', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '刷新对话',
            onPressed: () {
              setState(() => _avatarRefresh++);
              unawaited(_load());
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _busy || _draftBusy ? null : () => _call('voice'),
            tooltip: '语音通话',
            icon: const Icon(Icons.call_outlined),
          ),
          IconButton(
            onPressed: _busy || _draftBusy ? null : () => _call('video'),
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
              onPressed: _busy || _draftBusy
                  ? null
                  : () => _send(asset: _retryAsset),
              child: const Text('使用原消息编号重试'),
            ),
          if (_uploadStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  Text(_uploadStatus!),
                  if (_pendingMedia != null &&
                      !_busy &&
                      !_draftBusy &&
                      !_offline &&
                      _attempt == null)
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () =>
                              _attachment(_pendingMediaKind!, retry: true),
                          child: Text(
                            _readyMediaAsset == null ? '重试上传' : '重试发送附件',
                          ),
                        ),
                        TextButton(
                          onPressed: _removePendingMedia,
                          child: const Text('移除附件'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          if (_historyError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_historyError!),
            ),
          Expanded(
            child: ListView(
              key: PageStorageKey<String>(
                'live-chat-history-${_session?.user?.id}-${widget.peerId}',
              ),
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ..._messages.reversed.map((m) {
                  final senderId = (m['sender_id'] as num?)?.toInt();
                  final sentByMe =
                      senderId != null && senderId == _session?.user?.id;
                  final colors = Theme.of(context).colorScheme;
                  final textColor = sentByMe
                      ? colors.onPrimaryContainer
                      : colors.onSurface;
                  return Align(
                    alignment: sentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.84,
                      ),
                      child: Card(
                        key: ValueKey('live-message-${m['id']}'),
                        color: sentByMe
                            ? colors.primaryContainer
                            : colors.surfaceContainerLow,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['content']?.toString() ?? '',
                                style: TextStyle(color: textColor),
                              ),
                              for (final a in (m['attachments'] as List? ?? []))
                                if (a['media_asset'] is Map)
                                  if (_images[(a['media_asset']['id'] as num)
                                          .toInt()]
                                      case final bytes?)
                                    InkWell(
                                      key: ValueKey(
                                        'live-chat-image-${a['media_asset']['id']}',
                                      ),
                                      onTap: () => setState(
                                        () => _previewImageId =
                                            (a['media_asset']['id'] as num)
                                                .toInt(),
                                      ),
                                      child: Image.memory(
                                        bytes,
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
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
                                sentByMe
                                    ? (m['is_read'] == true
                                          ? '我 · 已读'
                                          : '我 · 未读')
                                    : (senderId == widget.peerId ? '对方' : '消息'),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (!_offline && _hasOlder)
                  TextButton(
                    key: const ValueKey('load-earlier-messages'),
                    onPressed: _loadingOlder ? null : _loadOlder,
                    child: Text(_loadingOlder ? '正在加载较早消息…' : '加载更早消息'),
                  )
                else if (!_offline && _historyExpanded)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('已显示全部消息'),
                  ),
              ],
            ),
          ),
          if (_draftStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_draftStatus!),
            ),
          Wrap(
            children: [
              TextButton(
                onPressed:
                    !_draftLoaded ||
                        _draftBusy ||
                        _busy ||
                        _attempt != null ||
                        _offline ||
                        _timeLocked
                    ? null
                    : () => _saveDraft(),
                child: Text(_draftBusy ? '正在处理草稿…' : '保存草稿'),
              ),
              TextButton(
                onPressed:
                    !_draftLoaded ||
                        _draftBusy ||
                        _busy ||
                        _attempt != null ||
                        _offline ||
                        _timeLocked
                    ? null
                    : () => _saveDraft(clear: true),
                child: const Text('清除草稿'),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed:
                        _busy ||
                            _draftBusy ||
                            _attempt != null ||
                            _pendingMedia != null ||
                            _offline ||
                            _timeLocked
                        ? null
                        : _picture,
                    icon: const Icon(Icons.image),
                    tooltip: '发送图片',
                  ),
                  IconButton(
                    onPressed:
                        _busy ||
                            _draftBusy ||
                            _attempt != null ||
                            _pendingMedia != null ||
                            _offline ||
                            _timeLocked
                        ? null
                        : _video,
                    icon: const Icon(Icons.video_library_outlined),
                    tooltip: '发送短视频',
                  ),
                  Expanded(
                    child: TextField(
                      readOnly:
                          _busy ||
                          _draftBusy ||
                          _attempt != null ||
                          _offline ||
                          _timeLocked,
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: '输入消息',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _busy ||
                            _draftBusy ||
                            _attempt != null ||
                            _pendingMedia != null ||
                            _offline ||
                            _timeLocked
                        ? null
                        : () => _send(),
                    child: const Text('发送'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
