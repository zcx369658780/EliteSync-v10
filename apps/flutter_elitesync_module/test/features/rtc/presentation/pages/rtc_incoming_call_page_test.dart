import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'dart:async';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import '../../rtc_test_session.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_incoming_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        appVersionProvider: () async => '0.04.06',
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

class FakeRtcRemoteDataSource extends RtcRemoteDataSource {
  FakeRtcRemoteDataSource(this._session)
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
      );

  RtcSessionEntity _session;
  int acceptRequests = 0;
  int rejectRequests = 0;
  Completer<RtcSessionEntity>? pendingAccept;

  @override
  Future<RtcSessionEntity> fetchCall(int callId) async => callId == _session.id
      ? _session
      : RtcSessionEntity.fromJson({..._sessionToJson(), 'id': callId});

  @override
  Future<RtcSessionEntity> acceptCall(int callId) async {
    acceptRequests++;
    if (pendingAccept != null) return pendingAccept!.future;
    _session = RtcSessionEntity.fromJson({
      ..._sessionToJson(),
      'status': 'connecting',
      'accepted_at': '2026-04-21T12:00:00Z',
      'accepted_by_user_id': _session.peerUserId,
      'latest_event_name': 'accepted',
      'events': [
        ..._session.events.map(
          (event) => {
            'id': event.id,
            'event_name': event.eventName,
            'user_id': event.userId,
            'payload': event.payload,
            'created_at': event.createdAt,
          },
        ),
        {
          'id': 2,
          'event_name': 'accepted',
          'user_id': _session.peerUserId,
          'payload': <String, dynamic>{},
          'created_at': '2026-04-21T12:00:01Z',
        },
      ],
    });
    return _session;
  }

  @override
  Future<RtcSessionEntity> connectCall(int callId) async {
    _session = RtcSessionEntity.fromJson({
      ..._sessionToJson(),
      'status': 'in_call',
      'started_at': '2026-04-21T12:00:02Z',
      'latest_event_name': 'connected',
    });
    return _session;
  }

  @override
  Future<RtcSessionEntity> rejectCall(int callId) async {
    rejectRequests++;
    _session = RtcSessionEntity.fromJson({
      ..._sessionToJson(),
      'status': 'rejected',
      'ended_at': '2026-04-21T12:00:03Z',
      'failure_code': 'rejected',
      'failure_message': '通话已被拒绝',
      'latest_event_name': 'rejected',
    });
    return _session;
  }

  @override
  Future<RtcSessionEntity> endCall(int callId) async {
    _session = RtcSessionEntity.fromJson({
      ..._sessionToJson(),
      'status': 'ended',
      'ended_at': '2026-04-21T12:00:04Z',
      'latest_event_name': 'ended',
    });
    return _session;
  }

  Map<String, dynamic> _sessionToJson() {
    return <String, dynamic>{
      'id': _session.id,
      'call_key': _session.callKey,
      'room_key': _session.roomKey,
      'mode': _session.mode,
      'status': _session.status,
      'title': _session.title,
      'initiator_user_id': _session.initiatorUserId,
      'peer_user_id': _session.peerUserId,
      'initiator_name': _session.initiatorName,
      'peer_name': _session.peerName,
      'is_initiator': _session.isInitiator,
      'accepted_by_user_id': _session.acceptedByUserId,
      'ended_by_user_id': _session.endedByUserId,
      'failure_code': _session.failureCode,
      'failure_message': _session.failureMessage,
      'ringing_at': _session.ringingAt,
      'accepted_at': _session.acceptedAt,
      'started_at': _session.startedAt,
      'ended_at': _session.endedAt,
      'expires_at': _session.expiresAt,
      'created_at': _session.createdAt,
      'updated_at': _session.updatedAt,
      'latest_event_name': _session.latestEventName,
      'events': _session.events
          .map(
            (event) => {
              'id': event.id,
              'event_name': event.eventName,
              'user_id': event.userId,
              'payload': event.payload,
              'created_at': event.createdAt,
            },
          )
          .toList(),
      'is_active': _session.isActive,
      'is_terminal': _session.isTerminal,
    };
  }
}

class _IncomingPermissions implements RtcPermissionService {
  bool granted = false;
  @override
  Future<bool> hasVoiceCallPermission() async => granted;
  @override
  Future<bool> hasCameraPermission() async => granted;
  @override
  Future<bool> ensureVoiceCallPermission() async => granted;
  @override
  Future<bool> ensureCameraPermission() async => granted;
  @override
  Future<bool> openSettings() async => false;
}

Widget _wrap(
  Widget child, {
  required RtcRemoteDataSource rtc,
  GoRouter? router,
  RtcPermissionService? permissions,
}) {
  final telemetry = FakeAppTelemetryService();
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(RtcTestSession.new),
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: true,
          useLiveKitRtc: permissions != null,
        ),
      ),
      frontendTelemetryProvider.overrideWithValue(
        FrontendTelemetry(telemetry: telemetry),
      ),
      rtcRemoteDataSourceProvider.overrideWithValue(rtc),
      if (permissions != null) rtcPermissionServiceProvider.overrideWithValue(permissions),
    ],
    child: router != null
        ? MaterialApp.router(theme: AppTheme.light, routerConfig: router)
        : MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: child,
          ),
  );
}

