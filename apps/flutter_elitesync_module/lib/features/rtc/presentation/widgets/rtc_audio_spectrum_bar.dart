import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:livekit_client/livekit_client.dart';

// Legacy pure tone helper retained for unit tests; the widget never captures PCM.
@visibleForTesting
({int zeroCrossings, double tone440, double tone880}) rtcAudioToneDiagnostics(
  List<int> samples,
  int sampleRate,
) {
  if (samples.length < 2 || sampleRate <= 0) {
    return (zeroCrossings: 0, tone440: 0, tone880: 0);
  }
  final mean =
      samples.fold<double>(0, (sum, sample) => sum + sample) / samples.length;
  var energy = 0.0;
  var crossings = 0;
  var previous = samples.first - mean;
  for (final sample in samples) {
    final centered = sample - mean;
    energy += centered * centered;
    if ((previous < 0 && centered >= 0) || (previous >= 0 && centered < 0)) {
      crossings += 1;
    }
    previous = centered;
  }
  double toneFraction(double hz) {
    if (energy == 0 || hz >= sampleRate / 2) return 0;
    final coefficient = 2 * math.cos(2 * math.pi * hz / sampleRate);
    var previous = 0.0;
    var beforePrevious = 0.0;
    for (final sample in samples) {
      final current = sample - mean + coefficient * previous - beforePrevious;
      beforePrevious = previous;
      previous = current;
    }
    final power =
        previous * previous +
        beforePrevious * beforePrevious -
        coefficient * previous * beforePrevious;
    return (2 * power / (samples.length * energy)).clamp(0.0, 1.0);
  }

  return (
    zeroCrossings: crossings,
    tone440: toneFraction(440),
    tone880: toneFraction(880),
  );
}

typedef RtcAudioVisualizerFactory = AudioVisualizer Function(AudioTrack track);

class RtcAudioSpectrumBar extends StatefulWidget {
  const RtcAudioSpectrumBar({
    super.key,
    required this.audioTrack,
    this.visualizerFactory,
  });

  final AudioTrack? audioTrack;
  @visibleForTesting
  final RtcAudioVisualizerFactory? visualizerFactory;

  @override
  State<RtcAudioSpectrumBar> createState() => _RtcAudioSpectrumBarState();
}

class _RtcAudioSpectrumBarState extends State<RtcAudioSpectrumBar> {
  static const int _barCount = 7;
  static const double _decay = 0.82;
  static const double _silentThreshold = 0.001;

  AudioVisualizer? _visualizer;
  EventsListener<AudioVisualizerEvent>? _listener;
  Future<void> _bindingWork = Future.value();
  int _generation = 0;
  List<double> _levels = List<double>.filled(_barCount, 0.0);
  String _status = '等待远端音轨…';
  bool _receivedLevels = false;

  @override
  void initState() {
    super.initState();
    _scheduleBinding(widget.audioTrack);
  }

  @override
  void didUpdateWidget(covariant RtcAudioSpectrumBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A replacement track can reuse the same native ID after reconnection.
    if (!identical(oldWidget.audioTrack, widget.audioTrack) ||
        oldWidget.visualizerFactory != widget.visualizerFactory) {
      _scheduleBinding(widget.audioTrack);
    }
  }

  @override
  void dispose() {
    _generation++;
    // Native start is asynchronous. Finish it before stop/dispose so a late
    // completion cannot create an orphaned event channel after widget disposal.
    _bindingWork = _bindingWork.then((_) => _clearBinding());
    unawaited(_bindingWork);
    super.dispose();
  }

  void _scheduleBinding(AudioTrack? track) {
    final generation = ++_generation;
    _levels = List<double>.filled(_barCount, 0.0);
    _receivedLevels = false;
    _status = track == null ? '等待远端音轨…' : '正在读取远端音频活动…';
    _bindingWork = _bindingWork.then((_) => _bindTrack(track, generation));
    unawaited(_bindingWork);
  }

  bool _current(AudioTrack track, int generation) =>
      mounted &&
      generation == _generation &&
      identical(widget.audioTrack, track);

