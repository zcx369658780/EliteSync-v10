import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/settings_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/pending_logout_store.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import '../profile/presentation/pages/settings_page_test.dart' as support;

class _HangingLogoutApi extends support.FakeApiClient {
  final pending = Completer<NetworkResult<Map<String, dynamic>>>();
  Options? sentOptions;
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    expect(path, '/api/v1/auth/logout');
    sentOptions = options;
    return pending.future;
  }
}

class _Local extends support.FakeLocalStorageService {
  @override
  Future<bool> tryPurgeLegacyPrivateChatCache() async => true;
}

void main() {
  testWidgets(
    'local logout and navigation complete while server request remains pending',
    (tester) async {
      final secure = support.FakeSecureStorageService();
      final local = _Local();
      await secure.write(CacheKeys.accessToken, 'old-access');
      await secure.write(CacheKeys.refreshToken, 'old-refresh');
      await local.setJson(CacheKeys.lastKnownProfile, {
        'id': 1,
        'phone': '',
        'role': 'user',
      });
      final api = _HangingLogoutApi();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          localStorageProvider.overrideWithValue(local),
          apiClientProvider.overrideWithValue(api),
          restrictedAccountClientProvider.overrideWithValue(api),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'Test',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: AppRouteNames.settings,
        routes: [
          GoRoute(
            path: AppRouteNames.settings,
            builder: (_, _) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRouteNames.login,
            builder: (_, _) =>
                const Scaffold(body: Text('LOGIN AFTER LOCAL LOGOUT')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('退出登录'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('退出'));
      await tester.pumpAndSettle();
      expect(api.pending.isCompleted, false);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, false);
      expect(await secure.read(CacheKeys.accessToken), isNull);
      expect(await secure.read(CacheKeys.refreshToken), isNull);
      expect(find.text('LOGIN AFTER LOCAL LOGOUT'), findsOneWidget);
      expect(await PendingLogoutStore.read(secure), ['old-refresh']);
      expect(api.sentOptions?.headers?['Authorization'], 'Bearer old-refresh');
      // Completion after the settings widget disposed uses captured dependencies.
      api.pending.complete(const NetworkSuccess({'ok': true}));
      await tester.pumpAndSettle();
      expect(await PendingLogoutStore.read(secure), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
