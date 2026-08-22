import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stored state has value equality and conversation canonical identity',
    () {
      final first = ChatRouteState.stored(
        conversationId: 41,
        peerUserId: 23,
        matchId: 7,
        title: '  对方\n昵称  ',
      );
      final second = ChatRouteState.stored(
        conversationId: 41,
        peerUserId: 23,
        matchId: 7,
        title: '对方 昵称',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.entryKind, ChatEntryKind.storedConversation);
      expect(first.stableKey, 'conversation:41');
      expect(first.canonicalSegment, 'conversation-41');
      expect(first.title, '对方 昵称');
    },
  );

  test('eligible and legacy states use peer identity without fabrication', () {
    final eligible = ChatRouteState.eligibleMatch(
      peerUserId: 23,
      matchId: 7,
      title: 'Eligible',
    );
    final legacy = ChatRouteState.legacyPeer(peerUserId: 23, title: '\n');

    expect(eligible.entryKind, ChatEntryKind.eligibleMatch);
    expect(eligible.conversationId, isNull);
    expect(eligible.stableKey, 'peer:23');
    expect(eligible.canonicalSegment, 'peer-23');
    expect(legacy.entryKind, ChatEntryKind.legacyPeer);
    expect(legacy.conversationId, isNull);
    expect(legacy.title, '聊天');

    final adopted = eligible.withConversationId(41);
    expect(adopted.entryKind, ChatEntryKind.storedConversation);
    expect(adopted.conversationId, 41);
    expect(adopted.peerUserId, 23);
    expect(adopted.matchId, 7);
  });

  test('invalid identities fail closed', () {
    expect(() => ChatRouteState.legacyPeer(peerUserId: 0), throwsArgumentError);
    expect(
      () => ChatRouteState.stored(
        conversationId: -1,
        peerUserId: 2,
        title: 'Chat',
      ),
      throwsArgumentError,
    );
  });

  test('router accepts matching typed extra and numeric legacy fallback', () {
    final typed = ChatRouteState.stored(
      conversationId: 41,
      peerUserId: 23,
      title: 'Chat',
    );

    expect(
      identical(
        chatRouteStateFromPath(segment: 'conversation-41', extra: typed),
        typed,
      ),
      isTrue,
    );
    expect(
      chatRouteStateFromPath(segment: 'conversation-99', extra: typed),
      isNull,
    );

    final legacy = chatRouteStateFromPath(segment: '23', extra: ' Legacy ');
    expect(legacy?.entryKind, ChatEntryKind.legacyPeer);
    expect(legacy?.peerUserId, 23);
    expect(legacy?.conversationId, isNull);
    expect(legacy?.title, 'Legacy');
    expect(storedConversationIdFromSegment('conversation-41'), 41);
    expect(storedConversationIdFromSegment('peer-23'), isNull);
  });
}