  Future<void> _bindTrack(AudioTrack? track, int generation) async {
    await _clearBinding();
    if (track == null || !_current(track, generation)) return;
    AudioVisualizer? visualizer;
    EventsListener<AudioVisualizerEvent>? listener;
    try {
      visualizer =
          widget.visualizerFactory?.call(track) ??
          createVisualizer(
            track,
            options: const AudioVisualizerOptions(barCount: _barCount),
          );
      listener = visualizer.createListener();
      listener.on<AudioVisualizerEvent>((event) {
        if (_current(track, generation) && identical(event.track, track)) {
          _onLevels(event.event);
        }
      });
      await visualizer.start();
      if (!_current(track, generation)) {
        await _disposeVisualizer(visualizer, listener);
        return;
      }
      _visualizer = visualizer;
      _listener = listener;
      if (!_receivedLevels) setState(() => _status = '远端音频活动监听中');
    } catch (error) {
      if (visualizer != null) await _disposeVisualizer(visualizer, listener);
      debugPrint(
        'RTC_AUDIO_VISUALIZER_START_FAILED errorType=${error.runtimeType}',
      );
      if (_current(track, generation)) {
        setState(() {
          _levels = List<double>.filled(_barCount, 0.0);
          _status = '音频可视化暂不可用';
        });
      }
    }
  }

  Future<void> _clearBinding() async {
    final visualizer = _visualizer;
    final listener = _listener;
    _visualizer = null;
    _listener = null;
    if (visualizer != null) await _disposeVisualizer(visualizer, listener);
  }

  Future<void> _disposeVisualizer(
    AudioVisualizer visualizer,
    EventsListener<AudioVisualizerEvent>? listener,
  ) async {
    try {
      await listener?.dispose();
    } catch (error) {
      debugPrint(
        'RTC_AUDIO_VISUALIZER_LISTENER_CLEANUP_FAILED errorType=${error.runtimeType}',
      );
    }
    try {
      await visualizer.stop();
    } catch (error) {
      debugPrint(
        'RTC_AUDIO_VISUALIZER_STOP_FAILED errorType=${error.runtimeType}',
      );
    }
    try {
      await visualizer.dispose();
    } catch (error) {
      debugPrint(
        'RTC_AUDIO_VISUALIZER_DISPOSE_FAILED errorType=${error.runtimeType}',
      );
    }
  }

  void _onLevels(List<Object?> bands) {
    final levels = List<double>.generate(_barCount, (index) {
      final value = index < bands.length ? bands[index] : null;
      return value is num && value.isFinite
          ? value.toDouble().clamp(0.0, 1.0)
          : 0.0;
    });
    setState(() {
      _receivedLevels = true;
      _status = levels.any((level) => level > _silentThreshold)
          ? '远端音频活动中'
          : '当前远端音频活动较低';
      _levels = List<double>.generate(
        _barCount,
        (index) => math.max(levels[index], _levels[index] * _decay),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final hasTrack = widget.audioTrack != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(t.spacing.md),
          decoration: BoxDecoration(
            color: t.secondarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.browseBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasTrack ? Icons.graphic_eq : Icons.graphic_eq_outlined,
                    color: hasTrack ? t.brandPrimary : t.textTertiary,
                    size: 20,
                  ),
                  SizedBox(width: t.spacing.xs),
                  Expanded(
                    child: Text(
                      _status,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.sm),
              SizedBox(
                height: 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_barCount, (index) {
                    return AnimatedContainer(
                      key: ValueKey('rtc-audio-band-$index'),
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      width: 12,
                      height: 6.0 + _levels[index].clamp(0.0, 1.0) * 34.0,
                      decoration: BoxDecoration(
                        color: hasTrack
                            ? t.brandPrimary.withValues(alpha: 0.85)
                            : t.textTertiary.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.xs),
        Text(
          hasTrack ? '波形仅表示音轨活动，不能证明实际播放或回声消除效果。' : '等待对方接入后显示音频活动。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.35),
        ),
      ],
    );
  }
}
