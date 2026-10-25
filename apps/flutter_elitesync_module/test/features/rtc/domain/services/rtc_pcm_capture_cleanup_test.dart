import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

class _Stream extends Fake implements rtc.MediaStream {}

class _Track extends Fake implements rtc.MediaStreamTrack {
  @override
  String get id => 'pcm-cleanup-track';
}

// Only the native transport is replaced. Capture grouping, subscriptions,
// cancellation closures and stopCapture all execute the real SDK code.
class _NativeAudio {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  static const channel = MethodChannel('livekit_client');
  static const codec = StandardMethodCodec();
  final starts = <Map<String, dynamic>>[];
  final stops = <String>[];
  final channels = <String>{};
  final listening = <String>{};
  final firstStop = Completer<void>();
  Completer<bool>? startGate;
  Completer<void>? stopGate;
  final stopGates = <String, Completer<void>>{};

  void install() {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final id = args['rendererId'] as String;
      switch (call.method) {
        case 'startAudioRenderer':
          starts.add(args);
          final name = eventChannel(id);
          channels.add(name);
          messenger.setMockMethodCallHandler(MethodChannel(name), (event) async {
            switch (event.method) {
              case 'listen':
                listening.add(id);
                break;
              case 'cancel':
                listening.remove(id);
                break;
              default:
                throw StateError('Unexpected event method: ${event.method}');
            }
            return null;
          });
          return startGate == null ? true : await startGate!.future;
        case 'stopAudioRenderer':
          stops.add(id);
          if (!firstStop.isCompleted) firstStop.complete();
          if (stopGate != null) await stopGate!.future;
          if (stopGates[id] != null) await stopGates[id]!.future;
          return null;
        default:
          throw StateError('Unexpected native method: ${call.method}');
      }
    });
  }

  String eventChannel(String id) => 'io.livekit.audio.renderer/channel-$id';
  String idAt(int index) => starts[index]['rendererId'] as String;

  Future<void> frame(String id, {bool expectListening = true}) async {
    if (expectListening) expect(listening, contains(id));
    final format = starts.firstWhere(
      (start) => start['rendererId'] == id,
    )['format'] as Map;
    final delivered = Completer<void>();
    messenger.handlePlatformMessage(
      eventChannel(id),
      codec.encodeSuccessEnvelope({
        'commonFormat': format['commonFormat'],
        'sampleRate': format['sampleRate'],
        'channels': format['channels'],
        'data': Uint8List.fromList([1, 0, 2, 0]),
      }),
      (_) => delivered.complete(),
    );
    await delivered.future;
    await _drain();
  }

  void release() {
    if (startGate != null && !startGate!.isCompleted) startGate!.complete(true);
    if (stopGate != null && !stopGate!.isCompleted) stopGate!.complete();
    for (final gate in stopGates.values) {
      if (!gate.isCompleted) gate.complete();
    }
  }

  void uninstall() {
    messenger.setMockMethodCallHandler(channel, null);
    for (final name in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  }
}

// A zero-duration event-loop turn drains channel replies and stream microtasks;
// the races themselves are held at explicit native start/stop Completers.
Future<void> _drain() => Future<void>.delayed(Duration.zero);

