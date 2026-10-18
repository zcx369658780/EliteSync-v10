import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_chart_settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> show(
    WidgetTester tester,
    Future<Map<String, dynamic>?> Function() load,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [astroSummaryProvider.overrideWith((ref) => load())],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const AstroChartSettingsPage(),
        ),
      ),
    );
  }

  final native = <String, dynamic>{
    'natal': {'status': 'COMPUTED_UNVERIFIED'},
  };
  testWidgets(
    'cold entry actively loads native summary without pre-initialization',
    (tester) async {
      var loads = 0;
      await show(tester, () async {
        loads++;
        return native;
      });
      await tester.pumpAndSettle();
      expect(loads, 1);
      expect(find.text('计算设置（重新计算并保存）'), findsOneWidget);
      expect(find.text('本命盘设置'), findsOneWidget);
      expect(find.text('恒星黄道'), findsNothing);
      expect(find.text('打开高级时法'), findsNothing);
    },
  );
  testWidgets(
    'cold loading fails closed without exposing legacy calculation choices',
    (tester) async {
      final pending = Completer<Map<String, dynamic>?>();
      await show(tester, () => pending.future);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('正在读取本命计算设置…'), findsOneWidget);
      expect(find.text('恒星黄道'), findsNothing);
      expect(find.text('打开高级时法'), findsNothing);
      expect(find.text('计算设置（重新计算并保存）'), findsNothing);
      pending.complete(native);
      await tester.pumpAndSettle();
      expect(find.text('计算设置（重新计算并保存）'), findsOneWidget);
    },
  );
  testWidgets(
    'cold error remains closed and explicit retry loads actual mode',
    (tester) async {
      var loads = 0;
      await show(tester, () async {
        loads++;
        if (loads == 1) throw StateError('fictional-read-failure');
        return native;
      });
      await tester.pumpAndSettle();
      expect(find.text('无法读取本命设置，请重试。'), findsOneWidget);
      expect(find.text('恒星黄道'), findsNothing);
      expect(find.text('打开高级时法'), findsNothing);
      await tester.tap(find.text('重新读取'));
      await tester.pumpAndSettle();
      expect(loads, 2);
      expect(find.text('计算设置（重新计算并保存）'), findsOneWidget);
    },
  );
  testWidgets(
    'cold successful legacy summary preserves accepted local setting choices',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 10000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var loads = 0;
      await show(tester, () async {
        loads++;
        return {'name': 'legacy fictional user'};
      });
      await tester.pumpAndSettle();
      expect(loads, 1);
      expect(find.text('盘面设置'), findsOneWidget);
      expect(find.text('恒星黄道'), findsOneWidget);
      expect(find.text('打开高级时法'), findsOneWidget);
      expect(find.text('计算设置（重新计算并保存）'), findsNothing);
    },
  );
}
