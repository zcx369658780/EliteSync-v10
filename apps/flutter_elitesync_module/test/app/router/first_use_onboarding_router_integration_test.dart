import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync_module/features/progress/presentation/pages/progress_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RouterFakeLocalStorage extends LocalStorageService {
  String? onboardingStatus;
  int onboardingReadCount = 0;

  @override
  Future<String?> getString(String key) async {
    if (key == CacheKeys.firstUseOnboardingV1Status) {
      onboardingReadCount += 1;
      return onboardingStatus;
    }
    return null;
  }

  @override
  Future<bool?> getBool(String key) async {
    if (key == CacheKeys.performanceLiteMode) return true;
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;

  @override
  Future<bool> setString(String key, String value) async {
    if (key == CacheKeys.firstUseOnboardingV1Status) {
      onboardingStatus = value;
    }
    return true;
  }
}

class _FakeHomeNotifier extends HomeNotifier {
  @override
  Future<HomeUiState> build() async => const HomeUiState();
}

Widget _routerApp({
  required AuthStatus authStatus,
  required _RouterFakeLocalStorage storage,
}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync E2 Router Test',
          apiBaseUrl: 'http://localhost',
          useMockData: true,
          initialRoute: AppRouteNames.home,
        ),
      ),
      authStatusProvider.overrideWithValue(authStatus),
      localStorageProvider.overrideWithValue(storage),
      appShellRtcInviteWatcherEnabledProvider.overrideWithValue(false),
      homeProvider.overrideWith(_FakeHomeNotifier.new),
    ],
    child: Consumer(
      builder: (context, ref, child) => MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routerConfig: ref.watch(appRouterProvider),
      ),
    ),
  );
}

Future<void> _pumpRouter(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets(
    'authenticated shell reaches four target destinations and Match child',
    (tester) async {
      final storage = _RouterFakeLocalStorage()..onboardingStatus = 'completed';
      await _pumpRouter(
        tester,
        _routerApp(authStatus: AuthStatus.authenticated, storage: storage),
      );

      final dock = find.byType(FloatingDockBottomBar);
      expect(dock, findsOneWidget);
      expect(
        tester
            .widget<FloatingDockBottomBar>(dock)
            .items
            .map((item) => item.label)
            .toList(),
        ['首页', '进展', '消息', '我的'],
      );
      final destinations = <String, Type>{
        '首页': HomeShellPage,
        '进展': ProgressShellPage,
        '消息': MessagesShellPage,
        '我的': MeShellPage,
      };
      for (final indexedEntry in destinations.entries.indexed) {
        final index = indexedEntry.$1;
        final entry = indexedEntry.$2;
        await tester.tap(
          find.descendant(of: dock, matching: find.text(entry.key)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(entry.value), findsOneWidget);
        final currentDock = tester.widget<FloatingDockBottomBar>(dock);
        expect(currentDock.currentIndex, index);
        expect(currentDock.browseMode, index != 1);
      }

      await tester.tap(find.descendant(of: dock, matching: find.text('进展')));
      await tester.pump();
      await tester.tap(find.byKey(ProgressPage.matchEntryKey));
      await tester.pump();
      expect(find.byType(MatchShellPage), findsOneWidget);

      expect(
        tester
            .widget<FloatingDockBottomBar>(dock)
            .items
            .map((item) => item.label),
        isNot(containsAll(['发现', '匹配'])),
      );
      expect(find.text('管理'), findsNothing);
      await tester.pump(const Duration(seconds: 10));
    },
  );

  testWidgets(
    'authenticated home AppShell opens E2 and skip suppresses a new session',
    (tester) async {
      final storage = _RouterFakeLocalStorage();

      await _pumpRouter(
        tester,
        _routerApp(authStatus: AuthStatus.authenticated, storage: storage),
      );

      expect(storage.onboardingReadCount, 1);
      expect(find.text('先从慢约进展开始'), findsOneWidget);

      await tester.tap(find.text('跳过'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));
      expect(storage.onboardingStatus, 'skipped');
      expect(find.text('先从慢约进展开始'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await _pumpRouter(
        tester,
        _routerApp(authStatus: AuthStatus.authenticated, storage: storage),
      );

      expect(storage.onboardingReadCount, 2);
      expect(find.text('先从慢约进展开始'), findsNothing);
    },
  );

  testWidgets(
    'unauthenticated initial home redirects to login without E2 storage read',
    (tester) async {
      final storage = _RouterFakeLocalStorage();

      await _pumpRouter(
        tester,
        _routerApp(authStatus: AuthStatus.unauthenticated, storage: storage),
      );

      expect(find.text('账号登录'), findsOneWidget);
      expect(storage.onboardingReadCount, 0);
      expect(find.text('先从慢约进展开始'), findsNothing);
    },
  );
}