// Observe errors immediately, including before a deliberately paused native
// reply is released, so regressions are assertions rather than unhandled errors.
Future<Object?> _outcome(Future<void> future) async {
  try {
    await future;
    return null;
  } catch (error) {
    return error;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _NativeAudio native;
  late RemoteAudioTrack track;

  setUp(() {
    native = _NativeAudio()..install();
    track = RemoteAudioTrack(TrackSource.microphone, _Stream(), _Track());
  });

  tearDown(() async {
    native.release();
    await _drain();
    await track.stopCapture();
    await track.dispose();
    native.uninstall();
  });

  test('last renderer cancel during stopCapture does not mutate live iteration',
      () async {
    final cancel = track.addAudioRenderer(onFrame: (_) {});
    await _drain();
    native.stopGate = Completer<void>();
    final stopping = _outcome(track.stopCapture());
    await native.firstStop.future;
    final cancelling = _outcome(cancel());
    await _drain();
    native.release();
    final results = await Future.wait([stopping, cancelling]);
    expect(results, everyElement(isNull));
    expect(native.stops, [native.idAt(0)]);
  });

  test('concurrent stopCapture requests stop each native renderer once', () async {
    track.addAudioRenderer(onFrame: (_) {});
    await _drain();
    native.stopGate = Completer<void>();
    final first = _outcome(track.stopCapture());
    await native.firstStop.future;
    var secondCompleted = false;
    final second = _outcome(track.stopCapture()).then((result) {
      secondCompleted = true;
      return result;
    });
    await _drain();
    expect(secondCompleted, isFalse,
        reason: 'A second stop must await the pending native cleanup');
    native.release();
    expect(await Future.wait([first, second]), everyElement(isNull));
    expect(secondCompleted, isTrue);
    expect(native.stops, [native.idAt(0)]);
  });

  test('stopCapture awaits a group already removed by last renderer cancel',
      () async {
    final cancel = track.addAudioRenderer(onFrame: (_) {});
    await _drain();
    native.stopGate = Completer<void>();
    final cancelling = _outcome(cancel());
    await native.firstStop.future;
    var stopCompleted = false;
    final stopping = _outcome(track.stopCapture()).then((result) {
      stopCompleted = true;
      return result;
    });
    await _drain();
    expect(stopCompleted, isFalse,
        reason: 'Removing a group must not lose its in-flight cleanup');
    native.release();
    expect(await Future.wait([cancelling, stopping]), everyElement(isNull));
    expect(stopCompleted, isTrue);
    expect(native.stops, [native.idAt(0)]);
  });

  test('stopCapture awaits both different-format groups and stops frame delivery',
      () async {
    var firstFrames = 0;
    var secondFrames = 0;
    track.addAudioRenderer(
      onFrame: (_) => firstFrames++,
      options: const AudioRendererOptions(sampleRate: 24000),
    );
    track.addAudioRenderer(
      onFrame: (_) => secondFrames++,
      options: const AudioRendererOptions(sampleRate: 48000),
    );
    await _drain();
    expect(native.starts, hasLength(2));
    final firstId = native.idAt(0);
    final secondId = native.idAt(1);
    expect(firstId, isNot(secondId));
    await native.frame(firstId);
    await native.frame(secondId);
    expect([firstFrames, secondFrames], [1, 1]);
    native.stopGates[firstId] = Completer<void>();
    native.stopGates[secondId] = Completer<void>();
    var stopCompleted = false;
    final stopping = _outcome(track.stopCapture()).then((result) {
      stopCompleted = true;
      return result;
    });
    await native.firstStop.future;
    await _drain();
    expect(native.stops, unorderedEquals([firstId, secondId]));
    expect(stopCompleted, isFalse);
    native.stopGates[firstId]!.complete();
    await _drain();
    expect(stopCompleted, isFalse,
        reason: 'The other format still has a pending native stop');
    expect(native.listening, isEmpty);
    // Inject late native packets through the real EventChannel transport after
    // subscription cancellation, rather than bypassing SDK frame dispatch.
    await native.frame(firstId, expectListening: false);
    await native.frame(secondId, expectListening: false);
    expect([firstFrames, secondFrames], [1, 1]);
    native.stopGates[secondId]!.complete();
    expect(await stopping, isNull);
    expect(stopCompleted, isTrue);
    await native.frame(firstId, expectListening: false);
    await native.frame(secondId, expectListening: false);
    expect([firstFrames, secondFrames], [1, 1]);
    expect(native.stops, unorderedEquals([firstId, secondId]));
  });

  test('concurrent repeated renderer cancellation stops native capture once',
      () async {
    final cancel = track.addAudioRenderer(onFrame: (_) {});
    await _drain();
    native.stopGate = Completer<void>();
    final first = _outcome(cancel());
    await native.firstStop.future;
    final second = _outcome(cancel());
    await _drain();
    native.release();
    expect(await Future.wait([first, second]), everyElement(isNull));
    expect(native.stops, [native.idAt(0)]);
  });

  test('late old cancel cannot detach a new same-format capture group', () async {
    final oldCancel = track.addAudioRenderer(onFrame: (_) {});
    await _drain();
    await track.stopCapture();
    var frames = 0;
    final newCancel = track.addAudioRenderer(onFrame: (_) => frames++);
    await _drain();
    expect(native.starts, hasLength(2));
    final newId = native.idAt(1);
    await oldCancel();
    await native.frame(newId);
    expect(frames, 1);
    await track.stopCapture();
    // The new group must still belong to the track and be cleaned up by it.
    final stoppedByTrack = List<String>.of(native.stops);
    await newCancel();
    expect(stoppedByTrack, [native.idAt(0), newId]);
    expect(native.stops, stoppedByTrack);
  });

  test('equal-format renderers share capture until the last renderer cancels',
      () async {
    var firstFrames = 0;
    var secondFrames = 0;
    final first = track.addAudioRenderer(
      onFrame: (_) => firstFrames++,
      options: const AudioRendererOptions(sampleRate: 24000),
    );
    final second = track.addAudioRenderer(
      onFrame: (_) => secondFrames++,
      options: const AudioRendererOptions(sampleRate: 24000),
    );
    await _drain();
    expect(native.starts, hasLength(1));
    expect(native.starts.single['trackId'], 'pcm-cleanup-track');
    expect(native.starts.single['format'], {
      'commonFormat': 'int16',
      'sampleRate': 24000,
      'channels': 1,
    });
    final id = native.idAt(0);
    await native.frame(id);
    expect([firstFrames, secondFrames], [1, 1]);
    await first();
    expect(native.stops, isEmpty);
    await native.frame(id);
    expect([firstFrames, secondFrames], [1, 2]);
    await second();
    expect(native.stops, [id]);
    expect(native.listening, isEmpty);
  });

  test('stop and last cancel while native start is pending settle once', () async {
    native.startGate = Completer<bool>();
    native.stopGate = Completer<void>();
    final cancel = track.addAudioRenderer(onFrame: (_) {});
    await _drain();
    expect(native.starts, hasLength(1));
    expect(native.listening, isEmpty);
    final stopping = _outcome(track.stopCapture());
    final cancelling = _outcome(cancel());
    await _drain();
    expect(native.stops, isEmpty);
    native.startGate!.complete(true);
    await native.firstStop.future;
    await _drain();
    native.release();
    expect(await Future.wait([stopping, cancelling]), everyElement(isNull));
    expect(native.stops, [native.idAt(0)]);
    expect(native.listening, isEmpty);
  });
}
