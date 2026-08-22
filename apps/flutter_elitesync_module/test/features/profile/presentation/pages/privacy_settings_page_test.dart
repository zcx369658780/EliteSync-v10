import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrivacySettingsPage hides unsupported visibility controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
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

    expect(find.text('隐私设置'), findsOneWidget);
    expect(find.text('公开可见性设置暂未提供'), findsOneWidget);
    expect(find.textContaining('本地或设备偏好不会改变其他用户能看到'), findsOneWidget);
    expect(find.text('公开个人资料'), findsNothing);
    expect(find.text('显示城市'), findsNothing);
    expect(find.byType(Switch), findsNothing);
    expect(find.textContaining('仅匹配对象可见'), findsNothing);
    expect(find.textContaining('共同兴趣和活动边界展示'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
