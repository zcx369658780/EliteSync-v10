import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/components/controls/app_switch.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/about_update_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = <String, Object?>{};
  bool returnFalseOnWrite = false;
  bool throwOnWrite = false;
  bool throwOnRemove = false;

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    if (throwOnWrite) throw StateError('raw local write failure');
    if (returnFalseOnWrite) return false;
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    if (throwOnWrite) throw StateError('raw local write failure');
    if (returnFalseOnWrite) return false;
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
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (throwOnRemove) throw StateError('raw local remove failure');
    _values.remove(key);
    return true;
  }
}

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}

class FakeApiClient extends ApiClient {
  FakeApiClient({this.adminProbeAllowed = false}) : super(dio: Dio());

  final bool adminProbeAllowed;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path == '/api/v1/app/health') {
      return NetworkSuccess({
        'status': 'ok',
        'environment': 'test',
        'app_version': '0.08.03',
        'checks': {
          'database': {'ok': true},
        },
      });
    }
    if (path == '/api/v1/admin/users') {
      return adminProbeAllowed
          ? NetworkSuccess({'items': <Map<String, Object?>>[]})
          : NetworkFailure(message: 'admin access required', statusCode: 403);
    }
    return NetworkSuccess({
      'latest_version_name': '0.08.03',
      'has_update': false,
      'force_update': false,
    });
  }
}

Future<FakeLocalStorageService> _pumpSettingsPage(
  WidgetTester tester, {
  required AppFlavor flavor,
  required String? phone,
  String? role = 'user',
  Map<String, Object?> profileOverrides = const {},
  bool adminProbeAllowed = false,
  bool withAstroRoute = false,
  bool withHomeRoute = false,
  FakeLocalStorageService? localStorage,
}) async {
  final storage = localStorage ?? FakeLocalStorageService();
  final secureStorage = FakeSecureStorageService();

  if (phone != null) {
    await secureStorage.write(CacheKeys.accessToken, 'test-token');
    final profile = <String, Object?>{
      'id': 8,
      'phone': phone,
      'nickname': 'tester',
      ...profileOverrides,
    };
    if (role != null) {
      profile['role'] = role;
    }
    await storage.setJson(CacheKeys.lastKnownProfile, profile);
  }

  final Widget app;
  if (withAstroRoute || withHomeRoute) {
    final router = GoRouter(
      initialLocation: AppRouteNames.settings,
      routes: [
        GoRoute(
          path: AppRouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRouteNames.astroChartSettings,
          builder: (context, state) =>
              const Scaffold(body: Text('ASTRO CHART SETTINGS ROUTE')),
        ),
        if (withHomeRoute)
          GoRoute(
            path: AppRouteNames.home,
            builder: (context, state) =>
                const Scaffold(body: Text('TEST HOME ROUTE')),
          ),
      ],
    );
    addTearDown(router.dispose);
    app = MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  } else {
    app = MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const SettingsPage(),
    );
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: flavor,
            appName: 'EliteSync',
            apiBaseUrl: 'http://localhost',
            useMockData: true,
          ),
        ),
        localStorageProvider.overrideWithValue(storage),
        secureStorageProvider.overrideWithValue(secureStorage),
        apiClientProvider.overrideWithValue(
          FakeApiClient(adminProbeAllowed: adminProbeAllowed),
        ),
      ],
      child: app,
    ),
  );

  await tester.pumpAndSettle();
  return storage;
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}

