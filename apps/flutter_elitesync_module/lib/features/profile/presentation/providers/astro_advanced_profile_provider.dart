import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_errors.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class AstroAdvancedPreviewRequests {
  const AstroAdvancedPreviewRequests({
    required this.pair,
    required this.comparison,
    required this.transit,
    required this.returnChart,
  });

  final Map<String, dynamic> pair;
  final Map<String, dynamic> comparison;
  final Map<String, dynamic> transit;
  final Map<String, dynamic> returnChart;
}

class AstroAdvancedPreviewItem {
  const AstroAdvancedPreviewItem({
    required this.title,
    required this.summary,
    required this.routeMode,
    required this.generatedAt,
    required this.primaryName,
    required this.secondaryName,
    required this.primaryPointCount,
    required this.secondaryPointCount,
    required this.aspectCount,
    required this.chartKind,
    required this.advancedMode,
    this.pairMode,
    this.returnType,
    this.returnYear,
    this.relationshipScoreDescription,
    this.relationshipScoreValue,
  });

  final String title;
  final String summary;
  final String routeMode;
  final String generatedAt;
  final String primaryName;
  final String secondaryName;
  final int primaryPointCount;
  final int secondaryPointCount;
  final int aspectCount;
  final String chartKind;
  final String advancedMode;
  final String? pairMode;
  final String? returnType;
  final int? returnYear;
  final String? relationshipScoreDescription;
  final num? relationshipScoreValue;

  String get modeLabel {
    return switch (advancedMode) {
      'pair' => '合盘',
      'transit' => '行运',
      'return' => '返照',
      _ => advancedMode,
    };
  }

  String get routeLabel => _routeModeLabelText(routeMode);

  String get metricsLabel =>
      '主档 $primaryPointCount 点位 / 对照 $secondaryPointCount 点位 / $aspectCount 条关系线索';

  String get chartKindLabel => _chartKindLabel(chartKind);

  String get pairModeLabel => _pairModeLabel(pairMode);

  String get returnTypeLabel => _returnTypeLabel(returnType);

  List<String> get badges => [
    '路线：$routeLabel',
    '模式：$modeLabel',
    if ((pairMode ?? '').isNotEmpty) '关系模式：$pairModeLabel',
    if ((returnType ?? '').isNotEmpty) '返照：$returnTypeLabel',
    if (returnYear != null) '返照年：$returnYear',
  ];

  List<String> toMarkdownLines() => [
    '- 模式：$modeLabel',
    '- 路线：$routeLabel',
    '- 参考类型：$chartKindLabel',
    '- 标题：$title',
    '- 概要：$summary',
    '- 主档：$primaryName',
    '- 对照：$secondaryName',
    '- 计数：${metricsLabel.replaceAll(' / ', '，')}',
    if (pairMode != null) '- 关系模式：$pairModeLabel',
    if (returnType != null) '- 返照类型：$returnTypeLabel',
    if (returnYear != null) '- 返照年份：$returnYear',
    if ((relationshipScoreDescription ?? '').trim().isNotEmpty)
      '- 关系提示：$relationshipScoreDescription',
  ];

  List<AstroExplainabilityEntry> buildExplainabilityEntries() => [
    AstroExplainabilityEntry(
      layerLabel: '互动角度级',
      title: '$title · 互动角度条目',
      summary: '$aspectCount 条关系线索 · $modeLabel · $chartKindLabel',
      detail: '当前只展示条目化说明与权重表达，不把结果冒充为新的资料来源；这层用于高级预览的首轮解释。',
      badges: ['关系线索 $aspectCount', '参考类型 $chartKindLabel', '路线 $routeLabel'],
    ),
    AstroExplainabilityEntry(
      layerLabel: '点位级',
      title: '$title · 点位条目',
      summary: '主档 $primaryPointCount 点位 / 对照 $secondaryPointCount 点位',
      detail: '点位条目只负责把主要对象与可见范围拆成可读单元，后续小行星、虚点和扩展点位可以继续挂接到这个位置。',
      badges: [
        '主档 $primaryPointCount',
        '对照 $secondaryPointCount',
        '模式 $modeLabel',
      ],
    ),
    AstroExplainabilityEntry(
      layerLabel: '高级时法关联层',
      title: '$title · 关联条目',
      summary: _buildExplainabilityAssociationSummary(
        mode: advancedMode,
        returnType: returnType,
        returnYear: returnYear,
        pairMode: pairMode,
      ),
      detail: '这一层只做关系与时间维度的展示关联，不回写本命盘主结构；用来说明当前解释与时间维度、关系维度之间的连接方式。',
      badges: [
        '关联 $modeLabel',
        '路线 $routeLabel',
        if ((pairMode ?? '').isNotEmpty) '关系模式 $pairModeLabel',
        if ((returnType ?? '').isNotEmpty) '返照 $returnTypeLabel',
        if (returnYear != null) '返照年份 $returnYear',
      ],
    ),
  ];
}

