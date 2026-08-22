import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/features/match/data/local_runtime_adapter/relationship_runtime_local_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> loadFixture() {
    final file = File(
      '../../services/backend-laravel/tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json',
    );
    expect(file.existsSync(), isTrue);
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  final adapter = RelationshipRuntimeLocalAdapter();

  test(
    'projects every local fixture state through the dormant source skeleton',
    () {
      final results = adapter.projectFixture(loadFixture());

      expect(
        results.map((result) => result.state),
        RelationshipRuntimeLocalAdapter.supportedStates,
      );
      expect(
        results.map((result) => result.evidenceLevel),
        everyElement(RelationshipRuntimeLocalAdapter.evidenceLevel),
      );
      expect(
        results.map((result) => result.roundId),
        everyElement(startsWith('fixture-round-')),
      );
      expect(
        results.map((result) => result.fallbackCopyKey),
        everyElement(startsWith('relationship.')),
      );
      expect(
        results.map((result) => result.boundaries.hasEndpointDependency),
        everyElement(isFalse),
      );
      expect(
        results.map((result) => result.boundaries.hasDatabaseDependency),
        everyElement(isFalse),
      );
      expect(
        results.map((result) => result.boundaries.hasProductionRuntimeImport),
        everyElement(isFalse),
      );
    },
  );

  test('preserves reveal, manual-send, feedback, and notification guards', () {
    final results = {
      for (final result in adapter.projectFixture(loadFixture()))
        result.state: result,
    };

    expect(results['reveal_available']!.candidateSummaryAvailable, isTrue);
    expect(results['reveal_available']!.candidateDetailAvailable, isFalse);
    expect(results['reveal_available']!.boundaries.canRevealLocally, isTrue);

    expect(results['revealed']!.candidateDetailAvailable, isTrue);
    expect(results['revealed']!.explanationBlocksAvailable, isTrue);

    expect(results['opener_prepared']!.boundaries.manualSendOnly, isTrue);
    expect(
      results['opener_prepared']!.boundaries.automaticSendAllowed,
      isFalse,
    );
    expect(
      results['opener_prepared']!.boundaries.canOpenConversationLocally,
      isTrue,
    );

    expect(results['conversation_opened']!.boundaries.readModelOnly, isTrue);
    expect(results['conversation_opened']!.boundaries.canSend, isFalse);

    expect(results['feedback_pending']!.boundaries.localFeedbackOnly, isTrue);
    expect(
      results['feedback_pending']!.boundaries.remoteFeedbackInactive,
      isTrue,
    );
    expect(
      results['feedback_recorded_local']!.boundaries.localFeedbackOnly,
      isTrue,
    );
    expect(
      results['feedback_recorded_remote_future']!
          .boundaries
          .remoteFeedbackInactive,
      isTrue,
    );
    expect(
      results.values.map(
        (result) => result.boundaries.notificationPushInactive,
      ),
      everyElement(isTrue),
    );
  });

  test('keeps fallback states and truth mutations disabled', () {
    final results = {
      for (final result in adapter.projectFixture(loadFixture()))
        result.state: result,
    };

    expect(results['no_candidate']!.reasonCode, 'no_safe_candidate');
    expect(results['paused_or_unavailable']!.reasonCode, 'service_unavailable');
    expect(results['paused_or_unavailable']!.retryable, isTrue);
    expect(results['auth_session_failure']!.reasonCode, 'session_required');

    expect(
      results.values.map((result) => result.boundaries.scoringMutationAllowed),
      everyElement(isFalse),
    );
    expect(
      results.values.map(
        (result) => result.boundaries.profileTruthMutationAllowed,
      ),
      everyElement(isFalse),
    );
    expect(
      results.values.map(
        (result) => result.boundaries.astroTruthMutationAllowed,
      ),
      everyElement(isFalse),
    );
  });

  test('refuses forbidden actions without mutating the local fixture', () {
    final fixture = loadFixture();
    final before = jsonEncode(fixture);
    final actions = (fixture['forbidden_runtime_actions'] as List<dynamic>)
        .cast<String>();

    for (final action in actions) {
      final refusal = adapter.refuseForbiddenAction(action);

      expect(refusal.action, action);
      expect(refusal.refused, isTrue);
      expect(refusal.executed, isFalse);
      expect(refusal.reason, RelationshipRuntimeLocalAdapter.refusalReason);
      expect(refusal.category, isNotEmpty);
    }

    expect(jsonEncode(fixture), before);
  });

  test('rejects malformed or mutation-like payloads safely', () {
    expect(
      () => adapter.projectFixture(<String, dynamic>{
        'contract_version': RelationshipRuntimeLocalAdapter.contractVersion,
        'states': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'bad',
            'state': 'mutate_profile_truth',
            'round_id': 'fixture-round-bad',
            'fallback_copy_key': 'relationship.bad',
            'capabilities': <String, dynamic>{},
            'runtime_claims': <String, dynamic>{},
          },
        ],
      }),
      throwsFormatException,
    );

    expect(
      () => adapter.projectState(<String, dynamic>{
        'id': 'missing-capabilities',
        'state': 'waiting',
        'round_id': 'fixture-round-waiting',
        'fallback_copy_key': 'relationship.waiting',
        'runtime_claims': <String, dynamic>{},
      }),
      throwsFormatException,
    );
  });

  test(
    'fails closed when supported payload states claim write capabilities',
    () {
      final fixture = loadFixture();
      final state = Map<String, dynamic>.from(
        (fixture['states'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .firstWhere((item) => item['state'] == 'conversation_opened'),
      );
      state['capabilities'] = <String, dynamic>{
        ...state['capabilities'] as Map<String, dynamic>,
        'can_auto_send': true,
        'can_persist_feedback_remote': true,
        'can_push_notification': true,
      };
      state['runtime_claims'] = <String, dynamic>{
        ...state['runtime_claims'] as Map<String, dynamic>,
        'message_sent': true,
        'feedback_persisted_remote': true,
        'notification_pushed': true,
      };
      state['opener_suggestions'] = <Map<String, dynamic>>[
        <String, dynamic>{
          'text': 'Unsafe automatic send fixture mutation.',
          'manual_send_allowed': true,
          'auto_send_allowed': true,
        },
      ];
      state['conversation'] = <String, dynamic>{
        'read_model_only': true,
        'can_send': true,
      };
      state['feedback'] = <String, dynamic>{
        'can_record_local': true,
        'can_record_remote': true,
        'remote_record_id': 'unsafe-remote-id',
      };

      final result = adapter.projectState(state);

      expect(result.boundaries.automaticSendAllowed, isFalse);
      expect(result.boundaries.canSend, isFalse);
      expect(result.boundaries.remoteFeedbackInactive, isTrue);
      expect(result.boundaries.notificationPushInactive, isTrue);
      expect(result.boundaries.scoringMutationAllowed, isFalse);
      expect(result.boundaries.profileTruthMutationAllowed, isFalse);
      expect(result.boundaries.astroTruthMutationAllowed, isFalse);
    },
  );
}