void main() {
  void expectNoForbiddenVisibleTerms(String text, List<String> forbidden) {
    for (final term in forbidden) {
      expect(text, isNot(contains(term)));
      expect(text.toLowerCase(), isNot(contains(term.toLowerCase())));
    }
  }

  testWidgets('SettingsPage stays usable at narrow width', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    expect(find.text('设置中心'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Settings orders ordinary groups from local preferences to destructive actions',
    (tester) async {
      tester.view.physicalSize = const Size(320, 3000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      await _pumpSettingsPage(
        tester,
        flavor: AppFlavor.prod,
        phone: '17094346566',
      );

      final orderedLabels = [
        '显示与外观',
        '提醒与性能',
        '资料与隐私',
        '账号与安全',
        '帮助与反馈',
        '本机缓存与重置',
        '退出账号',
      ];
      expect(
        tester
            .widgetList<SettingsGroup>(find.byType(SettingsGroup))
            .map((group) => group.title)
            .toList(),
        orderedLabels,
      );

      expect(find.text('运营管理'), findsNothing);
      expect(find.text('开发者预览'), findsNothing);
      expect(find.text('退出登录'), findsOneWidget);
      for (final tile in tester.widgetList<SettingsItemTile>(
        find.byType(SettingsItemTile),
      )) {
        expect(
          tester.getSize(find.byWidget(tile)).height,
          greaterThanOrEqualTo(48),
        );
      }
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    },
  );

  testWidgets('Settings uses one consistent switch component', (tester) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    for (final label in ['夜间模式', '性能模式', '站内提醒']) {
      await tester.scrollUntilVisible(
        find.text(label),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text(label),
        matching: find.byType(SettingsItemTile),
      );
      expect(
        find.descendant(of: tile, matching: find.byType(AppSwitch)),
        findsOneWidget,
      );
    }
  });

  testWidgets('Settings tabs from local preferences into later key groups', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );
    final labels = ['夜间模式', '盘面设置', '站内提醒', '性能模式', '隐私设置'];
    var next = 0;
    for (var press = 0; press < 30 && next < labels.length; press++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focusedContext = tester.binding.focusManager.primaryFocus?.context;
      if (focusedContext != null &&
          find
              .descendant(
                of: find.byElementPredicate(
                  (element) => element == focusedContext,
                ),
                matching: find.text(labels[next]),
              )
              .evaluate()
              .isNotEmpty) {
        next++;
      }
    }
    expect(next, labels.length);
  });

  testWidgets('Settings keeps Astro as a bounded configuration entry', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
      withAstroRoute: true,
    );

    expect(find.text('盘面设置'), findsOneWidget);
    expect(find.text('星盘元素、预设档位与恢复默认'), findsOneWidget);
    expect(find.text('星盘关系参考'), findsNothing);

    await tester.tap(find.text('盘面设置'));
    await tester.pumpAndSettle();
    expect(find.text('ASTRO CHART SETTINGS ROUTE'), findsOneWidget);
  });

  testWidgets('SettingsPage shows real jobs and omits pseudo-settings', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
    );

    expect(find.text('解释与建议设置'), findsNothing);
    expect(find.text('关系解释提示'), findsNothing);
    expect(find.text('个人表达建议'), findsNothing);
    expect(find.text('聊天开场建议'), findsNothing);
    expect(find.text('个人空间外观'), findsNothing);
    expect(find.textContaining('预览层'), findsNothing);
    expect(find.textContaining('后续完善'), findsNothing);
    expect(find.text('通过后端接口更新登录密码'), findsNothing);
    expect(find.text('查看当前隐私边界与安全说明'), findsOneWidget);
    expect(find.text('控制资料可见范围与城市展示'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('帮助与反馈'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('帮助与反馈'), findsOneWidget);
    expect(find.text('新手引导'), findsOneWidget);
    expect(find.text('随时重新查看使用说明'), findsOneWidget);
    expect(find.text('帮我们改进体验'), findsOneWidget);
    expect(find.text('在本机整理可复制反馈，由你选择发送方式'), findsOneWidget);
    expect(find.text('查看当前安装版本、手动检查更新和更新说明'), findsOneWidget);
    expect(find.text('支持与帮助信息'), findsNothing);
    expect(
      _visibleText(tester).indexOf('帮我们改进体验'),
      lessThan(_visibleText(tester).indexOf('版本中心')),
    );
  });

  testWidgets('Settings replay opens the common flow without resetting state', (
    tester,
  ) async {
    final storage = await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
    );
    await storage.setString(CacheKeys.firstUseOnboardingV1Status, 'completed');

    await tester.scrollUntilVisible(
      find.text('新手引导'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('新手引导'));
    await tester.pumpAndSettle();

    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('先从慢约进展开始'), findsOneWidget);
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(
      await storage.getString(CacheKeys.firstUseOnboardingV1Status),
      'completed',
    );
    expect(find.text('新手引导'), findsOneWidget);
  });

  testWidgets('Settings replay completion returns to canonical Home', (
    tester,
  ) async {
    final storage = await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
      withHomeRoute: true,
    );
    await storage.setString(CacheKeys.firstUseOnboardingV1Status, 'completed');

    await tester.scrollUntilVisible(
      find.text('新手引导'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('新手引导'));
    await tester.pumpAndSettle();

    for (var step = 1; step < 5; step += 1) {
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('TEST HOME ROUTE'), findsOneWidget);
    expect(
      await storage.getString(CacheKeys.firstUseOnboardingV1Status),
      'completed',
    );
  });

  testWidgets('Settings confirms local preference reset and cache clearing', (
    tester,
  ) async {
    final storage = await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );
    await storage.setString(CacheKeys.contentPreferredTag, 'coffee');
    await storage.setString(CacheKeys.homeFeedSnapshot, 'snapshot');
    await storage.setString(
      CacheKeys.messagesConversationSnapshot,
      'conversation-snapshot',
    );

    await tester.scrollUntilVisible(
      find.text('重置浏览内容顺序'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('重置浏览内容顺序'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SettingsItemTile>(
            find.ancestor(
              of: find.text('重置浏览内容顺序'),
              matching: find.byType(SettingsItemTile),
            ),
          )
          .variant,
      SettingsItemVariant.destructive,
    );
    await tester.tap(find.text('重置浏览内容顺序'));
    await tester.pumpAndSettle();

    expect(find.text('重置浏览内容顺序？'), findsOneWidget);
    expect(find.textContaining('清除本机记录的内容标签偏好'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(await storage.getString(CacheKeys.contentPreferredTag), 'coffee');

    await tester.ensureVisible(find.text('重置浏览内容顺序'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('重置浏览内容顺序'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('重置'));
    await tester.pumpAndSettle();
    expect(await storage.getString(CacheKeys.contentPreferredTag), isNull);
    expect(
      await storage.getString(CacheKeys.messagesConversationSnapshot),
      'conversation-snapshot',
    );

    await tester.scrollUntilVisible(
      find.text('清空本机内容缓存'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('清空本机内容缓存'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SettingsItemTile>(
            find.ancestor(
              of: find.text('清空本机内容缓存'),
              matching: find.byType(SettingsItemTile),
            ),
          )
          .variant,
      SettingsItemVariant.destructive,
    );
    await tester.tap(find.text('清空本机内容缓存'));
    await tester.pumpAndSettle();
    expect(find.text('清空本机内容缓存？'), findsOneWidget);
    expect(find.textContaining('不会删除账号或聊天记录'), findsOneWidget);
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();
    expect(await storage.getString(CacheKeys.homeFeedSnapshot), isNull);
    expect(
      await storage.getString(CacheKeys.messagesConversationSnapshot),
      isNull,
    );
  });

  testWidgets('SettingsPage shows admin entries for admin session role', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '13772423130',
      role: 'admin',
    );

    await tester.scrollUntilVisible(
      find.text('运营管理'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('运营管理'), findsOneWidget);
    expect(find.text('运营看板'), findsOneWidget);
    expect(find.text('运营后台'), findsOneWidget);
    expect(find.text('关系运行态本地预览'), findsNothing);
  });

  testWidgets('SettingsPage recognizes admin role with whitespace and case', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '13772423130',
      role: ' Admin ',
    );

    await tester.scrollUntilVisible(
      find.text('运营管理'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('运营管理'), findsOneWidget);
    expect(find.text('运营看板'), findsOneWidget);
    expect(find.text('运营后台'), findsOneWidget);
  });

  testWidgets('SettingsPage recognizes admin group fallback', (tester) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '13772423130',
      role: null,
      profileOverrides: {'group': 'admin'},
    );

    await tester.scrollUntilVisible(
      find.text('运营管理'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('运营管理'), findsOneWidget);
    expect(find.text('运营看板'), findsOneWidget);
    expect(find.text('运营后台'), findsOneWidget);
  });

  testWidgets('SettingsPage opens debug relationship preview in dev flavor', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
      role: 'admin',
    );

    await tester.scrollUntilVisible(
      find.text('关系运行态本地预览'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('关系运行态本地预览'), findsOneWidget);
    expect(find.text('开发者预览'), findsOneWidget);
    expect(find.text('仅调试 / 开发环境，本地样例，不接数据连接或数据库'), findsOneWidget);
    expect(find.text('运营管理'), findsOneWidget);

    await tester.ensureVisible(find.text('关系运行态本地预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.developer_mode_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('开发者预览入口检查'), findsOneWidget);
    expect(find.text('仅调试 / 开发'), findsWidgets);
    expect(find.text('本地样例'), findsWidgets);
    expect(find.textContaining('不触发数据连接'), findsOneWidget);
    expect(find.textContaining('不写入数据库'), findsOneWidget);
    expect(find.text('本地关系预览：等待揭晓'), findsOneWidget);
    expect(find.text('本地关系预览：可查看线索'), findsOneWidget);
    expect(find.text('本地关系预览：开场草稿'), findsOneWidget);
    expect(find.text('仅本地开场草稿'), findsOneWidget);
  });

  testWidgets('SettingsPage keeps help and feedback compact', (tester) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    await tester.scrollUntilVisible(
      find.text('帮助与反馈'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('帮助与反馈'), findsOneWidget);
    expect(find.text('支持与帮助信息'), findsNothing);
    expect(find.text('版本中心'), findsOneWidget);
    expect(find.text('支持与说明'), findsNothing);
    expect(find.text('反馈说明'), findsNothing);
  });

  testWidgets('AboutUpdatePage explains current version and support entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
            ),
          ),
          apiClientProvider.overrideWithValue(FakeApiClient()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const AboutUpdatePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('查看当前版本与更新说明'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('当前版本'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('当前版本'), findsOneWidget);
    expect(find.text('本机安装版本与手动更新状态'), findsOneWidget);
    expect(find.text('产品版本'), findsOneWidget);
    expect(find.text('查看构建与页面模块详情'), findsNothing);
    expect(find.text('产品构建号'), findsNothing);
    expect(find.text('页面模块版本'), findsNothing);
    expect(find.text('手动检查更新'), findsOneWidget);
    expect(find.text('刷新更新状态'), findsNothing);
    expect(find.text('更新说明'), findsOneWidget);
    await tester.tap(find.text('手动检查更新'));
    await tester.pumpAndSettle();

    expect(_visibleText(tester), contains('当前已是可用版本（最新版本参考: 0.08.03）'));
    expect(find.text('发现强制更新'), findsNothing);
    expect(find.text('发现新版本'), findsNothing);

    expect(
      _visibleText(tester).indexOf('当前版本'),
      lessThan(_visibleText(tester).indexOf('手动检查更新')),
    );
    expect(
      _visibleText(tester).indexOf('手动检查更新'),
      lessThan(_visibleText(tester).indexOf('更新说明')),
    );

    await tester.scrollUntilVisible(
      find.text('更新说明'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('更新说明'), findsOneWidget);
    expect(find.textContaining('是否有可用更新，以手动检查结果为准'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('遇到版本问题？把问题整理一下'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('遇到版本问题？把问题整理一下'), findsOneWidget);
    expect(find.text('反馈版本或更新问题'), findsOneWidget);
    expect(find.textContaining('反馈版本或更新问题'), findsOneWidget);
  });

  testWidgets('SettingsPage hides admin entries for non-admin prod user', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    expect(find.text('开发者'), findsNothing);
    expect(find.text('运营管理'), findsNothing);
    expect(find.text('运营看板'), findsNothing);
    expect(find.text('运营后台'), findsNothing);
    expect(find.text('关系运行态本地预览'), findsNothing);
  });

  testWidgets('SettingsPage hides admin entries for non-admin dev user', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
    );

    expect(find.text('开发者'), findsNothing);
    expect(find.text('运营管理'), findsNothing);
    expect(find.text('运营看板'), findsNothing);
    expect(find.text('运营后台'), findsNothing);
    expect(find.text('关系运行态本地预览'), findsNothing);
  });

  testWidgets(
    'SettingsPage can show admin entries after backend probe succeeds',
    (tester) async {
      await _pumpSettingsPage(
        tester,
        flavor: AppFlavor.prod,
        phone: '13772423130',
        adminProbeAllowed: true,
      );

      await tester.scrollUntilVisible(
        find.text('运营管理'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('运营管理'), findsOneWidget);
      expect(find.text('运营看板'), findsOneWidget);
      expect(find.text('运营后台'), findsOneWidget);
    },
  );

  testWidgets('Settings and Version surfaces hide D7B forbidden visible copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 6200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    var visibleText = _visibleText(tester);
    expectNoForbiddenVisibleTerms(visibleText, [
      'mock',
      'test',
      'debug',
      'payload',
      'release-chain',
      'gate',
      'oracle',
      '不做真正持久化',
      '本地/mock 卡片',
      'RTC 骨架',
      'Alpha',
      'internal',
      'dev',
      'dating',
      '通过后端接口更新登录密码',
      '/api/v1/app/health',
      '/api/v1/app/version/check',
      '已发布最新 APK',
      '生产验证通过',
      '内测与诊断信息',
      'smoke',
      'staging',
      'endpoint',
      'API',
      'schema',
      '必须',
      '立即',
      '精准',
      '保证',
    ]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
            ),
          ),
          apiClientProvider.overrideWithValue(FakeApiClient()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const AboutUpdatePage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    visibleText = _visibleText(tester);
    expectNoForbiddenVisibleTerms(visibleText, [
      'mock',
      'test',
      'debug',
      'payload',
      'release-chain',
      'gate',
      'oracle',
      '接口',
      '不做真正持久化',
      '本地/mock 卡片',
      'RTC 骨架',
      'Alpha',
      'internal',
      'dev',
      'dating',
      'release readiness',
      'production verification',
      'Flutter 模块版本',
      'module sync',
      'Flutter module AAR',
      'display-only',
      'candidate_visualization',
      'human_review_required',
      'PASS_WITH_OBSERVATIONS',
      '/api/v1/app/health',
      '/api/v1/app/version/check',
      '已发布最新 APK',
      '生产验证通过',
      'smoke',
      'staging',
      'endpoint',
      'schema',
      '必须',
      '立即',
      '精准',
      '保证',
    ]);

    final rawAboutConfig = File(
      'assets/config/about_update_0_xx.json',
    ).readAsStringSync();
    final historyItems =
        (jsonDecode(rawAboutConfig) as Map<String, dynamic>)['history_items']
            as List<dynamic>;
    final sanitizedHistory = historyItems
        .map((item) => sanitizeVisibleUpdateHistoryCopy(item.toString()))
        .join('\n');

    expect(sanitizedHistory, contains('0.06.09'));
    expect(sanitizedHistory, contains('0.01.07'));
    expectNoForbiddenVisibleTerms(sanitizedHistory, [
      '接口',
      'Alpha',
      'mock',
      'oracle',
      'release-chain',
      '/api/v1/app/health',
      '/api/v1/app/version/check',
      '已发布最新 APK',
      '生产验证通过',
      'release readiness',
      'production verification',
      'module sync',
      'Flutter module AAR',
      'display-only',
      'candidate_visualization',
      'human_review_required',
      'PASS_WITH_OBSERVATIONS',
      'smoke',
      'staging',
      'endpoint',
      'schema',
      '必须',
      '立即',
      '精准',
      '保证',
    ]);
  });

  testWidgets(
    'Settings content order uses ordinary labels and preserves mode values',
    (tester) async {
      final storage = await _pumpSettingsPage(
        tester,
        flavor: AppFlavor.prod,
        phone: '17094346566',
      );

      await tester.scrollUntilVisible(
        find.textContaining('当前：按系统推荐排列'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'), findsOneWidget);

      await tester.tap(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'));
      await tester.pumpAndSettle();
      expect(await storage.getString(CacheKeys.contentRankerMode), 'weighted');
      expect(find.text('当前：优先展示更感兴趣的内容（仅调整本机浏览偏好）'), findsOneWidget);

      await tester.tap(find.text('当前：优先展示更感兴趣的内容（仅调整本机浏览偏好）'));
      await tester.pumpAndSettle();
      expect(await storage.getString(CacheKeys.contentRankerMode), 'legacy');
      expect(find.text('当前：按原有顺序展示（仅调整本机浏览偏好）'), findsOneWidget);

      await tester.tap(find.text('当前：按原有顺序展示（仅调整本机浏览偏好）'));
      await tester.pumpAndSettle();
      expect(await storage.getString(CacheKeys.contentRankerMode), 'auto');
      expect(find.textContaining('浏览内容顺序已切换：按系统推荐排列'), findsOneWidget);
      expect(find.text('新排序'), findsNothing);
      expect(find.text('旧排序'), findsNothing);
      expect(find.text('自动'), findsNothing);
    },
  );

  testWidgets(
    'Settings content order rejects false and thrown local writes without success',
    (tester) async {
      final storage = await _pumpSettingsPage(
        tester,
        flavor: AppFlavor.prod,
        phone: '17094346566',
      );
      await tester.scrollUntilVisible(
        find.textContaining('当前：按系统推荐排列'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      const browseCacheKeys = [
        CacheKeys.homeFeedSnapshot,
        CacheKeys.discoverFeedSnapshot,
        CacheKeys.homeSearchHistory,
        CacheKeys.discoverSearchHistory,
      ];
      for (final key in browseCacheKeys) {
        await storage.setString(key, 'preserved-$key');
      }

      storage.returnFalseOnWrite = true;
      await tester.tap(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'));
      await tester.pumpAndSettle();
      expect(await storage.getString(CacheKeys.contentRankerMode), isNull);
      expect(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'), findsOneWidget);
      expect(find.text('暂时无法保存浏览内容顺序，请重试'), findsOneWidget);
      expect(find.textContaining('浏览内容顺序已切换'), findsNothing);
      for (final key in browseCacheKeys) {
        expect(await storage.getString(key), 'preserved-$key');
      }

      storage.returnFalseOnWrite = false;
      storage.throwOnWrite = true;
      await tester.tap(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'));
      await tester.pumpAndSettle();
      expect(await storage.getString(CacheKeys.contentRankerMode), isNull);
      expect(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'), findsOneWidget);
      expect(find.textContaining('raw local write failure'), findsNothing);
      expect(find.textContaining('浏览内容顺序已切换'), findsNothing);
      for (final key in browseCacheKeys) {
        expect(await storage.getString(key), 'preserved-$key');
      }

      await tester.pump(const Duration(seconds: 4));
      storage.throwOnWrite = false;
      storage.throwOnRemove = true;
      await tester.tap(find.text('当前：按系统推荐排列（仅调整本机浏览偏好）'));
      await tester.pumpAndSettle();
      expect(await storage.getString(CacheKeys.contentRankerMode), 'weighted');
      expect(find.text('当前：优先展示更感兴趣的内容（仅调整本机浏览偏好）'), findsOneWidget);
      expect(find.textContaining('raw local remove failure'), findsNothing);
      expect(find.text('浏览内容顺序已保存，但本机内容暂时无法刷新，请重新进入查看'), findsOneWidget);
      expect(find.textContaining('浏览内容顺序已切换'), findsNothing);
    },
  );

  testWidgets('Settings switches keep state when local writes fail or throw', (
    tester,
  ) async {
    final storage = await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    storage.returnFalseOnWrite = true;
    await tester.scrollUntilVisible(
      find.text('性能模式'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('性能模式'));
    await tester.pumpAndSettle();
    expect(await storage.getBool(CacheKeys.performanceLiteMode), isNull);
    expect(find.text('暂时无法保存性能模式设置，请重试'), findsOneWidget);
    expect(find.textContaining('已开启性能模式'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    storage.returnFalseOnWrite = false;
    storage.throwOnWrite = true;
    await tester.scrollUntilVisible(
      find.text('站内提醒'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('站内提醒'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('站内提醒'));
    await tester.pumpAndSettle();
    expect(await storage.getBool(CacheKeys.pushNotificationEnabled), isNull);
    expect(find.text('暂时无法保存站内提醒设置，请重试'), findsOneWidget);
    expect(find.textContaining('raw local write failure'), findsNothing);
  });
}
