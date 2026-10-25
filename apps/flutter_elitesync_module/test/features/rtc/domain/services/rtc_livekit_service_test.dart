import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _DeniedRtcSource extends RtcRemoteDataSource {
  _DeniedRtcSource({this.unavailable = false})
    : super(apiClient: ApiClient(dio: Dio()));
  final bool unavailable;
  int requests = 0;

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) async {
    requests++;
    if (!unavailable) throw StateError('permission denied');
    return RtcLiveKitJoinInfoEntity.fromJson({'enabled': false});
  }
}

class _PendingRtcSource extends _DeniedRtcSource {
  final reply = Completer<RtcLiveKitJoinInfoEntity>();

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) =>
      reply.future;
}

class _QueuedRtcSource extends _DeniedRtcSource {
  final callIds = <int>[];
  final replies = <Completer<RtcLiveKitJoinInfoEntity>>[];

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) {
    callIds.add(callId);
    final reply = Completer<RtcLiveKitJoinInfoEntity>();
    replies.add(reply);
    return reply.future;
  }
}

RtcLiveKitService _service(_DeniedRtcSource source, {bool enabled = true}) =>
    RtcLiveKitService(
      remoteDataSource: source,
      appEnv: AppEnv(
        flavor: AppFlavor.dev,
        appName: 'RTC unit test',
        apiBaseUrl: 'http://127.0.0.1',
        useMockData: false,
        useLiveKitRtc: enabled,
      ),
    );

class _MediaParticipant implements LocalParticipant {
  int microphonePublications = 0;
  int cameraPublications = 0;
  @override
  Future<LocalTrackPublication?> setMicrophoneEnabled(
    bool enabled, {
    AudioCaptureOptions? audioCaptureOptions,
  }) async {
    if (enabled) microphonePublications++;
    return null;
  }

  @override
  Future<LocalTrackPublication?> setCameraEnabled(
    bool enabled, {
    CameraCaptureOptions? cameraCaptureOptions,
  }) async {
    if (enabled) cameraPublications++;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MediaRoom implements Room {
  _MediaRoom(this.localParticipant);
  Completer<void>? disconnectPending;
  Object? disconnectError;
  Object? disposeError;
  Completer<void>? disposePending;
  final disconnectStarted = Completer<void>();
  final disposeStarted = Completer<void>();
  @override
  final LocalParticipant localParticipant;
  @override
  void removeListener(VoidCallback listener) {}
  @override
  Future<void> disconnect() async {
    if (!disconnectStarted.isCompleted) disconnectStarted.complete();
    await disconnectPending?.future;
    if (disconnectError != null) throw disconnectError!;
  }

  @override
  Future<bool> dispose() async {
    if (!disposeStarted.isCompleted) disposeStarted.complete();
    await disposePending?.future;
    if (disposeError != null) throw disposeError!;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'leave waits for renderer cancellation before disconnect and dispose',
    () async {
      final room = _MediaRoom(_MediaParticipant());
      final gate = Completer<void>();
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _DeniedRtcSource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Cleanup test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
        rendererCancel: () => gate.future,
      );
      final first = service.leave();
      var secondCompleted = false;
      final second = service.leave().then((_) => secondCompleted = true);
      await Future<void>.delayed(Duration.zero);
      expect(room.disconnectStarted.isCompleted, isFalse);
      expect(room.disposeStarted.isCompleted, isFalse);
      expect(secondCompleted, isFalse);
      gate.complete();
      await Future.wait([first, second]);
      expect(room.disconnectStarted.isCompleted, isTrue);
      expect(room.disposeStarted.isCompleted, isTrue);
      expect(service.lastCleanupSucceeded, isTrue);
      service.dispose();
    },
  );

  test(
    'renderer cancel failure still disposes room and prevents a new join',
    () async {
      final room = _MediaRoom(_MediaParticipant());
      final source = _QueuedRtcSource();
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: source,
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Cleanup test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
          useLiveKitRtc: true,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
        rendererCancel: () async => throw StateError('injected cancel failure'),
      );
      await service.leave();
      expect(room.disposeStarted.isCompleted, isTrue);
      expect(service.lastCleanupSucceeded, isFalse);
      expect(service.failureMessage, isNotNull);
      await expectLater(service.ensureConnected(19), throwsStateError);
      expect(source.callIds, isEmpty);
      service.dispose();
    },
  );

