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
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';

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

  final List<int> markedReadIds = <int>[];
  bool failMarkRead = false;
  bool failMarkAllRead = false;
  int markReadAttempts = 0;
  int markAllReadAttempts = 0;

  @override
  Future<void> markRead(int notificationId) async {
    markReadAttempts += 1;
    if (failMarkRead) throw Exception('raw mark-one failure');
    markedReadIds.add(notificationId);
  }

  @override
  Future<void> markAllRead() async {
    markAllReadAttempts += 1;
    if (failMarkAllRead) throw Exception('raw mark-all failure');
  }
}

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: Scaffold(body: Material(child: child)),
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
  testWidgets('chat notification resolves stored ID before marking read', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final notifications = FakeNotificationRemoteDataSource();
    Object? capturedExtra;
    String? capturedSegment;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const NotificationCenterPage(),
        ),
        GoRoute(
          path: '${AppRouteNames.chatRoom}/:chatIdentity',
          builder: (context, state) {
            capturedExtra = state.extra;
            capturedSegment = state.pathParameters['chatIdentity'];
            return const Scaffold(body: Text('RESOLVED CHAT'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: FakeAppTelemetryService()),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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
            (ref, conversationId) async => const ConversationEntity(
              id: 'legacy-peer-alias',
              name: 'Resolved Peer',
              lastMessage: '',
              lastTime: '',
              unread: 0,
              entryKind: 'stored_conversation',
              conversationId: 41,
              peerUserId: 23,
            ),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    final action = find.widgetWithText(OutlinedButton, '回到聊天');
    await tester.scrollUntilVisible(
      action,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(action);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('RESOLVED CHAT'), findsOneWidget);
    expect(capturedSegment, 'conversation-41');
    final routeState = capturedExtra! as ChatRouteState;
    expect(routeState.conversationId, 41);
    expect(routeState.peerUserId, 23);
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
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: FakeAppTelemetryService()),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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
    final action = find.widgetWithText(OutlinedButton, '回到聊天');
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

  testWidgets('notification center sanitizes load failure', (tester) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
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

    expect(find.text('暂时无法加载通知，请稍后重试。'), findsOneWidget);
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
    expect(find.text('对方发来一条消息'), findsOneWidget);
    expect(find.text('可以继续手动编辑草稿'), findsOneWidget);
    expect(find.text('继续聊天'), findsWidgets);
    expect(find.text('回到聊天'), findsWidgets);
    expect(find.text('稍后处理'), findsOneWidget);
    expect(find.text('标记已读'), findsOneWidget);
    expect(find.text('回到这段对话，继续手动编辑草稿。'), findsOneWidget);
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

    expect(find.text('本轮慢约会有新进度'), findsOneWidget);
    expect(find.text('慢约会提醒'), findsOneWidget);
    expect(find.text('本轮进度'), findsOneWidget);
    expect(find.text('查看本轮进度'), findsOneWidget);
    expect(find.text('回到本轮慢约会进度。'), findsOneWidget);
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
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: telemetry),
            ),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
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

      expect(find.text('反馈与资料准备'), findsOneWidget);
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
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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

    expect(find.text('回到聊天'), findsOneWidget);
    expect(find.text('仅标记已读'), findsOneWidget);
    expect(find.text('回到聊天'), findsOneWidget);

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
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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

    expect(find.text('暂不支持该跳转目标。'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, '打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '打开'));
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
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
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

    expect(find.text('可操作提醒'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('可操作提醒'), matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(find.widgetWithText(OutlinedButton, '回到聊天'), findsOneWidget);
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
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: telemetry),
            ),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
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

      await tester.tap(find.text('未知跳转卡片'));
      await tester.pumpAndSettle();

      expect(notifications.markedReadIds, isEmpty);
    },
  );
}
