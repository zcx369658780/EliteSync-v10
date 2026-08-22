import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchWeightBreakdown extends StatelessWidget {
  const MatchWeightBreakdown({super.key, required this.weights});
  final Map<String, int> weights;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sorted = weights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '解释线索',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '这些线索只帮助你理解推荐理由，不代表关系结论，也不会立刻改变后续推荐。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          if (sorted.isEmpty)
            Text(
              '暂无可展示的解释线索',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
            ),
          ...sorted.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(t.spacing.sm),
                decoration: BoxDecoration(
                  color: t.browseChip.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(t.radius.md),
                  border: Border.all(color: t.browseBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: t.brandPrimary,
                    ),
                    SizedBox(width: t.spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.key,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          Text(
                            '可作为了解顺序的一个参考，仍需要结合对方真实表达慢慢判断。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
