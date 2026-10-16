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
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
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
  int connectRequests = 0;
  int joinRequests = 0;
  bool denySession = false;
  final List<String> requestOrder = [];

  @override
  Future<RtcSessionEntity> fetchCall(int callId) async {
    requestOrder.add('session');
    // Match the real data source: failed HTTP results throw Exception.
    if (denySession) throw Exception('session denied');
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

Widget _wrap(
  Widget child, {
  required RtcRemoteDataSource rtc,
  bool liveKit = false,
}) {
  final telemetry = FakeAppTelemetryService();
  return ProviderScope(
    overrides: [
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
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
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
    expect(find.text('通话进行中'), findsOneWidget);
    expect(rtc.joinRequests, 1);
    rtc.denySession = true;
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('通话加载失败'), findsOneWidget);
    expect(find.text('通话进行中'), findsNothing);
    expect(rtc.joinRequests, 1);
    rtc.denySession = false;
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('通话进行中'), findsOneWidget);
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
