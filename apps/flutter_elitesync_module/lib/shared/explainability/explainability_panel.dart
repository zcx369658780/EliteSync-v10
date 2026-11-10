import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/explainability/explainability_contract.dart';

class ExplainabilityPanel extends StatelessWidget {
  const ExplainabilityPanel({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final ExplainabilityContent content;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sections = <(String, String)>[
      ('发生了什么', content.whatHappened),
      ('为什么', content.why),
      ('使用的信息类别', content.informationClasses.join('、')),
      ('不代表什么', content.doesNotMean),
      ('不确定性与限制', content.uncertaintyAndLimits),
      ('你可以做什么', content.userControls.join('、')),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          for (final section in sections) ...[
            Text(
              section.$1,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: t.spacing.xxs),
            Text(
              section.$2,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
            if (section != sections.last) SizedBox(height: t.spacing.sm),
          ],
        ],
      ),
    );
  }
}
