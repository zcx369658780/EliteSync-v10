import 'package:flutter_elitesync_module/features/chat/domain/conversation_revalidation_gate.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_test/flutter_test.dart';

// All IDs and verification receipts below are fictional caller-supplied test
// claims. A passing result does not authenticate a server or authorize UI.
const request = RevalidationRequest(
  subjectId: 'synthetic-actor-a',
  participantIds: ['synthetic-actor-a', 'synthetic-actor-b'],
  connectionAggregateId: 'synthetic-connection-1',
  contextId: 'synthetic-context-1',
  purpose: 'synthetic-conversation-live',
  audience: 'synthetic-bound-participants',
);

const verified = RevalidationChecks(
  identity: RevalidationCheck.passed,
  participants: RevalidationCheck.passed,
  ownerProvenance: RevalidationCheck.passed,
  purposeAudience: RevalidationCheck.passed,
  revisionCurrentness: RevalidationCheck.passed,
  freshness: RevalidationCheck.passed,
  context: RevalidationCheck.passed,
);

RevalidationEvidence evidence({
  RevalidationOrigin origin = RevalidationOrigin.authoritativeClaim,
  RevalidationCurrentness currentness = RevalidationCurrentness.current,
  RevalidationFreshness freshness = RevalidationFreshness.fresh,
  RevalidationChecks checks = verified,
  String? sourceOwner = 'fictional-source-owner',
  String? provenance = 'fictional-provenance',
  String? subjectId = 'synthetic-actor-a',
  List<String>? participantIds = const [
    'synthetic-actor-a',
    'synthetic-actor-b',
  ],
  String? connectionAggregateId = 'synthetic-connection-1',
  String? contextId = 'synthetic-context-1',
  String? purpose = 'synthetic-conversation-live',
  String? audience = 'synthetic-bound-participants',
  String? lineageId = 'fictional-independent-lineage',
  String? revision = 'fictional-revision-1',
}) => RevalidationEvidence(
  origin: origin,
  currentness: currentness,
  freshness: freshness,
  checks: checks,
  sourceOwner: sourceOwner,
  provenance: provenance,
  subjectId: subjectId,
  participantIds: participantIds,
  connectionAggregateId: connectionAggregateId,
  contextId: contextId,
  purpose: purpose,
  audience: audience,
  lineageId: lineageId,
  revision: revision,
);

RevalidationDecision decide({
  RevalidationRequest context = request,
  RevalidationEvidence? connection,
  RevalidationEvidence? consent,
  ProductConnectionState connectionState = ProductConnectionState.active,
  ConsentGateState consentState = ConsentGateState.active,
  RevalidationMoment moment = RevalidationMoment.readRequest,
  RevalidationCheck readCheck = RevalidationCheck.passed,
  RevalidationCheck sendCheck = RevalidationCheck.passed,
}) => ConversationRevalidationGate.evaluate(
  request: context,
  connection: ConnectionRevalidationInput(
    connectionState,
    connection ?? evidence(
      lineageId: 'connection-lineage',
      revision: 'connection-revision-14',
    ),
  ),
  messagingConsent: ConsentRevalidationInput(
    consentState,
    consent ?? evidence(
      lineageId: 'consent-lineage',
      revision: 'consent-revision-7',
    ),
  ),
  moment: moment,
  liveReadCheck: readCheck,
  liveSendCheck: sendCheck,
);

bool hasFailure(
  RevalidationDecision decision,
  RevalidationInput input,
  RevalidationReason reason, [
  String? field,
]) => decision.failures.any(
  (failure) => failure.input == input &&
      failure.reason == reason &&
      (field == null || failure.field == field),
);

