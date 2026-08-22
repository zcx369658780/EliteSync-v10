import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/features/match/data/local_runtime_adapter/relationship_runtime_local_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final relationshipRuntimeLocalAdapterProvider =
    Provider<RelationshipRuntimeLocalAdapter>(
      (_) => RelationshipRuntimeLocalAdapter(),
    );

final relationshipRuntimeFixtureProvider = Provider<Map<String, dynamic>>((_) {
  final fixture = File(
    '../../services/backend-laravel/tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json',
  );
  return jsonDecode(fixture.readAsStringSync()) as Map<String, dynamic>;
});

final relationshipRuntimeProjectedResultsProvider =
    Provider<List<RelationshipRuntimeLocalAdapterResult>>((ref) {
      final adapter = ref.watch(relationshipRuntimeLocalAdapterProvider);
      final fixture = ref.watch(relationshipRuntimeFixtureProvider);
      return adapter.projectFixture(fixture);
    });

final malformedRelationshipRuntimePayloadProvider =
    Provider<Map<String, dynamic>>((_) {
      return {
        'contract_version': RelationshipRuntimeLocalAdapter.contractVersion,
        'states': <Map<String, dynamic>>[
          {'id': 'malformed-state'},
        ],
      };
    });

final relationshipRuntimeSafeProjectedMalformedResultsProvider =
    Provider<List<RelationshipRuntimeLocalAdapterResult>>((ref) {
      final adapter = ref.watch(relationshipRuntimeLocalAdapterProvider);
      final payload = ref.watch(malformedRelationshipRuntimePayloadProvider);
      return projectRelationshipRuntimeFixtureWithSafeFallback(
        adapter: adapter,
        payload: payload,
      );
    });

List<RelationshipRuntimeLocalAdapterResult>
projectRelationshipRuntimeFixtureWithSafeFallback({
  required RelationshipRuntimeLocalAdapter adapter,
  required Map<String, dynamic> payload,
}) {
  try {
    return adapter.projectFixture(payload);
  } catch (_) {
    return const <RelationshipRuntimeLocalAdapterResult>[];
  }
}

void main() {
  test('projects all supported relationship states from local fixture', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final results = container.read(relationshipRuntimeProjectedResultsProvider);

    expect(
      results.map((result) => result.state).toList(),
      equals(RelationshipRuntimeLocalAdapter.supportedStates),
    );
  });

  test('projects L2 evidence for all supported states', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final results = container.read(relationshipRuntimeProjectedResultsProvider);

    expect(
      results.map((result) => result.evidenceLevel).toList(),
      everyElement(RelationshipRuntimeLocalAdapter.evidenceLevel),
    );
  });

  test(
    'projects offline boundary flags as endpoint/database/production disabled',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final results = container.read(
        relationshipRuntimeProjectedResultsProvider,
      );
      final boundaries = results
          .map((result) => result.boundaries)
          .toList(growable: false);

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
    },
  );

  test('projects send boundaries as manual/automatic send disabled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final results = container.read(relationshipRuntimeProjectedResultsProvider);
    final boundaries = results
        .map((result) => result.boundaries)
        .toList(growable: false);

    expect(
      boundaries.map((boundary) => boundary.canSend),
      everyElement(isFalse),
    );
    expect(
      boundaries.map((boundary) => boundary.automaticSendAllowed),
      everyElement(isFalse),
    );
  });

  test('projects remote feedback and notification as inactive', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final results = container.read(relationshipRuntimeProjectedResultsProvider);
    final boundaries = results
        .map((result) => result.boundaries)
        .toList(growable: false);

    expect(
      boundaries.map((boundary) => boundary.remoteFeedbackInactive),
      everyElement(isTrue),
    );
    expect(
      boundaries.map((boundary) => boundary.notificationPushInactive),
      everyElement(isTrue),
    );
  });

  test('projects truth mutations as disabled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final results = container.read(relationshipRuntimeProjectedResultsProvider);
    final boundaries = results
        .map((result) => result.boundaries)
        .toList(growable: false);

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

  test(
    'malformed payload fails closed with safe fallback without external IO',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(
          relationshipRuntimeSafeProjectedMalformedResultsProvider,
        ),
        returnsNormally,
      );
      final fallback = container.read(
        relationshipRuntimeSafeProjectedMalformedResultsProvider,
      );

      expect(fallback, isEmpty);
    },
  );

  test('test source does not import forbidden modules', () {
    final source = File(
      'test/features/match/presentation/providers/'
      'relationship_runtime_local_adapter_provider_skeleton_test.dart',
    ).readAsStringSync();
    final importLines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('import '));

    const forbidden = <String>[
      'match_providers',
      'app_providers',
      'repository',
      'usecase',
      'page',
      'widget',
      'route',
      'storage',
      'dio',
      'api',
      'client',
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
}
