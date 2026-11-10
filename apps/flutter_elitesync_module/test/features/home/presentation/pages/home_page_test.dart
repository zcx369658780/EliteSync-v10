import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/calm_home_projection_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';
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

Widget _wrap(
  GoRouter router, {
  ThemeMode themeMode = ThemeMode.light,
  CalmHomeProjection? projection,
}) {
  return ProviderScope(
    overrides: [
      calmHomeProjectionProvider.overrideWithValue(
        projection ?? CalmHomeProjection.current,
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    ),
  );
}

Widget _wrapMatchFuture(
  GoRouter router,
  Future<MatchRoundProjection> Function() loadMatch,
) {
  const readyNavigation = NavigationSnapshot(
    authStatus: AuthStatus.authenticated,
    verificationStatus: VerificationStatus.unknown,
    questionnaireStatus: QuestionnaireStatus.unknown,
    matchStatus: MatchStatus.unknown,
    canChat: false,
    readinessState: ReadinessGuardState.ready,
    isBootstrapLoading: false,
  );
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(createDemoAppEnv()),
      navigationGuardProvider.overrideWithValue(readyNavigation),
      matchRoundProjectionProvider.overrideWith((ref) => loadMatch()),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

MatchRoundProjection _syntheticMatch(MatchRoundBusinessState state) =>
    MatchRoundProjection(
      state: state,
      serverTime: DateTime.utc(2026, 9, 21),
      receivedAt: DateTime.utc(2026, 9, 21),
      contractVersion: 'synthetic-home-widget-v1',
      retryEligible: false,
      userAction: 'view',
      projectionVersion: 1,
      updatedAt: DateTime.utc(2026, 9, 21),
    );

Widget _wrapSyntheticMatch(GoRouter router, MatchRoundBusinessState state) =>
    _wrapMatchFuture(router, () async => _syntheticMatch(state));

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

GoRouter _router() {
  return GoRouter(
    initialLocation: AppRouteNames.home,
    routes: [
      GoRoute(
        path: AppRouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRouteNames.meReadiness,
        builder: (context, state) =>
            const Scaffold(body: Text('READINESS ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.progress,
        builder: (context, state) =>
            const Scaffold(body: Text('PROGRESS ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.mePrivacySettings,
        builder: (context, state) =>
            const Scaffold(body: Text('PRIVACY ROUTE')),
      ),
    ],
  );
}

void main() {
  test(
    'projection selects only readiness, authoritative next, or Progress',
    () {
      expect(
        CalmHomeProjection.current.nextDecision.route,
        AppRouteNames.meReadiness,
      );

      const noAuthoritativeNext = CalmHomeProjection(
        summaries: [],
        readinessAuthority: HomeProjectionAuthority.authoritative,
      );
      expect(noAuthoritativeNext.nextDecision.route, AppRouteNames.progress);

      const authoritativeNext = CalmHomeProjection(
        summaries: [],
        readinessAuthority: HomeProjectionAuthority.authoritative,
        authoritativeNextDecision: HomeNextDecision(
          label: '已确认的下一步',
          route: AppRouteNames.progressConnection,
        ),
      );
      expect(
        authoritativeNext.nextDecision.route,
        AppRouteNames.progressConnection,
      );

      const unknownReadiness = HomeStateSummary(
        domain: HomeProjectedDomain.readiness,
        authority: HomeProjectionAuthority.unknown,
      );
      expect(unknownReadiness.statusLabel, 'UNKNOWN');
      expect(unknownReadiness.statusLabel, isNot('状态尚未建立'));
    },
  );

  testWidgets('Home renders exactly three calm primary areas', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    expect(find.text('当前状态 · Current state'), findsOneWidget);
    expect(find.text('下一步 · Next decision'), findsOneWidget);
    expect(find.text('可选支持 · Optional support'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-area-current-state')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-area-next-decision')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-area-optional-support')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-state-readiness')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-state-match')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-state-connection')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-state-conversation')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-state-relationship')), findsNothing);
    expect(find.text('状态尚未建立'), findsNWidgets(2));
    expect(find.text('权限尚未建立'), findsNWidgets(2));
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('前往准备状态'), findsOneWidget);
    expect(find.text('隐私与数据设置'), findsOneWidget);
    expect(find.textContaining('访问这里不会改变任何生命周期状态'), findsOneWidget);
    expect(find.textContaining('状态尚未建立不代表失败或不符合条件'), findsOneWidget);
    expect(find.textContaining('匹配不等于连接'), findsOneWidget);
    expect(find.textContaining('连接不等于对话'), findsOneWidget);
    expect(find.textContaining('对话也不等于关系'), findsOneWidget);
    expect(find.textContaining('无需现在继续'), findsOneWidget);

    for (final forbidden in [
      '候选人',
      '消息预览',
      '未读',
      '匹配分数',
      '倒计时',
      '立即加入',
      '发现动态',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home routes the primary decision to Readiness', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-primary-next-decision')));
    await tester.pumpAndSettle();

    expect(find.text('READINESS ROUTE'), findsOneWidget);
  });

  testWidgets('Home Match unknown fallback opens Progress', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    const syntheticUnknownMatch = CalmHomeProjection(
      summaries: [
        HomeStateSummary(
          domain: HomeProjectedDomain.readiness,
          authority: HomeProjectionAuthority.syntheticDevelopment,
          stateCode: 'READY',
        ),
        HomeStateSummary(
          domain: HomeProjectedDomain.match,
          authority: HomeProjectionAuthority.unknown,
        ),
      ],
      readinessAuthority: HomeProjectionAuthority.syntheticDevelopment,
    );
    expect(syntheticUnknownMatch.authoritativeNextDecision, isNull);

    await tester.pumpWidget(_wrap(router, projection: syntheticUnknownMatch));
    await tester.pumpAndSettle();

    expect(find.text('UNKNOWN'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('查看进展'), findsOneWidget);
    expect(find.textContaining('当前没有可用的匹配提案'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('home-primary-next-decision')));
    await tester.pumpAndSettle();

    expect(find.text('PROGRESS ROUTE'), findsOneWidget);
    expect(find.text('READINESS ROUTE'), findsNothing);
    expect(find.text('PRIVACY ROUTE'), findsNothing);
  });

  for (final state in [
    MatchRoundBusinessState.failed,
    MatchRoundBusinessState.closed,
  ]) {
    testWidgets('synthetic Match $state reaches Home unknown fallback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = _router();
      addTearDown(router.dispose);

      await tester.pumpWidget(_wrapSyntheticMatch(router, state));
      await tester.pumpAndSettle();

      expect(find.text('UNKNOWN'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('查看进展'), findsOneWidget);
      expect(find.textContaining('当前没有可用的匹配提案'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('home-primary-next-decision')),
      );
      await tester.pumpAndSettle();

      expect(find.text('PROGRESS ROUTE'), findsOneWidget);
      expect(find.text('READINESS ROUTE'), findsNothing);
      expect(find.text('PRIVACY ROUTE'), findsNothing);
    });
  }

  testWidgets('loading synthetic Match reaches Home unknown fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);
    final pendingMatch = Completer<MatchRoundProjection>();

    await tester.pumpWidget(
      _wrapMatchFuture(router, () => pendingMatch.future),
    );
    await tester.pumpAndSettle();

    expect(find.text('UNKNOWN'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('查看进展'), findsOneWidget);
    expect(find.textContaining('当前没有可用的匹配提案'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('home-primary-next-decision')));
    await tester.pumpAndSettle();
    expect(find.text('PROGRESS ROUTE'), findsOneWidget);

    pendingMatch.complete(_syntheticMatch(MatchRoundBusinessState.noRound));
    await pendingMatch.future;
    await tester.pump();
  });

  testWidgets('errored synthetic Match reaches Home unknown fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);
    final failedMatch = Completer<MatchRoundProjection>();
    final consumedFailure = expectLater(failedMatch.future, throwsStateError);

    await tester.pumpWidget(_wrapMatchFuture(router, () => failedMatch.future));
    failedMatch.completeError(StateError('synthetic Match read failure'));
    await consumedFailure;
    await tester.pumpAndSettle();

    expect(find.text('UNKNOWN'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('查看进展'), findsOneWidget);
    expect(find.textContaining('当前没有可用的匹配提案'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('home-primary-next-decision')));
    await tester.pumpAndSettle();
    expect(find.text('PROGRESS ROUTE'), findsOneWidget);
  });

  testWidgets('Home keeps optional privacy support secondary', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('home-optional-privacy-support')),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRIVACY ROUTE'), findsOneWidget);
  });

  testWidgets('Home primary CTA preserves accessible theme contrast', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router, themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    final ctaFinder = find.byKey(const ValueKey('home-primary-next-decision'));
    final cta = tester.widget<FilledButton>(ctaFinder);
    final tokens = tester.element(ctaFinder).appTokens;
    expect(
      cta.style?.backgroundColor?.resolve(const <WidgetState>{}),
      tokens.textPrimary,
    );
    expect(
      cta.style?.foregroundColor?.resolve(const <WidgetState>{}),
      tokens.browseSurface,
    );
    expect(
      _contrastRatio(tokens.textPrimary, tokens.browseSurface),
      greaterThan(4.5),
    );
  });

  testWidgets('Calm State Hub fits an ordinary phone width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    expect(find.text('当前状态 · Current state'), findsOneWidget);
    expect(find.text('前往准备状态'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
