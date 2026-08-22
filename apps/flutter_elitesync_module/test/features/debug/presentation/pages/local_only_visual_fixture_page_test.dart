import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/debug/presentation/pages/local_only_visual_fixture_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapFixture() {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: const LocalOnlyVisualFixturePage(),
  );
}

Widget _wrapRouter({
  required AppFlavor flavor,
  AuthStatus authStatus = AuthStatus.unauthenticated,
}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          appName: 'EliteSync Test',
          apiBaseUrl: 'http://localhost',
          useMockData: true,
          initialRoute: AppRouteNames.localOnlyVisualFixture,
        ),
      ),
      authStatusProvider.overrideWithValue(authStatus),
    ],
    child: Consumer(
      builder: (context, ref, child) {
        return MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: ref.watch(appRouterProvider),
        );
      },
    ),
  );
}

void main() {
  testWidgets('local visual fixture renders Astro Match Messages sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapFixture());
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('FIXTURE_OVERVIEW_TOP'));
    expect(visibleText, contains('FIXTURE_ASTRO_BAZI_ZIWEI'));
    expect(visibleText, contains('FIXTURE_MATCH_DATE_DROP'));
    expect(visibleText, contains('FIXTURE_MESSAGES_COMPOSER'));
    expect(visibleText, contains('本地视觉预览'));
    expect(visibleText, contains('Bazi four-pillar grid'));
    expect(visibleText, contains('Ziwei split-view palace grid'));
    expect(visibleText, contains('Messages list / row hierarchy'));
  });

  testWidgets('local visual fixture keeps non-claims visible', (tester) async {
    await tester.pumpWidget(_wrapFixture());
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('no backend'));
    expect(visibleText, contains('no runtime'));
    expect(visibleText, contains('no production'));
    expect(visibleText, contains('不调用后端'));
    expect(visibleText, contains('no production claim'));
    expect(visibleText, isNot(contains('生产已验证')));
    expect(visibleText, isNot(contains('推荐权重已调整')));
    expect(visibleText, isNot(contains('已自动发送')));
  });

  testWidgets('fixture send actions are disabled visual examples', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapFixture());
    await tester.pumpAndSettle();

    final buttons = tester.widgetList<AppSecondaryButton>(
      find.byType(AppSecondaryButton),
    );
    expect(buttons.length, greaterThanOrEqualTo(2));
    for (final button in buttons) {
      expect(button.label, 'fixture 中不可发送');
      expect(button.onPressed, isNull);
    }
  });

  testWidgets('fixture route is dev-only and bypasses login only in dev', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapRouter(flavor: AppFlavor.dev));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('8.1 本地视觉预览'), findsOneWidget);
    expect(find.text('账号登录'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(_wrapRouter(flavor: AppFlavor.prod));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('8.1 本地视觉预览'), findsNothing);
  });
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}
