import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';

enum CanonicalMatchTargetState {
  notOptedIn('MT_NOT_OPTED_IN'),
  active('MT_ACTIVE'),
  proposalPresented('MT_PROPOSAL_PRESENTED'),
  interestRecorded('MT_INTEREST_RECORDED'),
  mutualInterest('MT_MUTUAL_INTEREST'),
  completed('MT_COMPLETED'),
  paused('MT_PAUSED'),
  declined('MT_DECLINED'),
  expired('MT_EXPIRED'),
  withdrawn('MT_WITHDRAWN');

  const CanonicalMatchTargetState(this.code);

  final String code;
}

enum CanonicalMatchPresentationCondition {
  roundAvailable,
  noRound,
  noCandidate,
  transportUnavailable,
  closedWithoutCompletionEvidence,
}

enum CanonicalMatchTargetAction {
  optIn,
  pause,
  resume,
  withdraw,
  decline,
  recordInterest,
  confirmMutualInterest,
  expire,
  complete,
}

class CanonicalMatchLifecycleSnapshot {
  const CanonicalMatchLifecycleSnapshot({
    required this.targetState,
    required this.condition,
    required this.authoritativeActions,
  });

  final CanonicalMatchTargetState? targetState;
  final CanonicalMatchPresentationCondition condition;
  final Set<CanonicalMatchTargetAction> authoritativeActions;

  bool isActionAuthoritative(CanonicalMatchTargetAction action) =>
      authoritativeActions.contains(action);
}

abstract final class CanonicalMatchLifecycleAdapter {
  static CanonicalMatchLifecycleSnapshot fromRound(
    MatchRoundProjection projection,
  ) {
    // The current canonical endpoint supplies read-only round facts. It does
    // not establish authority for target lifecycle mutations, so the action
    // set remains empty until a separately accepted source provides it.
    const noActions = <CanonicalMatchTargetAction>{};

    return switch (projection.state) {
      MatchRoundBusinessState.scheduled ||
      MatchRoundBusinessState.preparing ||
      MatchRoundBusinessState.running => const CanonicalMatchLifecycleSnapshot(
        targetState: CanonicalMatchTargetState.active,
        condition: CanonicalMatchPresentationCondition.roundAvailable,
        authoritativeActions: noActions,
      ),
      MatchRoundBusinessState.revealed => const CanonicalMatchLifecycleSnapshot(
        targetState: CanonicalMatchTargetState.proposalPresented,
        condition: CanonicalMatchPresentationCondition.roundAvailable,
        authoritativeActions: noActions,
      ),
      MatchRoundBusinessState.noRound => const CanonicalMatchLifecycleSnapshot(
        targetState: null,
        condition: CanonicalMatchPresentationCondition.noRound,
        authoritativeActions: noActions,
      ),
      MatchRoundBusinessState.noCandidate =>
        const CanonicalMatchLifecycleSnapshot(
          targetState: null,
          condition: CanonicalMatchPresentationCondition.noCandidate,
          authoritativeActions: noActions,
        ),
      MatchRoundBusinessState.failed => const CanonicalMatchLifecycleSnapshot(
        targetState: null,
        condition: CanonicalMatchPresentationCondition.transportUnavailable,
        authoritativeActions: noActions,
      ),
      MatchRoundBusinessState.closed => const CanonicalMatchLifecycleSnapshot(
        targetState: null,
        condition:
            CanonicalMatchPresentationCondition.closedWithoutCompletionEvidence,
        authoritativeActions: noActions,
      ),
    };
  }
}
