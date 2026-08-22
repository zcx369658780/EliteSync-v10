import 'package:flutter_elitesync_module/features/match/data/local_runtime_adapter/relationship_runtime_local_adapter.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/relationship_runtime_local_adapter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RelationshipRuntimeLocalPresentationPhase {
  inactive,
  preparing,
  waiting,
  revealAvailable,
  revealed,
  openerPrepared,
  conversationOpened,
  feedbackPending,
  feedbackRecordedLocal,
  feedbackRecordedRemoteFuture,
  nextRoundPending,
  noCandidate,
  pausedOrUnavailable,
  authSessionFailure,
}

final relationshipRuntimeLocalPresentationStateProvider =
    Provider<RelationshipRuntimeLocalPresentationState>((ref) {
      final results = ref.watch(
        relationshipRuntimeLocalProjectedResultsProvider,
      );
      return RelationshipRuntimeLocalPresentationState.fromProjectedResults(
        results,
      );
    });

class RelationshipRuntimeLocalPresentationState {
  const RelationshipRuntimeLocalPresentationState({
    required this.phase,
    required this.entries,
    required this.evidenceLevel,
    required this.guards,
  });

  factory RelationshipRuntimeLocalPresentationState.inactive() {
    return const RelationshipRuntimeLocalPresentationState(
      phase: RelationshipRuntimeLocalPresentationPhase.inactive,
      entries: <RelationshipRuntimeLocalPresentationEntry>[],
      evidenceLevel: RelationshipRuntimeLocalAdapter.evidenceLevel,
      guards: RelationshipRuntimeLocalPresentationGuards.disabled(),
    );
  }

  factory RelationshipRuntimeLocalPresentationState.fromProjectedResults(
    List<RelationshipRuntimeLocalAdapterResult> results,
  ) {
    if (results.isEmpty) {
      return RelationshipRuntimeLocalPresentationState.inactive();
    }

    final entries = results
        .map(RelationshipRuntimeLocalPresentationEntry.fromResult)
        .toList(growable: false);

    return RelationshipRuntimeLocalPresentationState(
      phase: _firstActivePhase(entries),
      entries: entries,
      evidenceLevel: RelationshipRuntimeLocalAdapter.evidenceLevel,
      guards: RelationshipRuntimeLocalPresentationGuards.aggregate(entries),
    );
  }

  final RelationshipRuntimeLocalPresentationPhase phase;
  final List<RelationshipRuntimeLocalPresentationEntry> entries;
  final String evidenceLevel;
  final RelationshipRuntimeLocalPresentationGuards guards;

  bool get isInactive =>
      phase == RelationshipRuntimeLocalPresentationPhase.inactive &&
      entries.isEmpty;
}

class RelationshipRuntimeLocalPresentationEntry {
  const RelationshipRuntimeLocalPresentationEntry({
    required this.runtimeState,
    required this.phase,
    required this.roundId,
    required this.fallbackCopyKey,
    required this.evidenceLevel,
    required this.candidateSummaryAvailable,
    required this.candidateDetailAvailable,
    required this.explanationBlocksAvailable,
    required this.guards,
    this.reasonCode,
    this.retryable,
  });

  factory RelationshipRuntimeLocalPresentationEntry.fromResult(
    RelationshipRuntimeLocalAdapterResult result,
  ) {
    return RelationshipRuntimeLocalPresentationEntry(
      runtimeState: result.state,
      phase: _phaseForRuntimeState(result.state),
      roundId: result.roundId,
      fallbackCopyKey: result.fallbackCopyKey,
      evidenceLevel: result.evidenceLevel,
      candidateSummaryAvailable: result.candidateSummaryAvailable,
      candidateDetailAvailable: result.candidateDetailAvailable,
      explanationBlocksAvailable: result.explanationBlocksAvailable,
      guards: RelationshipRuntimeLocalPresentationGuards.fromBoundaries(
        result.boundaries,
      ),
      reasonCode: result.reasonCode,
      retryable: result.retryable,
    );
  }

