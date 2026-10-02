import 'dart:async';

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

const syntheticHomeWithoutConnectionEnv = AppEnv(
  flavor: AppFlavor.dev,
  appName: 'Synthetic Home without Connection',
  apiBaseUrl: 'http://127.0.0.1:9/',
  useMockData: true,
  useSyntheticHomeProjection: true,
  useSyntheticConversationLifecycle: true,
);

const syntheticHomeWithoutConversationEnv = AppEnv(
  flavor: AppFlavor.dev,
  appName: 'Synthetic Home without Conversation',
  apiBaseUrl: 'http://127.0.0.1:9/',
  useMockData: true,
  useSyntheticHomeProjection: true,
  useSyntheticConnectionLifecycle: true,
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

const unknownNavigation = NavigationSnapshot(
  authStatus: AuthStatus.authenticated,
  verificationStatus: VerificationStatus.unknown,
  questionnaireStatus: QuestionnaireStatus.unknown,
  matchStatus: MatchStatus.unknown,
  canChat: false,
  readinessState: ReadinessGuardState.unknown,
  isBootstrapLoading: false,
);

const setupRequiredNavigation = NavigationSnapshot(
  authStatus: AuthStatus.authenticated,
  verificationStatus: VerificationStatus.unknown,
  questionnaireStatus: QuestionnaireStatus.unknown,
  matchStatus: MatchStatus.unknown,
  canChat: false,
  readinessState: ReadinessGuardState.setupRequired,
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

MatchRoundProjection syntheticMatchWithState(MatchRoundBusinessState state) =>
    MatchRoundProjection(
      state: state,
      serverTime: DateTime.utc(2026, 9, 21),
      receivedAt: DateTime.utc(2026, 9, 21),
      contractVersion: 'synthetic-demo-v1',
      retryEligible: false,
      userAction: 'view',
      projectionVersion: 1,
      updatedAt: DateTime.utc(2026, 9, 21),
    );

ProviderContainer demoContainer({
  NavigationSnapshot navigation = readyNavigation,
  AppEnv? env,
}) => ProviderContainer(
  overrides: [
    appEnvProvider.overrideWithValue(env ?? createDemoAppEnv()),
    navigationGuardProvider.overrideWithValue(navigation),
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

void expectUnknownMatchFallback(ProviderContainer container) {
  final match = summary(container, HomeProjectedDomain.match);
  final projection = container.read(calmHomeProjectionProvider);

  expect(match.authority, HomeProjectionAuthority.unknown);
  expect(match.stateCode, isNull);
  expect(
    projection.readinessAuthority,
    HomeProjectionAuthority.syntheticDevelopment,
  );
  expect(projection.authoritativeNextDecision, isNull);
  expect(projection.nextDecision.label, '查看进展');
  expect(projection.nextDecision.route, AppRouteNames.progress);
  expect(projection.nextDecision.description, isNot(contains('没有可用的匹配提案')));
}

void expectDownstreamFallback(
  ProviderContainer container,
  String excludedClaim,
) {
  final projection = container.read(calmHomeProjectionProvider);
  expect(projection.authoritativeNextDecision, isNull);
  expect(projection.nextDecision.label, '查看进展');
  expect(projection.nextDecision.route, AppRouteNames.progress);
  expect(projection.nextDecision.description, isNot(contains(excludedClaim)));
}

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

  test('unknown synthetic readiness only offers safe navigation', () {
    final container = demoContainer(navigation: unknownNavigation);
    addTearDown(container.dispose);

    final projection = container.read(calmHomeProjectionProvider);
    final readiness = summary(container, HomeProjectedDomain.readiness);
    expect(readiness.authority, HomeProjectionAuthority.unknown);
    expect(readiness.stateCode, isNull);
    expect(projection.readinessAuthority, HomeProjectionAuthority.unknown);
    expect(projection.authoritativeNextDecision, isNull);
    expect(projection.nextDecision.route, AppRouteNames.meReadiness);
    expect(projection.nextDecision.description, contains('准备状态尚未建立'));
    expect(projection.nextDecision.description, isNot(contains('尚未就绪')));
  });

  test('setup-required synthetic readiness keeps its existing guidance', () {
    final container = demoContainer(navigation: setupRequiredNavigation);
    addTearDown(container.dispose);

    final projection = container.read(calmHomeProjectionProvider);
    final readiness = summary(container, HomeProjectedDomain.readiness);
    expect(readiness.authority, HomeProjectionAuthority.syntheticDevelopment);
    expect(readiness.stateCode, 'SETUPREQUIRED');
    expect(projection.nextDecision.route, AppRouteNames.meReadiness);
    expect(projection.nextDecision.description, contains('准备状态尚未就绪'));
  });

  test('loading synthetic Match keeps ready Home decision unknown', () {
    final pendingMatch = Completer<MatchRoundProjection>();
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(createDemoAppEnv()),
        navigationGuardProvider.overrideWithValue(readyNavigation),
        matchRoundProjectionProvider.overrideWith((ref) => pendingMatch.future),
      ],
    );
    addTearDown(container.dispose);

    expectUnknownMatchFallback(container);
  });

  test('failed synthetic Match keeps ready Home decision unknown', () async {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(createDemoAppEnv()),
        navigationGuardProvider.overrideWithValue(readyNavigation),
        matchRoundProjectionProvider.overrideWith(
          (ref) => Future.error(StateError('synthetic Match failure')),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(matchRoundProjectionProvider.future),
      throwsStateError,
    );
    expectUnknownMatchFallback(container);
  });

  for (final (state, expectedCondition) in [
    (
      MatchRoundBusinessState.failed,
      CanonicalMatchPresentationCondition.transportUnavailable,
    ),
    (
      MatchRoundBusinessState.closed,
      CanonicalMatchPresentationCondition.closedWithoutCompletionEvidence,
    ),
  ]) {
    test('synthetic Match $state condition keeps Home unknown', () async {
      final match = syntheticMatchWithState(state);
      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(createDemoAppEnv()),
          navigationGuardProvider.overrideWithValue(readyNavigation),
          matchRoundProjectionProvider.overrideWith((ref) async => match),
        ],
      );
      addTearDown(container.dispose);

      await container.read(matchRoundProjectionProvider.future);
      expect(
        CanonicalMatchLifecycleAdapter.fromRound(match).condition,
        expectedCondition,
      );
      expectUnknownMatchFallback(container);
    });
  }

  test('known no-candidate Match keeps its match navigation', () async {
    final match = syntheticMatchWithState(MatchRoundBusinessState.noCandidate);
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(createDemoAppEnv()),
        navigationGuardProvider.overrideWithValue(readyNavigation),
        matchRoundProjectionProvider.overrideWith((ref) async => match),
      ],
    );
    addTearDown(container.dispose);

    await container.read(matchRoundProjectionProvider.future);
    expect(
      CanonicalMatchLifecycleAdapter.fromRound(match).condition,
      CanonicalMatchPresentationCondition.noCandidate,
    );
    final matchSummary = summary(container, HomeProjectedDomain.match);
    expect(
      matchSummary.authority,
      HomeProjectionAuthority.syntheticDevelopment,
    );
    expect(matchSummary.stateCode, isNull);
    final projection = container.read(calmHomeProjectionProvider);
    expect(projection.nextDecision.label, '查看匹配');
    expect(projection.nextDecision.route, AppRouteNames.progressMatch);
    expect(projection.nextDecision.description, contains('没有可用的匹配提案'));
  });

  test('unestablished Connection does not imply inactivity', () async {
    final container = demoContainer(env: syntheticHomeWithoutConnectionEnv);
    addTearDown(container.dispose);
    await container.read(matchRoundProjectionProvider.future);

    expect(
      summary(container, HomeProjectedDomain.readiness).stateCode,
      'READY',
    );
    expect(
      summary(container, HomeProjectedDomain.match).authority,
      HomeProjectionAuthority.syntheticDevelopment,
    );
    final connection = summary(container, HomeProjectedDomain.connection);
    expect(connection.authority, HomeProjectionAuthority.notYetEstablished);
    expect(connection.stateCode, isNull);
    expectDownstreamFallback(container, '连接尚未激活');
  });

  test('unestablished Conversation does not imply missing consent', () async {
    final container = demoContainer(env: syntheticHomeWithoutConversationEnv);
    addTearDown(container.dispose);
    await container.read(matchRoundProjectionProvider.future);

    final connection = container.read(connectionPresentationProvider.notifier);
    connection.apply(ConnectionLifecycleAction.request);
    connection.apply(ConnectionLifecycleAction.accept);
    expect(
      summary(container, HomeProjectedDomain.readiness).stateCode,
      'READY',
    );
    expect(
      summary(container, HomeProjectedDomain.match).authority,
      HomeProjectionAuthority.syntheticDevelopment,
    );
    expect(
      summary(container, HomeProjectedDomain.connection).stateCode,
      'CN_ACTIVE',
    );
    final conversation = summary(container, HomeProjectedDomain.conversation);
    expect(conversation.authority, HomeProjectionAuthority.notYetEstablished);
    expect(conversation.stateCode, isNull);
    expectDownstreamFallback(container, '消息同意尚未完成');
  });

  test(
    'Home follows the existing synthetic main loop without mutation',
    () async {
      final container = demoContainer();
      addTearDown(container.dispose);
      await container.read(matchRoundProjectionProvider.future);

      final canonical = CanonicalMatchLifecycleAdapter.fromRound(
        syntheticMatch,
      );
      expect(
        summary(container, HomeProjectedDomain.readiness).stateCode,
        'READY',
      );
      expect(
        summary(container, HomeProjectedDomain.match).stateCode,
        canonical.targetState!.code,
      );
      expect(
        summary(container, HomeProjectedDomain.connection).stateCode,
        'CN_NONE',
      );
      expect(
        summary(container, HomeProjectedDomain.conversation).stateCode,
        'CV_LOCKED',
      );
      expect(
        container.read(calmHomeProjectionProvider).nextDecision.route,
        AppRouteNames.progressConnection,
      );

      final connection = container.read(
        connectionPresentationProvider.notifier,
      );
      connection.apply(ConnectionLifecycleAction.request);
      connection.apply(ConnectionLifecycleAction.accept);
      expect(
        summary(container, HomeProjectedDomain.connection).stateCode,
        'CN_ACTIVE',
      );
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
      expect(
        summary(container, HomeProjectedDomain.conversation).stateCode,
        'CV_ACTIVE',
      );
      expect(
        container.read(calmHomeProjectionProvider).nextDecision.label,
        '查看消息',
      );

      connection.apply(ConnectionLifecycleAction.close);
      expect(
        summary(container, HomeProjectedDomain.connection).stateCode,
        'CN_CLOSED',
      );
      expect(
        summary(container, HomeProjectedDomain.conversation).stateCode,
        'CV_LOCKED',
      );
      expect(
        container.read(calmHomeProjectionProvider).nextDecision.route,
        AppRouteNames.progressConnection,
      );
    },
  );
}
