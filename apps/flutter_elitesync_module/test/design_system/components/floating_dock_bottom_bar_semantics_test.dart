import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_bottom_nav_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync_module/design_system/theme/light_theme.dart';
import 'package:flutter_test/flutter_test.dart';

const _items = [
  AppBottomNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: '首页',
  ),
  AppBottomNavItem(icon: Icons.explore_outlined, label: '发现'),
  AppBottomNavItem(icon: Icons.auto_awesome_outlined, label: '匹配'),
  AppBottomNavItem(icon: Icons.chat_bubble_outline, label: '消息'),
  AppBottomNavItem(icon: Icons.person_outline, label: '我的'),
];

void main() {
  testWidgets('current dock item exposes selected labeled semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          bottomNavigationBar: FloatingDockBottomBar(
            currentIndex: 0,
            items: _items,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('首页'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('首页')),
      containsSemantics(
        label: '首页',
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('dock semantics follow current index and preserve tap order', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    int? tappedIndex;

    Widget buildDock(int currentIndex) {
      return MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          bottomNavigationBar: FloatingDockBottomBar(
            currentIndex: currentIndex,
            items: _items,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildDock(0));
    const labels = ['首页', '发现', '匹配', '消息', '我的'];
    final centers = <double>[];
    for (final label in labels) {
      final finder = find.bySemanticsLabel(label);
      expect(finder, findsOneWidget);
      centers.add(tester.getCenter(finder).dx);
    }
    expect(centers, orderedEquals([...centers]..sort()));

    await tester.pumpWidget(buildDock(3));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('首页')),
      containsSemantics(hasSelectedState: true, isSelected: false),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('消息')),
      containsSemantics(hasSelectedState: true, isSelected: true),
    );

    await tester.tap(find.bySemanticsLabel('发现'));
    await tester.pump();
    expect(tappedIndex, 1);
    semantics.dispose();
  });
}
