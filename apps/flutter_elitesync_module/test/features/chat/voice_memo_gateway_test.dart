import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/voice_memo_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('elitesync/voice_memo');
  const gateway = VoiceMemoGateway(channel: channel);
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Map<String, Object?> status({
    bool recording = false,
    String? previewPath,
    int durationMs = 0,
    String playbackState = 'idle',
  }) => {
    'recording': recording,
    'previewPath': previewPath,
    'durationMs': durationMs,
    'sizeBytes': previewPath == null ? 0 : 12500,
    'recordingElapsedMs': recording ? 1250 : 0,
    'playbackState': playbackState,
    'positionMs': 500,
    'playbackDurationMs': durationMs,
    'errorCode': null,
  };

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'start' => status(recording: true),
        'stop' => status(
          previewPath: '/private/fixture/voice-memo.m4a',
          durationMs: 2100,
        ),
        'play' || 'resumePlayback' => status(playbackState: 'playing'),
        'pausePlayback' => status(playbackState: 'paused'),
        _ => status(),
      };
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'recording stops into a preview without upload or automatic send',
    () async {
      final recording = await gateway.start();
      expect(recording.recording, isTrue);
      expect(recording.hasPreview, isFalse);
      expect(recording.recordingElapsedMs, 1250);
      final preview = await gateway.stop();
      expect(preview.recording, isFalse);
      expect(preview.hasPreview, isTrue);
      expect(preview.previewPath, '/private/fixture/voice-memo.m4a');
      expect(preview.durationMs, 2100);
      expect(preview.sizeBytes, 12500);
      await gateway.status();
      expect(calls.map((call) => call.method), ['start', 'stop', 'status']);
      expect(calls.every((call) => call.arguments == null), isTrue);
    },
  );

  test('preview playback sends only its private file locator', () async {
    final playing = await gateway.playPreview(
      '/private/fixture/voice-memo.m4a',
    );
    expect(playing.playing, isTrue);
    expect(calls.single.method, 'play');
    expect(calls.single.arguments, {
      'source': '/private/fixture/voice-memo.m4a',
    });
  });

  test(
    'content playback passes the current URI and explicit authorization',
    () async {
      final uri = Uri.parse('http://127.0.0.1:8021/api/v1/media/42/content');
      await gateway.playContent(
        uri,
        authorization: 'Bearer fixture-only-token',
      );
      expect(calls.single.method, 'play');
      expect(calls.single.arguments, {
        'source': uri.toString(),
        'headers': {'Authorization': 'Bearer fixture-only-token'},
      });
    },
  );

  test(
    'pause, resume, stop, discard and release remain explicit commands',
    () async {
      expect((await gateway.pausePlayback()).playbackState, 'paused');
      expect((await gateway.resumePlayback()).playing, isTrue);
      await gateway.stopPlayback();
      expect((await gateway.discard()).hasPreview, isFalse);
      await gateway.release();
      expect(calls.map((call) => call.method), [
        'pausePlayback',
        'resumePlayback',
        'stopPlayback',
        'discard',
        'release',
      ]);
    },
  );

  test(
    'native permission rejection is propagated without a fake recording',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        throw PlatformException(code: 'microphone_denied');
      });
      await expectLater(
        gateway.start(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'microphone_denied',
          ),
        ),
      );
      expect(calls.map((call) => call.method), ['start']);
    },
  );

  test(
    'a missing native status cannot become a successful operation',
    () async {
      messenger.setMockMethodCallHandler(channel, (_) async => null);
      await expectLater(gateway.start(), throwsStateError);
    },
  );
}
