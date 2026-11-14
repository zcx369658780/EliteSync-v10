import 'dart:async';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import '../../../../support/synthetic_private_login.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_conversation_list_page.dart';

class _Session extends SessionNotifier {
  void change() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'synthetic-other',
      user: UserSummary(id: 3, phone: 'synthetic'),
    ),
  );
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-only',
    user: UserSummary(id: 1, phone: 'synthetic'),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  bool fail = false;
  bool offline = false;
  int reads = 0;
  int? temporaryStatus;
  String preview = '服务器消息';
  int unread = 3;
  Completer<NetworkResult<Map<String, dynamic>>>? pending;
  bool hidden = false;
  bool hiddenFilter = false;
  bool eligibleMatchOnly = false;
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/conversations/9/visibility');
    hidden = (body as Map)['hidden'] == true;
    return const NetworkSuccess({'ok': true});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    reads++;
    hiddenFilter = query?['hidden_only'] == 1;
    if (fail) {
      return const NetworkFailure(
        message: 'permission revoked',
        statusCode: 403,
      );
    }
    if (offline) {
      return NetworkFailure(
        message: 'fictional offline',
        error: DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    if (temporaryStatus != null) {
      return NetworkFailure(
        message: 'fictional temporarily unavailable',
        statusCode: temporaryStatus,
      );
    }
    if (pending != null) return pending!.future;
    if (hidden != hiddenFilter) {
      return const NetworkSuccess({'ok': true, 'items': []});
    }
    return NetworkSuccess({
      'ok': true,
      'items': [
        {
          'id': '2',
          'conversation_id': eligibleMatchOnly ? null : 9,
          'peer_user_id': 2,
          'name': '虚构对象',
          'last_message': preview,
          'unread': unread,
        },
      ],
    });
  }
}

Future<PrivateCacheService> _show(
  WidgetTester tester,
  _Api api, {
  double textScale = 1,
}) async {
  final secure = await syntheticPrivateLogin();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const LiveConversationListPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return PrivateCacheService.forStorage(secure);
}

