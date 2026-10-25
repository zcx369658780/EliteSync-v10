import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_ice_diagnostic.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class _DiagnosticRoom extends lk.Room {
  final started = Completer<void>();
  final connected = Completer<void>();
  lk.ConnectOptions? options;
  @override
  Future<void> connect(
    String url,
    String token, {
    lk.ConnectOptions? connectOptions,
    lk.RoomOptions? roomOptions,
    lk.FastConnectOptions? fastConnectOptions,
  }) async {
    options = connectOptions;
    started.complete();
    await connected.future;
  }

  @override
  Future<void> disconnect() async {}
}

class _DiagnosticSource extends RtcRemoteDataSource {
  _DiagnosticSource() : super(apiClient: ApiClient(dio: Dio()));
  int ends = 0;
  final endStarted = Completer<void>();
  Completer<RtcSessionEntity>? pendingEnd;
  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int id) async =>
      RtcLiveKitJoinInfoEntity.fromJson({
        'enabled': true,
        'url': 'ws://127.0.0.1',
        'token': 'unit-placeholder-not-a-JWT',
        'mode': 'voice',
      });
  @override
  Future<RtcSessionEntity> heartbeatCall(int id) async =>
      RtcSessionEntity.fromJson({'id': id, 'status': 'connecting'});
  @override
  Future<RtcSessionEntity> endCall(int id) async {
    ends++;
    if (!endStarted.isCompleted) endStarted.complete();
    final pending = pendingEnd;
    pendingEnd = null;
    if (pending != null) return pending.future;
    return RtcSessionEntity.fromJson({
      'id': id,
      'status': 'ended',
      'is_terminal': true,
    });
  }
}

class _QueuedHeartbeatSource extends _DiagnosticSource {
  final heartbeats = <Completer<RtcSessionEntity>>[];

