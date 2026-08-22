import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_bottom_nav_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';

void main() {
  testWidgets('AppShell browse dock exposes no center action copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: FloatingDockBottomBar(
            currentIndex: 0,
            browseMode: true,
            centerActionLabel: null,
            onTap: (_) {},
            onCenterActionTap: null,
            items: const [
              AppBottomNavItem(icon: Icons.home_outlined, label: '首页'),
              AppBottomNavItem(icon: Icons.explore_outlined, label: '发现'),
              AppBottomNavItem(icon: Icons.auto_awesome_outlined, label: '匹配'),
              AppBottomNavItem(icon: Icons.chat_bubble_outline, label: '消息'),
              AppBottomNavItem(icon: Icons.person_outline, label: '我的'),
            ],
          ),
        ),
      ),
    );

    for (final label in ['首页', '发现', '匹配', '消息', '我的']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('查看状态'), findsNothing);
    expect(find.text('发布状态'), findsNothing);
    expect(find.text('发布'), findsNothing);
    expect(find.text('状态中心'), findsNothing);
    expect(find.text('release'), findsNothing);
  });
}
