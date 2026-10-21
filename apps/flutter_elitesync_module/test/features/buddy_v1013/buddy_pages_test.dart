import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/features/buddy_v1013/buddy_page.dart';
import 'package:flutter_elitesync_module/features/buddy_v1013/comment_panel.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState _session(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'synthetic-widget-$id',
  user: UserSummary(id: id, phone: ''),
);

class _Sessions extends SessionNotifier {
  @override
  Future<SessionState> build() async => _session(1);
  void change(int id) => state = AsyncData(_session(id));
}

class _Api extends RelationshipApi {
  _Api(this.handle) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>?,
  )
  handle;
  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) => handle(method, path, body);
}

Map<String, dynamic> _buddy({
  List<Map<String, dynamic>> activities = const [],
}) => {
  'preferences': {'enabled': false, 'revision': 0},
  'activities': activities,
};

Future<void> _mount(
  WidgetTester tester,
  Widget child,
  _Api api, {
  _Sessions? sessions,
}) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => sessions ?? _Sessions()),
        relationshipApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}

class _Telemetry extends AppTelemetryService {
  _Telemetry()
    : super(
        apiClient: ApiClient(dio: Dio()),
        appVersionProvider: () async => 'synthetic-widget',
      );
  @override
  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async => const NetworkSuccess({});
}

class _Notifications extends NotificationRemoteDataSource {
  _Notifications() : super(apiClient: ApiClient(dio: Dio()), useMock: false);
  int marked = 0;
  @override
  Future<void> markRead(int notificationId) async {
    marked++;
  }
}

Future<void> _mountNotification(
  WidgetTester tester,
  String kind,
  Map<String, dynamic> payload,
  _Api api,
  _Notifications notifications, {
  _Sessions? sessions,
}) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NotificationCenterPage(),
      ),
      GoRoute(
        path: '/buddy-v1013',
        builder: (context, state) =>
            const Scaffold(body: Text('CURRENT_BUDDY_ENTRY')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => sessions ?? _Sessions()),
        relationshipApiProvider.overrideWithValue(api),
        frontendTelemetryProvider.overrideWithValue(
          FrontendTelemetry(telemetry: _Telemetry()),
        ),
        notificationRemoteDataSourceProvider.overrideWithValue(notifications),
        notificationListProvider.overrideWith(
          (ref) async => [
            NotificationItemEntity(
              id: 1,
              kind: kind,
              title: 'Generic update',
              body: 'No private body',
              payload: payload,
              routeName: '',
              routeArgs: const {},
              isRead: false,
              createdAt: '2026-10-21T00:00:00Z',
            ),
          ],
        ),
        notificationUnreadCountProvider.overrideWith((ref) async => 1),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(NotificationCenterPage)),
  );
  await container.read(sessionProvider.future);
  await tester.pumpAndSettle();
}

