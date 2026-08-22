import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_relationship_narrative_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_chart_svg_builder.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_chart_svg_card.dart';

class AstroNatalChartPage extends ConsumerWidget {
  const AstroNatalChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroNatalChartProvider);
    final routePrefs = ref.watch(astroChartRouteProvider);
    final chartPrefs = ref.watch(astroChartSettingsProvider);
    final workbenchPrefs = ref.watch(astroChartWorkbenchProvider);
    final sectionGap = chartPrefs.compactDensity ? t.spacing.xxs : t.spacing.sm;

    Future<void> reloadAstro() async {
      ref.invalidate(astroNatalChartProvider);
      try {
        await ref.read(astroNatalChartProvider.future);
      } catch (_) {
        // Error state is rendered below.
      }
    }

    return AppScaffold(
      appBar: AppTopBar(
        title: "本命盘详情",
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '盘面设置',
            onPressed: () => context.push(AppRouteNames.astroChartSettings),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: AstroDetailScopeHint(
                key: ValueKey('western-natal-detail-scope-hint'),
                text: '先看盘面，再读关系理解辅助',
                icon: Icons.public_rounded,
              ),
            ),
            SizedBox(
              height: chartPrefs.compactDensity ? t.spacing.xs : t.spacing.md,
            ),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('星盘')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('星盘', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('星盘');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: reloadAstro,
                  );
                }

                final trueSolarTime = astroText(profile['true_solar_time']);
                final birthTime = astroText(profile['birth_time']);
                final birthPlace = astroText(
                  profile['birth_place'] ?? profile['private_birth_place'],
                );
                final locationShift =
                    astroDouble(profile['location_shift_minutes']) ?? 0;
                final longitudeOffset =
                    astroDouble(profile['longitude_offset_minutes']) ?? 0;
                final equationOfTime =
                    astroDouble(profile['equation_of_time_minutes']) ?? 0;
                final locationSource = _locationSourceLabel(
                  astroText(profile['location_source'], 'unknown'),
                );
                final westernEngine = _westernEngineLabel(
                  astroText(profile['western_engine'], 'legacy_input'),
                );
                final westernPrecision = _westernPrecisionLabel(
                  astroText(profile['western_precision'], 'legacy_estimate'),
                );
                final westernConfidence = _westernConfidenceLabel(
                  astroText(profile['western_confidence'], '0.0'),
                );
                final notes = _displayNotes(astroList(profile['notes']));
                final svg = buildNatalChartSvgFromProfile(
                  profile,
                  prefs: chartPrefs,
                  workbenchPrefs: workbenchPrefs,
                );
                final planets = _mapList(profile['planets_data']);
                final houses = _mapList(profile['houses_data']);
                final aspects = _mapList(profile['aspects_data']);
                final houseTruthStatus = _profileText(profile, const [
                  ['house_truth_status'],
                  ['metadata', 'house_truth_status'],
                  ['metadata', 'provenance', 'house_truth_status'],
                  ['chart_data', 'metadata', 'house_truth_status'],
                  [
                    'chart_data',
                    'metadata',
                    'provenance',
                    'house_truth_status',
                  ],
                ], fallback: 'unknown');
                final externalOracleStatus = _profileText(profile, const [
                  ['external_oracle_status'],
                  ['metadata', 'external_oracle_status'],
                  ['metadata', 'provenance', 'external_oracle_status'],
                  ['chart_data', 'metadata', 'external_oracle_status'],
                  [
                    'chart_data',
                    'metadata',
                    'provenance',
                    'external_oracle_status',
                  ],
                ], fallback: 'unknown');
                final policy = _firstProfileMap(profile, const [
                  ['western_natal_policy'],
                  ['metadata', 'western_natal_policy'],
                  ['metadata', 'provenance', 'western_natal_policy'],
                  ['chart_data', 'western_natal_policy'],
                  ['chart_data', 'metadata', 'western_natal_policy'],
                  ['chart_data', 'metadata', 'provenance'],
                ]);
                final houseTruthDisplayable = _isHouseTruthDisplayable(
                  houseTruthStatus,
                );

                return Column(
                  children: [
                    NatalChartSvgCard(
                      key: const ValueKey('western-natal-chart-first-svg'),
                      svg: svg,
                    ),
                    SizedBox(height: sectionGap),
                    const AstroRelationshipNarrativeCard(
                      key: ValueKey('western-natal-readable-narrative'),
                      title: '西洋本命盘阅读引导',
                      subtitle: '一句话理解沟通风格',
                      icon: Icons.public_rounded,
                      leadingText: '把这张本命盘先当作',
                      emphasisText: '沟通风格地图',
                      trailingText: '：看表达、情绪节奏和互动切入点，用来更温和地开口，不替你判断关系结论或匹配结果。',
                    ),
                    SizedBox(height: sectionGap),
                    AstroSectionCard(
                      key: const ValueKey('western-natal-compact-provenance'),
                      title: '来源摘要',
                      subtitle: '已保存资料用于盘面，本机仅调整显示路线',
                      icon: Icons.verified_user_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前使用已保存本命盘资料，本机仅调整显示路线；不会改写资料或匹配结果。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Wrap(
                            spacing: t.spacing.xs,
                            runSpacing: t.spacing.xs,
                            children: [
                              AstroPill(
                                label:
                                    '保存黄道：${_backendZodiacPolicyLabel(policy)}',
                              ),
                              AstroPill(
                                label:
                                    '保存宫位：${_backendHousePolicyLabel(policy)}',
                              ),
                              AstroPill(
                                label:
                                    '外部对照：${_externalOracleStatusLabel(externalOracleStatus)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    AstroDisclosureCard(
                      key: const ValueKey(
                        'western-natal-source-display-details',
                      ),
                      title: '来源与显示详情',
                      subtitle: '展开查看保存口径、来源状态与本机绘制说明',
                      icon: Icons.verified_user_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '已保存星盘来源',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.xs),
                          Text(
                            '已保存星盘口径：${_backendZodiacPolicyLabel(policy)} / ${_backendHousePolicyLabel(policy)}。外部对照：${_externalOracleStatusLabel(externalOracleStatus)}。本页不改变资料或匹配算法。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Wrap(
                            spacing: t.spacing.xs,
                            runSpacing: t.spacing.xs,
                            children: [
                              AstroPill(
                                label:
                                    '保存黄道：${_backendZodiacPolicyLabel(policy)}',
                              ),
                              AstroPill(
                                label:
                                    '保存宫位：${_backendHousePolicyLabel(policy)}',
                              ),
                              AstroPill(
                                label:
                                    '外部对照：${_externalOracleStatusLabel(externalOracleStatus)}',
                              ),
                              ..._policyPills(policy),
                            ],
                          ),
                          SizedBox(height: t.spacing.md),
                          Text(
                            '星盘来源状态',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.xs),
                          Text(
                            _sourceStatusMessage(
                              houseTruthStatus,
                              externalOracleStatus,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Wrap(
                            spacing: t.spacing.xs,
                            runSpacing: t.spacing.xs,
                            children: [
                              AstroPill(
                                label:
                                    '宫位状态：${_houseTruthStatusLabel(houseTruthStatus)}',
                              ),
                              AstroPill(
                                label:
                                    '外部对照：${_externalOracleStatusLabel(externalOracleStatus)}',
                              ),
                            ],
                          ),
                          SizedBox(height: t.spacing.md),
                          Text(
                            '本机绘制',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.xs),
                          Text(
                            '当前页面使用已保存星盘资料在本机绘制星盘，不再依赖服务端输出图像。出生时间和出生地需要到编辑资料页修改；保存后，本页会重新读取最新结果并渲染盘面。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  context.push(AppRouteNames.editProfile),
                              icon: const Icon(Icons.edit_location_alt_rounded),
                              label: const Text('编辑出生资料'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    if (chartPrefs.showPlanetSummary) ...[
                      AstroDisclosureCard(
                        key: const ValueKey(
                          'western-natal-planet-placement-details',
                        ),
                        title: '行星与落宫明细',
                        subtitle: houseTruthDisplayable
                            ? '展开查看已保存字段，不从太阳/月亮/上升摘要推断'
                            : '宫位结果待出生地坐标或星盘来源校验后确认',
                        icon: Icons.public_rounded,
                        child: _StructuredFactList(
                          items: planets
                              .take(12)
                              .map((row) {
                                final name = astroText(
                                  row['name'],
                                  astroText(row['key'], '-'),
                                );
                                final sign = _displayZodiacSignLabel(
                                  row['sign'],
                                );
                                final position = _displayDegreeLabel(
                                  row['position'],
                                );
                                final houseLabel = _planetHouseLabel(
                                  row['house'],
                                  houseTruthStatus,
                                );
                                return _FactRowItem(
                                  icon: _planetGlyph(name),
                                  title: name,
                                  value: position,
                                  subtitle: '$sign / $houseLabel',
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    if (chartPrefs.showHouseSummary && houses.isNotEmpty) ...[
                      AstroSectionCard(
                        title: '宫位摘要',
                        subtitle: '按列表查看宫位与星座归属',
                        icon: Icons.view_column_rounded,
                        child: _StructuredFactList(
                          items: houses
                              .take(12)
                              .map((row) {
                                final name = _displayHouseLabel(
                                  row['name'],
                                  fallback: '${astroText(row['index'], '-')}宫',
                                );
                                final sign = _displayZodiacSignLabel(
                                  row['sign'],
                                );
                                final position = _displayDegreeLabel(
                                  row['position'],
                                );
                                return _FactRowItem(
                                  icon: _zodiacGlyph(sign),
                                  title: name,
                                  value: position,
                                  subtitle: sign,
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    if (chartPrefs.showAspectSummary && aspects.isNotEmpty) ...[
                      AstroSectionCard(
                        title: '互动角度摘要',
                        subtitle: '只把盘面角度转成可读标签，不判断关系结果',
                        icon: Icons.share_outlined,
                        child: Column(
                          children: aspects
                              .take(8)
                              .map((row) {
                                final p1 = _displayAstroPointLabel(
                                  row['p1_name'],
                                );
                                final p2 = _displayAstroPointLabel(
                                  row['p2_name'],
                                );
                                final aspect = _displayAspectLabel(
                                  row['aspect'],
                                );
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: t.spacing.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '✶',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: t.brandPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      SizedBox(width: t.spacing.xs),
                                      Expanded(
                                        child: Text(
                                          '$p1 · $aspect · $p2',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textPrimary,
                                                height: 1.35,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    if (chartPrefs.showTechnicalParameters) ...[
                      AstroDisclosureCard(
                        key: const ValueKey(
                          'western-natal-display-technical-parameters',
                        ),
                        title: '显示参数',
                        subtitle: '展开查看路线、盘面开关和技术参数',
                        icon: Icons.tune_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '展示路线模板',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(height: t.spacing.xs),
                            Text(
                              '当前本命盘会按「${_routeModeLabel(routePrefs.routeMode)}」作为本机展示上下文读取资料，并用本机显示参数绘制。这里的整宫制 / 普拉西德宫制只影响本机视图设置，不改写已保存的本命盘计算口径。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: t.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                            SizedBox(height: t.spacing.sm),
                            Wrap(
                              spacing: t.spacing.xs,
                              runSpacing: t.spacing.xs,
                              children: [
                                AstroPill(
                                  label:
                                      '展示路线：${_routeModeLabel(routePrefs.routeMode)}',
                                ),
                                AstroPill(
                                  label:
                                      '展示上下文：${_routeModeDescription(routePrefs.routeMode)}',
                                ),
                                AstroPill(
                                  label:
                                      '本机显示参数：${_workbenchLabel(workbenchPrefs)}',
                                ),
                              ],
                            ),
                            SizedBox(height: t.spacing.sm),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: () => context.push(
                                  AppRouteNames.astroChartSettings,
                                ),
                                icon: const Icon(Icons.tune_rounded),
                                label: const Text('切换路线 / 显示参数'),
                              ),
                            ),
                            SizedBox(height: t.spacing.md),
                            Text(
                              '盘面阅读提示',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(height: t.spacing.xs),
                            Wrap(
                              spacing: t.spacing.xs,
                              runSpacing: t.spacing.xs,
                              children: [
                                AstroPill(
                                  label:
                                      '路线：${_routeModeLabel(routePrefs.routeMode)}',
                                ),
                                AstroPill(
                                  label: chartPrefs.showChartSignLabels
                                      ? '外圈星座已显示'
                                      : '外圈星座已隐藏',
                                ),
                                AstroPill(
                                  label: chartPrefs.showChartHouseLines
                                      ? '宫位分割已显示'
                                      : '宫位分割已隐藏',
                                ),
                                AstroPill(
                                  label: chartPrefs.showChartPlanetLabels
                                      ? '行星标签已显示'
                                      : '行星标签已隐藏',
                                ),
                                AstroPill(
                                  label: chartPrefs.showChartAspectLines
                                      ? '互动角度连线已显示'
                                      : '互动角度连线已隐藏',
                                ),
                                AstroPill(
                                  label: chartPrefs.showChartCenterTitle
                                      ? '中心标题已显示'
                                      : '中心标题已隐藏',
                                ),
                              ],
                            ),
                            SizedBox(height: t.spacing.md),
                            Text(
                              '星盘来源参数',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(label: '出生时间', value: birthTime),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '真太阳时',
                              value: trueSolarTime,
                              emphasis: true,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(label: '出生地', value: birthPlace),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '出生地校正',
                              value: '已记录，用于排盘校正；页面不展示具体坐标数值',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '位置修正',
                              value: '${locationShift.toStringAsFixed(0)} 分钟',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '经度偏移',
                              value: '${longitudeOffset.toStringAsFixed(0)} 分钟',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '均时差',
                              value: '${equationOfTime.toStringAsFixed(0)} 分钟',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '位置来源',
                              value: locationSource,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '资料来源',
                              value: westernEngine,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '计算口径',
                              value: westernPrecision,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '参考程度',
                              value: westernConfidence,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    AstroSectionCard(
                      title: '备注',
                      subtitle: '来源与参考状态',
                      icon: Icons.notes_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notes.isEmpty
                            ? [
                                Text(
                                  '无备注',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ]
                            : notes
                                  .take(8)
                                  .map((e) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: t.spacing.xs,
                                      ),
                                      child: Text(
                                        '• ${e.toString()}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: t.textSecondary,
                                              height: 1.35,
                                            ),
                                      ),
                                    );
                                  })
                                  .toList(growable: false),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _zodiacModeLabel(AstroZodiacMode mode) => switch (mode) {
  AstroZodiacMode.tropical => '回归黄道',
  AstroZodiacMode.sidereal => '恒星黄道',
};

String _houseSystemLabel(AstroHouseSystem system) => switch (system) {
  AstroHouseSystem.whole => '整宫制',
  AstroHouseSystem.placidus => '普拉西德宫制',
  AstroHouseSystem.alcabitius => '阿卡比特宫制',
};

String _aspectModeLabel(AstroAspectMode mode) => switch (mode) {
  AstroAspectMode.major => '主要互动角度',
  AstroAspectMode.standard => '标准',
  AstroAspectMode.extended => '扩展',
};

String _orbPresetLabel(AstroOrbPreset preset) => switch (preset) {
  AstroOrbPreset.tight => '紧凑',
  AstroOrbPreset.standard => '标准',
  AstroOrbPreset.wide => '宽松',
};

String _pointModeLabel(AstroPointMode mode) => switch (mode) {
  AstroPointMode.core => '核心',
  AstroPointMode.extended => '扩展',
  AstroPointMode.full => '全量',
};

String _routeModeLabel(AstroChartRouteMode mode) => switch (mode) {
  AstroChartRouteMode.standard => '标准路线',
  AstroChartRouteMode.classical => '古典路线',
  AstroChartRouteMode.modern => '现代路线',
};

String _routeModeDescription(AstroChartRouteMode mode) => switch (mode) {
  AstroChartRouteMode.standard => '回归黄道 / 整宫制 / 标准互动角度',
  AstroChartRouteMode.classical => '恒星黄道 / 整宫制 / 紧凑互动角度',
  AstroChartRouteMode.modern => '回归黄道 / 普拉西德宫制 / 宽松互动角度',
};

String _workbenchLabel(AstroChartWorkbenchPrefs prefs) =>
    '黄道=${_zodiacModeLabel(prefs.zodiacMode)} / 宫位=${_houseSystemLabel(prefs.houseSystem)} / 互动角度=${_aspectModeLabel(prefs.aspectMode)} / 容许度=${_orbPresetLabel(prefs.orbPreset)} / 点位=${_pointModeLabel(prefs.pointMode)}';

String _displayAstroPointLabel(Object? value) {
  final raw = (value ?? '').toString().trim();
  if (raw.isEmpty) return '-';
  final key = _normalizedAstroLabelKey(raw);
  const labels = {
    'sun': '太阳',
    'moon': '月亮',
    'mercury': '水星',
    'venus': '金星',
    'mars': '火星',
    'jupiter': '木星',
    'saturn': '土星',
    'uranus': '天王星',
    'neptune': '海王星',
    'pluto': '冥王星',
    'ascendant': '上升点',
    'asc': '上升点',
    'descendant': '下降点',
    'desc': '下降点',
    'mediumcoeli': '天顶',
    'midheaven': '天顶',
    'mc': '天顶',
    'imumcoeli': '天底',
    'ic': '天底',
    'meannorthlunarnode': '北交点',
    'truenorthlunarnode': '北交点',
    'northnode': '北交点',
    'meansouthlunarnode': '南交点',
    'truesouthlunarnode': '南交点',
    'southnode': '南交点',
    'chiron': '凯龙星',
  };
  return labels[key] ?? raw;
}

String _displayAspectLabel(Object? value) {
  final raw = (value ?? '').toString().trim();
  if (raw.isEmpty) return '-';
  final key = _normalizedAstroLabelKey(raw);
  const labels = {
    'conjunction': '合相',
    'opposition': '冲相',
    'trine': '拱相',
    'square': '刑相',
    'sextile': '六合',
  };
  return labels[key] ?? raw;
}

String _normalizedAstroLabelKey(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.map((key, val) => MapEntry(key.toString(), val)))
      .toList(growable: false);
}

Map<String, dynamic> _map(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, val) => MapEntry(key.toString(), val));
}

Map<String, dynamic> _firstProfileMap(
  Map<String, dynamic> profile,
  List<List<String>> paths,
) {
  for (final path in paths) {
    final value = _valueAtPath(profile, path);
    final map = _map(value);
    if (map.isNotEmpty) return map;
  }
  return const <String, dynamic>{};
}

String _profileText(
  Map<String, dynamic> profile,
  List<List<String>> paths, {
  required String fallback,
}) {
  for (final path in paths) {
    final text = (_valueAtPath(profile, path) ?? '').toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

dynamic _valueAtPath(Map<String, dynamic> source, List<String> path) {
  dynamic current = source;
  for (final segment in path) {
    if (current is! Map) return null;
    current = current[segment];
  }
  return current;
}

bool _isHouseTruthDisplayable(String status) {
  final normalized = status.toLowerCase().trim();
  if (normalized.isEmpty || normalized == 'unknown') return true;
  const blocked = {
    'not_house_truth',
    'degraded',
    'unavailable',
    'needs_coordinates',
    'incomplete',
  };
  return !blocked.contains(normalized);
}

String _planetHouseLabel(dynamic value, String houseTruthStatus) {
  if (!_isHouseTruthDisplayable(houseTruthStatus)) return '宫位待确认';
  return _displayHouseLabel(value, fallback: '宫位未返回');
}

String _displayDegreeLabel(dynamic value) {
  final raw = astroText(value, '-');
  if (raw == '-' || raw.contains('°')) return raw;
  final parsed = value is num ? value.toDouble() : double.tryParse(raw);
  if (parsed == null || !parsed.isFinite) return raw;
  final rounded = parsed.toStringAsFixed(1);
  return '${rounded.endsWith('.0') ? rounded.substring(0, rounded.length - 2) : rounded}°';
}

String _displayZodiacSignLabel(dynamic value) {
  final raw = astroText(value, '-');
  final normalized = raw.toLowerCase().trim().replaceAll('_', ' ');
  return switch (normalized) {
    'aries' || 'ari' => '白羊座',
    'taurus' || 'tau' => '金牛座',
    'gemini' || 'gem' => '双子座',
    'cancer' || 'can' => '巨蟹座',
    'leo' => '狮子座',
    'virgo' || 'vir' => '处女座',
    'libra' || 'lib' => '天秤座',
    'scorpio' || 'sco' => '天蝎座',
    'sagittarius' || 'sag' => '射手座',
    'capricorn' || 'cap' => '摩羯座',
    'aquarius' || 'aqu' => '水瓶座',
    'pisces' || 'pis' => '双鱼座',
    _ => raw,
  };
}

String _displayHouseLabel(dynamic value, {String fallback = '宫位未返回'}) {
  final raw = astroText(value, fallback);
  final normalized = raw
      .toLowerCase()
      .trim()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  return switch (normalized) {
    'first_house' || '1' || '1.0' => '第一宫',
    'second_house' || '2' || '2.0' => '第二宫',
    'third_house' || '3' || '3.0' => '第三宫',
    'fourth_house' || '4' || '4.0' => '第四宫',
    'fifth_house' || '5' || '5.0' => '第五宫',
    'sixth_house' || '6' || '6.0' => '第六宫',
    'seventh_house' || '7' || '7.0' => '第七宫',
    'eighth_house' || '8' || '8.0' => '第八宫',
    'ninth_house' || '9' || '9.0' => '第九宫',
    'tenth_house' || '10' || '10.0' => '第十宫',
    'eleventh_house' || '11' || '11.0' => '第十一宫',
    'twelfth_house' || '12' || '12.0' => '第十二宫',
    _ => raw,
  };
}

String _sourceStatusMessage(String houseTruthStatus, String oracleStatus) {
  if (!_isHouseTruthDisplayable(houseTruthStatus)) {
    return '当前后端标记宫位结果不可作为真实落宫使用，页面只保留盘面与摘要展示，需补齐出生地坐标或来源校验后再确认。';
  }
  if (oracleStatus.toLowerCase().trim() == 'not_validated') {
    return '行星宫位读取已保存宫位字段；外部对照尚未完成，页面只显示未完成状态。';
  }
  return '行星宫位读取已保存宫位字段；页面不从太阳、月亮或上升星座摘要推断宫位。';
}

String _houseTruthStatusLabel(String status) {
  final normalized = status.toLowerCase().trim();
  return switch (normalized) {
    'available' => '可展示',
    'needs_coordinates' => '待出生地坐标',
    'not_house_truth' => '宫位待来源确认',
    'degraded' => '降级',
    'unavailable' => '不可用',
    'incomplete' => '不完整',
    'unknown' || '' => '未标记',
    _ => status,
  };
}

String _externalOracleStatusLabel(String status) {
  final normalized = status.toLowerCase().trim();
  return switch (normalized) {
    'not_validated' => '未完成',
    'validated' => '已有对照记录',
    'failed' => '未通过',
    'unknown' || '' => '未标记',
    _ => status,
  };
}

String _locationSourceLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'longitude_based' => '出生地经度校正',
    'geocode' || 'geocoded' => '出生地坐标校正',
    'manual' => '手动资料',
    'unknown' || '' => '未标记',
    _ => '已记录',
  };
}

String _westernEngineLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'legacy_input' => '资料输入口径',
    'kerykeion' => '本命盘计算服务',
    'unknown' || '' => '未标记',
    _ => '本命盘计算服务',
  };
}

String _westernPrecisionLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'legacy_estimate' => '估算口径，待外部校验',
    'calendar_canonical' => '历法口径',
    'not_validated' => '待外部校验',
    'unknown' || '' => '未标记',
    _ => '已记录，待外部校验',
  };
}

String _westernConfidenceLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == '0.0') return '未标记';
  return '仅供展示参考';
}

List<String> _displayNotes(List<dynamic> rawNotes) {
  return rawNotes
      .map((note) => _displayNoteLabel(note.toString()))
      .whereType<String>()
      .toList(growable: false);
}

String? _displayNoteLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final lower = trimmed.toLowerCase();
  if (lower == 'recomputed_from_basic_profile') {
    return '已按当前基础资料重新计算';
  }
  if (lower == 'location_source:longitude_based') {
    return '出生地经度已用于时间校正';
  }
  if (lower.startsWith('location_shift_minutes:')) {
    return '时间修正参考：${trimmed.split(':').skip(1).join(':')} 分钟';
  }
  if (lower.startsWith('canonical_confidence:')) {
    return '综合参考状态：已记录';
  }
  if (lower.startsWith('western_confidence:')) {
    return '西洋星盘参考状态：仅供展示参考';
  }
  if (lower == 'ziwei_engine:ziwei_canonical_server') {
    return '紫微展示来源：标准排盘服务';
  }
  if (lower.startsWith('ziwei_engine:')) {
    return '紫微展示来源：已记录';
  }
  if (lower.startsWith('ziwei_confidence:')) {
    return '紫微展示参考状态：仅供展示参考';
  }
  const hiddenFragments = [
    'canonical_source',
    'canonical_accuracy',
    'precision:',
    'time_source:',
    'rollout_',
    'legacy_input',
    'legacy_estimate',
  ];
  if (hiddenFragments.any(lower.contains)) return null;
  return trimmed;
}

String _backendZodiacPolicyLabel(Map<String, dynamic> policy) {
  final raw = (policy['zodiac_mode'] ?? '').toString().toLowerCase().trim();
  if (raw.contains('tropical')) return 'Tropical / 回归黄道';
  if (raw.contains('sidereal')) return 'Sidereal / 恒星黄道';
  if (raw.isEmpty) return '未标记';
  return policy['zodiac_mode'].toString();
}

String _backendHousePolicyLabel(Map<String, dynamic> policy) {
  final raw = (policy['house_system'] ?? '').toString().toLowerCase().trim();
  if (raw.contains('placidus') || raw == 'p') {
    return 'Placidus / 普拉西德宫制';
  }
  if (raw.contains('whole')) return 'Whole / 整宫制';
  if (raw.isEmpty) return '未标记';
  return policy['house_system'].toString();
}

List<Widget> _policyPills(Map<String, dynamic> policy) {
  if (policy.isEmpty) return const [];
  final entries = <String, String>{
    'engine': '引擎',
    'timezone': '时区',
    'generated_at': '生成时间',
  };
  return entries.entries
      .map((entry) {
        final value = (policy[entry.key] ?? '').toString().trim();
        if (value.isEmpty) return null;
        return AstroPill(label: '${entry.value}：$value');
      })
      .whereType<Widget>()
      .toList(growable: false);
}

class _FactRowItem {
  const _FactRowItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String value;
  final String subtitle;
}

class _StructuredFactList extends StatelessWidget {
  const _StructuredFactList({required this.items});

  final List<_FactRowItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: t.spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      item.icon,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.brandPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: t.spacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            SizedBox(width: t.spacing.xs),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 8),
                                height: 1,
                                decoration: BoxDecoration(
                                  color: t.browseBorder,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            SizedBox(width: t.spacing.xs),
                            Text(
                              item.value,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (index != items.length - 1)
              Divider(height: 1, color: t.browseBorder),
          ],
        );
      }),
    );
  }
}

String _planetGlyph(String name) {
  switch (name.toLowerCase()) {
    case 'sun':
      return '☉';
    case 'moon':
      return '☾';
    case 'mercury':
      return '☿';
    case 'venus':
      return '♀';
    case 'mars':
      return '♂';
    case 'jupiter':
      return '♃';
    case 'saturn':
      return '♄';
    case 'uranus':
      return '♅';
    case 'neptune':
      return '♆';
    case 'pluto':
      return '♇';
    case 'ascendant':
      return 'Asc';
    case 'medium coeli':
    case 'medium_coeli':
      return 'MC';
    default:
      return '✦';
  }
}

String _zodiacGlyph(String sign) {
  switch (sign) {
    case '白羊座':
    case 'Aries':
      return '♈';
    case '金牛座':
    case 'Taurus':
      return '♉';
    case '双子座':
    case 'Gemini':
      return '♊';
    case '巨蟹座':
    case 'Cancer':
      return '♋';
    case '狮子座':
    case 'Leo':
      return '♌';
    case '处女座':
    case 'Virgo':
      return '♍';
    case '天秤座':
    case 'Libra':
      return '♎';
    case '天蝎座':
    case 'Scorpio':
      return '♏';
    case '射手座':
    case 'Sagittarius':
      return '♐';
    case '摩羯座':
    case 'Capricorn':
      return '♑';
    case '水瓶座':
    case 'Aquarius':
      return '♒';
    case '双鱼座':
    case 'Pisces':
      return '♓';
    default:
      return '✧';
  }
}
