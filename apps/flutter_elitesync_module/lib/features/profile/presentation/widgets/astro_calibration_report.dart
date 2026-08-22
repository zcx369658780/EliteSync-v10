import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_sample_set.dart';

class AstroCalibrationReportData {
  const AstroCalibrationReportData({
    required this.sampleSet,
    required this.knownDeviations,
  });

  final AstroRouteSampleSetReport sampleSet;
  final List<String> knownDeviations;

  List<String> toMarkdownLines() {
    final lines = <String>[
      '# 3.8 校准报告',
      '- 报告性质：展示参考 / 不改写已保存记录',
      '- 用途：参考样例校准、偏差归档、回归锚点',
      '- 样例数量：${sampleSet.entries.length}',
      '- 说明：以下差异只用于校准与归档，不回写已保存的星盘记录。',
      '',
    ];
    for (final entry in sampleSet.entries) {
      lines.addAll(entry.toMarkdownLines());
      lines.add('');
    }
    lines.add('- 已知偏差：');
    lines.addAll(knownDeviations.map((item) => '- $item'));
    return lines;
  }
}

AstroCalibrationReportData buildAstroCalibrationReport() {
  final sampleSet = buildAstroRouteSampleSetReport();
  return AstroCalibrationReportData(
    sampleSet: sampleSet,
    knownDeviations: [
      '基线样例与现代扩展样例的差异主要来自路线模板与样例密度，不应误判为已保存星盘记录被改写。',
      '古典路线收紧到核心点位与主要互动角度，现代路线保留扩展关系线索，这属于预期的展示差异。',
      '校准报告目前只作为展示参考和偏差归档，不作为新的资料来源。',
    ],
  );
}

class AstroCalibrationReportCard extends StatelessWidget {
  const AstroCalibrationReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final report = buildAstroCalibrationReport();
    return AppInfoSectionCard(
      title: '校准样例',
      subtitle: '参考样例 / 偏差归档 / 回归锚点',
      leadingIcon: Icons.science_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前把基线样例与现代扩展样例两组参考样例固定下来，便于后续重复复核点位与关系线索差异。这里记录的是校准与偏差归档，不是新的算法来源。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: '样例数：${report.sampleSet.entries.length}'),
              const AstroPill(label: '基线：基线样例'),
              const AstroPill(label: '扩展：现代扩展样例'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          ...report.sampleSet.entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _CalibrationTile(entry: entry),
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '已知偏差',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: t.spacing.xs),
          ...report.knownDeviations.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Text(
                '• $item',
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

class _CalibrationTile extends StatelessWidget {
  const _CalibrationTile({required this.entry});

  final AstroRouteSampleSetEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final standard = entry.standardSummary;
    final classical = entry.classicalSummary;
    final modern = entry.modernSummary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.variant.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '标准 ${standard.visiblePointCount}/${standard.visibleAspectCount} · '
            '古典 ${classical.visiblePointCount}/${classical.visibleAspectCount} · '
            '现代 ${modern.visiblePointCount}/${modern.visibleAspectCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(
                label:
                    '古典差异：${_signed(entry.standardVsClassical.pointDelta)} 点位 / ${_signed(entry.standardVsClassical.aspectDelta)} 关系线索',
              ),
              AstroPill(
                label:
                    '现代差异：${_signed(entry.standardVsModern.pointDelta)} 点位 / ${_signed(entry.standardVsModern.aspectDelta)} 关系线索',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _signed(int value) => value > 0 ? '+$value' : value.toString();
