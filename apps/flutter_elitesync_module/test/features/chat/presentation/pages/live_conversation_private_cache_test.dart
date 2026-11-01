import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_conversation_list_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  bool refuseDelete = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async {
    if (!refuseDelete) values.remove(key);
  }
}

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-only',
    user: UserSummary(id: 1, phone: 'synthetic'),
  );
  void switchAccount() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'synthetic-new',
      user: UserSummary(id: 2, phone: 'synthetic'),
    ),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  bool offline = false;
  int reads = 0;
  int writes = 0;
  String text = '仅限测试的当前服务器内容';
  Completer<NetworkResult<Map<String, dynamic>>>? pending;
  NetworkResult<Map<String, dynamic>> success() => NetworkSuccess({
    'ok': true,
    'items': [
      {
        'peer_user_id': 2,
        'conversation_id': 12,
        'name': '合成会话对象',
        'last_message': text,
        'unread': 3,
      },
    ],
  });
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    reads++;
    if (pending != null) return pending!.future;
    if (offline) {
      return NetworkFailure(
        message: 'Connection error',
        error: DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    return success();
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    writes++;
    return const NetworkSuccess({'ok': true});
  }
}

class _Fixture {
  _Fixture(this.secure, this.cache, this.api, this.container, this.anchor);
  final _Secure secure;
  final PrivateCacheService cache;
  final _Api api;
  final ProviderContainer container;
  final Map<String, dynamic> anchor;
}

Future<_Fixture> _mount(
  WidgetTester tester, {
  required DateTime Function() wallNow,
  required Duration Function() elapsed,
}) async {
  SharedPreferences.setMockInitialValues({});
  final secure = _Secure();
  final api = _Api();
  final cache = PrivateCacheService.forTesting(
    secure,
    wallNow: wallNow,
    elapsed: elapsed,
  );
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure),
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
    ],
  );
  await container.read(sessionProvider.future);
  final now = DateTime.utc(2026, 10, 21);
  final anchor = {
    'user_id': 1,
    'device_id': 'synthetic-device',
    'session_id': 7,
    'login_at': now.toIso8601String(),
    'server_now': now.toIso8601String(),
    'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
    'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
  };
  await cache.establishLogin(userId: 1, retention: anchor);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: LiveConversationListPage()),
    ),
  );
  await tester.pumpAndSettle();
  return _Fixture(secure, cache, api, container, anchor);
}

Future<void> _dispose(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(const SizedBox.shrink());
  fixture.container.dispose();
}

void main() {
  testWidgets(
    'actual live list persists encrypted copy, offline is read only, reconnect hides until current HTTP succeeds',
    (tester) async {
      final now = DateTime.utc(2026, 10, 21);
      var elapsed = Duration.zero;
      final f = await _mount(
        tester,
        wallNow: () => now.add(elapsed),
        elapsed: () => elapsed,
      );
      expect(find.text('当前会话已按账户和设备加密保存。'), findsOneWidget);
      expect(find.text('仅限测试的当前服务器内容'), findsOneWidget);
      expect(
        f.secure.values.keys.any(
          (key) => key.contains('live-conversations%3Avisible'),
        ),
        isTrue,
      );
      elapsed = const Duration(days: 15);
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();
      expect(find.text('仅限测试的当前服务器内容'), findsNothing);
      expect(find.text('当前私有内容的读取资格已失效，请重新核验或在线登录。'), findsOneWidget);
      f.api.offline = true;
      await tester.tap(find.byTooltip('刷新会话'));
      await tester.pumpAndSettle();
      expect(find.text('仅限测试的当前服务器内容'), findsOneWidget);
      expect(find.text('离线只读：不可打开新会话、发送、隐藏或修改。'), findsOneWidget);
      final row = tester.widget<ListTile>(
        find.widgetWithText(ListTile, '合成会话对象'),
      );
      expect(row.onTap, isNull);
      expect(row.onLongPress, isNull);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
        isNull,
      );
      expect(f.api.writes, 0);
      f.api.offline = false;
      f.api.pending = Completer();
      await tester.tap(find.byTooltip('刷新会话'));
      await tester.pump();
      expect(find.text('仅限测试的当前服务器内容'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // A genuine online login is required before online use after day 15.
      elapsed = Duration.zero;
      await f.cache.establishLogin(
        userId: 1,
        retention: {...f.anchor, 'session_id': 8},
      );
      f.api.text = '重新授权的当前内容';
      f.api.pending!.complete(f.api.success());
      await tester.pumpAndSettle();
      expect(find.text('重新授权的当前内容'), findsOneWidget);
      expect(f.cache.isOffline, isFalse);
      await _dispose(tester, f);
    },
  );

  for (final failDelete in [false, true]) {
    testWidgets(
      'actual live list 30 day purge ${failDelete ? 'failure locks and retains receipt' : 'deletes owned ciphertext and reports completed'}',
      (tester) async {
        final now = DateTime.utc(2026, 10, 21);
        var elapsed = Duration.zero;
        final f = await _mount(
          tester,
          wallNow: () => now.add(elapsed),
          elapsed: () => elapsed,
        );
        f.secure.refuseDelete = failDelete;
        elapsed = const Duration(days: 30);
        await tester.pump(const Duration(minutes: 1));
        await tester.pumpAndSettle();
        expect(find.text('合成会话对象'), findsNothing);
        expect(find.text('仅限测试的当前服务器内容'), findsNothing);
        expect(
          find.text(
            failDelete
                ? '私有缓存清理失败，内容已锁定，请重新在线登录后重试清理。'
                : '私有缓存已到期并完成清理，请重新在线登录。',
          ),
          findsOneWidget,
        );
        expect(f.secure.values.isEmpty, !failDelete);
        await _dispose(tester, f);
      },
    );
  }

  testWidgets(
    'actual live list clock rollback hides prior online rows and a retry cannot unlock',
    (tester) async {
      final now = DateTime.utc(2026, 10, 21);
      var wallOffset = Duration.zero;
      final f = await _mount(
        tester,
        wallNow: () => now.add(wallOffset),
        elapsed: () => Duration.zero,
      );
      expect(find.text('合成会话对象'), findsOneWidget);
      wallOffset = const Duration(minutes: -2);
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();
      expect(find.text('合成会话对象'), findsNothing);
      expect(find.text('仅限测试的当前服务器内容'), findsNothing);
      final reads = f.api.reads;
      await tester.tap(find.byTooltip('刷新会话'));
      await tester.pumpAndSettle();
      expect(f.api.reads, reads);
      expect(find.textContaining('无法确认可信登录与设备时间'), findsOneWidget);
      await _dispose(tester, f);
    },
  );

  testWidgets(
    'actual live list clears old rows when account changes and restart cannot use persisted copy',
    (tester) async {
      final now = DateTime.utc(2026, 10, 21);
      final f = await _mount(
        tester,
        wallNow: () => now,
        elapsed: () => Duration.zero,
      );
      expect(find.text('合成会话对象'), findsOneWidget);
      (f.container.read(sessionProvider.notifier) as _Session).switchAccount();
      await tester.pumpAndSettle();
      expect(find.text('合成会话对象'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      f.container.dispose();
      PrivateCacheService.forTesting(
        f.secure,
        wallNow: () => now,
        elapsed: () => Duration.zero,
      );
      final restarted = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(f.secure),
          apiClientProvider.overrideWithValue(f.api),
        ],
      );
      await restarted.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: restarted,
          child: const MaterialApp(home: LiveConversationListPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('合成会话对象'), findsNothing);
      expect(find.textContaining('请登录后读取会话'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      restarted.dispose();
    },
  );
}
