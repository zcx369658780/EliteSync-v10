import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';

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

  bool _canOpenConversation(MatchRoundProjection data) {
    final result = data.result;
    final capability = data.conversationCapability;
    return data.state == MatchRoundBusinessState.revealed &&
        result != null &&
        result.matchId > 0 &&
        result.partnerId > 0 &&
        capability != null &&
        (capability.canCreate || capability.canSend);
  }

  ({String title, String body, String action, IconData icon, Color color})
  _content(BuildContext context, MatchRoundProjection data) {
    final t = context.appTokens;
    return switch (data.state) {
      MatchRoundBusinessState.noRound => (
        title: '当前没有进行中的慢约会',
        body: '有新的轮次开放时，会在这里显示。',
        action: '返回首页',
        icon: Icons.calendar_today_outlined,
        color: t.info,
      ),
      MatchRoundBusinessState.scheduled => (
        title: '本轮慢约会已安排',
        body: data.nextTransitionAt == null
            ? '服务器尚未公布下一次状态更新时间。'
            : '请按服务器公布的时间等待下一次状态更新。',
        action: '刷新状态',
        icon: Icons.schedule_rounded,
        color: t.brandPrimary,
      ),
      MatchRoundBusinessState.preparing || MatchRoundBusinessState.running => (
        title: '正在为你匹配',
        body: '本轮匹配正在进行，请稍后刷新查看服务器状态。',
        action: '刷新状态',
        icon: Icons.hourglass_top_rounded,
        color: t.brandPrimary,
      ),
      MatchRoundBusinessState.revealed => (
        title: '本轮结果已公布',
        body: data.result?.headline.trim().isNotEmpty == true
            ? data.result!.headline
            : '结果已经可以查看，请按当前可用操作继续。',
        action: _canOpenConversation(data) ? '前往消息' : '刷新结果',
        icon: Icons.auto_awesome_rounded,
        color: t.success,
      ),
      MatchRoundBusinessState.noCandidate => (
        title: '本轮暂未匹配到合适的人',
        body: '这是本轮结果。可以返回首页，等待下一轮开放。',
        action: '返回首页',
        icon: Icons.favorite_border_rounded,
        color: t.info,
      ),
      MatchRoundBusinessState.failed => (
        title: '本轮状态暂时无法更新',
        body: '请稍后重新加载；这不代表本轮暂未匹配到人。',
        action: '重新加载',
        icon: Icons.sync_problem_rounded,
        color: t.warning,
      ),
      MatchRoundBusinessState.closed => (
        title: '本轮已结束',
        body: '如已有可用消息，可从消息页查看。',
        action: '查看消息',
        icon: Icons.task_alt_rounded,
        color: t.textSecondary,
      ),
    };
  }

  Future<void> _primaryAction(MatchRoundProjection data) async {
    switch (data.state) {
      case MatchRoundBusinessState.noRound:
      case MatchRoundBusinessState.noCandidate:
        if (mounted) context.go(AppRouteNames.home);
        return;
      case MatchRoundBusinessState.revealed:
        if (_canOpenConversation(data)) {
          if (mounted) context.go(AppRouteNames.messages);
        } else {
          await _refreshProjection();
        }
        return;
      case MatchRoundBusinessState.closed:
        if (mounted) context.go(AppRouteNames.messages);
        return;
      case MatchRoundBusinessState.preparing:
      case MatchRoundBusinessState.running:
      case MatchRoundBusinessState.scheduled:
      case MatchRoundBusinessState.failed:
        await _refreshProjection();
        return;
    }
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
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (_, _) => AppErrorState(
          title: '当前状态不可用',
          description: '网络或服务暂时不可用，请重新连接后重试。',
          retryLabel: '重新加载',
          onRetry: _refreshProjection,
        ),
        data: (data) {
          final content = _content(context, data);
          final showServerTime =
              data.state == MatchRoundBusinessState.scheduled;
          final actionAllowed = _canOpenConversation(data);
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
                        onPressed: () => _primaryAction(data),
                      ),
                      if (data.state == MatchRoundBusinessState.revealed &&
                          !actionAllowed) ...[
                        const SizedBox(height: 8),
                        Text(
                          '当前没有可用的消息入口，请稍后刷新结果。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
