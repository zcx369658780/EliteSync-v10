import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> loadFixture() {
    final file = File(
      '../../services/backend-laravel/tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json',
    );
    expect(file.existsSync(), isTrue);
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('relationship runtime fixture exposes Flutter-safe expectation keys', () {
    final fixture = loadFixture();

    expect(fixture['contract_version'], 'relationship_runtime_test_contract_v1');
    expect(fixture['evidence_level'], 'L1_TEST_ONLY_FIXTURE_SKELETON');

    final expectations =
        fixture['flutter_expectations'] as Map<String, dynamic>;
    expect(expectations['match_result_keys'], containsAll(<String>[
      'status',
      'headline',
      'score',
      'tags',
      'highlights',
      'match_id',
      'partner_id',
      'partner_nickname',
    ]));
    expect(expectations['match_detail_keys'], containsAll(<String>[
      'reasons',
      'weights',
      'module_explanations',
      'explanation_blocks',
      'compatibility_sections',
      'reason_glossary',
      'evidence_strength_summary',
    ]));
    expect(expectations['manual_send_boundary_key'], 'manual_send_allowed');
    expect(expectations['local_feedback_boundary_key'], 'local_only');
  });

  test('relationship runtime fixture keeps write-side runtime disabled', () {
    final fixture = loadFixture();

    final topLevelClaims =
        fixture['runtime_claims'] as Map<String, dynamic>;
    expect(topLevelClaims.values, everyElement(isFalse));

    final states = fixture['states'] as List<dynamic>;
    expect(states.map((state) => state['state']), <String>[
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
    ]);

    for (final item in states) {
      final state = item as Map<String, dynamic>;
      final capabilities = state['capabilities'] as Map<String, dynamic>;
      final claims = state['runtime_claims'] as Map<String, dynamic>;

      expect(capabilities['can_auto_send'], isFalse);
      expect(capabilities['can_upload_media'], isFalse);
      expect(capabilities['can_persist_feedback_remote'], isFalse);
      expect(capabilities['can_push_notification'], isFalse);
      expect(claims.values, everyElement(isFalse));
      expect(state['fallback_copy_key'], startsWith('relationship.'));
    }
  });

  test('relationship runtime fixture preserves manual-send and feedback bounds', () {
    final fixture = loadFixture();
    final states = {
      for (final item in fixture['states'] as List<dynamic>)
        item['state'] as String: item as Map<String, dynamic>,
    };

    final opener = states['opener_prepared']!;
    final openerSuggestion =
        (opener['opener_suggestions'] as List<dynamic>).first
            as Map<String, dynamic>;
    expect(openerSuggestion['manual_send_allowed'], isTrue);
    expect(openerSuggestion['auto_send_allowed'], isFalse);

    final localFeedback =
        states['feedback_recorded_local']!['feedback'] as Map<String, dynamic>;
    expect(localFeedback['local_only'], isTrue);
    expect(localFeedback['sync_state'], 'not_authorized_for_remote');

    final remoteFuture =
        states['feedback_recorded_remote_future']!['feedback']
            as Map<String, dynamic>;
    expect(remoteFuture['remote_record_id'], isNull);
    expect(remoteFuture['sync_state'], 'future_gate_not_active');
  });
}
