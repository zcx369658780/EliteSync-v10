import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_chart_settings_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  FakeLocalStorageService([Map<String, Object?>? initialValues]) {
    _values.addAll(initialValues ?? const {});
  }

  final Map<String, Object?> _values = {};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

Widget _wrap(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: AppRouteNames.astroAdvancedPreview,
        builder: (context, state) => const Scaffold(body: Text('高级时法路由已打开')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync Dev',
          apiBaseUrl: 'http://101.133.161.203',
          useMockData: true,
          useMockHome: true,
          useMockMatch: true,
          useMockChat: true,
        ),
      ),
      localStorageProvider.overrideWithValue(FakeLocalStorageService()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets(
    'astro chart settings page links parameters to advanced preview',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 10000));
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(_wrap(const AstroChartSettingsPage()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('校准样例'), 200.0);
      await tester.pumpAndSettle();

      expect(find.text('盘面设置'), findsOneWidget);
      expect(find.text('继续了解'), findsOneWidget);
      expect(find.text('打开高级时法'), findsOneWidget);
      expect(find.text('校准样例'), findsOneWidget);
      expect(find.text('查看校准报告'), findsNothing);
      expect(find.text('打开校准演示'), findsNothing);
      expect(find.textContaining('advanced-demo'), findsNothing);
      expect(find.text('路线：标准路线'), findsOneWidget);
      expect(find.text('黄道：回归黄道'), findsAtLeastNWidgets(1));
      expect(find.text('宫位：Whole'), findsAtLeastNWidgets(1));
      expect(find.textContaining('工作台参数'), findsNothing);
      expect(find.textContaining('参数联动'), findsNothing);

      await tester.tap(find.text('打开高级时法'));
      await tester.pumpAndSettle();
      expect(find.text('高级时法路由已打开'), findsOneWidget);
    },
  );
}