class AstroExplainabilityEntry {
  const AstroExplainabilityEntry({
    required this.layerLabel,
    required this.title,
    required this.summary,
    required this.detail,
    required this.badges,
  });

  final String layerLabel;
  final String title;
  final String summary;
  final String detail;
  final List<String> badges;

  List<String> toMarkdownLines() => [
    '- 层级：$layerLabel',
    '- 标题：$title',
    '- 概要：$summary',
    '- 说明：$detail',
    if (badges.isNotEmpty) '- 标签：${badges.join('，')}',
  ];
}

class AstroAdvancedPreviewBundle {
  const AstroAdvancedPreviewBundle({
    required this.routeMode,
    required this.requests,
    required this.timing,
    required this.pair,
    required this.comparison,
    required this.transit,
    required this.returnChart,
    this.offlineFallback = false,
  });

  final AstroChartRouteMode routeMode;
  final AstroAdvancedPreviewRequests requests;
  final AstroTimingFrameworkBundle timing;
  final AstroAdvancedPreviewItem pair;
  final AstroAdvancedPreviewItem comparison;
  final AstroAdvancedPreviewItem transit;
  final AstroAdvancedPreviewItem returnChart;
  final bool offlineFallback;

  List<AstroAdvancedPreviewItem> get items => [
    pair,
    comparison,
    transit,
    returnChart,
  ];

  List<String> toMarkdownLines() => [
    '# 3.9 高级时法预览',
    '- 报告性质：展示参考 / 不改写已保存记录',
    '- 当前路线：${_routeModeLabel(routeMode)}',
    if (offlineFallback) '- 说明：当前使用离线样例预览，在线高级预览暂不可用。',
    '- 说明：预览数据使用当前画像与对照样例生成，不回写已保存的星盘记录。',
    '',
    ...timing.toMarkdownLines(),
    '',
    ...pair.toMarkdownLines(),
    '',
    ...comparison.toMarkdownLines(),
    '',
    ...transit.toMarkdownLines(),
    '',
    ...returnChart.toMarkdownLines(),
    '',
    '# 3.9 细粒度解释层',
    ...items.expand(
      (item) => [
        ...item.buildExplainabilityEntries().expand(
          (entry) => [...entry.toMarkdownLines()],
        ),
        '',
      ],
    ),
    '# 3.9 高级时法关联层',
    '- 时法框架：${timing.frameworkTitle}',
    '- 时法摘要：${timing.frameworkSummary}',
    '- 正式能力：${timing.formalSignal.title} / ${timing.formalSignal.summary}',
    '- 占位能力：${timing.placeholderSignal.title} / ${timing.placeholderSignal.summary}',
  ];
}

enum AstroTimingMode { annualProfectionLike, firdariaLike, placeholder }

class AstroTimingSignal {
  const AstroTimingSignal({
    required this.mode,
    required this.title,
    required this.summary,
    required this.scopeLabel,
    required this.windowLabel,
    required this.sourceLayer,
    required this.basisLabel,
    required this.tags,
    this.isFormal = false,
    this.degraded = false,
  });

  final AstroTimingMode mode;
  final String title;
  final String summary;
  final String scopeLabel;
  final String windowLabel;
  final String sourceLayer;
  final String basisLabel;
  final List<String> tags;
  final bool isFormal;
  final bool degraded;

