import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';

class AstroAdvancedSampleSetReport {
  const AstroAdvancedSampleSetReport({
    required this.relationshipSamples,
    required this.timeSamples,
    required this.knownDeviations,
  });

  final List<AstroAdvancedPreviewItem> relationshipSamples;
  final List<AstroAdvancedPreviewItem> timeSamples;
  final List<String> knownDeviations;

  List<String> toMarkdownLines() => [
    '# 3.9 高级样例集',
    '- 报告性质：展示参考 / 不改写已保存记录',
    '- 关系样例数：${relationshipSamples.length}',
    '- 时间样例数：${timeSamples.length}',
    '- 已知偏差数：${knownDeviations.length}',
    ...relationshipSamples.map(
      (item) => '- 关系样例：${item.title} / ${item.summary}',
    ),
    ...timeSamples.map((item) => '- 时间样例：${item.title} / ${item.summary}'),
    ...knownDeviations.map((item) => '- 已知偏差：$item'),
  ];
}

AstroAdvancedSampleSetReport buildAstroAdvancedSampleSetReport(
  AstroAdvancedPreviewBundle bundle,
) {
  return AstroAdvancedSampleSetReport(
    relationshipSamples: [bundle.pair, bundle.comparison],
    timeSamples: [bundle.transit, bundle.returnChart],
    knownDeviations: [
      '合盘与对比盘的样例仅作对照预览，关系提示可能在对比模式下为空或弱化。',
      '行运与返照都保持关联说明，不回写已保存的星盘记录；返回结构更强调解释层而非结果层。',
      '返照优先使用 Lunar 回归口径，若未来扩展 Solar 仍应单独注明。',
    ],
  );
}

class AstroAdvancedSampleSetCard extends StatelessWidget {
  const AstroAdvancedSampleSetCard({super.key, required this.bundle});

  final AstroAdvancedPreviewBundle bundle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final report = buildAstroAdvancedSampleSetReport(bundle);

    return AppInfoSectionCard(
      title: '关系与时间样例',
      subtitle: '比较不同样例，并了解阅读边界',
      leadingIcon: Icons.view_list_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '高级样例矩阵把合盘、对比盘、行运、返照和时法放在一起，方便你比较不同样例的关注角度与已知偏差。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _SectionLabel(text: '关系样例'),
          SizedBox(height: t.spacing.xs),
          ...report.relationshipSamples.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _SampleTile(item: item, accent: const Color(0xFF5AA8FF)),
            ),
          ),
          SizedBox(height: t.spacing.xs),
          _SectionLabel(text: '时间样例'),
          SizedBox(height: t.spacing.xs),
          ...report.timeSamples.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _SampleTile(item: item, accent: const Color(0xFF4BCB92)),
            ),
          ),
          SizedBox(height: t.spacing.xs),
          _SectionLabel(text: '阅读边界'),
          SizedBox(height: t.spacing.xs),
          ...report.knownDeviations.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Text(
                '• ${_ordinaryKnownDeviationCopy(item)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _ordinaryKnownDeviationCopy(String text) =>
    text.replaceAll('不回写已保存的星盘记录', '不会影响你已保存的星盘信息').replaceAll('回写', '影响');

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _SampleTile extends StatelessWidget {
  const _SampleTile({required this.item, required this.accent});

  final AstroAdvancedPreviewItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                item.modeLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            _ordinarySampleIdentityCopy(item.summary),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              _pill('路线：${item.routeLabel}', accent),
              _pill('参考类型：${item.chartKindLabel}', accent),
              _pill(
                '点位：${item.primaryPointCount}/${item.secondaryPointCount}',
                accent,
              ),
              _pill('关系线索：${item.aspectCount}', accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _ordinarySampleIdentityCopy(String text) => text.replaceAllMapped(
  RegExp(r'(^|[^A-Za-z0-9_])EliteSync(?=$|[^A-Za-z0-9_])'),
  (match) => '${match[1]}示例人物',
);

class AstroAdvancedSampleSetView extends ConsumerWidget {
  const AstroAdvancedSampleSetView({super.key, required this.bundle});

  final AstroAdvancedPreviewBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AstroAdvancedSampleSetCard(bundle: bundle);
  }
}
