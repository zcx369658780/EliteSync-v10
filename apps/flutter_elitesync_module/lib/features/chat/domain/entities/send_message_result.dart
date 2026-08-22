import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';

class SendMessageResult {
  const SendMessageResult({
    required this.serverMessageId,
    required this.conversationId,
    required this.clientMessageId,
    required this.idempotentReplay,
    required this.message,
  });

  final int serverMessageId;
  final int conversationId;
  final String? clientMessageId;
  final bool idempotentReplay;
  final MessageEntity message;
}
