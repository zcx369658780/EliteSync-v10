import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';

enum ChatEntryKind { storedConversation, eligibleMatch, legacyPeer }

int chatPeerUserIdForOperations(ChatRouteState routeState) =>
    routeState.peerUserId;

class ChatRouteState {
  ChatRouteState._({
    required this.entryKind,
    required this.conversationId,
    required this.peerUserId,
    required this.matchId,
    required String title,
  }) : title = _sanitizeTitle(title) {
    if (peerUserId <= 0) {
      throw ArgumentError.value(peerUserId, 'peerUserId', 'must be positive');
    }
    if (conversationId != null && conversationId! <= 0) {
      throw ArgumentError.value(
        conversationId,
        'conversationId',
        'must be positive when present',
      );
    }
    if (matchId != null && matchId! <= 0) {
      throw ArgumentError.value(
        matchId,
        'matchId',
        'must be positive when present',
      );
    }
    switch (entryKind) {
      case ChatEntryKind.storedConversation:
        if (conversationId == null) {
          throw ArgumentError('stored conversation requires conversationId');
        }
        break;
      case ChatEntryKind.eligibleMatch:
        if (conversationId != null || matchId == null) {
          throw ArgumentError(
            'eligible match requires matchId and no conversationId',
          );
        }
        break;
      case ChatEntryKind.legacyPeer:
        if (conversationId != null || matchId != null) {
          throw ArgumentError(
            'legacy peer cannot claim conversation or match identity',
          );
        }
        break;
    }
  }

  factory ChatRouteState.stored({
    required int conversationId,
    required int peerUserId,
    int? matchId,
    required String title,
  }) => ChatRouteState._(
    entryKind: ChatEntryKind.storedConversation,
    conversationId: conversationId,
    peerUserId: peerUserId,
    matchId: matchId,
    title: title,
  );

  factory ChatRouteState.eligibleMatch({
    required int peerUserId,
    required int matchId,
    required String title,
  }) => ChatRouteState._(
    entryKind: ChatEntryKind.eligibleMatch,
    conversationId: null,
    peerUserId: peerUserId,
    matchId: matchId,
    title: title,
  );

  factory ChatRouteState.legacyPeer({
    required int peerUserId,
    String title = '聊天',
  }) => ChatRouteState._(
    entryKind: ChatEntryKind.legacyPeer,
    conversationId: null,
    peerUserId: peerUserId,
    matchId: null,
    title: title,
  );

  factory ChatRouteState.fromConversation(ConversationEntity conversation) {
    final peerUserId =
        conversation.peerUserId ?? int.tryParse(conversation.id.trim());
    if (peerUserId == null || peerUserId <= 0) {
      throw ArgumentError.value(
        conversation.id,
        'conversation',
        'does not contain a positive peer identity',
      );
    }
    final conversationId = conversation.conversationId;
    if (conversationId != null) {
      return ChatRouteState.stored(
        conversationId: conversationId,
        peerUserId: peerUserId,
        matchId: conversation.matchId,
        title: conversation.name,
      );
    }
    if (conversation.entryKind == 'eligible_match' &&
        conversation.matchId != null) {
      return ChatRouteState.eligibleMatch(
        peerUserId: peerUserId,
        matchId: conversation.matchId!,
        title: conversation.name,
      );
    }
    return ChatRouteState.legacyPeer(
      peerUserId: peerUserId,
      title: conversation.name,
    );
  }

  final ChatEntryKind entryKind;
  final int? conversationId;
  final int peerUserId;
  final int? matchId;
  final String title;

  String get stableKey => conversationId == null
      ? 'peer:$peerUserId'
      : 'conversation:$conversationId';

  String get canonicalSegment => conversationId == null
      ? 'peer-$peerUserId'
      : 'conversation-$conversationId';

  ChatRouteState withConversationId(int storedConversationId) =>
      ChatRouteState.stored(
        conversationId: storedConversationId,
        peerUserId: peerUserId,
        matchId: matchId,
        title: title,
      );

  static String _sanitizeTitle(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.isEmpty) return '聊天';
    return sanitized.length <= 80 ? sanitized : sanitized.substring(0, 80);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRouteState &&
          entryKind == other.entryKind &&
          conversationId == other.conversationId &&
          peerUserId == other.peerUserId &&
          matchId == other.matchId &&
          title == other.title;

  @override
  int get hashCode =>
      Object.hash(entryKind, conversationId, peerUserId, matchId, title);

  @override
  String toString() =>
      'ChatRouteState($entryKind, $stableKey, matchId: $matchId, title: $title)';
}
