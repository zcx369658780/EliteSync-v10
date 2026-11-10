import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

typedef PrivateVideoControllerFactory =
    VideoPlayerController Function(Uri uri, Map<String, String> headers);

/// Private assets are addressed by server ID, never by a supplied public URL.
class PrivateVideoPlayer extends ConsumerStatefulWidget {
  const PrivateVideoPlayer({
    super.key,
    required this.assetId,
    this.controllerFactory,
  });

  final int assetId;
  final PrivateVideoControllerFactory? controllerFactory;

  @override
  ConsumerState<PrivateVideoPlayer> createState() => _PrivateVideoPlayerState();
}

class _PrivateVideoPlayerState extends ConsumerState<PrivateVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _player;
  SessionState? _session;
  Timer? _timer;
  final _cancel = CancelToken();
  bool _blocked = false;
  bool _checking = false;

  bool get _current =>
      mounted &&
      !_blocked &&
      _session != null &&
      identical(ref.read(sessionProvider).asData?.value, _session) &&
      _session!.isLoggedIn;
  String get _path => '/api/v1/media/${widget.assetId}/content';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_initialize);
  }

  Future<void> _authorize() async {
    if (!_current) throw StateError('Session unavailable');
    final response = await ref
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
        response.statusCode != 206 ||
        (response.data?.isEmpty ?? true)) {
      throw StateError('Private video unavailable');
    }
  }

  Future<void> _initialize() async {
    try {
      _session = ref.read(sessionProvider).asData?.value;
      final token = _session?.accessToken;
      if (widget.assetId <= 0 || !_current || token == null || token.isEmpty) {
        throw StateError('Session unavailable');
      }
      await _authorize();
      if (!_current) return;
      final uri = Uri.parse(
        ref.read(dioProvider).options.baseUrl,
      ).resolve(_path);
      if (!['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        throw StateError('Private video origin unavailable');
      }
      final headers = {'Authorization': 'Bearer $token'};
      final player =
          widget.controllerFactory?.call(uri, headers) ??
          VideoPlayerController.networkUrl(uri, httpHeaders: headers);
      _player = player;
      player.addListener(_playerChanged);
      await player.initialize().timeout(const Duration(seconds: 15));
      if (!_current) {
        await _invalidate();
        return;
      }
      await player.setLooping(false);
      // Revalidate before first playback and repeatedly while native buffers exist.
      await _authorize();
      if (!_current) return;
      setState(() {});
      _timer = Timer.periodic(const Duration(seconds: 2), (_) => _revalidate());
    } catch (_) {
      await _invalidate();
    }
  }

  void _playerChanged() {
    if (_player?.value.hasError ?? false) {
      unawaited(_invalidate());
      return;
    }
    if (mounted && !_blocked) setState(() {});
  }

  Future<void> _revalidate() async {
    if (_checking || _blocked) return;
    _checking = true;
    try {
      await _authorize();
    } catch (_) {
      await _invalidate();
    } finally {
      _checking = false;
    }
  }

  Future<void> _toggle() async {
    try {
      await _authorize();
      final player = _player;
      if (!_current || player == null) return;
      if (player.value.isPlaying) {
        await player.pause();
      } else {
        await player.play();
      }
    } catch (_) {
      await _invalidate();
    }
  }

  Future<void> _invalidate() async {
    if (_blocked) return;
    _blocked = true;
    _timer?.cancel();
    _cancel.cancel('Private video authorization ended');
    final player = _player;
    _player = null;
    if (mounted) setState(() {});
    if (player != null) {
      player.removeListener(_playerChanged);
      try {
        await player.pause();
      } catch (_) {}
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_invalidate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _cancel.cancel('Private video closed');
    final player = _player;
    _player = null;
    if (player != null) {
      player.removeListener(_playerChanged);
      unawaited(player.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (_, next) {
      if (_session != null && !identical(next.asData?.value, _session)) {
        unawaited(_invalidate());
      }
    });
    if (_blocked) return const Text('视频不可用，请检查当前登录与消息权限。');
    final player = _player;
    if (player == null || !player.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.45,
          child: Center(
            child: AspectRatio(
              aspectRatio: player.value.aspectRatio > 0
                  ? player.value.aspectRatio
                  : 16 / 9,
              child: VideoPlayer(player),
            ),
          ),
        ),
        IconButton(
          onPressed: _toggle,
          tooltip: player.value.isPlaying ? '暂停视频' : '播放视频',
          icon: Icon(player.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ],
    );
  }
}
