import 'package:flutter_elitesync_module/design_system/components/layout/ui_s3_canvas.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/astro_chart_settings_provider.dart';

Map<String, dynamic> natalMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
List<dynamic> natalList(dynamic value) => value is List ? value : [];
String natalText(dynamic value) => value == null
    ? '未知'
    : value is List
    ? value.join(' · ')
    : '$value';

String natalBodyLabel(dynamic key) =>
    const {
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
      'chiron': '凯龙星',
      'lilith': '莉莉丝',
      'mean_north_node': '平均北交点',
      'true_north_node': '真北交点',
      'mean_south_node': '平均南交点',
      'true_south_node': '真南交点',
      'true_north_lunar_node': '真北交点',
      'true_south_lunar_node': '真南交点',
      'mean_lilith': '平均莉莉丝',
    }[key] ??
    natalText(key);

/// Projection shared by existing detail routes. A pending/failed native record
/// owns the screen too: never substitute legacy estimates for it.
class NatalProjectionView extends ConsumerWidget {
  const NatalProjectionView({super.key, required this.natal, this.section});
  final Map<String, dynamic> natal;
  final String? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = natalMap(natal['input']);
    final settings = natalMap(natal['settings']);
    final status = natal['status']?.toString() ?? 'UNKNOWN';
    final ready = status == 'COMPUTED_UNVERIFIED' || status == 'COMPUTED';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '私有本命计算镜像',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text('仅供本人计算；不改写正式出生资料，不用于匹配硬筛选或关系事实判断。'),
                Text(
                  '状态 $status · 输入版本 ${natalText(natal['input_revision'])} · 结果版本 ${natalText(natal['result_revision'])}',
                ),
                Text(
                  '当地日期 ${natalText(input['civil_date'])}；时间 ${natalText(input['civil_time'])}；精度 ${natalText(input['time_precision'])}',
                ),
                Text(
                  '时区 ${natalText(input['timezone'])}；地点 ${natalText(input['location_label'])}',
                ),
                Text(
                  '黄道 ${natalText(settings['zodiac_mode'])}；宫制 ${natalText(settings['house_system'])}；真太阳时 ${settings['true_solar_time'] == true ? '启用' : '未启用'}',
                ),
                const Text('计算结果与独立准确性核验分别记录；未核字段仍为待核验。'),
              ],
            ),
          ),
        ),
        if (ready)
          NatalRestorationCharts(
            results: natalMap(natal['results']),
            section: section,
            displayPrefs: ref.watch(astroChartSettingsProvider),
            locationLabel: input['location_label']?.toString(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              status == 'FAILED'
                  ? '本次计算失败，请到三盘本命输入页重新读取并检查输入。未展示旧盘替代结果。'
                  : '本次结果尚未就绪，请重新读取状态。未展示旧盘替代结果。',
            ),
          ),
      ],
    );
  }
}

String _chartState(Object? state) => switch (state) {
  'CALCULATED' || 'COMPUTED' => '已计算',
  'COMPUTED_UNVERIFIED' => '已计算，精度待独立核验',
  'VERIFIED' => '已核验',
  'UNVERIFIED' => '待核验',
  'NOT_REQUESTED' => '未请求计算',
  'FAILED' => '计算失败，请核对资料后重试',
  'PENDING' => '等待计算',
  'UNAVAILABLE' => '当前条件下无法计算',
  _ => '状态待确认',
};

String _chartSetting(Object? value) => switch (value) {
  'civil' => '出生地当地时间',
  'tropical' => '回归黄道',
  'sidereal' => '恒星黄道',
  'placidus' => '普拉西德宫制',
  'whole' => '整宫制',
  'alcabitius' => '阿尔卡比提乌斯宫制',
  _ => natalText(value),
};

class NatalRestorationCharts extends StatelessWidget {
  const NatalRestorationCharts({
    super.key,
    required this.results,
    this.explanation = false,
    this.section,
    this.displayPrefs,
    this.locationLabel,
    this.backdrop,
  });
  final Map<String, dynamic> results;
  final bool explanation;
  final String? section;
  final AstroChartDisplayPrefs? displayPrefs;
  final String? locationLabel;
  final UiS3Backdrop? backdrop;
  AstroChartDisplayPrefs get prefs =>
      displayPrefs ?? AstroChartDisplayPrefs.defaults();