Future<void> _tapNotification(
  WidgetTester tester, {
  String label = '打开所属页面',
}) async {
  final action = find.widgetWithText(OutlinedButton, label);
  await tester.scrollUntilVisible(
    action,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(action);
  await tester.pump();
}

void main() {
  testWidgets(
    'missing buddy actions never creates a confirmation or contact control',
    (tester) async {
      await _mount(
        tester,
        const BuddyPage(),
        _Api(
          (m, p, b) async => _buddy(
            activities: [
              {
                'id': 'synthetic-activity',
                'state': 'REQUESTED',
                'revision': 2,
                'type': 'MEAL',
                'subject': '合成主题',
              },
            ],
          ),
        ),
      );
      expect(find.text('合成主题'), findsOneWidget);
      expect(find.text('确认这位搭子'), findsNothing);
      expect(find.text('邀请当前好友'), findsNothing);
      expect(find.text('生成一次性邀请凭据'), findsNothing);
    },
  );

  testWidgets('failed buddy refresh clears the formerly authorized card', (
    tester,
  ) async {
    var revoked = false;
    await _mount(
      tester,
      const BuddyPage(),
      _Api((m, p, b) async {
        if (revoked) throw const RelationshipFailure('not found');
        return _buddy(
          activities: [
            {
              'id': 'synthetic-activity',
              'state': 'OPEN',
              'revision': 1,
              'type': 'STUDY',
              'subject': 'ONLY_PREVIOUS_AUTHORITY',
              'allowed_actions': [],
            },
          ],
        );
      }),
    );
    expect(find.text('ONLY_PREVIOUS_AUTHORITY'), findsOneWidget);
    revoked = true;
    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect(find.text('ONLY_PREVIOUS_AUTHORITY'), findsNothing);
    expect(find.byKey(const Key('server-error')), findsOneWidget);
  });

  testWidgets(
    'late buddy response cannot replace the next accounts projection',
    (tester) async {
      final sessions = _Sessions();
      final old = Completer<Map<String, dynamic>>();
      var calls = 0;
      await _mount(
        tester,
        const BuddyPage(),
        _Api((m, p, b) {
          calls++;
          if (calls == 2) return old.future;
          return Future.value(
            _buddy(
              activities: calls >= 3
                  ? [
                      {
                        'id': 'next',
                        'state': 'DRAFT',
                        'type': 'MEAL',
                        'revision': 0,
                        'subject': 'NEXT_ACCOUNT',
                        'allowed_actions': [],
                      },
                    ]
                  : [],
            ),
          );
        }),
        sessions: sessions,
      );
      await tester.tap(find.byTooltip('刷新'));
      await tester.pump();
      sessions.change(2);
      await tester.pumpAndSettle();
      old.complete(
        _buddy(
          activities: [
            {
              'id': 'old',
              'subject': 'OLD_ACCOUNT_SECRET',
              'state': 'OPEN',
              'type': 'STUDY',
              'revision': 1,
              'allowed_actions': ['confirm'],
            },
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('NEXT_ACCOUNT'), findsOneWidget);
      expect(find.text('OLD_ACCOUNT_SECRET'), findsNothing);
      expect(find.text('确认这位搭子'), findsNothing);
    },
  );

  testWidgets(
    'authority invalidation removes the one-time capability from the page',
    (tester) async {
      final activity = <String, dynamic>{
        'id': 'synthetic-activity',
        'state': 'OPEN',
        'revision': 1,
        'type': 'MEAL',
        'subject': '合成主题',
        'allowed_actions': ['token', 'revoke_token'],
      };
      await _mount(
        tester,
        const BuddyPage(),
        _Api((method, path, body) async {
          if (method == 'POST') {
            return {
              'token': 'SYNTHETIC_CAPABILITY_ONLY',
              'expires_at': '2030-01-01T00:00:00Z',
              'activity': activity,
            };
          }
          return _buddy(activities: [activity]);
        }),
      );
      await tester.tap(
        find.byKey(const ValueKey('buddy-synthetic-activity-token')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('SYNTHETIC_CAPABILITY_ONLY'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(BuddyPage)),
      );
      container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      await tester.pumpAndSettle();
      expect(find.text('SYNTHETIC_CAPABILITY_ONLY'), findsNothing);
    },
  );

  testWidgets('comments require explicit deletion and report flags', (
    tester,
  ) async {
    await _mount(
      tester,
      const Scaffold(
        body: SingleChildScrollView(child: CommentPanel(postId: 1)),
      ),
      _Api(
        (m, p, b) async => {
          'items': [
            {
              'id': 'comment-one',
              'body': '授权正文',
              'state': 'ACTIVE',
              'revision': 1,
              'author_id': 2,
            },
          ],
          'meta': {'has_more': false},
        },
      ),
    );
    expect(find.text('授权正文'), findsOneWidget);
    expect(find.text('删除评论'), findsNothing);
    expect(find.text('举报评论'), findsNothing);
  });

  testWidgets('failed comment write removes the old private comments', (
    tester,
  ) async {
    await _mount(
      tester,
      const Scaffold(
        body: SingleChildScrollView(child: CommentPanel(postId: 1)),
      ),
      _Api((m, p, b) async {
        if (m == 'POST') throw const RelationshipFailure('audience revoked');
        return {
          'items': [
            {
              'id': 'comment-one',
              'body': 'PREVIOUS_PRIVATE_COMMENT',
              'state': 'ACTIVE',
              'revision': 1,
              'author_id': 2,
            },
          ],
          'meta': {'has_more': false},
        };
      }),
    );
    await tester.enterText(find.byKey(const Key('comment-draft')), '新的评论');
    await tester.tap(find.byKey(const Key('comment-submit')));
    await tester.pumpAndSettle();
    expect(find.text('PREVIOUS_PRIVATE_COMMENT'), findsNothing);
    expect(find.byKey(const Key('comments-error')), findsOneWidget);
    expect(find.byKey(const Key('comment-submit')), findsNothing);
  });

  testWidgets('switching post ids clears an older comments projection', (
    tester,
  ) async {
    var currentPost = 1;
    late StateSetter changePost;
    await _mount(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              changePost = setState;
              return CommentPanel(postId: currentPost);
            },
          ),
        ),
      ),
      _Api(
        (m, p, b) async => {
          'items': [
            {
              'id': p.contains('/1/') ? 'one' : 'two',
              'body': p.contains('/1/') ? 'POST_ONE' : 'POST_TWO',
              'state': 'ACTIVE',
              'revision': 1,
              'author_id': 2,
            },
          ],
          'meta': {'has_more': false},
        },
      ),
    );
    expect(find.text('POST_ONE'), findsOneWidget);
    changePost(() => currentPost = 2);
    await tester.pumpAndSettle();
    expect(find.text('POST_TWO'), findsOneWidget);
    expect(find.text('POST_ONE'), findsNothing);
  });

  testWidgets(
    'cached buddy notification rechecks current activity before navigation',
    (tester) async {
      final calls = <String>[];
      final notifications = _Notifications();
      await _mountNotification(
        tester,
        'buddy',
        {'buddy_activity_id': '00000000-0000-4000-8000-000000000001'},
        _Api((m, p, b) async {
          calls.add(p);
          throw const RelationshipFailure('unavailable');
        }),
        notifications,
      );
      await _tapNotification(tester);
      await tester.pumpAndSettle();
      expect(calls, ['/buddy/00000000-0000-4000-8000-000000000001']);
      expect(find.text('CURRENT_BUDDY_ENTRY'), findsNothing);
      expect(notifications.marked, 0);
    },
  );

  testWidgets(
    'comment notification opens live comment projection after post authorization',
    (tester) async {
      final calls = <String>[];
      final notifications = _Notifications();
      await _mountNotification(
        tester,
        'status_comment',
        {'status_post_id': 12},
        _Api((m, p, b) async {
          calls.add(p);
          if (p == '/status/posts/12') {
            return {
              'item': {'id': 12, 'body': 'PREFLIGHT_BODY_NOT_NAVIGATION_STATE'},
            };
          }
          return {
            'items': [
              {
                'id': 'current-comment',
                'body': 'AUTHORIZED_CURRENT_COMMENT',
                'state': 'ACTIVE',
                'author_id': 2,
                'revision': 1,
                'can_delete': false,
                'can_report': true,
              },
            ],
            'meta': {'has_more': false},
          };
        }),
        notifications,
      );
      await _tapNotification(tester);
      await tester.pumpAndSettle();
      expect(calls, ['/status/posts/12', '/status-posts/12/comments']);
      expect(find.text('AUTHORIZED_CURRENT_COMMENT'), findsOneWidget);
      expect(find.text('PREFLIGHT_BODY_NOT_NAVIGATION_STATE'), findsNothing);
      expect(notifications.marked, 1);
    },
  );

  for (final kind in ['buddy', 'status_comment']) {
    testWidgets('$kind empty terminal payload cannot navigate', (tester) async {
      final notifications = _Notifications();
      final calls = <String>[];
      await _mountNotification(
        tester,
        kind,
        {},
        _Api((m, p, b) async {
          calls.add(p);
          return {};
        }),
        notifications,
      );
      await _tapNotification(tester, label: '仅标记已读');
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(find.text('CURRENT_BUDDY_ENTRY'), findsNothing);
      expect(find.byType(CommentPanel), findsNothing);
      expect(notifications.marked, 1);
    });
  }

  testWidgets(
    'late notification authorization cannot open under another account',
    (tester) async {
      final notifications = _Notifications();
      final sessions = _Sessions();
      final late = Completer<Map<String, dynamic>>();
      var started = false;
      await _mountNotification(
        tester,
        'buddy',
        {'buddy_activity_id': '00000000-0000-4000-8000-000000000001'},
        _Api((m, p, b) {
          started = true;
          return late.future;
        }),
        notifications,
        sessions: sessions,
      );
      await _tapNotification(tester);
      expect(started, isTrue);
      sessions.change(2);
      await tester.pumpAndSettle();
      late.complete({
        'id': '00000000-0000-4000-8000-000000000001',
        'subject': 'OLD_AUTHORITY',
        'state': 'OPEN',
      });
      await tester.pumpAndSettle();
      expect(find.text('CURRENT_BUDDY_ENTRY'), findsNothing);
      expect(find.text('OLD_AUTHORITY'), findsNothing);
      expect(notifications.marked, 0);
    },
  );
}
