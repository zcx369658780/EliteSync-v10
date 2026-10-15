import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart';

void main() {
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

    await tester.pumpAndSettle();

    expect(find.text('等待远端音轨…'), findsOneWidget);
    expect(find.byType(RtcAudioSpectrumBar), findsOneWidget);
  });
}
