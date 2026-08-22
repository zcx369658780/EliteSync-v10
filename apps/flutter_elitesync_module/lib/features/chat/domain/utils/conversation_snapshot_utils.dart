import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';

int? _positiveInt(Object? value) {
  final parsed = value is num
      ? (value.isFinite && value == value.truncateToDouble()
            ? value.toInt()
            : null)
      : int.tryParse(value?.toString() ?? '');
  return parsed != null && parsed > 0 ? parsed : null;
}

Map<String, Object?> encodeConversationSnapshotItem(ConversationEntity item) =>
    <String, Object?>{
      'id': item.id,
      'name': item.name,
      'lastMessage': item.lastMessage,
      'lastTime': item.lastTime,
      'unread': item.unread,
      'entryKind': item.entryKind,
      'conversationId': item.conversationId,
      'peerUserId': item.peerUserId,
      'matchId': item.matchId,
    };

ConversationEntity decodeConversationSnapshotItem(Map<String, dynamic> json) {
  final id = (json['id'] ?? '').toString();
  final peerUserId = _positiveInt(json['peerUserId']) ?? _positiveInt(id);
  final conversationId = _positiveInt(json['conversationId']);
  final matchId = _positiveInt(json['matchId']);
  final rawEntryKind = json['entryKind']?.toString();
  final entryKind = switch (rawEntryKind) {
    'stored_conversation' when conversationId != null && peerUserId != null =>
      'stored_conversation',
    'eligible_match'
        when conversationId == null && peerUserId != null && matchId != null =>
      'eligible_match',
    _ => 'legacy_peer',
  };
  return ConversationEntity(
    id: id,
    name: (json['name'] ?? '').toString(),
    lastMessage: (json['lastMessage'] ?? '').toString(),
    lastTime: (json['lastTime'] ?? '').toString(),
    unread: (json['unread'] as num?)?.toInt() ?? 0,
    entryKind: entryKind,
    conversationId: entryKind == 'stored_conversation' ? conversationId : null,
    peerUserId: peerUserId,
    matchId: entryKind == 'legacy_peer' ? null : matchId,
  );
}

bool isSupportedConversationId(String id, {required bool allowMockIds}) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return false;
  if (allowMockIds) return true;
  return int.tryParse(trimmed) != null;
}

List<ConversationEntity> sanitizeConversationSnapshot(
  List<ConversationEntity> items, {
  required bool allowMockIds,
}) {
  return items
      .where(
        (item) =>
            isSupportedConversationId(item.id, allowMockIds: allowMockIds),
      )
      .toList(growable: false);
}
