import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
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

  test('list item becomes stored only with explicit kind and positive ID', () {
    final route = ChatRouteState.fromConversation(
      const ConversationEntity(
        id: 'legacy-peer-alias',
        name: 'Stored peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        entryKind: 'stored_conversation',
        conversationId: 41,
        peerUserId: 23,
      ),
    );

    expect(route.entryKind, ChatEntryKind.storedConversation);
    expect(route.conversationId, 41);
    expect(route.peerUserId, 23);
    expect(route.canonicalSegment, 'conversation-41');
  });

  test('stored list item cannot borrow numeric id for missing peer', () {
    expect(
      () => ChatRouteState.fromConversation(
        const ConversationEntity(
          id: '23',
          name: 'Unresolved stored peer',
          lastMessage: '',
          lastTime: '',
          unread: 0,
          entryKind: 'stored_conversation',
          conversationId: 41,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('stored list item with numeric id uses its explicit peer', () {
    final route = ChatRouteState.fromConversation(
      const ConversationEntity(
        id: '29',
        name: 'Bound stored peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        entryKind: 'stored_conversation',
        conversationId: 41,
        peerUserId: 23,
      ),
    );

    expect(route.entryKind, ChatEntryKind.storedConversation);
    expect(route.conversationId, 41);
    expect(route.peerUserId, 23);
  });

  for (final invalidId in <int?>[null, 0, -1]) {
    test('stored list item rejects missing or invalid ID $invalidId', () {
      expect(
        () => ChatRouteState.fromConversation(
          ConversationEntity(
            id: 'legacy-peer-alias',
            name: 'Unresolved peer',
            lastMessage: '',
            lastTime: '',
            unread: 0,
            entryKind: 'stored_conversation',
            conversationId: invalidId,
            peerUserId: 23,
          ),
        ),
        throwsArgumentError,
      );
    });
  }

  for (final kind in <String?>['legacy_peer', 'eligible_match', null]) {
    test('non-stored list item rejects carried conversation ID $kind', () {
      expect(
        () => ChatRouteState.fromConversation(
          ConversationEntity(
            id: 'legacy-peer-alias',
            name: 'Contradictory peer',
            lastMessage: '',
            lastTime: '',
            unread: 0,
            entryKind: kind,
            conversationId: 41,
            peerUserId: 23,
            matchId: 7,
          ),
        ),
        throwsArgumentError,
      );
    });
  }

  for (final invalidMatchId in <int?>[null, 0, -1]) {
    for (final useNumericPeerFallback in <bool>[false, true]) {
      test(
        'explicit eligible rejects match ID $invalidMatchId with numeric peer fallback $useNumericPeerFallback',
        () {
          expect(
            () => ChatRouteState.fromConversation(
              ConversationEntity(
                id: useNumericPeerFallback ? '23' : 'legacy-peer-alias',
                name: 'Unresolved eligible peer',
                lastMessage: '',
                lastTime: '',
                unread: 0,
                entryKind: 'eligible_match',
                peerUserId: useNumericPeerFallback ? null : 23,
                matchId: invalidMatchId,
              ),
            ),
            throwsArgumentError,
          );
        },
      );
    }
  }

  test(
    'eligible and old peer list entries remain compatibility identities',
    () {
      final eligible = ChatRouteState.fromConversation(
        const ConversationEntity(
          id: 'legacy-peer-alias',
          name: 'Eligible peer',
          lastMessage: '',
          lastTime: '',
          unread: 0,
          entryKind: 'eligible_match',
          peerUserId: 23,
          matchId: 7,
        ),
      );
      final legacy = ChatRouteState.fromConversation(
        const ConversationEntity(
          id: '23',
          name: 'Legacy peer',
          lastMessage: '',
          lastTime: '',
          unread: 0,
        ),
      );

      expect(eligible.entryKind, ChatEntryKind.eligibleMatch);
      expect(eligible.conversationId, isNull);
      expect(eligible.matchId, 7);
      expect(legacy.entryKind, ChatEntryKind.legacyPeer);
      expect(legacy.peerUserId, 23);
      expect(legacy.conversationId, isNull);
    },
  );

  test('eligible list item keeps numeric peer fallback without stored ID', () {
    final route = ChatRouteState.fromConversation(
      const ConversationEntity(
        id: '23',
        name: 'Eligible peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        entryKind: 'eligible_match',
        matchId: 7,
      ),
    );

    expect(route.entryKind, ChatEntryKind.eligibleMatch);
    expect(route.conversationId, isNull);
    expect(route.peerUserId, 23);
    expect(route.matchId, 7);
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
    expect(chatRouteStateFromPath(segment: '23', extra: typed), isNull);
    final eligible = ChatRouteState.eligibleMatch(
      peerUserId: 23,
      matchId: 7,
      title: 'Eligible',
    );
    expect(chatRouteStateFromPath(segment: '23', extra: eligible), isNull);

    final legacy = chatRouteStateFromPath(segment: '23', extra: ' Legacy ');
    expect(legacy?.entryKind, ChatEntryKind.legacyPeer);
    expect(legacy?.peerUserId, 23);
    expect(legacy?.conversationId, isNull);
    expect(legacy?.title, 'Legacy');
    expect(
      chatRouteStateFromPath(segment: '23')?.entryKind,
      ChatEntryKind.legacyPeer,
    );
    expect(storedConversationIdFromSegment('conversation-41'), 41);
    expect(storedConversationIdFromSegment('peer-23'), isNull);
  });
}
