import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

enum DateDropReadinessStage { waiting, reveal, chatPrep, feedback }

class DateDropReadinessCard extends StatelessWidget {
  const DateDropReadinessCard({
    super.key,
    required this.stage,
    this.primarySignal,
    this.secondarySignal,
    this.compact = false,
  });

  final DateDropReadinessStage stage;
  final String? primarySignal;
  final String? secondarySignal;
  final bool compact;

  String get _title {
    switch (stage) {
      case DateDropReadinessStage.waiting:
        return '本轮行动确认';
      case DateDropReadinessStage.reveal:
        return '揭晓后的选择确认';
      case DateDropReadinessStage.chatPrep:
        return '首聊前的手动确认';
      case DateDropReadinessStage.feedback:
        return '反馈方向确认';
    }
  }

  String get _subtitle {
    switch (stage) {
      case DateDropReadinessStage.waiting:
        return '确认本轮节奏和资料表达后，再安静等待慢约会揭晓。';
      case DateDropReadinessStage.reveal:
        return '先看推荐理由和共同线索，再决定是否进入聊天或稍后反馈。';
      case DateDropReadinessStage.chatPrep:
        return '开场建议只是草稿来源，发送动作始终由你自己确认。';
      case DateDropReadinessStage.feedback:
        return '把这次体验整理成温和反馈，帮助后续方向更贴近你。';
    }
  }

  IconData get _icon {
    switch (stage) {
      case DateDropReadinessStage.waiting:
        return Icons.fact_check_outlined;
      case DateDropReadinessStage.reveal:
        return Icons.visibility_outlined;
      case DateDropReadinessStage.chatPrep:
        return Icons.edit_note_rounded;
      case DateDropReadinessStage.feedback:
        return Icons.rate_review_outlined;
    }
  }

  List<_ReadinessItem> get _items {
    switch (stage) {
      case DateDropReadinessStage.waiting:
        return const [
          _ReadinessItem('资料表达', '确认资料和问卷更接近当前状态。'),
          _ReadinessItem('等待揭晓', '等待期间不需要反复刷新。'),
          _ReadinessItem('不为你打分', '准备是为了更容易被理解，不是给你贴标签。'),
        ];
      case DateDropReadinessStage.reveal:
        return const [
          _ReadinessItem('先读理由', '先看共同点、差异和行动建议。'),
          _ReadinessItem('再决定', '可以进入聊天，也可以稍后再反馈。'),
          _ReadinessItem('不替你判断', '解释只帮助理解，不替你决定关系结果。'),
        ];
      case DateDropReadinessStage.chatPrep:
        return const [
          _ReadinessItem('草稿可改', '开场话题可以追加、替换或放弃。'),
          _ReadinessItem('手动发送', '写入草稿不等于自动发送消息。'),
          _ReadinessItem('低压推进', '先问一个轻问题，再看对方回应。'),
        ];
      case DateDropReadinessStage.feedback:
        return const [
          _ReadinessItem('未来方向', '反馈会帮助后续方向更贴近你。'),
          _ReadinessItem('不替对方打分', '这只是帮助我们理解你的偏好，不会立刻给对方打分。'),
          _ReadinessItem('温和表达', '不合适也可以温和表达。'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = switch (stage) {
      DateDropReadinessStage.waiting => t.brandPrimary,
      DateDropReadinessStage.reveal => t.success,
      DateDropReadinessStage.chatPrep => t.info,
      DateDropReadinessStage.feedback => t.warning,
    };
    final signals = [
      primarySignal,
      secondarySignal,
    ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty);

    return AppCard(
      padding: EdgeInsets.all(
        compact ? t.spacing.cardPadding : t.spacing.cardPaddingLarge,
      ),
      border: Border.all(color: accent.withValues(alpha: 0.2)),
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
                child: Icon(_icon, color: accent, size: 20),
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
                        const AppChoiceChip(label: '你来决定', selected: true),
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
          if (signals.isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxSignalWidth = constraints.maxWidth < 280
                    ? constraints.maxWidth
                    : 280.0;
                return Wrap(
                  spacing: t.spacing.xs,
                  runSpacing: t.spacing.xs,
                  children: signals
                      .map(
                        (signal) => _SignalTag(
                          label: signal,
                          maxWidth: maxSignalWidth,
                          accent: accent,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
          SizedBox(height: t.spacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 560;
              final rows = _items
                  .map((item) => _ReadinessTile(item: item, accent: accent))
                  .toList();
              if (narrow) {
                return Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      rows[i],
                      if (i != rows.length - 1) SizedBox(height: t.spacing.xs),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    Expanded(child: rows[i]),
                    if (i != rows.length - 1) SizedBox(width: t.spacing.xs),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '行动卡：承接路径卡的当前阶段，只做温和提示，不写资料或星盘真值、不替对方打分、不自动发送聊天消息。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalTag extends StatelessWidget {
  const _SignalTag({
    required this.label,
    required this.maxWidth,
    required this.accent,
  });

  final String label;
  final double maxWidth;
  final Color accent;

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
          color: t.browseChip.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(t.radius.pill),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 14, color: accent),
            SizedBox(width: t.spacing.xxs),
            Flexible(
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
          ],
        ),
      ),
    );
  }
}

class _ReadinessItem {
  const _ReadinessItem(this.title, this.body);

  final String title;
  final String body;
}

class _ReadinessTile extends StatelessWidget {
  const _ReadinessTile({required this.item, required this.accent});

  final _ReadinessItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
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
              Icon(Icons.check_circle_outline_rounded, size: 16, color: accent),
              SizedBox(width: t.spacing.xxs),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            item.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
