import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class A5UnderstandingDimension {
  const A5UnderstandingDimension({
    required this.title,
    required this.body,
    this.label,
  });

  final String title;
  final String body;
  final String? label;
}

class A5RelationshipUnderstandingCard extends StatelessWidget {
  const A5RelationshipUnderstandingCard({
    super.key,
    this.title = '我的慢约会理解卡',
    this.subtitle = '摘要 / 维度 / 建议 / 避免，帮助理解关系与表达节奏',
    this.icon = Icons.auto_awesome_outlined,
    required this.summary,
    required this.dimensions,
    required this.suggestions,
    required this.avoidances,
    this.footer,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String summary;
  final List<A5UnderstandingDimension> dimensions;
  final List<String> suggestions;
  final List<String> avoidances;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _A5SectionLabel(text: '摘要'),
          SizedBox(height: t.spacing.xxs),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _A5SectionLabel(text: '维度'),
          SizedBox(height: t.spacing.xs),
          for (final dimension in dimensions) ...[
            _A5DimensionRow(dimension: dimension),
            SizedBox(height: t.spacing.xs),
          ],
          SizedBox(height: t.spacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 420;
              final children = [
                _A5AdviceBlock(
                  title: '建议',
                  icon: Icons.lightbulb_outline_rounded,
                  items: suggestions,
                ),
                _A5AdviceBlock(
                  title: '先避免',
                  icon: Icons.do_not_disturb_on_outlined,
                  items: avoidances,
                ),
              ];
              if (narrow) {
                return Column(
                  children: [
                    children[0],
                    SizedBox(height: t.spacing.xs),
                    children[1],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  SizedBox(width: t.spacing.sm),
                  Expanded(child: children[1]),
                ],
              );
            },
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            footer ?? '这些内容仅为关系理解辅助，不会写入资料、星盘记录或匹配算法，也不会替你做决定。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _A5SectionLabel extends StatelessWidget {
  const _A5SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: t.brandPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _A5DimensionRow extends StatelessWidget {
  const _A5DimensionRow({required this.dimension});

  final A5UnderstandingDimension dimension;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 18, color: t.brandPrimary),
        SizedBox(width: t.spacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xxs,
                children: [
                  Text(
                    dimension.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((dimension.label ?? '').trim().isNotEmpty)
                    Text(
                      dimension.label!.trim(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.brandPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                dimension.body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _A5AdviceBlock extends StatelessWidget {
  const _A5AdviceBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.secondarySurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: t.brandPrimary),
              SizedBox(width: t.spacing.xxs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          for (final item in items.take(3)) ...[
            Text(
              item,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.35,
              ),
            ),
            SizedBox(height: t.spacing.xxs),
          ],
        ],
      ),
    );
  }
}
