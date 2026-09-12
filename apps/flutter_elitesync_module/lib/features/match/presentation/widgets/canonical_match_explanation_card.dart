import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/canonical_match_lifecycle.dart';

class CanonicalMatchExplanationCard extends StatelessWidget {
  const CanonicalMatchExplanationCard({super.key, required this.snapshot});

  final CanonicalMatchLifecycleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final stateLabel = snapshot.targetState?.code ?? '目标生命周期状态尚未建立';

    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前状态说明',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stateLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: t.brandPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const _ExplanationLine(text: '匹配只呈现当前轮次的有限信息，不存在一个权威的兼容性总分。'),
          const _ExplanationLine(
            text: '系统或 AI 输出是辅助判断，不是经验证的关系事实，也不证明安全、可信或适合建立关系。',
          ),
          const _ExplanationLine(
            text: '匹配不会自动创建 Connection，也不会授权或打开 Conversation。',
          ),
          const _ExplanationLine(
            text: '加入、暂停、恢复、退出、拒绝、表达兴趣、互相确认和过期操作尚未接入权威目标状态。',
          ),
          const _ExplanationLine(text: '信息可能有限或仍在更新；没有轮次或候选提案是可用性状态，不代表拒绝或失败。'),
        ],
      ),
    );
  }
}

class _ExplanationLine extends StatelessWidget {
  const _ExplanationLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: t.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
