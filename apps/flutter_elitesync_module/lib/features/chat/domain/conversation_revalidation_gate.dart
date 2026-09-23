import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

/// Inputs are claims supplied by a future caller. This pure function cannot
/// authenticate a server, a participant, or the caller's verification results.
enum RevalidationOrigin { authoritativeClaim, syntheticDevelopment, unknown }

enum RevalidationCurrentness {
  current,
  loading,
  unavailable,
  unknown,
  stale,
  superseded,
  incomparable,
}

enum RevalidationFreshness { fresh, stale, unknown }

enum RevalidationCheck { passed, failed, unknown }

enum ConsentGateState { none, pending, active, declined, withdrawn, revoked }

enum RevalidationMoment { readRequest, sendSubmission }

enum RevalidationInput { request, connection, messagingConsent, liveRead, liveSend }

enum RevalidationReason {
  incompleteRequest,
  missingEvidenceField,
  syntheticEvidence,
  unknownOrigin,
  loading,
  unavailable,
  unknownCurrentness,
  stale,
  superseded,
  incomparable,
  unknownFreshness,
  verificationNotPassed,
  bindingMismatch,
  connectionNotActive,
  consentNotActive,
  liveReadCheckNotPassed,
  liveSendCheckNotPassed,
  sendSubmissionRecheckRequired,
}

class RevalidationFailure {
  const RevalidationFailure(this.input, this.reason, [this.field]);

  final RevalidationInput input;
  final RevalidationReason reason;
  final String? field;
}

/// Each check is a separate caller-provided verification receipt, not proof
/// produced by this evaluator. An unknown or failed dimension denies access.
class RevalidationChecks {
  const RevalidationChecks({
    required this.identity,
    required this.participants,
    required this.ownerProvenance,
    required this.purposeAudience,
    required this.revisionCurrentness,
    required this.freshness,
    required this.context,
  });

  final RevalidationCheck identity;
  final RevalidationCheck participants;
  final RevalidationCheck ownerProvenance;
  final RevalidationCheck purposeAudience;
  final RevalidationCheck revisionCurrentness;
  final RevalidationCheck freshness;
  final RevalidationCheck context;

  Iterable<String> get unpassedDimensions sync* {
    if (identity != RevalidationCheck.passed) yield 'identity';
    if (participants != RevalidationCheck.passed) yield 'participants';
    if (ownerProvenance != RevalidationCheck.passed) yield 'ownerProvenance';
    if (purposeAudience != RevalidationCheck.passed) yield 'purposeAudience';
    if (revisionCurrentness != RevalidationCheck.passed) {
      yield 'revisionCurrentness';
    }
    if (freshness != RevalidationCheck.passed) yield 'freshness';
    if (context != RevalidationCheck.passed) yield 'context';
  }
}

class RevalidationRequest {
  const RevalidationRequest({
    required this.subjectId,
    required this.participantIds,
    required this.connectionAggregateId,
    required this.contextId,
    required this.purpose,
    required this.audience,
  });

  final String? subjectId;
  final List<String>? participantIds;
  final String? connectionAggregateId;
  final String? contextId;
  final String? purpose;
  final String? audience;
}

class RevalidationEvidence {
  const RevalidationEvidence({
    required this.origin,
    required this.currentness,
    required this.freshness,
    required this.checks,
    required this.sourceOwner,
    required this.provenance,
    required this.subjectId,
    required this.participantIds,
    required this.connectionAggregateId,
    required this.contextId,
    required this.purpose,
    required this.audience,
    required this.lineageId,
    required this.revision,
  });

  final RevalidationOrigin origin;
  final RevalidationCurrentness currentness;
  final RevalidationFreshness freshness;
  final RevalidationChecks checks;
  final String? sourceOwner;
  final String? provenance;
  final String? subjectId;
  final List<String>? participantIds;
  final String? connectionAggregateId;
  final String? contextId;
  final String? purpose;
  final String? audience;
  final String? lineageId;
  /// Opaque source revision; this evaluator neither orders nor compares it.
  final String? revision;
}