void main() {
  test('fictional fresh claims yield only a read candidate before send time', () {
    final result = decide();
    expect(result.liveReadCandidate, isTrue);
    expect(result.liveSendCandidate, isFalse);
    expect(
      hasFailure(result, RevalidationInput.liveSend,
          RevalidationReason.sendSubmissionRecheckRequired),
      isTrue,
    );
  });

  test('separate current lineages permit hypothetical send-time candidate', () {
    final result = decide(moment: RevalidationMoment.sendSubmission);
    expect(result.liveReadCandidate, isTrue);
    expect(result.liveSendCandidate, isTrue);
    expect(result.failures, isEmpty);
  });

  test('read and send scope checks are independent', () {
    final result = decide(
      moment: RevalidationMoment.sendSubmission,
      readCheck: RevalidationCheck.failed,
    );
    expect(result.liveReadCandidate, isFalse);
    expect(result.liveSendCandidate, isTrue);
    expect(
      hasFailure(result, RevalidationInput.liveRead,
          RevalidationReason.liveReadCheckNotPassed),
      isTrue,
    );
    final noSend = decide(
      moment: RevalidationMoment.sendSubmission,
      sendCheck: RevalidationCheck.unknown,
    );
    expect(noSend.liveReadCandidate, isTrue);
    expect(noSend.liveSendCandidate, isFalse);
  });

  test('loading, unavailable, unknown and offline lack current evidence', () {
    final cases = <RevalidationCurrentness, RevalidationReason>{
      RevalidationCurrentness.loading: RevalidationReason.loading,
      RevalidationCurrentness.unavailable: RevalidationReason.unavailable,
      RevalidationCurrentness.unknown: RevalidationReason.unknownCurrentness,
    };
    for (final entry in cases.entries) {
      final result = decide(
        moment: RevalidationMoment.sendSubmission,
        connection: evidence(currentness: entry.key),
      );
      expect(result.liveReadCandidate, isFalse);
      expect(result.liveSendCandidate, isFalse);
      expect(
        hasFailure(result, RevalidationInput.connection, entry.value),
        isTrue,
      );
    }
    final offline = decide(
      moment: RevalidationMoment.sendSubmission,
      consent: evidence(currentness: RevalidationCurrentness.unavailable),
    );
    expect(offline.liveReadCandidate, isFalse);
    expect(offline.liveSendCandidate, isFalse);
  });

  test('synthetic and unknown origin never pass as authority', () {
    for (final origin in [
      RevalidationOrigin.syntheticDevelopment,
      RevalidationOrigin.unknown,
    ]) {
      final result = decide(
        moment: RevalidationMoment.sendSubmission,
        consent: evidence(origin: origin),
      );
      expect(result.liveReadCandidate, isFalse);
      expect(result.liveSendCandidate, isFalse);
      expect(
        hasFailure(
          result,
          RevalidationInput.messagingConsent,
          origin == RevalidationOrigin.syntheticDevelopment
              ? RevalidationReason.syntheticEvidence
              : RevalidationReason.unknownOrigin,
        ),
        isTrue,
      );
    }
  });

  test('stale, superseded and incomparable claims fail independently', () {
    final cases = <RevalidationCurrentness, RevalidationReason>{
      RevalidationCurrentness.stale: RevalidationReason.stale,
      RevalidationCurrentness.superseded: RevalidationReason.superseded,
      RevalidationCurrentness.incomparable: RevalidationReason.incomparable,
    };
    for (final entry in cases.entries) {
      final result = decide(
        moment: RevalidationMoment.sendSubmission,
        consent: evidence(currentness: entry.key),
      );
      expect(result.liveReadCandidate, isFalse);
      expect(result.liveSendCandidate, isFalse);
      expect(
        hasFailure(result, RevalidationInput.messagingConsent, entry.value),
        isTrue,
      );
    }
    final staleFreshness = decide(
      connection: evidence(freshness: RevalidationFreshness.stale),
    );
    expect(staleFreshness.liveReadCandidate, isFalse);
    expect(
      hasFailure(staleFreshness, RevalidationInput.connection,
          RevalidationReason.unknownFreshness, 'stale'),
      isTrue,
    );
  });

  test('revoked or incomplete consent and paused or closed connection deny', () {
    for (final state in [
      ConsentGateState.none,
      ConsentGateState.pending,
      ConsentGateState.declined,
      ConsentGateState.withdrawn,
      ConsentGateState.revoked,
    ]) {
      final result = decide(
        moment: RevalidationMoment.sendSubmission,
        consentState: state,
      );
      expect(result.liveReadCandidate, isFalse);
      expect(result.liveSendCandidate, isFalse);
      expect(
        hasFailure(result, RevalidationInput.messagingConsent,
            RevalidationReason.consentNotActive),
        isTrue,
      );
    }
    for (final state in [
      ProductConnectionState.paused,
      ProductConnectionState.closed,
    ]) {
      final result = decide(connectionState: state);
      expect(result.liveReadCandidate, isFalse);
      expect(
        hasFailure(result, RevalidationInput.connection,
            RevalidationReason.connectionNotActive),
        isTrue,
      );
    }
  });

  test('a new aggregate cannot reuse the old active consent claim', () {
    const newRequest = RevalidationRequest(
      subjectId: 'synthetic-actor-a',
      participantIds: ['synthetic-actor-a', 'synthetic-actor-b'],
      connectionAggregateId: 'synthetic-connection-2',
      contextId: 'synthetic-context-2',
      purpose: 'synthetic-conversation-live',
      audience: 'synthetic-bound-participants',
    );
    final result = decide(
      context: newRequest,
      connection: evidence(
        connectionAggregateId: 'synthetic-connection-2',
        contextId: 'synthetic-context-2',
      ),
      consent: evidence(),
    );
    expect(result.liveReadCandidate, isFalse);
    expect(
      hasFailure(result, RevalidationInput.messagingConsent,
          RevalidationReason.bindingMismatch, 'connectionAggregateId'),
      isTrue,
    );
  });

  test('each actor, participant, purpose, audience and context mismatch denies', () {
    final variants = <String, RevalidationEvidence>{
      'subjectId': evidence(subjectId: 'synthetic-actor-b'),
      'participantIds': evidence(participantIds: const [
        'synthetic-actor-a',
        'synthetic-actor-c',
      ]),
      'purpose': evidence(purpose: 'unrelated-purpose'),
      'audience': evidence(audience: 'public'),
      'contextId': evidence(contextId: 'old-context'),
    };
    for (final entry in variants.entries) {
      final result = decide(connection: entry.value);
      expect(result.liveReadCandidate, isFalse);
      expect(
        hasFailure(result, RevalidationInput.connection,
            RevalidationReason.bindingMismatch, entry.key),
        isTrue,
      );
    }
  });

  test('missing fields and an unpassed verification dimension fail closed', () {
    final missing = decide(
      consent: evidence(provenance: null, revision: null),
    );
    expect(missing.liveReadCandidate, isFalse);
    expect(
      hasFailure(missing, RevalidationInput.messagingConsent,
          RevalidationReason.missingEvidenceField, 'provenance'),
      isTrue,
    );
    expect(
      hasFailure(missing, RevalidationInput.messagingConsent,
          RevalidationReason.missingEvidenceField, 'revision'),
      isTrue,
    );
    const unverified = RevalidationChecks(
      identity: RevalidationCheck.passed,
      participants: RevalidationCheck.passed,
      ownerProvenance: RevalidationCheck.unknown,
      purposeAudience: RevalidationCheck.passed,
      revisionCurrentness: RevalidationCheck.passed,
      freshness: RevalidationCheck.passed,
      context: RevalidationCheck.passed,
    );
    final unknownProof = decide(connection: evidence(checks: unverified));
    expect(unknownProof.liveReadCandidate, isFalse);
    expect(
      hasFailure(unknownProof, RevalidationInput.connection,
          RevalidationReason.verificationNotPassed, 'ownerProvenance'),
      isTrue,
    );
  });

  test('incomplete request and duplicate participants cannot pass', () {
    const incomplete = RevalidationRequest(
      subjectId: 'synthetic-actor-a',
      participantIds: ['synthetic-actor-a', 'synthetic-actor-a'],
      connectionAggregateId: null,
      contextId: 'synthetic-context-1',
      purpose: 'synthetic-conversation-live',
      audience: 'synthetic-bound-participants',
    );
    final result = decide(context: incomplete);
    expect(result.liveReadCandidate, isFalse);
    expect(
      hasFailure(result, RevalidationInput.request,
          RevalidationReason.incompleteRequest, 'participantIds'),
      isTrue,
    );
  });

  test('old active arrival after current revocation cannot revive candidate', () {
    final currentRevoked = decide(consentState: ConsentGateState.revoked);
    final reorderedOldActive = decide(
      consent: evidence(currentness: RevalidationCurrentness.superseded),
    );
    expect(currentRevoked.liveReadCandidate, isFalse);
    expect(reorderedOldActive.liveReadCandidate, isFalse);
    expect(
      hasFailure(reorderedOldActive, RevalidationInput.messagingConsent,
          RevalidationReason.superseded),
      isTrue,
    );
  });

  test('send-time invalidation defeats an earlier read candidate', () {
    final before = decide();
    expect(before.liveReadCandidate, isTrue);
    final duringSend = decide(
      moment: RevalidationMoment.sendSubmission,
      consentState: ConsentGateState.revoked,
    );
    expect(duringSend.liveReadCandidate, isFalse);
    expect(duringSend.liveSendCandidate, isFalse);
  });
}
