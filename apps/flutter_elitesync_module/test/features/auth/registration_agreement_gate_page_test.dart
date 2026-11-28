import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'registration with an unverified agreement offers no consent or submission',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const RegisterPage()),
      );

      expect(find.text('暂时无法注册'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byType(TextField), findsNothing);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '完成注册'),
      );
      expect(button.onPressed, isNull);
    },
  );
}
