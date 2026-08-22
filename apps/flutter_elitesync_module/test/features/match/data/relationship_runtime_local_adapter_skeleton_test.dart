import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class LocalRuntimeAdapterView {
  const LocalRuntimeAdapterView({
    required this.state,
    required this.roundId,
    required this.fallbackCopyKey,
    required this.evidenceLevel,
    required this.hasEndpointDependency,
    required this.hasDbDependency,
    required this.hasProductionRuntimeImport,
    required this.manualSendOnly,
    required this.autoSendAllowed,
    required this.localFeedbackOnly,
    required this.remoteFeedbackInactive,
    required this.notificationFutureInactive,
    required this.readModelOnly,
    required this.canSend,
    required this.scoringMutationAllowed,
    required this.profileTruthMutationAllowed,
    required this.astroTruthMutationAllowed,
    this.reasonCode,
    this.retryable,
  });

  final String state;
  final String roundId;
  final String fallbackCopyKey;
  final String evidenceLevel;
  final bool hasEndpointDependency;
  final bool hasDbDependency;
  final bool hasProductionRuntimeImport;
  final bool manualSendOnly;
  final bool autoSendAllowed;
  final bool localFeedbackOnly;
  final bool remoteFeedbackInactive;
  final bool notificationFutureInactive;
  final bool readModelOnly;
  final bool canSend;
  final bool scoringMutationAllowed;
  final bool profileTruthMutationAllowed;
  final bool astroTruthMutationAllowed;
  final String? reasonCode;
  final bool? retryable;
}

