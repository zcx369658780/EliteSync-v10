import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RouterStorage extends LocalStorageService {
  @override
  Future<String?> getString(String key) async {
    if (key == CacheKeys.firstUseOnboardingV1Status) return 'completed';
    return null;
  }

  @override
  Future<bool?> getBool(String key) async => true;

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;
}

class _FakeHomeNotifier extends HomeNotifier {
  @override
  Future<HomeUiState> build() async => const HomeUiState();
}

Widget _app({String initialRoute = '/missing-route'}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync Router Test',
          apiBaseUrl: 'http://localhost',
          useMockData: true,
          initialRoute: initialRoute,
        ),
      ),
      authStatusProvider.overrideWithValue(AuthStatus.authenticated),
      localStorageProvider.overrideWithValue(_RouterStorage()),
      appShellRtcInviteWatcherEnabledProvider.overrideWithValue(false),
      homeProvider.overrideWith(_FakeHomeNotifier.new),
    ],
    child: Consumer(
      builder: (context, ref, child) => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: ref.watch(appRouterProvider),
      ),
    ),
  );
}

Future<void> _settleRouter(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

void main() {
  testWidgets('invalid initial route offers Home recovery', (tester) async {
    await tester.pumpWidget(_app());
    await _settleRouter(tester);

    expect(find.text('页面未找到'), findsOneWidget);
    expect(find.text('返回首页'), findsOneWidget);
    expect(find.text('返回上一页'), findsOneWidget);

    await tester.tap(find.text('返回首页'));
    await _settleRouter(tester);
    expect(find.text('查看慢约进展'), findsOneWidget);
  });

  testWidgets('invalid pushed route can recover back', (tester) async {
    await tester.pumpWidget(_app(initialRoute: AppRouteNames.home));
    await _settleRouter(tester);
    expect(find.text('查看慢约进展'), findsOneWidget);

    final context = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(context);
    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);
    router.push('/missing-pushed-route');
    await _settleRouter(tester);
    expect(find.text('页面未找到'), findsOneWidget);

    await tester.tap(find.text('返回上一页'));
    await _settleRouter(tester);
    expect(find.text('查看慢约进展'), findsOneWidget);
  });
}
