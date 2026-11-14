import 'dart:async';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

class _CurrentSession extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-notification-session',
  );
  void changeAccount() => state = const AsyncData(SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-other-notification-session',
  ));
}

class _ControlledNotificationApi extends RelationshipApi {
  _ControlledNotificationApi(this.handler) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(String) handler;

  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) => handler(path);
}

const _controlledId = '11111111-1111-4111-8111-111111111111';

Future<void> _mountControlledNotification(
  WidgetTester tester,
  String kind,
  _ControlledNotificationApi api,
) async {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final item = NotificationItemEntity(
    id: 990,
    kind: kind,
    title: 'old private title',
    body: 'old private body',
    payload: {
      kind == 'buddy' ? 'buddy_activity_id' : 'platform_event_id':
          _controlledId,
    },
    routeName: '',
    routeArgs: const {},
    isRead: false,
    createdAt: '2026-11-14T00:00:00Z',
  );
  final notifications = FakeNotificationRemoteDataSource()
    ..lookup = (_) async => item;
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, state) => const NotificationCenterPage()),
      GoRoute(
        path: '/buddy-v1013',
        builder: (_, state) =>
            const Scaffold(body: Text('CURRENT_BUDDY_RESULT')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(_CurrentSession.new),
        relationshipApiProvider.overrideWithValue(api),
        frontendTelemetryProvider.overrideWithValue(
          FrontendTelemetry(telemetry: FakeAppTelemetryService()),
        ),
        notificationRemoteDataSourceProvider.overrideWithValue(notifications),
        notificationListProvider.overrideWith((ref) async => [item]),
        notificationUnreadCountProvider.overrideWith((ref) async => 1),
      ],
      child: _SessionHarness(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, '打开所属页面'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, '打开所属页面'));
  await tester.pumpAndSettle();
}

/// The real notification providers watch sessionProvider. List mocks replace
/// that dependency, so initialize and retain the explicit session fixture here.
class _SessionHarness extends ConsumerWidget {
  const _SessionHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return session.hasValue ? child : const SizedBox.shrink();
  }
}

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        appVersionProvider: () async => '0.05.04',
      );

  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
    calls.add({'path': path, 'sourcePage': sourcePage, 'body': body});
    return const NetworkSuccess(<String, dynamic>{});
  }
}

class FakeNotificationRemoteDataSource extends NotificationRemoteDataSource {
  FakeNotificationRemoteDataSource()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        useMock: false,
      );

  late Future<NotificationItemEntity> Function(int) lookup;
  @override
  Future<NotificationItemEntity> fetchNotification(int id) => lookup(id);

  final List<int> markedReadIds = <int>[];
  bool failMarkRead = false;
  bool failMarkAllRead = false;
  int markReadAttempts = 0;
  int markAllReadAttempts = 0;

  @override
  Future<void> markRead(int notificationId) async {
    markReadAttempts += 1;
    if (failMarkRead) {
      throw Exception('raw mark-one failure');
    }
    markedReadIds.add(notificationId);
  }

  @override
  Future<void> markAllRead() async {
    markAllReadAttempts += 1;
    if (failMarkAllRead) {
      throw Exception('raw mark-all failure');
    }
  }
}

Map<String, dynamic> _pagingItem(int id) => {
  'id': id,
  'kind': 'system',
  'title': 'synthetic hidden title $id',
  'body': 'synthetic hidden body',
  'payload': <String, dynamic>{},
  'is_read': true,
  'created_at': '2026-11-10T00:00:00Z',
};

