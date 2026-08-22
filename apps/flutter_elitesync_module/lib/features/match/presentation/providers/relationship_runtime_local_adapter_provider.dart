import 'package:flutter_elitesync_module/features/match/data/local_runtime_adapter/relationship_runtime_local_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef RelationshipRuntimeLocalPayload = Map<String, dynamic>;

final relationshipRuntimeLocalAdapterProvider =
    Provider<RelationshipRuntimeLocalAdapter>(
      (_) => RelationshipRuntimeLocalAdapter(),
    );

final relationshipRuntimeLocalPayloadProvider =
    Provider<RelationshipRuntimeLocalPayload?>((_) => null);

final relationshipRuntimeLocalProjectedResultsProvider =
    Provider<List<RelationshipRuntimeLocalAdapterResult>>((ref) {
      final adapter = ref.watch(relationshipRuntimeLocalAdapterProvider);
      final payload = ref.watch(relationshipRuntimeLocalPayloadProvider);
      return projectRelationshipRuntimeLocalPayloadWithSafeFallback(
        adapter: adapter,
        payload: payload,
      );
    });

final relationshipRuntimeLocalForbiddenActionProvider =
    Provider.family<RelationshipRuntimeLocalAdapterRefusal, String>((
      ref,
      action,
    ) {
      final adapter = ref.watch(relationshipRuntimeLocalAdapterProvider);
      return adapter.refuseForbiddenAction(action);
    });

List<RelationshipRuntimeLocalAdapterResult>
projectRelationshipRuntimeLocalPayloadWithSafeFallback({
  required RelationshipRuntimeLocalAdapter adapter,
  required RelationshipRuntimeLocalPayload? payload,
}) {
  if (payload == null) {
    return const <RelationshipRuntimeLocalAdapterResult>[];
  }

  try {
    return adapter.projectFixture(payload);
  } catch (_) {
    return const <RelationshipRuntimeLocalAdapterResult>[];
  }
}
