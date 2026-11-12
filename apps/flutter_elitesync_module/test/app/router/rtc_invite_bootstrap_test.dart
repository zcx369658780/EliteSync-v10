import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/router/rtc_invite_coordinator.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _TestSession extends SessionNotifier {
  @override
  SessionState build() =>
      const SessionState(status: AuthStatus.unauthenticated);

  void login() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 3, phone: 'fictional-test'),
    ),
  );

  void logout() =>
      state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
}

class _Notifications extends NotificationRemoteDataSource {
  _Notifications({this.pending})
    : super(apiClient: ApiClient(dio: Dio()), useMock: false);

  final Future<List<NotificationItemEntity>>? pending;
  int requests = 0;

  @override
  Future<List<NotificationItemEntity>> fetchNotifications({int limit = 50}) {
    requests++;
    return pending ?? Future.value(<NotificationItemEntity>[]);
  }

  @override
  Future<void> markRead(int notificationId) async {}
}

class _Calls extends RtcRemoteDataSource {
  _Calls({this.pending, this.items = const []})
    : super(apiClient: ApiClient(dio: Dio()));

  final Future<List<RtcSessionEntity>>? pending;
  final List<RtcSessionEntity> items;
  int requests = 0;

  @override
  Future<List<RtcSessionEntity>> fetchCalls() {
    requests++;
    return pending ?? Future.value(items);
  }
}

RtcSessionEntity _call(int id, {int peerUserId = 3, bool incoming = true}) =>
    RtcSessionEntity.fromJson({
      'id': id,
      'status': 'ringing',
      'title': 'Fictional incoming call',
      'initiator_user_id': incoming ? 7 : 3,
      'peer_user_id': peerUserId,
      'is_initiator': !incoming,
      'is_terminal': false,
    });

