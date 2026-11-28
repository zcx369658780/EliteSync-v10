import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'permission page keeps controls and groups readable explanations',
    (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const PrivacySettingsPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('权限与说明'), findsOneWidget);
      expect(find.text('查看和管理资料分享'), findsOneWidget);
      expect(find.text('匹配与每周慢约'), findsOneWidget);
      expect(find.text('持续参与与自动化'), findsOneWidget);
      expect(find.text('搭子与社区'), findsOneWidget);
      expect(find.text('自我了解工具'), findsOneWidget);
      expect(find.textContaining('UNKNOWN'), findsNothing);
      expect(find.textContaining('MVP'), findsNothing);
      await tester.tap(find.text('匹配与每周慢约'));
      await tester.pumpAndSettle();
      expect(find.textContaining('双方分别决定'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
