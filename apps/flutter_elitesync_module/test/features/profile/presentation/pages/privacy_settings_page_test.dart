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

    expect(find.text('隐私控制中心'), findsOneWidget);
    expect(find.text('按用途理解和管理'), findsOneWidget);
    expect(find.textContaining('没有全局公开 MVP Profile'), findsOneWidget);

    for (final key in [
      'private-identity',
      'matching-inputs-readiness',
      'candidate-showcase',
      'product-connection',
      'private-conversation',
      'ai-private-support',
      'safety-restricted',
      'operational-minimum',
    ]) {
      expect(
        find.byKey(ValueKey('privacy-purpose-$key')),
        findsOneWidget,
        reason: key,
      );
    }

    expect(find.textContaining('NOT YET ESTABLISHED'), findsWidgets);
    expect(find.text('发生了什么'), findsOneWidget);
    expect(find.text('为什么'), findsOneWidget);
    expect(find.text('使用的信息类别'), findsOneWidget);
    expect(find.text('不代表什么'), findsOneWidget);
    expect(find.text('不确定性与限制'), findsOneWidget);
    expect(find.text('你可以做什么'), findsOneWidget);
    expect(find.text('EliteSync 有新提醒'), findsOneWidget);
    expect(find.text('打开应用查看详情'), findsOneWidget);
    expect(find.textContaining('不代表 OS 推送或送达能力已经建立'), findsOneWidget);

    expect(find.byType(Switch), findsNothing);
    expect(find.text('公开个人资料'), findsNothing);
    expect(find.text('显示城市'), findsNothing);
    expect(find.textContaining('仅匹配对象可见'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
