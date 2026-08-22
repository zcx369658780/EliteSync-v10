import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_failure.dart';

ChatRouteState resolveChatRouteAfterSend(
  ChatRouteState current,
  int returnedConversationId,
) {
  if (returnedConversationId <= 0) {
    throw const ChatSendFailure(
      message: 'Invalid conversation identity returned by send',
      serverCode: ChatSendFailure.conversationIdentityConflictCode,
    );
  }
  final storedConversationId = current.conversationId;
  if (storedConversationId == null) {
    return current.withConversationId(returnedConversationId);
  }
  if (storedConversationId == returnedConversationId) return current;
  throw const ChatSendFailure(
    message: 'Conversation identity changed during send',
    serverCode: ChatSendFailure.conversationIdentityConflictCode,
  );
}
