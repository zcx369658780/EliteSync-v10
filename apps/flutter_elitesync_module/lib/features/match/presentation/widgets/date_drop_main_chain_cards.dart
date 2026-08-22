import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/date_drop_main_chain_model.dart';

class DateDropMainChainCard extends StatelessWidget {
  const DateDropMainChainCard({
    super.key,
    required this.model,
    this.result,
    this.onShowcaseTap,
    this.onDetailTap,
    this.onMessagesTap,
    this.onFeedbackTap,
  });

  final DateDropMainChainModel model;
  final MatchResultEntity? result;
  final VoidCallback? onShowcaseTap;
  final VoidCallback? onDetailTap;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onFeedbackTap;

  String get _title {
    switch (model.state) {
      case DateDropChainState.preparing:
        return '本轮慢约会正在整理资料';
      case DateDropChainState.noCandidate:
        return '本轮慢约会还在等待揭晓';
      case DateDropChainState.revealed:
        return '本轮慢约会已可继续了解';
      case DateDropChainState.feedbackGiven:
        return '这次体验已进入回看整理';
    }
  }

  String get _subtitle {
    switch (model.state) {
      case DateDropChainState.preparing:
        return '先整理表达线索，再等待本轮节奏推进。';
      case DateDropChainState.noCandidate:
        return '现在只确认节奏，不提前打开解释或聊天。';
      case DateDropChainState.revealed:
        return '先看关系参考，再决定是否继续聊。';
      case DateDropChainState.feedbackGiven:
        return '反馈只作为后续方向参考。';
    }
  }

  List<String> _actions() {
    final actions = <String>[...model.lightActions];
    if (model.state == DateDropChainState.feedbackGiven) {
      actions.add('回到下一轮说明');
    }
    return actions.take(4).toList();
  }

  String get _primaryActionLabel {
    final actions = _actions();
    if (actions.isNotEmpty) return actions.first;
    return model.nextStepLabel;
  }

