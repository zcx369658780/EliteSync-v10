class ConversationDto {
  const ConversationDto({
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

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      ConversationDto(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        lastMessage: (json['last_message'] ?? '').toString(),
        lastTime: (json['last_time'] ?? '').toString(),
        unread: (json['unread'] as num?)?.toInt() ?? 0,
        entryKind: _nullableString(json['entry_kind']),
        conversationId: _positiveInt(json['conversation_id']),
        peerUserId: json['peer_user_id'] == null
            ? _positiveInt(json['id'])
            : _positiveInt(json['peer_user_id']),
        matchId: _positiveInt(json['match_id']),
      );

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString();
    return parsed.isEmpty ? null : parsed;
  }

  static int? _nullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) {
      if (!value.isFinite || value != value.truncateToDouble()) return null;
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static int? _positiveInt(dynamic value) {
    final parsed = _nullableInt(value);
    return parsed != null && parsed > 0 ? parsed : null;
  }
}
