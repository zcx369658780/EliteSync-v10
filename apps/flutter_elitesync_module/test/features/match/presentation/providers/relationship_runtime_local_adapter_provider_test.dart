import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/features/match/data/local_runtime_adapter/relationship_runtime_local_adapter.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/relationship_runtime_local_adapter_provider.dart';
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
  test('defaults to dormant empty projection without local payload', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final results = container.read(
      relationshipRuntimeLocalProjectedResultsProvider,
    );

    expect(results, isEmpty);
  });

  test('projects all supported states from injected local payload', () {
    final container = _containerWithPayload(_fixturePayload());
    addTearDown(container.dispose);

    final results = container.read(
      relationshipRuntimeLocalProjectedResultsProvider,
    );

    expect(
      results.map((result) => result.state).toList(),
      RelationshipRuntimeLocalAdapter.supportedStates,
    );
    expect(
      results.map((result) => result.evidenceLevel).toList(),
      everyElement(RelationshipRuntimeLocalAdapter.evidenceLevel),
    );
  });

  test('malformed payload fails closed to empty results', () {
    final container = _containerWithPayload({
      'contract_version': RelationshipRuntimeLocalAdapter.contractVersion,
      'states': <Map<String, dynamic>>[
        {'id': 'malformed-state'},
      ],
    });
    addTearDown(container.dispose);

    final results = container.read(
      relationshipRuntimeLocalProjectedResultsProvider,
    );

    expect(results, isEmpty);
  });

  test('keeps endpoint database and production runtime disabled', () {
    final container = _containerWithPayload(_fixturePayload());
    addTearDown(container.dispose);

    final results = container.read(
      relationshipRuntimeLocalProjectedResultsProvider,
    );
    final boundaries = results.map((result) => result.boundaries);

    expect(
      boundaries.map((boundary) => boundary.hasEndpointDependency),
      everyElement(isFalse),
    );
    expect(
      boundaries.map((boundary) => boundary.hasDatabaseDependency),
      everyElement(isFalse),
    );
    expect(
      boundaries.map((boundary) => boundary.hasProductionRuntimeImport),
      everyElement(isFalse),
    );
  });

  test('keeps send feedback notification and truth mutations disabled', () {
    final container = _containerWithPayload(_fixturePayload());
    addTearDown(container.dispose);

    final results = container.read(
      relationshipRuntimeLocalProjectedResultsProvider,
    );
    final boundaries = results.map((result) => result.boundaries);

    expect(boundaries.map((boundary) => boundary.canSend), everyElement(false));
    expect(
      boundaries.map((boundary) => boundary.automaticSendAllowed),
      everyElement(isFalse),
    );
    expect(
      boundaries.map((boundary) => boundary.remoteFeedbackInactive),
      everyElement(isTrue),
    );
    expect(
      boundaries.map((boundary) => boundary.notificationPushInactive),
      everyElement(isTrue),
    );
    expect(
      boundaries.map((boundary) => boundary.scoringMutationAllowed),
      everyElement(isFalse),
    );
    expect(
      boundaries.map((boundary) => boundary.profileTruthMutationAllowed),
      everyElement(isFalse),
    );
    expect(
      boundaries.map((boundary) => boundary.astroTruthMutationAllowed),
      everyElement(isFalse),
    );
  });

  test('refuses protected actions without executing them', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (final action in <String>[
      'endpoint_smoke',
      'db_migration',
      'chat_send',
      'media_upload',
      'remote_feedback',
      'notification_push',
      'profile_truth_mutation',
      'release_apk',
    ]) {
      final refusal = container.read(
        relationshipRuntimeLocalForbiddenActionProvider(action),
      );

      expect(refusal.refused, isTrue);
      expect(refusal.executed, isFalse);
      expect(refusal.reason, RelationshipRuntimeLocalAdapter.refusalReason);
    }
  });

  test('source provider imports only local adapter and Riverpod', () {
    final source = File(
      'lib/features/match/presentation/providers/'
      'relationship_runtime_local_adapter_provider.dart',
    ).readAsStringSync();
    final importLines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('import '))
        .toList(growable: false);

    expect(importLines, hasLength(2));
    expect(
      importLines,
      contains(
        "import 'package:flutter_elitesync_module/features/match/data/"
        "local_runtime_adapter/relationship_runtime_local_adapter.dart';",
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
  });

  test('source provider is referenced only by local presentation state', () {
    final sourcePath =
        'lib/features/match/presentation/providers/'
        'relationship_runtime_local_adapter_provider.dart';
    final allowedPresentationStatePath =
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
      if (normalized.endsWith(allowedPresentationStatePath)) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains(
            'relationship_runtime_local_adapter_provider.dart',
          ) ||
          content.contains(
            'relationshipRuntimeLocalProjectedResultsProvider',
          ) ||
          content.contains('relationshipRuntimeLocalPayloadProvider') ||
          content.contains('relationshipRuntimeLocalForbiddenActionProvider')) {
        references.add(normalized);
      }
    }

    expect(references, isEmpty);
  });
}
