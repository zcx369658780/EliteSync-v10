import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({super.key, required this.completion});
  final double completion;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final value = completion.clamp(0, 1).toDouble();
    final ready = value >= 0.7;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '资料准备状态',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: value),
          const SizedBox(height: 6),
          Text(
            ready ? '已具备基础理解线索' : '继续补充会让表达建议更贴近你',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
