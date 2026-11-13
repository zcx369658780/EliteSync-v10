import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_elitesync_module/core/audio/communication_audio_focus.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/voice_memo_gateway.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class VoiceMemoPanel extends ConsumerStatefulWidget {
  const VoiceMemoPanel({super.key, required this.peerId, required this.onSend});

  final int peerId;

  /// The caller owns the immutable message attempt. Only confirmed persistence
  /// returns true. A false result keeps this same uploaded asset for retry.
  final Future<bool> Function(int assetId) onSend;

  @override
  ConsumerState<VoiceMemoPanel> createState() => _VoiceMemoPanelState();
}

class _VoiceMemoPanelState extends ConsumerState<VoiceMemoPanel>
    with WidgetsBindingObserver {
  final _voice = const VoiceMemoGateway();
  final _cancel = CancelToken();
  final _focusOwner = Object();
  SessionState? _session;
  VoiceMemoStatus? _status;
  Timer? _timer;
  bool _attached = false;
  bool _blocked = false;
  bool _disposing = false;
  Future<void>? _releaseFuture;
  bool _busy = true;
  bool _polling = false;
  bool _foreground = true;
  bool _permissionPrompt = false;
  bool _submissionAttempted = false;
  int _pollCount = 0;
  int? _assetId;
  String _message = '正在核验当前消息权限…';

  bool get _current =>
      mounted &&
      !_disposing &&
      !_blocked &&
      _foreground &&
      _session?.isLoggedIn == true &&
      identical(ref.read(sessionProvider).asData?.value, _session) &&
      CommunicationAudioFocus.ownsVoice(_focusOwner);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_initialize);
  }

  Future<void> _initialize() async {
    if (!mounted || _blocked) return;
    _session = ref.read(sessionProvider).asData?.value;
    try {
      _attached = await CommunicationAudioFocus.claimVoice(
        _focusOwner,
        () => _invalidate('通话已占用音频，语音留言已停止。'),
      );
      if (!mounted || _blocked) {
        CommunicationAudioFocus.releaseVoice(_focusOwner);
        _attached = false;
        return;
      }
      if (!_attached || !_current) {
        await _invalidate('当前无法录制，请先结束通话并确认登录。');
        return;
      }
      await _authorize();
      if (!_current) return;
      setState(() {
        _busy = false;
        _message = '可录制1–60秒语音，停止后试听并确认发送。';
      });
      _timer = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => _poll(),
      );
    } catch (_) {
      await _invalidate('当前无法录制，请检查登录与双方消息同意。');
    }
  }

  Future<void> _authorize() async {
    if (!_current) throw StateError('Voice context unavailable');
    final response = await ref
        .read(apiClientProvider)
        .get(
          '/api/v1/connections/${widget.peerId}',
          cancelToken: _cancel,
          options: Options(
            sendTimeout: const Duration(seconds: 2),
            receiveTimeout: const Duration(seconds: 2),
            extra: {requestSessionGuardKey: () => _current},
          ),
        )
        .timeout(const Duration(seconds: 3));
    if (!_current || response is! NetworkSuccess<Map<String, dynamic>>) {
      throw StateError('Voice authorization unavailable');
    }
    final gates = response.data['gates'];
    if ((response.data['peer_id'] as num?)?.toInt() != widget.peerId ||
        gates is! Map ||
        gates['live_read_allowed'] != true ||
        gates['live_send_allowed'] != true) {
      throw StateError('Voice authorization unavailable');
    }
  }

  Future<void> _poll() async {
    if (_polling || _busy || !_current) return;
    _polling = true;
    try {
      if (++_pollCount % 8 == 0) await _authorize();
      if (!_current) return;
      final status = await _voice.status();
      if (!_current) return;
      setState(() {
        final wasRecording = _status?.recording == true;
        _status = status;
        if (status.errorCode != null) {
          _message = status.errorCode == 'recording_too_short'
              ? '录制至少需要1秒，请重新录制。'
              : '录制或播放未完成，请重试。';
        } else if (wasRecording && !status.recording && status.hasPreview) {
          _message = '录制已停止，请试听并确认发送。';
        }
      });
    } catch (_) {
      await _invalidate('权限或连接已失效，语音留言已停止。');
    } finally {
      _polling = false;
    }
  }

  Future<void> _record() async {
    if (_busy || !_current || _submissionAttempted) return;
    setState(() => _busy = true);
    try {
      _permissionPrompt = true;
      final granted = await Permission.microphone.request();
      _permissionPrompt = false;
      if (!_foreground && !_blocked) {
        await WidgetsBinding.instance.endOfFrame;
      }
      if (!_current) return;
      if (!granted.isGranted) {
        setState(() => _message = '麦克风权限未允许，尚未录制或发送。');
        return;
      }
      await _authorize();
      if (!_current) return;
      final status = await _voice.start();
      if (!_current) return;
      setState(() {
        _status = status;
        _assetId = null;
        _message = '正在录制，达到60秒会停止至预览。';
      });
    } catch (_) {
      if (_current) setState(() => _message = '录制未能开始，请检查麦克风并重试。');
    } finally {
      _permissionPrompt = false;
      if (_current) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    if (_busy || !_current) return;
    setState(() => _busy = true);
    try {
      final status = await _voice.stop();
      if (!_current) return;
      setState(() {
        _status = status;
        _message = status.hasPreview ? '录制已停止，请试听并确认发送。' : '录制至少需要1秒，请重新录制。';
      });
    } catch (_) {
      await _invalidate('录制未能停止，已释放语音资源。');
    } finally {
      if (_current) setState(() => _busy = false);
    }
  }

  Future<void> _play() async {
    if (_busy || !_current || _status?.hasPreview != true) return;
    setState(() => _busy = true);
    try {
      await _authorize();
      if (!_current) return;
      final before = _status!;
      final next = before.playing
          ? await _voice.pausePlayback()
          : before.playbackState == 'paused'
          ? await _voice.resumePlayback()
          : await _voice.playPreview(before.previewPath!);
      if (_current) setState(() => _status = next);
    } catch (_) {
      await _invalidate('试听权限或资源已失效，请重新进入录制。');
    } finally {
      if (_current) setState(() => _busy = false);
    }
  }

  Future<void> _discard() async {
    if (_busy || !_current || _submissionAttempted) return;
    setState(() => _busy = true);
    try {
      final next = await _voice.discard();
      if (!_current) return;
      setState(() {
        _status = next;
        _assetId = null;
        _message = '本次语音已删除，可以重新录制。';
      });
    } finally {
      if (_current) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    if (_busy || !_current || _status?.hasPreview != true) return;
    setState(() => _busy = true);
    try {
      await _authorize();
      if (!_current) return;
      await _voice.stopPlayback();
      if (!_current) return;
      if (_assetId == null) {
        setState(() => _message = '正在上传语音，尚未发送消息…');
        final form = FormData.fromMap({
          'media_type': 'audio',
          'mime_type': 'audio/mp4',
          'original_name': 'voice-memo.m4a',
          'file': await MultipartFile.fromFile(
            _status!.previewPath!,
            filename: 'voice-memo.m4a',
          ),
        });
        if (!_current) return;
        final response = await ref
            .read(apiClientProvider)
            .post(
              '/api/v1/media',
              body: form,
              cancelToken: _cancel,
              options: Options(extra: {requestSessionGuardKey: () => _current}),
            );
        if (!_current) return;
        final asset = response is NetworkSuccess<Map<String, dynamic>>
            ? response.data['asset']
            : null;
        if (asset is! Map ||
            asset['status'] != 'ready' ||
            asset['media_type'] != 'audio' ||
            ((asset['id'] as num?)?.toInt() ?? 0) <= 0) {
          throw StateError('Voice upload unavailable');
        }
        _assetId = (asset['id'] as num).toInt();
      }
      setState(() {
        _submissionAttempted = true;
        _message = '语音已上传，正在等待消息提交确认…';
      });
      final confirmed = await widget.onSend(_assetId!);
      if (!_current) return;
      if (confirmed) {
        await _invalidate('语音消息已保存。');
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() => _message = '消息尚未确认，语音已保留，请按原编号重试发送。');
      }
    } catch (_) {
      if (_current) {
        setState(
          () => _message = _assetId == null
              ? '上传或处理未完成，录制已保留，请重试。'
              : '消息尚未确认，已上传语音保留，请重试发送。',
        );
      }
    } finally {
      if (_current) setState(() => _busy = false);
    }
  }

  Future<void> _invalidate(String message) {
    final pending = _releaseFuture;
    if (pending != null) return pending;
    _blocked = true;
    _timer?.cancel();
    _cancel.cancel('Voice context ended');
    final attached = _attached;
    _attached = false;
    if (mounted && !_disposing) setState(() => _message = message);
    return _releaseFuture = attached
        ? _voice.release().then<void>((_) {}).whenComplete(() {
            CommunicationAudioFocus.releaseVoice(_focusOwner);
          })
        : Future<void>.value();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground ||
        (_permissionPrompt && state == AppLifecycleState.inactive)) {
      return;
    }
    unawaited(_invalidate('离开前台后语音已停止，请重新进入录制。'));
  }

  @override
  void dispose() {
    _disposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_invalidate('语音留言已关闭。'));
    super.dispose();
  }

  String _seconds(int milliseconds) =>
      '${(milliseconds / 1000).toStringAsFixed(1)}秒';

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (_, next) {
      if (_session != null && !identical(next.asData?.value, _session)) {
        unawaited(_invalidate('登录已变化，语音留言已停止。'));
      }
    });
    ref.listen(relationshipAuthorityEpochProvider, (_, next) {
      unawaited(_invalidate('消息权限已变化，请重新进入录制。'));
    });
    final recording = _status?.recording == true;
    final preview = _status?.hasPreview == true;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('语音留言', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(_message),
            if (recording) Text(_seconds(_status!.recordingElapsedMs)),
            if (preview) Text('时长 ${_seconds(_status!.durationMs)}'),
            if (preview && (_status?.playbackDurationMs ?? 0) > 0)
              Text(
                '${_seconds(_status!.positionMs)} / ${_seconds(_status!.playbackDurationMs)}',
              ),
            const SizedBox(height: 12),
            if (!_blocked && !preview)
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : recording
                    ? _stop
                    : _record,
                icon: Icon(recording ? Icons.stop : Icons.mic),
                label: Text(recording ? '停止录制' : '开始录制'),
              ),
            if (!_blocked && preview) ...[
              OutlinedButton.icon(
                onPressed: _busy ? null : _play,
                icon: Icon(_status!.playing ? Icons.pause : Icons.play_arrow),
                label: Text(_status!.playing ? '暂停试听' : '试听语音'),
              ),
              TextButton(
                onPressed: _busy || _submissionAttempted ? null : _discard,
                child: const Text('删除并重新录制'),
              ),
              FilledButton(
                onPressed: _busy ? null : _send,
                child: Text(_submissionAttempted ? '重试发送语音' : '确认发送语音'),
              ),
            ],
            TextButton(
              onPressed: () async {
                await _invalidate('语音留言已关闭。');
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
}
