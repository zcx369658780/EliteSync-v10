import 'dart:async';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_request_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_response_dto.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_failure.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/chat_mock.dart';

class ChatRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 6);

  ChatRemoteDataSource({
    required this.apiClient,
    required this.localStorage,
    required this.useMock,
  });

  final ApiClient apiClient;
  final LocalStorageService localStorage;
  final bool useMock;
  int? _cachedSelfId;

  Future<int> _selfId() async {
    if (_cachedSelfId != null && _cachedSelfId! > 0) return _cachedSelfId!;
    try {
      final local = await localStorage.getJson(CacheKeys.lastKnownProfile);
      final localId = (local?['id'] as num?)?.toInt();
      if (localId != null && localId > 0) {
        _cachedSelfId = localId;
        return localId;
      }
      final profile = await apiClient
          .get('/api/v1/profile/basic')
          .timeout(_requestTimeout);
      if (profile is NetworkSuccess<Map<String, dynamic>>) {
        final id = (profile.data['id'] as num?)?.toInt() ?? 0;
        if (id > 0) {
          _cachedSelfId = id;
          return id;
        }
      }
    } catch (_) {}
    return 0;
  }

  Future<List<ConversationDto>> getConversations() async {
    if (useMock) {
      return ChatMock.conversationsHappy.map(ConversationDto.fromJson).toList();
    }
    final conversations = await apiClient
        .get('/api/v1/conversations')
        .timeout(_requestTimeout);
    if (conversations is NetworkSuccess<Map<String, dynamic>>) {
      final items = (conversations.data['items'] as List<dynamic>? ?? const []);
      return items
          .whereType<Map<String, dynamic>>()
          .map(ConversationDto.fromJson)
          .toList();
    }
    final failure = conversations as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<ConversationDto> getConversation(int conversationId) async {
    if (conversationId <= 0) {
      throw const FormatException('invalid conversation id');
    }
    if (useMock) {
      final items = ChatMock.conversationsHappy
          .map(ConversationDto.fromJson)
          .where((item) => item.conversationId == conversationId)
          .toList();
      if (items.isNotEmpty) return items.first;
      throw Exception('Conversation unavailable');
    }
    final result = await apiClient
        .get('/api/v1/conversations/$conversationId')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final raw = result.data['conversation'];
      if (raw is Map<String, dynamic>) {
        final parsed = ConversationDto.fromJson(raw);
        if (parsed.conversationId == conversationId &&
            parsed.peerUserId != null &&
            parsed.peerUserId! > 0) {
          return parsed;
        }
      }
      throw const FormatException('invalid conversation detail');
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<MessageDto>> getMessages(String conversationId) async {
    if (useMock) {
      return ChatMock.messagesHappy.map(MessageDto.fromJson).toList();
    }
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) {
      throw Exception('invalid conversation id');
    }
    final selfId = await _selfId();
    final result = await apiClient
        .get('/api/v1/messages', query: {'peer_id': peerId, 'limit': 100})
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = (result.data['items'] as List<dynamic>? ?? const []);
      return list.whereType<Map<String, dynamic>>().map((raw) {
        final senderId = (raw['sender_id'] as num?)?.toInt() ?? 0;
        return MessageDto.fromJson({
          ...raw,
          'mine': selfId > 0 && senderId == selfId,
          'text': (raw['content'] ?? '').toString(),
          'time': (raw['created_at'] ?? '').toString(),
        });
      }).toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<SendMessageResponseDto> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) async {
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) {
      throw Exception('invalid conversation id');
    }
    if (useMock) {
      return SendMessageResponseDto.fromJson({
        'id': 1,
        'conversation_id': peerId + 1000000000,
        'client_message_id': clientMessageId,
        'idempotent_replay': false,
        'message': {
          'id': 1,
          'mine': true,
          'content': text,
          'time': '',
          'client_message_id': clientMessageId,
          'attachments': const <dynamic>[],
        },
      });
    }
    final result = await apiClient
        .post(
          '/api/v1/messages',
          body: SendMessageRequestDto(
            receiverId: peerId,
            content: text,
            attachmentIds: attachmentIds,
            clientMessageId: clientMessageId,
          ).toJson(),
        )
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw ChatSendFailure(
        message: result.message,
        statusCode: result.statusCode,
        serverCode: result.code,
      );
    }
    final success = result as NetworkSuccess<Map<String, dynamic>>;
    final message = success.data['message'];
    if (message is! Map<String, dynamic>) {
      return SendMessageResponseDto.fromJson(success.data);
    }
    return SendMessageResponseDto.fromJson({
      ...success.data,
      'message': {
        ...message,
        'mine': true,
        'time': (message['time'] ?? message['created_at'] ?? '').toString(),
        if (message['client_message_id'] == null)
          'client_message_id': success.data['client_message_id'],
      },
    });
  }
}