  String get modeLabel => switch (mode) {
    AstroTimingMode.annualProfectionLike => '年度视角',
    AstroTimingMode.firdariaLike => '主时段占位',
    AstroTimingMode.placeholder => '占位容器',
  };

  String get layerLabel => degraded ? '展示参考' : _sourceLayerLabel(sourceLayer);

  List<String> get badges => [
    if (isFormal) '正式能力' else '占位能力',
    modeLabel,
    '范围：$scopeLabel',
    '窗口：$windowLabel',
    '层：$layerLabel',
  ];

  AstroTimingSignal copyWith({
    String? summary,
    String? scopeLabel,
    String? windowLabel,
    String? sourceLayer,
    String? basisLabel,
    List<String>? tags,
    bool? isFormal,
    bool? degraded,
  }) {
    return AstroTimingSignal(
      mode: mode,
      title: title,
      summary: summary ?? this.summary,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      windowLabel: windowLabel ?? this.windowLabel,
      sourceLayer: sourceLayer ?? this.sourceLayer,
      basisLabel: basisLabel ?? this.basisLabel,
      tags: tags ?? this.tags,
      isFormal: isFormal ?? this.isFormal,
      degraded: degraded ?? this.degraded,
    );
  }

  List<String> toMarkdownLines() => [
    '- 时法：$title',
    '- 模式：$modeLabel',
    '- 范围：$scopeLabel',
    '- 窗口：$windowLabel',
    '- 层：$layerLabel',
    '- 基础：$basisLabel',
    '- 说明：$summary',
    if (tags.isNotEmpty) '- 标签：${tags.join('，')}',
  ];
}

class AstroTimingSampleCase {
  const AstroTimingSampleCase({
    required this.title,
    required this.subtitle,
    required this.signals,
    required this.notes,
    this.isEdgeCase = false,
  });

  final String title;
  final String subtitle;
  final List<AstroTimingSignal> signals;
  final List<String> notes;
  final bool isEdgeCase;

  List<String> toMarkdownLines() => [
    '- 用例：$title',
    '- 场景：$subtitle',
    '- 类型：${isEdgeCase ? '边界样例' : '常规样例'}',
    ...signals.expand((signal) => signal.toMarkdownLines()),
    ...notes.map((item) => '- 备注：$item'),
  ];
}

class AstroTimingFrameworkBundle {
  const AstroTimingFrameworkBundle({
    required this.routeMode,
    required this.generatedAt,
    required this.frameworkTitle,
    required this.frameworkSummary,
    required this.formalSignal,
    required this.placeholderSignal,
    required this.sampleCases,
    required this.knownDeviations,
    this.offlineFallback = false,
    this.hasBirthData = true,
  });

  final AstroChartRouteMode routeMode;
  final String generatedAt;
  final String frameworkTitle;
  final String frameworkSummary;
  final AstroTimingSignal formalSignal;
  final AstroTimingSignal placeholderSignal;
  final List<AstroTimingSampleCase> sampleCases;
  final List<String> knownDeviations;
  final bool offlineFallback;
  final bool hasBirthData;

  List<AstroTimingSignal> get signals => [formalSignal, placeholderSignal];

  List<String> toMarkdownLines() => [
    '# 3.9 高级时法框架',
    '- 报告性质：展示参考 / 不改写已保存记录',
    '- 当前路线：${_routeModeLabel(routeMode)}',
    '- 生成时间：$generatedAt',
    '- 框架标题：$frameworkTitle',
    '- 框架摘要：$frameworkSummary',
    '- 正式能力：${formalSignal.modeLabel}',
    '- 占位能力：${placeholderSignal.modeLabel}',
    '- 出生数据：${hasBirthData ? '已提供最小锚点' : '仅保留容器占位'}',
    if (offlineFallback) '- 说明：当前使用离线样例与显示层占位，等待正式数据连接扩展。',
    '',
    ...signals.expand((signal) => signal.toMarkdownLines()),
    '',
    '# 3.9 时法样例矩阵',
    ...sampleCases.expand(
      (sampleCase) => [...sampleCase.toMarkdownLines(), ''],
    ),
    '# 3.9 已知偏差',
    ...knownDeviations.map((item) => '- $item'),
  ];
}

