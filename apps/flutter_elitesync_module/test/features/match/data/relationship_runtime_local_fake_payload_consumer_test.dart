import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class LocalRelationshipRuntimeView {
  const LocalRelationshipRuntimeView({
    required this.state,
    required this.roundId,
    required this.fallbackCopyKey,
    required this.canReveal,
    required this.canOpenConversation,
    required this.candidateSummaryPresent,
    required this.candidatePresent,
    required this.candidateSourceLabels,
    required this.explanationBlocksPresent,
    required this.manualSendOnly,
    required this.localFeedbackOnly,
    required this.readModelOnly,
    required this.canSend,
    required this.runtimeWriteClaimed,
    required this.forbiddenCapabilityEnabled,
    this.reasonCode,
  });

  final String state;
  final String roundId;
  final String fallbackCopyKey;
  final bool canReveal;
  final bool canOpenConversation;
  final bool candidateSummaryPresent;
  final bool candidatePresent;
  final List<String> candidateSourceLabels;
  final bool explanationBlocksPresent;
  final bool manualSendOnly;
  final bool localFeedbackOnly;
  final bool readModelOnly;
  final bool canSend;
  final bool runtimeWriteClaimed;
  final bool forbiddenCapabilityEnabled;
  final String? reasonCode;
}

void main() {
  Map<String, dynamic> loadFixture() {
    final file = File(
      '../../services/backend-laravel/tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json',
    );
    expect(file.existsSync(), isTrue);
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  LocalRelationshipRuntimeView consumeState(Map<String, dynamic> state) {
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
    final candidate =
        state['candidate'] as Map<String, dynamic>? ??
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
    final forbiddenCapabilityEnabled = <String>[
      'can_auto_send',
      'can_upload_media',
      'can_persist_feedback_remote',
      'can_push_notification',
    ].any((key) => capabilities[key] == true);

    return LocalRelationshipRuntimeView(
      state: state['state'] as String,
      roundId: state['round_id'] as String,
      fallbackCopyKey: state['fallback_copy_key'] as String,
      canReveal: capabilities['can_reveal'] == true,
      canOpenConversation: capabilities['can_open_conversation'] == true,
      candidateSummaryPresent:
          state['candidate_summary'] is Map<String, dynamic>,
      candidatePresent: state['candidate'] is Map<String, dynamic>,
      candidateSourceLabels:
          (candidate['source_labels'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>(),
      explanationBlocksPresent:
          (state['explanation_blocks'] as List<dynamic>? ?? const <dynamic>[])
              .isNotEmpty,
      manualSendOnly: manualSendOnly,
      localFeedbackOnly: localFeedbackOnly,
      readModelOnly: conversation['read_model_only'] == true,
      canSend: conversation['can_send'] == true,
      runtimeWriteClaimed: claims.values.any((value) => value == true),
      forbiddenCapabilityEnabled: forbiddenCapabilityEnabled,
      reasonCode: state['reason_code'] as String?,
    );
  }

  List<LocalRelationshipRuntimeView> consumeFixture() {
    final fixture = loadFixture();
    return (fixture['states'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(consumeState)
        .toList(growable: false);
  }

  test('local fake payload consumer projects every contract state', () {
    final views = consumeFixture();

    expect(views.map((view) => view.state), <String>[
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
    expect(
      views.map((view) => view.roundId),
      everyElement(startsWith('fixture-round-')),
    );
    expect(
      views.map((view) => view.fallbackCopyKey),
      everyElement(startsWith('relationship.')),
    );
    expect(
      views.map((view) => view.runtimeWriteClaimed),
      everyElement(isFalse),
    );
    expect(
      views.map((view) => view.forbiddenCapabilityEnabled),
      everyElement(isFalse),
    );
  });

  test(
    'local fake payload consumer preserves manual-send and read-model bounds',
    () {
      final views = {for (final view in consumeFixture()) view.state: view};

      expect(views['reveal_available']!.canReveal, isTrue);
      expect(views['reveal_available']!.candidateSummaryPresent, isTrue);
      expect(views['reveal_available']!.candidatePresent, isFalse);

      expect(views['revealed']!.candidatePresent, isTrue);
      expect(views['revealed']!.explanationBlocksPresent, isTrue);
      expect(views['revealed']!.candidateSourceLabels, contains('test_only'));
      expect(
        views['revealed']!.candidateSourceLabels,
        contains('not_runtime_evidence'),
      );

      expect(views['opener_prepared']!.manualSendOnly, isTrue);
      expect(views['opener_prepared']!.canOpenConversation, isTrue);
      expect(views['opener_prepared']!.runtimeWriteClaimed, isFalse);

      expect(views['conversation_opened']!.readModelOnly, isTrue);
      expect(views['conversation_opened']!.canOpenConversation, isTrue);
      expect(views['conversation_opened']!.canSend, isFalse);
      expect(views['conversation_opened']!.manualSendOnly, isFalse);
    },
  );

  test(
    'local fake payload consumer preserves fallback and future-gate bounds',
    () {
      final views = {for (final view in consumeFixture()) view.state: view};
      final placeholders =
          loadFixture()['future_write_contract_placeholders']
              as Map<String, dynamic>;
      final mediaFuture =
          placeholders['media_upload_future'] as Map<String, dynamic>;
      final notificationPlaceholder =
          placeholders['notification_return_placeholder']
              as Map<String, dynamic>;

      expect(views['feedback_pending']!.localFeedbackOnly, isTrue);
      expect(views['feedback_recorded_local']!.localFeedbackOnly, isTrue);
      expect(
        views['feedback_recorded_remote_future']!.runtimeWriteClaimed,
        isFalse,
      );

      expect(views['no_candidate']!.reasonCode, 'no_safe_candidate');
      expect(views['paused_or_unavailable']!.reasonCode, 'service_unavailable');
      expect(views['auth_session_failure']!.reasonCode, 'session_required');
      expect(mediaFuture['runtime_write_allowed'], isFalse);
      expect(notificationPlaceholder['read_state_write_allowed'], isFalse);
      expect(notificationPlaceholder['push_delivery_claimed'], isFalse);
    },
  );
}
