import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart';
import 'package:livekit_client/livekit_client.dart';

class RtcCallPage extends ConsumerStatefulWidget {
  const RtcCallPage({
    super.key,
    required this.callId,
    this.title = '通话',
    this.autoConnect = true,
  });

  final int callId;
  final String title;
  final bool autoConnect;

  @override
  ConsumerState<RtcCallPage> createState() => _RtcCallPageState();
}

class _RtcCallPageState extends ConsumerState<RtcCallPage>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _busy = false;
  int? _autoConnectedCallId;
  int? _liveKitAttemptedCallId;
  final Set<int> _closedMediaCallIds = {};
  late final RtcLiveKitService _liveKitService;
  bool _serviceBound = false;
  SessionState? _ownerSession;
  bool _sessionInvalidated = false;

  bool get _currentSession =>
      mounted &&
      !_sessionInvalidated &&
      _ownerSession?.isLoggedIn == true &&
      identical(ref.read(sessionProvider).asData?.value, _ownerSession);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref
        .read(frontendTelemetryProvider)
        .rtcCallEntryOpened(sourcePage: 'rtc_call');
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_currentSession) return;
      ref.invalidate(rtcCallProvider(widget.callId));
    });
  }

  @override
  void didUpdateWidget(covariant RtcCallPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callId != widget.callId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_leaveMediaOnce(oldWidget.callId));
      });
      _autoConnectedCallId = null;
      _liveKitAttemptedCallId = null;
      _busy = false;
    }
  }

  // Set the guard before leave can notify listeners and schedule another build.
  // Explicit reconnect starts a fresh media attempt; rebuilds never do.
  Future<void> _leaveMediaOnce(int callId) async {
    if (!_serviceBound) return;
    if (!_closedMediaCallIds.add(callId)) return;
    await _liveKitService.leave(callId: callId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_leaveMediaOnce(widget.callId));
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // No background capture; the user explicitly re-enables devices on return.
      unawaited(
        _mediaAction(() async {
          await _liveKitService.setCameraEnabled(false);
          await _liveKitService.setMicrophoneEnabled(false);
        }),
      );
    }
  }

  Future<void> _mediaAction(Future<void> Function() action) async {
    if (!_currentSession) return;
    try {
      await action();
    } catch (_) {
      if (mounted && _currentSession) {
        AppFeedback.showError(context, '媒体操作失败，请检查设备权限后重试');
      }
    }
  }

  Future<void> _refresh() async {
    if (!_currentSession) return;
    ref.invalidate(rtcCallProvider(widget.callId));
    await ref.read(rtcCallProvider(widget.callId).future);
  }

  Future<void> _withAction(
    Future<RtcSessionEntity> Function() action,
    String okMessage,
  ) async {
    if (_busy || !_currentSession) return;
    final callId = widget.callId;
    setState(() => _busy = true);
    try {
      final session = await action();
      if (!mounted || !_currentSession || widget.callId != callId) return;
      ref
          .read(frontendTelemetryProvider)
          .rtcCallStatusChanged(
            sourcePage: 'rtc_call',
            callId: session.id,
            status: session.status,
          );
      ref.invalidate(rtcCallProvider(callId));
      if (session.isTerminal) {
        unawaited(_leaveMediaOnce(session.id));
      }
      AppFeedback.showInfo(context, okMessage);
    } catch (e) {
      if (!mounted || !_currentSession || widget.callId != callId) return;
      AppFeedback.showError(context, e.toString());
    } finally {
      if (mounted && _currentSession && widget.callId == callId) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _autoConnect(RtcSessionEntity session) async {
    if (!_currentSession) return;
    if (_busy || _autoConnectedCallId == session.id) return;
    if (!session.canConnect) return;
    _autoConnectedCallId = session.id;
    await _withAction(
      () => ref.read(rtcRemoteDataSourceProvider).connectCall(session.id),
      '已自动进入通话',
    );
  }

  Future<void> _syncLiveKit(RtcSessionEntity session) async {
    if (!_currentSession) return;
    final liveKit = _liveKitService;
    if (session.isTerminal) {
      await _leaveMediaOnce(session.id);
      return;
    }

    if (!liveKit.isEnabled || _closedMediaCallIds.contains(session.id)) return;

    if (_busy) return;
    if (!['connecting', 'in_call'].contains(session.status)) return;
    if (_liveKitAttemptedCallId == session.id) return;
    _liveKitAttemptedCallId = session.id;
    try {
      await liveKit.ensureConnected(session.id);
    } catch (_) {
      if (_currentSession && widget.callId == session.id) setState(() {});
      return;
    }
  }

  Future<void> _reconnectMedia() async {
    if (!_currentSession) return;
    if (_busy || _liveKitService.isConnecting || _liveKitService.isConnected) {
      return;
    }
    final callId = widget.callId;
    setState(() => _busy = true);
    try {
      // Never reuse the page's cached session or the previous room credentials.
      final current = await ref
          .read(rtcRemoteDataSourceProvider)
          .fetchCall(callId);
      if (!mounted || !_currentSession || widget.callId != callId) return;
      if (current.id != callId ||
          current.isTerminal ||
          !['connecting', 'in_call'].contains(current.status)) {
        throw StateError('通话当前不可重新连接');
      }
      await _leaveMediaOnce(callId);
      if (!mounted || !_currentSession || widget.callId != callId) return;
      _closedMediaCallIds.remove(callId);
      _liveKitAttemptedCallId = current.id;
      // ensureConnected obtains fresh join information through the server gate.
      await _liveKitService.ensureConnected(current.id);
    } catch (_) {
      await _leaveMediaOnce(callId);
      if (mounted && _currentSession && widget.callId == callId) {
        AppFeedback.showError(context, '当前通话授权或网络不可验证，媒体保持关闭');
      }
    } finally {
      if (mounted && _currentSession && widget.callId == callId) {
        ref.invalidate(rtcCallProvider(callId));
        setState(() => _busy = false);
      }
    }
  }

  Widget _statusChip(RtcSessionEntity session) {
    return AppChoiceChip(label: session.status, onTap: null, selected: true);
  }

  Widget _buildContent(
    RtcSessionEntity session,
    dynamic t, {
    required AudioTrack? remoteAudioTrack,
  }) {
    final title = session.title.isNotEmpty
        ? session.title
        : (session.mode == 'video' ? '视频通话' : '语音通话');
    final displayPeer = session.isInitiator
        ? session.peerName
        : session.initiatorName;
    final isIncoming = !session.isInitiator;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        t.spacing.pageHorizontal,
        t.spacing.md,
        t.spacing.pageHorizontal,
        t.spacing.huge,
      ),
      children: [
        AppInfoSectionCard(
          title: title,
          subtitle: session.mode == 'video' ? '双向音视频' : '双向语音',
          leadingIcon: session.mode == 'video'
              ? Icons.videocam_outlined
              : Icons.call_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.14),
                    child: Icon(
                      session.mode == 'video'
                          ? Icons.videocam_outlined
                          : Icons.call_outlined,
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayPeer,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          session.failureMessage ?? '以双方当前授权建立通话',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(session),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  AppChoiceChip(
                    label: session.isInitiator ? '发起方' : '接听方',
                    onTap: null,
                  ),
                  AppChoiceChip(
                    label: session.mode == 'video' ? '视频通话' : '语音通话',
                    onTap: null,
                  ),
                  if (session.latestEventName != null)
                    AppChoiceChip(label: session.latestEventName!, onTap: null),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Text(
                switch (session.status) {
                  'calling' => '等待对方接听',
                  'ringing' => isIncoming ? '有来电进入' : '正在呼叫对方',
                  'connecting' => '正在建立通话',
                  'in_call' => '通话进行中',
                  'rejected' => '对方已拒绝',
                  'missed' => '未接通',
                  'busy' => '对方正在通话中',
                  'ended' => '通话已结束',
                  'failed' => '通话失败',
                  _ => '通话状态未知',
                },
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: t.spacing.xxs),
              Text(
                '麦克风和摄像头仅在当前通话中使用，挂断后关闭。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        if (session.mode == 'video' && !session.isTerminal) ...[
          _videoPanel(),
          SizedBox(height: t.spacing.md),
        ],
        if (_liveKitService.failureMessage != null && !session.isTerminal)
          AppErrorState(
            title: '媒体连接已关闭',
            description: _liveKitService.failureMessage!,
          ),
        if (_liveKitService.isEnabled &&
            ['connecting', 'in_call'].contains(session.status) &&
            !session.isTerminal &&
            _liveKitAttemptedCallId == session.id &&
            !_liveKitService.isConnected &&
            !_liveKitService.isConnecting)
          AppSecondaryButton(
            label: '重新连接',
            isLoading: _busy,
            onPressed: _busy ? null : _reconnectMedia,
          ),
        if (_liveKitService.isConnected) ...[
          Wrap(
            spacing: 8,
            children: [
              IconButton.filledTonal(
                tooltip: _liveKitService.microphoneEnabled ? '静音' : '开启麦克风',
                onPressed: () => _mediaAction(
                  () => _liveKitService.setMicrophoneEnabled(
                    !_liveKitService.microphoneEnabled,
                  ),
                ),
                icon: Icon(
                  _liveKitService.microphoneEnabled ? Icons.mic : Icons.mic_off,
                ),
              ),
              if (session.mode == 'video') ...[
                IconButton.filledTonal(
                  tooltip: _liveKitService.cameraEnabled ? '关闭摄像头' : '开启摄像头',
                  onPressed: () => _mediaAction(
                    () => _liveKitService.setCameraEnabled(
                      !_liveKitService.cameraEnabled,
                    ),
                  ),
                  icon: Icon(
                    _liveKitService.cameraEnabled
                        ? Icons.videocam
                        : Icons.videocam_off,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: '切换摄像头',
                  onPressed: _liveKitService.cameraEnabled
                      ? () => _mediaAction(_liveKitService.switchCamera)
                      : null,
                  icon: const Icon(Icons.cameraswitch),
                ),
              ],
            ],
          ),
          SizedBox(height: t.spacing.md),
        ],
        AppInfoSectionCard(
          title: '通话操作',
          subtitle: '接听与结束',
          leadingIcon: Icons.tune_rounded,
          child: Column(
            children: [
              if (session.canAccept && isIncoming) ...[
                AppPrimaryButton(
                  label: '接听',
                  isLoading: _busy,
                  prefixIcon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .acceptCall(session.id),
                    '已接听通话',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                AppSecondaryButton(
                  label: '拒绝',
                  style: AppSecondaryButtonStyle.outline,
                  isLoading: _busy,
                  prefixIcon: const Icon(Icons.call_end_rounded),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .rejectCall(session.id),
                    '已拒绝来电',
                  ),
                ),
              ] else if (session.canConnect) ...[
                AppPrimaryButton(
                  label: '进入通话',
                  isLoading: _busy,
                  prefixIcon: const Icon(
                    Icons.headphones_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .connectCall(session.id),
                    '已进入通话',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                AppSecondaryButton(
                  label: '挂断',
                  style: AppSecondaryButtonStyle.outline,
                  isLoading: _busy,
                  prefixIcon: const Icon(Icons.call_end_rounded),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .endCall(session.id),
                    '已挂断',
                  ),
                ),
              ] else if (session.canHangup) ...[
                AppPrimaryButton(
                  label: '挂断',
                  isLoading: _busy,
                  prefixIcon: const Icon(
                    Icons.call_end_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .endCall(session.id),
                    '已挂断',
                  ),
                ),
              ] else if (session.isTerminal) ...[
                AppPrimaryButton(
                  label: '查看结果',
                  isLoading: _busy,
                  prefixIcon: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (!_currentSession) return;
                    context.push(
                      '${AppRouteNames.rtcCallResult}/${session.id}',
                      extra: session.title,
                    );
                  },
                ),
                SizedBox(height: t.spacing.sm),
                AppSecondaryButton(
                  label: '返回会话',
                  style: AppSecondaryButtonStyle.outline,
                  onPressed: () => context.go(AppRouteNames.messages),
                ),
              ] else ...[
                AppSecondaryButton(
                  label: '返回会话',
                  fullWidth: true,
                  onPressed: () => context.go(AppRouteNames.messages),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '音频频谱',
          subtitle: '远端语音可视化诊断',
          leadingIcon: Icons.graphic_eq_rounded,
          child: RtcAudioSpectrumBar(audioTrack: remoteAudioTrack),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '状态回放',
          subtitle: '最新事件与时间线',
          leadingIcon: Icons.timeline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'call_id: ${session.id} / ${session.callKey}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
              SizedBox(height: t.spacing.sm),
              if (session.events.isEmpty)
                Text(
                  '暂无事件记录',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                )
              else
                Column(
                  children: session.events.map((event) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.only(top: t.spacing.xs),
                            decoration: BoxDecoration(
                              color: t.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: t.spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.eventName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (event.payload.isNotEmpty)
                                  Text(
                                    '通话状态已更新',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: t.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _videoPanel() {
    final remote = _liveKitService.remoteVideoTrack;
    final local = _liveKitService.localVideoTrack;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: remote == null
                ? const Center(
                    child: Text(
                      '等待对方视频',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : VideoTrackRenderer(
                    remote,
                    key: ValueKey('remote-${remote.sid}'),
                  ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            width: 100,
            height: 135,
            child: Semantics(
              key: const ValueKey('rtc-local-video-preview'),
              label: '本机视频预览',
              child: local == null
                  ? const ColoredBox(
                      color: Colors.black54,
                      child: Icon(Icons.videocam_off, color: Colors.white),
                    )
                  : VideoTrackRenderer(
                      local,
                      key: ValueKey('local-${local.sid}'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).asData?.value;
    if (_ownerSession == null && session?.isLoggedIn == true) {
      _ownerSession = session;
    }
    if (_ownerSession != null && !identical(session, _ownerSession)) {
      _sessionInvalidated = true;
    }
    if (!_currentSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_leaveMediaOnce(widget.callId));
      });
      return Scaffold(
        appBar: AppBar(title: const Text('通话')),
        body: const Center(child: Text('登录状态已变化，请重新打开通话')),
      );
    }
    if (!_serviceBound) {
      _liveKitService = ref.read(rtcLiveKitServiceProvider);
      _serviceBound = true;
    }
    final callId = widget.callId;
    final sessionAsync = ref.watch(rtcCallProvider(widget.callId));
    final liveKitService = ref.watch(rtcLiveKitServiceProvider);
    final t = context.appTokens;

    return Scaffold(
      body: BrowseScaffold(
        header: AppTopBar(
          title: widget.title,
          mode: AppTopBarMode.backTitle,
          actions: [
            IconButton(
              tooltip: '刷新通话',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: sessionAsync.when(
          skipLoadingOnReload: false,
          // Polling keeps the current call controls and scroll position stable.
          // Actions still fetch fresh authority; real errors close media below.
          skipLoadingOnRefresh: true,
          loading: () => const AppLoadingSkeleton(lines: 6),
          error: (e, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentSession && widget.callId == callId) {
                unawaited(_leaveMediaOnce(callId));
              }
            });
            return ListView(
              padding: EdgeInsets.only(bottom: t.spacing.huge),
              children: [
                AppErrorState(
                  title: '通话加载失败',
                  description: e.toString(),
                  onRetry: _refresh,
                ),
              ],
            );
          },
          data: (session) {
            if (widget.autoConnect) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || !_currentSession || widget.callId != callId) {
                  return;
                }
                unawaited(_autoConnect(session));
              });
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_currentSession || widget.callId != callId) {
                return;
              }
              unawaited(_syncLiveKit(session));
            });
            return _buildContent(
              session,
              t,
              remoteAudioTrack: liveKitService.remoteAudioTrack,
            );
          },
        ),
      ),
    );
  }
}
