import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_advanced_preview_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
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

Widget _wrap(Widget child, {Iterable<dynamic> overrides = const []}) {
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
      ...overrides,
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

AstroAdvancedPreviewBundle _identityBundle() {
  const requests = AstroAdvancedPreviewRequests(
    pair: {'route_mode': 'modern'},
    comparison: {'route_mode': 'modern'},
    transit: {'route_mode': 'modern'},
    returnChart: {'route_mode': 'modern'},
  );
  return AstroAdvancedPreviewBundle(
    routeMode: AstroChartRouteMode.modern,
    timing: buildAstroTimingFrameworkBundle(
      const {
        'name': 'EliteSync',
        'birthday': '1994-04-17',
        'birth_time': '09:30',
      },
      AstroChartRouteMode.modern,
      referenceNow: DateTime(2026, 4, 17, 10, 30),
    ),
    requests: requests,
    pair: const AstroAdvancedPreviewItem(
      title: '合盘预览',
      summary: 'EliteSync × EliteSync 对照',
      routeMode: 'modern',
      generatedAt: '2026-04-12 15:26',
      primaryName: 'EliteSync',
      secondaryName: 'EliteSync',
      primaryPointCount: 10,
      secondaryPointCount: 10,
      aspectCount: 4,
      chartKind: 'synastry',
      advancedMode: 'pair',
      pairMode: 'synastry',
      relationshipScoreDescription: '78 / 100',
      relationshipScoreValue: 78,
    ),
    comparison: const AstroAdvancedPreviewItem(
      title: '对比盘预览',
      summary: 'EliteSync × EliteSync 差异对照',
      routeMode: 'modern',
      generatedAt: '2026-04-12 15:26',
      primaryName: 'EliteSync',
      secondaryName: 'EliteSync',
      primaryPointCount: 10,
      secondaryPointCount: 11,
      aspectCount: 5,
      chartKind: 'comparison',
      advancedMode: 'pair',
      pairMode: 'comparison',
      relationshipScoreDescription: '对照评分弱化',
      relationshipScoreValue: 61,
    ),
    transit: const AstroAdvancedPreviewItem(
      title: '行运预览',
      summary: 'EliteSync 的时间窗口摘要',
      routeMode: 'modern',
      generatedAt: '2026-04-12 15:26',
      primaryName: 'EliteSync',
      secondaryName: 'EliteSync',
      primaryPointCount: 10,
      secondaryPointCount: 10,
      aspectCount: 6,
      chartKind: 'transit',
      advancedMode: 'transit',
    ),
    returnChart: const AstroAdvancedPreviewItem(
      title: '返照预览',
      summary: 'EliteSync 的返照年摘要',
      routeMode: 'modern',
      generatedAt: '2026-04-12 15:26',
      primaryName: 'EliteSync',
      secondaryName: 'EliteSync',
      primaryPointCount: 10,
      secondaryPointCount: 10,
      aspectCount: 5,
      chartKind: 'return',
      advancedMode: 'return',
      returnType: 'Lunar',
      returnYear: 2026,
    ),
    offlineFallback: true,
  );
}

void main() {
  testWidgets('advanced preview loading state uses ordinary user copy', (
    tester,
  ) async {
    final pending = Completer<AstroAdvancedPreviewBundle?>();

    await tester.pumpWidget(
      _wrap(
        const AstroAdvancedPreviewPage(),
        overrides: [
          astroAdvancedPreviewProvider.overrideWith((ref) => pending.future),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('高级时法'), findsOneWidget);
    expect(find.text('正在加载高级时法'), findsOneWidget);
    expect(find.text('正在准备高级时法内容，请稍候。'), findsOneWidget);
    expect(find.textContaining('服务端'), findsNothing);
    expect(find.textContaining('拉取'), findsNothing);
    expect(find.textContaining('画像数据'), findsNothing);
    expect(find.text('正在从服务端拉取高级时法相关画像数据，请稍候。'), findsNothing);
  });

  testWidgets('advanced preview page renders detail sections', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 2000));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final bundle = _identityBundle();
    final requestsBeforeRender = bundle.requests;

    await tester.pumpWidget(
      _wrap(
        const AstroAdvancedPreviewPage(),
        overrides: [
          astroAdvancedPreviewProvider.overrideWith((ref) async => bundle),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('高级时法'), findsOneWidget);
    expect(find.text('这页内容怎么用'), findsOneWidget);
    expect(find.text('时间视角样例'), findsOneWidget);
    expect(find.text('样例怎样拆开看'), findsOneWidget);
    expect(find.text('路线差异怎么读'), findsOneWidget);
    expect(find.text('关系与时间样例'), findsOneWidget);
    expect(find.text('本页样例一览'), findsOneWidget);
    expect(find.text('高级时法样例'), findsOneWidget);
    expect(find.text('离线预览'), findsOneWidget);
    expect(find.textContaining('现在展示的是离线样例'), findsOneWidget);
    expect(find.textContaining('方便你完成截图与归档'), findsNothing);
    expect(find.textContaining('路线能力复核'), findsNothing);
    expect(find.textContaining('单独截图'), findsNothing);
    expect(find.textContaining('快速复核'), findsNothing);
    expect(find.textContaining('归档'), findsNothing);
    expect(find.textContaining('这些样例不是你的个人结论'), findsOneWidget);
    expect(find.textContaining('不会影响你已保存的星盘信息'), findsWidgets);
    expect(find.textContaining('回写'), findsNothing);
    expect(
      find.textContaining(
        '这里用年度视角和主时段示意帮助你理解时间线索。主时段内容仍是样例，不是你的最终结论，也不会回写已保存的星盘记录。',
      ),
      findsNothing,
    );
    expect(find.textContaining('不回写已保存的星盘记录'), findsNothing);
    expect(find.textContaining('回写本命盘主结构'), findsNothing);
    expect(find.textContaining('# 3.9'), findsNothing);
    expect(find.textContaining('报告性质'), findsNothing);
    expect(find.textContaining('正式能力'), findsNothing);
    expect(find.textContaining('占位能力'), findsNothing);
    expect(find.textContaining('生成时间'), findsNothing);
    expect(find.textContaining('预览日志'), findsNothing);
    expect(find.text('返回设置中心'), findsOneWidget);
    expect(find.text('合盘预览'), findsWidgets);
    expect(find.text('对比盘预览'), findsWidgets);
    expect(find.text('行运预览'), findsWidgets);
    expect(find.text('返照预览'), findsWidgets);
    expect(find.textContaining('EliteSync'), findsNothing);
    expect(find.textContaining('以 示例人物 的当前年龄'), findsWidgets);
    expect(find.textContaining('示例人物 × 示例人物'), findsWidgets);
    expect(find.textContaining('这些样例不是你的个人结论'), findsOneWidget);
    expect(identical(bundle.requests, requestsBeforeRender), isTrue);
    expect(bundle.pair.primaryName, 'EliteSync');
    expect(bundle.pair.secondaryName, 'EliteSync');
    expect(bundle.pair.summary, 'EliteSync × EliteSync 对照');
  });

  testWidgets(
    'advanced preview masks fallback identity with animations enabled',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final bundle = _identityBundle();

      await tester.pumpWidget(
        _wrap(
          const AstroAdvancedPreviewPage(),
          overrides: [
            astroAdvancedPreviewProvider.overrideWith((ref) async => bundle),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('EliteSync'), findsNothing);
      expect(find.textContaining('示例人物 × 示例人物'), findsWidgets);
      expect(find.textContaining('不是你的个人结论'), findsWidgets);
      expect(bundle.pair.primaryName, 'EliteSync');
      expect(bundle.requests.pair, const {'route_mode': 'modern'});
    },
  );
}
