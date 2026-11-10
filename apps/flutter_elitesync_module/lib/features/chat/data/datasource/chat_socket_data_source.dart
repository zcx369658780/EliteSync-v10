import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/chat_socket_endpoint.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';

Uri buildChatSocketUri({
  required String apiBaseUrl,
  required int selfId,
  int? peerId,
  String wsBaseUrl = '',
  bool allowLocalInsecure = true,
}) {
  if (selfId <= 0 || (peerId != null && peerId <= 0)) {
    throw StateError('Invalid websocket actor');
  }
  final endpoint = resolveChatSocketBaseUrl(
    apiBaseUrl: apiBaseUrl,
    override: wsBaseUrl,
    allowLocalInsecure: allowLocalInsecure,
  );
  if (endpoint.isEmpty) throw StateError('No trusted websocket endpoint');
  return Uri.parse(endpoint).replace(
    path: '/api/v1/messages/ws/$selfId',
    queryParameters: peerId == null ? null : {'peer_id': '$peerId'},
  );
}

MessageDto? decodeChatSocketEvent(
  dynamic event, {
  required int selfId,
  required int peerId,
}) {
  final payload = switch (event) {
    final String value => value,
    final List<int> bytes => utf8.decode(bytes),
    _ => event.toString(),
  };
  if (payload.trim().isEmpty) return null;

  Map<String, dynamic>? json;
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      json = decoded;
    }
  } catch (_) {
    return null;
  }
  if (json == null) return null;

  final type = (json['type'] ?? '').toString();
  if (type == 'conversation_changed') {
    // Scoped authenticated socket is only an invalidation signal. Fetch text
    // and media from the current-authorized HTTP reader, never from this frame.
    return MessageDto(
      id: (json['id'] ?? '').toString(),
      mine: false,
      text: '',
      time: '',
      attachments: const [],
    );
  }
  if (type != 'message') return null;

  final senderId = (json['sender_id'] as num?)?.toInt() ?? 0;
  final receiverId = (json['receiver_id'] as num?)?.toInt() ?? 0;
  final isConversationPair =
      (senderId == peerId && receiverId == selfId) ||
      (senderId == selfId && receiverId == peerId);
  if (!isConversationPair) return null;

  return MessageDto(
    id: (json['id'] ?? '').toString(),
    mine: senderId == selfId,
    text: (json['content'] ?? '').toString(),
    time: (json['created_at'] ?? '').toString(),
    attachments: const [],
  );
}

typedef ChatSocketConnector =
    Future<WebSocket> Function(
      Uri uri,
      Map<String, dynamic> headers,
      HttpClient client,
    );

class ChatSocketDataSource {
  ChatSocketDataSource({
    required this.apiClient,
    required this.localStorage,
    required this.env,
    this.accessToken,
    this.sessionIdentity,
    this.sessionChanges,
    ChatSocketConnector? connector,
    this.reconnectDelay = const Duration(seconds: 2),
    this.connectTimeout = const Duration(seconds: 10),
    this.maxReconnectAttempts = 5,
  }) : connector = connector ?? _connect;

  final ApiClient apiClient;
  final LocalStorageService localStorage;
  final AppEnv env;
  final Future<String?> Function()? accessToken;
  final String Function()? sessionIdentity;
  final Stream<void>? sessionChanges;
  final ChatSocketConnector connector;
  final Duration reconnectDelay;
  final Duration connectTimeout;
  final int maxReconnectAttempts;
  final _observations = <_ChatSocketObservation>{};
  bool _disposed = false;

  static Future<WebSocket> _connect(
    Uri uri,
    Map<String, dynamic> headers,
    HttpClient client,
  ) =>
      WebSocket.connect(uri.toString(), headers: headers, customClient: client);

  void dispose() {
    _disposed = true;
    for (final item in _observations.toList()) {
      item.stop();
    }
  }

