import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchHeroSummaryCard extends StatelessWidget {
  const MatchHeroSummaryCard({
    super.key,
    required this.headline,
    required this.score,
    required this.tags,
  });

  final String headline;
  final int score;
  final List<String> tags;

  Color _signalColor(BuildContext context) {
    final t = context.appTokens;
    if (score >= 85) return t.success;
    if (score >= 70) return t.brandPrimary;
    if (score >= 55) return t.warning;
    return t.error;
  }

  String _signalNarrative() {
    if (score >= 85) return '这轮有较多可继续了解的线索，建议先读理由，再慢慢开场。';
    if (score >= 70) return '这轮有一些值得理解的共同点，适合从轻话题慢慢建立连接。';
    if (score >= 55) return '这轮更适合先观察沟通节奏，不急着做关系判断。';
    return '当前线索较少，建议先看边界说明，再决定是否继续。';
  }

  List<String> _safeTags() {
    return tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) {
          if (tag.contains('高匹配') || tag.contains('匹配分')) {
            return '关系线索';
          }
          return tag;
        })
        .toSet()
        .take(4)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final signalColor = _signalColor(context);
    final safeTags = _safeTags();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.brandPrimary.withValues(alpha: 0.2),
            t.brandSecondary.withValues(alpha: 0.16),
            t.brandAccent.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: t.browseBorder),
      ),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本轮慢约会已揭晓',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            headline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            _signalNarrative(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: signalColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(t.radius.pill),
              border: Border.all(color: signalColor.withValues(alpha: 0.18)),
            ),
            child: Text(
              '先理解，再决定',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: signalColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (safeTags.isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: safeTags.map((tag) {
                return AppTag(label: tag, variant: AppTagVariant.outlined);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
