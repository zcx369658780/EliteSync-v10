enum MatchRoundBusinessState {
  noRound('no_round'),
  scheduled('scheduled'),
  preparing('preparing'),
  running('running'),
  revealed('revealed'),
  noCandidate('no_candidate'),
  failed('failed'),
  closed('closed');

  const MatchRoundBusinessState(this.key);
  final String key;

  static MatchRoundBusinessState parse(String value) => values.firstWhere(
    (state) => state.key == value,
    orElse: () => throw FormatException('Unknown match-round state'),
  );
}

class MatchRoundConversationCapability {
  const MatchRoundConversationCapability({
    required this.canCreate,
    required this.canSend,
    required this.canWebSocket,
  });

  final bool canCreate;
  final bool canSend;
  final bool canWebSocket;
}

class MatchRoundResult {
  const MatchRoundResult({
    required this.matchId,
    required this.partnerId,
    required this.headline,
    this.partnerNickname,
  });

  final int matchId;
  final int partnerId;
  final String headline;
  final String? partnerNickname;
}

class MatchRoundProjection {
  const MatchRoundProjection({
    required this.state,
    required this.serverTime,
    required this.receivedAt,
    required this.contractVersion,
    required this.retryEligible,
    required this.userAction,
    required this.projectionVersion,
    required this.updatedAt,
    this.roundId,
    this.scheduledAt,
    this.nextTransitionAt,
    this.resultId,
    this.noCandidateReasonCode,
    this.failureCode,
    this.roundKey,
    this.stateVersion,
    this.scheduledFor,
    this.revealAt,
    this.reasonCode,
    this.nextActionCode,
    this.result,
    this.conversationCapability,
  });

  final MatchRoundBusinessState state;
  final DateTime serverTime;
  final DateTime receivedAt;
  final String contractVersion;
  final int? roundId;
  final DateTime? scheduledAt;
  final DateTime? nextTransitionAt;
  final int? resultId;
  final String? noCandidateReasonCode;
  final String? failureCode;
  final bool retryEligible;
  final String userAction;
  final int projectionVersion;
  final DateTime updatedAt;
  final String? roundKey;
  final int? stateVersion;
  final DateTime? scheduledFor;
  final DateTime? revealAt;
  final String? reasonCode;
  final String? nextActionCode;
  final MatchRoundResult? result;
  final MatchRoundConversationCapability? conversationCapability;

  Duration? remainingAt(DateTime localNow) {
    if (nextTransitionAt == null) return null;
    final estimatedServerNow = serverTime.add(localNow.difference(receivedAt));
    final remaining = nextTransitionAt!.difference(estimatedServerNow);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory MatchRoundProjection.fromJson(
    Map<String, dynamic> envelope, {
    DateTime? receivedAt,
  }) {
    final data = envelope['data'];
    final meta = envelope['meta'];
    if (data is! Map || meta is! Map) {
      throw const FormatException('Invalid match-round envelope');
    }
    DateTime? optionalTime(dynamic value) {
      final raw = value?.toString().trim() ?? '';
      return raw.isEmpty ? null : DateTime.tryParse(raw)?.toUtc();
    }

    final serverTime = optionalTime(data['server_now'] ?? data['server_time']);
    if (serverTime == null) throw const FormatException('Missing server_now');
    final updatedAt = optionalTime(data['updated_at']);
    if (updatedAt == null) throw const FormatException('Missing updated_at');
    final state = MatchRoundBusinessState.parse(
      data['state']?.toString() ?? '',
    );
    final resultRaw = data['result'];
    final capabilityRaw = data['conversation_capability'];
    MatchRoundResult? result;
    if (resultRaw is Map) {
      final matchId = (resultRaw['match_id'] as num?)?.toInt() ?? 0;
      final partnerId = (resultRaw['partner_id'] as num?)?.toInt() ?? 0;
      if (matchId <= 0 || partnerId <= 0) {
        throw const FormatException('Invalid revealed match identity');
      }
      result = MatchRoundResult(
        matchId: matchId,
        partnerId: partnerId,
        headline: resultRaw['headline']?.toString() ?? '',
        partnerNickname: resultRaw['partner_nickname']?.toString(),
      );
    }
    if (state == MatchRoundBusinessState.revealed && result == null) {
      throw const FormatException('Missing revealed match identity');
    }
    return MatchRoundProjection(
      state: state,
      serverTime: serverTime,
      receivedAt: (receivedAt ?? DateTime.now()).toUtc(),
      contractVersion: meta['contract_version']?.toString() ?? '',
      roundId: (data['round_id'] as num?)?.toInt(),
      scheduledAt: optionalTime(data['scheduled_at']),
      nextTransitionAt: optionalTime(data['next_transition_at']),
      resultId: (data['result_id'] as num?)?.toInt(),
      noCandidateReasonCode: data['no_candidate_reason_code']?.toString(),
      failureCode: data['failure_code']?.toString(),
      retryEligible: data['retry_eligible'] == true,
      userAction: data['user_action']?.toString() ?? 'wait',
      projectionVersion: (data['projection_version'] as num?)?.toInt() ?? 1,
      updatedAt: updatedAt,
      roundKey: data['round_key']?.toString(),
      stateVersion: (data['state_version'] as num?)?.toInt(),
      scheduledFor: optionalTime(data['scheduled_for']),
      revealAt: optionalTime(data['reveal_at']),
      reasonCode: data['reason_code']?.toString(),
      nextActionCode: data['next_action_code']?.toString(),
      result: result,
      conversationCapability: capabilityRaw is Map
          ? MatchRoundConversationCapability(
              canCreate: capabilityRaw['can_create'] == true,
              canSend: capabilityRaw['can_send'] == true,
              canWebSocket: capabilityRaw['can_ws'] == true,
            )
          : null,
    );
  }
}
