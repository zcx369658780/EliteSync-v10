import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';

abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<ConversationEntity> getConversation(int conversationId);
  Future<List<MessageEntity>> getMessages(String conversationId);
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds,
    String? clientMessageId,
  });
  Stream<MessageEntity> observeMessages(String conversationId);
}