  Stream<MessageDto> observe(String conversationId) {
    if (_disposed || env.useMockChat) return const Stream.empty();
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) return const Stream.empty();
    late final _ChatSocketObservation observation;
    observation = _ChatSocketObservation(
      this,
      peerId,
      _selfId,
      () => _observations.remove(observation),
    );
    _observations.add(observation);
    return observation.stream;
  }

  Future<int> _selfId() async {
    try {
      final local = await localStorage.getJson(CacheKeys.lastKnownProfile);
      final localId = (local?['id'] as num?)?.toInt();
      if (localId != null && localId > 0) {
        return localId;
      }
    } catch (_) {}

    try {
      final profile = await apiClient.get('/api/v1/profile/basic');
      if (profile is NetworkSuccess<Map<String, dynamic>>) {
        return (profile.data['id'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}

    return 0;
  }
}

class _ChatSocketObservation {
  _ChatSocketObservation(this.source, this.peerId, this.selfId, this.onStop) {
    // Install cancellation before the first async profile/token/connect step.
    _controller.onListen = () {
      unawaited(_run());
    };
    _controller.onCancel = stop;
  }
  final ChatSocketDataSource source;
  final int peerId;
  final Future<int> Function() selfId;
  final void Function() onStop;
  final _controller = StreamController<MessageDto>();
  final _stopped = Completer<void>();
  Stream<MessageDto> get stream => _controller.stream;
  String? _identity;
  bool _closed = false;
  Timer? _identityMonitor;
  Timer? _retryTimer;
  int _connectionGeneration = 0;
  StreamSubscription<void>? _identitySubscription;
  StreamSubscription<dynamic>? _frames;
  WebSocket? _socket;
  HttpClient? _client;

  bool get current {
    if (_closed) return false;
    try {
      return source.sessionIdentity?.call() == _identity;
    } catch (_) {
      return false;
    }
  }

  void stop() {
    if (_closed) return;
    _closed = true;
    _connectionGeneration++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _identityMonitor?.cancel();
    _identityMonitor = null;
    _client?.close(force: true); // Abort a connecting HTTP upgrade as well.
    _client = null;
    if (!_stopped.isCompleted) _stopped.complete();
    final identitySubscription = _identitySubscription;
    _identitySubscription = null;
    if (identitySubscription != null) unawaited(_cancel(identitySubscription));
    final frames = _frames;
    _frames = null;
    if (frames != null) unawaited(_cancel(frames));
    final socket = _socket;
    _socket = null;
    if (socket != null) unawaited(_close(socket));
    onStop();
    if (!_controller.isClosed) unawaited(_controller.close());
  }

  Future<void> _cancel(StreamSubscription<dynamic> subscription) async {
    try {
      await subscription.cancel().timeout(const Duration(seconds: 1));
    } catch (_) {
      /* Invalidation still force-closes the owned socket/client. */
    }
  }

  Future<void> _close(WebSocket socket) async {
    try {
      await socket.close().timeout(const Duration(seconds: 1));
    } catch (_) {
      /* The owned HTTP client is also force-closed on invalidation. */
    }
  }

  Future<T?> _untilStopped<T>(Future<T> pending) => Future.any<T?>([
    pending.then<T?>((value) => value),
    _stopped.future.then<T?>((_) => null),
  ]);

  void _error(Object error, StackTrace stack) {
    if (current && !_controller.isClosed) _controller.addError(error, stack);
  }

  Future<void> _run() async {
    if (_closed) return;
    try {
      _identity = source.sessionIdentity?.call();
      _identitySubscription = source.sessionChanges?.listen(
        (_) {
          if (!current) stop();
        },
        onError: (Object _, StackTrace _) => stop(),
        onDone: stop,
      );
      // Also cover callback-only consumers; no frame is needed to notice logout.
      _identityMonitor = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!current) stop();
      });
      final actor = await _untilStopped(selfId());
      if (!current || actor == null || actor <= 0) return;
      // Invalid endpoint configuration is terminal, not a retry destination.
      final uri = buildChatSocketUri(
        apiBaseUrl: source.env.apiBaseUrl,
        wsBaseUrl: source.env.wsBaseUrl,
        selfId: actor,
        peerId: peerId,
        allowLocalInsecure: source.env.isDev,
      );
      for (
        var attempt = 0;
        current && attempt <= source.maxReconnectAttempts;
        attempt++
      ) {
        final generation = ++_connectionGeneration;
        try {
          final token = await _untilStopped(
            source.accessToken?.call() ?? Future<String?>.value(),
          );
          if (!current || token == null || token.isEmpty) return;
          final client = HttpClient()
            ..connectionTimeout = source.connectTimeout;
          _client = client;
          final connection = source
              .connector(uri, {'Authorization': 'Bearer $token'}, client)
              .then<WebSocket?>((s) {
                if (!current || generation != _connectionGeneration) {
                  unawaited(_close(s));
                  return null;
                }
                return s;
              });
          final socket = await _untilStopped(
            connection.timeout(source.connectTimeout),
          );
          if (!current || socket == null) return;
          _socket = socket;
          socket.pingInterval = const Duration(seconds: 20);
          final ended = Completer<void>();
          void end() {
            if (!ended.isCompleted) ended.complete();
          }

          _frames = socket.listen(
            (event) {
              if (!current || generation != _connectionGeneration) {
                return;
              }
              try {
                final dto = decodeChatSocketEvent(
                  event,
                  selfId: actor,
                  peerId: peerId,
                );
                if (dto != null && current) _controller.add(dto);
              } catch (error, stack) {
                _error(error, stack);
                end();
              }
            },
            onError: (Object error, StackTrace stack) {
              _error(error, stack);
              end();
            },
            onDone: end,
            cancelOnError: false,
          );
          await _untilStopped(ended.future);
        } catch (error, stack) {
          _error(error, stack);
        } finally {
          if (_connectionGeneration == generation) _connectionGeneration++;
          final frames = _frames;
          _frames = null;
          if (frames != null) await _cancel(frames);
          final socket = _socket;
          _socket = null;
          if (socket != null) await _close(socket);
          _client?.close(force: true);
          _client = null;
        }
        if (current && attempt < source.maxReconnectAttempts) {
          final ready = Completer<void>();
          _retryTimer = Timer(source.reconnectDelay, ready.complete);
          await _untilStopped(ready.future);
          _retryTimer?.cancel();
          _retryTimer = null;
        }
      }
    } catch (error, stack) {
      _error(error, stack);
    } finally {
      stop();
    }
  }
}
