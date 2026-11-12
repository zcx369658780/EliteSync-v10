import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_incoming_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_result_page.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _CurrentRtcSession extends SessionNotifier {
  static SessionState member(int id) => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'rtc-fixture-$id',
    user: UserSummary(id: id, phone: ''),
  );
  @override
  SessionState build() => member(1);
  void change(int id) => state = AsyncData(member(id));
}

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
  int connectRequests = 0;
  int endRequests = 0;
  int acceptRequests = 0;
  Completer<RtcSessionEntity>? pendingFetch;
  final pendingByCall = <int, Completer<RtcSessionEntity>>{};
  int joinRequests = 0;
  bool denySession = false;
  final List<String> requestOrder = [];

  @override
  Future<RtcSessionEntity> fetchCall(int callId) async {
    requestOrder.add('session');
    // Match the real data source: failed HTTP results throw Exception.
    if (denySession) throw Exception('session denied');
    if (pendingByCall[callId] case final pending?) return pending.future;
    if (pendingFetch != null) return pendingFetch!.future;
    return _session;
  }

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) async {
    requestOrder.add('join');
    joinRequests++;
    throw StateError('join denied');
  }

  @override
  Future<RtcSessionEntity> acceptCall(int callId) async {
    acceptRequests++;
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
    connectRequests++;
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
    endRequests++;
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

class NotifyingLeaveRtcService extends RtcLiveKitService {
  NotifyingLeaveRtcService(RtcRemoteDataSource rtc)
    : super(
        remoteDataSource: rtc,
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: true,
          useLiveKitRtc: true,
        ),
      );

  final List<int?> leaves = [];
  final List<int> connections = [];
  int suspensions = 0;
  bool connected = false;

  @override
  bool get isConnected => connected;

  @override
  Future<void> suspendCapture() async {
    suspensions++;
  }

  @override
  Future<void> leave({int? callId}) async {
    // Service disposal also performs an unscoped cleanup, outside page ownership.
    if (callId == null) return;
    leaves.add(callId);
    notifyListeners();
  }

  @override
  Future<void> ensureConnected(int callId) async {
    connections.add(callId);
  }
}

class _CallPagePermissions implements RtcPermissionService {
  bool granted = true;
  Completer<bool>? pendingCheck;
  @override
  Future<bool> hasVoiceCallPermission() async => pendingCheck == null ? granted : await pendingCheck!.future;
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
  bool liveKit = false,
  RtcLiveKitService? service,
  RtcPermissionService? permissions,
  GoRouter? router,
}) {
  final telemetry = FakeAppTelemetryService();
  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWith(_CurrentRtcSession.new),
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: true,
          useLiveKitRtc: liveKit,
        ),
      ),
      frontendTelemetryProvider.overrideWithValue(
        FrontendTelemetry(telemetry: telemetry),
      ),
      rtcRemoteDataSourceProvider.overrideWithValue(rtc),
      rtcPermissionServiceProvider.overrideWithValue(permissions ?? _CallPagePermissions()),
      if (service != null)
        rtcLiveKitServiceProvider.overrideWith((ref) => service),
    ],
  );
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: router != null ? MaterialApp.router(theme: AppTheme.light, routerConfig: router) : MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

RtcSessionEntity _videoCall(int id, String peer) => RtcSessionEntity.fromJson({
  'id': id,
  'mode': 'video',
  'status': 'in_call',
  'title': '视频通话',
  'initiator_user_id': 1,
  'peer_user_id': 2,
  'peer_name': peer,
  'is_initiator': true,
  'is_active': true,
});

