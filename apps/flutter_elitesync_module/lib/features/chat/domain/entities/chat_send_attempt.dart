import 'dart:collection';

import 'package:uuid/uuid.dart';

class ChatSendAttempt {
  ChatSendAttempt({
    required String clientMessageId,
    required this.peerUserId,
    required String content,
    List<int> attachmentIds = const [],
  }) : clientMessageId = _validatedClientMessageId(clientMessageId),
       content = _validatedContent(content),
       attachmentIds = UnmodifiableListView<int>(List<int>.of(attachmentIds)) {
    if (peerUserId <= 0) {
      throw ArgumentError.value(peerUserId, 'peerUserId', 'must be positive');
    }
  }

  factory ChatSendAttempt.create({
    required int peerUserId,
    required String content,
    List<int> attachmentIds = const [],
  }) => ChatSendAttempt(
    clientMessageId: const Uuid().v4().toLowerCase(),
    peerUserId: peerUserId,
    content: content,
    attachmentIds: attachmentIds,
  );

  final String clientMessageId;
  final int peerUserId;
  final String content;
  final List<int> attachmentIds;

  String get localMessageId => 'local-$clientMessageId';

  bool hasSamePayload({
    required int peerUserId,
    required String content,
    required List<int> attachmentIds,
  }) {
    if (this.peerUserId != peerUserId || this.content != content.trim()) {
      return false;
    }
    if (this.attachmentIds.length != attachmentIds.length) return false;
    for (var index = 0; index < attachmentIds.length; index++) {
      if (this.attachmentIds[index] != attachmentIds[index]) return false;
    }
    return true;
  }

  static String _validatedClientMessageId(String value) {
    final normalized = value.toLowerCase();
    final uuidV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    if (value != normalized || !uuidV4.hasMatch(normalized)) {
      throw ArgumentError.value(
        value,
        'clientMessageId',
        'must be a canonical lowercase UUID-v4',
      );
    }
    return normalized;
  }

  static String _validatedContent(String value) {
    final trimmed = value.trim();
    if (value != trimmed) {
      throw ArgumentError.value(value, 'content', 'must already be trimmed');
    }
    return trimmed;
  }
}