  test(
    'room disposal failure is observable instead of successful leave',
    () async {
      final room = _MediaRoom(_MediaParticipant())
        ..disposeError = StateError('injected room failure');
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _DeniedRtcSource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Cleanup test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
      );
      await service.leave();
      expect(service.lastCleanupSucceeded, isFalse);
      expect(service.failureMessage, contains('清理失败'));
      await service.leave();
      expect(service.lastCleanupSucceeded, isFalse);
      service.dispose();
    },
  );

  test('disconnect failure still waits for room disposal', () async {
    final room = _MediaRoom(_MediaParticipant())
      ..disconnectError = StateError('disconnect timeout')
      ..disposePending = Completer<void>();
    final service = RtcLiveKitService.mediaControlTest(
      remoteDataSource: _DeniedRtcSource(),
      appEnv: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'Media teardown test',
        apiBaseUrl: 'http://127.0.0.1',
        useMockData: false,
      ),
      room: room,
      microphonePermission: () async => true,
      cameraPermission: () async => true,
    );
    var closed = false;
    final closing = service.leave().then((_) => closed = true);
    await Future<void>.delayed(Duration.zero);
    try {
      expect(room.disposeStarted.isCompleted, true);
      expect(closed, false);
    } finally {
      room.disposePending!.complete();
      await closing;
      service.dispose();
    }
    expect(closed, true);
  });

  test(
    'reconnect waits for detached room teardown before loading credentials',
    () async {
      final room = _MediaRoom(_MediaParticipant())
        ..disconnectPending = Completer<void>();
      final source = _QueuedRtcSource();
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: source,
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Media teardown test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
          useLiveKitRtc: true,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
      );
      final closing = service.leave();
      await room.disconnectStarted.future;
      final reconnect = service.ensureConnected(19);
      try {
        expect(source.callIds, isEmpty);
      } finally {
        // Cancellation while teardown is pending must not start a new join.
        service.dispose();
        for (final reply in source.replies) {
          reply.complete(RtcLiveKitJoinInfoEntity.fromJson({'enabled': false}));
        }
        room.disconnectPending!.complete();
        await closing;
        await reconnect;
      }
      expect(source.callIds, isEmpty);
    },
  );

  for (final nextCall in [19, 20]) {
    for (final lateResult in ['unavailable', 'error']) {
      test(
        'cancelled credential request cannot block or clear call $nextCall after late $lateResult',
        () async {
          final source = _QueuedRtcSource();
          final service = _service(source);
          addTearDown(service.dispose);
          final oldConnection = service.ensureConnected(19);
          expect(source.callIds, [19]);
          await service.leave(callId: 19);
          expect(service.isConnecting, false);

          final nextConnection = service.ensureConnected(nextCall);
          final nextFailure = expectLater(nextConnection, throwsStateError);
          expect(source.callIds, [19, nextCall]);
          if (lateResult == 'error') {
            source.replies.first.completeError(
              StateError('old request denied'),
            );
          } else {
            source.replies.first.complete(
              RtcLiveKitJoinInfoEntity.fromJson({'enabled': false}),
            );
          }
          await oldConnection;
          expect(service.isConnecting, true);
          expect(service.failureMessage, isNull);
          await service.ensureConnected(21);
          expect(source.callIds, [19, nextCall]);

          source.replies.last.complete(
            RtcLiveKitJoinInfoEntity.fromJson({'enabled': false}),
          );
          await nextFailure;
          expect(service.isConnecting, false);
          expect(service.isConnected, false);
          expect(service.connectedCallId, isNull);
          expect(service.failureMessage, isNotNull);
        },
      );
    }
  }

  test(
    'dispose during old room disconnect cannot create a new media room',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final room = _MediaRoom(_MediaParticipant())
        ..disconnectPending = Completer<void>();
      final source = _PendingRtcSource();
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: source,
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Media control test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
          useLiveKitRtc: true,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
      );
      final connection = service.ensureConnected(20);
      source.reply.complete(
        RtcLiveKitJoinInfoEntity.fromJson({
          'enabled': true,
          'url': 'ws://127.0.0.1',
          'token': 'unit-test-placeholder',
          'mode': 'voice',
        }),
      );
      await room.disconnectStarted.future;
      service.dispose();
      room.disconnectPending!.complete();
      await connection;
      expect(service.connectedCallId, isNull);
      expect(service.isConnected, false);
    },
  );

  for (final device in ['microphone', 'camera']) {
    for (final boundary in ['leave', 'dispose', 'current']) {
      test(
        '$device permission result cannot publish after $boundary boundary',
        () async {
          final permission = Completer<bool>();
          final participant = _MediaParticipant();
          final service = RtcLiveKitService.mediaControlTest(
            remoteDataSource: _DeniedRtcSource(),
            appEnv: const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'Media control test',
              apiBaseUrl: 'http://127.0.0.1',
              useMockData: false,
            ),
            room: _MediaRoom(participant),
            microphonePermission: () => permission.future,
            cameraPermission: () => permission.future,
          );
          final operation = device == 'microphone'
              ? service.setMicrophoneEnabled(true)
              : service.setCameraEnabled(true);
          expect(participant.microphonePublications, 0);
          expect(participant.cameraPublications, 0);
          if (boundary == 'leave') await service.leave();
          if (boundary == 'dispose') service.dispose();
          permission.complete(true);
          await operation;
          expect(
            participant.microphonePublications,
            boundary == 'current' && device == 'microphone' ? 1 : 0,
          );
          expect(
            participant.cameraPublications,
            boundary == 'current' && device == 'camera' ? 1 : 0,
          );
          if (boundary != 'dispose') service.dispose();
        },
      );
    }
  }

  test('disabled RTC does not request join credentials', () async {
    final source = _DeniedRtcSource();
    final service = _service(source, enabled: false);
    await service.ensureConnected(1);
    expect(source.requests, 0);
    expect(service.isConnected, false);
    service.dispose();
  });

  test('authorization failure never creates a media connection', () async {
    final source = _DeniedRtcSource();
    final service = _service(source);
    await expectLater(service.ensureConnected(1), throwsStateError);
    expect(source.requests, 1);
    expect(service.isConnected, false);
    expect(service.connectedCallId, isNull);
    expect(service.localVideoTrack, isNull);
    expect(service.remoteVideoTrack, isNull);
    expect(service.failureMessage, isNotNull);
    service.dispose();
  });

  test(
    'unavailable join information fails closed before device capture',
    () async {
      final service = _service(_DeniedRtcSource(unavailable: true));
      await expectLater(service.ensureConnected(1), throwsStateError);
      expect(service.isConnected, false);
      expect(service.cameraEnabled, false);
      expect(service.remoteAudioTrack, isNull);
      service.dispose();
    },
  );
  test(
    'leaving during credential request prevents late device capture',
    () async {
      final source = _PendingRtcSource();
      final service = _service(source);
      final connection = service.ensureConnected(19);
      await service.leave(callId: 19);
      source.reply.complete(
        RtcLiveKitJoinInfoEntity.fromJson({
          'enabled': true,
          'url': 'ws://127.0.0.1',
          'token': 'unit-test-placeholder',
          'mode': 'video',
        }),
      );
      await connection;
      expect(service.isConnected, false);
      expect(service.connectedCallId, isNull);
      expect(service.cameraEnabled, false);
      service.dispose();
    },
  );
}
