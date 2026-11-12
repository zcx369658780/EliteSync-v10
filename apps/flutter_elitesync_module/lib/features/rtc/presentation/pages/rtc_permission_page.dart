import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
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
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class RtcPermissionPage extends ConsumerStatefulWidget {
  const RtcPermissionPage({
    super.key,
    this.title = '通话权限',
    this.sourcePage = 'rtc_permission',
    this.requireCamera = false,
  });

  final String title;
  final String sourcePage;
  final bool requireCamera;

  @override
  ConsumerState<RtcPermissionPage> createState() => _RtcPermissionPageState();
}

class _RtcPermissionPageState extends ConsumerState<RtcPermissionPage>
    with WidgetsBindingObserver {
  bool _busy = false;
  bool _foreground = true;
  bool _canceled = false;
  bool _finished = false;
  bool? _pendingResult;
  SessionState? _ownerSession;

  bool get _currentSession =>
      mounted &&
      !_canceled &&
      _ownerSession?.isLoggedIn == true &&
      identical(ref.read(sessionProvider).asData?.value, _ownerSession);

  String get _permissionName => widget.requireCamera ? '麦克风和摄像头权限' : '麦克风权限';

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground =
        lifecycle != AppLifecycleState.inactive &&
        lifecycle != AppLifecycleState.hidden &&
        lifecycle != AppLifecycleState.paused &&
        lifecycle != AppLifecycleState.detached;
    WidgetsBinding.instance.addObserver(this);
    ref
        .read(frontendTelemetryProvider)
        .rtcCallEntryOpened(sourcePage: widget.sourcePage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshPermissionState(showFeedback: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _foreground = true);
      if (_pendingResult != null) _finishWhenForeground(_pendingResult!);
      return;
    }
    _foreground = false;
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cancel();
    }
  }

  void _cancel() {
    _canceled = true;
    _finishWhenForeground(false);
  }

  void _finishWhenForeground(bool result) {
    if (!mounted || _finished) return;
    _pendingResult = result && !_canceled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _finished ||
          !_foreground ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      final result = _pendingResult;
      if (result == null) return;
      _finished = true;
      _pendingResult = null;
      Navigator.of(context).maybePop(result && _currentSession);
    });
  }

  Future<bool> _hasPermissions() async {
    final service = ref.read(rtcPermissionServiceProvider);
    if (!await service.hasVoiceCallPermission()) return false;
    if (!_currentSession) return false;
    return !widget.requireCamera || await service.hasCameraPermission();
  }

  Future<void> _refreshPermissionState({required bool showFeedback}) async {
    if (_busy || !_currentSession) return;
    try {
      final granted = await _hasPermissions();
      if (!mounted || !_currentSession) return;
      if (granted) {
        if (showFeedback) {
          AppFeedback.showSuccess(context, '$_permissionName已开启，可以返回继续通话');
        }
        _finishWhenForeground(true);
        return;
      }
      if (showFeedback) {
        AppFeedback.showInfo(context, '$_permissionName尚未开启，请先完成授权');
      }
    } catch (_) {
      if (showFeedback && mounted && _currentSession) {
        AppFeedback.showError(context, '权限状态读取失败，请重试');
      }
    }
  }

  Future<void> _requestPermission() async {
    if (_busy || !_currentSession || !_foreground) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(rtcPermissionServiceProvider);
      var granted = await service.ensureVoiceCallPermission();
      if (!mounted || !_currentSession) return;
      if (granted && widget.requireCamera) {
        granted = await service.ensureCameraPermission();
        if (!mounted || !_currentSession) return;
      }
      if (granted) {
        _finishWhenForeground(true);
      } else {
        AppFeedback.showError(
          context,
          widget.requireCamera
              ? '通话权限尚未完整开启，请在系统设置中授权后重试'
              : '麦克风权限未开启，请在系统设置中授权后重试',
        );
      }
    } catch (_) {
      if (!mounted || !_currentSession) return;
      AppFeedback.showError(context, '权限申请失败，请重试或前往系统设置');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _openSettings() async {
    if (_busy || !_currentSession || !_foreground) return;
    setState(() => _busy = true);
    try {
      await ref.read(rtcPermissionServiceProvider).openSettings();
    } catch (_) {
      if (!mounted || !_currentSession) return;
      AppFeedback.showError(context, '系统设置暂不可用，请重试');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _buildContent(dynamic t) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        t.spacing.pageHorizontal,
        t.spacing.md,
        t.spacing.pageHorizontal,
        t.spacing.huge,
      ),
      children: [
        AppInfoSectionCard(
          title: '通话权限',
          subtitle: '通话需要设备权限',
          leadingIcon: Icons.mic_none_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.14),
                    child: Icon(Icons.mic_none_rounded, color: t.brandPrimary),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _permissionName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          widget.requireCamera
                              ? '视频通话需要麦克风和摄像头权限。'
                              : '语音通话需要麦克风权限。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AppChoiceChip(label: '1v1 通话', onTap: null, selected: true),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Text(
                '如果权限未开启，来电或发起通话时会先停留在这里，避免直接失败后让用户看不懂。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '操作',
          subtitle: '授权 / 去设置 / 返回',
          leadingIcon: Icons.tune_rounded,
          child: Column(
            children: [
              AppPrimaryButton(
                label: widget.requireCamera ? '申请通话权限' : '申请麦克风权限',
                isLoading: _busy,
                prefixIcon: const Icon(Icons.mic_rounded, color: Colors.white),
                onPressed: _requestPermission,
              ),
              SizedBox(height: t.spacing.sm),
              AppSecondaryButton(
                label: '打开系统设置',
                style: AppSecondaryButtonStyle.outline,
                isLoading: _busy,
                onPressed: _openSettings,
              ),
              SizedBox(height: t.spacing.sm),
              AppSecondaryButton(
                label: '返回',
                fullWidth: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '提示',
          subtitle: '异常恢复',
          leadingIcon: Icons.info_outline_rounded,
          child: Text(
            '如果你已经授权但仍然无法通话，先返回上一页重试；如果依然失败，再检查系统级麦克风开关。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).asData?.value;
    if (_ownerSession == null && session?.isLoggedIn == true) {
      _ownerSession = session;
    }
    if (_ownerSession == null || !identical(session, _ownerSession)) {
      _cancel();
    }
    final t = context.appTokens;
    return BrowseScaffold(
      header: AppTopBar(
        title: widget.title,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新状态',
            onPressed: () => _refreshPermissionState(showFeedback: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _hasPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingSkeleton(lines: 5);
          }
          if (snapshot.hasError) {
            return ListView(
              padding: EdgeInsets.only(bottom: t.spacing.huge),
              children: [
                AppErrorState(
                  title: '权限状态读取失败',
                  description: snapshot.error.toString(),
                  onRetry: () => setState(() {}),
                ),
              ],
            );
          }
          return _buildContent(t);
        },
      ),
    );
  }
}