  final String runtimeState;
  final RelationshipRuntimeLocalPresentationPhase phase;
  final String roundId;
  final String fallbackCopyKey;
  final String evidenceLevel;
  final bool candidateSummaryAvailable;
  final bool candidateDetailAvailable;
  final bool explanationBlocksAvailable;
  final RelationshipRuntimeLocalPresentationGuards guards;
  final String? reasonCode;
  final bool? retryable;
}

class RelationshipRuntimeLocalPresentationGuards {
  const RelationshipRuntimeLocalPresentationGuards({
    required this.hasEndpointDependency,
    required this.hasDatabaseDependency,
    required this.hasProductionRuntimeImport,
    required this.canRevealLocally,
    required this.canOpenConversationLocally,
    required this.manualSendOnly,
    required this.automaticSendAllowed,
    required this.localFeedbackOnly,
    required this.remoteFeedbackInactive,
    required this.notificationPushInactive,
    required this.readModelOnly,
    required this.canSend,
    required this.scoringMutationAllowed,
    required this.profileTruthMutationAllowed,
    required this.astroTruthMutationAllowed,
  });

  const RelationshipRuntimeLocalPresentationGuards.disabled()
    : hasEndpointDependency = false,
      hasDatabaseDependency = false,
      hasProductionRuntimeImport = false,
      canRevealLocally = false,
      canOpenConversationLocally = false,
      manualSendOnly = false,
      automaticSendAllowed = false,
      localFeedbackOnly = false,
      remoteFeedbackInactive = true,
      notificationPushInactive = true,
      readModelOnly = false,
      canSend = false,
      scoringMutationAllowed = false,
      profileTruthMutationAllowed = false,
      astroTruthMutationAllowed = false;

  factory RelationshipRuntimeLocalPresentationGuards.fromBoundaries(
    RelationshipRuntimeLocalAdapterBoundaries boundaries,
  ) {
    return RelationshipRuntimeLocalPresentationGuards(
      hasEndpointDependency: boundaries.hasEndpointDependency,
      hasDatabaseDependency: boundaries.hasDatabaseDependency,
      hasProductionRuntimeImport: boundaries.hasProductionRuntimeImport,
      canRevealLocally: boundaries.canRevealLocally,
      canOpenConversationLocally: boundaries.canOpenConversationLocally,
      manualSendOnly: boundaries.manualSendOnly,
      automaticSendAllowed: boundaries.automaticSendAllowed,
      localFeedbackOnly: boundaries.localFeedbackOnly,
      remoteFeedbackInactive: boundaries.remoteFeedbackInactive,
      notificationPushInactive: boundaries.notificationPushInactive,
      readModelOnly: boundaries.readModelOnly,
      canSend: boundaries.canSend,
      scoringMutationAllowed: boundaries.scoringMutationAllowed,
      profileTruthMutationAllowed: boundaries.profileTruthMutationAllowed,
      astroTruthMutationAllowed: boundaries.astroTruthMutationAllowed,
    );
  }