Future<void> _mount(
  WidgetTester tester,
  ProviderContainer container, {
  String watcher = 'bootstrap',
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (_, ref, child) {
          if (watcher == 'widget') {
            return const RtcInviteCoordinator(child: SizedBox.shrink());
          }
          ref.watch(
            watcher == 'bootstrap'
                ? rtcInviteBootstrapProvider
                : rtcInviteWatcherProvider,
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();
}

Future<void> _close(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(const SizedBox.shrink());
  container.dispose();
  await tester.pump(const Duration(seconds: 9));
}

void main() {
  testWidgets(
    'queued notification navigation expires on sign-out before frame',
    (tester) async {
      final pending = Completer<List<NotificationItemEntity>>();
      final router = GoRouter(
        initialLocation: '/idle',
        routes: [
          GoRoute(path: '/idle', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '${AppRouteNames.rtcIncomingCall}/:callId',
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
          rtcRemoteDataSourceProvider.overrideWithValue(_Calls()),
          appRouterProvider.overrideWithValue(router),
          notificationRemoteDataSourceProvider.overrideWithValue(
            _Notifications(pending: pending.future),
          ),
        ],
      );
      try {
        final session =
            container.read(sessionProvider.notifier) as _TestSession;
        session.login();
        await _mount(tester, container, watcher: 'widget');
        pending.complete([
          NotificationItemEntity.fromJson({
            'id': 5,
            'kind': 'rtc_call_invite',
            'title': 'Fictional old invitation',
            'body': 'fictional',
            'payload': {'call_id': 59},
            'route_name': 'rtc_call',
            'route_args': {'call_id': 59},
            'is_read': false,
            'created_at': '2026-11-12T00:00:00Z',
          }),
        ]);
        await tester.idle();
        session.logout();
        await tester.pump();
        expect(router.routeInformationProvider.value.uri.path, '/idle');
      } finally {
        await _close(tester, container);
        router.dispose();
      }
    },
  );

  for (final watcher in ['provider', 'widget']) {
    testWidgets('$watcher signed-out scan sends no notification requests', (
      tester,
    ) async {
      final notifications = _Notifications();
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
          rtcRemoteDataSourceProvider.overrideWithValue(_Calls()),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
        ],
      );
      try {
        await _mount(tester, container, watcher: watcher);
        await tester.pump(const Duration(seconds: 4));
        await tester.pump();
        expect(notifications.requests, 0);
      } finally {
        await _close(tester, container);
      }
    });

    testWidgets(
      '$watcher signed-out during call read sends no notification requests',
      (tester) async {
        final pending = Completer<List<RtcSessionEntity>>();
        final notifications = _Notifications();
        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(_TestSession.new),
            rtcRemoteDataSourceProvider.overrideWithValue(
              _Calls(pending: pending.future),
            ),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
          ],
        );
        try {
          final session =
              container.read(sessionProvider.notifier) as _TestSession;
          session.login();
          await _mount(tester, container, watcher: watcher);
          session.logout();
          pending.complete(<RtcSessionEntity>[]);
          await tester.pump();
          expect(notifications.requests, 0);
        } finally {
          await _close(tester, container);
        }
      },
    );
  }

  for (final watcher in ['bootstrap', 'provider', 'widget']) {
    testWidgets('$watcher polling keeps visible notification read stable', (
      tester,
    ) async {
      var pageReads = 0;
      var pageLoadingStates = 0;
      final notifications = _Notifications();
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
          rtcRemoteDataSourceProvider.overrideWithValue(_Calls()),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
          notificationListProvider.overrideWith((ref) async {
            pageReads++;
            return <NotificationItemEntity>[];
          }),
        ],
      );
      final subscription = container.listen(notificationListProvider, (
        _,
        next,
      ) {
        if (next.isLoading) pageLoadingStates++;
      });
      try {
        (container.read(sessionProvider.notifier) as _TestSession).login();
        await container.read(notificationListProvider.future);
        final initialLoadingStates = pageLoadingStates;
        await _mount(tester, container, watcher: watcher);
        for (var tick = 0; tick < 3; tick++) {
          await tester.pump(const Duration(seconds: 2));
          await tester.pump();
        }
        expect(pageReads, 1);
        expect(pageLoadingStates, initialLoadingStates);
        expect(notifications.requests, greaterThan(1));
      } finally {
        subscription.close();
        await _close(tester, container);
      }
    });
  }

  for (final watcher in ['bootstrap', 'provider', 'widget']) {
    testWidgets(
      '$watcher polling reads calls without refreshing the shared list',
      (tester) async {
        var pageReads = 0;
        var pageLoadingStates = 0;
        final calls = _Calls();
        final notifications = _Notifications();
        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(_TestSession.new),
            rtcRemoteDataSourceProvider.overrideWithValue(calls),
            rtcCallsProvider.overrideWith((ref) async {
              pageReads++;
              return <RtcSessionEntity>[];
            }),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
          ],
        );
        final subscription = container.listen(rtcCallsProvider, (_, next) {
          if (next.isLoading) pageLoadingStates++;
        });
        try {
          (container.read(sessionProvider.notifier) as _TestSession).login();
          await container.read(rtcCallsProvider.future);
          final initialLoadingStates = pageLoadingStates;
          await _mount(tester, container, watcher: watcher);
          for (var tick = 0; tick < 3; tick++) {
            await tester.pump(const Duration(seconds: 2));
            await tester.pump();
          }
          expect(pageReads, 1);
          expect(pageLoadingStates, initialLoadingStates);
          expect(calls.requests, greaterThan(1));
          expect(notifications.requests, calls.requests);
        } finally {
          subscription.close();
          await _close(tester, container);
        }
      },
    );

    testWidgets(
      '$watcher direct scan still selects the current incoming call',
      (tester) async {
        final incomingId =
            200 + ['bootstrap', 'provider', 'widget'].indexOf(watcher);
        final calls = _Calls(
          items: [
            _call(100, peerUserId: 4),
            _call(101, incoming: false),
            _call(incomingId),
            _call(incomingId + 10),
          ],
        );
        final notifications = _Notifications();
        final router = GoRouter(
          initialLocation: '/idle',
          routes: [
            GoRoute(path: '/idle', builder: (_, _) => const SizedBox.shrink()),
            GoRoute(
              path: '${AppRouteNames.rtcIncomingCall}/:callId',
              builder: (_, _) => const SizedBox.shrink(),
            ),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(_TestSession.new),
            rtcRemoteDataSourceProvider.overrideWithValue(calls),
            // Background scans must not consume this page's cached snapshot.
            rtcCallsProvider.overrideWith((ref) async => <RtcSessionEntity>[]),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
            appRouterProvider.overrideWithValue(router),
          ],
        );
        try {
          (container.read(sessionProvider.notifier) as _TestSession).login();
          await _mount(tester, container, watcher: watcher);
          await tester.pump();
          // The widget coordinator queues navigation for the following frame.
          tester.binding.scheduleFrame();
          await tester.pump();
          await tester.idle();
          expect(
            router.routeInformationProvider.value.uri.path,
            '${AppRouteNames.rtcIncomingCall}/$incomingId',
          );
          await tester.pump(const Duration(seconds: 2));
          await tester.pump();
          expect(calls.requests, greaterThan(1));
          expect(notifications.requests, 0);
          expect(
            router.routeInformationProvider.value.uri.path,
            '${AppRouteNames.rtcIncomingCall}/$incomingId',
          );
        } finally {
          await _close(tester, container);
          router.dispose();
        }
      },
    );
  }

  testWidgets('cold login starts polling without a process restart', (
    tester,
  ) async {
    final calls = _Calls();
    final notifications = _Notifications();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_TestSession.new),
        rtcRemoteDataSourceProvider.overrideWithValue(calls),
        notificationRemoteDataSourceProvider.overrideWithValue(notifications),
      ],
    );
    await _mount(tester, container);
    await tester.pump(const Duration(seconds: 4));
    expect(calls.requests, 0);
    expect(notifications.requests, 0);
    (container.read(sessionProvider.notifier) as _TestSession).login();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls.requests, 1);
    expect(notifications.requests, 1);
    await _close(tester, container);
  });

  testWidgets('a stuck notification future releases the next call scan', (
    tester,
  ) async {
    final calls = _Calls();
    final pending = Completer<List<NotificationItemEntity>>();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_TestSession.new),
        rtcRemoteDataSourceProvider.overrideWithValue(calls),
        notificationRemoteDataSourceProvider.overrideWithValue(
          _Notifications(pending: pending.future),
        ),
      ],
    );
    await _mount(tester, container);
    (container.read(sessionProvider.notifier) as _TestSession).login();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls.requests, 1);
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls.requests, greaterThan(1));
    await _close(tester, container);
  });

  testWidgets('an old signed-out scan cannot continue into notifications', (
    tester,
  ) async {
    final pending = Completer<List<RtcSessionEntity>>();
    final notifications = _Notifications();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_TestSession.new),
        rtcRemoteDataSourceProvider.overrideWithValue(
          _Calls(pending: pending.future),
        ),
        notificationRemoteDataSourceProvider.overrideWithValue(notifications),
      ],
    );
    await _mount(tester, container);
    final session = container.read(sessionProvider.notifier) as _TestSession;
    session.login();
    await tester.pump(const Duration(seconds: 2));
    session.logout();
    pending.complete(<RtcSessionEntity>[]);
    await tester.pump();
    expect(notifications.requests, 0);
    await _close(tester, container);
  });
}