class ConnectionRevalidationInput {
  const ConnectionRevalidationInput(this.state, this.evidence);

  final ProductConnectionState? state;
  final RevalidationEvidence evidence;
}

class ConsentRevalidationInput {
  const ConsentRevalidationInput(this.state, this.evidence);

  final ConsentGateState? state;
  final RevalidationEvidence evidence;
}

class RevalidationDecision {
  const RevalidationDecision({
    required this.liveReadCandidate,
    required this.liveSendCandidate,
    required this.failures,
  });

  /// These are hypothetical decisions over supplied claims, never real grants.
  final bool liveReadCandidate;
  final bool liveSendCandidate;
  final List<RevalidationFailure> failures;
}

abstract final class ConversationRevalidationGate {
  static RevalidationDecision evaluate({
    required RevalidationRequest request,
    required ConnectionRevalidationInput connection,
    required ConsentRevalidationInput messagingConsent,
    required RevalidationMoment moment,
    required RevalidationCheck liveReadCheck,
    required RevalidationCheck liveSendCheck,
  }) {
    final shared = <RevalidationFailure>[
      ..._checkRequest(request),
      ..._checkEvidence(
        request,
        connection.evidence,
        RevalidationInput.connection,
      ),
      ..._checkEvidence(
        request,
        messagingConsent.evidence,
        RevalidationInput.messagingConsent,
      ),
    ];
    if (connection.state != ProductConnectionState.active) {
      shared.add(const RevalidationFailure(
        RevalidationInput.connection,
        RevalidationReason.connectionNotActive,
      ));
    }
    if (messagingConsent.state != ConsentGateState.active) {
      shared.add(const RevalidationFailure(
        RevalidationInput.messagingConsent,
        RevalidationReason.consentNotActive,
      ));
    }

    final failures = <RevalidationFailure>[...shared];
    if (liveReadCheck != RevalidationCheck.passed) {
      failures.add(const RevalidationFailure(
        RevalidationInput.liveRead,
        RevalidationReason.liveReadCheckNotPassed,
      ));
    }
    if (moment != RevalidationMoment.sendSubmission) {
      failures.add(const RevalidationFailure(
        RevalidationInput.liveSend,
        RevalidationReason.sendSubmissionRecheckRequired,
      ));
    } else if (liveSendCheck != RevalidationCheck.passed) {
      failures.add(const RevalidationFailure(
        RevalidationInput.liveSend,
        RevalidationReason.liveSendCheckNotPassed,
      ));
    }
    return RevalidationDecision(
      liveReadCandidate: shared.isEmpty &&
          liveReadCheck == RevalidationCheck.passed,
      liveSendCandidate: shared.isEmpty &&
          moment == RevalidationMoment.sendSubmission &&
          liveSendCheck == RevalidationCheck.passed,
      failures: List.unmodifiable(failures),
    );
  }

  static List<RevalidationFailure> _checkRequest(RevalidationRequest request) {
    final failures = <RevalidationFailure>[];
    for (final entry in <String, String?>{
      'subjectId': request.subjectId,
      'connectionAggregateId': request.connectionAggregateId,
      'contextId': request.contextId,
      'purpose': request.purpose,
      'audience': request.audience,
    }.entries) {
      if (!_present(entry.value)) {
        failures.add(RevalidationFailure(
          RevalidationInput.request,
          RevalidationReason.incompleteRequest,
          entry.key,
        ));
      }
    }
    if (!_validParticipants(request.participantIds, request.subjectId)) {
      failures.add(const RevalidationFailure(
        RevalidationInput.request,
        RevalidationReason.incompleteRequest,
        'participantIds',
      ));
    }
    return failures;
  }

