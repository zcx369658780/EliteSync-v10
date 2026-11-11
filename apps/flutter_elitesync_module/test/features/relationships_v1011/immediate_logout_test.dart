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
  Future<bool> purgeLegacyPrivateCache() async => true;
  @override
  Future<bool> tryPurgeLegacyPrivateChatCache() async => true;
}

class _Secure extends support.FakeSecureStorageService {
  Completer<void>? queueWrite;
  @override
  Future<void> write(String key, String value) async {
    if (key == 'pending_logout_credentials' && queueWrite != null) {
      await queueWrite!.future;
    }
    await super.write(key, value);
  }
}

void main() {
  testWidgets('immediate logout receipts remain truthful across account changes', (
    tester,
  ) async {
    // The production pending queue is process-wide. Keep its futures in one
    // widget-test clock while exercising successive account/logout lifetimes.
    for (final scenario in [
      'confirmed',
      'network_failure',
      'unrecognized_receipt',
      'new_login',
      'new_logout',
      'cleanup_failure',
      'account_changed_during_queue_write',
    ]) {
      final secure = _Secure();
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
      // Exercise logout from an explicit active session. Persisted credentials
      // and a plaintext fixture profile alone cannot authenticate on startup.
      await container.read(sessionProvider.future);
      await container
          .read(sessionProvider.notifier)
          .setAuthenticated(
            accessToken: 'old-access',
            refreshToken: 'old-refresh',
          );
      if (scenario == 'cleanup_failure') local.throwOnRemove = true;
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
      try {
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
        if (scenario == 'account_changed_during_queue_write') {
          secure.queueWrite = Completer<void>();
        }
        await tester.tap(find.text('退出'));
        await tester.pumpAndSettle();
        if (scenario == 'account_changed_during_queue_write') {
          await container
              .read(sessionProvider.notifier)
              .setAuthenticated(
                accessToken: 'new-access',
                refreshToken: 'new-refresh',
              );
          await container
              .read(sessionProvider.notifier)
              .setUnauthenticated(notice: 'New account logout pending');
          final newerPending = PendingLogoutStore.add(secure, 'new-refresh');
          secure.queueWrite!.complete();
          await tester.pumpAndSettle();
          await newerPending;
          if (api.sentOptions != null) {
            api.pending.complete(
              const NetworkSuccess({'ok': true, 'status': 'SESSION_REVOKED'}),
            );
            await tester.pumpAndSettle();
          }
          expect(
            container.read(sessionProvider).requireValue.notice,
            'New account logout pending',
          );
          expect(api.sentOptions, isNull);
          expect(await PendingLogoutStore.read(secure), [
            'old-refresh',
            'new-refresh',
          ]);
          continue;
        }
        expect(api.pending.isCompleted, false);
        expect(container.read(sessionProvider).asData?.value.isLoggedIn, false);
        if (scenario != 'cleanup_failure') {
          expect(await secure.read(CacheKeys.accessToken), isNull);
          expect(await secure.read(CacheKeys.refreshToken), isNull);
        }
        expect(find.text('LOGIN AFTER LOCAL LOGOUT'), findsOneWidget);
        expect(await PendingLogoutStore.read(secure), ['old-refresh']);
        expect(
          api.sentOptions?.headers?['Authorization'],
          'Bearer old-refresh',
        );
        if (scenario == 'new_login' || scenario == 'new_logout') {
          local.throwOnRemove = false;
          await container
              .read(sessionProvider.notifier)
              .setAuthenticated(
                accessToken: 'new-access',
                refreshToken: 'new-refresh',
              );
          if (scenario == 'new_logout') {
            await PendingLogoutStore.add(secure, 'new-refresh');
            await container
                .read(sessionProvider.notifier)
                .setUnauthenticated(notice: 'New account logout pending');
          }
        }
        // Completion after the settings widget disposed uses captured dependencies.
        api.pending.complete(
          scenario == 'network_failure'
              ? const NetworkFailure(message: 'offline', statusCode: 503)
              : NetworkSuccess({
                  'ok': true,
                  if (scenario != 'unrecognized_receipt')
                    'status': 'SESSION_REVOKED',
                }),
        );
        await tester.pumpAndSettle();
        final session = container.read(sessionProvider).requireValue;
        if (scenario == 'network_failure' ||
            scenario == 'unrecognized_receipt') {
          expect(await PendingLogoutStore.read(secure), ['old-refresh']);
          expect(session.notice, contains('尚未确认'));
        } else if (scenario == 'new_login') {
          expect(await PendingLogoutStore.read(secure), isEmpty);
          expect(session.isLoggedIn, isTrue);
          expect(session.accessToken, 'new-access');
          expect(session.notice, isNull);
        } else if (scenario == 'new_logout') {
          expect(await PendingLogoutStore.read(secure), ['new-refresh']);
          expect(session.notice, 'New account logout pending');
        } else {
          expect(await PendingLogoutStore.read(secure), isEmpty);
          expect(session.notice, contains('撤销已确认'));
          if (scenario == 'cleanup_failure') {
            expect(session.notice, contains('本地清理未完成'));
          }
        }
        expect(tester.takeException(), isNull);
      } finally {
        if (secure.queueWrite?.isCompleted == false) {
          secure.queueWrite!.complete();
        }
        if (!api.pending.isCompleted) {
          api.pending.complete(
            const NetworkFailure(message: 'fixture cleanup'),
          );
        }
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }
  });
}
