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
  int implicitMicrophoneEnables = 0;
  int implicitCameraEnables = 0;
  final removedTrackSids = <String>[];
  Completer<LocalTrackPublication?>? pendingMicrophoneEnable;
  final microphoneEnableStarted = Completer<void>();
  _CaptureTrack? microphoneTrack;
  bool microphoneAlreadyPublished = true;
  int cameraPublications = 0;
  bool cameraAlreadyPublished = true;
  bool failVideoPublish = false;
  Completer<LocalTrackPublication<LocalVideoTrack>>? pendingVideoPublish;
  final videoPublishStarted = Completer<void>();
  @override
  final Map<String, LocalTrackPublication> trackPublications = {};
  @override
  List<LocalTrackPublication<LocalVideoTrack>> get videoTrackPublications =>
      trackPublications.values
          .whereType<LocalTrackPublication<LocalVideoTrack>>()
          .toList();
  @override
  LocalTrackPublication? getTrackPublicationBySource(TrackSource source) {
    final key = source == TrackSource.camera ? 'camera' : 'microphone';
    if (trackPublications.containsKey(key)) return trackPublications[key];
    if ((source == TrackSource.camera && cameraAlreadyPublished) ||
        (source == TrackSource.microphone && microphoneAlreadyPublished)) {
      return _CapturePublication(_CaptureTrack());
    }
    return null;
  }

  @override
  Future<void> removePublishedTrack(
    String trackSid, {
    bool notify = true,
  }) async {
    removedTrackSids.add(trackSid);
    final keys = trackPublications.entries
        .where((entry) => entry.value.sid == trackSid)
        .map((entry) => entry.key)
        .toList();
    for (final key in keys) {
      trackPublications.remove(key);
      if (key == 'camera') cameraAlreadyPublished = false;
      if (key == 'microphone') microphoneAlreadyPublished = false;
    }
  }

  @override
  Future<LocalTrackPublication<LocalAudioTrack>> publishAudioTrack(
    LocalAudioTrack track, {
    AudioPublishOptions? publishOptions,
  }) async {
    microphonePublications++;
    if (!microphoneEnableStarted.isCompleted) {
      microphoneEnableStarted.complete();
    }
    final publication = pendingMicrophoneEnable == null
        ? _CapturePublication<LocalAudioTrack>(track)
        : await pendingMicrophoneEnable!.future
              as LocalTrackPublication<LocalAudioTrack>;
    microphoneAlreadyPublished = true;
    trackPublications['microphone'] = publication;
    return publication;
  }

  @override
  Future<LocalTrackPublication<LocalVideoTrack>> publishVideoTrack(
    LocalVideoTrack track, {
    VideoPublishOptions? publishOptions,
  }) async {
    cameraPublications++;
    if (!videoPublishStarted.isCompleted) videoPublishStarted.complete();
    if (failVideoPublish) throw StateError('Synthetic video publish failure');
    final publication = pendingVideoPublish == null
        ? _CapturePublication<LocalVideoTrack>(track)
        : await pendingVideoPublish!.future;
    cameraAlreadyPublished = true;
    trackPublications['camera'] = publication;
    return publication;
  }

  @override
  Future<LocalTrackPublication?> setMicrophoneEnabled(
    bool enabled, {
    AudioCaptureOptions? audioCaptureOptions,
  }) async {
    if (enabled) {
      implicitMicrophoneEnables++;
      microphonePublications++;
      microphoneTrack?.nativeActive = true;
      microphoneTrack?.muted = false;
      if (!microphoneEnableStarted.isCompleted) {
        microphoneEnableStarted.complete();
      }
      if (microphonePublications == 1 && pendingMicrophoneEnable != null) {
        return pendingMicrophoneEnable!.future;
      }
      if (microphoneTrack != null) return _CapturePublication(microphoneTrack!);
    }
    return null;
  }

  @override
  Future<LocalTrackPublication?> setCameraEnabled(
    bool enabled, {
    CameraCaptureOptions? cameraCaptureOptions,
  }) async {
    if (enabled) {
      implicitCameraEnables++;
      cameraPublications++;
      final publication = trackPublications['camera'];
      final track = publication?.track;
      if (track is _CaptureTrack) {
        track.nativeActive = true;
        track.muted = false;
      }
      return publication;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CaptureTrack implements LocalTrack {
  int stops = 0;
  bool failStop = false;
  bool nativeActive = true;
  @override
  bool get isActive => nativeActive;
  @override
  bool muted = false;
  @override
  Future<bool> mute({bool stopOnMute = true}) async {
    muted = true;
    return true;
  }

  @override
  Future<bool> stop() async {
    stops++;
    nativeActive = false;
    if (failStop) throw StateError('Synthetic native stop failure');
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CapturePublication<T extends LocalTrack>
    implements LocalTrackPublication<T> {
  _CapturePublication(this.track) : sid = 'fixture-${identityHashCode(track)}';
  @override
  final String sid;
  @override
  final T track;
  @override
  bool get muted => track.muted;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _VideoCaptureTrack extends _CaptureTrack implements LocalVideoTrack {
  VideoCaptureOptions _options = const CameraCaptureOptions();
  @override
  VideoCaptureOptions get currentOptions => _options;
  @override
  set currentOptions(VideoCaptureOptions value) => _options = value;
}

class _AudioCaptureTrack extends _CaptureTrack implements LocalAudioTrack {}

class _MediaRoom implements Room {
  _MediaRoom(this.localParticipant, {this.roomOptions = const RoomOptions()});
  Completer<void>? disconnectPending;
  bool failDisconnect = false;
  int disposeCalls = 0;
  final disconnectStarted = Completer<void>();
  @override
  final LocalParticipant localParticipant;
  @override
  final RoomOptions roomOptions;
  @override
  void removeListener(VoidCallback listener) {}
  @override
  Future<void> disconnect() async {
    if (!disconnectStarted.isCompleted) disconnectStarted.complete();
    if (failDisconnect) throw StateError('Synthetic disconnect failure');
    await disconnectPending?.future;
  }

  @override
  Future<bool> dispose() async {
    disposeCalls++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final device in ['microphone', 'camera']) {
    test(
      'restoring muted $device replaces the track without implicit restart',
      () async {
        final previous = device == 'microphone'
            ? _AudioCaptureTrack()
            : _VideoCaptureTrack();
        previous.muted = true;
        previous.nativeActive = false;
        final participant = _MediaParticipant()
          ..trackPublications[device] = _CapturePublication(previous);
        var creations = 0;
        final service = RtcLiveKitService.mediaControlTest(
          remoteDataSource: _DeniedRtcSource(),
          appEnv: const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'Owned track restore test',
            apiBaseUrl: 'http://127.0.0.1',
            useMockData: false,
          ),
          room: _MediaRoom(participant),
          microphonePermission: () async => true,
          cameraPermission: () async => true,
          audioTrackFactory: (_) async {
            creations++;
            return _AudioCaptureTrack();
          },
          cameraTrackFactory: (_) async {
            creations++;
            return _VideoCaptureTrack();
          },
        );
        if (device == 'microphone') {
          await service.setMicrophoneEnabled(true);
        } else {
          await service.setCameraEnabled(true);
        }
        expect(creations, 1);
        expect(participant.implicitMicrophoneEnables, 0);
        expect(participant.implicitCameraEnables, 0);
        expect(participant.removedTrackSids, hasLength(1));
        expect(previous.nativeActive, isFalse);
        await service.leave();
        service.dispose();
      },
    );
  }

  test(
    'new microphone enable waits for suspended old publication cleanup',
    () async {
      final track = _AudioCaptureTrack();
      final participant = _MediaParticipant()
        ..microphoneTrack = track
        ..microphoneAlreadyPublished = false
        ..pendingMicrophoneEnable = Completer();
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _DeniedRtcSource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Microphone operation ownership test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
        ),
        room: _MediaRoom(participant),
        microphonePermission: () async => true,
        cameraPermission: () async => true,
        audioTrackFactory: (_) async {
          track.nativeActive = true;
          track.muted = false;
          return track;
        },
      );
      final oldEnable = service.setMicrophoneEnabled(true);
      await participant.microphoneEnableStarted.future;
      await service.suspendCapture();
      expect(track.nativeActive, isFalse);
      expect(participant.microphonePublications, 1);
      final newEnable = service.setMicrophoneEnabled(true);
      await Future<void>.delayed(Duration.zero);
      participant.pendingMicrophoneEnable!.complete(
        _CapturePublication<LocalAudioTrack>(track),
      );
      await oldEnable;
      await newEnable;
      expect(participant.microphonePublications, 2);
      expect(track.nativeActive, isTrue);
      expect(track.muted, isFalse);
      expect(service.microphoneEnabled, isTrue);
      await service.leave();
      service.dispose();
    },
  );

  test(
    'background stops both capture tracks without disconnecting the call',
    () async {
      final microphone = _CaptureTrack()..failStop = true;
      final camera = _CaptureTrack();
      final participant = _MediaParticipant()
        ..trackPublications.addAll({
          'microphone': _CapturePublication(microphone),
          'camera': _CapturePublication(camera),
        });
      final room = _MediaRoom(participant);
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _DeniedRtcSource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Background capture test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
      );
      await service.suspendCapture();
      expect([microphone.stops, camera.stops], [1, 1]);
      expect(room.disconnectStarted.isCompleted, isFalse);
      expect(room.disposeCalls, 0);
      expect(service.microphoneEnabled, isFalse);
      expect(service.cameraEnabled, isFalse);
      await service.leave();
      service.dispose();
    },
  );

  test(
    'new camera uses its capture position as the next switch baseline',
    () async {
      final participant = _MediaParticipant()..cameraAlreadyPublished = false;
      final track = _VideoCaptureTrack();
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _DeniedRtcSource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Camera position baseline test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
        ),
        room: _MediaRoom(
          participant,
          roomOptions: const RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
              cameraPosition: CameraPosition.back,
            ),
          ),
        ),
        microphonePermission: () async => true,
        cameraPermission: () async => true,
        cameraTrackFactory: (options) async {
          track.currentOptions = options;
          track.nativeActive = true;
          track.muted = false;
          return track;
        },
      );
      await service.setCameraEnabled(true);
      await service.switchCamera();
      expect(
        (track.currentOptions as CameraCaptureOptions).cameraPosition,
        CameraPosition.front,
      );
      await service.leave();
      service.dispose();
    },
  );

  for (final boundary in ['leave', 'suspend']) {
    test(
      'camera switch finishing after $boundary stops restarted capture',
      () async {
        final participant = _MediaParticipant()..cameraAlreadyPublished = false;
        final firstTrack = _VideoCaptureTrack();
        final replacementTrack = _VideoCaptureTrack();
        final restoredTrack = _VideoCaptureTrack();
        final replacement = Completer<LocalVideoTrack>();
        final replacementStarted = Completer<void>();
        var creations = 0;
        final service = RtcLiveKitService.mediaControlTest(
          remoteDataSource: _DeniedRtcSource(),
          appEnv: const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'Camera switch ownership test',
            apiBaseUrl: 'http://127.0.0.1',
            useMockData: false,
          ),
          room: _MediaRoom(participant),
          microphonePermission: () async => true,
          cameraPermission: () async => true,
          cameraTrackFactory: (options) {
            creations++;
            if (creations == 2) {
              replacementStarted.complete();
              return replacement.future;
            }
            final track = creations == 1 ? firstTrack : restoredTrack;
            track.currentOptions = options;
            return Future.value(track);
          },
        );
        await service.setCameraEnabled(true);
        final switching = service.switchCamera();
        await replacementStarted.future;
        if (boundary == 'suspend') {
          await service.suspendCapture();
        } else {
          await service.leave();
        }
        replacement.complete(replacementTrack);
        await switching;
        expect(firstTrack.nativeActive, isFalse);
        expect(replacementTrack.stops, greaterThan(0));
        expect(replacementTrack.nativeActive, isFalse);
        expect(service.cameraEnabled, isFalse);
        if (boundary == 'suspend') {
          expect(replacementTrack.muted, isTrue);
          await service.setCameraEnabled(true);
          expect(service.cameraEnabled, isTrue);
          expect(restoredTrack.nativeActive, isTrue);
          expect(restoredTrack.muted, isFalse);
        }
        await service.leave();
        service.dispose();
      },
    );
  }

  for (final boundary in [
    'creation',
    'publication',
    'suspend creation',
    'suspend publication',
    'publish failure',
    'current',
  ]) {
    test('camera track ownership survives $boundary boundary', () async {
      final duringCreation = boundary.endsWith('creation');
      final duringPublication = boundary.endsWith('publication');
      final suspend = boundary.startsWith('suspend ');
      final participant = _MediaParticipant()..cameraAlreadyPublished = false;
      if (boundary == 'publish failure') participant.failVideoPublish = true;
      if (duringPublication) {
        participant.pendingVideoPublish = Completer();
      }
      final room = _MediaRoom(participant);
      final track = _VideoCaptureTrack();
      final creation = Completer<LocalVideoTrack>();
      final creationStarted = Completer<void>();
      var creations = 0;
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _DeniedRtcSource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Pending capture test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
        ),
        room: room,
        microphonePermission: () async => true,
        cameraPermission: () async => true,
        cameraTrackFactory: (_) {
          creations++;
          if (!creationStarted.isCompleted) creationStarted.complete();
          return creation.future.then((track) {
            (track as _VideoCaptureTrack).nativeActive = true;
            track.muted = false;
            return track;
          });
        },
      );
      final enable = service.setCameraEnabled(true);
      final expectedFailure = boundary == 'publish failure'
          ? expectLater(enable, throwsStateError)
          : null;
      await creationStarted.future;
      if (duringCreation) {
        if (suspend) {
          await service.suspendCapture();
        } else {
          await service.leave();
        }
      }
      creation.complete(track);
      if (duringPublication) {
        await participant.videoPublishStarted.future;
        if (suspend) {
          await service.suspendCapture();
        } else {
          await service.leave();
        }
        expect(track.stops, greaterThanOrEqualTo(1));
        participant.pendingVideoPublish!.complete(
          _CapturePublication<LocalVideoTrack>(track),
        );
      }
      if (expectedFailure != null) {
        await expectedFailure;
      } else {
        await enable;
      }
      expect(creations, 1);
      if (boundary == 'current') {
        expect(service.cameraEnabled, isTrue);
        expect(track.stops, 0);
        await service.setCameraEnabled(true);
        expect(creations, 1);
      } else {
        expect(service.cameraEnabled, isFalse);
        expect(track.stops, greaterThanOrEqualTo(1));
        expect(participant.cameraPublications, duringCreation ? 0 : 1);
        expect(track.muted, isTrue);
        if (suspend) expect(room.disconnectStarted.isCompleted, isFalse);
      }
      if (suspend) {
        await service.setCameraEnabled(true);
        expect(service.cameraEnabled, isTrue);
        expect(track.nativeActive, isTrue);
        expect(track.muted, isFalse);
      }
      await service.leave();
      service.dispose();
    });
  }

  test('reconnect leave waits for previous native teardown', () async {
    final room = _MediaRoom(_MediaParticipant())
      ..disconnectPending = Completer<void>();
    final service = RtcLiveKitService.mediaControlTest(
      remoteDataSource: _DeniedRtcSource(),
      appEnv: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'Teardown serialization test',
        apiBaseUrl: 'http://127.0.0.1',
        useMockData: false,
      ),
      room: room,
      microphonePermission: () async => true,
      cameraPermission: () async => true,
    );
    final first = service.leave();
    await room.disconnectStarted.future;
    var secondFinished = false;
    final second = service.leave().then((_) => secondFinished = true);
    await Future<void>.delayed(Duration.zero);
    final finishedBeforeDisconnect = secondFinished;
    room.disconnectPending!.complete();
    await first;
    await second;
    expect(finishedBeforeDisconnect, isFalse);
    expect(room.disposeCalls, 1);
    service.dispose();
  });

  test('local capture stops before a pending signaling disconnect', () async {
    final microphone = _CaptureTrack()..failStop = true;
    final camera = _CaptureTrack();
    final participant = _MediaParticipant()
      ..trackPublications.addAll({
        'microphone': _CapturePublication(microphone),
        'camera': _CapturePublication(camera),
      });
    final room = _MediaRoom(participant)..disconnectPending = Completer<void>();
    final service = RtcLiveKitService.mediaControlTest(
      remoteDataSource: _DeniedRtcSource(),
      appEnv: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'Capture stop test',
        apiBaseUrl: 'http://127.0.0.1',
        useMockData: false,
      ),
      room: room,
      microphonePermission: () async => true,
      cameraPermission: () async => true,
    );
    final leaving = service.leave();
    await room.disconnectStarted.future;
    // A failed microphone stop must still attempt the camera before signaling.
    final stopCounts = [microphone.stops, camera.stops];
    room.disconnectPending!.complete();
    await leaving;
    expect(stopCounts, [1, 1]);
    expect(room.disposeCalls, 1);
    service.dispose();
  });

  test('disconnect failure still disposes media resources', () async {
    final room = _MediaRoom(_MediaParticipant())..failDisconnect = true;
    final service = RtcLiveKitService.mediaControlTest(
      remoteDataSource: _DeniedRtcSource(),
      appEnv: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'Media cleanup test',
        apiBaseUrl: 'http://127.0.0.1',
        useMockData: false,
      ),
      room: room,
      microphonePermission: () async => true,
      cameraPermission: () async => true,
    );
    await service.leave();
    expect(room.disposeCalls, 1);
    expect(service.microphoneEnabled, isFalse);
    service.dispose();
  });

  test(
    'late microphone grant after leave cannot request camera permission',
    () async {
      final source = _PendingRtcSource();
      final microphone = Completer<bool>();
      final permissionStarted = Completer<void>();
      var cameraRequests = 0;
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: source,
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Media permission test',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
          useLiveKitRtc: true,
        ),
        room: _MediaRoom(_MediaParticipant()),
        microphonePermission: () {
          permissionStarted.complete();
          return microphone.future;
        },
        cameraPermission: () async {
          cameraRequests++;
          return true;
        },
      );
      final connection = service.ensureConnected(105);
      source.reply.complete(
        RtcLiveKitJoinInfoEntity.fromJson({
          'enabled': true,
          'url': 'ws://127.0.0.1',
          'token': 'unit-test-placeholder',
          'mode': 'video',
        }),
      );
      await permissionStarted.future;
      await service.leave(callId: 105);
      microphone.complete(true);
      await connection;
      expect(cameraRequests, 0);
      expect(service.isConnected, isFalse);
      service.dispose();
    },
  );

  for (final gateway in [
    'ws://untrusted.example.com:7880',
    'ws://localhost:7880',
    'wss://user:synthetic-secret@sfu.example.com',
    'wss://@sfu.example.com',
    'wss://sfu.example.com?token=synthetic-secret',
  ]) {
    test(
      'invalid RTC gateway fails before permissions or new room: $gateway',
      () async {
        var permissionCalls = 0;
        final logs = <String>[];
        final originalDebugPrint = debugPrint;
        debugPrint = (message, {wrapWidth}) {
          if (message != null) logs.add(message);
        };
        addTearDown(() => debugPrint = originalDebugPrint);
        final source = _PendingRtcSource();
        final room = _MediaRoom(_MediaParticipant());
        final service = RtcLiveKitService.mediaControlTest(
          remoteDataSource: source,
          appEnv: const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'RTC gateway rejection test',
            apiBaseUrl: 'http://127.0.0.1:8021',
            useMockData: false,
            useLiveKitRtc: true,
          ),
          room: room,
          microphonePermission: () async {
            permissionCalls++;
            return true;
          },
          cameraPermission: () async {
            permissionCalls++;
            return true;
          },
        );
        final connection = service.ensureConnected(21);
        source.reply.complete(
          RtcLiveKitJoinInfoEntity.fromJson({
            'enabled': true,
            'url': gateway,
            'token': 'synthetic-secret-join-token',
            'mode': 'video',
          }),
        );
        await expectLater(connection, throwsFormatException);
        expect(permissionCalls, 0);
        expect(service.isConnecting, isFalse);
        expect(service.isConnected, isFalse);
        expect(service.connectedCallId, isNull);
        expect(service.failureMessage, isNotNull);
        expect(logs.join('\n'), isNot(contains('AUDIO_ROUTE_PRECONNECT')));
        expect(logs.join('\n'), isNot(contains('ROOM_CONNECT_START')));
        expect(logs.join('\n'), isNot(contains(gateway)));
        expect(logs.join('\n'), isNot(contains('synthetic-secret')));
        service.dispose();
      },
    );
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
    for (final boundary in ['leave', 'dispose', 'suspend', 'current']) {
      test(
        '$device permission result cannot publish after $boundary boundary',
        () async {
          final permission = Completer<bool>();
          final permissionStarted = Completer<void>();
          Future<bool> requestPermission() {
            permissionStarted.complete();
            return permission.future;
          }

          final participant = _MediaParticipant()
            ..microphoneAlreadyPublished = false
            ..cameraAlreadyPublished = false;
          final service = RtcLiveKitService.mediaControlTest(
            remoteDataSource: _DeniedRtcSource(),
            appEnv: const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'Media control test',
              apiBaseUrl: 'http://127.0.0.1',
              useMockData: false,
            ),
            room: _MediaRoom(participant),
            microphonePermission: requestPermission,
            cameraPermission: requestPermission,
            audioTrackFactory: (_) async => _AudioCaptureTrack(),
            cameraTrackFactory: (_) async => _VideoCaptureTrack(),
          );
          final operation = device == 'microphone'
              ? service.setMicrophoneEnabled(true)
              : service.setCameraEnabled(true);
          await permissionStarted.future;
          expect(participant.microphonePublications, 0);
          expect(participant.cameraPublications, 0);
          if (boundary == 'leave') await service.leave();
          if (boundary == 'suspend') await service.suspendCapture();
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