class _PagingApi extends ApiClient {
  _PagingApi() : super(dio: Dio());
  List<Map<String, dynamic>> firstItems = [_pagingItem(30), _pagingItem(29)];
  bool firstHasMore = true;
  int? firstCursor = 29;
  bool emptyCurrentAccount = false;
  bool failCurrentRead = false;
  int currentReads = 0;
  bool failOlderOnce = false;
  final cursors = <int>[];
  final pages = <int, Map<String, dynamic>>{};
  Completer<NetworkResult<Map<String, dynamic>>>? pending;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/notifications');
    expect(query?['limit'], 50);
    final before = query?['before_id'] as int?;
    if (before == null) {
      currentReads++;
      if (failCurrentRead) {
        return const NetworkFailure(message: 'fictional unavailable', statusCode: 503);
      }
      return NetworkSuccess({
        'items': emptyCurrentAccount ? <dynamic>[] : firstItems,
        'has_more': !emptyCurrentAccount && firstHasMore,
        'next_before_id': emptyCurrentAccount ? null : firstCursor,
      });
    }
    cursors.add(before);
    if (pending != null) return pending!.future;
    if (failOlderOnce) {
      failOlderOnce = false;
      return const NetworkFailure(message: 'fictional unavailable', statusCode: 503);
    }
    return NetworkSuccess(pages[before] ?? {
      'items': <dynamic>[], 'has_more': false, 'next_before_id': null,
    });
  }
}

Widget _pagingApp(_PagingApi api) => _wrap(
  const NotificationCenterPage(),
  overrides: [
    sessionProvider.overrideWith(_CurrentSession.new),
    frontendTelemetryProvider.overrideWithValue(FrontendTelemetry(telemetry: FakeAppTelemetryService())),
    notificationRemoteDataSourceProvider.overrideWith((ref) => NotificationRemoteDataSource(
      apiClient: api,
      useMock: false,
      identity: () => '${ref.read(sessionProvider).asData?.value.accessToken}:${ref.read(relationshipAuthorityEpochProvider)}',
    )),
    notificationUnreadCountProvider.overrideWith((ref) async => 0),
  ],
);

Future<void> _loadOlderNotifications(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('notification-load-more'));
  await tester.scrollUntilVisible(button, 350, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: _SessionHarness(
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: Scaffold(body: Material(child: child)),
      ),
    ),
  );
}

void _expectNoD7CForbiddenVisibleCopy() {
  final forbiddenVisibleTerms = <String>[
    'mock',
    '本地/mock 卡片',
    'payload',
    'debug',
    'test',
    'gate',
    'release-chain',
    'oracle',
    'Alpha',
    'internal',
    'dev',
    'dating',
    '接口',
    '已写入服务端通知',
    '服务端通知已保存',
    '推送已上线',
    '生产通知验证通过',
    '系统会立即调整推荐权重',
  ];
  for (final term in forbiddenVisibleTerms) {
    expect(find.textContaining(term), findsNothing, reason: term);
  }
}