void main() {
  testWidgets(
    'late permission from call A cannot accept A after A B A navigation',
    (tester) async {
      final session = RtcSessionEntity.fromJson({
        'id': 140,
        'mode': 'voice',
        'status': 'ringing',
        'initiator_user_id': 1,
        'peer_user_id': 2,
        'is_initiator': false,
        'is_active': true,
      });
      final rtc = FakeRtcRemoteDataSource(session);
      final permissions = _IncomingPermissions();
      final call = ValueNotifier<int>(140);
      addTearDown(call.dispose);
      final router = GoRouter(
        initialLocation: '/incoming',
        routes: [
          GoRoute(
            path: '/incoming',
            builder: (_, _) => ValueListenableBuilder<int>(
              valueListenable: call,
              builder: (_, id, _) => RtcIncomingCallPage(callId: id),
            ),
          ),
          GoRoute(
            path: AppRouteNames.rtcPermission,
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () {
                  permissions.granted = true;
                  context.pop(true);
                },
                child: const Text('late-grant'),
              ),
            ),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCall}/:callId',
            builder: (_, _) => const Scaffold(body: Text('accepted-route')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _wrap(
          const SizedBox(),
          rtc: rtc,
          router: router,
          permissions: permissions,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('接听'));
      await tester.tap(find.text('接听'));
      await tester.pumpAndSettle();
      call.value = 141;
      await tester.pumpAndSettle();
      call.value = 140;
      await tester.pumpAndSettle();
      await tester.tap(find.text('late-grant'));
      await tester.pumpAndSettle();
      expect(rtc.acceptRequests, 0);
      expect(find.text('accepted-route'), findsNothing);
      final accept = tester.widget<AppPrimaryButton>(
        find.widgetWithText(AppPrimaryButton, '接听'),
      );
      expect(accept.isLoading, isFalse);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Home after accept POST cancels the late navigation and releases busy',
    (tester) async {
      final session = RtcSessionEntity.fromJson({
        'id': 142,
        'mode': 'voice',
        'status': 'ringing',
        'initiator_user_id': 1,
        'peer_user_id': 2,
        'is_initiator': false,
        'is_active': true,
      });
      final rtc = FakeRtcRemoteDataSource(session)
        ..pendingAccept = Completer<RtcSessionEntity>();
      final permissions = _IncomingPermissions()..granted = true;
      final router = GoRouter(
        initialLocation: '/incoming',
        routes: [
          GoRoute(
            path: '/incoming',
            builder: (_, _) => const RtcIncomingCallPage(callId: 142),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCall}/:callId',
            builder: (_, _) => const Scaffold(body: Text('accepted-route')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _wrap(
          const SizedBox(),
          rtc: rtc,
          router: router,
          permissions: permissions,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('接听'));
      await tester.tap(find.text('接听'));
      await tester.pump();
      expect(rtc.acceptRequests, 1);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      rtc.pendingAccept!.complete(
        RtcSessionEntity.fromJson({
          ...rtc._sessionToJson(),
          'status': 'connecting',
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('accepted-route'), findsNothing);
      final accept = tester.widget<AppPrimaryButton>(
        find.widgetWithText(AppPrimaryButton, '接听'),
      );
      expect(accept.isLoading, isFalse);
      expect(rtc.acceptRequests, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final mode in ['voice', 'video']) {
    testWidgets('incoming $mode obtains permissions before acceptance', (
      tester,
    ) async {
      final rtc = FakeRtcRemoteDataSource(
        RtcSessionEntity.fromJson({
          'id': 131,
          'mode': mode,
          'status': 'ringing',
          'initiator_user_id': 1,
          'peer_user_id': 2,
          'is_initiator': false,
          'is_active': true,
        }),
      );
      final permissions = _IncomingPermissions();
      final modes = <String?>[];
      final router = GoRouter(
        initialLocation: '/incoming',
        routes: [
          GoRoute(
            path: '/incoming',
            builder: (_, _) => const RtcIncomingCallPage(callId: 131),
          ),
          GoRoute(
            path: AppRouteNames.rtcPermission,
            builder: (context, state) {
              modes.add(state.uri.queryParameters['mode']);
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    permissions.granted = true;
                    context.pop(true);
                  },
                  child: const Text('grant-test-call-permissions'),
                ),
              );
            },
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCall}/:callId',
            builder: (_, _) =>
                const Scaffold(body: Text('accepted-after-permission')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _wrap(
          const SizedBox(),
          rtc: rtc,
          router: router,
          permissions: permissions,
        ),
      );
      await tester.pumpAndSettle();
      final accept = find.text('接听');
      await tester.ensureVisible(accept);
      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(rtc.acceptRequests, 0);
      expect(modes, [mode]);
      await tester.tap(find.text('grant-test-call-permissions'));
      await tester.pumpAndSettle();
      expect(rtc.acceptRequests, 1);
      expect(find.text('accepted-after-permission'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('RtcIncomingCallPage renders incoming call actions', (
    tester,
  ) async {
    final session = RtcSessionEntity.fromJson({
      'id': 2,
      'call_key': 'call-2',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'ringing',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': false,
      'accepted_by_user_id': null,
      'ended_by_user_id': null,
      'failure_code': null,
      'failure_message': null,
      'ringing_at': '2026-04-21T12:00:00Z',
      'accepted_at': null,
      'started_at': null,
      'ended_at': null,
      'expires_at': '2026-04-21T12:02:00Z',
      'created_at': '2026-04-21T12:00:00Z',
      'updated_at': '2026-04-21T12:00:00Z',
      'latest_event_name': 'created',
      'events': [
        {
          'id': 1,
          'event_name': 'created',
          'user_id': 1,
          'payload': {'mode': 'voice'},
          'created_at': '2026-04-21T12:00:00Z',
        },
      ],
      'is_active': true,
      'is_terminal': false,
    });
    final rtc = FakeRtcRemoteDataSource(session);

    await tester.pumpWidget(
      _wrap(const RtcIncomingCallPage(callId: 2, title: '来电'), rtc: rtc),
    );

    await tester.pumpAndSettle();

    expect(find.text('来电提醒'), findsOneWidget);
    expect(find.text('Caller'), findsOneWidget);
    expect(find.text('来电中'), findsOneWidget);
    expect(find.text('接听'), findsWidgets);
    expect(find.text('拒绝'), findsWidgets);
  });

  testWidgets('RtcIncomingCallPage hides accept actions for terminal calls', (
    tester,
  ) async {
    final session = RtcSessionEntity.fromJson({
      'id': 116,
      'call_key': 'call-ended',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'ended',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': false,
      'accepted_by_user_id': 2,
      'ended_by_user_id': 1,
      'failure_code': null,
      'failure_message': null,
      'ringing_at': '2026-05-08T06:29:31Z',
      'accepted_at': '2026-05-08T06:29:33Z',
      'started_at': '2026-05-08T06:29:33Z',
      'ended_at': '2026-05-08T06:29:34Z',
      'expires_at': '2026-05-08T06:59:34Z',
      'created_at': '2026-05-08T06:29:31Z',
      'updated_at': '2026-05-08T06:29:34Z',
      'latest_event_name': 'ended',
      'events': [
        {
          'id': 1,
          'event_name': 'created',
          'user_id': 1,
          'payload': {'mode': 'voice'},
          'created_at': '2026-05-08T06:29:31Z',
        },
        {
          'id': 2,
          'event_name': 'ended',
          'user_id': 1,
          'payload': <String, dynamic>{},
          'created_at': '2026-05-08T06:29:34Z',
        },
      ],
      'is_active': false,
      'is_terminal': true,
    });
    final rtc = FakeRtcRemoteDataSource(session);

    await tester.pumpWidget(
      _wrap(const RtcIncomingCallPage(callId: 116, title: '语音来电'), rtc: rtc),
    );

    await tester.pumpAndSettle();

    expect(find.text('通话结束'), findsOneWidget);
    expect(find.text('查看结果'), findsOneWidget);
    expect(find.text('接听'), findsNothing);
    expect(find.text('拒绝'), findsNothing);
  });
  for (final action in ['接听', '拒绝']) {
    testWidgets('default incoming page requires explicit $action action', (
      tester,
    ) async {
      final rtc = FakeRtcRemoteDataSource(
        RtcSessionEntity.fromJson({
          'id': 29,
          'mode': 'video',
          'status': 'ringing',
          'initiator_user_id': 1,
          'peer_user_id': 2,
          'initiator_name': 'Caller',
          'is_initiator': false,
          'is_active': true,
        }),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const RtcIncomingCallPage(callId: 29),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCall}/:callId',
            builder: (_, _) => const Scaffold(body: Text('accepted route')),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCallResult}/:callId',
            builder: (_, _) => const Scaffold(body: Text('rejected route')),
          ),
        ],
      );
      await tester.pumpWidget(
        _wrap(const SizedBox(), rtc: rtc, router: router),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      expect(
        rtc.acceptRequests,
        0,
        reason: 'Rendering an incoming call is not acceptance',
      );
      expect(rtc.rejectRequests, 0);
      final button = find.text(action);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(rtc.acceptRequests, action == '接听' ? 1 : 0);
      expect(rtc.rejectRequests, action == '拒绝' ? 1 : 0);
      expect(
        find.text(action == '接听' ? 'accepted route' : 'rejected route'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    });
  }
}
