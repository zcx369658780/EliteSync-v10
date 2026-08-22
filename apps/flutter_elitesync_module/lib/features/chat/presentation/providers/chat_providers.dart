import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/mapper/chat_mapper.dart';
import 'package:flutter_elitesync_module/features/chat/data/repository/chat_repository_impl.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/observe_messages_usecase.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/get_conversation_usecase.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_elitesync_module/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_list_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ChatRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    localStorage: ref.watch(localStorageProvider),
    useMock: env.useMockChat,
  );
});

final chatSocketDataSourceProvider = Provider<ChatSocketDataSource>(
  (ref) => ChatSocketDataSource(
    apiClient: ref.watch(apiClientProvider),
    localStorage: ref.watch(localStorageProvider),
    env: ref.watch(appEnvProvider),
  ),
);

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remote: ref.watch(chatRemoteDataSourceProvider),
    socket: ref.watch(chatSocketDataSourceProvider),
    mapper: const ChatMapper(),
  );
});

final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>(
  (ref) => GetConversationsUseCase(ref.watch(chatRepositoryProvider)),
);
final getConversationUseCaseProvider = Provider<GetConversationUseCase>(
  (ref) => GetConversationUseCase(ref.watch(chatRepositoryProvider)),
);
final conversationDetailProvider =
    FutureProvider.family<ConversationEntity, int>((ref, conversationId) {
      return ref.read(getConversationUseCaseProvider).call(conversationId);
    });
final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>(
  (ref) => GetMessagesUseCase(ref.watch(chatRepositoryProvider)),
);
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>(
  (ref) => SendMessageUseCase(ref.watch(chatRepositoryProvider)),
);
final observeMessagesUseCaseProvider = Provider<ObserveMessagesUseCase>(
  (ref) => ObserveMessagesUseCase(ref.watch(chatRepositoryProvider)),
);
final conversationListProvider = FutureProvider<ConversationListUiState>((
  ref,
) async {
  try {
    final items = await ref.read(getConversationsUseCaseProvider).call();
    return ConversationListUiState(items: items);
  } catch (e) {
    return ConversationListUiState(error: e.toString());
  }
});

class ChatMessagesRequest {
  const ChatMessagesRequest({
    required this.stableKey,
    required this.peerUserId,
  });

  factory ChatMessagesRequest.fromRoute(ChatRouteState routeState) =>
      ChatMessagesRequest(
        stableKey: routeState.stableKey,
        peerUserId: routeState.peerUserId,
      );

  final String stableKey;
  final int peerUserId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessagesRequest && stableKey == other.stableKey;

  @override
  int get hashCode => stableKey.hashCode;
}

final chatRoomMessagesProvider =
    FutureProvider.family<List<MessageEntity>, ChatMessagesRequest>((
      ref,
      request,
    ) async {
      return ref
          .read(getMessagesUseCaseProvider)
          .call(request.peerUserId.toString());
    });

final chatConnectionProvider = Provider<String>((ref) => 'connected');
