import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_response_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/mapper/chat_mapper.dart';
import 'package:flutter_elitesync_module/features/chat/data/repository/chat_repository_impl.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/get_conversation_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final response = SendMessageResponseDto.fromJson({
    'id': 88,
    'conversation_id': 44,
    'client_message_id': 'client-88',
    'idempotent_replay': true,
    'message': {
      'id': 88,
      'mine': true,
      'content': 'hello',
      'time': '2026-08-03T10:00:00Z',
      'client_message_id': 'client-88',
      'attachments': const <dynamic>[],
    },
  });

  test(
    'repository maps every response identity and shaped message field',
    () async {
      final dependencies = _Dependencies();
      final repository = ChatRepositoryImpl(
        remote: _StubRemote(dependencies, response),
        socket: dependencies.socket,
        mapper: const ChatMapper(),
      );

      final result = await repository.sendMessage(
        '23',
        'hello',
        clientMessageId: 'client-88',
      );

      expect(result.serverMessageId, 88);
      expect(result.conversationId, 44);
      expect(result.clientMessageId, 'client-88');
      expect(result.idempotentReplay, isTrue);
      expect(result.message.id, '88');
      expect(result.message.text, 'hello');
      expect(result.message.clientMessageId, 'client-88');
    },
  );

  test('repository and use case map stored conversation detail', () async {
    final dependencies = _Dependencies();
    final repository = ChatRepositoryImpl(
      remote: _StubRemote(dependencies, response),
      socket: dependencies.socket,
      mapper: const ChatMapper(),
    );

    final conversation = await GetConversationUseCase(repository)(44);

    expect(conversation.conversationId, 44);
    expect(conversation.peerUserId, 23);
    expect(conversation.name, 'Stored Peer');
  });

  test(
    'use case returns repository result unchanged and may be ignored',
    () async {
      final result = SendMessageResult(
        serverMessageId: 88,
        conversationId: 44,
        clientMessageId: 'client-88',
        idempotentReplay: false,
        message: const MessageEntity(
          id: '88',
          mine: true,
          text: 'hello',
          time: '',
          attachments: [],
          clientMessageId: 'client-88',
        ),
      );
      final useCase = SendMessageUseCase(_ResultRepository(result));

      final returned = await useCase('23', 'hello');
      expect(identical(returned, result), isTrue);

      await useCase('23', 'ignored');
    },
  );
}

class _Dependencies {
  _Dependencies()
    : apiClient = ApiClient(dio: Dio()),
      localStorage = LocalStorageService() {
    socket = ChatSocketDataSource(
      apiClient: apiClient,
      localStorage: localStorage,
      env: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'test',
        apiBaseUrl: 'https://example.test',
        useMockData: true,
        useMockChat: true,
      ),
    );
  }

  final ApiClient apiClient;
  final LocalStorageService localStorage;
  late final ChatSocketDataSource socket;
}

class _StubRemote extends ChatRemoteDataSource {
  _StubRemote(_Dependencies dependencies, this.response)
    : super(
        apiClient: dependencies.apiClient,
        localStorage: dependencies.localStorage,
        useMock: false,
      );

  final SendMessageResponseDto response;

  @override
  Future<ConversationDto> getConversation(int conversationId) async =>
      ConversationDto(
        id: '23',
        name: 'Stored Peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        entryKind: 'stored_conversation',
        conversationId: conversationId,
        peerUserId: 23,
      );

  @override
  Future<SendMessageResponseDto> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) async => response;
}

class _ResultRepository implements ChatRepository {
  const _ResultRepository(this.result);

  final SendMessageResult result;

  @override
  Future<List<ConversationEntity>> getConversations() async => const [];

  @override
  Future<ConversationEntity> getConversation(int conversationId) async =>
      ConversationEntity(
        id: '23',
        name: 'Stored Peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        conversationId: conversationId,
        peerUserId: 23,
      );

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async =>
      const [];

  @override
  Stream<MessageEntity> observeMessages(String conversationId) =>
      const Stream.empty();

  @override
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) async => result;
}
