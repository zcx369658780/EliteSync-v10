import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/canonical_match_lifecycle.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/canonical_match_explanation_card.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state_view.dart';

class MatchRoundContractView extends ConsumerStatefulWidget {
  const MatchRoundContractView({super.key});

  @override
  ConsumerState<MatchRoundContractView> createState() =>
      _MatchRoundContractViewState();
}

class _MatchRoundContractViewState
    extends ConsumerState<MatchRoundContractView> {
  Timer? _timer;
  Future<void>? _refreshInFlight;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _time(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${local.month}月${two(local.day)}日 ${two(local.hour)}:${two(local.minute)}';
  }

  String _remaining(MatchRoundProjection data) {
    final duration = data.remainingAt(DateTime.now().toUtc());
    if (duration == null) return '下一次状态更新时间尚未确定';
    if (duration == Duration.zero) return '状态更新时间已到，正在等待服务器更新';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}小时 ${minutes.toString().padLeft(2, '0')}分';
  }

  ({String title, String body, String action, IconData icon, Color color})
  _content(
    BuildContext context,
    MatchRoundProjection data,
    CanonicalMatchLifecycleSnapshot canonical,
  ) {
    final t = context.appTokens;
    if (canonical.condition == CanonicalMatchPresentationCondition.noRound) {
      return (
        title: '当前没有进行中的慢约会',
        body: '这是当前轮次可用性，不代表退出、拒绝或匹配失败。',
        action: '返回首页',
        icon: Icons.calendar_today_outlined,
        color: t.info,
      );
    }
    if (canonical.condition ==
        CanonicalMatchPresentationCondition.noCandidate) {
      return (
        title: '本轮暂无候选提案',
        body: '这是本轮可用性结果，不代表你被拒绝，也不是兼容性或安全结论。',
        action: '返回首页',
        icon: Icons.favorite_border_rounded,
        color: t.info,
      );
    }
    if (canonical.condition ==
        CanonicalMatchPresentationCondition.transportUnavailable) {
      return (
        title: '本轮状态暂时无法更新',
        body: '请稍后重新加载；传输或服务问题不是匹配领域结果。',
        action: '重新加载',
        icon: Icons.sync_problem_rounded,
        color: t.warning,
      );
    }
    if (canonical.condition ==
        CanonicalMatchPresentationCondition.closedWithoutCompletionEvidence) {
      return (
        title: '本轮已关闭',
        body: '当前来源没有证明本轮已完成、已过期或建立任何后续生命周期。',
        action: '刷新状态',
        icon: Icons.task_alt_rounded,
        color: t.textSecondary,
      );
    }

    return switch (canonical.targetState) {
      CanonicalMatchTargetState.active
          when data.state == MatchRoundBusinessState.scheduled =>
        (
          title: '本轮慢约会已安排',
          body: data.nextTransitionAt == null
              ? '服务器尚未公布下一次状态更新时间。'
              : '请按服务器公布的时间等待下一次状态更新。',
          action: '刷新状态',
          icon: Icons.schedule_rounded,
          color: t.brandPrimary,
        ),
      CanonicalMatchTargetState.active => (
        title: '正在为你匹配',
        body: '当前轮次正在进行；这不代表已有候选提案。',
        action: '刷新状态',
        icon: Icons.hourglass_top_rounded,
        color: t.brandPrimary,
      ),
      CanonicalMatchTargetState.proposalPresented => (
        title: '候选提案已呈现',
        body: '当前存在一项候选提案；可用信息仍然有限，请结合说明自行判断。',
        action: '刷新结果',
        icon: Icons.auto_awesome_rounded,
        color: t.success,
      ),
      CanonicalMatchTargetState.completed => (
        title: '本轮 Match 已完成',
        body: '完成只结束本轮 Match；不会创建 Connection，也不会授权 Conversation。',
        action: '刷新状态',
        icon: Icons.task_alt_rounded,
        color: t.textSecondary,
      ),
      CanonicalMatchTargetState.notOptedIn ||
      CanonicalMatchTargetState.interestRecorded ||
      CanonicalMatchTargetState.mutualInterest ||
      CanonicalMatchTargetState.paused ||
      CanonicalMatchTargetState.declined ||
      CanonicalMatchTargetState.expired ||
      CanonicalMatchTargetState.withdrawn ||
      null => (
        title: '目标 Match 状态尚未建立',
        body: '当前 round projection 不足以证明该目标生命周期状态。',
        action: '刷新状态',
        icon: Icons.help_outline_rounded,
        color: t.info,
      ),
    };
  }

  Future<void> _primaryAction(CanonicalMatchLifecycleSnapshot canonical) async {
    if (canonical.condition == CanonicalMatchPresentationCondition.noRound ||
        canonical.condition ==
            CanonicalMatchPresentationCondition.noCandidate) {
      if (mounted) context.go(AppRouteNames.home);
      return;
    }
    await _refreshProjection();
  }

  Future<void> _refreshProjection() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final operation = _performRefresh();
    _refreshInFlight = operation;
    operation.whenComplete(() {
      if (identical(_refreshInFlight, operation)) {
        _refreshInFlight = null;
      }
    });
    return operation;
  }

  Future<void> _performRefresh() async {
    ref.invalidate(matchRoundProjectionProvider);
    try {
      await ref.read(matchRoundProjectionProvider.future);
    } catch (_) {
      // The provider now owns the AsyncError state rendered by this view.
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final async = ref.watch(matchRoundProjectionProvider);
    return BrowseScaffold(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '慢约会',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: '刷新本轮状态',
                onPressed: _refreshProjection,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Text(
            '查看当前状态和可用的下一步。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
      body: async.when(
        skipLoadingOnRefresh: false,
        loading: () => const AppPresentationStateView(
          state: AppPresentationState.loading(
            safeTitle: '正在读取 Match 状态',
            safeBody: '所属来源尚未完成解析；这不代表 Match、Connection 或同意正在等待。',
          ),
          loadingLines: 6,
        ),
        error: (_, _) => AppPresentationStateView(
          state: const AppPresentationState.retryableError(
            safeTitle: '当前状态不可用',
            safeBody: '网络或服务暂时不可用，请重新连接后重试；这不是 Match 领域结果。',
            safeActionLabel: '重新加载',
          ),
          onRetryRead: _refreshProjection,
        ),
        data: (data) {
          final canonical = CanonicalMatchLifecycleAdapter.fromRound(data);
          final content = _content(context, data, canonical);
          final showServerTime =
              data.state == MatchRoundBusinessState.scheduled;
          return RefreshIndicator(
            onRefresh: _refreshProjection,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: t.spacing.huge),
              children: [
                AppCard(
                  padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: content.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(content.icon, color: content.color),
                      ),
                      SizedBox(height: t.spacing.md),
                      Text(
                        content.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      if (showServerTime) ...[
                        SizedBox(height: t.spacing.lg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: content.color.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(t.radius.lg),
                            border: Border.all(
                              color: content.color.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _remaining(data),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: content.color,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              if (data.nextTransitionAt != null) ...[
                                const SizedBox(height: 5),
                                Text(
                                  '服务器更新时间：${_time(data.nextTransitionAt)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: t.spacing.lg),
                      AppPrimaryButton(
                        label: content.action,
                        onPressed: () => _primaryAction(canonical),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.spacing.md),
                CanonicalMatchExplanationCard(snapshot: canonical),
              ],
            ),
          );
        },
      ),
    );
  }
}
