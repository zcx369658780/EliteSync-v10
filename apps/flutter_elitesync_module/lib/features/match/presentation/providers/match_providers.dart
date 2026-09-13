import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/match/data/datasource/match_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final matchRemoteDataSourceProvider = Provider<MatchRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return MatchRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockMatch,
  );
});

final matchRoundProjectionProvider = FutureProvider<MatchRoundProjection>((
  ref,
) async {
  return ref.read(matchRemoteDataSourceProvider).getRoundProjection();
});
