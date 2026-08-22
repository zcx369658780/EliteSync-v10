import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';

const _engineeringMessageTexts = {
  'codex test message after fix',
  '333',
  '444',
  '222',
  '新消息测试',
  '234',
  '556',
};

bool isEngineeringChatText(String value) {
  return _engineeringMessageTexts.contains(value.trim().toLowerCase());
}

String displayChatPreviewText(String value) {
  return isEngineeringChatText(value) ? '示例消息' : value;
}

bool isVisibleChatMessage(MessageEntity message) {
  final text = message.text.trim().toLowerCase();
  if (text.isEmpty) return message.hasAttachments;
  return !_engineeringMessageTexts.contains(text);
}

List<MessageEntity> sanitizeVisibleChatMessages(List<MessageEntity> messages) {
  return messages.where(isVisibleChatMessage).toList(growable: false);
}
