import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this.repository);
  final ChatRepository repository;
  Future<SendMessageResult> call(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) => repository.sendMessage(
    conversationId,
    text,
    attachmentIds: attachmentIds,
    clientMessageId: clientMessageId,
  );
}
