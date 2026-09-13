import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

enum ProductConversationState { locked, pendingConsent, active, paused, closed }

extension ProductConversationStateContract on ProductConversationState {
  String get code => switch (this) {
    ProductConversationState.locked => 'CV_LOCKED',
    ProductConversationState.pendingConsent => 'CV_PENDING_CONSENT',
    ProductConversationState.active => 'CV_ACTIVE',
    ProductConversationState.paused => 'CV_PAUSED',
    ProductConversationState.closed => 'CV_CLOSED',
  };
}

enum ConversationEvidenceAuthority { authoritative, notYetEstablished }

enum MessagingConsentState { pending, mutual }

enum ConversationLifecycleAction {
  requestMessagingConsent,
  acceptMessagingConsent,
  declineMessagingConsent,
  withdrawMessagingConsent,
  pause,
  resume,
  close,
}

extension ConversationLifecycleActionContract on ConversationLifecycleAction {
  String get label => switch (this) {
    ConversationLifecycleAction.requestMessagingConsent => '请求消息同意',
    ConversationLifecycleAction.acceptMessagingConsent => '同意消息交流',
    ConversationLifecycleAction.declineMessagingConsent => '谢绝消息交流',
    ConversationLifecycleAction.withdrawMessagingConsent => '撤回消息请求',
    ConversationLifecycleAction.pause => '暂停对话',
    ConversationLifecycleAction.resume => '恢复对话',
    ConversationLifecycleAction.close => '关闭对话',
  };
}

enum ConversationActionAuthority { authoritative, notYetEstablished }

class ConversationTransition {
  const ConversationTransition({
    required this.from,
    required this.to,
    required this.action,
    this.requiresAuthoritativeActiveConnection = false,
    this.requiresAuthoritativeMutualMessagingConsent = false,
  });

  final ProductConversationState from;
  final ProductConversationState to;
  final ConversationLifecycleAction action;
  final bool requiresAuthoritativeActiveConnection;
  final bool requiresAuthoritativeMutualMessagingConsent;
}

abstract final class ProductConversationContract {
  static const transitions = <ConversationTransition>[
    ConversationTransition(
      from: ProductConversationState.locked,
      to: ProductConversationState.pendingConsent,
      action: ConversationLifecycleAction.requestMessagingConsent,
      requiresAuthoritativeActiveConnection: true,
    ),
    ConversationTransition(
      from: ProductConversationState.pendingConsent,
      to: ProductConversationState.active,
      action: ConversationLifecycleAction.acceptMessagingConsent,
      requiresAuthoritativeActiveConnection: true,
      requiresAuthoritativeMutualMessagingConsent: true,
    ),
    ConversationTransition(
      from: ProductConversationState.pendingConsent,
      to: ProductConversationState.locked,
      action: ConversationLifecycleAction.declineMessagingConsent,
    ),
    ConversationTransition(
      from: ProductConversationState.pendingConsent,
      to: ProductConversationState.locked,
      action: ConversationLifecycleAction.withdrawMessagingConsent,
    ),
    ConversationTransition(
      from: ProductConversationState.pendingConsent,
      to: ProductConversationState.closed,
      action: ConversationLifecycleAction.close,
    ),
    ConversationTransition(
      from: ProductConversationState.active,
      to: ProductConversationState.paused,
      action: ConversationLifecycleAction.pause,
    ),
    ConversationTransition(
      from: ProductConversationState.active,
      to: ProductConversationState.closed,
      action: ConversationLifecycleAction.close,
    ),
    ConversationTransition(
      from: ProductConversationState.paused,
      to: ProductConversationState.active,
      action: ConversationLifecycleAction.resume,
      requiresAuthoritativeActiveConnection: true,
      requiresAuthoritativeMutualMessagingConsent: true,
    ),
    ConversationTransition(
      from: ProductConversationState.paused,
      to: ProductConversationState.closed,
      action: ConversationLifecycleAction.close,
    ),
  ];
}

class ProductConnectionEvidence {
  const ProductConnectionEvidence.authoritative(this.state)
    : authority = ConversationEvidenceAuthority.authoritative;

  const ProductConnectionEvidence.notYetEstablished()
    : state = null,
      authority = ConversationEvidenceAuthority.notYetEstablished;

  final ProductConnectionState? state;
  final ConversationEvidenceAuthority authority;

  bool get isAuthoritativeActive =>
      authority == ConversationEvidenceAuthority.authoritative &&
      state == ProductConnectionState.active;
}

class MessagingConsentEvidence {
  const MessagingConsentEvidence.authoritative(this.state)
    : authority = ConversationEvidenceAuthority.authoritative;

  const MessagingConsentEvidence.notYetEstablished()
    : state = null,
      authority = ConversationEvidenceAuthority.notYetEstablished;

  final MessagingConsentState? state;
  final ConversationEvidenceAuthority authority;

  bool get hasAuthoritativeState =>
      authority == ConversationEvidenceAuthority.authoritative && state != null;
}

class ConversationAccessSnapshot {
  const ConversationAccessSnapshot._authoritative(this.state)
    : authority = ConversationEvidenceAuthority.authoritative;

  const ConversationAccessSnapshot.notYetEstablished()
    : state = ProductConversationState.locked,
      authority = ConversationEvidenceAuthority.notYetEstablished;

  final ProductConversationState state;
  final ConversationEvidenceAuthority authority;

  bool get canRevealPrivateContent =>
      authority == ConversationEvidenceAuthority.authoritative &&
      state == ProductConversationState.active;

  bool get canSend => canRevealPrivateContent;
}

abstract final class ProductConversationAccessAdapter {
  static ConversationAccessSnapshot resolve({
    required ProductConnectionEvidence connection,
    required MessagingConsentEvidence messagingConsent,
  }) {
    if (!connection.isAuthoritativeActive) {
      return connection.authority == ConversationEvidenceAuthority.authoritative
          ? const ConversationAccessSnapshot._authoritative(
              ProductConversationState.locked,
            )
          : const ConversationAccessSnapshot.notYetEstablished();
    }
    if (!messagingConsent.hasAuthoritativeState) {
      return const ConversationAccessSnapshot.notYetEstablished();
    }
    return messagingConsent.state == MessagingConsentState.mutual
        ? const ConversationAccessSnapshot._authoritative(
            ProductConversationState.active,
          )
        : const ConversationAccessSnapshot._authoritative(
            ProductConversationState.pendingConsent,
          );
  }
}

abstract final class ProductConversationAuthority {
  static const notYetEstablishedLabel = 'NOT YET ESTABLISHED';

  static const authoritativeActions = <ConversationLifecycleAction>{};

  static ConversationActionAuthority statusFor(
    ConversationLifecycleAction action,
  ) => authoritativeActions.contains(action)
      ? ConversationActionAuthority.authoritative
      : ConversationActionAuthority.notYetEstablished;
}
