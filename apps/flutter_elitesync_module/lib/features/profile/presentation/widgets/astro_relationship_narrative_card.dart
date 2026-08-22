import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AstroRelationshipNarrativeCard extends StatelessWidget {
  const AstroRelationshipNarrativeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.leadingText,
    required this.emphasisText,
    required this.trailingText,
    this.boundaryText = '仅作关系理解辅助；不改写资料、星盘记录或匹配算法。',
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String leadingText;
  final String emphasisText;
  final String trailingText;
  final String boundaryText;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: t.textPrimary,
      height: 1.55,
      fontWeight: FontWeight.w600,
    );
    return AppInfoSectionCard(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: bodyStyle,
              children: [
                TextSpan(text: leadingText),
                TextSpan(
                  text: emphasisText,
                  style: bodyStyle?.copyWith(
                    color: t.brandPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(text: trailingText),
              ],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            boundaryText,
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
