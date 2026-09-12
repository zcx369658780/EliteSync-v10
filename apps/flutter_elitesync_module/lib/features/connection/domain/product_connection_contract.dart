enum ProductConnectionState {
  none,
  pending,
  active,
  paused,
  closed,
  declined,
  withdrawn,
  expired,
}

extension ProductConnectionStateContract on ProductConnectionState {
  String get code => switch (this) {
    ProductConnectionState.none => 'CN_NONE',
    ProductConnectionState.pending => 'CN_PENDING',
    ProductConnectionState.active => 'CN_ACTIVE',
    ProductConnectionState.paused => 'CN_PAUSED',
    ProductConnectionState.closed => 'CN_CLOSED',
    ProductConnectionState.declined => 'CN_DECLINED',
    ProductConnectionState.withdrawn => 'CN_WITHDRAWN',
    ProductConnectionState.expired => 'CN_EXPIRED',
  };

  String get label => switch (this) {
    ProductConnectionState.none => '尚未发起连接',
    ProductConnectionState.pending => '等待另一方独立确认',
    ProductConnectionState.active => '双方已同意连接',
    ProductConnectionState.paused => '连接已暂停',
    ProductConnectionState.closed => '连接已关闭',
    ProductConnectionState.declined => '连接请求已谢绝',
    ProductConnectionState.withdrawn => '连接请求已撤回',
    ProductConnectionState.expired => '连接请求已过期',
  };

  bool get isTerminalRequestOutcome => switch (this) {
    ProductConnectionState.declined ||
    ProductConnectionState.withdrawn ||
    ProductConnectionState.expired => true,
    _ => false,
  };

  bool get impliesSafetyFinding => false;

  bool get impliesObjectiveIncompatibility => false;
}

enum ConnectionLifecycleAction {
  request,
  accept,
  decline,
  withdraw,
  expire,
  pause,
  resume,
  close,
}

extension ConnectionLifecycleActionContract on ConnectionLifecycleAction {
  String get label => switch (this) {
    ConnectionLifecycleAction.request => '请求连接',
    ConnectionLifecycleAction.accept => '接受连接',
    ConnectionLifecycleAction.decline => '谢绝请求',
    ConnectionLifecycleAction.withdraw => '撤回请求',
    ConnectionLifecycleAction.expire => '请求过期',
    ConnectionLifecycleAction.pause => '暂停连接',
    ConnectionLifecycleAction.resume => '恢复连接',
    ConnectionLifecycleAction.close => '关闭连接',
  };
}

enum ConnectionActorRequirement {
  eitherEligibleCandidate,
  recipient,
  requester,
  eitherConnectedParticipant,
  pausingParticipant,
  systemWithEstablishedExpiryPolicy,
}

enum ConnectionActionAuthority { authoritative, notYetEstablished }

class ConnectionTransition {
  const ConnectionTransition({
    required this.from,
    required this.to,
    required this.action,
    required this.actor,
    this.establishesMutualConsent = false,
  });

  final ProductConnectionState from;
  final ProductConnectionState to;
  final ConnectionLifecycleAction action;
  final ConnectionActorRequirement actor;
  final bool establishesMutualConsent;
}

abstract final class ProductConnectionContract {
  static const transitions = <ConnectionTransition>[
    ConnectionTransition(
      from: ProductConnectionState.none,
      to: ProductConnectionState.pending,
      action: ConnectionLifecycleAction.request,
      actor: ConnectionActorRequirement.eitherEligibleCandidate,
    ),
    ConnectionTransition(
      from: ProductConnectionState.pending,
      to: ProductConnectionState.active,
      action: ConnectionLifecycleAction.accept,
      actor: ConnectionActorRequirement.recipient,
      establishesMutualConsent: true,
    ),
    ConnectionTransition(
      from: ProductConnectionState.pending,
      to: ProductConnectionState.declined,
      action: ConnectionLifecycleAction.decline,
      actor: ConnectionActorRequirement.recipient,
    ),
    ConnectionTransition(
      from: ProductConnectionState.pending,
      to: ProductConnectionState.withdrawn,
      action: ConnectionLifecycleAction.withdraw,
      actor: ConnectionActorRequirement.requester,
    ),
    ConnectionTransition(
      from: ProductConnectionState.pending,
      to: ProductConnectionState.expired,
      action: ConnectionLifecycleAction.expire,
      actor: ConnectionActorRequirement.systemWithEstablishedExpiryPolicy,
    ),
    ConnectionTransition(
      from: ProductConnectionState.active,
      to: ProductConnectionState.paused,
      action: ConnectionLifecycleAction.pause,
      actor: ConnectionActorRequirement.eitherConnectedParticipant,
    ),
    ConnectionTransition(
      from: ProductConnectionState.active,
      to: ProductConnectionState.closed,
      action: ConnectionLifecycleAction.close,
      actor: ConnectionActorRequirement.eitherConnectedParticipant,
    ),
    ConnectionTransition(
      from: ProductConnectionState.paused,
      to: ProductConnectionState.active,
      action: ConnectionLifecycleAction.resume,
      actor: ConnectionActorRequirement.pausingParticipant,
    ),
    ConnectionTransition(
      from: ProductConnectionState.paused,
      to: ProductConnectionState.closed,
      action: ConnectionLifecycleAction.close,
      actor: ConnectionActorRequirement.eitherConnectedParticipant,
    ),
  ];

  static ConnectionTransition? transition({
    required ProductConnectionState from,
    required ProductConnectionState to,
  }) {
    for (final transition in transitions) {
      if (transition.from == from && transition.to == to) {
        return transition;
      }
    }
    return null;
  }
}

abstract final class ProductConnectionAuthority {
  static const notYetEstablishedLabel = 'NOT YET ESTABLISHED';

  static const authoritativeActions = <ConnectionLifecycleAction>{};

  static ConnectionActionAuthority statusFor(ConnectionLifecycleAction action) {
    return authoritativeActions.contains(action)
        ? ConnectionActionAuthority.authoritative
        : ConnectionActionAuthority.notYetEstablished;
  }
}