void main() {
  testWidgets(
    'focus loss after permission approval cancels its pending fresh call read',
    (tester) async {
      final rtc = FakeRtcRemoteDataSource(
        _videoCall(123, 'PERMISSION_READ_PEER'),
      );
      final service = NotifyingLeaveRtcService(rtc);
      final permissions = _CallPagePermissions()..granted = false;
      final router = GoRouter(
        initialLocation: '/call',
        routes: [
          GoRoute(
            path: '/call',
            builder: (_, _) =>
                const RtcCallPage(callId: 123, autoConnect: false),
          ),
          GoRoute(
            path: AppRouteNames.rtcPermission,
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () {
                  permissions.granted = true;
                  rtc.pendingFetch = Completer<RtcSessionEntity>();
                  context.pop(true);
                },
                child: const Text('approve-before-read'),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _wrap(
          const SizedBox(),
          rtc: rtc,
          service: service,
          liveKit: true,
          permissions: permissions,
          router: router,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('approve-before-read'));
      await tester.pumpAndSettle();
      expect(service.connections, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      rtc.pendingFetch!.complete(rtc._session);
      await tester.pumpAndSettle();
      expect(service.connections, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'focus loss while an existing permission is checked cancels explicit reconnect',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final rtc = FakeRtcRemoteDataSource(
        _videoCall(124, 'PERMISSION_CHECK_PEER'),
      );
      final service = NotifyingLeaveRtcService(rtc);
      final permissions = _CallPagePermissions();
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 124, autoConnect: false),
          rtc: rtc,
          service: service,
          liveKit: true,
          permissions: permissions,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.connections, [124]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      permissions.pendingCheck = Completer<bool>();
      await tester.ensureVisible(find.text('重新连接'));
      await tester.tap(find.text('重新连接'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      permissions.pendingCheck!.complete(true);
      await tester.pumpAndSettle();
      expect(service.connections, [124]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a stale reconnect failure cannot close a newer reconnected room',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final rtc = FakeRtcRemoteDataSource(
        _videoCall(125, 'STALE_RECONNECT_PEER'),
      );
      final service = NotifyingLeaveRtcService(rtc);
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 125, autoConnect: false),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      final oldRead = Completer<RtcSessionEntity>();
      rtc.pendingFetch = oldRead;
      await tester.ensureVisible(find.text('重新连接'));
      await tester.tap(find.text('重新连接'));
      await tester.pump();
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
      rtc.pendingFetch = null;
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('重新连接'));
      await tester.tap(find.text('重新连接'));
      await tester.pumpAndSettle();
      expect(service.connections, [125, 125]);
      final leavesBeforeOldFailure = service.leaves.length;
      oldRead.completeError(StateError('old read failed'));
      await tester.pumpAndSettle();
      expect(service.leaves.length, leavesBeforeOldFailure);
      expect(service.connections, [125, 125]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final mode in ['voice', 'video']) {
    for (final home in [false, true]) {
      testWidgets('direct $mode route permission with Home=$home', (
        tester,
      ) async {
        final rtc = FakeRtcRemoteDataSource(
          RtcSessionEntity.fromJson({
            'id': 122,
            'mode': mode,
            'status': 'in_call',
            'initiator_user_id': 1,
            'peer_user_id': 2,
            'is_initiator': true,
            'is_active': true,
          }),
        );
        final service = NotifyingLeaveRtcService(rtc);
        final permissions = _CallPagePermissions()..granted = false;
        final modes = <String?>[];
        final router = GoRouter(
          initialLocation: '/call',
          routes: [
            GoRoute(
              path: '/call',
              builder: (_, _) =>
                  const RtcCallPage(callId: 122, autoConnect: false),
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
                    child: const Text('allow-direct-call-permissions'),
                  ),
                );
              },
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          _wrap(
            const SizedBox(),
            rtc: rtc,
            service: service,
            liveKit: true,
            permissions: permissions,
            router: router,
          ),
        );
        await tester.pumpAndSettle();
        expect(service.connections, isEmpty);
        expect(modes, [mode]);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        if (home) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.hidden,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.hidden,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
        }
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.tap(find.text('allow-direct-call-permissions'));
        await tester.pumpAndSettle();
        expect(service.connections, home ? isEmpty : [122]);
        if (!home) {
          expect(
            rtc.requestOrder.where((s) => s == 'session').length,
            greaterThanOrEqualTo(2),
          );
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets(
    'server in_call does not report media ready before audio connects',
    (tester) async {
      final rtc = FakeRtcRemoteDataSource(
        _videoCall(121, 'AUDIO_CONNECTING_PEER'),
      );
      final service = NotifyingLeaveRtcService(rtc);
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 121, autoConnect: false),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('正在连接音频'), findsOneWidget);
      expect(find.text('通话进行中'), findsNothing);
      service.connected = true;
      service.notifyListeners();
      await tester.pumpAndSettle();
      expect(find.text('等待对方音频'), findsOneWidget);
      expect(find.text('通话进行中'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'inactive round trip keeps capture closed until explicit reconnect',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final rtc = FakeRtcRemoteDataSource(_videoCall(107, 'INACTIVE_PEER'));
      final service = NotifyingLeaveRtcService(rtc);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 107, autoConnect: false),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.connections, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(service.connections, isEmpty);
      expect(find.text('采集已暂停，请点击麦克风或摄像头重新开启。'), findsOneWidget);
      final reconnect = find.text('重新连接');
      await tester.ensureVisible(reconnect);
      await tester.tap(reconnect);
      await tester.pumpAndSettle();
      expect(service.connections, [107]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(service.suspensions, 1);
      expect(service.connections, [107]);
    rtc._session = RtcSessionEntity.fromJson({
      ...rtc._sessionToJson(),
      'status': 'ended',
      'is_terminal': true,
      'is_active': false,
    });
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('采集已暂停，请点击麦克风或摄像头重新开启。'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'background suspends capture once and preserves the active call',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final rtc = FakeRtcRemoteDataSource(_videoCall(103, 'BACKGROUND_PEER'));
      final service = NotifyingLeaveRtcService(rtc);
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 103, autoConnect: false),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.connections, [103]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(service.suspensions, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(service.leaves, isEmpty);
      expect(service.suspensions, 1);
      expect(service.connections, [103]);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(service.connections, [103]);
      final reconnect = find.text('重新连接');
      await tester.ensureVisible(reconnect);
      await tester.tap(reconnect);
      await tester.pumpAndSettle();
      expect(service.connections, [103, 103]);
      expect(rtc.requestOrder, contains('session'));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('late reconnect read stays closed after background round trip', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = _videoCall(106, 'LATE_RECONNECT_PEER');
    final rtc = FakeRtcRemoteDataSource(session);
    final service = NotifyingLeaveRtcService(rtc);
    await tester.pumpWidget(
      _wrap(
        const RtcCallPage(callId: 106, autoConnect: false),
        rtc: rtc,
        service: service,
        liveKit: true,
      ),
    );
    addTearDown(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox());
    });
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    rtc.pendingFetch = Completer();
    await tester.tap(find.text('重新连接'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    rtc.pendingFetch!.complete(session);
    await tester.pumpAndSettle();
    expect(service.connections, [106]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('late call read cannot start capture while backgrounded', (
    tester,
  ) async {
    final session = _videoCall(104, 'LATE_BACKGROUND_PEER');
    final rtc = FakeRtcRemoteDataSource(session)..pendingFetch = Completer();
    final service = NotifyingLeaveRtcService(rtc);
    await tester.pumpWidget(
      _wrap(
        const RtcCallPage(callId: 104, autoConnect: false),
        rtc: rtc,
        service: service,
        liveKit: true,
      ),
    );
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    rtc.pendingFetch!.complete(session);
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.connections, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(service.connections, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'same-call polling retains video surface and scroll state until success',
    (tester) async {
      final session = _videoCall(97, 'CURRENT_VIDEO_PEER');
      final rtc = FakeRtcRemoteDataSource(session);
      final service = NotifyingLeaveRtcService(rtc);
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 97, autoConnect: false),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      final preview = find.byKey(const ValueKey('rtc-local-video-preview'));
      await tester.ensureVisible(preview);
      await tester.pumpAndSettle();
      final previewElement = tester.element(preview);
      final previewRenderObject = tester.renderObject(preview);
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      final offset = scroll.position.pixels;
      expect(offset, greaterThan(0));
      rtc.pendingFetch = Completer();
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(tester.element(preview), same(previewElement));
      expect(tester.renderObject(preview), same(previewRenderObject));
      expect(
        tester.state<ScrollableState>(find.byType(Scrollable).first),
        same(scroll),
      );
      expect(scroll.position.pixels, offset);
      expect(service.leaves, isEmpty);
      rtc.pendingFetch!.complete(session);
      await tester.pumpAndSettle();
      expect(tester.element(preview), same(previewElement));
      expect(scroll.position.pixels, offset);
      expect(service.connections, [97]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'unmount leaves active media once after Consumer subscriptions detach',
    (tester) async {
      final rtc = FakeRtcRemoteDataSource(_videoCall(102, 'EXITED_VIDEO_PEER'));
      final service = NotifyingLeaveRtcService(rtc);
      final visible = ValueNotifier(true);
      await tester.pumpWidget(
        _wrap(
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (_, show, _) => show
                ? const RtcCallPage(callId: 102, autoConnect: false)
                : const Text('通话页已关闭'),
          ),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.connections, [102]);
      visible.value = false;
      await tester.pumpAndSettle();
      expect(find.text('通话页已关闭'), findsOneWidget);
      expect(service.leaves, [102]);
      expect(tester.takeException(), isNull);
      service.notifyListeners();
      await tester.pumpAndSettle();
      expect(service.leaves, [102]);
      await tester.pumpWidget(const SizedBox());
      expect(service.leaves, [102]);
      visible.dispose();
    },
  );

  testWidgets('actual polling error removes video and closes media only once', (
    tester,
  ) async {
    final rtc = FakeRtcRemoteDataSource(_videoCall(98, 'REMOVED_VIDEO_PEER'));
    final service = NotifyingLeaveRtcService(rtc);
    await tester.pumpWidget(
      _wrap(
        const RtcCallPage(callId: 98, autoConnect: false),
        rtc: rtc,
        service: service,
        liveKit: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(service.connections, [98]);
    rtc.denySession = true;
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('通话加载失败'), findsOneWidget);
    expect(find.text('当前通话暂不可用，请重试或返回会话。'), findsOneWidget);
    expect(find.textContaining('session denied'), findsNothing);
    expect(find.text('返回会话'), findsOneWidget);
    expect(find.byKey(const ValueKey('rtc-local-video-preview')), findsNothing);
    expect(find.text('REMOVED_VIDEO_PEER'), findsNothing);
    expect(service.leaves, [98]);
    service.notifyListeners();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(service.leaves, [98]);
    await tester.pumpWidget(const SizedBox());
    expect(service.leaves, [98]);
  });

  testWidgets('pending refreshed video is hidden after account switch', (
    tester,
  ) async {
    final session = _videoCall(99, 'OLD_ACCOUNT_VIDEO_PEER');
    final rtc = FakeRtcRemoteDataSource(session);
    final service = NotifyingLeaveRtcService(rtc);
    const page = RtcCallPage(callId: 99, autoConnect: false);
    await tester.pumpWidget(
      _wrap(page, rtc: rtc, service: service, liveKit: true),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byWidget(page)),
    );
    rtc.pendingFetch = Completer();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    (container.read(sessionProvider.notifier) as _CurrentRtcSession).change(2);
    await tester.pumpAndSettle();
    rtc.pendingFetch!.complete(session);
    await tester.pumpAndSettle();
    expect(find.text('登录状态已变化，请重新打开通话'), findsOneWidget);
    expect(find.text('OLD_ACCOUNT_VIDEO_PEER'), findsNothing);
    expect(find.byKey(const ValueKey('rtc-local-video-preview')), findsNothing);
    expect(service.leaves, [99]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'switching calls cannot reuse a pending old call video projection',
    (tester) async {
      final first = _videoCall(100, 'OLD_CALL_VIDEO_PEER');
      final next = _videoCall(101, 'NEW_CALL_VIDEO_PEER');
      final rtc = FakeRtcRemoteDataSource(first);
      final service = NotifyingLeaveRtcService(rtc);
      final callId = ValueNotifier(100);
      await tester.pumpWidget(
        _wrap(
          ValueListenableBuilder<int>(
            valueListenable: callId,
            builder: (_, id, _) => RtcCallPage(callId: id, autoConnect: false),
          ),
          rtc: rtc,
          service: service,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      rtc.pendingByCall[100] = Completer();
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      rtc.pendingByCall[101] = Completer();
      callId.value = 101;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('OLD_CALL_VIDEO_PEER'), findsNothing);
      expect(
        find.byKey(const ValueKey('rtc-local-video-preview')),
        findsNothing,
      );
      expect(service.leaves, [100]);
      rtc.pendingByCall[100]!.complete(first);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('OLD_CALL_VIDEO_PEER'), findsNothing);
      expect(service.connections, [100]);
      rtc.pendingByCall[101]!.complete(next);
      await tester.pumpAndSettle();
      expect(find.text('NEW_CALL_VIDEO_PEER'), findsOneWidget);
      expect(service.connections, [100, 101]);
      await tester.pumpWidget(const SizedBox());
      expect(service.leaves, [100, 101]);
      callId.dispose();
    },
  );
  for (final page in ['call', 'incoming', 'result']) {
    for (final lateResponse in [false, true]) {
      testWidgets(
        '$page clears A projection on account change (late=$lateResponse)',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1000, 2400));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final rtc = FakeRtcRemoteDataSource(
            RtcSessionEntity.fromJson({
              'id': 96,
              'mode': 'voice',
              'status': page == 'result' ? 'ended' : 'ringing',
              'title': 'A_PRIVATE_CALL_TITLE',
              'initiator_name': 'A_PRIVATE_INITIATOR',
              'peer_name': 'A_PRIVATE_PEER',
              'initiator_user_id': 1,
              'peer_user_id': 2,
              'is_initiator': page != 'incoming',
              'is_terminal': page == 'result',
            }),
          );
          if (lateResponse) rtc.pendingFetch = Completer<RtcSessionEntity>();
          final service = NotifyingLeaveRtcService(rtc);
          final child = switch (page) {
            'incoming' => const RtcIncomingCallPage(callId: 96),
            'result' => const RtcCallResultPage(callId: 96),
            _ => const RtcCallPage(callId: 96, autoConnect: false),
          };
          await tester.pumpWidget(_wrap(child, rtc: rtc, service: service));
          if (lateResponse) {
            // Loading skeletons animate while the intentionally suspended fetch waits.
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          } else {
            await tester.pumpAndSettle();
          }
          if (!lateResponse) {
            expect(
              find.text(
                page == 'incoming' ? 'A_PRIVATE_INITIATOR' : 'A_PRIVATE_PEER',
              ),
              findsOneWidget,
            );
          }
          final container = ProviderScope.containerOf(
            tester.element(find.byWidget(child)),
          );
          final oldActions = tester
              .widgetList<AppPrimaryButton>(find.byType(AppPrimaryButton))
              .where((button) => ['挂断', '接听'].contains(button.label))
              .map((button) => button.onPressed)
              .toList();
          if (!lateResponse && page != 'result') expect(oldActions, isNotEmpty);
          // B is the other legitimate participant, but cannot inherit A's action.
          (container.read(sessionProvider.notifier) as _CurrentRtcSession)
              .change(2);
          for (final action in oldActions) {
            action?.call();
          }
          await tester.pumpAndSettle();
          if (lateResponse) {
            rtc.pendingFetch!.complete(rtc._session);
            await tester.pumpAndSettle();
          }
          expect(find.text('A_PRIVATE_CALL_TITLE'), findsNothing);
          expect(find.text('A_PRIVATE_INITIATOR'), findsNothing);
          expect(find.text('A_PRIVATE_PEER'), findsNothing);
          expect(find.text('登录状态已变化，请重新打开通话'), findsOneWidget);
          expect(rtc.endRequests, 0);
          expect(rtc.acceptRequests, 0);
          expect(service.connections, isEmpty);
          await tester.pumpWidget(const SizedBox());
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final denied in [false, true]) {
    testWidgets(
      'closed call leaves once despite notifications and polling: denied=$denied',
      (tester) async {
        final rtc = FakeRtcRemoteDataSource(
          RtcSessionEntity.fromJson({
            'id': 93,
            'mode': 'voice',
            'status': 'ended',
            'initiator_user_id': 1,
            'peer_user_id': 2,
            'is_terminal': true,
          }),
        )..denySession = denied;
        final service = NotifyingLeaveRtcService(rtc);
        await tester.pumpWidget(
          _wrap(
            const RtcCallPage(callId: 93, autoConnect: false),
            rtc: rtc,
            service: service,
          ),
        );
        await tester.pumpAndSettle();
        expect(service.leaves, [93]);
        service.notifyListeners();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 8));
        await tester.pumpAndSettle();
        expect(service.leaves, [93]);
        expect(service.connections, isEmpty);
        await tester.pumpWidget(const SizedBox());
        expect(service.leaves, [93]);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'new call lifecycle connects and revokes independently of old terminal call',
    (tester) async {
      RtcSessionEntity session(int id, String status) =>
          RtcSessionEntity.fromJson({
            'id': id,
            'mode': 'voice',
            'status': status,
            'initiator_user_id': 1,
            'peer_user_id': 2,
            'is_terminal': status == 'ended',
          });
      final rtc = FakeRtcRemoteDataSource(session(94, 'ended'));
      final service = NotifyingLeaveRtcService(rtc);
      final callId = ValueNotifier(94);
      await tester.pumpWidget(
        _wrap(
          ValueListenableBuilder<int>(
            valueListenable: callId,
            builder: (_, id, _) => RtcCallPage(callId: id, autoConnect: false),
          ),
          rtc: rtc,
          service: service,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.leaves, [94]);
      rtc._session = session(95, 'in_call');
      callId.value = 95;
      await tester.pumpAndSettle();
      expect(service.connections, [95]);
      expect(service.leaves, [94]);
      rtc._session = session(95, 'ended');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(service.leaves, [94, 95]);
      service.notifyListeners();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      expect(service.leaves, [94, 95]);
      expect(tester.takeException(), isNull);
      callId.dispose();
    },
  );

  testWidgets('denied call fetch shows an error instead of retry loading', (
    tester,
  ) async {
    final rtc = FakeRtcRemoteDataSource(
      RtcSessionEntity.fromJson({
        'id': 91,
        'mode': 'voice',
        'status': 'in_call',
        'initiator_user_id': 1,
        'peer_user_id': 2,
        'is_active': true,
      }),
    )..denySession = true;
    await tester.pumpWidget(
      _wrap(
        const RtcCallPage(callId: 91, autoConnect: false),
        rtc: rtc,
        liveKit: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('通话加载失败'), findsOneWidget);
    expect(rtc.joinRequests, 0);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('通话加载失败'), findsOneWidget);
    expect(rtc.joinRequests, 0);
    await tester.pumpWidget(const SizedBox());
  });
  for (final outcome in ['active', 'terminal', 'unknown']) {
    testWidgets('explicit reconnect rechecks current session: $outcome', (
      tester,
    ) async {
      final rtc = FakeRtcRemoteDataSource(
        RtcSessionEntity.fromJson({
          'id': 72,
          'mode': 'voice',
          'status': 'in_call',
          'initiator_user_id': 1,
          'peer_user_id': 2,
          'is_initiator': true,
          'is_active': true,
        }),
      );
      await tester.pumpWidget(
        _wrap(
          const RtcCallPage(callId: 72, autoConnect: false),
          rtc: rtc,
          liveKit: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(rtc.joinRequests, 1);
      expect(find.text('重新连接'), findsOneWidget);
      final previous = rtc.requestOrder.length;
      if (outcome == 'terminal') {
        rtc._session = RtcSessionEntity.fromJson({
          ...rtc._sessionToJson(),
          'status': 'ended',
          'is_terminal': true,
          'is_active': false,
        });
      } else if (outcome == 'unknown') {
        rtc.denySession = true;
      }
      await tester.ensureVisible(find.text('重新连接'));
      await tester.tap(find.text('重新连接'));
      await tester.pumpAndSettle();
      expect(rtc.requestOrder[previous], 'session');
      expect(rtc.joinRequests, outcome == 'active' ? 2 : 1);
      if (outcome == 'active') {
        expect(rtc.requestOrder[previous + 1], 'join');
      }
      expect(rtc.connectRequests, 0);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('polling a revoked call replaces cached data with an error', (
    tester,
  ) async {
    final rtc = FakeRtcRemoteDataSource(
      RtcSessionEntity.fromJson({
        'id': 92,
        'mode': 'voice',
        'status': 'in_call',
        'initiator_user_id': 1,
        'peer_user_id': 2,
        'is_active': true,
      }),
    );
    await tester.pumpWidget(
      _wrap(
        const RtcCallPage(callId: 92, autoConnect: false),
        rtc: rtc,
        liveKit: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('音频连接异常'), findsOneWidget);
    expect(rtc.joinRequests, 1);
    rtc.denySession = true;
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('通话加载失败'), findsOneWidget);
    expect(find.text('音频连接异常'), findsNothing);
    expect(rtc.joinRequests, 1);
    rtc.denySession = false;
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('音频连接异常'), findsOneWidget);
    // Fetch recovery must not silently republish media. Explicit reconnect remains required.
    expect(rtc.joinRequests, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('RtcCallPage renders session status and actions', (tester) async {
    final session = RtcSessionEntity.fromJson({
      'id': 1,
      'call_key': 'call-1',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'calling',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': true,
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
      _wrap(
        const RtcCallPage(callId: 1, title: '语音通话', autoConnect: false),
        rtc: rtc,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('语音通话'), findsWidgets);
    expect(find.text('Callee'), findsOneWidget);
    expect(find.text('等待对方接听'), findsOneWidget);
    expect(find.text('挂断'), findsWidgets);
  });
  testWidgets('video session renders remote and local video surfaces', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final session = RtcSessionEntity.fromJson({
      'id': 2,
      'call_key': 'call-video-2',
      'mode': 'video',
      'status': 'calling',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': true,
    });
    await tester.pumpWidget(
      _wrap(
        const RtcCallPage(callId: 2, autoConnect: false),
        rtc: FakeRtcRemoteDataSource(session),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('等待对方视频'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('rtc-local-video-preview')),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('本机视频预览')), findsOneWidget);
    expect(find.text('视频预留'), findsNothing);
    semantics.dispose();
  });
  for (final status in ['calling', 'ringing']) {
    testWidgets(
      '$status call does not auto-connect before independent acceptance',
      (tester) async {
        final rtc = FakeRtcRemoteDataSource(
          RtcSessionEntity.fromJson({
            'id': 31,
            'mode': 'voice',
            'status': status,
            'initiator_user_id': 1,
            'peer_user_id': 2,
            'is_initiator': true,
            'is_active': true,
          }),
        );
        await tester.pumpWidget(_wrap(const RtcCallPage(callId: 31), rtc: rtc));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(rtc.connectRequests, 0);
        expect(find.text('进入通话'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