final astroAdvancedPreviewProvider =
    FutureProvider<AstroAdvancedPreviewBundle?>((ref) async {
      try {
        final routeMode = ref.watch(astroChartRouteProvider).routeMode;
        final summary = await ref.watch(astroSummaryProvider.future);
        if (summary == null) return null;

        final requests = buildAstroAdvancedPreviewRequests(summary, routeMode);
        final timing = buildAstroTimingFrameworkBundle(summary, routeMode);

        final pairPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/pair',
          body: requests.pair,
        );
        final comparisonPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/pair',
          body: requests.comparison,
        );
        final transitPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/transit',
          body: requests.transit,
        );
        final returnPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/return',
          body: requests.returnChart,
        );

        return AstroAdvancedPreviewBundle(
          routeMode: routeMode,
          requests: requests,
          timing: timing,
          pair: _buildAdvancedPreviewItem(title: '合盘预览', payload: pairPayload),
          comparison: _buildAdvancedPreviewItem(
            title: '对比盘预览',
            payload: comparisonPayload,
          ),
          transit: _buildAdvancedPreviewItem(
            title: '行运预览',
            payload: transitPayload,
          ),
          returnChart: _buildAdvancedPreviewItem(
            title: '返照预览',
            payload: returnPayload,
          ),
        );
      } catch (_) {
        final routeMode = ref.read(astroChartRouteProvider).routeMode;
        final fallbackProfile = <String, dynamic>{'name': 'EliteSync'};
        final fallbackRequests = buildAstroAdvancedPreviewRequests(
          fallbackProfile,
          routeMode,
        );
        final fallbackTiming = buildAstroTimingFrameworkBundle(
          fallbackProfile,
          routeMode,
          referenceNow: DateTime.now(),
        );
        return _buildOfflineAdvancedPreviewBundle(
          fallbackProfile,
          routeMode,
          fallbackRequests,
          fallbackTiming,
        );
      }
    });

Future<Map<String, dynamic>> _postAdvancedProfile(
  Ref ref, {
  required String path,
  required Map<String, dynamic> body,
}) async {
  final result = await ref
      .read(apiClientProvider)
      .post(path, body: body)
      .timeout(const Duration(seconds: 12));

  if (result is NetworkSuccess<Map<String, dynamic>>) {
    final data = result.data;
    if (data['ok'] == true && data['profile'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['profile'] as Map<String, dynamic>);
    }
    return data;
  }

  final failure = result as NetworkFailure<Map<String, dynamic>>;
  if (failure.statusCode == 401 || failure.statusCode == 403) {
    await ref.read(sessionProvider.notifier).setUnauthenticated();
  }

  throw AstroProfileApiException(
    message: failure.message,
    statusCode: failure.statusCode,
    code: failure.code,
  );
}

