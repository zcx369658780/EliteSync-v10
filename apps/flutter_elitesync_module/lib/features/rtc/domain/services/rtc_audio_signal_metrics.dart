import 'dart:math' as math;

// Only aggregate one PCM block; never retain samples or treat this as playback proof.
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
