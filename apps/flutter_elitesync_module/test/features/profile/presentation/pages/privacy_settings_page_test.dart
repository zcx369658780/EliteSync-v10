import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Privacy Control Center is purpose-oriented and truthful', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 5000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const PrivacySettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('权限与说明'), findsOneWidget);
    expect(find.text('查看和管理资料分享'), findsOneWidget);

    for (final title in [
      '匹配与每周慢约',
      '持续参与与自动化',
      '私密资料与展示',
      '连接与私密消息',
      '搭子与社区',
      '自我了解工具',
      '举报与受限资料',
      '账号与设备',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('完整数据导出、统一删除、保留期限及地区权利处理仍待完善'), findsOneWidget);
    expect(find.textContaining('本版尚未接入系统推送'), findsOneWidget);
    expect(find.textContaining('本版未接入运行时AI'), findsOneWidget);
    expect(find.text('管理连接'), findsOneWidget);
    expect(find.text('查看消息'), findsOneWidget);
    expect(find.text('编辑私密资料'), findsOneWidget);
    expect(find.text('编辑展示资料'), findsOneWidget);
    expect(find.textContaining('NOT YET ESTABLISHED'), findsNothing);

    expect(find.byType(Switch), findsNothing);
    expect(find.text('公开个人资料'), findsNothing);
    expect(find.text('显示城市'), findsNothing);
    expect(find.textContaining('仅匹配对象可见'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
