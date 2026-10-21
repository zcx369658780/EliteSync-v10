import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/platform_v1014/platform_events_page.dart';
import 'package:flutter_elitesync_module/features/platform_v1014/safety_cases_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

const _targetId = '00000000-0000-4000-8000-000000000014';

class _Sessions extends SessionNotifier {
  @override
  Future<SessionState> build() async => _state(1);
  void change(int id) => state = AsyncData(_state(id));
  SessionState _state(int id) => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-platform-notification-$id',
    user: UserSummary(id: id, phone: ''),
  );
}

class _Api extends RelationshipApi {
  _Api(this.handle) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(String) handle;
  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) {
    expect(method, 'GET');
    return handle(path);
  }
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
  Future<void> markRead(int id) async {
    marked++;
  }
}

NotificationItemEntity _item(String kind, {Object? id = _targetId}) =>
    NotificationItemEntity(
      id: 14,
      kind: kind,
      title: 'PRIVATE_NOTIFICATION_TITLE',
      body: 'PRIVATE_NOTIFICATION_BODY',
      payload: {
        kind == 'platform_event' ? 'platform_event_id' : 'safety_case_id': id,
      },
      // A cached routing hint must never bypass the platform preflight.
      routeName: 'settings',
      routeArgs: const {},
      isRead: false,
      createdAt: '2026-10-21T00:00:00Z',
    );

String _preflightPath(String kind) => kind == 'platform_event'
    ? '/platform-events/$_targetId'
    : '/safety/own/$_targetId';

Map<String, dynamic> _preflight(String kind) => kind == 'platform_event'
    ? {
        'id': _targetId,
        'title': 'PREFLIGHT_RESPONSE_ONLY',
        'marker': 'DEV_SYNTHETIC_EVENT',
        'state': 'OPEN',
      }
    : {
        'id': _targetId,
        'role': 'subject',
        'state': 'CLOSED',
        'private_extra': 'PREFLIGHT_RESPONSE_ONLY',
      };

Future<ProviderContainer> _mount(
  WidgetTester tester,
  NotificationItemEntity item,
  _Api api,
  _Notifications notifications, {
  _Sessions? sessions,
  bool Function()? stillAvailable,
}) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const NotificationCenterPage()),
      GoRoute(
        path: AppRouteNames.settings,
        builder: (_, _) => const Scaffold(body: Text('UNRELATED_ROUTE_BYPASS')),
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
        notificationListProvider.overrideWith((ref) async {
          ref.watch(sessionProvider);
          ref.watch(relationshipAuthorityEpochProvider);
          return stillAvailable?.call() == false ? [] : [item];
        }),
        notificationUnreadCountProvider.overrideWith((ref) async => 1),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(
    tester.element(find.byType(NotificationCenterPage)),
  );
}

Future<void> _open(WidgetTester tester) async {
  final action = find.widgetWithText(OutlinedButton, '打开所属页面');
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pump();
}

