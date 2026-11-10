import 'dart:async';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart';

class _MediaTrack implements rtc.MediaStreamTrack {
  _MediaTrack(this.id);
  @override
  final String id;
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected native track access');
}

class _Track implements AudioTrack {
  _Track(String id) : mediaStreamTrack = _MediaTrack(id);
  @override
  final rtc.MediaStreamTrack mediaStreamTrack;
  int rawRendererCalls = 0;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #addAudioRenderer) rawRendererCalls++;
    throw StateError('The waveform must not capture raw audio');
  }
}

class _Visualizer extends AudioVisualizer {
  _Visualizer({this.startGate, this.failStart = false, this.failStop = false}) {
    onDispose(() async {
      await events.dispose();
    });
  }
  final Completer<void>? startGate;
  final bool failStart;
  final bool failStop;
  int starts = 0;
  int stops = 0;
  int disposals = 0;

  @override
  Future<void> start() async {
    starts++;
    await startGate?.future;
    if (failStart) throw StateError('fictional visualizer start failure');
  }

  @override
  Future<void> stop() async {
    stops++;
    if (failStop) throw StateError('fictional visualizer stop failure');
  }

  @override
  Future<bool> dispose() async {
    disposals++;
    return super.dispose();
  }

  void emit(AudioTrack track, List<Object?> bands) {
    events.streamCtrl.add(AudioVisualizerEvent(track: track, event: bands));
  }
}

Widget _waveform(AudioTrack? track, RtcAudioVisualizerFactory factory) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: RtcAudioSpectrumBar(
          audioTrack: track,
          visualizerFactory: factory,
        ),
      ),
    );

AnimatedContainer _band(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find.byKey(const ValueKey('rtc-audio-band-0')));

// The SDK event listener cancellation uses real-zone stream futures in tests.
Future<void> _settleBindings(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'visualizer bands update the waveform without a raw PCM renderer',
    (tester) async {
      final track = _Track('same-track');
      final visualizer = _Visualizer();
      AudioVisualizer factory(AudioTrack _) => visualizer;
      await tester.pumpWidget(_waveform(track, factory));
      await _settleBindings(tester);
      expect(visualizer.starts, 1);
      visualizer.emit(track, [1.0, 0.5, 0, 0, 0, 0, 0]);
      await _settleBindings(tester);
      expect(find.text('远端音频活动中'), findsOneWidget);
      expect(_band(tester).constraints!.maxHeight, 40);
      expect(track.rawRendererCalls, 0);
      await tester.pumpWidget(_waveform(track, factory));
      await _settleBindings(tester);
      expect(visualizer.starts, 1);
      visualizer.emit(track, [0, 0, 0, 0, 0, 0, 0]);
      await _settleBindings(tester);
      expect(find.text('当前远端音频活动较低'), findsOneWidget);
      await tester.pumpWidget(_waveform(null, factory));
      await _settleBindings(tester);
      expect(find.text('等待远端音轨…'), findsOneWidget);
      expect(_band(tester).constraints!.maxHeight, 6);
      expect(visualizer.stops, 1);
      expect(visualizer.disposals, 1);
      expect(visualizer.events.streamCtrl.hasListener, isFalse);
      await tester.pumpWidget(const SizedBox());
      expect(visualizer.disposals, 1);
    },
  );

  testWidgets(
    'replacement track with the same ID waits for stale start cleanup',
    (tester) async {
      final first = _Track('reused-native-id');
      final next = _Track('reused-native-id');
      final gate = Completer<void>();
      final firstVisualizer = _Visualizer(startGate: gate);
      final nextVisualizer = _Visualizer();
      final created = <AudioTrack>[];
      AudioVisualizer factory(AudioTrack track) {
        created.add(track);
        return identical(track, first) ? firstVisualizer : nextVisualizer;
      }

      await tester.pumpWidget(_waveform(first, factory));
      await _settleBindings(tester);
      await tester.pumpWidget(_waveform(next, factory));
      await _settleBindings(tester);
      firstVisualizer.emit(first, [1, 1, 1, 1, 1, 1, 1]);
      await _settleBindings(tester);
      expect(created, [first]);
      expect(find.text('远端音频活动中'), findsNothing);
      expect(_band(tester).constraints!.maxHeight, 6);
      gate.complete();
      await _settleBindings(tester);
      expect(created, [first, next]);
      expect(firstVisualizer.stops, 1);
      expect(firstVisualizer.disposals, 1);
      nextVisualizer.emit(next, [0.8, 0.2]);
      await _settleBindings(tester);
      expect(find.text('远端音频活动中'), findsOneWidget);
      expect(first.rawRendererCalls + next.rawRendererCalls, 0);
      await tester.pumpWidget(const SizedBox());
      await _settleBindings(tester);
      expect(nextVisualizer.stops, 1);
      expect(nextVisualizer.disposals, 1);
    },
  );

  testWidgets(
    'dispose during asynchronous start eventually releases its visualizer once',
    (tester) async {
      final track = _Track('disposed-while-starting');
      final gate = Completer<void>();
      final visualizer = _Visualizer(startGate: gate);
      await tester.pumpWidget(_waveform(track, (_) => visualizer));
      await _settleBindings(tester);
      await tester.pumpWidget(const SizedBox());
      expect(visualizer.stops, 0);
      gate.complete();
      await _settleBindings(tester);
      expect(visualizer.starts, 1);
      expect(visualizer.stops, 1);
      expect(visualizer.disposals, 1);
      expect(visualizer.events.streamCtrl.hasListener, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed start still disposes even when stop also fails', (
    tester,
  ) async {
    final track = _Track('failed-visualizer');
    final visualizer = _Visualizer(failStart: true, failStop: true);
    await tester.pumpWidget(_waveform(track, (_) => visualizer));
    await _settleBindings(tester);
    await _settleBindings(tester);
    expect(find.text('音频可视化暂不可用'), findsOneWidget);
    expect(visualizer.starts, 1);
    expect(visualizer.stops, 1);
    expect(visualizer.disposals, 1);
    expect(visualizer.events.streamCtrl.hasListener, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(visualizer.disposals, 1);
    expect(tester.takeException(), isNull);
  });
  test('PCM diagnostics distinguish synthetic 440 and 880 Hz blocks', () {
    for (final frequency in [440, 880]) {
      const sampleRate = 24000;
      final samples = List<int>.generate(
        2400,
        (index) =>
            (12000 * math.sin(2 * math.pi * frequency * index / sampleRate))
                .round(),
      );
      final result = rtcAudioToneDiagnostics(samples, sampleRate);
      final expected = frequency == 440 ? result.tone440 : result.tone880;
      final other = frequency == 440 ? result.tone880 : result.tone440;
      expect(expected, greaterThan(0.99));
      expect(other, lessThan(0.001));
      expect(result.zeroCrossings, closeTo(frequency * 0.2, 2));
    }
  });

  test('PCM diagnostics report no tone for silence or a DC-only block', () {
    for (final value in [0, 12000]) {
      final result = rtcAudioToneDiagnostics(
        List<int>.filled(240, value),
        24000,
      );
      expect(result, (zeroCrossings: 0, tone440: 0.0, tone880: 0.0));
    }
    expect(rtcAudioToneDiagnostics([], 24000).tone440, 0);
  });

  testWidgets('RtcAudioSpectrumBar shows waiting state without track', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const Scaffold(body: RtcAudioSpectrumBar(audioTrack: null)),
      ),
    );

    await _settleBindings(tester);

    expect(find.text('等待远端音轨…'), findsOneWidget);
    expect(find.byType(RtcAudioSpectrumBar), findsOneWidget);
  });
}
