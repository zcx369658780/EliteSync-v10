import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

void main() {
  test('declares the complete Product Conversation vocabulary', () {
    expect(
      ProductConversationState.values.map((state) => state.code),
      orderedEquals(const [
        'CV_LOCKED',
        'CV_PENDING_CONSENT',
        'CV_ACTIVE',
        'CV_PAUSED',
        'CV_CLOSED',
      ]),
    );
  });

  test('fails closed while either authority is not established', () {
    const activeConnection = ProductConnectionEvidence.authoritative(
      ProductConnectionState.active,
    );

    expect(
      ProductConversationAccessAdapter.resolve(
        connection: const ProductConnectionEvidence.notYetEstablished(),
        messagingConsent: const MessagingConsentEvidence.notYetEstablished(),
      ).state,
      ProductConversationState.locked,
    );
    expect(
      ProductConversationAccessAdapter.resolve(
        connection: activeConnection,
        messagingConsent: const MessagingConsentEvidence.notYetEstablished(),
      ).canRevealPrivateContent,
      isFalse,
    );
  });

  test('requires authoritative CN_ACTIVE and mutual messaging consent', () {
    const activeConnection = ProductConnectionEvidence.authoritative(
      ProductConnectionState.active,
    );
    const pendingConsent = MessagingConsentEvidence.authoritative(
      MessagingConsentState.pending,
    );
    const mutualConsent = MessagingConsentEvidence.authoritative(
      MessagingConsentState.mutual,
    );

    final pending = ProductConversationAccessAdapter.resolve(
      connection: activeConnection,
      messagingConsent: pendingConsent,
    );
    final active = ProductConversationAccessAdapter.resolve(
      connection: activeConnection,
      messagingConsent: mutualConsent,
    );
    final nonActiveConnection = ProductConversationAccessAdapter.resolve(
      connection: const ProductConnectionEvidence.authoritative(
        ProductConnectionState.paused,
      ),
      messagingConsent: mutualConsent,
    );

    expect(pending.state, ProductConversationState.pendingConsent);
    expect(pending.canRevealPrivateContent, isFalse);
    expect(active.state, ProductConversationState.active);
    expect(active.authority, ConversationEvidenceAuthority.authoritative);
    expect(active.canRevealPrivateContent, isTrue);
    expect(active.canSend, isTrue);
    expect(nonActiveConnection.state, ProductConversationState.locked);
    expect(nonActiveConnection.canRevealPrivateContent, isFalse);
  });

  test('every transition into active records both prerequisites', () {
    final intoActive = ProductConversationContract.transitions.where(
      (transition) => transition.to == ProductConversationState.active,
    );

    expect(intoActive, isNotEmpty);
    for (final transition in intoActive) {
      expect(transition.requiresAuthoritativeActiveConnection, isTrue);
      expect(transition.requiresAuthoritativeMutualMessagingConsent, isTrue);
    }
    final intoPending = ProductConversationContract.transitions.singleWhere(
      (transition) =>
          transition.from == ProductConversationState.locked &&
          transition.to == ProductConversationState.pendingConsent,
    );
    expect(intoPending.requiresAuthoritativeActiveConnection, isTrue);
  });

  test('keeps every messaging consent mutation unavailable', () {
    expect(ProductConversationAuthority.authoritativeActions, isEmpty);
    for (final action in ConversationLifecycleAction.values) {
      expect(
        ProductConversationAuthority.statusFor(action),
        ConversationActionAuthority.notYetEstablished,
      );
    }
  });

  test('route identity never grants Conversation read or send authority', () {
    final routes = [
      ChatRouteState.stored(
        conversationId: 11,
        peerUserId: 21,
        title: 'Synthetic stored route',
      ),
      ChatRouteState.eligibleMatch(
        peerUserId: 22,
        matchId: 32,
        title: 'Synthetic eligible route',
      ),
      ChatRouteState.legacyPeer(
        peerUserId: 23,
        title: 'Synthetic legacy route',
      ),
    ];

    for (final route in routes) {
      expect(route.grantsConversationReadOrSendAuthority, isFalse);
    }
    expect(routes[1].isCompatibilityIdentifier, isTrue);
    expect(routes[2].isCompatibilityIdentifier, isTrue);
  });
}
