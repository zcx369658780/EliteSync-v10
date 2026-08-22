class RelationshipRuntimeLocalAdapter {
  static const contractVersion = 'relationship_runtime_test_contract_v1';
  static const evidenceLevel = 'L2_LOCAL_SOURCE_SKELETON_ONLY';
  static const refusalReason = 'not_authorized_in_current_gate';

  static const supportedStates = <String>[
    'not_started',
    'preparing',
    'waiting',
    'reveal_available',
    'revealed',
    'opener_prepared',
    'conversation_opened',
    'feedback_pending',
    'feedback_recorded_local',
    'feedback_recorded_remote_future',
    'next_round_pending',
    'no_candidate',
    'paused_or_unavailable',
    'auth_session_failure',
  ];

  List<RelationshipRuntimeLocalAdapterResult> projectFixture(
    Map<String, dynamic> fixture,
  ) {
    if (fixture['contract_version'] != contractVersion) {
      throw const FormatException(
        'Unsupported relationship runtime contract version',
      );
    }

    final states = fixture['states'];
    if (states is! List) {
      throw const FormatException('Missing relationship runtime states');
    }

    return states
        .map((state) {
          if (state is! Map<String, dynamic>) {
            throw const FormatException('Invalid relationship runtime state');
          }
          return projectState(state);
        })
        .toList(growable: false);
  }

  RelationshipRuntimeLocalAdapterResult projectState(
    Map<String, dynamic> payload,
  ) {
    for (final key in <String>[
      'id',
      'state',
      'round_id',
      'fallback_copy_key',
      'capabilities',
      'runtime_claims',
    ]) {
      if (!payload.containsKey(key)) {
        throw FormatException(
          'Missing required relationship runtime key: $key',
        );
      }
    }

    final state = payload['state'];
    if (state is! String || !supportedStates.contains(state)) {
      throw FormatException('Unsupported relationship runtime state: $state');
    }

    final capabilities = _mapValue(payload, 'capabilities');
    _mapValue(payload, 'runtime_claims');
    final openerSuggestions = _mapList(payload['opener_suggestions']);
    final feedback = _optionalMapValue(payload, 'feedback');
    final conversation = _optionalMapValue(payload, 'conversation');

    return RelationshipRuntimeLocalAdapterResult(
      state: state,
      roundId: _stringValue(payload, 'round_id'),
      fallbackCopyKey: _stringValue(payload, 'fallback_copy_key'),
      evidenceLevel: evidenceLevel,
      candidateSummaryAvailable: payload['candidate_summary'] is Map,
      candidateDetailAvailable: payload['candidate'] is Map,
      explanationBlocksAvailable: _mapList(
        payload['explanation_blocks'],
      ).isNotEmpty,
      reasonCode: payload['reason_code'] as String?,
      retryable: payload['retryable'] as bool?,
      boundaries: RelationshipRuntimeLocalAdapterBoundaries(
        hasEndpointDependency: false,
        hasDatabaseDependency: false,
        hasProductionRuntimeImport: false,
        canRevealLocally: capabilities['can_reveal'] == true,
        canOpenConversationLocally:
            capabilities['can_open_conversation'] == true,
        manualSendOnly: openerSuggestions.any(
          (item) =>
              item['manual_send_allowed'] == true &&
              item['auto_send_allowed'] == false,
        ),
        automaticSendAllowed: false,
        localFeedbackOnly:
            feedback['local_only'] == true ||
            (feedback['can_record_local'] == true &&
                feedback['can_record_remote'] == false),
        remoteFeedbackInactive: true,
        notificationPushInactive: true,
        readModelOnly: conversation['read_model_only'] == true,
        canSend: false,
        scoringMutationAllowed: false,
        profileTruthMutationAllowed: false,
        astroTruthMutationAllowed: false,
      ),
    );
  }

  RelationshipRuntimeLocalAdapterRefusal refuseForbiddenAction(String action) {
    return RelationshipRuntimeLocalAdapterRefusal(
      action: action,
      refused: true,
      executed: false,
      reason: refusalReason,
      category: _categoryFor(action),
    );
  }

  static Map<String, dynamic> _mapValue(
    Map<String, dynamic> payload,
    String key,
  ) {
    final value = payload[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('Expected map relationship runtime key: $key');
    }
    return value;
  }

  static Map<String, dynamic> _optionalMapValue(
    Map<String, dynamic> payload,
    String key,
  ) {
    final value = payload[key];
    if (value == null) {
      return const <String, dynamic>{};
    }
    if (value is! Map<String, dynamic>) {
      throw FormatException('Expected optional map runtime key: $key');
    }
    return value;
  }

  static List<Map<String, dynamic>> _mapList(Object? value) {
    if (value == null) {
      return const <Map<String, dynamic>>[];
    }
    if (value is! List) {
      throw const FormatException('Expected relationship runtime list');
    }
    return value
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'Expected relationship runtime map item',
            );
          }
          return item;
        })
        .toList(growable: false);
  }

  static String _stringValue(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is! String) {
      throw FormatException('Expected string relationship runtime key: $key');
    }
    return value;
  }

  static String _categoryFor(String action) {
    if (action.contains('endpoint')) {
      return 'endpoint_forbidden';
    }
    if (action.contains('db') || action.contains('migration')) {
      return 'database_forbidden';
    }
    if (action.contains('chat') || action.contains('message')) {
      return 'chat_send_forbidden';
    }
    if (action.contains('media')) {
      return 'media_upload_forbidden';
    }
    if (action.contains('feedback')) {
      return 'feedback_remote_persistence_forbidden';
    }
    if (action.contains('notification')) {
      return 'notification_write_forbidden';
    }
    if (action.contains('scoring') ||
        action.contains('profile_truth') ||
        action.contains('astro_truth')) {
      return 'truth_mutation_forbidden';
    }
    if (action.contains('release') || action.contains('apk')) {
      return 'release_forbidden';
    }
    return 'write_forbidden';
  }
}

class RelationshipRuntimeLocalAdapterResult {
  const RelationshipRuntimeLocalAdapterResult({
    required this.state,
    required this.roundId,
    required this.fallbackCopyKey,
    required this.evidenceLevel,
    required this.candidateSummaryAvailable,
    required this.candidateDetailAvailable,
    required this.explanationBlocksAvailable,
    required this.boundaries,
    this.reasonCode,
    this.retryable,
  });

  final String state;
  final String roundId;
  final String fallbackCopyKey;
  final String evidenceLevel;
  final bool candidateSummaryAvailable;
  final bool candidateDetailAvailable;
  final bool explanationBlocksAvailable;
  final RelationshipRuntimeLocalAdapterBoundaries boundaries;
  final String? reasonCode;
  final bool? retryable;
}

class RelationshipRuntimeLocalAdapterBoundaries {
  const RelationshipRuntimeLocalAdapterBoundaries({
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
}

class RelationshipRuntimeLocalAdapterRefusal {
  const RelationshipRuntimeLocalAdapterRefusal({
    required this.action,
    required this.refused,
    required this.executed,
    required this.reason,
    required this.category,
  });

  final String action;
  final bool refused;
  final bool executed;
  final String reason;
  final String category;
}