  factory RelationshipRuntimeLocalPresentationGuards.aggregate(
    List<RelationshipRuntimeLocalPresentationEntry> entries,
  ) {
    if (entries.isEmpty) {
      return const RelationshipRuntimeLocalPresentationGuards.disabled();
    }

    return RelationshipRuntimeLocalPresentationGuards(
      hasEndpointDependency: entries.any(
        (entry) => entry.guards.hasEndpointDependency,
      ),
      hasDatabaseDependency: entries.any(
        (entry) => entry.guards.hasDatabaseDependency,
      ),
      hasProductionRuntimeImport: entries.any(
        (entry) => entry.guards.hasProductionRuntimeImport,
      ),
      canRevealLocally: entries.any((entry) => entry.guards.canRevealLocally),
      canOpenConversationLocally: entries.any(
        (entry) => entry.guards.canOpenConversationLocally,
      ),
      manualSendOnly: entries.any((entry) => entry.guards.manualSendOnly),
      automaticSendAllowed: entries.any(
        (entry) => entry.guards.automaticSendAllowed,
      ),
      localFeedbackOnly: entries.any((entry) => entry.guards.localFeedbackOnly),
      remoteFeedbackInactive: entries.every(
        (entry) => entry.guards.remoteFeedbackInactive,
      ),
      notificationPushInactive: entries.every(
        (entry) => entry.guards.notificationPushInactive,
      ),
      readModelOnly: entries.any((entry) => entry.guards.readModelOnly),
      canSend: entries.any((entry) => entry.guards.canSend),
      scoringMutationAllowed: entries.any(
        (entry) => entry.guards.scoringMutationAllowed,
      ),
      profileTruthMutationAllowed: entries.any(
        (entry) => entry.guards.profileTruthMutationAllowed,
      ),
      astroTruthMutationAllowed: entries.any(
        (entry) => entry.guards.astroTruthMutationAllowed,
      ),
    );
  }

  final bool hasEndpointDependency;
  final bool hasDatabaseDependency;
  final bool hasProductionRuntimeImport;
  final bool canRevealLocally;
  final bool canOpenConversationLocally;
  final bool manualSendOnly;
  final bool automaticSendAllowed;
  final bool localFeedbackOnly;
  final bool remoteFeedbackInactive;
  final bool notificationPushInactive;
  final bool readModelOnly;
  final bool canSend;
  final bool scoringMutationAllowed;
  final bool profileTruthMutationAllowed;
  final bool astroTruthMutationAllowed;

  bool get protectedRuntimeDisabled =>
      !hasEndpointDependency &&
      !hasDatabaseDependency &&
      !hasProductionRuntimeImport &&
      !automaticSendAllowed &&
      !canSend &&
      remoteFeedbackInactive &&
      notificationPushInactive &&
      !scoringMutationAllowed &&
      !profileTruthMutationAllowed &&
      !astroTruthMutationAllowed;
}

RelationshipRuntimeLocalPresentationPhase _firstActivePhase(
  List<RelationshipRuntimeLocalPresentationEntry> entries,
) {
  for (final entry in entries) {
    if (entry.phase != RelationshipRuntimeLocalPresentationPhase.inactive) {
      return entry.phase;
    }
  }
  return RelationshipRuntimeLocalPresentationPhase.inactive;
}

RelationshipRuntimeLocalPresentationPhase _phaseForRuntimeState(String state) {
  switch (state) {
    case 'not_started':
      return RelationshipRuntimeLocalPresentationPhase.inactive;
    case 'preparing':
      return RelationshipRuntimeLocalPresentationPhase.preparing;
    case 'waiting':
      return RelationshipRuntimeLocalPresentationPhase.waiting;
    case 'reveal_available':
      return RelationshipRuntimeLocalPresentationPhase.revealAvailable;
    case 'revealed':
      return RelationshipRuntimeLocalPresentationPhase.revealed;
    case 'opener_prepared':
      return RelationshipRuntimeLocalPresentationPhase.openerPrepared;
    case 'conversation_opened':
      return RelationshipRuntimeLocalPresentationPhase.conversationOpened;
    case 'feedback_pending':
      return RelationshipRuntimeLocalPresentationPhase.feedbackPending;
    case 'feedback_recorded_local':
      return RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal;
    case 'feedback_recorded_remote_future':
      return RelationshipRuntimeLocalPresentationPhase
          .feedbackRecordedRemoteFuture;
    case 'next_round_pending':
      return RelationshipRuntimeLocalPresentationPhase.nextRoundPending;
    case 'no_candidate':
      return RelationshipRuntimeLocalPresentationPhase.noCandidate;
    case 'paused_or_unavailable':
      return RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable;
    case 'auth_session_failure':
      return RelationshipRuntimeLocalPresentationPhase.authSessionFailure;
  }

  return RelationshipRuntimeLocalPresentationPhase.inactive;
}
