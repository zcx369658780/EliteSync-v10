import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/calm_home_projection_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/canonical_match_lifecycle.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const defaultDevEnv = AppEnv(
  flavor: AppFlavor.dev,
  appName: 'Default dev',
  apiBaseUrl: 'http://127.0.0.1:9/',
  useMockData: true,
);

const readyNavigation = NavigationSnapshot(
  authStatus: AuthStatus.authenticated,
  verificationStatus: VerificationStatus.unknown,
  questionnaireStatus: QuestionnaireStatus.unknown,
  matchStatus: MatchStatus.unknown,
  canChat: false,
  readinessState: ReadinessGuardState.ready,
  isBootstrapLoading: false,
);

final syntheticMatch = MatchRoundProjection(
  state: MatchRoundBusinessState.revealed,
  serverTime: DateTime.utc(2026, 9, 21),
  receivedAt: DateTime.utc(2026, 9, 21),
  contractVersion: 'synthetic-demo-v1',
  retryEligible: false,
  userAction: 'view',
  projectionVersion: 1,
  updatedAt: DateTime.utc(2026, 9, 21),
  result: const MatchRoundResult(
    matchId: 990000101,
    partnerId: 990000201,
    headline: 'Synthetic candidate proposal',
  ),
);

ProviderContainer demoContainer() => ProviderContainer(
  overrides: [
    appEnvProvider.overrideWithValue(createDemoAppEnv()),
    navigationGuardProvider.overrideWithValue(readyNavigation),
    matchRoundProjectionProvider.overrideWith((ref) async => syntheticMatch),
  ],
);

HomeStateSummary summary(
  ProviderContainer container,
  HomeProjectedDomain domain,
) => container
    .read(calmHomeProjectionProvider)
    .summaries
    .singleWhere((value) => value.domain == domain);

void main() {
  test('synthetic Home projection requires the explicit demo flag', () {
    expect(defaultDevEnv.useSyntheticHomeProjection, isFalse);
    expect(createDemoAppEnv().useSyntheticHomeProjection, isTrue);

    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(defaultDevEnv)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(calmHomeProjectionProvider),
      same(CalmHomeProjection.current),
    );
  });

  test('Home follows the existing synthetic main loop without mutation', () async {
    final container = demoContainer();
    addTearDown(container.dispose);
    await container.read(matchRoundProjectionProvider.future);

    final canonical = CanonicalMatchLifecycleAdapter.fromRound(syntheticMatch);
    expect(summary(container, HomeProjectedDomain.readiness).stateCode, 'READY');
    expect(
      summary(container, HomeProjectedDomain.match).stateCode,
      canonical.targetState!.code,
    );
    expect(summary(container, HomeProjectedDomain.connection).stateCode, 'CN_NONE');
    expect(
      summary(container, HomeProjectedDomain.conversation).stateCode,
      'CV_LOCKED',
    );
    expect(
      container.read(calmHomeProjectionProvider).nextDecision.route,
      AppRouteNames.progressConnection,
    );

    final connection = container.read(connectionPresentationProvider.notifier);
    connection.apply(ConnectionLifecycleAction.request);
    connection.apply(ConnectionLifecycleAction.accept);
    expect(summary(container, HomeProjectedDomain.connection).stateCode, 'CN_ACTIVE');
    expect(
      container.read(calmHomeProjectionProvider).nextDecision.label,
      '前往消息同意',
    );
    expect(
      container.read(calmHomeProjectionProvider).nextDecision.route,
      AppRouteNames.messages,
    );

    final conversation = container.read(conversationAccessProvider.notifier);
    conversation.apply(ConversationLifecycleAction.requestMessagingConsent);
    conversation.apply(ConversationLifecycleAction.acceptMessagingConsent);
    expect(summary(container, HomeProjectedDomain.conversation).stateCode, 'CV_ACTIVE');
    expect(
      container.read(calmHomeProjectionProvider).nextDecision.label,
      '查看消息',
    );

    connection.apply(ConnectionLifecycleAction.close);
    expect(summary(container, HomeProjectedDomain.connection).stateCode, 'CN_CLOSED');
    expect(
      summary(container, HomeProjectedDomain.conversation).stateCode,
      'CV_LOCKED',
    );
    expect(
      container.read(calmHomeProjectionProvider).nextDecision.route,
      AppRouteNames.progressConnection,
    );
  });
}