void main() {
  testWidgets(
    'current 404 explains unavailable conversations without an unknown result',
    (tester) async {
      final api = _Api();
      final cache = await _show(tester, api);
      api.temporaryStatus = 404;
      await tester.tap(find.byTooltip('刷新会话'));
      await tester.pumpAndSettle();
      expect(find.text('服务器消息'), findsNothing);
      expect(find.textContaining('当前没有可读取的会话'), findsOneWidget);
      expect(find.textContaining('未确认'), findsNothing);
      expect(find.textContaining('Bad state'), findsNothing);
      expect(
        await cache.readOnlineAuthorized('live-conversations:visible'),
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'manual 503 keeps an unconfirmed read distinct from a current 404',
    (tester) async {
      await _show(tester, _Api()..temporaryStatus = 503);
      expect(find.textContaining('会话读取未确认'), findsOneWidget);
      expect(find.textContaining('当前没有可读取的会话'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Large unread summary stays readable at 200 percent on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _show(tester, _Api()..unread = 999999, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.text('未读 999999'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'offline resume hides the old list until a current read succeeds',
    (tester) async {
      final api = _Api();
      final cache = await _show(tester, api);
      expect(find.text('服务器消息'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      api.offline = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('服务器消息'), findsNothing);
      expect(await cache.readOffline('live-conversations:visible'), isNull);
      expect(find.textContaining('没有本次可信登录'), findsOneWidget);
      api.offline = false;
      api.preview = '回前台后重新核验的消息';
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('回前台后重新核验的消息'), findsOneWidget);
      expect(find.textContaining('没有本次可信登录'), findsNothing);
      // A duplicate lifecycle callback must not revoke the new read grant.
      final reads = api.reads;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(api.reads, reads);
      expect(
        await cache.readOnlineAuthorized('live-conversations:visible'),
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('foreground polling updates the preview and unread count', (
    tester,
  ) async {
    final api = _Api();
    await _show(tester, api);
    api.preview = '新收到的服务器消息';
    api.unread = 4;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(api.reads, 2);
    expect(find.text('新收到的服务器消息'), findsOneWidget);
    expect(find.text('未读 4'), findsOneWidget);
    expect(find.text('服务器消息'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'pending automatic read keeps the list visible and does not overlap',
    (tester) async {
      final api = _Api();
      await _show(tester, api);
      api.pending = Completer();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(api.reads, 2);
      expect(find.text('服务器消息'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.pump(const Duration(seconds: 10));
      expect(api.reads, 2);
      api.pending!.complete(
        const NetworkSuccess({
          'ok': true,
          'items': [
            {
              'peer_user_id': 2,
              'conversation_id': 9,
              'name': '虚构对象',
              'last_message': '稍后确认的新消息',
              'unread': 8,
            },
          ],
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('稍后确认的新消息'), findsOneWidget);
      expect(find.text('未读 8'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('background and disposed pages do not poll', (tester) async {
    final api = _Api();
    await _show(tester, api);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 15));
    expect(api.reads, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(api.reads, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 15));
    expect(api.reads, 2);
  });

  testWidgets(
    'automatic network recovery restores online preview and unread state',
    (tester) async {
      final api = _Api();
      final cache = await _show(tester, api);
      api.offline = true;
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(cache.isOffline, isTrue);
      expect(find.text('未读 0'), findsOneWidget);
      api.offline = false;
      api.preview = '重新在线的服务器消息';
      api.unread = 7;
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(cache.isOffline, isFalse);
      expect(find.text('重新在线的服务器消息'), findsOneWidget);
      expect(find.text('未读 7'), findsOneWidget);
      await tester.pump(const Duration(seconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('重新在线的服务器消息'), findsOneWidget);
      expect(find.textContaining('内容已锁定'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'temporary automatic server failure keeps the last current list',
    (tester) async {
      final api = _Api();
      await _show(tester, api);
      api.temporaryStatus = 503;
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('服务器消息'), findsOneWidget);
      expect(find.textContaining('暂时无法更新会话'), findsOneWidget);
      api.temporaryStatus = null;
      api.preview = '更新已恢复';
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('更新已恢复'), findsOneWidget);
      expect(find.textContaining('暂时无法更新会话'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'temporary automatic failure cannot retain a newly locked cache view',
    (tester) async {
      final api = _Api();
      final cache = await _show(tester, api);
      api.pending = Completer();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      cache.lock();
      api.pending!.complete(
        const NetworkFailure(
          message: 'fictional temporary failure',
          statusCode: 503,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('服务器消息'), findsNothing);
      expect(find.text('虚构对象'), findsNothing);
      final reads = api.reads;
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(api.reads, reads);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('old automatic response cannot populate a changed account', (
    tester,
  ) async {
    final api = _Api();
    await _show(tester, api);
    api.pending = Completer();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveConversationListPage)),
    );
    api.fail = true;
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pumpAndSettle();
    api.pending!.complete(
      const NetworkSuccess({
        'ok': true,
        'items': [
          {
            'peer_user_id': 2,
            'name': '旧账号对象',
            'last_message': '旧账号晚消息',
            'unread': 8,
          },
        ],
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('旧账号对象'), findsNothing);
    expect(find.text('旧账号晚消息'), findsNothing);
    expect(find.text('虚构对象'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('eligible match without conversation id has no hide action', (
    tester,
  ) async {
    final api = _Api()..eligibleMatchOnly = true;
    await _show(tester, api);
    expect(find.text('虚构对象'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    final tile = tester.widget<ListTile>(
      find.ancestor(of: find.text('虚构对象'), matching: find.byType(ListTile)),
    );
    expect(tile.onLongPress, isNull);
  });
  testWidgets('hide persists server view then hidden list can restore entry', (
    tester,
  ) async {
    final api = _Api();
    await _show(tester, api);
    await tester.longPress(find.text('虚构对象'));
    await tester.pumpAndSettle();
    expect(api.hidden, true);
    expect(find.text('虚构对象'), findsNothing);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(api.hiddenFilter, true);
    expect(find.text('虚构对象'), findsOneWidget);
    await tester.longPress(find.text('虚构对象'));
    await tester.pumpAndSettle();
    expect(api.hidden, false);
    expect(find.text('虚构对象'), findsNothing);
  });
  testWidgets('server fields render and rejected refresh removes old data', (
    tester,
  ) async {
    final api = _Api();
    await _show(tester, api);
    expect(find.text('虚构对象'), findsOneWidget);
    expect(find.text('服务器消息'), findsOneWidget);
    expect(find.text('未读 3'), findsOneWidget);
    api.fail = true;
    await tester.tap(find.byTooltip('刷新会话'));
    await tester.pumpAndSettle();
    expect(find.text('虚构对象'), findsNothing);
    expect(find.textContaining('permission revoked'), findsOneWidget);
  });
  testWidgets('principal change clears prior list', (tester) async {
    await _show(tester, _Api());
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveConversationListPage)),
    );
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pumpAndSettle();
    expect(find.text('虚构对象'), findsNothing);
  });
}