void main() {
  testWidgets('Platform account change blocks late 404 result fallback', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>>();
    final paths = <String>[];
    final api = _ControlledNotificationApi((path) {
      paths.add(path);
      return pending.future;
    });
    await _mountControlledNotification(tester, 'platform_event', api);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NotificationCenterPage)),
    );
    (container.read(sessionProvider.notifier) as _CurrentSession)
        .changeAccount();
    pending.completeError(
      const RelationshipFailure('unavailable', statusCode: 404),
    );
    await tester.pumpAndSettle();
    expect(paths, ['/platform-events/$_controlledId']);
    expect(find.text('平台合成活动'), findsNothing);
  });

  testWidgets('Buddy authority change blocks late terminal projection', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>>();
    final api = _ControlledNotificationApi((path) => pending.future);
    await _mountControlledNotification(tester, 'buddy', api);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NotificationCenterPage)),
    );
    container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    pending.complete({
      'id': _controlledId,
      'state': 'COMPLETED',
      'allowed_actions': [],
    });
    await tester.pumpAndSettle();
    expect(find.text('CURRENT_BUDDY_RESULT'), findsNothing);
  });

  for (final state in [
    'COMPLETED',
    'CANCELLED',
    'DECLINED',
    'WITHDRAWN',
    'EXPIRED',
  ]) {
    testWidgets(
      'Buddy $state notification opens currently authorized minimal result',
      (tester) async {
        final api = _ControlledNotificationApi(
          (path) async => {
            'id': _controlledId,
            'state': state,
            'allowed_actions': [],
          },
        );
        await _mountControlledNotification(tester, 'buddy', api);
        expect(find.text('CURRENT_BUDDY_RESULT'), findsOneWidget);
        expect(find.textContaining('old private'), findsNothing);
      },
    );
  }

  testWidgets(
    'Buddy terminal response with operations cannot reopen activity',
    (tester) async {
      final api = _ControlledNotificationApi(
        (path) async => {
          'id': _controlledId,
          'state': 'CANCELLED',
          'allowed_actions': ['request'],
        },
      );
      await _mountControlledNotification(tester, 'buddy', api);
      expect(find.text('CURRENT_BUDDY_RESULT'), findsNothing);
    },
  );

  for (final state in [
    'CANCELLED_BY_USER',
    'CANCELLED_BY_ORGANIZER',
    'EXPIRED',
  ]) {
    testWidgets(
      'Platform $state notification reads safe result after 404 and reloads history',
      (tester) async {
        final paths = <String>[];
        final api = _ControlledNotificationApi((path) async {
          paths.add(path);
          if (path == '/platform-events/$_controlledId') {
            throw const RelationshipFailure('unavailable', statusCode: 404);
          }
          if (path.endsWith('/result')) {
            return {
              'id': _controlledId,
              'registration_state': state,
              'allowed_actions': [],
            };
          }
          return {
            'events': [],
            'history': [],
            'exit_tickets': [],
            'report_contexts': [],
            'has_more': false,
          };
        });
        await _mountControlledNotification(tester, 'platform_event', api);
        expect(paths, [
          '/platform-events/$_controlledId',
          '/platform-events/$_controlledId/result',
          '/platform-events',
        ]);
        expect(find.text('平台合成活动'), findsOneWidget);
        expect(find.textContaining('old private'), findsNothing);
      },
    );
  }

  testWidgets('Platform non-404 failure never falls back to result', (
    tester,
  ) async {
    final paths = <String>[];
    final api = _ControlledNotificationApi((path) async {
      paths.add(path);
      throw const RelationshipFailure('Forbidden', statusCode: 403);
    });
    await _mountControlledNotification(tester, 'platform_event', api);
    expect(paths, ['/platform-events/$_controlledId']);
    expect(find.text('平台合成活动'), findsNothing);
  });

  for (final result in [
    {
      'id': _controlledId,
      'registration_state': 'APPLIED',
      'allowed_actions': [],
    },
    {
      'id': _controlledId,
      'registration_state': 'EXPIRED',
      'allowed_actions': ['apply'],
    },
    {'id': 'wrong-id', 'registration_state': 'EXPIRED', 'allowed_actions': []},
  ]) {
    testWidgets('Platform result rejects unauthorized projection $result', (
      tester,
    ) async {
      final api = _ControlledNotificationApi((path) async {
        if (!path.endsWith('/result')) {
          throw const RelationshipFailure('unavailable', statusCode: 404);
        }
        return result;
      });
      await _mountControlledNotification(tester, 'platform_event', api);
      expect(find.text('平台合成活动'), findsNothing);
    });
  }

  testWidgets('manual notification refresh fails once and waits for explicit retry', (tester) async {
    final api = _PagingApi();
    await tester.pumpWidget(_pagingApp(api));
    await tester.pumpAndSettle();
    expect(api.currentReads, 1);
    api.failCurrentRead = true;
    await tester.tap(find.widgetWithIcon(IconButton, Icons.refresh_rounded));
    await tester.pumpAndSettle();
    expect(find.text('通知加载失败'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 5));
    expect(api.currentReads, 2);
    expect(find.text('通知加载失败'), findsOneWidget);
    api.failCurrentRead = false;
    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();
    expect(api.currentReads, 3);
    expect(find.text('通知加载失败'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('older notifications merge by id and a first-page refresh clears history', (tester) async {
    final api = _PagingApi();
    api.pages[29] = {
      'items': [_pagingItem(28), _pagingItem(28), _pagingItem(29), _pagingItem(27)],
      'has_more': false,
      'next_before_id': 27,
    };
    await tester.pumpWidget(_pagingApp(api));
    await tester.pumpAndSettle();
    await _loadOlderNotifications(tester);
    await tester.scrollUntilVisible(find.text('已显示全部通知'), 350, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(api.cursors, [29]);
    expect(find.byKey(const ValueKey('notification-card-28')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-card-27')), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(const ValueKey('notification-card-28'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('notification-card-27'))).dy));
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-card-28')), findsNothing);
    expect(find.text('已显示全部通知'), findsNothing);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('notification-load-more')), 350, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-load-more')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('failed history read preserves notifications and retries the same cursor', (tester) async {
    final api = _PagingApi()..failOlderOnce = true;
    api.pages[29] = {'items': [_pagingItem(28)], 'has_more': false, 'next_before_id': 28};
    await tester.pumpWidget(_pagingApp(api));
    await tester.pumpAndSettle();
    await _loadOlderNotifications(tester);
    expect(find.text('较早通知加载失败，已读取的通知仍保留。'), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-card-29')), findsOneWidget);
    await _loadOlderNotifications(tester);
    expect(api.cursors, [29, 29]);
    expect(find.text('较早通知加载失败，已读取的通知仍保留。'), findsNothing);
    expect(find.byKey(const ValueKey('notification-card-28')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('empty authorized pages still advance the server scan cursor', (tester) async {
    final api = _PagingApi()..firstItems = []..firstCursor = 90;
    api.pages[90] = {'items': <dynamic>[], 'has_more': true, 'next_before_id': 80};
    api.pages[80] = {'items': [_pagingItem(79)], 'has_more': false, 'next_before_id': 79};
    await tester.pumpWidget(_pagingApp(api));
    await tester.pumpAndSettle();
    expect(find.textContaining('本页暂无可显示提醒'), findsOneWidget);
    await _loadOlderNotifications(tester);
    expect(api.cursors, [90]);
    expect(find.byKey(const ValueKey('notification-load-more')), findsOneWidget);
    await _loadOlderNotifications(tester);
    expect(api.cursors, [90, 80]);
    expect(find.byKey(const ValueKey('notification-card-79')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-load-more')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('old notification page cannot append after account change', (tester) async {
    final api = _PagingApi()..pending = Completer();
    await tester.pumpWidget(_pagingApp(api));
    await tester.pumpAndSettle();
    await _loadOlderNotifications(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(NotificationCenterPage)));
    api.emptyCurrentAccount = true;
    (container.read(sessionProvider.notifier) as _CurrentSession).changeAccount();
    await tester.pumpAndSettle();
    api.pending!.complete(NetworkSuccess({
      'items': [_pagingItem(28)], 'has_more': false, 'next_before_id': 28,
    }));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-card-28')), findsNothing);
    expect(find.byKey(const ValueKey('notification-card-30')), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.textContaining('当前没有提醒'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('chat notification resolves stored ID before marking read', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final notifications = FakeNotificationRemoteDataSource();
    Object? capturedExtra;
    int? requestedConversationId;
    String? capturedSegment;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const NotificationCenterPage(),
        ),
        GoRoute(
          path: '/live-chat/:peerId',
          builder: (context, state) {
            capturedExtra = state.extra;
            capturedSegment = state.pathParameters['peerId'];
            return const Scaffold(body: Text('RESOLVED CHAT'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'EliteSync fixture',
            apiBaseUrl: 'http://127.0.0.1',
            useMockData: false,
            restorationLocalBuild: true,
          )),
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: FakeAppTelemetryService()),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 81,
                kind: 'message',
                title: 'Stored chat',
                body: 'Continue',
                payload: const {},
                routeName: 'chat_room',
                routeArgs: const {'conversation_id': 41},
                isRead: false,
                createdAt: '2026-08-04T00:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
          conversationDetailProvider.overrideWith(
            (ref, conversationId) async {
              requestedConversationId = conversationId;
              return const ConversationEntity(
                id: 'legacy-peer-alias',
                name: 'Resolved Peer',
                lastMessage: '',
                lastTime: '',
                unread: 0,
                entryKind: 'stored_conversation',
                conversationId: 41,
                peerUserId: 23,
              );
            },
          ),
        ],
        child: _SessionHarness(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final action = find.widgetWithText(OutlinedButton, '查看当前状态');
    await tester.scrollUntilVisible(
      action,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(action);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('RESOLVED CHAT'), findsOneWidget);
    expect(requestedConversationId, 41);
    expect(capturedSegment, '23');
    expect(capturedExtra, isNull);
    expect(notifications.markedReadIds, [81]);
  });

  testWidgets('chat resolution failure stays unread and retryable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final notifications = FakeNotificationRemoteDataSource();
    var resolutionCalls = 0;
    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: FakeAppTelemetryService()),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 82,
                kind: 'message',
                title: 'Retry chat',
                body: 'Continue',
                payload: const {},
                routeName: 'chat_room',
                routeArgs: const {'conversation_id': 42},
                isRead: false,
                createdAt: '2026-08-04T00:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
          conversationDetailProvider.overrideWith((ref, conversationId) async {
            resolutionCalls += 1;
            throw Exception('unavailable');
          }),
        ],
      ),
    );

    await tester.pumpAndSettle();
    final action = find.widgetWithText(OutlinedButton, '查看当前状态');
    await tester.scrollUntilVisible(
      action,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(action);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(resolutionCalls, 1);
    expect(notifications.markedReadIds, isEmpty);
  });

  for (final (caseName, entryKind, resolvedId) in <(String, String?, int?)>[
    ('missing resolved ID', 'stored_conversation', null),
    ('different resolved ID', 'stored_conversation', 42),
    ('legacy entry kind', 'legacy_peer', 41),
    ('eligible entry kind', 'eligible_match', 41),
    ('unknown entry kind', null, 41),
  ]) {
    testWidgets('chat notification rejects $caseName without marking read', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final notifications = FakeNotificationRemoteDataSource();
      var chatRouteBuilt = false;
      int? requestedConversationId;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const NotificationCenterPage(),
          ),
          GoRoute(
            path: '/live-chat/:peerId',
            builder: (context, state) {
              chatRouteBuilt = true;
              return const Scaffold(body: Text('CHAT ROUTE'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_CurrentSession.new),
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: FakeAppTelemetryService()),
            ),
            notificationRemoteDataSourceProvider.overrideWith((ref) {
              notifications.lookup = (id) async => (await ref.read(
                notificationListProvider.future,
              )).firstWhere((item) => item.id == id);
              return notifications;
            }),
            notificationListProvider.overrideWith(
              (ref) async => [
                NotificationItemEntity(
                  id: 90,
                  kind: 'message',
                  title: 'RAW PRIVATE NOTIFICATION TITLE',
                  body: 'RAW PRIVATE NOTIFICATION BODY',
                  payload: const {},
                  routeName: 'chat_room',
                  routeArgs: const {'conversation_id': 41},
                  isRead: false,
                  createdAt: '2026-08-04T00:00:00Z',
                ),
              ],
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 1),
            conversationDetailProvider.overrideWith((
              ref,
              conversationId,
            ) async {
              requestedConversationId = conversationId;
              return ConversationEntity(
                id: 'legacy-peer-alias',
                name: 'RAW PRIVATE PEER NAME',
                lastMessage: '',
                lastTime: '',
                unread: 0,
                entryKind: entryKind,
                conversationId: resolvedId,
                peerUserId: 23,
              );
            }),
          ],
          child: _SessionHarness(
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final action = find.widgetWithText(OutlinedButton, '查看当前状态');
      await tester.scrollUntilVisible(
        action,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(action);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(requestedConversationId, 41);
      expect(chatRouteBuilt, isFalse);
      expect(find.text('CHAT ROUTE'), findsNothing);
      expect(notifications.markedReadIds, isEmpty);
      expect(notifications.markReadAttempts, 0);
      expect(find.text('暂时无法打开这段会话，请稍后重试'), findsOneWidget);
      expect(find.textContaining('RAW PRIVATE'), findsNothing);
    });
  }

  testWidgets(
    'status author notification fails closed without using payload identity',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final notifications = FakeNotificationRemoteDataSource();
      var authorRouteBuilt = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const NotificationCenterPage(),
          ),
          GoRoute(
            path: '${AppRouteNames.statusAuthor}/:userId',
            builder: (context, state) {
              authorRouteBuilt = true;
              return const Scaffold(body: Text('AUTHOR ROUTE'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_CurrentSession.new),
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: FakeAppTelemetryService()),
            ),
            notificationRemoteDataSourceProvider.overrideWith((ref) {
              notifications.lookup = (id) async => (await ref.read(
                notificationListProvider.future,
              )).firstWhere((item) => item.id == id);
              return notifications;
            }),
            notificationListProvider.overrideWith(
              (ref) async => [
                NotificationItemEntity(
                  id: 83,
                  kind: 'profile',
                  title: 'private raw title',
                  body: 'private raw body',
                  payload: const {},
                  routeName: 'status_author',
                  routeArgs: const {
                    'user_id': 77,
                    'name': 'Payload Author Name',
                  },
                  isRead: false,
                  createdAt: '2026-08-04T00:00:00Z',
                ),
              ],
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 1),
          ],
          child: _SessionHarness(
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final action = find.widgetWithText(OutlinedButton, '打开所属页面');
      await tester.scrollUntilVisible(
        action,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(authorRouteBuilt, isFalse);
      expect(find.text('当前访问权限尚未建立，暂无法打开'), findsOneWidget);
      expect(find.text('AUTHOR ROUTE'), findsNothing);
      expect(find.textContaining('Payload Author Name'), findsNothing);
      expect(find.textContaining('private raw'), findsNothing);
      expect(notifications.markedReadIds, isEmpty);
    },
  );

  testWidgets('notification center sanitizes load failure', (tester) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationListProvider.overrideWith(
            (ref) async => throw Exception('raw notification failure'),
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('暂时无法加载通知，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('不代表任何领域结果'), findsOneWidget);
    expect(find.textContaining('raw notification failure'), findsNothing);
    expect(find.text('重新加载'), findsOneWidget);
  });

  testWidgets('notification center renders notifications and unread count', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 1,
                kind: 'message',
                title: '对方发来一条消息',
                body: '可以继续手动编辑草稿',
                payload: const {
                  'route_name': 'chat_room',
                  'route_args': {'conversation_id': 'chat-1', 'title': '对方'},
                },
                routeName: 'chat_room',
                routeArgs: const {'conversation_id': 'chat-1', 'title': '对方'},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('通知中心'), findsOneWidget);
    expect(find.text('站内提醒'), findsWidgets);
    expect(find.textContaining('未读 1 条'), findsOneWidget);
    expect(find.text('对方发来一条消息'), findsNothing);
    expect(find.text('可以继续手动编辑草稿'), findsNothing);
    expect(find.text('消息有新提醒'), findsOneWidget);
    expect(find.textContaining('重新核验当前权限与状态'), findsWidgets);
    expect(find.text('消息'), findsOneWidget);
    expect(find.text('查看当前状态'), findsOneWidget);
    expect(find.text('稍后处理'), findsOneWidget);
    expect(find.text('标记已读'), findsOneWidget);
    expect(find.text('打开后重新核验当前权限与状态。'), findsOneWidget);
    expect(find.text('提醒内容示例'), findsOneWidget);
    expect(find.textContaining('不代表当前通知'), findsOneWidget);
    expect(find.text('本轮慢约会即将揭晓'), findsOneWidget);
    expect(find.text('聊天可以低压继续'), findsOneWidget);
    expect(find.text('资料准备提醒'), findsWidgets);
    expect(find.text('聊完后可以反馈方向'), findsOneWidget);
    expect(find.textContaining('不会自动发送消息'), findsOneWidget);
    expect(find.textContaining('不会替你改资料或匹配结果'), findsOneWidget);
    expect(find.text('message'), findsNothing);
    _expectNoD7CForbiddenVisibleCopy();
    expect(
      telemetry.calls.any(
        (row) =>
            row['path'] == '/api/v1/telemetry/events' &&
            (row['body'] as Map<String, dynamic>)['event_name'] ==
                'notification_center_opened',
      ),
      isTrue,
    );
  });

  testWidgets('notification center renders slow date reminder type', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 2,
                kind: 'match_success',
                title: '本轮慢约会有新进度',
                body: '可以回到本轮节奏，看看是否适合继续了解。',
                payload: const {
                  'route_name': 'match_result',
                  'route_args': <String, Object?>{},
                },
                routeName: 'match_result',
                routeArgs: const {},
                isRead: false,
                createdAt: '2026-04-21T12:01:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('本轮慢约会有新进度'), findsNothing);
    expect(find.text('匹配有新提醒'), findsOneWidget);
    expect(find.text('匹配'), findsOneWidget);
    expect(find.text('查看当前状态'), findsOneWidget);
    expect(find.text('打开后重新核验当前权限与状态。'), findsOneWidget);
    _expectNoD7CForbiddenVisibleCopy();
  });

  testWidgets('notification center empty state stays user-facing', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationListProvider.overrideWith((ref) async => []),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('通知中心'), findsOneWidget);
    expect(find.text('站内提醒'), findsOneWidget);
    expect(find.textContaining('慢约会、聊天和资料准备'), findsOneWidget);
    expect(find.textContaining('当前没有提醒'), findsOneWidget);
    expect(find.text('提醒内容示例'), findsOneWidget);
    expect(find.textContaining('不代表当前通知'), findsOneWidget);
    expect(find.text('本轮慢约会即将揭晓'), findsOneWidget);
    expect(find.text('聊天可以低压继续'), findsOneWidget);
    expect(find.text('资料准备提醒'), findsOneWidget);
    expect(find.text('聊完后可以反馈方向'), findsOneWidget);
    expect(find.textContaining('不会自动发送消息'), findsOneWidget);
    expect(find.textContaining('不会替你改资料或匹配结果'), findsOneWidget);
    _expectNoD7CForbiddenVisibleCopy();
  });

  testWidgets('notification center neutralizes abnormal unread count', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 1,
                kind: 'message',
                title: '对方发来一条消息',
                body: '可以稍后回到聊天',
                payload: const {},
                routeName: '',
                routeArgs: const {},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 81),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('有未读提醒'), findsOneWidget);
    expect(find.text('未读 81 条'), findsNothing);
  });

  testWidgets(
    'primary action marks unread notification when route is missing',
    (tester) async {
      final telemetry = FakeAppTelemetryService();
      final notifications = FakeNotificationRemoteDataSource();

      await tester.pumpWidget(
        _wrap(
          const NotificationCenterPage(),
          overrides: [
            sessionProvider.overrideWith(_CurrentSession.new),
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: telemetry),
            ),
            notificationRemoteDataSourceProvider.overrideWith((ref) {
              notifications.lookup = (id) async => (await ref.read(
                notificationListProvider.future,
              )).firstWhere((item) => item.id == id);
              return notifications;
            }),
            notificationListProvider.overrideWith(
              (ref) async => [
                NotificationItemEntity(
                  id: 2,
                  kind: 'system',
                  title: '资料完整度提醒',
                  body: '可以稍后处理',
                  payload: const {},
                  routeName: '',
                  routeArgs: const {},
                  isRead: false,
                  createdAt: '2026-04-21T12:00:00Z',
                ),
              ],
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 1),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('隐私保护提醒'), findsOneWidget);
      expect(find.text('仅标记已读'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(OutlinedButton, '仅标记已读'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, '仅标记已读'));
      await tester.pumpAndSettle();

      expect(notifications.markedReadIds, <int>[2]);
    },
  );

  testWidgets('mark-one failure has no false success and remains retryable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource()
      ..failMarkRead = true;

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 9,
                kind: 'system',
                title: '可重试提醒',
                body: '稍后再试',
                payload: const {},
                routeName: '',
                routeArgs: const {},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final action = find.widgetWithText(OutlinedButton, '仅标记已读');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.text('操作未完成，请稍后重试'), findsOneWidget);
    expect(find.text('已标记为已读'), findsNothing);
    expect(find.textContaining('raw mark-one failure'), findsNothing);
    expect(notifications.markReadAttempts, 1);
    expect(notifications.markedReadIds, isEmpty);

    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(notifications.markReadAttempts, 2);
  });

  testWidgets('mark-all failure has no false success and remains retryable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource()
      ..failMarkAllRead = true;

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 10,
                kind: 'system',
                title: '全部已读失败提醒',
                body: '稍后再试',
                payload: const {},
                routeName: '',
                routeArgs: const {},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final action = find.text('全部已读');
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.text('操作未完成，请稍后重试'), findsOneWidget);
    expect(find.text('已全部标记为已读'), findsNothing);
    expect(find.textContaining('raw mark-all failure'), findsNothing);
    expect(notifications.markAllReadAttempts, 1);

    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(notifications.markAllReadAttempts, 2);
  });

  testWidgets('known kind with missing route still uses mark read action', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 4,
                kind: 'message',
                title: '消息提醒缺少跳转目标',
                body: '需要保留为低噪声处理',
                payload: const {},
                routeName: '',
                routeArgs: const {},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('消息有新提醒'), findsOneWidget);
    expect(find.text('仅标记已读'), findsOneWidget);
    expect(find.text('回到聊天'), findsNothing);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, '仅标记已读'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '仅标记已读'));
    await tester.pumpAndSettle();

    expect(notifications.markedReadIds, <int>[4]);
  });

  testWidgets('unsupported route does not mark unread notification as read', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 3,
                kind: 'system',
                title: '未知跳转提醒',
                body: '暂不支持打开',
                payload: const {
                  'route_name': 'legacy_unknown',
                  'route_args': <String, Object?>{},
                },
                routeName: 'legacy_unknown',
                routeArgs: const {},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('所属页面会重新检查当前访问权限。'), findsOneWidget);
    expect(find.text('打开所属页面'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, '打开所属页面'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '打开所属页面'));
    await tester.pumpAndSettle();

    expect(notifications.markedReadIds, isEmpty);
  });

  testWidgets('notification card body is not a nested tappable container', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          sessionProvider.overrideWith(_CurrentSession.new),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWith((ref) {
            notifications.lookup = (id) async => (await ref.read(
              notificationListProvider.future,
            )).firstWhere((item) => item.id == id);
            return notifications;
          }),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 6,
                kind: 'message',
                title: '可操作提醒',
                body: '只允许通过明确按钮继续处理',
                payload: const {
                  'route_name': 'chat_room',
                  'route_args': {'conversation_id': 'chat-6', 'title': '对方'},
                },
                routeName: 'chat_room',
                routeArgs: const {'conversation_id': 'chat-6', 'title': '对方'},
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('可操作提醒'), findsNothing);
    expect(find.text('消息有新提醒'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('消息有新提醒'), matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(find.widgetWithText(OutlinedButton, '查看当前状态'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '稍后处理'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '标记已读'), findsOneWidget);
  });

  testWidgets(
    'card tap on unsupported route does not mark notification as read',
    (tester) async {
      final telemetry = FakeAppTelemetryService();
      final notifications = FakeNotificationRemoteDataSource();

      await tester.pumpWidget(
        _wrap(
          const NotificationCenterPage(),
          overrides: [
            sessionProvider.overrideWith(_CurrentSession.new),
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: telemetry),
            ),
            notificationRemoteDataSourceProvider.overrideWith((ref) {
              notifications.lookup = (id) async => (await ref.read(
                notificationListProvider.future,
              )).firstWhere((item) => item.id == id);
              return notifications;
            }),
            notificationListProvider.overrideWith(
              (ref) async => [
                NotificationItemEntity(
                  id: 5,
                  kind: 'system',
                  title: '未知跳转卡片',
                  body: '点击卡片也不应标记已读',
                  payload: const {
                    'route_name': 'legacy_unknown',
                    'route_args': <String, Object?>{},
                  },
                  routeName: 'legacy_unknown',
                  routeArgs: const {},
                  isRead: false,
                  createdAt: '2026-04-21T12:00:00Z',
                ),
              ],
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 1),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('未知跳转卡片'), findsNothing);
      final privacySafeCardSurface = find.text('有一条新提醒');
      expect(privacySafeCardSurface, findsOneWidget);
      await tester.tap(privacySafeCardSurface);
      await tester.pumpAndSettle();

      expect(notifications.markedReadIds, isEmpty);
    },
  );
}
