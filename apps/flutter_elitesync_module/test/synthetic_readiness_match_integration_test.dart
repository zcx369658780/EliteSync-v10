import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/match/data/datasource/match_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/canonical_match_lifecycle.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('synthetic readiness', () {
    test('requires authenticated dev session and explicit demo flag', () {
      final demoEnv = createDemoAppEnv();

      expect(
        resolveReadinessGuardState(
          authStatus: AuthStatus.unauthenticated,
          isDev: demoEnv.isDev,
          useSyntheticReadinessProjection:
              demoEnv.useSyntheticReadinessProjection,
        ),
        ReadinessGuardState.unauthenticated,
      );
      expect(
        resolveReadinessGuardState(
          authStatus: AuthStatus.authenticated,
          isDev: false,
          useSyntheticReadinessProjection: false,
        ),
        ReadinessGuardState.unknown,
      );
      expect(
        resolveReadinessGuardState(
          authStatus: AuthStatus.authenticated,
          isDev: demoEnv.isDev,
          useSyntheticReadinessProjection:
              demoEnv.useSyntheticReadinessProjection,
        ),
        ReadinessGuardState.ready,
      );
    });
  });

  test('mock match projection is local, revealed, and read only', () async {
    var requestCount = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestCount += 1;
          handler.reject(
            DioException(requestOptions: options, message: 'unexpected call'),
          );
        },
      ),
    );
    final source = MatchRemoteDataSource(
      apiClient: ApiClient(dio: dio),
      useMock: true,
    );

    final projection = await source.getRoundProjection();
    final result = projection.result;
    final capability = projection.conversationCapability;
    final canonical = CanonicalMatchLifecycleAdapter.fromRound(projection);

    expect(requestCount, 0);
    expect(projection.state, MatchRoundBusinessState.revealed);
    expect(projection.contractVersion, contains('synthetic-demo'));
    expect(projection.projectionVersion, 1);
    expect(result, isNotNull);
    expect(result!.matchId, greaterThanOrEqualTo(990000000));
    expect(result.partnerId, greaterThanOrEqualTo(990000000));
    expect(result.partnerNickname, contains('Synthetic Demo'));
    expect(result.headline, contains('Synthetic candidate proposal'));
    expect(capability, isNotNull);
    expect(capability!.canCreate, isFalse);
    expect(capability.canSend, isFalse);
    expect(capability.canWebSocket, isFalse);
    expect(canonical.targetState, CanonicalMatchTargetState.proposalPresented);
    expect(
      canonical.condition,
      CanonicalMatchPresentationCondition.roundAvailable,
    );
    expect(canonical.authoritativeActions, isEmpty);
  });
}
