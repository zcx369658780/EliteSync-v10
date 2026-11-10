import 'dart:async';
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
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

String _chatIdentity(Ref ref) {
  final session = ref.read(sessionProvider).asData?.value;
  return '${session?.status.name}:${session?.user?.id}:${session?.accessToken}:'
      '${ref.read(relationshipAuthorityEpochProvider)}';
}

bool Function() _chatCurrent(Ref ref) {
  ref.watch(sessionProvider);
  ref.watch(relationshipAuthorityEpochProvider);
  final identity = _chatIdentity(ref);
  var alive = true;
  ref.onDispose(() => alive = false);
  return () => alive && _chatIdentity(ref) == identity;
}

Never _conversationAccessUnavailable() =>
    throw StateError('Product Conversation access is NOT YET ESTABLISHED');

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  ref.watch(sessionProvider);
  final env = ref.watch(appEnvProvider);
  return ChatRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    localStorage: ref.watch(localStorageProvider),
    useMock: env.useMockChat,
  );
});

final chatSocketDataSourceProvider = Provider<ChatSocketDataSource>((ref) {
  final changes = StreamController<void>.broadcast(sync: true);
  ref.listen(sessionProvider, (_, _) {
    changes.add(null);
  });
  ref.listen(relationshipAuthorityEpochProvider, (_, _) {
    changes.add(null);
  });
  final source = ChatSocketDataSource(
    apiClient: ref.watch(apiClientProvider),
    localStorage: ref.watch(localStorageProvider),
    env: ref.watch(appEnvProvider),
    accessToken: ref.watch(accessTokenProvider),
    sessionIdentity: () => _chatIdentity(ref),
    sessionChanges: changes.stream,
  );
  ref.onDispose(() {
    source.dispose();
    unawaited(changes.close());
  });
  return source;
});

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
    FutureProvider.family<ConversationEntity, int>((ref, conversationId) async {
      final current = _chatCurrent(ref);
      if (!ref.watch(conversationAccessProvider).canRevealPrivateContent) {
        return _conversationAccessUnavailable();
      }
      final item = await ref
          .read(getConversationUseCaseProvider)
          .call(conversationId);
      if (!current()) return _conversationAccessUnavailable();
      return item;
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
  final current = _chatCurrent(ref);
  if (!ref.watch(conversationAccessProvider).canRevealPrivateContent) {
    return _conversationAccessUnavailable();
  }
  try {
    final items = await ref.read(getConversationsUseCaseProvider).call();
    if (!current()) return _conversationAccessUnavailable();
    return ConversationListUiState(items: items);
  } catch (e) {
    if (!current()) return _conversationAccessUnavailable();
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
      final current = _chatCurrent(ref);
      if (!ref.watch(conversationAccessProvider).canRevealPrivateContent) {
        return _conversationAccessUnavailable();
      }
      final items = await ref
          .read(getMessagesUseCaseProvider)
          .call(request.peerUserId.toString());
      if (!current()) return _conversationAccessUnavailable();
      return items;
    });

final chatConnectionProvider = Provider<String>((ref) => 'connected');
