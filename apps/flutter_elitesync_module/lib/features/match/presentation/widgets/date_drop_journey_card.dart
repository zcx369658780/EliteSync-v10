import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

enum DateDropJourneyStage {
  preparing,
  waiting,
  reveal,
  understanding,
  chatPrep,
  feedback,
  nextRound,
}

extension _DateDropJourneyStageLabel on DateDropJourneyStage {
  String get title {
    switch (this) {
      case DateDropJourneyStage.waiting:
        return '等待';
      case DateDropJourneyStage.preparing:
        return '准备';
      case DateDropJourneyStage.reveal:
        return '揭晓';
      case DateDropJourneyStage.understanding:
        return '理解';
      case DateDropJourneyStage.chatPrep:
        return '低压开场';
      case DateDropJourneyStage.feedback:
        return '反馈';
      case DateDropJourneyStage.nextRound:
        return '下一轮';
    }
  }
}

class DateDropJourneyCard extends StatelessWidget {
  const DateDropJourneyCard({
    super.key,
    required this.stage,
    this.compact = false,
  });

  final DateDropJourneyStage stage;
  final bool compact;

  String get _title {
    switch (stage) {
      case DateDropJourneyStage.preparing:
        return '先准备好被理解的线索';
      case DateDropJourneyStage.waiting:
        return '等待是慢约会节奏的一部分';
      case DateDropJourneyStage.reveal:
        return '揭晓后先看为什么值得了解';
      case DateDropJourneyStage.understanding:
        return '把推荐理由读成关系线索';
      case DateDropJourneyStage.chatPrep:
        return '把解释变成低压开场';
      case DateDropJourneyStage.feedback:
        return '反馈会帮助后续方向';
      case DateDropJourneyStage.nextRound:
        return '整理感受后再进入下一轮';
    }
  }

  String get _subtitle {
    switch (stage) {
      case DateDropJourneyStage.preparing:
        return '先准备表达线索，不给你打分。';
      case DateDropJourneyStage.waiting:
        return '等待期间先确认本轮状态。';
      case DateDropJourneyStage.reveal:
        return '先读理由，再决定。';
      case DateDropJourneyStage.understanding:
        return '看共同点、节奏和边界。';
      case DateDropJourneyStage.chatPrep:
        return '开场参考可编辑，不自动发送。';
      case DateDropJourneyStage.feedback:
        return '反馈只帮助后续方向。';
      case DateDropJourneyStage.nextRound:
        return '整理感受，再进入下一轮。';
    }
  }

  List<_DateDropStep> get _steps {
    return const [
      _DateDropStep(
        stage: DateDropJourneyStage.preparing,
        title: '准备',
        body: '确认展示自己和表达线索，让别人更容易理解你。',
        icon: Icons.fact_check_outlined,
      ),
      _DateDropStep(
        stage: DateDropJourneyStage.waiting,
        title: '等待',
        body: '看清本轮状态。',
        icon: Icons.hourglass_bottom_rounded,
      ),
      _DateDropStep(
        stage: DateDropJourneyStage.reveal,
        title: '揭晓',
        body: '先看这个人为什么值得了解。',
        icon: Icons.auto_awesome_rounded,
      ),
      _DateDropStep(
        stage: DateDropJourneyStage.understanding,
        title: '理解',
        body: '读共同点和边界。',
        icon: Icons.psychology_alt_outlined,
      ),
      _DateDropStep(
        stage: DateDropJourneyStage.chatPrep,
        title: '低压开场',
        body: '草稿可改，不代发。',
        icon: Icons.forum_outlined,
      ),
      _DateDropStep(
        stage: DateDropJourneyStage.feedback,
        title: '反馈',
        body: '表达感受。',
        icon: Icons.tune_rounded,
      ),
      _DateDropStep(
        stage: DateDropJourneyStage.nextRound,
        title: '下一轮',
        body: '慢一点继续。',
        icon: Icons.next_plan_outlined,
      ),
    ];
  }

  _DateDropStep get _activeStep =>
      _steps.firstWhere((item) => item.stage == stage);

  _DateDropStep? get _nextStep {
    final nextIndex = stage.index + 1;
    if (nextIndex >= _steps.length) return null;
    return _steps[nextIndex];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = switch (stage) {
      DateDropJourneyStage.waiting => t.brandPrimary,
      DateDropJourneyStage.preparing => t.brandPrimary,
      DateDropJourneyStage.reveal => t.success,
      DateDropJourneyStage.understanding => t.success,
      DateDropJourneyStage.chatPrep => t.info,
      DateDropJourneyStage.feedback => t.warning,
      DateDropJourneyStage.nextRound => t.warning,
    };

    return AppCard(
      padding: EdgeInsets.all(
        compact ? t.spacing.cardPadding : t.spacing.cardPaddingLarge,
      ),
      border: Border.all(color: accent.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(19),
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
                        const AppChoiceChip(label: '低频高质量', selected: true),
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
          SizedBox(height: compact ? t.spacing.sm : t.spacing.md),
          compact
              ? _CompactJourneyStage(stage: _activeStep, next: _nextStep)
              : _JourneyStepRail(steps: _steps, stage: stage),
          SizedBox(height: t.spacing.sm),
          Text(
            compact
                ? '路径卡：只说明本阶段在慢约会主链里的位置，不触发自动发送或资料改写。'
                : '路径卡：说明慢约会从准备、等待、揭晓、理解、低压开场、反馈到下一轮的主链；不写资料或星盘真值、不替对方打分、不自动发送聊天消息。',
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

class _JourneyStepRail extends StatelessWidget {
  const _JourneyStepRail({required this.steps, required this.stage});

  final List<_DateDropStep> steps;
  final DateDropJourneyStage stage;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final cards = steps
            .map(
              (item) => _DateDropStepTile(
                item: item,
                active: item.stage == stage,
                done: item.stage.index < stage.index,
              ),
            )
            .toList();
        if (narrow) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  SizedBox(width: 112, child: cards[i]),
                  if (i != cards.length - 1) SizedBox(width: t.spacing.xs),
                ],
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) SizedBox(width: t.spacing.xs),
            ],
          ],
        );
      },
    );
  }
}

class _CompactJourneyStage extends StatelessWidget {
  const _CompactJourneyStage({required this.stage, required this.next});

  final _DateDropStep stage;
  final _DateDropStep? next;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseChip.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder.withValues(alpha: 0.72)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stage.icon, size: 18, color: t.brandPrimary),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Text(
              next == null
                  ? '当前阶段：${stage.stage.title}。${stage.body}'
                  : '当前阶段：${stage.stage.title}。${stage.body}\n下一步：${next!.stage.title}。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDropStep {
  const _DateDropStep({
    required this.stage,
    required this.title,
    required this.body,
    required this.icon,
  });

  final DateDropJourneyStage stage;
  final String title;
  final String body;
  final IconData icon;
}

class _DateDropStepTile extends StatelessWidget {
  const _DateDropStepTile({
    required this.item,
    required this.active,
    required this.done,
  });

  final _DateDropStep item;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final color = active
        ? t.brandPrimary
        : done
        ? t.success
        : t.textSecondary;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: active
            ? t.brandPrimary.withValues(alpha: 0.08)
            : t.browseChip.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(
          color: color.withValues(alpha: active || done ? 0.24 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done ? Icons.check_circle_outline_rounded : item.icon,
                size: 17,
                color: color,
              ),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