AstroAdvancedPreviewItem _buildAdvancedPreviewItem({
  required String title,
  required Map<String, dynamic> payload,
}) {
  final advancedSummary = _map(payload['advanced_summary']);
  final primary = _readText(advancedSummary, 'primary_name');
  final secondary = _readText(advancedSummary, 'secondary_name');
  final chartKind = payload['engine_info'] is Map<String, dynamic>
      ? _readText(_map(payload['engine_info']), 'chart_kind') ?? '-'
      : '-';
  final advancedMode = _readText(payload, 'advanced_mode') ?? '-';
  final routeMode = _readText(payload, 'route_mode') ?? 'standard';
  final generatedAt = astroDateTimeLabel(payload['generated_at']);
  final primaryCount = _list(payload['primary_planets_data']).length;
  final secondaryCount = _list(payload['secondary_planets_data']).length;
  final aspectCount = _list(payload['aspects_data']).length;
  final pairMode = _readText(payload, 'pair_mode');
  final returnType = _readText(advancedSummary, 'return_type');
  final returnYear = advancedSummary['return_year'] is int
      ? advancedSummary['return_year'] as int
      : int.tryParse(advancedSummary['return_year']?.toString() ?? '');
  final relationshipScoreDescription = _readText(
    advancedSummary,
    'relationship_score_description',
  );
  final relationshipScoreValue =
      advancedSummary['relationship_score_value'] as num?;

  return AstroAdvancedPreviewItem(
    title: title,
    summary: _buildSummaryText(
      mode: advancedMode,
      primary: primary ?? '',
      secondary: secondary ?? '',
      aspectCount: aspectCount,
      relationshipScoreDescription: relationshipScoreDescription,
      returnType: returnType,
      returnYear: returnYear,
    ),
    routeMode: routeMode,
    generatedAt: generatedAt,
    primaryName: primary?.isNotEmpty == true ? primary! : '主档',
    secondaryName: secondary?.isNotEmpty == true ? secondary! : '对照档',
    primaryPointCount: primaryCount,
    secondaryPointCount: secondaryCount,
    aspectCount: aspectCount,
    chartKind: chartKind,
    advancedMode: advancedMode,
    pairMode: pairMode?.isEmpty == true ? null : pairMode,
    returnType: returnType?.isEmpty == true ? null : returnType,
    returnYear: returnYear,
    relationshipScoreDescription: relationshipScoreDescription?.isEmpty == true
        ? null
        : relationshipScoreDescription,
    relationshipScoreValue: relationshipScoreValue,
  );
}

AstroAdvancedPreviewBundle _buildOfflineAdvancedPreviewBundle(
  Map<String, dynamic> profile,
  AstroChartRouteMode routeMode,
  AstroAdvancedPreviewRequests requests,
  AstroTimingFrameworkBundle timing,
) {
  final nowLabel = astroDateTimeLabel(DateTime.now());
  final subject = _subjectName(profile);
  return AstroAdvancedPreviewBundle(
    routeMode: routeMode,
    requests: requests,
    timing: timing,
    offlineFallback: true,
    pair: AstroAdvancedPreviewItem(
      title: '合盘预览（离线）',
      summary: '$subject × 对照档 · 离线样例 · 9 条关系线索',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '对照档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 9,
      chartKind: 'synastry',
      advancedMode: 'pair',
      pairMode: 'synastry',
      relationshipScoreDescription: '离线样例',
      relationshipScoreValue: 78,
    ),
    comparison: AstroAdvancedPreviewItem(
      title: '对比盘预览（离线）',
      summary: '$subject × 对比档 · 离线样例 · 10 条关系线索',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '对比档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 10,
      chartKind: 'comparison',
      advancedMode: 'pair',
      pairMode: 'comparison',
      relationshipScoreDescription: '对照差异',
      relationshipScoreValue: 61,
    ),
    transit: AstroAdvancedPreviewItem(
      title: '行运预览（离线）',
      summary: '$subject · 时间维度样例 · 6 条关系线索',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '行运档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 6,
      chartKind: 'transit',
      advancedMode: 'transit',
    ),
    returnChart: AstroAdvancedPreviewItem(
      title: '返照预览（离线）',
      summary: '$subject · 月返照样例 · 5 条关系线索',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '返照档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 5,
      chartKind: 'return',
      advancedMode: 'return',
      returnType: 'Lunar',
      returnYear: DateTime.now().year,
    ),
  );
}

