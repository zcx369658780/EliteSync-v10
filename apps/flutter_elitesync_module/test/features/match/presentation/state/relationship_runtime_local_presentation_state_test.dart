import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/features/match/data/local_runtime_adapter/relationship_runtime_local_adapter.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/relationship_runtime_local_adapter_provider.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/relationship_runtime_local_presentation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixturePayload() {
  final fixture = File(
    '../../services/backend-laravel/tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json',
  );
  return jsonDecode(fixture.readAsStringSync()) as Map<String, dynamic>;
}

ProviderContainer _containerWithPayload(Map<String, dynamic>? payload) {
  return ProviderContainer(
    overrides: [
      relationshipRuntimeLocalPayloadProvider.overrideWithValue(payload),
    ],
  );
}

void main() {
  test('defaults to inactive presentation state without local payload', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(
      relationshipRuntimeLocalPresentationStateProvider,
    );

    expect(state.isInactive, isTrue);
    expect(state.entries, isEmpty);
    expect(state.evidenceLevel, RelationshipRuntimeLocalAdapter.evidenceLevel);
    expect(state.guards.protectedRuntimeDisabled, isTrue);
  });

  test('maps local projected results to presentation-safe phases', () {
    final container = _containerWithPayload(_fixturePayload());
    addTearDown(container.dispose);

    final state = container.read(
      relationshipRuntimeLocalPresentationStateProvider,
    );
    final phases = state.entries.map((entry) => entry.phase).toSet();

    expect(
      state.entries,
      hasLength(RelationshipRuntimeLocalAdapter.supportedStates.length),
    );
    expect(state.phase, RelationshipRuntimeLocalPresentationPhase.preparing);
    expect(phases, contains(RelationshipRuntimeLocalPresentationPhase.waiting));
    expect(
      phases,
      contains(RelationshipRuntimeLocalPresentationPhase.revealAvailable),
    );
    expect(
      phases,
      contains(RelationshipRuntimeLocalPresentationPhase.noCandidate),
    );
    expect(
      phases,
      contains(RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable),
    );
    expect(
      state.entries.map((entry) => entry.evidenceLevel),
      everyElement(RelationshipRuntimeLocalAdapter.evidenceLevel),
    );
  });

  test('preserves candidate availability as read-only presentation flags', () {
    final container = _containerWithPayload(_fixturePayload());
    addTearDown(container.dispose);

    final state = container.read(
      relationshipRuntimeLocalPresentationStateProvider,
    );
    final revealAvailable = state.entries.singleWhere(
      (entry) => entry.runtimeState == 'reveal_available',
    );
    final revealed = state.entries.singleWhere(
      (entry) => entry.runtimeState == 'revealed',
    );

    expect(revealAvailable.candidateSummaryAvailable, isTrue);
    expect(revealAvailable.candidateDetailAvailable, isFalse);
    expect(revealed.candidateDetailAvailable, isTrue);
    expect(revealed.explanationBlocksAvailable, isTrue);
  });

  test(
    'aggregates local reveal open flags without enabling runtime actions',
    () {
      final container = _containerWithPayload(_fixturePayload());
      addTearDown(container.dispose);

      final state = container.read(
        relationshipRuntimeLocalPresentationStateProvider,
      );
      final revealAvailable = state.entries.singleWhere(
        (entry) => entry.runtimeState == 'reveal_available',
      );
      final conversationOpened = state.entries.singleWhere(
        (entry) => entry.runtimeState == 'conversation_opened',
      );

      expect(revealAvailable.guards.canRevealLocally, isTrue);
      expect(conversationOpened.guards.canOpenConversationLocally, isTrue);
      expect(state.guards.canRevealLocally, isTrue);
      expect(state.guards.canOpenConversationLocally, isTrue);
      expect(state.guards.automaticSendAllowed, isFalse);
      expect(state.guards.canSend, isFalse);
      expect(state.guards.remoteFeedbackInactive, isTrue);
      expect(state.guards.notificationPushInactive, isTrue);
      expect(state.guards.protectedRuntimeDisabled, isTrue);
    },
  );

  test('malformed local payload fails closed to inactive state', () {
    final container = _containerWithPayload({
      'contract_version': RelationshipRuntimeLocalAdapter.contractVersion,
      'states': <Map<String, dynamic>>[
        {'id': 'malformed-state'},
      ],
    });
    addTearDown(container.dispose);

    final state = container.read(
      relationshipRuntimeLocalPresentationStateProvider,
    );

    expect(state.isInactive, isTrue);
    expect(state.entries, isEmpty);
    expect(state.guards.protectedRuntimeDisabled, isTrue);
  });

  test('preserves manual send feedback notification and truth guards', () {
    final container = _containerWithPayload(_fixturePayload());
    addTearDown(container.dispose);

    final state = container.read(
      relationshipRuntimeLocalPresentationStateProvider,
    );
    final openerPrepared = state.entries.singleWhere(
      (entry) => entry.runtimeState == 'opener_prepared',
    );

    expect(openerPrepared.guards.manualSendOnly, isTrue);
    expect(state.guards.automaticSendAllowed, isFalse);
    expect(state.guards.canSend, isFalse);
    expect(state.guards.remoteFeedbackInactive, isTrue);
    expect(state.guards.notificationPushInactive, isTrue);
    expect(state.guards.scoringMutationAllowed, isFalse);
    expect(state.guards.profileTruthMutationAllowed, isFalse);
    expect(state.guards.astroTruthMutationAllowed, isFalse);
    expect(state.guards.protectedRuntimeDisabled, isTrue);
  });

  test(
    'presentation state source imports only local provider adapter and Riverpod',
    () {
      final source = File(
        'lib/features/match/presentation/state/'
        'relationship_runtime_local_presentation_state.dart',
      ).readAsStringSync();
      final importLines = source
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.startsWith('import '))
          .toList(growable: false);

      expect(importLines, hasLength(3));
      expect(
        importLines,
        contains(
          "import 'package:flutter_elitesync_module/features/match/data/"
          "local_runtime_adapter/relationship_runtime_local_adapter.dart';",
        ),
      );
      expect(
        importLines,
        contains(
          "import 'package:flutter_elitesync_module/features/match/"
          "presentation/providers/relationship_runtime_local_adapter_provider.dart';",
        ),
      );
      expect(
        importLines,
        contains("import 'package:flutter_riverpod/flutter_riverpod.dart';"),
      );

      const forbidden = <String>[
        'match_providers',
        'match_feedback_provider',
        'app_providers',
        'repository',
        'usecase',
        'datasource',
        'remote',
        'page',
        'widget',
        'route',
        'storage',
        'dio',
        'api',
        'client',
        'chat',
        'notification',
        'database',
      ];

      for (final line in importLines) {
        final lower = line.toLowerCase();
        for (final term in forbidden) {
          expect(
            lower.contains(term),
            isFalse,
            reason: 'forbidden import token: $term',
          );
        }
      }
    },
  );

  test(
    'presentation state references stay inside exact dev-preview allowlist',
    () {
      const sourcePath =
          'lib/features/match/presentation/state/'
          'relationship_runtime_local_presentation_state.dart';
      final libDir = Directory('lib');
      final references = <String>[];

      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final normalized = entity.path.replaceAll('\\', '/');
        if (normalized.endsWith(sourcePath)) {
          continue;
        }
        final content = entity.readAsStringSync();
        if (content.contains(
              'relationship_runtime_local_presentation_state.dart',
            ) ||
            content.contains(
              'relationshipRuntimeLocalPresentationStateProvider',
            ) ||
            content.contains('RelationshipRuntimeLocalPresentationState')) {
          references.add(normalized);
        }
      }

      references.sort();
      const allowedReferences = [
        'lib/features/match/presentation/widgets/'
            'relationship_runtime_local_preview_entry.dart',
        'lib/features/match/presentation/widgets/'
            'relationship_runtime_local_preview_panel.dart',
      ];

      expect(references, orderedEquals(allowedReferences));
      for (final reference in references) {
        expect(reference.contains('/pages/'), isFalse);
        expect(reference.contains('/router/'), isFalse);
        expect(reference.endsWith('/app_shell.dart'), isFalse);
        expect(reference.contains('preview_'), isTrue);
      }
    },
  );
}
