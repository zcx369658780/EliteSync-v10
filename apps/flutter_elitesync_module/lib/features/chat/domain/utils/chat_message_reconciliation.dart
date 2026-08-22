import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';

bool sameChatMessageIdentity(MessageEntity first, MessageEntity second) {
  final firstClientId = first.clientMessageId?.trim() ?? '';
  final secondClientId = second.clientMessageId?.trim() ?? '';
  if (firstClientId.isNotEmpty && secondClientId.isNotEmpty) {
    return firstClientId == secondClientId;
  }
  return first.id.isNotEmpty && first.id == second.id;
}

List<MessageEntity> reconcileChatMessages({
  required Iterable<MessageEntity> remote,
  required Iterable<MessageEntity> local,
}) {
  final reconciled = <MessageEntity>[];
  for (final message in [...remote, ...local]) {
    final existing = reconciled.indexWhere(
      (candidate) => sameChatMessageIdentity(candidate, message),
    );
    if (existing < 0) {
      reconciled.add(message);
    }
  }
  return List<MessageEntity>.unmodifiable(reconciled);
}