  static List<RevalidationFailure> _checkEvidence(
    RevalidationRequest request,
    RevalidationEvidence evidence,
    RevalidationInput input,
  ) {
    final failures = <RevalidationFailure>[];
    switch (evidence.origin) {
      case RevalidationOrigin.authoritativeClaim:
        break;
      case RevalidationOrigin.syntheticDevelopment:
        failures.add(RevalidationFailure(
          input,
          RevalidationReason.syntheticEvidence,
        ));
      case RevalidationOrigin.unknown:
        failures.add(RevalidationFailure(
          input,
          RevalidationReason.unknownOrigin,
        ));
    }
    final currentnessReason = switch (evidence.currentness) {
      RevalidationCurrentness.current => null,
      RevalidationCurrentness.loading => RevalidationReason.loading,
      RevalidationCurrentness.unavailable => RevalidationReason.unavailable,
      RevalidationCurrentness.unknown => RevalidationReason.unknownCurrentness,
      RevalidationCurrentness.stale => RevalidationReason.stale,
      RevalidationCurrentness.superseded => RevalidationReason.superseded,
      RevalidationCurrentness.incomparable => RevalidationReason.incomparable,
    };
    if (currentnessReason != null) {
      failures.add(RevalidationFailure(input, currentnessReason));
    }
    if (evidence.freshness != RevalidationFreshness.fresh) {
      failures.add(RevalidationFailure(
        input,
        RevalidationReason.unknownFreshness,
        evidence.freshness.name,
      ));
    }
    for (final field in <String, String?>{
      'sourceOwner': evidence.sourceOwner,
      'provenance': evidence.provenance,
      'subjectId': evidence.subjectId,
      'connectionAggregateId': evidence.connectionAggregateId,
      'contextId': evidence.contextId,
      'purpose': evidence.purpose,
      'audience': evidence.audience,
      'lineageId': evidence.lineageId,
    }.entries) {
      if (!_present(field.value)) {
        failures.add(RevalidationFailure(
          input,
          RevalidationReason.missingEvidenceField,
          field.key,
        ));
      }
    }
    if (!_present(evidence.revision)) {
      failures.add(RevalidationFailure(
        input,
        RevalidationReason.missingEvidenceField,
        'revision',
      ));
    }
    if (!_validParticipants(evidence.participantIds, evidence.subjectId)) {
      failures.add(RevalidationFailure(
        input,
        RevalidationReason.missingEvidenceField,
        'participantIds',
      ));
    }
    for (final dimension in evidence.checks.unpassedDimensions) {
      failures.add(RevalidationFailure(
        input,
        RevalidationReason.verificationNotPassed,
        dimension,
      ));
    }
    for (final entry in <String, bool>{
      'subjectId': evidence.subjectId == request.subjectId,
      'participantIds': _sameParticipants(
        evidence.participantIds,
        request.participantIds,
      ),
      'connectionAggregateId':
          evidence.connectionAggregateId == request.connectionAggregateId,
      'contextId': evidence.contextId == request.contextId,
      'purpose': evidence.purpose == request.purpose,
      'audience': evidence.audience == request.audience,
    }.entries) {
      if (!entry.value) {
        failures.add(RevalidationFailure(
          input,
          RevalidationReason.bindingMismatch,
          entry.key,
        ));
      }
    }
    return failures;
  }

  static bool _present(String? value) => value != null && value.trim().isNotEmpty;

  static bool _validParticipants(List<String>? ids, String? subjectId) {
    if (ids == null || ids.length != 2 || !_present(subjectId)) return false;
    final values = ids.toSet();
    return values.length == 2 &&
        ids.every(_present) &&
        values.contains(subjectId);
  }

  static bool _sameParticipants(List<String>? a, List<String>? b) =>
      a != null &&
      b != null &&
      a.length == b.length &&
      a.toSet().length == b.toSet().length &&
      a.toSet().containsAll(b);
}
