import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/audio/communication_audio_focus.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/voice_memo_gateway.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class PrivateAudioPlayer extends ConsumerStatefulWidget {
  const PrivateAudioPlayer({super.key, required this.assetId});
  final int assetId;
  @override
  ConsumerState<PrivateAudioPlayer> createState() => _PrivateAudioPlayerState();
}

class _PrivateAudioPlayerState extends ConsumerState<PrivateAudioPlayer>
    with WidgetsBindingObserver {
  final _gateway = const VoiceMemoGateway();
  final _owner = Object();
  final _cancel = CancelToken();
  SessionState? _session;
  VoiceMemoStatus? _status;
  Timer? _timer;
  bool _blocked = false;
  bool _attached = false;
  Future<void>? _releaseFuture;
  bool _busy = false;
  int _ticks = 0;
  bool get _current =>
      mounted &&
      !_blocked &&
      _session?.isLoggedIn == true &&
      identical(ref.read(sessionProvider).asData?.value, _session);
  String get _path => '/api/v1/media/${widget.assetId}/content';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = ref.read(sessionProvider).asData?.value;
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  Future<void> _authorize() async {
    if (!_current) {
      throw StateError('Session unavailable');
    }
    final result = await ref
        .read(dioProvider)
        .get<List<int>>(
          _path,
          cancelToken: _cancel,
          options: Options(
            headers: {'Range': 'bytes=0-0'},
            responseType: ResponseType.bytes,
            sendTimeout: const Duration(seconds: 2),
            receiveTimeout: const Duration(seconds: 2),
            extra: {requestSessionGuardKey: () => _current},
          ),
        )
        .timeout(const Duration(seconds: 3));
    if (!_current ||
        result.statusCode != 206 ||
        (result.data?.isEmpty ?? true)) {
      throw StateError('Audio unavailable');
    }
  }

  Future<void> _stop() {
    if (_releaseFuture != null) return _releaseFuture!;
    _blocked = true;
    _timer?.cancel();
    _cancel.cancel();
    final attached = _attached;
    _attached = false;
    if (mounted) setState(() {});
    if (!attached) return Future<void>.value();
    return _releaseFuture = _gateway.release().then<void>((_) {}).whenComplete(
      () {
        CommunicationAudioFocus.releaseVoice(_owner);
      },
    );
  }

  Future<void> _tick() async {
    if (!_current || _busy || !CommunicationAudioFocus.ownsVoice(_owner)) {
      return;
    }
    _busy = true;
    try {
      if (++_ticks % 8 == 0) await _authorize();
      final status = await _gateway.status();
      if (status.errorCode != null) {
        throw StateError('Playback failed');
      }
      if (_current) setState(() => _status = status);
    } catch (_) {
      await _stop();
    } finally {
      _busy = false;
    }
  }

  Future<void> _play() async {
    if (!_current || _busy) return;
    _busy = true;
    try {
      _attached = await CommunicationAudioFocus.claimVoice(_owner, _stop);
      if (!_attached) throw StateError('RTC active');
      if (!_current) {
        CommunicationAudioFocus.releaseVoice(_owner);
        _attached = false;
        return;
      }
      await _authorize();
      if (!_current || !CommunicationAudioFocus.ownsVoice(_owner)) return;
      VoiceMemoStatus status;
      if (_status?.playing == true) {
        status = await _gateway.pausePlayback();
      } else if (_status?.playbackState == 'paused') {
        status = await _gateway.resumePlayback();
      } else {
        final uri = Uri.parse(
          ref.read(dioProvider).options.baseUrl,
        ).resolve(_path);
        status = await _gateway.playContent(
          uri,
          authorization: 'Bearer ${_session!.accessToken}',
        );
      }
      if (_current) setState(() => _status = status);
    } catch (_) {
      await _stop();
    } finally {
      _busy = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (_, next) {
      if (!identical(next.asData?.value, _session)) unawaited(_stop());
    });
    if (_blocked) return const Text('语音已停止，请检查当前权限或通话状态后重新打开。');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${((_status?.positionMs ?? 0) / 1000).toStringAsFixed(1)} / ${((_status?.playbackDurationMs ?? 0) / 1000).toStringAsFixed(1)} 秒',
        ),
        TextButton.icon(
          onPressed: _busy ? null : _play,
          icon: Icon(_status?.playing == true ? Icons.pause : Icons.play_arrow),
          label: Text(
            _status?.playing == true
                ? '暂停'
                : (_status?.playbackState == 'completed' ? '重播' : '播放'),
          ),
        ),
      ],
    );
  }
}
