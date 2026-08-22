import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';

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
        path: AppRouteNames.match,
        builder: (context, state) => const Scaffold(body: Text('MATCH ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.personalShowcase,
        builder: (context, state) =>
            const Scaffold(body: Text('PERSONAL SHOWCASE ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.messages,
        builder: (context, state) =>
            const Scaffold(body: Text('MESSAGES ROUTE')),
      ),
    ],
  );
}

void main() {
  testWidgets('Home has one static Match action and no secondary tasks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('从这里查看慢约进展。'), findsOneWidget);
    expect(find.text('查看慢约进展'), findsOneWidget);

    const ctaKey = ValueKey('e1-home-primary-match-cta');
    final ctaFinder = find.byKey(ctaKey);
    expect(ctaFinder, findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
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
    expect(cta.style?.minimumSize?.resolve(const <WidgetState>{})?.height, 48);

    expect(find.text('完善资料'), findsNothing);
    expect(find.text('查看消息'), findsNothing);
    for (final forbidden in [
      '本轮',
      '今日慢约',
      '倒计时',
      '候选人',
      '结果',
      '资格',
      '未读',
      '重试',
      'Admin',
      'raw home failure',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home actions keep their canonical destinations', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('e1-home-primary-match-cta')));
    await tester.pumpAndSettle();
    expect(find.text('MATCH ROUTE'), findsOneWidget);
  });

  testWidgets('Home primary CTA keeps accessible dark-theme contrast', (
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

    final ctaFinder = find.byKey(const ValueKey('e1-home-primary-match-cta'));
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

  testWidgets('Home static shell fits an ordinary phone width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    expect(find.text('从这里查看慢约进展。'), findsOneWidget);
    expect(find.text('查看慢约进展'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