  Widget _section(
    BuildContext context,
    String title,
    Map<String, dynamic> chart,
    List<Widget> children,
  ) {
    final oracle = natalText(chart['oracle_status']);
    final verified = oracle == 'VERIFIED';
    return Card(
      color: backdrop?.surfaceOf(context),
      child: Padding(
        padding: EdgeInsets.all(prefs.compactDensity ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (backdrop == null)
              Text(
                '计算：${natalText(chart['calculation_status'] ?? chart['status'])}；独立核验：${verified ? oracle : '待核验 ($oracle)'}',
              )
            else ...[
              Text(
                '${_chartState(chart['calculation_status'] ?? chart['status'])} · 独立核验${_chartState(oracle)}',
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('计算依据与限制'),
                children: [
                  Text(
                    '计算状态码 ${natalText(chart['calculation_status'] ?? chart['status'])} · 核验状态码 $oracle',
                  ),
                  if (chart['reason'] != null || chart['reason_codes'] != null)
                    Text(
                      '限制 ${natalText(chart['reason'] ?? chart['reason_codes'])}',
                    ),
                ],
              ),
            ],
            if (backdrop == null &&
                (chart['reason'] != null || chart['reason_codes'] != null))
              Text('限制：${natalText(chart['reason'] ?? chart['reason_codes'])}'),
            const SizedBox(height: 12),
            ...children,
            if (explanation)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('本页仅呈现所选计算口径，不构成命运、健康或关系客观判断，也不增加匹配筛选。'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bazi = natalMap(results['bazi']);
    final ziwei = natalMap(results['ziwei']);
    final western = natalMap(results['western']);
    final pillars = natalMap(bazi['pillars']);
    final yun = natalMap(bazi['yun']);
    final elements = natalMap(bazi['five_elements']);
    final visibleElements = natalMap(elements['visible_counts']);
    final hiddenElements = natalMap(elements['hidden_stem_counts']);
    final palaces = natalList(ziwei['palaces']);
    final planets = natalList(western['planets']);
    return Column(
      children: [
        if (section == null || section == 'bazi')
          _section(context, '八字', bazi, [
            if (backdrop == UiS3Backdrop.bazi) ...[
              _BaziPillars(pillars: pillars),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('藏干、十神与纳音'),
                children: [
                  for (final entry in _BaziPillars.names.entries)
                    ListTile(
                      title: Text(entry.value),
                      subtitle: Text(
                        [
                          '藏干 ${natalText(natalMap(pillars[entry.key])['hidden_stems'])}',
                          '十神 ${natalText(natalMap(pillars[entry.key])['ten_god_stem'])}',
                          '纳音 ${natalText(natalMap(pillars[entry.key])['na_yin'])}',
                        ].join(' · '),
                      ),
                    ),
                ],
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in const {
                    'year': '年柱',
                    'month': '月柱',
                    'day': '日柱',
                    'hour': '时柱',
                  }.entries)
                    Expanded(
                      child: Column(
                        children: [
                          Text(entry.value),
                          Text(
                            natalText(natalMap(pillars[entry.key])['gan_zhi']),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '藏干 ${natalText(natalMap(pillars[entry.key])['hidden_stems'])}',
                          ),
                          Text(
                            '十神 ${natalText(natalMap(pillars[entry.key])['ten_god_stem'])}',
                          ),
                          Text(
                            '纳音 ${natalText(natalMap(pillars[entry.key])['na_yin'])}',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            if (backdrop == UiS3Backdrop.bazi &&
                visibleElements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('五行分布', style: Theme.of(context).textTheme.titleSmall),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final entry in visibleElements.entries)
                    Chip(label: Text('${entry.key} ${natalText(entry.value)}')),
                ],
              ),
              if (hiddenElements.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('藏干五行'),
                  children: [
                    Text(
                      hiddenElements.entries
                          .map(
                            (entry) => '${entry.key} ${natalText(entry.value)}',
                          )
                          .join(' · '),
                    ),
                    const Text('这里显示出现次数，可用于了解盘面结构。'),
                  ],
                ),
            ],
            const Divider(),
            Text(
              '起运：${natalText(yun['start_user_datetime'] ?? yun['start_solar_datetime'])}${yun['start_user_datetime'] == null && yun['start_solar_datetime'] != null ? '（${natalText(yun['timestamp_frame'])}）' : ''}；${yun['forward'] == null
                  ? '顺逆未知'
                  : yun['forward'] == true
                  ? '顺行'
                  : '逆行'}',
            ),
            Text(
              '时间依据 · ${_chartSetting(natalMap(bazi['time_basis'])['mode'])}',
            ),
            if (natalMap(
                  natalMap(bazi['time_basis'])['term_time_context'],
                )['utc_interpretation'] ==
                'PRE_1960_CIVIL_LABEL_AS_UT1')
              const Text('1960年前的时间采用历史模型近似，不能当作精确UTC。'),
            if (natalMap(
                  natalMap(bazi['time_basis'])['term_time_context'],
                )['accuracy_status'] ==
                'FUTURE_ASSUMPTION')
              const Text('未来时刻按当前闰秒表推算，实际未来闰秒未知。'),
            if (natalMap(yun['calendar_policy'])['id'] != null)
              const Text('交运采用兼容公历换算；保留分秒不代表秒级准确性。'),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('大运与流年'),
              children: [
                for (final raw in natalList(bazi['da_yun']))
                  Builder(
                    builder: (_) {
                      final cycle = natalMap(raw);
                      return ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          '${cycle['kind'] == 'pre_yun' ? '起运前' : natalText(cycle['gan_zhi'])}  ${natalText(cycle['start_year'])}–${natalText(cycle['end_year'])}',
                        ),
                        children: [
                          Wrap(
                            spacing: 12,
                            children: [
                              for (final item in natalList(cycle['liu_nian']))
                                Text(
                                  '${natalMap(item)['year']} ${natalMap(item)['gan_zhi']}',
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('节气与扩展'),
              children: [
                for (final entry in natalMap(bazi['solar_terms']).entries)
                  if (entry.value is Map)
                    ListTile(
                      title: Text(entry.key),
                      subtitle: Text(
                        '${natalMap(entry.value)['name']} ${natalMap(entry.value)['solar_datetime']}（${natalText(natalMap(entry.value)['timestamp_frame'])}）',
                      ),
                    ),
                for (final entry in natalMap(bazi['extensions']).entries)
                  if (entry.value is Map)
                    ListTile(
                      title: Text(entry.key),
                      subtitle: Text(
                        natalText(natalMap(entry.value)['gan_zhi']),
                      ),
                    ),
              ],
            ),
          ]),
        if (section == null || section == 'ziwei')
          _section(context, '紫微斗数', ziwei, [
            Text(
              '命宫：${natalText(ziwei['soul_palace_branch'])}  身宫：${natalText(ziwei['body_palace_branch'])}  ${natalText(ziwei['five_elements_class'])}',
            ),
            if (backdrop == UiS3Backdrop.ziwei && palaces.length == 12)
              _ZiweiPalaceBoard(palaces: palaces, backdrop: backdrop!)
            else
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final raw in palaces)
                      Builder(
                        builder: (_) {
                          final p = natalMap(raw);
                          return SizedBox(
                            width: (constraints.maxWidth - 6) / 2,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p['name']} ${p['heavenly_stem']}${p['earthly_branch']}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    for (final group in [
                                      'major_stars',
                                      'minor_stars',
                                      'adjective_stars',
                                    ])
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          for (final s in natalList(p[group]))
                                            Text(
                                              '${natalMap(s)['name']} ${natalMap(s)['brightness'] ?? ''} ${natalMap(s)['natal_transformation'] ?? ''}',
                                            ),
                                        ],
                                      ),
                                    Text(
                                      '大限 ${natalText(natalMap(p['decadal'])['range'])}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ExpansionTile(
              title: const Text('命宫飞星与自化'),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final raw in natalList(
                  ziwei['soul_palace_flying_transformations'],
                ))
                  Builder(
                    builder: (_) {
                      final e = natalMap(raw);
                      return ListTile(
                        title: Text(
                          '${e['source_palace']} → ${e['target_palace']}',
                        ),
                        subtitle: Text(
                          '${e['star']} ${e['transformation']}${e['is_self_transformation'] == true ? ' · 自化' : ''} · 待核验',
                        ),
                      );
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title: const Text('十二宫飞化与四化规则'),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final raw in natalList(ziwei['mutagen_table']))
                  ListTile(
                    title: Text('${natalMap(raw)['heavenly_stem']}干'),
                    subtitle: Text(
                      natalList(natalMap(raw)['transformations'])
                          .map(
                            (e) =>
                                '${natalMap(e)['star']}化${natalMap(e)['transformation']}',
                          )
                          .join(' · '),
                    ),
                  ),
                for (final raw in natalList(ziwei['flying_transformations']))
                  ListTile(
                    dense: true,
                    title: Text(
                      '${natalMap(raw)['source_palace']} → ${natalMap(raw)['target_palace']}',
                    ),
                    subtitle: Text(
                      '${natalMap(raw)['star']}化${natalMap(raw)['transformation']} ${natalMap(raw)['is_self_transformation'] == true ? '自化' : ''} · 待核验',
                    ),
                  ),
              ],
            ),
            _selectedHoroscope(ziwei, palaces),
          ]),
        if (section == null || section == 'western')
          _section(context, '西方本命盘', western, [
            if (natalMap(western['sidereal_reference'])['display_name_zh'] !=
                null)
              Text(
                natalText(
                  natalMap(western['sidereal_reference'])['display_name_zh'],
                ),
              ),
            if (planets.any((raw) => natalMap(raw)['name'] == 'mean_lilith'))
              const Text('平均莉莉丝：平均月球远地点；非瞬时真实远地点。'),
            if (planets.isNotEmpty)
              Semantics(
                label: '西方本命星盘示意；精确数值见下方列表',
                child: AspectRatio(
                  aspectRatio: 1,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: NatalWheelPainter(
                        planets,
                        natalList(western['houses']),
                        natalList(western['aspects']),
                        prefs,
                        subtitle:
                            '${_chartSetting(natalMap(western['effective_profile'])['zodiac_mode'])} / ${_chartSetting(natalMap(western['axes'])['effective_house_system'])}',
                        place: locationLabel ?? '',
                        dark: Theme.of(context).brightness == Brightness.dark,
                        textScaler: MediaQuery.textScalerOf(context),
                      ),
                    ),
                  ),
                ),
              ),
            if (planets.isNotEmpty && prefs.showChartPlanetLabels)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('密集区域可能省略盘内标签。完整名称和黄经见位置列表。'),
              ),
            if (prefs.showTechnicalParameters)
              Text(
                '黄道 ${_chartSetting(natalMap(western['effective_profile'])['zodiac_mode'])} · 宫制 ${_chartSetting(natalMap(western['axes'])['effective_house_system'])}',
              ),
            Text(
              '宫位 · ${backdrop == null ? natalText(natalMap(western['axes'])['status']) : _chartState(natalMap(western['axes'])['status'])}${natalMap(western['axes'])['reason'] == null ? '' : ' · ${natalText(natalMap(western['axes'])['reason'])}'}',
            ),
            if (!prefs.showPlanetSummary &&
                prefs.showChartPlanetLabels &&
                planets.isNotEmpty)
              ExpansionTile(
                title: const Text('行星位置列表'),
                children: [
                  for (final raw in planets)
                    ListTile(
                      title: Text(natalBodyLabel(natalMap(raw)['name'])),
                      subtitle: Text(
                        '黄经 ${_degrees(natalMap(raw)['longitude'])}',
                      ),
                    ),
                ],
              ),
            if (prefs.showPlanetSummary)
              for (final raw in planets)
                Builder(
                  builder: (_) {
                    final p = natalMap(raw);
                    return ListTile(
                      dense: true,
                      title: Text(
                        '${natalBodyLabel(p['name'])}${p['retrograde'] == true ? ' · 逆行' : ''}',
                      ),
                      subtitle: Text(
                        '黄经 ${_degrees(p['longitude'])} · 纬度 ${_degrees(p['latitude'])} · 宫 ${natalText(p['house'])}',
                      ),
                    );
                  },
                ),
            if (prefs.showHouseSummary)
              ExpansionTile(
                title: const Text('四轴与十二宫'),
                tilePadding: EdgeInsets.zero,
                children: [
                  for (final key in [
                    'ascendant',
                    'midheaven',
                    'descendant',
                    'imum_coeli',
                  ])
                    ListTile(
                      dense: true,
                      title: Text(key.toUpperCase()),
                      trailing: Text(_degrees(natalMap(western['axes'])[key])),
                    ),
                  for (final raw in natalList(western['houses']))
                    ListTile(
                      dense: true,
                      title: Text('第 ${natalMap(raw)['number']} 宫'),
                      trailing: Text(_degrees(natalMap(raw)['cusp'])),
                    ),
                ],
              ),
            if (prefs.showAspectSummary)
              ExpansionTile(
                title: const Text('相位'),
                tilePadding: EdgeInsets.zero,
                children: [
                  for (final raw in natalList(western['aspects']))
                    Builder(
                      builder: (_) {
                        final a = natalMap(raw);
                        return ListTile(
                          dense: true,
                          title: Text(
                            '${natalBodyLabel(a['a'])} — ${natalBodyLabel(a['b'])} · ${a['type']}',
                          ),
                          subtitle: Text(
                            '夹角 ${_degrees(a['separation'])}；偏差 ${_degrees(a['deviation'])}；容许 ${_degrees(a['orb'])}',
                          ),
                        );
                      },
                    ),
                ],
              ),
            if (planets.any((raw) => natalMap(raw)['name'] == 'chiron'))
              ExpansionTile(
                title: const Text('凯龙星数据来源'),
                tilePadding: EdgeInsets.zero,
                children: [
                  for (final raw in planets)
                    if (natalMap(raw)['name'] == 'chiron')
                      SelectableText(
                        natalText(natalMap(raw)['source_attribution']),
                      ),
                  const Text('采用已署名的 Lowell 轨道资料在本地推算。独立样本对照不代表对全部日期的连续误差保证。'),
                ],
              ),
            if (prefs.showTechnicalParameters)
              Text('扩展点：${natalText(western['extensions_status'])}'),
          ]),
      ],
    );
  }

  Widget _selectedHoroscope(Map<String, dynamic> ziwei, List<dynamic> palaces) {
    final selected = natalMap(ziwei['selected_horoscope']);
    final status = selected['calculation_status'];
    return ExpansionTile(
      title: const Text('选定运限'),
      tilePadding: EdgeInsets.zero,
      children: [
        if (status != 'CALCULATED')
          Text(status == 'NOT_REQUESTED' ? '未请求运限计算' : '运限结果未知或尚未就绪')
        else ...[
          Text(
            '目标年份 ${natalText(selected['target_year'])}；'
            '参考日 ${natalText(selected['reference_date'])}；'
            '参考时刻 ${natalText(selected['reference_time'])}',
          ),
          const Text('以下运限按参考时刻选取，不代表目标年份全年恒定。'),
          const Text('独立核验：待核验'),
          for (final key in ['decadal', 'age', 'yearly'])
            if (natalMap(selected[key]).isNotEmpty)
              _horoscopeLayer(key, natalMap(selected[key]), palaces),
        ],
      ],
    );
  }

  Widget _horoscopeLayer(
    String key,
    Map<String, dynamic> layer,
    List<dynamic> palaces,
  ) {
    // Engine arrays use the natal palace's explicit index, never its position
    // in a filtered/reordered UI list, nor this layer's selected index.
    dynamic at(dynamic values, dynamic index) {
      final list = natalList(values);
      return index is int && index >= 0 && index < list.length
          ? list[index]
          : null;
    }

    String palaceLabel(Map<String, dynamic> palace) =>
        '${natalText(palace['earthly_branch'])}宫（本命${natalText(palace['name'])}）';
    String transformationLocation(dynamic star) {
      if (star == null || star == '') return '本命落宫未提供';
      final matches = palaces
          .map(natalMap)
          .where(
            (palace) => ['major_stars', 'minor_stars', 'adjective_stars'].any(
              (group) => natalList(
                palace[group],
              ).any((raw) => natalMap(raw)['name'] == star),
            ),
          );
      return matches.isEmpty
          ? '本命落宫未提供'
          : '本命落宫 ${matches.map(palaceLabel).join('、')}';
    }

    final name = layer['name']?.toString();
    final title = name == null || name.isEmpty
        ? const {'decadal': '运限', 'age': '小限', 'yearly': '流年'}[key]!
        : name;
    if (layer['calculation_status'] == 'NOT_APPLICABLE') {
      final outsideRange = natalList(
        layer['reason_codes'],
      ).contains('OUTSIDE_DEFINED_PERIOD_RANGE');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(
          '不适用：${outsideRange ? '超出已定义的运限范围' : '此参考时刻无适用运限'}'
          '${layer['nominalAge'] == null ? '' : '；名义年龄 ${layer['nominalAge']}岁'}',
        ),
      );
    }
    final transformations = natalList(layer['mutagen']);
    final decorations = natalMap(layer['yearlyDecStar']);
    final anchors = palaces
        .map(natalMap)
        .where((p) => layer['index'] is int && p['index'] == layer['index']);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        '干支 ${natalText(layer['heavenlyStem'])}${natalText(layer['earthlyBranch'])}'
        '${layer['nominalAge'] == null ? '' : '；名义年龄 ${layer['nominalAge']}岁'}',
      ),
      children: [
        if (anchors.isNotEmpty)
          Text('$title命宫对应 ${anchors.map(palaceLabel).join('、')}'),
        if (transformations.isNotEmpty) ...[
          const Text('运限四化（禄、权、科、忌）· 待核验'),
          for (var i = 0; i < math.min(4, transformations.length); i++)
            ListTile(
              dense: true,
              title: Text(
                '${transformations[i]}化${const ['禄', '权', '科', '忌'][i]}',
              ),
              subtitle: Text(transformationLocation(transformations[i])),
            ),
        ],
        ExpansionTile(
          title: const Text('宫职与流曜详情'),
          tilePadding: EdgeInsets.zero,
          children: [
            for (final palace in palaces.map(natalMap))
              ListTile(
                dense: true,
                title: Text(
                  '${natalText(at(layer['palaceNames'], palace['index']))} → ${palaceLabel(palace)}',
                ),
                subtitle: Text(
                  [
                    if (at(layer['stars'], palace['index']) is List)
                      '流曜：${natalList(at(layer['stars'], palace['index'])).isEmpty ? '无' : natalList(at(layer['stars'], palace['index'])).map((raw) {
                              final star = natalMap(raw);
                              return '${natalText(star['name'])}'
                                  '${star['brightness'] == null ? '' : '（亮度 ${star['brightness']}，待核验）'}'
                                  '${star['natal_transformation'] == null ? '' : ' 化${star['natal_transformation']}'}';
                            }).join(' · ')}',
                    if (at(decorations['suiqian12'], palace['index']) != null)
                      '岁前：${at(decorations['suiqian12'], palace['index'])}',
                    if (at(decorations['jiangqian12'], palace['index']) != null)
                      '将前：${at(decorations['jiangqian12'], palace['index'])}',
                  ].join('\n'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _degrees(dynamic value) =>
    value is num ? '${value.toStringAsFixed(4)}°' : '未知';

class _BaziPillars extends StatelessWidget {
  const _BaziPillars({required this.pillars});
  final Map<String, dynamic> pillars;
  static const names = {'year': '年柱', 'month': '月柱', 'day': '日柱', 'hour': '时柱'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final large = MediaQuery.textScalerOf(context).scale(16) > 23;
    return LayoutBuilder(
      builder: (context, box) {
        final columns = large || box.maxWidth < 240 ? 2 : 4;
        final width = (box.maxWidth - (columns - 1) * 6) / columns;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final entry in names.entries)
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceContainerHighest
                      : UiS3Backdrop.bazi.alternate,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(entry.value, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 5),
                    Text(
                      natalText(natalMap(pillars[entry.key])['gan_zhi']),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ZiweiPalaceBoard extends StatefulWidget {
  const _ZiweiPalaceBoard({required this.palaces, required this.backdrop});
  final List<dynamic> palaces;
  final UiS3Backdrop backdrop;

  @override
  State<_ZiweiPalaceBoard> createState() => _ZiweiPalaceBoardState();
}

class _ZiweiPalaceBoardState extends State<_ZiweiPalaceBoard> {
  Object? _selected;

  Future<void> _showPalace(
    BuildContext context,
    Map<String, dynamic> palace,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${palace['name']} ${palace['heavenly_stem']}${palace['earthly_branch']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final group in const {
              'major_stars': '主星',
              'minor_stars': '辅星',
              'adjective_stars': '杂曜',
            }.entries)
              if (natalList(palace[group.key]).isNotEmpty)
                ListTile(
                  title: Text(group.value),
                  subtitle: Text(
                    natalList(palace[group.key])
                        .map((star) {
                          final data = natalMap(star);
                          return [
                                data['name'],
                                data['brightness'],
                                data['natal_transformation'],
                              ]
                              .where((item) => item != null && item != '')
                              .join(' ');
                        })
                        .join(' · '),
                  ),
                ),
            ListTile(
              title: Text(
                '大限 ${natalText(natalMap(palace['decadal'])['range'])}',
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final palaces = widget.palaces;
    final backdrop = widget.backdrop;
    final byBranch = {
      for (final raw in palaces) natalMap(raw)['earthly_branch']: natalMap(raw),
    };
    final theme = Theme.of(context);
    const grid = [
      ['巳', '午', '未', '申'],
      ['辰', '', '', '酉'],
      ['卯', '', '', '戌'],
      ['寅', '丑', '子', '亥'],
    ];
    final complete = grid
        .expand((row) => row)
        .where((key) => key.isNotEmpty)
        .every(byBranch.containsKey);
    Widget tile(Map<String, dynamic> palace) {
      final branch = palace['earthly_branch'];
      final selected = _selected == branch;
      final stars = natalList(
        palace['major_stars'],
      ).map((item) => natalMap(item)['name']).whereType<String>().join(' ');
      return Semantics(
        selected: selected,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: selected
                ? theme.colorScheme.primary
                : theme.brightness == Brightness.dark
                ? theme.colorScheme.surfaceContainerHighest
                : backdrop.alternate,
            foregroundColor: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            minimumSize: const Size(48, 68),
            padding: const EdgeInsets.all(4),
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () {
            setState(() => _selected = branch);
            _showPalace(context, palace);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${palace['name']} $branch',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (stars.isNotEmpty)
                Text(
                  stars,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
            ],
          ),
        ),
      );
    }

    if (!complete ||
        MediaQuery.textScalerOf(context).scale(14) > 21 ||
        MediaQuery.sizeOf(context).width < 340) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [for (final raw in palaces) tile(natalMap(raw))],
      );
    }
    return Column(
      children: [
        for (final row in grid)
          Row(
            children: [
              for (final branch in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: branch.isEmpty
                        ? const SizedBox(height: 56)
                        : tile(byBranch[branch]!),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Label rectangles are view coordinates. The original longitude is used only
/// for the marker and never rewritten by this layout.
Rect? placeNatalWheelLabel({
  required Size extent,
  required Rect bounds,
  required Iterable<Offset> candidates,
  required List<Rect> occupied,
}) {
  for (final center in candidates) {
    final box = Rect.fromCenter(
      center: center,
      width: extent.width,
      height: extent.height,
    );
    final padded = box.inflate(2);
    if (padded.left < bounds.left ||
        padded.right > bounds.right ||
        padded.top < bounds.top ||
        padded.bottom > bounds.bottom ||
        occupied.any(padded.overlaps)) {
      continue;
    }
    occupied.add(padded);
    return box;
  }
  return null;
}

class NatalWheelPainter extends CustomPainter {
  NatalWheelPainter(
    this.planets,
    this.houses,
    this.aspects,
    this.prefs, {
    this.subtitle = '',
    this.place = '',
    this.dark = false,
    this.textScaler = TextScaler.noScaling,
  });
  final List<dynamic> planets, houses, aspects;
  final AstroChartDisplayPrefs prefs;
  final String subtitle, place;
  final bool dark;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - 9;
    if (radius < 20) return;
    final center = size.center(Offset.zero);
    final bounds = (Offset.zero & size).deflate(3);
    final occupied = <Rect>[];
    final ink = dark ? const Color(0xffece6f7) : const Color(0xff392d50);
    final track = dark ? const Color(0xffac9cbe) : const Color(0xff7d6a91);
    final line = Paint()
      ..color = track
      ..style = PaintingStyle.stroke;
    final guide = Paint()
      ..color = track.withValues(alpha: .63)
      ..strokeWidth = .8;
    final marker = Paint()..color = ink;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = dark ? const Color(0xff342842) : const Color(0xfff1eaf6),
    );
    for (final fraction in const [1.0, .79, .58]) {
      canvas.drawCircle(center, radius * fraction, line);
    }

    Offset point(double degrees, double r) =>
        center +
        Offset(
          -math.cos(degrees * math.pi / 180) * r,
          math.sin(degrees * math.pi / 180) * r,
        );

    void label(
      String text,
      Iterable<Offset> candidates, {
      Offset? origin,
      double fontSize = 11,
    }) {
      if (text.isEmpty) return;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: fontSize, color: ink),
        ),
        textScaler: textScaler,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width * .43);
      try {
        final box = placeNatalWheelLabel(
          extent: painter.size,
          bounds: bounds,
          candidates: candidates,
          occupied: occupied,
        );
        if (box == null) return;
        if (origin != null && prefs.showChartPlanetConnectors) {
          final end = Offset(
            origin.dx.clamp(box.left, box.right),
            origin.dy.clamp(box.top, box.bottom),
          );
          canvas.drawLine(origin, end, guide);
        }
        if (origin != null) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(box.inflate(1), const Radius.circular(2)),
            Paint()
              ..color = dark
                  ? const Color(0xff342842)
                  : const Color(0xfff1eaf6),
          );
        }
        painter.paint(canvas, box.topLeft);
      } finally {
        painter.dispose();
      }
    }

    // Exact angular positions are shared by markers, cusps, and aspect endpoints.
    final byName = {
      for (final raw in planets)
        natalMap(raw)['name']: natalMap(raw)['longitude'],
    };
    if (prefs.showChartAspectLines) {
      for (final raw in aspects) {
        final edge = natalMap(raw);
        final a = byName[edge['a']], b = byName[edge['b']];
        if (a is num && b is num && a.isFinite && b.isFinite) {
          canvas.drawLine(
            point(a.toDouble(), radius * .46),
            point(b.toDouble(), radius * .46),
            guide,
          );
        }
      }
    }
    for (var i = 0; i < 12; i++) {
      if (prefs.showChartSignGridLines) {
        canvas.drawLine(
          point(i * 30, radius * .79),
          point(i * 30, radius),
          line,
        );
      }
      if (prefs.showChartSignLabels) {
        label(
          const ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'][i],
          [point(i * 30 + 15, radius * .90)],
        );
      }
    }
    for (final raw in houses) {
      final h = natalMap(raw);
      final cusp = h['cusp'];
      if (cusp is! num || !cusp.isFinite) continue;
      final d = cusp.toDouble();
      if (prefs.showChartHouseLines) {
        canvas.drawLine(point(d, radius * .25), point(d, radius * .79), line);
      }
    }

    if (prefs.showChartCenterTitle ||
        prefs.showChartCenterSubtitle ||
        prefs.showChartCenterPlace) {
      final lines = [
        if (prefs.showChartCenterTitle) '本命盘',
        if (prefs.showChartCenterSubtitle && subtitle.isNotEmpty) subtitle,
        if (prefs.showChartCenterPlace && place.isNotEmpty) place,
      ];
      final spacing = textScaler.scale(12) + 4;
      for (var i = 0; i < lines.length; i++) {
        label(lines[i], [
          center.translate(0, (i - (lines.length - 1) / 2) * spacing),
        ]);
      }
      final centerBand = Rect.fromCenter(
        center: center,
        width: radius * .99,
        height: math.max(radius * .36, spacing * lines.length),
      );
      occupied.add(centerBand);
    }
    for (final raw in planets) {
      final p = natalMap(raw);
      final longitude = p['longitude'];
      if (longitude is! num || !longitude.isFinite) continue;
      final d = longitude.toDouble();
      final at = point(d, radius * .72);
      if (prefs.showChartPlanetMarkers) canvas.drawCircle(at, 2.4, marker);
      if (prefs.showChartPlanetLabels) {
        label(natalBodyLabel(p['name']), [
          for (final delta in const [
            0,
            12,
            -12,
            24,
            -24,
            38,
            -38,
            56,
            -56,
            75,
            -75,
          ])
            for (final level in const [.61, .48, .33])
              point(d + delta, radius * level),
        ], origin: at);
      } else if (prefs.showChartPlanetConnectors) {
        canvas.drawLine(at, point(d, radius * .61), guide);
      }
    }
    if (prefs.showChartHouseNumbers) {
      for (final raw in houses) {
        final h = natalMap(raw);
        final cusp = h['cusp'];
        if (cusp is num && cusp.isFinite) {
          label(natalText(h['number']), [
            point(cusp.toDouble() + 5, radius * .55),
          ], fontSize: 10);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NatalWheelPainter oldDelegate) =>
      !listEquals(oldDelegate.planets, planets) ||
      !listEquals(oldDelegate.houses, houses) ||
      !listEquals(oldDelegate.aspects, aspects) ||
      oldDelegate.prefs != prefs ||
      oldDelegate.subtitle != subtitle ||
      oldDelegate.place != place ||
      oldDelegate.dark != dark ||
      oldDelegate.textScaler != textScaler;
}
