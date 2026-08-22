import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/relationship_runtime_local_presentation_state.dart';

/// Developer-only local preview for relationship runtime presentation state.
class RelationshipRuntimeLocalPreviewPanel extends StatelessWidget {
  const RelationshipRuntimeLocalPreviewPanel({
    super.key,
    required this.state,
    this.compact = false,
    this.maxEntries = 5,
  }) : assert(maxEntries > 0);

  final RelationshipRuntimeLocalPresentationState state;
  final bool compact;
  final int maxEntries;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = _accentForPhase(t);
    final entries = state.entries.take(maxEntries).toList(growable: false);
    final hiddenEntryCount = state.entries.length > maxEntries
        ? state.entries.length - maxEntries
        : 0;

    return AppCard(
      padding: EdgeInsets.all(
        compact ? t.spacing.cardPadding : t.spacing.cardPaddingLarge,
      ),
      border: Border.all(color: accent.withValues(alpha: 0.16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(t.radius.pill),
                ),
                alignment: Alignment.center,
                child: Icon(_iconForPhase, color: accent, size: 20),
              ),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: t.spacing.xs,
                      runSpacing: t.spacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const AppChoiceChip(label: '本地预览', selected: true),
                        AppChoiceChip(label: '证据 ${state.evidenceLevel}'),
                      ],
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      _subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          _PreviewSummary(
            state: state,
            visibleEntryCount: entries.length,
            hiddenEntryCount: hiddenEntryCount,
            accent: accent,
          ),
          SizedBox(height: t.spacing.sm),
          _GuardStrip(guards: state.guards, accent: accent),
          SizedBox(height: t.spacing.sm),
          if (entries.isEmpty)
            Text(
              '暂无本地关系运行态：默认空态或异常载荷会安全降级到不可见运行态。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _PreviewEntryTile(entry: entries[i], accent: accent),
                  if (i != entries.length - 1) SizedBox(height: t.spacing.xs),
                ],
              ],
            ),
          SizedBox(height: t.spacing.sm),
          Text(
            '开发者本地预览：只展示本地注入状态，不接公开入口、不写资料或星盘真值、不自动发送聊天消息；真实用户路径仍需后续单独授权。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    switch (state.phase) {
      case RelationshipRuntimeLocalPresentationPhase.inactive:
        return '本地关系预览未激活';
      case RelationshipRuntimeLocalPresentationPhase.preparing:
        return '本地关系预览：准备中';
      case RelationshipRuntimeLocalPresentationPhase.waiting:
        return '本地关系预览：等待揭晓';
      case RelationshipRuntimeLocalPresentationPhase.revealAvailable:
      case RelationshipRuntimeLocalPresentationPhase.revealed:
        return '本地关系预览：可查看线索';
      case RelationshipRuntimeLocalPresentationPhase.openerPrepared:
      case RelationshipRuntimeLocalPresentationPhase.conversationOpened:
        return '本地关系预览：开场草稿';
      case RelationshipRuntimeLocalPresentationPhase.feedbackPending:
      case RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal:
      case RelationshipRuntimeLocalPresentationPhase
          .feedbackRecordedRemoteFuture:
        return '本地关系预览：反馈整理';
      case RelationshipRuntimeLocalPresentationPhase.nextRoundPending:
        return '本地关系预览：下一轮';
      case RelationshipRuntimeLocalPresentationPhase.noCandidate:
        return '本地关系预览：暂无候选';
      case RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable:
      case RelationshipRuntimeLocalPresentationPhase.authSessionFailure:
        return '本地关系预览：暂不可用';
    }
  }

  String get _subtitle {
    switch (state.phase) {
      case RelationshipRuntimeLocalPresentationPhase.inactive:
        return '没有本地注入载荷时保持空态，不改变真实关系流程。';
      case RelationshipRuntimeLocalPresentationPhase.waiting:
        return '用于检查等待阶段文案和边界，不触发刷新或请求。';
      case RelationshipRuntimeLocalPresentationPhase.revealAvailable:
      case RelationshipRuntimeLocalPresentationPhase.revealed:
        return '用于检查揭晓阶段的本地线索展示，不进入真实聊天。';
      case RelationshipRuntimeLocalPresentationPhase.noCandidate:
        return '用于检查暂无候选时的本地降级表达。';
      case RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable:
      case RelationshipRuntimeLocalPresentationPhase.authSessionFailure:
        return '用于检查暂停、不可用或会话失败时的本地兜底表达。';
      default:
        return '用于检查本地阶段、守卫和边界文案，不连接线上运行时。';
    }
  }

  IconData get _iconForPhase {
    switch (state.phase) {
      case RelationshipRuntimeLocalPresentationPhase.revealAvailable:
      case RelationshipRuntimeLocalPresentationPhase.revealed:
        return Icons.visibility_outlined;
      case RelationshipRuntimeLocalPresentationPhase.noCandidate:
        return Icons.search_off_rounded;
      case RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable:
      case RelationshipRuntimeLocalPresentationPhase.authSessionFailure:
        return Icons.pause_circle_outline_rounded;
      case RelationshipRuntimeLocalPresentationPhase.feedbackPending:
      case RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal:
      case RelationshipRuntimeLocalPresentationPhase
          .feedbackRecordedRemoteFuture:
        return Icons.rate_review_outlined;
      default:
        return Icons.developer_mode_rounded;
    }
  }

  Color _accentForPhase(AppThemeTokens t) {
    switch (state.phase) {
      case RelationshipRuntimeLocalPresentationPhase.revealAvailable:
      case RelationshipRuntimeLocalPresentationPhase.revealed:
        return t.success;
      case RelationshipRuntimeLocalPresentationPhase.noCandidate:
        return t.warning;
      case RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable:
      case RelationshipRuntimeLocalPresentationPhase.authSessionFailure:
        return t.textTertiary;
      case RelationshipRuntimeLocalPresentationPhase.feedbackPending:
      case RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal:
      case RelationshipRuntimeLocalPresentationPhase
          .feedbackRecordedRemoteFuture:
        return t.info;
      default:
        return t.brandPrimary;
    }
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary({
    required this.state,
    required this.visibleEntryCount,
    required this.hiddenEntryCount,
    required this.accent,
  });

  final RelationshipRuntimeLocalPresentationState state;
  final int visibleEntryCount;
  final int hiddenEntryCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final items = <String>[
      '阶段：${_phaseLabel(state.phase)}',
      '展示 $visibleEntryCount / ${state.entries.length}',
      if (hiddenEntryCount > 0) '另有 $hiddenEntryCount 条已折叠',
      state.guards.protectedRuntimeDisabled ? '运行面关闭' : '需复核守卫',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Text(
        items.join(' · '),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: t.textSecondary,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GuardStrip extends StatelessWidget {
  const _GuardStrip({required this.guards, required this.accent});

  final RelationshipRuntimeLocalPresentationGuards guards;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final labels = <String>[
      if (guards.canRevealLocally) '仅本地揭晓',
      if (guards.canOpenConversationLocally) '仅本地开场草稿',
      if (guards.manualSendOnly) '手动发送',
      if (!guards.automaticSendAllowed && !guards.canSend) '不会自动发送',
      if (guards.localFeedbackOnly) '本地反馈',
      if (guards.remoteFeedbackInactive) '远端反馈未启用',
      if (guards.notificationPushInactive) '通知推送未启用',
      if (guards.readModelOnly) '只读模型',
      if (guards.protectedRuntimeDisabled) '运行面禁用',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本地守卫',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: t.spacing.xxs),
        Wrap(
          spacing: t.spacing.xs,
          runSpacing: t.spacing.xs,
          children: labels
              .map(
                (label) => AppChoiceChip(
                  label: label,
                  selected: label == '运行面禁用',
                  leading: Icon(
                    label == '运行面禁用'
                        ? Icons.lock_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: accent,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

String _phaseLabel(RelationshipRuntimeLocalPresentationPhase phase) {
  switch (phase) {
    case RelationshipRuntimeLocalPresentationPhase.inactive:
      return '未激活';
    case RelationshipRuntimeLocalPresentationPhase.preparing:
      return '准备中';
    case RelationshipRuntimeLocalPresentationPhase.waiting:
      return '等待揭晓';
    case RelationshipRuntimeLocalPresentationPhase.revealAvailable:
    case RelationshipRuntimeLocalPresentationPhase.revealed:
      return '可查看线索';
    case RelationshipRuntimeLocalPresentationPhase.openerPrepared:
    case RelationshipRuntimeLocalPresentationPhase.conversationOpened:
      return '开场草稿';
    case RelationshipRuntimeLocalPresentationPhase.feedbackPending:
    case RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal:
    case RelationshipRuntimeLocalPresentationPhase.feedbackRecordedRemoteFuture:
      return '反馈整理';
    case RelationshipRuntimeLocalPresentationPhase.nextRoundPending:
      return '下一轮';
    case RelationshipRuntimeLocalPresentationPhase.noCandidate:
      return '暂无候选';
    case RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable:
    case RelationshipRuntimeLocalPresentationPhase.authSessionFailure:
      return '暂不可用';
  }
}

class _PreviewEntryTile extends StatelessWidget {
  const _PreviewEntryTile({required this.entry, required this.accent});

  final RelationshipRuntimeLocalPresentationEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final details = <String>[
      '本地状态：${entry.runtimeState}',
      '回合：${entry.roundId}',
      if (entry.candidateSummaryAvailable) '候选摘要可见',
      if (entry.candidateDetailAvailable) '候选详情可见',
      if (entry.explanationBlocksAvailable) '解释块可见',
      if (entry.reasonCode != null) '原因：${entry.reasonCode}',
      if (entry.retryable != null) entry.retryable! ? '可本地重试' : '不建议重试',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _entryTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            details.join(' · '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '兜底文案：${entry.fallbackCopyKey}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String get _entryTitle {
    switch (entry.phase) {
      case RelationshipRuntimeLocalPresentationPhase.waiting:
        return '等待揭晓';
      case RelationshipRuntimeLocalPresentationPhase.revealAvailable:
      case RelationshipRuntimeLocalPresentationPhase.revealed:
        return '可查看线索';
      case RelationshipRuntimeLocalPresentationPhase.openerPrepared:
      case RelationshipRuntimeLocalPresentationPhase.conversationOpened:
        return '开场草稿';
      case RelationshipRuntimeLocalPresentationPhase.noCandidate:
        return '暂无候选';
      case RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable:
      case RelationshipRuntimeLocalPresentationPhase.authSessionFailure:
        return '暂不可用';
      case RelationshipRuntimeLocalPresentationPhase.feedbackPending:
      case RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal:
      case RelationshipRuntimeLocalPresentationPhase
          .feedbackRecordedRemoteFuture:
        return '反馈整理';
      case RelationshipRuntimeLocalPresentationPhase.nextRoundPending:
        return '下一轮';
      default:
        return '本地阶段';
    }
  }
}
