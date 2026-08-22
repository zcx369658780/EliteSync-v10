import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroTimingFrameworkCard extends StatelessWidget {
  const AstroTimingFrameworkCard({super.key, required this.bundle});

  final AstroTimingFrameworkBundle bundle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      title: '时间视角样例',
      subtitle: '年度视角 / 主时段示意 / 使用边界',
      leadingIcon: Icons.schedule_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '这里用年度视角和主时段示意帮助你理解时间线索。主时段内容仍是样例，不是你的最终结论，也不会影响你已保存的星盘信息。',
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
              AstroPill(label: '路线：${_routeModeLabel(bundle.routeMode)}'),
              const AstroPill(label: '年度视角：样例'),
              const AstroPill(label: '主时段：示意'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          _TimingSignalTile(
            title: '年度视角样例',
            signal: bundle.formalSignal,
            accent: const Color(0xFF4BCB92),
          ),
          SizedBox(height: t.spacing.sm),
          _TimingSignalTile(
            title: '主时段示意',
            signal: bundle.placeholderSignal,
            accent: const Color(0xFFF5A623),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '使用情境样例',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: t.spacing.xs),
          ...bundle.sampleCases.map(
            (sampleCase) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _TimingCaseTile(sampleCase: sampleCase),
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '阅读边界',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: t.spacing.xs),
          ...bundle.knownDeviations.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Text(
                '• ${_ordinaryTimingCopy(item)}',
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

class _TimingSignalTile extends StatelessWidget {
  const _TimingSignalTile({
    required this.title,
    required this.signal,
    required this.accent,
  });

  final String title;
  final AstroTimingSignal signal;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                signal.isFormal ? '年度样例' : '主时段示意',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            _ordinaryTimingCopy(signal.summary),
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
              _pill(signal.isFormal ? '样例' : '示意', accent),
              _pill('范围：${signal.scopeLabel}', accent),
              _pill('时间：${_ordinaryTimingCopy(signal.windowLabel)}', accent),
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

class _TimingCaseTile extends StatelessWidget {
  const _TimingCaseTile({required this.sampleCase});

  final AstroTimingSampleCase sampleCase;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scheme = Theme.of(context).colorScheme;
    final accent = sampleCase.isEdgeCase ? scheme.error : scheme.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sampleCase.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                sampleCase.isEdgeCase ? '边界' : '常规',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            _ordinaryTimingCopy(sampleCase.subtitle),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: sampleCase.signals
                .map(
                  (signal) =>
                      _pill(signal.isFormal ? '年度视角样例' : '主时段示意', accent),
                )
                .toList(),
          ),
          SizedBox(height: t.spacing.xs),
          ...sampleCase.notes.map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Text(
                '• ${_ordinaryTimingCopy(note)}',
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

String _ordinaryTimingCopy(String text) => text
    .replaceAllMapped(
      RegExp(r'(^|[^A-Za-z0-9_])EliteSync(?=$|[^A-Za-z0-9_])'),
      (match) => '${match[1]}示例人物',
    )
    .replaceAll('用于验证时法容器是否可读、可审查、可归档。', '用于帮助理解时法样例的结构与阅读顺序。')
    .replaceAll('用于验证多层展示时的卡片密度、排序与命名是否稳定。', '用于比较多层样例的阅读顺序与名称差异。')
    .replaceAll('第二个正式时法能力', '更多时间视角样例')
    .replaceAll('正式能力', '年度样例')
    .replaceAll('占位能力', '示意内容')
    .replaceAll('主时段占位', '主时段示意')
    .replaceAll('接入位', '展示位置')
    .replaceAll('占位', '示意')
    .replaceAll('待接入', '暂无个人内容')
    .replaceAll('正式接入', '提供个人内容')
    .replaceAll('挂接式扩展', '补充说明')
    .replaceAll('已完成算法', '个人结论')
    .replaceAll('容器', '样例')
    .replaceAll('回写', '影响');

String _routeModeLabel(AstroChartRouteMode mode) => switch (mode) {
  AstroChartRouteMode.standard => '标准路线',
  AstroChartRouteMode.classical => '古典路线',
  AstroChartRouteMode.modern => '现代路线',
};