void main() {
  for (final kind in ['platform_event', 'safety_case']) {
    testWidgets(
      '$kind preflights current target then destination reads again',
      (tester) async {
        final calls = <String>[];
        final notifications = _Notifications();
        await _mount(
          tester,
          _item(kind),
          _Api((path) async {
            calls.add(path);
            if (path == _preflightPath(kind)) return _preflight(kind);
            if (kind == 'platform_event') {
              expect(path, '/platform-events');
              return {
                'items': [
                  {
                    'id': _targetId,
                    'title': 'CURRENT_EVENT_REREAD',
                    'state': 'OPEN',
                    'revision': 3,
                    'marker': 'DEV_SYNTHETIC_EVENT',
                    'capacity': 2,
                    'allowed_actions': <String>[],
                  },
                ],
              };
            }
            expect(path, '/safety/own');
            return {
              'items': [
                {
                  'id': _targetId,
                  'role': 'subject',
                  'state': 'CORRECTED',
                  'revision': 3,
                },
              ],
              'sanctions': <Map<String, dynamic>>[],
            };
          }),
          notifications,
        );
        expect(find.text('PRIVATE_NOTIFICATION_TITLE'), findsNothing);
        expect(find.text('PRIVATE_NOTIFICATION_BODY'), findsNothing);
        await _open(tester);
        await tester.pumpAndSettle();
        expect(calls, [
          _preflightPath(kind),
          kind == 'platform_event' ? '/platform-events' : '/safety/own',
        ]);
        expect(
          find.byType(
            kind == 'platform_event' ? PlatformEventsPage : SafetyCasesPage,
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            kind == 'platform_event' ? 'CURRENT_EVENT_REREAD' : '本案已记录纠错',
          ),
          findsOneWidget,
        );
        expect(find.text('PREFLIGHT_RESPONSE_ONLY'), findsNothing);
        expect(find.text('UNRELATED_ROUTE_BYPASS'), findsNothing);
        expect(notifications.marked, 1);
      },
    );

    testWidgets('$kind revoked preflight clears authority and stays unread', (
      tester,
    ) async {
      final notifications = _Notifications();
      var available = true;
      final calls = <String>[];
      final container = await _mount(
        tester,
        _item(kind),
        _Api((path) async {
          calls.add(path);
          available = false;
          throw const RelationshipFailure('unavailable');
        }),
        notifications,
        stillAvailable: () => available,
      );
      final before = container.read(relationshipAuthorityEpochProvider);
      await _open(tester);
      await tester.pumpAndSettle();
      expect(calls, [_preflightPath(kind)]);
      expect(container.read(relationshipAuthorityEpochProvider), before + 1);
      expect(find.byType(PlatformEventsPage), findsNothing);
      expect(find.byType(SafetyCasesPage), findsNothing);
      expect(find.text('UNRELATED_ROUTE_BYPASS'), findsNothing);
      expect(notifications.marked, 0);
    });

    testWidgets('$kind unavailable projection cannot authorize a destination', (
      tester,
    ) async {
      final notifications = _Notifications();
      final calls = <String>[];
      await _mount(
        tester,
        _item(kind),
        _Api((path) async {
          calls.add(path);
          return {
            ..._preflight(kind),
            'state': kind == 'platform_event' ? 'CANCELLED' : 'UNKNOWN',
          };
        }),
        notifications,
      );
      await _open(tester);
      await tester.pumpAndSettle();
      expect(calls, [_preflightPath(kind)]);
      expect(find.byType(PlatformEventsPage), findsNothing);
      expect(find.byType(SafetyCasesPage), findsNothing);
      expect(find.text('UNRELATED_ROUTE_BYPASS'), findsNothing);
      expect(notifications.marked, 0);
    });

    for (final boundary in ['identity', 'authority']) {
      testWidgets('$kind late preflight cannot cross $boundary change', (
        tester,
      ) async {
        final late = Completer<Map<String, dynamic>>();
        final sessions = _Sessions();
        final notifications = _Notifications();
        var started = false;
        final container = await _mount(
          tester,
          _item(kind),
          _Api((path) {
            started = true;
            expect(path, _preflightPath(kind));
            return late.future;
          }),
          notifications,
          sessions: sessions,
        );
        await _open(tester);
        expect(started, isTrue);
        if (boundary == 'identity') {
          sessions.change(2);
        } else {
          container
              .read(relationshipAuthorityEpochProvider.notifier)
              .invalidate();
        }
        await tester.pumpAndSettle();
        late.complete(_preflight(kind));
        await tester.pumpAndSettle();
        expect(find.byType(PlatformEventsPage), findsNothing);
        expect(find.byType(SafetyCasesPage), findsNothing);
        expect(find.text('UNRELATED_ROUTE_BYPASS'), findsNothing);
        expect(notifications.marked, 0);
      });
    }

    testWidgets('$kind malformed target cannot fall through to cached route', (
      tester,
    ) async {
      final notifications = _Notifications();
      final calls = <String>[];
      await _mount(
        tester,
        _item(kind, id: '../settings'),
        _Api((path) async {
          calls.add(path);
          return {};
        }),
        notifications,
      );
      await _open(tester);
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(find.text('UNRELATED_ROUTE_BYPASS'), findsNothing);
      expect(notifications.marked, 0);
    });
  }
}