class LocalRuntimeAdapterRefusal {
  const LocalRuntimeAdapterRefusal({
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

class RelationshipRuntimeLocalAdapterSkeleton {
  static const evidenceLevel =
      'L2_LOCAL_FAKE_PAYLOAD_CONSUMER_ADAPTER_SKELETON';

  static const allowedStates = <String>[
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

  List<LocalRuntimeAdapterView> projectFixture(Map<String, dynamic> fixture) {
    if (fixture['contract_version'] !=
        'relationship_runtime_test_contract_v1') {
      throw const FormatException('Unsupported relationship runtime fixture');
    }

    final states = (fixture['states'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return states.map(projectState).toList(growable: false);
  }

  LocalRuntimeAdapterView projectState(Map<String, dynamic> state) {
    for (final key in <String>[
      'id',
      'state',
      'round_id',
      'fallback_copy_key',
      'capabilities',
      'runtime_claims',
    ]) {
      if (!state.containsKey(key)) {
        throw FormatException('Missing required fixture key: $key');
      }
    }

    final stateName = state['state'] as String;
    if (!allowedStates.contains(stateName)) {
      throw FormatException('Unsupported fixture state: $stateName');
    }

    final capabilities = state['capabilities'] as Map<String, dynamic>;
    final claims = state['runtime_claims'] as Map<String, dynamic>;
    final openerSuggestions =
        (state['opener_suggestions'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();
    final feedback =
        state['feedback'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final conversation =
        state['conversation'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    final manualSendOnly = openerSuggestions.any(
      (item) =>
          item['manual_send_allowed'] == true &&
          item['auto_send_allowed'] == false,
    );

    final localFeedbackOnly =
        feedback['local_only'] == true ||
        (feedback['can_record_local'] == true &&
            feedback['can_record_remote'] == false);

    final remoteFeedbackInactive =
        capabilities['can_persist_feedback_remote'] == false &&
        claims['feedback_persisted_remote'] == false &&
        feedback['remote_record_id'] != true;

    final notificationFutureInactive =
        capabilities['can_push_notification'] == false &&
        claims['notification_pushed'] == false;

    return LocalRuntimeAdapterView(
      state: stateName,
      roundId: state['round_id'] as String,
      fallbackCopyKey: state['fallback_copy_key'] as String,
      evidenceLevel: evidenceLevel,
      hasEndpointDependency: false,
      hasDbDependency: false,
      hasProductionRuntimeImport: false,
      manualSendOnly: manualSendOnly,
      autoSendAllowed: openerSuggestions.any(
        (item) => item['auto_send_allowed'] == true,
      ),
      localFeedbackOnly: localFeedbackOnly,
      remoteFeedbackInactive: remoteFeedbackInactive,
      notificationFutureInactive: notificationFutureInactive,
      readModelOnly: conversation['read_model_only'] == true,
      canSend: conversation['can_send'] == true,
      scoringMutationAllowed: false,
      profileTruthMutationAllowed: false,
      astroTruthMutationAllowed: false,
      reasonCode: state['reason_code'] as String?,
      retryable: state['retryable'] as bool?,
    );
  }

  LocalRuntimeAdapterRefusal refuseForbiddenAction(String action) {
    return LocalRuntimeAdapterRefusal(
      action: action,
      refused: true,
      executed: false,
      reason: 'not_authorized_in_current_gate',
      category: _categoryFor(action),
    );
  }

  String _categoryFor(String action) {
    if (action.contains('endpoint')) {
      return 'endpoint_forbidden';
    }
    if (action.contains('db') || action.contains('migration')) {
      return 'db_forbidden';
    }
    if (action.contains('release') || action.contains('apk')) {
      return 'release_forbidden';
    }
    if (action.contains('scoring') ||
        action.contains('profile_truth') ||
        action.contains('astro_truth')) {
      return 'truth_mutation_forbidden';
    }
    return 'write_forbidden';
  }
}

void main() {
  Map<String, dynamic> loadFixture() {
    final file = File(
      '../../services/backend-laravel/tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json',
    );
    expect(file.existsSync(), isTrue);
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  final adapter = RelationshipRuntimeLocalAdapterSkeleton();

  test(
    'local adapter skeleton projects every fixture state without runtime dependencies',
    () {
      final views = adapter.projectFixture(loadFixture());

      expect(
        views.map((view) => view.state),
        RelationshipRuntimeLocalAdapterSkeleton.allowedStates,
      );
      expect(
        views.map((view) => view.evidenceLevel),
        everyElement(RelationshipRuntimeLocalAdapterSkeleton.evidenceLevel),
      );
      expect(
        views.map((view) => view.roundId),
        everyElement(startsWith('fixture-round-')),
      );
      expect(
        views.map((view) => view.fallbackCopyKey),
        everyElement(startsWith('relationship.')),
      );
      expect(
        views.map((view) => view.hasEndpointDependency),
        everyElement(isFalse),
      );
      expect(views.map((view) => view.hasDbDependency), everyElement(isFalse));
      expect(
        views.map((view) => view.hasProductionRuntimeImport),
        everyElement(isFalse),
      );
    },
  );

  test(
    'local adapter skeleton preserves manual send and future write boundaries',
    () {
      final views = {
        for (final view in adapter.projectFixture(loadFixture()))
          view.state: view,
      };

      expect(views['opener_prepared']!.manualSendOnly, isTrue);
      expect(views['opener_prepared']!.autoSendAllowed, isFalse);

      expect(views['conversation_opened']!.readModelOnly, isTrue);
      expect(views['conversation_opened']!.canSend, isFalse);

      expect(views['feedback_pending']!.localFeedbackOnly, isTrue);
      expect(views['feedback_pending']!.remoteFeedbackInactive, isTrue);
      expect(views['feedback_recorded_local']!.localFeedbackOnly, isTrue);
      expect(
        views['feedback_recorded_remote_future']!.remoteFeedbackInactive,
        isTrue,
      );

      expect(
        views.values.map((view) => view.notificationFutureInactive),
        everyElement(isTrue),
      );
    },
  );

  test(
    'local adapter skeleton refuses forbidden runtime actions without payload mutation',
    () {
      final fixture = loadFixture();
      final before = jsonEncode(fixture);
      final actions = (fixture['forbidden_runtime_actions'] as List<dynamic>)
          .cast<String>();

      for (final action in actions) {
        final refusal = adapter.refuseForbiddenAction(action);

        expect(refusal.action, action);
        expect(refusal.refused, isTrue);
        expect(refusal.executed, isFalse);
        expect(refusal.reason, 'not_authorized_in_current_gate');
        expect(refusal.category, isNotEmpty);
      }

      expect(jsonEncode(fixture), before);
    },
  );

  test(
    'local adapter skeleton keeps fallback states and truth mutations disabled',
    () {
      final views = {
        for (final view in adapter.projectFixture(loadFixture()))
          view.state: view,
      };

      expect(views['no_candidate']!.reasonCode, 'no_safe_candidate');
      expect(views['paused_or_unavailable']!.reasonCode, 'service_unavailable');
      expect(views['paused_or_unavailable']!.retryable, isTrue);
      expect(views['auth_session_failure']!.reasonCode, 'session_required');

      expect(
        views.values.map((view) => view.scoringMutationAllowed),
        everyElement(isFalse),
      );
      expect(
        views.values.map((view) => view.profileTruthMutationAllowed),
        everyElement(isFalse),
      );
      expect(
        views.values.map((view) => view.astroTruthMutationAllowed),
        everyElement(isFalse),
      );
    },
  );
}