AstroTimingFrameworkBundle buildAstroTimingFrameworkBundle(
  Map<String, dynamic> profile,
  AstroChartRouteMode routeMode, {
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();
  final generatedAt = astroDateTimeLabel(now);
  final subject = _subjectName(profile);
  final birthday = _readString(profile, ['birthday']);
  final birthTime = _readString(profile, ['birth_time']);
  final birthDate = _parseDate(birthday);
  final hasBirthData = birthDate != null && (birthTime ?? '').trim().isNotEmpty;
  final age = birthDate == null
      ? null
      : now.year -
            birthDate.year -
            ((now.month < birthDate.month ||
                    (now.month == birthDate.month && now.day < birthDate.day))
                ? 1
                : 0);
  final annualCycle = age == null ? null : ((age % 12) + 1);
  final formalSummary = hasBirthData
      ? '以 $subject 的当前年龄${age == null ? '' : '（$age 岁）'}与当前年份 $generatedAt 生成年限视角，仅作为展示预览。'
      : '缺少生日或出生时间锚点，当前仅保留年限容器与阅读占位，不生成强结论。';
  final formalSignal = AstroTimingSignal(
    mode: AstroTimingMode.annualProfectionLike,
    title: '年度视角',
    summary: formalSummary,
    scopeLabel: '年限 / 流年',
    windowLabel: annualCycle == null ? '当前年' : '第$annualCycle 宫循环 / 当前年',
    sourceLayer: 'advanced-context',
    basisLabel: hasBirthData ? '年龄锚点 ${age ?? '-'} + 当前年份' : '生日 / 出生时间缺失',
    tags: [
      '年度视角',
      '年限类参考',
      _routeModeLabel(routeMode),
      if (hasBirthData) '有出生锚点' else '出生锚点不足',
    ],
    isFormal: true,
    degraded: !hasBirthData,
  );
  final placeholderSignal = AstroTimingSignal(
    mode: AstroTimingMode.firdariaLike,
    title: '主时段视角',
    summary: '预留法达类接入位的时段容器，当前仅展示占位窗口与解释边界，不把结果当作本命盘结论。',
    scopeLabel: '主时段 / 次时段',
    windowLabel: '待接入',
    sourceLayer: 'advanced-context',
    basisLabel: '后续可接法达 / 时段轮转',
    tags: ['主时段视角', '法达类预留', '占位展示', _routeModeLabel(routeMode)],
    isFormal: false,
    degraded: true,
  );

  final baselineCase = AstroTimingSampleCase(
    title: '基线样例',
    subtitle: '最小正式能力：年度视角单独展示',
    signals: [formalSignal],
    notes: ['用于验证时法容器是否可读、可审查、可归档。', '该用例只展示高级上下文，不回写本命盘主结构。'],
  );
  final edgeCase = AstroTimingSampleCase(
    title: '边界样例',
    subtitle: '出生数据不完整时的降级表现',
    isEdgeCase: true,
    signals: [formalSignal.copyWith(degraded: true, basisLabel: '出生锚点不完整')],
    notes: ['如果生日或出生时间缺失，年限容器保留，但不继续放大解释结论。', '边界说明优先于结果陈述，避免把预览内容冒充为新结论。'],
  );
  final denseCase = AstroTimingSampleCase(
    title: '密集样例',
    subtitle: '年度视角 + 主时段视角并列展示',
    signals: [formalSignal, placeholderSignal],
    notes: ['用于验证多层展示时的卡片密度、排序与命名是否稳定。', '后续若接入第二个正式时法能力，可直接替换占位信号。'],
  );

  return AstroTimingFrameworkBundle(
    routeMode: routeMode,
    generatedAt: generatedAt,
    frameworkTitle: '时法容器 v1',
    frameworkSummary: '先建立年限类正式能力，再保留法达类接入口，所有输出都只用于展示与关联说明。',
    formalSignal: formalSignal,
    placeholderSignal: placeholderSignal,
    sampleCases: [baselineCase, edgeCase, denseCase],
    knownDeviations: [
      '年度视角使用年龄锚点与当前年份生成预览，不代表最终时法结论。',
      '主时段视角当前仍是占位能力，后续正式接入前不得冒充为已完成算法。',
      '高级时法层只做挂接式扩展，不回写基础资料或已保存的星盘记录。',
    ],
    hasBirthData: hasBirthData,
  );
}

String _buildExplainabilityAssociationSummary({
  required String mode,
  String? returnType,
  int? returnYear,
  String? pairMode,
}) {
  return switch (mode) {
    'pair' =>
      '关系维度条目继续保留主档 / 对照档 / 评分描述，并通过 ${_pairModeLabel(pairMode)} 作为上下文锚点。',
    'transit' => '时间维度条目以过境盘为锚点，仅说明当前窗口与显示层关联，不进入新的结论层。',
    'return' =>
      '返照条目以 ${_returnTypeLabel(returnType)}${returnYear == null ? '' : ' $returnYear'} 为上下文锚点。',
    _ => '${_advancedModeLabel(mode)} 关联条目仅用于展示参考。',
  };
}

String _buildSummaryText({
  required String mode,
  required String primary,
  required String secondary,
  required int aspectCount,
  String? relationshipScoreDescription,
  String? returnType,
  int? returnYear,
}) {
  return switch (mode) {
    'pair' =>
      '${primary.isEmpty ? '主档' : primary} × ${secondary.isEmpty ? '对照档' : secondary} · ${relationshipScoreDescription ?? '关系提示预览'} · $aspectCount 条关系线索',
    'transit' =>
      '${primary.isEmpty ? '主档' : primary} × ${secondary.isEmpty ? '过境档' : secondary} · $aspectCount 条关系线索',
    'return' =>
      '${primary.isEmpty ? '主档' : primary} · ${_returnTypeLabel(returnType)}${returnYear == null ? '' : ' $returnYear'} · $aspectCount 条关系线索',
    _ => '${_advancedModeLabel(mode)} · $aspectCount 条关系线索',
  };
}

String _advancedModeLabel(String? mode) {
  final normalized = (mode ?? '').toLowerCase().trim();
  return switch (normalized) {
    'pair' => '关系维度',
    'transit' => '时间维度',
    'return' => '返照维度',
    'comparison' => '对比维度',
    '' => '展示维度',
    _ => '展示维度',
  };
}

String _chartKindLabel(String? kind) {
  final normalized = (kind ?? '').toLowerCase().trim();
  return switch (normalized) {
    'synastry' => '合盘参考',
    'comparison' => '对比盘参考',
    'transit' => '行运参考',
    'return' => '返照参考',
    'natal' => '本命盘参考',
    '' || '-' => '展示参考',
    _ => '展示参考',
  };
}

String _pairModeLabel(String? mode) {
  final normalized = (mode ?? '').toLowerCase().trim();
  return switch (normalized) {
    'synastry' => '合盘参考',
    'comparison' => '对比参考',
    'transit' => '行运参考',
    'return' => '返照参考',
    '' => '关系参考',
    _ => '关系参考',
  };
}

String _returnTypeLabel(String? type) {
  final normalized = (type ?? '').toLowerCase().trim();
  return switch (normalized) {
    'lunar' => '月返照',
    'solar' => '太阳返照',
    '' => '返照',
    _ => '返照',
  };
}

AstroAdvancedPreviewRequests buildAstroAdvancedPreviewRequests(
  Map<String, dynamic> profile,
  AstroChartRouteMode routeMode, {
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();
  final natal = _buildSubjectRequest(profile, name: _subjectName(profile));
  final pair = _buildSubjectRequest(
    profile,
    name: '${natal['name']} 对照',
    birthday: _shiftDate(natal['birthday']?.toString(), 17, referenceNow: now),
    birthTime: _shiftTime(natal['birth_time']?.toString(), 97),
  );
  final transit = _buildSubjectRequest(
    profile,
    name: '行运 ${_subjectName(profile)}',
    birthday: _formatDate(now),
    birthTime: _formatTime(now),
  );
  final comparisonSecond = _buildSubjectRequest(
    profile,
    name: '${natal['name']} 对比',
    birthday: _shiftDate(natal['birthday']?.toString(), -23, referenceNow: now),
    birthTime: _shiftTime(natal['birth_time']?.toString(), -83),
  );
  final returnChart = {
    'natal': natal,
    'return_year': now.year,
    'return_type': 'Lunar',
    'route_mode': routeMode.name,
    'return_place': _readString(profile, [
      'birth_place',
      'private_birth_place',
    ]),
    'return_lat': _readDouble(profile, ['birth_lat', 'lat']),
    'return_lng': _readDouble(profile, ['birth_lng', 'lng']),
    'return_tz_str': _readString(profile, ['tz_str']) ?? 'Asia/Shanghai',
    'return_nation': _readString(profile, ['nation']) ?? 'CN',
  };

  return AstroAdvancedPreviewRequests(
    pair: {
      'first': natal,
      'second': pair,
      'pair_mode': 'synastry',
      'route_mode': routeMode.name,
    },
    comparison: {
      'first': natal,
      'second': comparisonSecond,
      'pair_mode': 'comparison',
      'route_mode': routeMode.name,
    },
    transit: {'natal': natal, 'transit': transit, 'route_mode': routeMode.name},
    returnChart: returnChart,
  );
}

Map<String, dynamic> _buildSubjectRequest(
  Map<String, dynamic> profile, {
  String? name,
  String? birthday,
  String? birthTime,
}) {
  final resolvedName = (name ?? _subjectName(profile)).trim();
  return <String, dynamic>{
    'name': resolvedName.isEmpty ? 'EliteSync' : resolvedName,
    'birthday':
        (birthday ??
                _readString(profile, ['birthday']) ??
                _formatDate(DateTime.now()))
            .trim(),
    'birth_time': (birthTime ?? _readString(profile, ['birth_time']) ?? '12:00')
        .trim(),
    'birth_place': _readString(profile, ['birth_place', 'private_birth_place']),
    'birth_lat': _readDouble(profile, ['birth_lat', 'lat']),
    'birth_lng': _readDouble(profile, ['birth_lng', 'lng']),
    'tz_str': _readString(profile, ['tz_str']) ?? 'Asia/Shanghai',
    'nation': _readString(profile, ['nation']) ?? 'CN',
  };
}

String _subjectName(Map<String, dynamic> profile) {
  final raw = _readString(profile, ['name', 'nickname']);
  if (raw != null && raw.trim().isNotEmpty) return raw.trim();
  return 'EliteSync';
}

String _shiftDate(String? value, int days, {DateTime? referenceNow}) {
  final parsed = _parseDate(value);
  if (parsed == null) {
    return _formatDate(
      (referenceNow ?? DateTime.now()).add(Duration(days: days)),
    );
  }
  return _formatDate(parsed.add(Duration(days: days)));
}

String _shiftTime(String? value, int minutes) {
  final parsed = _parseTime(value);
  if (parsed == null) return '12:00';
  final shifted = parsed.add(Duration(minutes: minutes));
  return _formatTime(shifted);
}

DateTime? _parseDate(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  if (match == null) return null;
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

DateTime? _parseTime(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(raw);
  if (match == null) return null;
  return DateTime(
    2000,
    1,
    1,
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
  );
}

String _formatDate(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

String _formatTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.hour)}:${two(value.minute)}';
}

String? _readString(Map<String, dynamic> profile, List<String> keys) {
  for (final key in keys) {
    final raw = profile[key];
    if (raw == null) continue;
    final text = raw.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String? _readText(Map<String, dynamic> map, String key) {
  final raw = map[key];
  if (raw == null) return null;
  final text = raw.toString().trim();
  return text.isEmpty ? null : text;
}

double? _readDouble(Map<String, dynamic> profile, List<String> keys) {
  for (final key in keys) {
    final raw = profile[key];
    if (raw is num) return raw.toDouble();
    final parsed = double.tryParse((raw ?? '').toString());
    if (parsed != null) return parsed;
  }
  return null;
}

List<dynamic> _list(dynamic value) =>
    value is List<dynamic> ? value : const <dynamic>[];

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

String _routeModeLabel(AstroChartRouteMode mode) {
  switch (mode) {
    case AstroChartRouteMode.standard:
      return '标准路线';
    case AstroChartRouteMode.classical:
      return '古典路线';
    case AstroChartRouteMode.modern:
      return '现代路线';
  }
}

String _routeModeLabelText(String mode) {
  switch (mode) {
    case 'standard':
      return '标准路线';
    case 'classical':
      return '古典路线';
    case 'modern':
      return '现代路线';
    default:
      return mode;
  }
}

String _sourceLayerLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'advanced-context' => '高级展示参考',
    'display-only' => '展示参考',
    'derived-only' => '推导参考',
    '' => '展示参考',
    _ => value,
  };
}
