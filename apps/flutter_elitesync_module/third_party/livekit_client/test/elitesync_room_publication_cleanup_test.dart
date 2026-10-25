import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_client/src/core/engine.dart';
import 'package:livekit_client/src/internal/events.dart';
import 'package:livekit_client/src/proto/livekit_models.pb.dart' as models;
import 'package:livekit_client/src/proto/livekit_rtc.pb.dart' as protocol;

class _Stream extends Fake implements rtc.MediaStream {}

class _MediaTrack extends Fake implements rtc.MediaStreamTrack {
  @override
  String get id => 'publication-pcm-track';
}

class _CleanupEngine extends Engine {
  _CleanupEngine()
      : super(
          connectOptions: const ConnectOptions(),
          roomOptions: const RoomOptions(),
        );

  final cleanupEntered = Completer<void>();
  final cleanupGate = Completer<void>();
  int disposalRequests = 0;
  bool _insideDisposal = false;

  @override
  Future<void> cleanUp() async {
    if (!_insideDisposal) {
      if (!cleanupEntered.isCompleted) cleanupEntered.complete();
      await cleanupGate.future;
    }
    await super.cleanUp();
  }

  @override
  Future<bool> dispose() async {
    disposalRequests++;
    _insideDisposal = true;
    try {
      return await super.dispose();
    } finally {
      _insideDisposal = false;
    }
  }

  void release() {
    if (!cleanupGate.isCompleted) cleanupGate.complete();
  }

  Future<void> finishFixture() async {
    release();
    _insideDisposal = true;
    try {
      await super.dispose();
      await signalClient.dispose();
    } finally {
      _insideDisposal = false;
    }
  }
}

const _deadline = Duration(seconds: 2);

Future<Object?> _outcome(Future<dynamic> operation) async {
  try {
    await operation.timeout(_deadline);
    return null;
  } catch (error) {
    return error;
  }
}

Matcher get _pcmStopFailure => isA<PlatformException>().having(
      (error) => error.code,
      'code',
      'PCM_STOP_FAILURE',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Room propagates inactive published track PCM stop failure and finishes cleanup',
      () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const native = MethodChannel('livekit_client');
    final starts = <String>[];
    final stops = <String>[];
    final listeners = <String>{};
    final engine = _CleanupEngine();
    final room = Room(engine: engine);
    RemoteAudioTrack? fixtureTrack;
    RemoteTrackPublication<RemoteAudioTrack>? fixturePublication;
    RemoteParticipant? fixtureParticipant;

    addTearDown(() async {
      engine.release();
      try {
        await _outcome(room.dispose());
        final track = fixtureTrack;
        Object? trackFailure;
        if (track != null) {
          trackFailure = await _outcome(track.dispose());
        }
        await fixturePublication?.dispose().timeout(_deadline);
        await fixtureParticipant?.dispose().timeout(_deadline);
        await engine.finishFixture().timeout(_deadline);
        await room.events.dispose().timeout(_deadline);
        if (track != null) expect(trackFailure, _pcmStopFailure);
      } finally {
        messenger.setMockMethodCallHandler(native, null);
        for (final id in starts) {
          messenger.setMockMethodCallHandler(
            MethodChannel('io.livekit.audio.renderer/channel-$id'),
            null,
          );
        }
      }
    });

    messenger.setMockMethodCallHandler(native, (call) async {
      if (call.method == 'stopAndroidAudioSession') return null;
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final id = args['rendererId'] as String;
      switch (call.method) {
        case 'startAudioRenderer':
          starts.add(id);
          messenger.setMockMethodCallHandler(
            MethodChannel('io.livekit.audio.renderer/channel-$id'),
            (event) async {
              if (event.method == 'listen') {
                listeners.add(id);
              } else if (event.method == 'cancel') {
                listeners.remove(id);
              } else {
                throw StateError('Unexpected EventChannel method: ${event.method}');
              }
              return null;
            },
          );
          return true;
        case 'stopAudioRenderer':
          stops.add(id);
          throw PlatformException(code: 'PCM_STOP_FAILURE');
        default:
          throw StateError('Unexpected native method: ${call.method}');
      }
    });

    // Exercise Room's real join listener to populate its private collection.
    // This test belongs to the livekit_client package, where these named
    // internal SDK events are legal; no runtime fixture API or dynamic bypass.
    final joined = room.events.waitFor<RoomConnectedEvent>(duration: _deadline);
    engine.events.emit(EngineJoinResponseEvent(
      response: protocol.JoinResponse(
        room: models.Room(sid: 'RM_cleanup', name: 'cleanup'),
        participant: models.ParticipantInfo(sid: 'PA_local', identity: 'local'),
        otherParticipants: [
          models.ParticipantInfo(sid: 'PA_remote', identity: 'remote'),
        ],
      ),
    ));
    await joined;
    final registeredParticipant = room.remoteParticipants['remote'];
    expect(registeredParticipant, isA<RemoteParticipant>());
    final participant = registeredParticipant!;
    fixtureParticipant = participant;
    final track = RemoteAudioTrack(TrackSource.microphone, _Stream(), _MediaTrack());
    fixtureTrack = track;
    final publication = RemoteTrackPublication<RemoteAudioTrack>(
      participant: participant,
      info: models.TrackInfo(
        sid: 'TR_pcm',
        type: models.TrackType.AUDIO,
        source: models.TrackSource.MICROPHONE,
      ),
      track: track,
    );
    fixturePublication = publication;
    participant.addTrackPublication(publication);
    track.addAudioRenderer(onFrame: (_) {});
    await Future<void>.delayed(Duration.zero);
    // Fixture assertions precede the disposal regression under test.
    expect(participant.trackPublications['TR_pcm'], same(publication));
    expect(publication.track, same(track));
    expect(track.isActive, isFalse);
    expect(starts, hasLength(1));
    expect(listeners, contains(starts.single));

    var roomCompleted = false;
    final disposing = _outcome(room.dispose()).then((error) {
      roomCompleted = true;
      return error;
    });
    await engine.cleanupEntered.future.timeout(_deadline);
    expect(roomCompleted, isFalse);
    engine.release();
    final failure = await disposing;
    expect(failure, _pcmStopFailure,
        reason: 'Room must observe the error hidden by publication disposal');
    expect(engine.disposalRequests, 1);
    expect(track.events.isDisposed, isTrue);
    expect(publication.isDisposed, isTrue);
    expect(stops, [starts.single]);
    expect(listeners, isEmpty);
  });
}
