import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';

Widget _wrap(GoRouter router, {ThemeMode themeMode = ThemeMode.light}) {
  return MaterialApp.router(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    routerConfig: router,
  );
}

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
