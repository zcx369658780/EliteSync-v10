import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/app/config/app_env.dart';
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
}) {
  if (wsBaseUrl.isNotEmpty) {
    final configured = Uri.parse(wsBaseUrl);
    if (!['ws', 'wss'].contains(configured.scheme) || configured.host.isEmpty) {
      throw StateError('Invalid websocket endpoint');
    }
    return configured.replace(
      path: '/api/v1/messages/ws/$selfId',
      queryParameters: peerId == null ? null : {'peer_id': '$peerId'},
    );
  }
  final apiUri = Uri.tryParse(apiBaseUrl.trim());
  final host = apiUri?.host.isNotEmpty == true ? apiUri!.host : '127.0.0.1';
  final scheme = (apiUri?.scheme ?? 'http').toLowerCase() == 'https'
      ? 'wss'
      : 'ws';
  final path = '/api/v1/messages/ws/$selfId';

  if (scheme == 'wss') {
    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: peerId == null ? null : {'peer_id': '$peerId'},
    );
  }

  return Uri(
    scheme: scheme,
    host: host,
    port: 8081,
    path: path,
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

class ChatSocketDataSource {
  ChatSocketDataSource({
    required this.apiClient,
    required this.localStorage,
    required this.env,
    this.accessToken,
    this.sessionIdentity,
  });

  final ApiClient apiClient;
  final LocalStorageService localStorage;
  final AppEnv env;
  final Future<String?> Function()? accessToken;
  final String Function()? sessionIdentity;

  Stream<MessageDto> observe(String conversationId) {
    if (env.useMockChat) {
      return const Stream.empty();
    }
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) {
      return const Stream.empty();
    }
    final controller = StreamController<MessageDto>.broadcast();
    var started = false;
    controller.onListen = () {
      if (started) return;
      started = true;
      unawaited(_runConnectionLoop(peerId: peerId, controller: controller));
    };
    return controller.stream;
  }

  Future<void> _runConnectionLoop({
    required int peerId,
    required StreamController<MessageDto> controller,
  }) async {
    final selfId = await _selfId();
    if (selfId <= 0) {
      if (!controller.isClosed) {
        await controller.close();
      }
      return;
    }

    var keepRunning = true;
    final identity = sessionIdentity?.call();
    WebSocket? activeSocket;
    controller.onCancel = () async {
      keepRunning = false;
      await activeSocket?.close();
    };

    while (keepRunning && !controller.isClosed) {
      WebSocket? socket;
      try {
        if (sessionIdentity?.call() != identity) break;
        final token = await accessToken?.call();
        if (token == null ||
            token.isEmpty ||
            sessionIdentity?.call() != identity) {
          break;
        }
        final uri = buildChatSocketUri(
          apiBaseUrl: env.apiBaseUrl,
          selfId: selfId,
          peerId: peerId,
          wsBaseUrl: env.wsBaseUrl,
        );
        socket = await WebSocket.connect(
          uri.toString(),
          headers: {'Authorization': 'Bearer $token'},
        );
        activeSocket = socket;
        if (!keepRunning || sessionIdentity?.call() != identity) {
          await socket.close();
          break;
        }
        socket.pingInterval = const Duration(seconds: 20);
        final completed = Completer<void>();
        socket.listen(
          (event) {
            final dto = decodeChatSocketEvent(
              event,
              selfId: selfId,
              peerId: peerId,
            );
            if (dto != null &&
                keepRunning &&
                sessionIdentity?.call() == identity &&
                !controller.isClosed) {
              controller.add(dto);
            }
          },
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
            if (!completed.isCompleted) completed.complete();
          },
          onDone: () {
            if (!completed.isCompleted) completed.complete();
          },
          cancelOnError: false,
        );
        await completed.future;
      } catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      } finally {
        try {
          await socket?.close();
        } catch (_) {}
      }

      if (keepRunning && !controller.isClosed) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    if (!controller.isClosed) {
      await controller.close();
    }
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
