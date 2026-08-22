import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroAdvancedExplanationLayerCard extends StatelessWidget {
  const AstroAdvancedExplanationLayerCard({super.key, required this.bundle});

  final AstroAdvancedPreviewBundle bundle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final entries = bundle.items
        .expand((item) => item.buildExplainabilityEntries())
        .toList(growable: false);

    return AppInfoSectionCard(
      title: '样例怎样拆开看',
      subtitle: '先看摘要，再看具体线索与时间提示',
      leadingIcon: Icons.notes_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '这一层不再只给整段摘要，而是把互动角度、点位和关联关系拆成可浏览的条目。所有内容仍只作为展示参考与关系说明，不会影响你已保存的星盘信息。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '每张卡片都按“样例线索 -> 解释 -> 提示”组织，方便逐项理解不同路线的关注角度；这些样例不是你的个人结论。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _LayerSection(
            title: '先看摘要',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bundle.items
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.xs),
                      child: _SummaryTile(item: item),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _LayerSection(
            title: '再看具体线索',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.xs),
                      child: _ExplainabilityEntryTile(entry: entry),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _LayerSection(
            title: '时间与关系提示',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimingAssociationTile(
                  title: '年度视角样例',
                  summary: _ordinaryAdvancedTimingCopy(
                    bundle.timing.formalSignal.summary,
                  ),
                  accent: const Color(0xFF4BCB92),
                  badges: const ['样例', '年度视角'],
                ),
                SizedBox(height: t.spacing.xs),
                _TimingAssociationTile(
                  title: '主时段示意',
                  summary: _ordinaryAdvancedTimingCopy(
                    bundle.timing.placeholderSignal.summary,
                  ),
                  accent: const Color(0xFFF5A623),
                  badges: const ['示意', '主时段'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _ordinaryAdvancedTimingCopy(String text) => text
    .replaceAllMapped(
      RegExp(r'(^|[^A-Za-z0-9_])EliteSync(?=$|[^A-Za-z0-9_])'),
      (match) => '${match[1]}示例人物',
    )
    .replaceAll('接入位', '展示位置')
    .replaceAll('待接入', '暂无个人内容')
    .replaceAll('占位', '示意')
    .replaceAll('容器', '样例')
    .replaceAll('回写', '影响');

String _ordinaryLayerLabel(String label) => switch (label) {
  '互动角度级' => '关系线索',
  '点位级' => '主要对象',
  _ => '时间与关系',
};

String _ordinaryExplainabilityCopy(String text) => text
    .replaceAllMapped(
      RegExp(r'(^|[^A-Za-z0-9_])EliteSync(?=$|[^A-Za-z0-9_])'),
      (match) => '${match[1]}示例人物',
    )
    .replaceAll('互动角度条目', '关系线索')
    .replaceAll('点位条目', '主要对象')
    .replaceAll('关联条目', '时间与关系提示')
    .replaceAll('互动角度级', '关系线索')
    .replaceAll('点位级', '主要对象')
    .replaceAll('高级时法关联层', '时间与关系提示')
    .replaceAll('首轮解释', '阅读说明')
    .replaceAll('继续挂接', '继续补充')
    .replaceAll('挂接', '补充')
    .replaceAll('上下文锚点', '阅读依据')
    .replaceAll('当前窗口与显示层关联', '当前时间范围')
    .replaceAll('新的结论层', '个人结论')
    .replaceAll('回写本命盘主结构', '改变已保存的星盘记录')
    .replaceAll('回写', '影响');

class _LayerSection extends StatelessWidget {
  const _LayerSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: t.spacing.xs),
        child,
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item});

  final AstroAdvancedPreviewItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF5AA8FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(
          color: const Color(0xFF5AA8FF).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5AA8FF),
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            _ordinarySampleIdentityCopy(item.summary),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: item.routeLabel, color: const Color(0xFF5AA8FF)),
              AstroPill(label: item.modeLabel, color: const Color(0xFF5AA8FF)),
              AstroPill(
                label: item.metricsLabel,
                color: const Color(0xFF5AA8FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _ordinarySampleIdentityCopy(String text) => text.replaceAllMapped(
  RegExp(r'(^|[^A-Za-z0-9_])EliteSync(?=$|[^A-Za-z0-9_])'),
  (match) => '${match[1]}示例人物',
);

class _ExplainabilityEntryTile extends StatelessWidget {
  const _ExplainabilityEntryTile({required this.entry});

  final AstroExplainabilityEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = switch (entry.layerLabel) {
      '互动角度级' => const Color(0xFF5AA8FF),
      '点位级' => const Color(0xFF8F7BFF),
      _ => const Color(0xFF4BCB92),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _ordinaryExplainabilityCopy(entry.title),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              Text(
                _ordinaryLayerLabel(entry.layerLabel),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            _ordinaryExplainabilityCopy(entry.summary),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            _ordinaryExplainabilityCopy(entry.detail),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          if (entry.badges.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: entry.badges
                  .map(
                    (badge) => AstroPill(
                      label: _ordinaryExplainabilityCopy(badge),
                      color: accent,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimingAssociationTile extends StatelessWidget {
  const _TimingAssociationTile({
    required this.title,
    required this.summary,
    required this.accent,
    required this.badges,
  });

  final String title;
  final String summary;
  final Color accent;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          if (badges.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: badges
                  .map((badge) => AstroPill(label: badge, color: accent))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
