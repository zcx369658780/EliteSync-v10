import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_bottom_nav_bar.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance(), second = b.computeLuminance();
  return (first > second ? first + .05 : second + .05) /
      (first > second ? second + .05 : first + .05);
}

void main() {
  testWidgets(
    'Destructive confirmation has an explicit destructive action style',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppConfirmDialog(
              title: '确认删除',
              message: '请核对后确认删除。',
              confirmLabel: '确认删除',
              destructive: true,
            ),
          ),
        ),
      );
      final action = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '确认删除').last,
      );
      expect(
        action.style?.backgroundColor?.resolve({}),
        AppTheme.light.colorScheme.error,
      );
    },
  );
  testWidgets('Four primary destinations provide 48dp touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: FloatingDockBottomBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              AppBottomNavItem(icon: Icons.home_outlined, label: '首页'),
              AppBottomNavItem(icon: Icons.route_outlined, label: '进展'),
              AppBottomNavItem(icon: Icons.chat_outlined, label: '消息'),
              AppBottomNavItem(icon: Icons.person_outline, label: '我的'),
            ],
          ),
        ),
      ),
    );
    for (final title in ['首页', '进展', '消息', '我的']) {
      expect(
        tester.getSize(find.bySemanticsLabel(title)).height,
        greaterThanOrEqualTo(48),
      );
    }
    semantics.dispose();
  });
  for (final dark in [false, true]) {
    test('Readable semantic roles in ${dark ? 'dark' : 'light'} theme', () {
      final theme = dark ? AppTheme.dark : AppTheme.light;
      final tokens = theme.extension<AppThemeTokens>()!;
      for (final ink in [
        tokens.textSecondary,
        tokens.textTertiary,
        tokens.error,
        tokens.info,
      ]) {
        expect(contrast(ink, tokens.surface), greaterThanOrEqualTo(4.5));
      }
      expect(
        contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets(
      'Long actions and dialog wrap at 200 percent ${dark ? 'dark' : 'light'}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: ListView(
                children: [
                  AppPrimaryButton(label: '确认保存并读取本人提交记录', onPressed: () {}),
                  AppSecondaryButton(
                    label: '重新读取当前账号的处理状态',
                    fullWidth: true,
                    onPressed: () {},
                  ),
                  Builder(
                    builder: (context) => TextButton(
                      onPressed: () => AppConfirmDialog.show(
                        context,
                        title: '确认退出当前账号？',
                        message: '退出前请确认已保存必要内容。当前操作需要你明确确认。',
                        confirmLabel: '确认退出当前账号',
                      ),
                      child: const Text('打开确认'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('打开确认'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('确认退出当前账号'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'Form field has a semantic label and busy action retains its purpose',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                const AppTextField(label: '反馈内容', hint: '请输入内容'),
                const AppPrimaryButton(label: '提交反馈', isLoading: true),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('反馈内容'), findsWidgets);
      expect(find.text('提交反馈'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      semantics.dispose();
    },
  );
}
