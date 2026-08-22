import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';

class GetConversationUseCase {
  const GetConversationUseCase(this.repository);

  final ChatRepository repository;

  Future<ConversationEntity> call(int conversationId) =>
      repository.getConversation(conversationId);
}
