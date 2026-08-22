import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_showcase_publication_fixture_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapFixture() {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: const ProfileShowcasePublicationFixturePage(),
  );
}

Widget _wrapRouter(AppFlavor flavor) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          appName: 'EliteSync Test',
          apiBaseUrl: 'http://localhost',
          useMockData: true,
          initialRoute: AppRouteNames.profileShowcasePublicationFixture,
        ),
      ),
      authStatusProvider.overrideWithValue(AuthStatus.authenticated),
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
  testWidgets('publication fixture covers safe public display states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapFixture());
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('DEBUG ONLY'));
    expect(visibleText, contains('不调用后端'));
    expect(visibleText, contains('No Draft / 状态不可用'));
    expect(visibleText, contains('Approved Draft / 可手动展示'));
    expect(visibleText, contains('Published Projection / 当前展示中'));
    expect(visibleText, contains('Unsafe Scoring Payload / 评分载荷关闭'));
    expect(visibleText, contains('API Error / 状态读取失败'));
    expect(visibleText, contains('matching_scoring_eligible=false'));
    expect(visibleText, isNot(contains('matching_scoring_eligible=true')));
    expect(visibleText, isNot(contains('推荐评分已开启')));
  });

  testWidgets(
    'publication fixture does not invent eligibility for local confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapFixture());
      await tester.pumpAndSettle();

      final visibleText = _visibleText(tester);
      expect(find.text('手动打开这份可展示草稿'), findsNothing);
      expect(find.text('打开这份草稿展示？'), findsNothing);
      expect(visibleText, isNot(contains('本地夹具已确认展示')));
      expect(visibleText, contains('不进入推荐评分'));
      expect(visibleText, isNot(contains('已用于推荐')));
    },
  );

  testWidgets(
    'publication fixture blocked states do not expose publish action',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapFixture());
      await tester.pumpAndSettle();

      final buttons = tester.widgetList<AppSecondaryButton>(
        find.byType(AppSecondaryButton),
      );
      final labels = buttons.map((button) => button.label).toList();

      expect(labels, isNot(contains('手动打开这份可展示草稿')));
      expect(labels.where((label) => label == '暂不可打开展示'), hasLength(4));
      expect(labels.where((label) => label == '已发布版本'), hasLength(1));

      for (final button in buttons) {
        if (button.label == '暂不可打开展示' || button.label == '已发布版本') {
          expect(button.onPressed, isNull);
        }
      }
    },
  );

  testWidgets('publication fixture route is dev-only', (tester) async {
    await tester.pumpWidget(_wrapRouter(AppFlavor.dev));
    await tester.pumpAndSettle();

    expect(find.text('公开展示状态夹具'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_wrapRouter(AppFlavor.prod));
    await tester.pumpAndSettle();

    expect(find.text('公开展示状态夹具'), findsNothing);
  });
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}