  String get _detailTitle {
    switch (model.state) {
      case DateDropChainState.preparing:
        return '展开准备与边界';
      case DateDropChainState.noCandidate:
        return '展开等待说明';
      case DateDropChainState.revealed:
        return '展开解释、开场与反馈';
      case DateDropChainState.feedbackGiven:
        return '展开反馈回看';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = switch (model.state) {
      DateDropChainState.preparing => t.brandPrimary,
      DateDropChainState.noCandidate => t.warning,
      DateDropChainState.revealed => t.success,
      DateDropChainState.feedbackGiven => t.info,
    };

    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
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
                child: Icon(Icons.favorite_border_rounded, color: accent),
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
                        AppChoiceChip(
                          label: switch (model.state) {
                            DateDropChainState.preparing => '先准备',
                            DateDropChainState.noCandidate => '等待揭晓',
                            DateDropChainState.revealed => '继续了解',
                            DateDropChainState.feedbackGiven => '回看整理',
                          },
                          selected: true,
                        ),
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
          _StageSummary(
            accent: accent,
            stage: model.stageLabel,
            nextStep: model.nextStepLabel,
            boundary: model.boundaryLabel,
          ),
          SizedBox(height: t.spacing.sm),
          _CompactStatusPanel(
            accent: accent,
            prompt: model.showcasePrompt,
            nextAction: _primaryActionLabel,
            boundary: model.boundaryNotes.isNotEmpty
                ? model.boundaryNotes.first
                : model.boundaryLabel,
          ),
          SizedBox(height: t.spacing.sm),
          _ProgressiveDetails(
            title: _detailTitle,
            accent: accent,
            children: [
              _TextSection(
                title: '理解线索',
                icon: Icons.checklist_rounded,
                accent: accent,
                items: model.preparationReferences.take(5).toList(),
              ),
              SizedBox(height: t.spacing.sm),
              _TextSection(
                title: '更多可做的事',
                icon: Icons.tips_and_updates_outlined,
                accent: accent,
                items: _actions().skip(1).toList(),
              ),
              SizedBox(height: t.spacing.sm),
              _ChipSection(
                title: '草稿开场 · 手动发送',
                icon: Icons.chat_bubble_outline_rounded,
                accent: t.info,
                items: model.openerSuggestions,
              ),
              SizedBox(height: t.spacing.sm),
              _ChipSection(
                title: '反馈意向 · 只作方向参考',
                icon: Icons.tune_rounded,
                accent: t.warning,
                items: model.feedbackOptions,
              ),
              SizedBox(height: t.spacing.sm),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: model.boundaryNotes
                    .take(3)
                    .map(
                      (note) => _SoftWrapTag(
                        label: note,
                        accent: t.textTertiary,
                        maxWidth: 220,
                      ),
                    )
                    .toList(),
              ),
              if (model.boundaryNotes.length > 3)
                Padding(
                  padding: EdgeInsets.only(top: t.spacing.xxs),
                  child: Text(
                    '更多边界说明保留在详情与反馈流程中。',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (_showActions) ...[
            SizedBox(height: t.spacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 520;
                final buttons = <Widget>[
                  if (onShowcaseTap != null)
                    AppPrimaryButton(label: '完善展示自己', onPressed: onShowcaseTap),
                  if (onDetailTap != null)
                    AppSecondaryButton(
                      label: '查看完整解释',
                      fullWidth: true,
                      onPressed: onDetailTap,
                    ),
                  if (onMessagesTap != null)
                    AppSecondaryButton(
                      label: '打开消息草稿',
                      fullWidth: true,
                      onPressed: onMessagesTap,
                    ),
                  if (onFeedbackTap != null)
                    AppSecondaryButton(
                      label: '记录反馈意向',
                      fullWidth: true,
                      onPressed: onFeedbackTap,
                    ),
                ];
                if (narrow) {
                  return Column(
                    children: [
                      for (var i = 0; i < buttons.length; i++) ...[
                        SizedBox(width: double.infinity, child: buttons[i]),
                        if (i != buttons.length - 1)
                          SizedBox(height: t.spacing.xs),
                      ],
                    ],
                  );
                }
                return Wrap(
                  spacing: t.spacing.xs,
                  runSpacing: t.spacing.xs,
                  children: buttons
                      .map((button) => SizedBox(width: 160, child: button))
                      .toList(),
                );
              },
            ),
          ],
          if (result != null) ...[
            SizedBox(height: t.spacing.sm),
            Text(
              '当前候选：${result!.headline}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: t.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _showActions =>
      onShowcaseTap != null ||
      onDetailTap != null ||
      onMessagesTap != null ||
      onFeedbackTap != null;
}

class _StageSummary extends StatelessWidget {
  const _StageSummary({
    required this.accent,
    required this.stage,
    required this.nextStep,
    required this.boundary,
  });

  final Color accent;
  final String stage;
  final String nextStep;
  final String boundary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Wrap(
        spacing: t.spacing.xs,
        runSpacing: t.spacing.xs,
        children: [
          _StageStatusChip(
            icon: Icons.radio_button_checked_rounded,
            label: stage,
            accent: accent,
            highlighted: true,
          ),
          _StageStatusChip(
            icon: Icons.arrow_forward_rounded,
            label: nextStep,
            accent: accent,
            highlighted: false,
          ),
          _StageStatusChip(
            icon: Icons.lock_outline_rounded,
            label: boundary,
            accent: accent,
            highlighted: false,
          ),
        ],
      ),
    );
  }
}

class _CompactStatusPanel extends StatelessWidget {
  const _CompactStatusPanel({
    required this.accent,
    required this.prompt,
    required this.nextAction,
    required this.boundary,
  });

  final Color accent;
  final String prompt;
  final String nextAction;
  final String boundary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final rows = [
      _CompactStatusRow(
        icon: Icons.flag_outlined,
        label: '当前重点',
        value: prompt,
      ),
      _CompactStatusRow(
        icon: Icons.arrow_forward_rounded,
        label: '下一步',
        value: nextAction,
      ),
      _CompactStatusRow(
        icon: Icons.verified_user_outlined,
        label: '边界',
        value: boundary,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseChip.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) SizedBox(height: t.spacing.xs),
          ],
        ],
      ),
    );
  }
}

class _CompactStatusRow extends StatelessWidget {
  const _CompactStatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: t.textTertiary),
        SizedBox(width: t.spacing.xxs),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressiveDetails extends StatelessWidget {
  const _ProgressiveDetails({
    required this.title,
    required this.accent,
    required this.children,
  });

  final String title;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: t.secondarySurface.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(t.radius.md),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: t.spacing.sm),
          childrenPadding: EdgeInsets.fromLTRB(
            t.spacing.sm,
            0,
            t.spacing.sm,
            t.spacing.sm,
          ),
          iconColor: accent,
          collapsedIconColor: t.textTertiary,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            '细节按需展开，关键边界已保留在上方。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.3,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _StageStatusChip extends StatelessWidget {
  const _StageStatusChip({
    required this.icon,
    required this.label,
    required this.accent,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final color = highlighted ? accent : t.textSecondary;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: highlighted ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseChip.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              SizedBox(width: t.spacing.xxs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          ...items
              .take(4)
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: t.spacing.xxs),
                  child: Text(
                    '• $item',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.secondarySurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              SizedBox(width: t.spacing.xxs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxTagWidth = constraints.maxWidth < 300
                  ? constraints.maxWidth
                  : 300.0;
              return Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: items
                    .take(4)
                    .map(
                      (item) => _SoftWrapTag(
                        label: item,
                        accent: accent,
                        maxWidth: maxTagWidth,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SoftWrapTag extends StatelessWidget {
  const _SoftWrapTag({
    required this.label,
    required this.accent,
    required this.maxWidth,
  });

  final String label;
  final Color accent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.sm,
          vertical: t.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(t.radius.pill),
          border: Border.all(color: accent.withValues(alpha: 0.24)),
        ),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: t.textSecondary,
            fontWeight: FontWeight.w600,
            height: 1.24,
          ),
        ),
      ),
    );
  }
}
