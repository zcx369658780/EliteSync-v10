import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

class _Stream extends Fake implements rtc.MediaStream {}

class _Track extends Fake implements rtc.MediaStreamTrack {
  @override
  String get id => 'pcm-failure-track';
}

const _deadline = Duration(seconds: 2);
const _nativeChannel = MethodChannel('livekit_client');
const _codec = StandardMethodCodec();

Matcher get _stopFailure => isA<PlatformException>().having(
  (error) => error.code,
  'code',
  'PCM_STOP_FAILURE',
);

Future<Object?> _outcome(Future<dynamic> operation) async {
  try {
    await operation.timeout(_deadline);
    return null;
  } catch (error) {
    return error;
  }
}

Future<void> _drain() => Future<void>.delayed(Duration.zero);

// Only transport replies are simulated. The RemoteAudioTrack, capture groups,
// AudioFrameCaptureNative, EventChannel and disposal algorithm remain real.
class _NativeReplies {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  bool startSucceeds = true;
  bool stopFails = false;
  final starts = <String>[];
  final stops = <String>[];
  final listens = <String>[];
  final activeListeners = <String>{};
  final firstStop = Completer<void>();
  Completer<void>? stopGate;

  String eventName(String id) => 'io.livekit.audio.renderer/channel-$id';

  void install() {
    messenger.setMockMethodCallHandler(_nativeChannel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final id = args['rendererId'] as String;
      switch (call.method) {
        case 'startAudioRenderer':
          starts.add(id);
          messenger.setMockMethodCallHandler(MethodChannel(eventName(id)), (
            event,
          ) async {
            switch (event.method) {
              case 'listen':
                listens.add(id);
                activeListeners.add(id);
                break;
              case 'cancel':
                activeListeners.remove(id);
                break;
              default:
                throw StateError('Unexpected event method: ${event.method}');
            }
            return null;
          });
          return startSucceeds;
        case 'stopAudioRenderer':
          stops.add(id);
          if (!firstStop.isCompleted) firstStop.complete();
          if (stopGate != null) await stopGate!.future;
          if (stopFails) {
            throw PlatformException(
              code: 'PCM_STOP_FAILURE',
              message: 'Injected native stop failure',
            );
          }
          return null;
        default:
          throw StateError('Unexpected native method: ${call.method}');
      }
    });
  }

  Future<void> emitFrame(String id) async {
    final delivered = Completer<void>();
    messenger.handlePlatformMessage(
      eventName(id),
      _codec.encodeSuccessEnvelope({
        'commonFormat': 'int16',
        'sampleRate': 24000,
        'channels': 1,
        'data': Uint8List.fromList([1, 0]),
      }),
      (_) => delivered.complete(),
    );
    await delivered.future.timeout(_deadline);
    await _drain();
  }

  void release() {
    if (stopGate != null && !stopGate!.isCompleted) stopGate!.complete();
  }

  void uninstall() {
    messenger.setMockMethodCallHandler(_nativeChannel, null);
    for (final id in starts) {
      messenger.setMockMethodCallHandler(MethodChannel(eventName(id)), null);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _NativeReplies native;
  late RemoteAudioTrack track;
  late bool expectDisposalFailure;

  setUp(() {
    native = _NativeReplies()..install();
    track = RemoteAudioTrack(TrackSource.microphone, _Stream(), _Track());
    expectDisposalFailure = false;
  });

  tearDown(() async {
    native.release();
    try {
      final error = await _outcome(track.dispose());
      if (expectDisposalFailure) {
        expect(
          error,
          _stopFailure,
          reason: 'Negative-case cleanup must retain the expected stop error',
        );
      } else {
        expect(error, isNull);
      }
      expect(track.events.isDisposed, isTrue);
      expect(native.activeListeners, isEmpty);
    } finally {
      native.uninstall();
    }
  });

  test(
    'failed native start creates no subscription or frames and no fake stop',
    () async {
      native.startSucceeds = false;
      var frames = 0;
      track.addAudioRenderer(onFrame: (_) => frames++);
      await _drain();
      expect(native.starts, hasLength(1));
      expect(native.listens, isEmpty);
      await native.emitFrame(native.starts.single);
      expect(frames, 0);
      expect(await _outcome(track.dispose()), isNull);
      expect(native.stops, isEmpty);
      expect(native.listens, isEmpty);
      expect(track.events.isDisposed, isTrue);
    },
  );

  for (final operation in ['cancel', 'stopCapture']) {
    test(
      '$operation failure remains visible to later dispose after group removal',
      () async {
        native.stopFails = true;
        expectDisposalFailure = true;
        final cancel = track.addAudioRenderer(onFrame: (_) {});
        await _drain();
        expect(native.listens, [native.starts.single]);
        final stopError = await _outcome(
          operation == 'cancel' ? cancel() : track.stopCapture(),
        );
        // Drain completion callbacks so dispose cannot pass merely by observing
        // the previous stop future before its in-flight entry has been cleared.
        await _drain();
        final disposeError = await _outcome(track.dispose());
        final repeatError = await _outcome(track.dispose());
        expect(stopError, _stopFailure);
        expect(disposeError, same(stopError));
        expect(repeatError, same(disposeError));
        expect(native.stops, [native.starts.single]);
        expect(native.activeListeners, isEmpty);
        expect(track.events.isDisposed, isTrue);
      },
    );
  }

  test(
    'concurrent and completed dispose calls retain the same native stop error',
    () async {
      native.stopFails = true;
      expectDisposalFailure = true;
      native.stopGate = Completer<void>();
      track.addAudioRenderer(onFrame: (_) {});
      await _drain();
      var firstCompleted = false;
      var secondCompleted = false;
      final first = _outcome(track.dispose()).then((error) {
        firstCompleted = true;
        return error;
      });
      await native.firstStop.future.timeout(_deadline);
      final second = _outcome(track.dispose()).then((error) {
        secondCompleted = true;
        return error;
      });
      await _drain();
      expect(firstCompleted, isFalse);
      expect(secondCompleted, isFalse);
      native.release();
      final errors = await Future.wait([first, second]);
      final afterCompletion = await _outcome(track.dispose());
      expect(errors.first, _stopFailure);
      expect(errors.last, same(errors.first));
      expect(afterCompletion, same(errors.first));
      expect(native.stops, [native.starts.single]);
      expect(native.activeListeners, isEmpty);
      expect(track.events.isDisposed, isTrue);
    },
  );
}
