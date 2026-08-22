import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';

/// Deterministic synthetic data for offline widget regression only.
///
/// This fixture is not astrology-correctness evidence and never participates in
/// routing, matching, authentication, or production data flows.
AstroAdvancedPreviewBundle buildTestOnlyAdvancedPreviewFixture() {
  const routeMode = AstroChartRouteMode.modern;
  const nowLabel = '2026-04-12 10:30';
  const subject = 'EliteSync';

  return AstroAdvancedPreviewBundle(
    routeMode: routeMode,
    offlineFallback: true,
    timing: buildAstroTimingFrameworkBundle(
      const {'name': subject, 'birthday': '1994-04-17', 'birth_time': '09:30'},
      routeMode,
      referenceNow: DateTime(2026, 4, 17, 10, 30),
    ),
    requests: AstroAdvancedPreviewRequests(
      pair: const {
        'first': {'name': subject},
        'second': {'name': '示例对照档'},
        'pair_mode': 'synastry',
        'route_mode': 'modern',
      },
      comparison: const {
        'first': {'name': subject},
        'second': {'name': '示例对比档'},
        'pair_mode': 'comparison',
        'route_mode': 'modern',
      },
      transit: const {
        'natal': {'name': subject},
        'transit': {'name': '行运参考盘'},
        'route_mode': 'modern',
      },
      returnChart: const {
        'natal': {'name': subject},
        'return_year': 2026,
        'return_type': 'Lunar',
        'route_mode': 'modern',
      },
    ),
    pair: const AstroAdvancedPreviewItem(
      title: '合盘预览（测试样例）',
      summary: '$subject × 示例对照档 · 测试样例 · 9 条关系线索',
      routeMode: 'modern',
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '示例对照档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 9,
      chartKind: 'synastry',
      advancedMode: 'pair',
      pairMode: 'synastry',
      relationshipScoreDescription: '测试样例',
      relationshipScoreValue: 78,
    ),
    comparison: const AstroAdvancedPreviewItem(
      title: '对比盘预览（测试样例）',
      summary: '$subject × 示例对比档 · 测试样例 · 10 条关系线索',
      routeMode: 'modern',
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '示例对比档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 10,
      chartKind: 'comparison',
      advancedMode: 'pair',
      pairMode: 'comparison',
      relationshipScoreDescription: '对照差异',
      relationshipScoreValue: 63,
    ),
    transit: const AstroAdvancedPreviewItem(
      title: '行运预览（测试样例）',
      summary: '$subject · 时间维度测试样例 · 6 条关系线索',
      routeMode: 'modern',
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '行运参考盘',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 6,
      chartKind: 'transit',
      advancedMode: 'transit',
      pairMode: 'transit',
      relationshipScoreDescription: '时间维度',
      relationshipScoreValue: 55,
    ),
    returnChart: const AstroAdvancedPreviewItem(
      title: '返照预览（测试样例）',
      summary: '$subject · 年度返照测试样例 · 5 条关系线索',
      routeMode: 'modern',
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '返照参考盘',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 5,
      chartKind: 'return',
      advancedMode: 'return',
      returnType: 'Lunar',
      returnYear: 2026,
      relationshipScoreDescription: '年度解释',
      relationshipScoreValue: 49,
    ),
  );
}