  @override
  Future<RtcSessionEntity> heartbeatCall(int id) {
    final reply = Completer<RtcSessionEntity>();
    heartbeats.add(reply);
    return reply.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const env = AppEnv(
    flavor: AppFlavor.dev,
    appName: 'ICE isolation test',
    apiBaseUrl: 'http://127.0.0.1:8031/',
    useMockData: false,
    useLiveKitRtc: true,
    restorationLocalBuild: true,
  );
  const channel = MethodChannel('elitesync/bootstrap');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('compile flag off never asks the host for diagnostic access', () async {
    var hostReads = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      hostReads++;
      return {};
    });
    expect(await verifyIceDiagnosticHost(env), false);
    expect(hostReads, iceDiagnosticRequested ? 1 : 0);
  });

  test('native identity cannot arm the ordinary R1 package', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'debugBuild': 'true',
        'iceDiagnosticBuild': 'true',
        'applicationId': 'com.elitesync.v1015r1dev',
        'apiBaseUrl': env.apiBaseUrl,
      },
    );
    expect(await verifyIceDiagnosticHost(env), false);
  });

  test(
    'missing native debug or native diagnostic identity fails closed',
    () async {
      for (final field in ['debugBuild', 'iceDiagnosticBuild']) {
        messenger.setMockMethodCallHandler(
          channel,
          (_) async => {
            'debugBuild': field == 'debugBuild' ? 'false' : 'true',
            'iceDiagnosticBuild': field == 'iceDiagnosticBuild'
                ? 'false'
                : 'true',
            'applicationId': 'com.elitesync.v1015icediag',
            'apiBaseUrl': env.apiBaseUrl,
          },
        );
        expect(await verifyIceDiagnosticHost(env), false);
      }
    },
  );

  test(
    'explicit flag build additionally requires the native isolated identity',
    () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => {
          'debugBuild': 'true',
          'iceDiagnosticBuild': 'true',
          'applicationId': 'com.elitesync.v1015icediag',
          'apiBaseUrl': env.apiBaseUrl,
        },
      );
      expect(await verifyIceDiagnosticHost(env), iceDiagnosticRequested);
    },
  );

  if (iceDiagnosticRequested) {
    for (final lateHeartbeat in ['terminal', 'error']) {
      test('old heartbeat $lateHeartbeat cannot end same-call retry', () async {
        messenger.setMockMethodCallHandler(
          channel,
          (_) async => {
            'debugBuild': 'true',
            'iceDiagnosticBuild': 'true',
            'applicationId': 'com.elitesync.v1015icediag',
            'apiBaseUrl': env.apiBaseUrl,
          },
        );
        final source = _QueuedHeartbeatSource();
        final firstRoom = _DiagnosticRoom();
        final nextRoom = _DiagnosticRoom();
        var rooms = 0;
        final service = RtcLiveKitService.mediaControlTest(
          remoteDataSource: source,
          appEnv: env,
          room: _DiagnosticRoom(),
          roomFactory: () => rooms++ == 0 ? firstRoom : nextRoom,
          microphonePermission: () async => false,
          cameraPermission: () async => false,
        );
        addTearDown(service.dispose);
        final first = service.ensureConnected(55);
        await firstRoom.started.future;
        await service.leave(callId: 55);
        firstRoom.connected.complete();
        await first;
        final next = service.ensureConnected(55);
        await nextRoom.started.future;
        expect(source.heartbeats, hasLength(2));
        if (lateHeartbeat == 'error') {
          source.heartbeats.first.completeError(
            StateError('old heartbeat failed'),
          );
        } else {
          source.heartbeats.first.complete(
            RtcSessionEntity.fromJson({
              'id': 55,
              'status': 'ended',
              'is_terminal': true,
            }),
          );
        }
        await Future<void>.delayed(Duration.zero);
        expect(service.isConnecting, true);
        expect(service.connectedCallId, 55);
        expect(service.failureMessage, isNull);
        source.heartbeats.last.complete(
          RtcSessionEntity.fromJson({'id': 55, 'status': 'connecting'}),
        );
        nextRoom.connected.complete();
        await next;
        expect(service.connectedCallId, isNull);
      });
    }

    for (final lateEnd in ['success', 'error']) {
      test(
        'late diagnostic end $lateEnd cannot close same-call retry',
        () async {
          messenger.setMockMethodCallHandler(
            channel,
            (_) async => {
              'debugBuild': 'true',
              'iceDiagnosticBuild': 'true',
              'applicationId': 'com.elitesync.v1015icediag',
              'apiBaseUrl': env.apiBaseUrl,
            },
          );
          final endReply = Completer<RtcSessionEntity>();
          final source = _DiagnosticSource()..pendingEnd = endReply;
          final firstRoom = _DiagnosticRoom();
          final nextRoom = _DiagnosticRoom();
          var rooms = 0;
          final service = RtcLiveKitService.mediaControlTest(
            remoteDataSource: source,
            appEnv: env,
            room: _DiagnosticRoom(),
            roomFactory: () => rooms++ == 0 ? firstRoom : nextRoom,
            microphonePermission: () async => false,
            cameraPermission: () async => false,
          );
          addTearDown(service.dispose);
          final first = service.ensureConnected(55);
          await firstRoom.started.future;
          firstRoom.connected.complete();
          await source.endStarted.future;
          await service.leave(callId: 55);
          final next = service.ensureConnected(55);
          await nextRoom.started.future;
          if (lateEnd == 'error') {
            endReply.completeError(StateError('old diagnostic end failed'));
          } else {
            endReply.complete(
              RtcSessionEntity.fromJson({'id': 55, 'status': 'ended'}),
            );
          }
          await first;
          expect(service.isConnecting, true);
          expect(service.connectedCallId, 55);
          nextRoom.connected.complete();
          await next;
          expect(service.isConnecting, false);
          expect(service.connectedCallId, isNull);
          expect(source.ends, 2);
        },
      );
    }

    for (final leaveEarly in [false, true]) {
      test(
        'diagnostic connect ${leaveEarly ? 'cancelled' : 'success'} never requests media and exits legally',
        () async {
          messenger.setMockMethodCallHandler(
            channel,
            (_) async => {
              'debugBuild': 'true',
              'iceDiagnosticBuild': 'true',
              'applicationId': 'com.elitesync.v1015icediag',
              'apiBaseUrl': env.apiBaseUrl,
            },
          );
          final source = _DiagnosticSource();
          final room = _DiagnosticRoom();
          var permissionRequests = 0;
          final service = RtcLiveKitService.mediaControlTest(
            remoteDataSource: source,
            appEnv: env,
            room: _DiagnosticRoom(),
            roomFactory: () => room,
            microphonePermission: () async {
              permissionRequests++;
              return false;
            },
            cameraPermission: () async {
              permissionRequests++;
              return false;
            },
          );
          final connection = service.ensureConnected(55);
          await room.started.future;
          if (leaveEarly) await service.leave();
          room.connected.complete();
          await connection;
          expect(permissionRequests, 0);
          expect(room.options!.autoSubscribe, false);
          expect(source.ends, leaveEarly ? 0 : 1);
          expect(service.connectedCallId, isNull);
          expect(service.microphoneEnabled, false);
          expect(service.cameraEnabled, false);
          service.dispose();
        },
      );
    }
    test(
      'diagnostic mode rejects microphone and camera before any permission request',
      () async {
        final service = RtcLiveKitService(
          remoteDataSource: RtcRemoteDataSource(
            apiClient: ApiClient(dio: Dio()),
          ),
          appEnv: env,
        );
        await expectLater(service.setMicrophoneEnabled(true), throwsStateError);
        await expectLater(service.setCameraEnabled(true), throwsStateError);
        expect(service.isConnected, false);
        service.dispose();
      },
    );
  }
}
