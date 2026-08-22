class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastTime,
    required this.unread,
    this.entryKind,
    this.conversationId,
    this.peerUserId,
    this.matchId,
  });
  final String id;
  final String name;
  final String lastMessage;
  final String lastTime;
  final int unread;
  final String? entryKind;
  final int? conversationId;
  final int? peerUserId;
  final int? matchId;
}
