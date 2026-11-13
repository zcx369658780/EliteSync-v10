import 'package:flutter/services.dart';

class VoiceMemoStatus {
  const VoiceMemoStatus({
    required this.recording,
    required this.previewPath,
    required this.durationMs,
    required this.sizeBytes,
    required this.recordingElapsedMs,
    required this.playbackState,
    required this.positionMs,
    required this.playbackDurationMs,
    required this.errorCode,
  });

  factory VoiceMemoStatus.fromMap(Map<Object?, Object?> value) =>
      VoiceMemoStatus(
        recording: value['recording'] == true,
        previewPath: value['previewPath'] as String?,
        durationMs: (value['durationMs'] as num?)?.toInt() ?? 0,
        sizeBytes: (value['sizeBytes'] as num?)?.toInt() ?? 0,
        recordingElapsedMs: (value['recordingElapsedMs'] as num?)?.toInt() ?? 0,
        playbackState: value['playbackState'] as String? ?? 'idle',
        positionMs: (value['positionMs'] as num?)?.toInt() ?? 0,
        playbackDurationMs: (value['playbackDurationMs'] as num?)?.toInt() ?? 0,
        errorCode: value['errorCode'] as String?,
      );

  final bool recording;
  final String? previewPath;
  final int durationMs;
  final int sizeBytes;
  final int recordingElapsedMs;
  final String playbackState;
  final int positionMs;
  final int playbackDurationMs;
  final String? errorCode;

  bool get hasPreview => previewPath != null && durationMs >= 1000;
  bool get playing => playbackState == 'playing';
}

/// Android owns the private temporary file and enforces one recorder/player.
/// Callers revalidate business permissions before starting or resuming playback.
class VoiceMemoGateway {
  const VoiceMemoGateway({
    MethodChannel channel = const MethodChannel('elitesync/voice_memo'),
  }) : _channel = channel;

  final MethodChannel _channel;

  Future<VoiceMemoStatus> _invoke(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    final value = await _channel.invokeMapMethod<Object?, Object?>(
      method,
      arguments,
    );
    if (value == null) throw StateError('Missing voice memo status');
    return VoiceMemoStatus.fromMap(value);
  }

  Future<VoiceMemoStatus> start() => _invoke('start');
  Future<VoiceMemoStatus> stop() => _invoke('stop');
  Future<VoiceMemoStatus> status() => _invoke('status');
  Future<VoiceMemoStatus> discard() => _invoke('discard');
  Future<VoiceMemoStatus> playPreview(String path) =>
      _invoke('play', {'source': path});
  Future<VoiceMemoStatus> playContent(
    Uri uri, {
    required String authorization,
  }) => _invoke('play', {
    'source': uri.toString(),
    'headers': {'Authorization': authorization},
  });
  Future<VoiceMemoStatus> pausePlayback() => _invoke('pausePlayback');

  /// Resumes a paused player. Replay after completion uses playPreview/playContent
  /// with a freshly authorized source because Android releases the completed player.
  Future<VoiceMemoStatus> resumePlayback() => _invoke('resumePlayback');
  Future<VoiceMemoStatus> stopPlayback() => _invoke('stopPlayback');
  Future<VoiceMemoStatus> release() => _invoke('release');
}
