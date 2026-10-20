import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_author_entity.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

final statusRemoteDataSourceProvider = Provider<StatusRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return StatusRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockData,
    identity: () =>
        '${ref.read(sessionProvider).asData?.value.accessToken}:${ref.read(relationshipAuthorityEpochProvider)}',
  );
});

final statusPostsProvider = FutureProvider<List<StatusPostEntity>>((ref) async {
  ref.watch(relationshipAuthorityEpochProvider);
  final session = ref.watch(sessionProvider).asData?.value;
  if (session?.isLoggedIn != true) return [];
  return ref.read(statusRemoteDataSourceProvider).fetchStatusPosts(limit: 20);
});

final statusAuthorProvider = FutureProvider.family<StatusAuthorEntity, int>((
  ref,
  userId,
) {
  ref.watch(relationshipAuthorityEpochProvider);
  ref.watch(sessionProvider);
  return ref.read(statusRemoteDataSourceProvider).fetchAuthorProfile(userId);
});
