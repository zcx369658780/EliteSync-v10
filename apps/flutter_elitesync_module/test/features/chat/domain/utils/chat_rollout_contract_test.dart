import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_failure.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/chat_message_reconciliation.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/chat_route_adoption.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_test/flutter_test.dart';

MessageEntity message({
  required String id,
  required String text,
  String? clientMessageId,
}) => MessageEntity(
  id: id,
  mine: true,
  text: text,
  time: 'now',
  attachments: const [],
  clientMessageId: clientMessageId,
);

void main() {
  group('route adoption guard', () {
    test('eligible and legacy first success adopt stored identity', () {
      final eligible = ChatRouteState.eligibleMatch(
        peerUserId: 23,
        matchId: 7,
        title: 'Peer',
      );
      final legacy = ChatRouteState.legacyPeer(peerUserId: 23);

      final adoptedEligible = resolveChatRouteAfterSend(eligible, 41);
      final adoptedLegacy = resolveChatRouteAfterSend(legacy, 42);

      expect(adoptedEligible.conversationId, 41);
      expect(adoptedEligible.peerUserId, 23);
      expect(adoptedEligible.matchId, 7);
      expect(adoptedLegacy.conversationId, 42);
      expect(adoptedLegacy.peerUserId, 23);
    });

    test('stored route accepts same ID and rejects different ID', () {
      final stored = ChatRouteState.stored(
        conversationId: 41,
        peerUserId: 23,
        title: 'Peer',
      );

      expect(identical(resolveChatRouteAfterSend(stored, 41), stored), isTrue);
      expect(
        () => resolveChatRouteAfterSend(stored, 99),
        throwsA(
          isA<ChatSendFailure>().having(
            (failure) => failure.isConversationIdentityConflict,
            'identity conflict',
            isTrue,
          ),
        ),
      );
      expect(stored.conversationId, 41);
      expect(stored.peerUserId, 23);
    });
  });

  group('keyed reconciliation', () {
    test('client key removes first-success and replay duplicates', () {
      final optimistic = message(
        id: 'local-key-1',
        text: 'same',
        clientMessageId: 'key-1',
      );
      final success = message(id: '81', text: 'same', clientMessageId: 'key-1');
      final replay = message(id: '81', text: 'same', clientMessageId: 'key-1');

      final merged = reconcileChatMessages(
        remote: [success, replay],
        local: [optimistic],
      );

      expect(merged, hasLength(1));
      expect(merged.single.id, '81');
    });

    test('server ID is fallback when a client key is unavailable', () {
      final fetched = message(id: '81', text: 'same');
      final reconciled = message(
        id: '81',
        text: 'same',
        clientMessageId: 'key-1',
      );

      expect(
        reconcileChatMessages(remote: [fetched], local: [reconciled]),
        hasLength(1),
      );
    });

    test('distinct same-text keyed attempts coexist', () {
      final first = message(id: '81', text: 'same', clientMessageId: 'key-1');
      final second = message(id: '82', text: 'same', clientMessageId: 'key-2');

      expect(
        reconcileChatMessages(remote: [first, second], local: const []),
        hasLength(2),
      );
    });
  });

  test('message provider identity is the explicit stable key', () {
    final first = ChatMessagesRequest.fromRoute(
      ChatRouteState.stored(
        conversationId: 41,
        peerUserId: 23,
        title: 'Old title',
      ),
    );
    final renamed = ChatMessagesRequest.fromRoute(
      ChatRouteState.stored(
        conversationId: 41,
        peerUserId: 23,
        matchId: 7,
        title: 'New title',
      ),
    );

    expect(first.stableKey, 'conversation:41');
    expect(first, renamed);
    expect(first.hashCode, renamed.hashCode);
    expect(first.peerUserId, 23);
  });

  test('messages realtime RTC and moderation retain peer target identity', () {
    final stored = ChatRouteState.stored(
      conversationId: 4100,
      peerUserId: 23,
      title: 'Peer',
    );

    expect(chatPeerUserIdForOperations(stored), 23);
    expect(chatPeerUserIdForOperations(stored), isNot(stored.conversationId));
    expect(ChatMessagesRequest.fromRoute(stored).peerUserId, 23);
  });
}
