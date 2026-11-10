import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/canonical_match_lifecycle.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';

MatchRoundProjection _projection(
  MatchRoundBusinessState state, {
  MatchRoundResult? result,
  MatchRoundConversationCapability? conversationCapability,
}) {
  final now = DateTime.utc(2026, 9, 12);
  return MatchRoundProjection(
    state: state,
    serverTime: now,
    receivedAt: now,
    contractVersion: 'match_round_v1',
    retryEligible: state == MatchRoundBusinessState.failed,
    userAction: 'wait',
    projectionVersion: 1,
    updatedAt: now,
    result: result,
    conversationCapability: conversationCapability,
  );
}

void main() {
  test('target vocabulary remains explicit and complete', () {
    expect(CanonicalMatchTargetState.values.map((state) => state.code), [
      'MT_NOT_OPTED_IN',
      'MT_ACTIVE',
      'MT_PROPOSAL_PRESENTED',
      'MT_INTEREST_RECORDED',
      'MT_MUTUAL_INTEREST',
      'MT_COMPLETED',
      'MT_PAUSED',
      'MT_DECLINED',
      'MT_EXPIRED',
      'MT_WITHDRAWN',
    ]);
  });

  test('scheduled preparing and running map to bounded active state', () {
    for (final state in [
      MatchRoundBusinessState.scheduled,
      MatchRoundBusinessState.preparing,
      MatchRoundBusinessState.running,
    ]) {
      final adapted = CanonicalMatchLifecycleAdapter.fromRound(
        _projection(state),
      );
      expect(adapted.targetState, CanonicalMatchTargetState.active);
      expect(
        adapted.condition,
        CanonicalMatchPresentationCondition.roundAvailable,
      );
      expect(adapted.authoritativeActions, isEmpty);
    }
  });

  test('revealed maps to proposal and ignores conversation capability', () {
    final adapted = CanonicalMatchLifecycleAdapter.fromRound(
      _projection(
        MatchRoundBusinessState.revealed,
        result: const MatchRoundResult(
          matchId: 1,
          partnerId: 2,
          headline: 'bounded proposal',
        ),
        conversationCapability: const MatchRoundConversationCapability(
          canCreate: true,
          canSend: true,
          canWebSocket: true,
        ),
      ),
    );

    expect(adapted.targetState, CanonicalMatchTargetState.proposalPresented);
    expect(adapted.authoritativeActions, isEmpty);
  });

  test('no round and no candidate remain presentation conditions', () {
    final noRound = CanonicalMatchLifecycleAdapter.fromRound(
      _projection(MatchRoundBusinessState.noRound),
    );
    final noCandidate = CanonicalMatchLifecycleAdapter.fromRound(
      _projection(MatchRoundBusinessState.noCandidate),
    );

    expect(noRound.targetState, isNull);
    expect(noRound.condition, CanonicalMatchPresentationCondition.noRound);
    expect(noCandidate.targetState, isNull);
    expect(
      noCandidate.condition,
      CanonicalMatchPresentationCondition.noCandidate,
    );
  });

  test('failed remains transport condition, not a domain outcome', () {
    final adapted = CanonicalMatchLifecycleAdapter.fromRound(
      _projection(MatchRoundBusinessState.failed),
    );

    expect(adapted.targetState, isNull);
    expect(
      adapted.condition,
      CanonicalMatchPresentationCondition.transportUnavailable,
    );
  });

  test('closed does not manufacture completed even when result exists', () {
    final unproven = CanonicalMatchLifecycleAdapter.fromRound(
      _projection(MatchRoundBusinessState.closed),
    );
    final withResult = CanonicalMatchLifecycleAdapter.fromRound(
      _projection(
        MatchRoundBusinessState.closed,
        result: const MatchRoundResult(
          matchId: 1,
          partnerId: 2,
          headline: 'bounded completion evidence',
        ),
      ),
    );

    expect(unproven.targetState, isNull);
    expect(
      unproven.condition,
      CanonicalMatchPresentationCondition.closedWithoutCompletionEvidence,
    );
    expect(withResult.targetState, isNull);
    expect(
      withResult.condition,
      CanonicalMatchPresentationCondition.closedWithoutCompletionEvidence,
    );
    expect(withResult.authoritativeActions, isEmpty);
  });
}
