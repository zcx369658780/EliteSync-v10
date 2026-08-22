import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> successBody({String? clientMessageId}) => {
    'id': 81,
    'conversation_id': 42,
    'client_message_id': clientMessageId,
    'idempotent_replay': false,
    'message': {
      'id': 81,
      'content': 'hello',
      'created_at': '2026-08-03T10:00:00Z',
      'attachments': const <dynamic>[],
    },
  };

  test(
    'authoritative conversation response preserves truthful empty eligibility',
    () async {
      final api = _ConversationFallbackApiClient();
      final remote = ChatRemoteDataSource(
        apiClient: api,
        localStorage: LocalStorageService(),
        useMock: false,
      );

      final conversations = await remote.getConversations();

      expect(api.paths, ['/api/v1/conversations']);
      expect(conversations, isEmpty);
    },
  );

  test(
    'posts peer, client key, and ordered attachments then returns identities',
    () async {
      final api = _FakeApiClient(
        NetworkSuccess(successBody(clientMessageId: 'client-81')),
      );
      final remote = ChatRemoteDataSource(
        apiClient: api,
        localStorage: LocalStorageService(),
        useMock: false,
      );

      final result = await remote.sendMessage(
        '23',
        'hello',
        attachmentIds: const [9, 4, 9],
        clientMessageId: 'client-81',
      );

      expect(api.path, '/api/v1/messages');
      expect(api.body, {
        'receiver_id': 23,
        'content': 'hello',
        'attachment_ids': [9, 4, 9],
        'client_message_id': 'client-81',
      });
      expect(result.serverMessageId, 81);
      expect(result.conversationId, 42);
      expect(result.clientMessageId, 'client-81');
      expect(result.message.clientMessageId, 'client-81');
      expect(result.message.mine, isTrue);
      expect(result.message.time, '2026-08-03T10:00:00Z');
    },
  );

  test('legacy null-key call remains supported', () async {
    final api = _FakeApiClient(NetworkSuccess(successBody()));
    final remote = ChatRemoteDataSource(
      apiClient: api,
      localStorage: LocalStorageService(),
      useMock: false,
    );

    final result = await remote.sendMessage('23', 'legacy');

    expect(api.body, isNot(contains('client_message_id')));
    expect(result.clientMessageId, isNull);
  });

  test('mock mode returns a deterministic well-formed typed result', () async {
    final remote = ChatRemoteDataSource(
      apiClient: _FakeApiClient(const NetworkFailure(message: 'unused')),
      localStorage: LocalStorageService(),
      useMock: true,
    );

    final first = await remote.sendMessage(
      '23',
      'mock hello',
      clientMessageId: 'mock-client',
    );
    final second = await remote.sendMessage(
      '23',
      'mock hello',
      clientMessageId: 'mock-client',
    );

    expect(first.serverMessageId, 1);
    expect(first.conversationId, isNot(23));
    expect(first.message.id, first.serverMessageId.toString());
    expect(first.clientMessageId, 'mock-client');
    expect(first.message.text, 'mock hello');
    expect(second.serverMessageId, first.serverMessageId);
    expect(second.conversationId, first.conversationId);
  });

  test('network failure still throws', () async {
    final remote = ChatRemoteDataSource(
      apiClient: _FakeApiClient(const NetworkFailure(message: 'send failed')),
      localStorage: LocalStorageService(),
      useMock: false,
    );

    expect(() => remote.sendMessage('23', 'hello'), throwsA(isA<Exception>()));
  });

  test('send failure preserves status and server code', () async {
    final remote = ChatRemoteDataSource(
      apiClient: _FakeApiClient(
        const NetworkFailure(
          message: 'payload conflict',
          statusCode: 409,
          code: 'client_message_id_payload_mismatch',
        ),
      ),
      localStorage: LocalStorageService(),
      useMock: false,
    );

    await expectLater(
      remote.sendMessage('23', 'hello', clientMessageId: 'client-23'),
      throwsA(
        isA<ChatSendFailure>()
            .having((failure) => failure.statusCode, 'statusCode', 409)
            .having(
              (failure) => failure.serverCode,
              'serverCode',
              'client_message_id_payload_mismatch',
            )
            .having(
              (failure) => failure.isPayloadMismatch,
              'isPayloadMismatch',
              isTrue,
            ),
      ),
    );
  });

  test('gets and validates stored conversation detail', () async {
    final api = _ConversationDetailApiClient(
      const NetworkSuccess({
        'conversation': {
          'id': 23,
          'conversation_id': 42,
          'peer_user_id': 23,
          'name': 'Stored Peer',
        },
      }),
    );
    final remote = ChatRemoteDataSource(
      apiClient: api,
      localStorage: LocalStorageService(),
      useMock: false,
    );

    final conversation = await remote.getConversation(42);

    expect(api.path, '/api/v1/conversations/42');
    expect(conversation.conversationId, 42);
    expect(conversation.peerUserId, 23);
  });

  test(
    'conversation detail failure and malformed identity fail closed',
    () async {
      final failed = ChatRemoteDataSource(
        apiClient: _ConversationDetailApiClient(
          const NetworkFailure(message: 'detail unavailable', statusCode: 503),
        ),
        localStorage: LocalStorageService(),
        useMock: false,
      );
      final malformed = ChatRemoteDataSource(
        apiClient: _ConversationDetailApiClient(
          const NetworkSuccess({
            'conversation': {'conversation_id': 42, 'peer_user_id': 0},
          }),
        ),
        localStorage: LocalStorageService(),
        useMock: false,
      );

      await expectLater(failed.getConversation(42), throwsException);
      await expectLater(malformed.getConversation(42), throwsFormatException);
      await expectLater(malformed.getConversation(0), throwsFormatException);
    },
  );
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.result) : super(dio: Dio());

  final NetworkResult<Map<String, dynamic>> result;
  String? path;
  Object? body;

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    this.path = path;
    this.body = body;
    return result;
  }
}

class _ConversationFallbackApiClient extends ApiClient {
  _ConversationFallbackApiClient() : super(dio: Dio());

  final List<String> paths = [];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    paths.add(path);
    if (path == '/api/v1/conversations') {
      return const NetworkSuccess({'items': <dynamic>[]});
    }
    return const NetworkFailure(message: 'unexpected path');
  }
}

class _ConversationDetailApiClient extends ApiClient {
  _ConversationDetailApiClient(this.result) : super(dio: Dio());

  final NetworkResult<Map<String, dynamic>> result;
  String? path;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    this.path = path;
    return result;
  }
}
