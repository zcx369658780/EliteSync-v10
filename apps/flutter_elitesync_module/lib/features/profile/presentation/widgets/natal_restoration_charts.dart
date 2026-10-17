import 'dart:math' as math;
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

class NatalRestorationCharts extends StatelessWidget {
  const NatalRestorationCharts({
    super.key,
    required this.results,
    this.explanation = false,
    this.section,
    this.displayPrefs,
    this.locationLabel,
  });
  final Map<String, dynamic> results;
  final bool explanation;
  final String? section;
  final AstroChartDisplayPrefs? displayPrefs;
  final String? locationLabel;
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
      child: Padding(
        padding: EdgeInsets.all(prefs.compactDensity ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(
              '计算：${natalText(chart['calculation_status'] ?? chart['status'])}；独立核验：${verified ? oracle : '待核验 ($oracle)'}',
            ),
            if (chart['reason'] != null || chart['reason_codes'] != null)
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
    final palaces = natalList(ziwei['palaces']);
    final planets = natalList(western['planets']);
    return Column(
      children: [
        if (section == null || section == 'bazi')
          _section(context, '八字', bazi, [
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
            const Divider(),
            Text(
              '起运：${natalText(yun['start_user_datetime'] ?? yun['start_solar_datetime'])}${yun['start_user_datetime'] == null && yun['start_solar_datetime'] != null ? '（${natalText(yun['timestamp_frame'])}）' : ''}；${yun['forward'] == null
                  ? '顺逆未知'
                  : yun['forward'] == true
                  ? '顺行'
                  : '逆行'}',
            ),
            Text('时间口径：${natalText(natalMap(bazi['time_basis'])['mode'])}'),
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
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('节气与扩展'),
              children: [
                for (final entry in natalMap(bazi['solar_terms']).entries)
                  if (entry.value is Map)
                    ListTile(
                      title: Text(entry.key),
                      subtitle: Text(
                        '${natalMap(entry.value)['name']} ${natalMap(entry.value)['solar_datetime']}',
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
            ExpansionTile(
              title: const Text('选定运限'),
              tilePadding: EdgeInsets.zero,
              children: [
                Text(
                  '参考日 ${natalText(natalMap(ziwei['selected_horoscope'])['reference_date'])}',
                ),
                for (final key in ['decadal', 'age', 'yearly'])
                  Builder(
                    builder: (_) {
                      final h = natalMap(
                        natalMap(ziwei['selected_horoscope'])[key],
                      );
                      return ListTile(
                        title: Text(key),
                        subtitle: Text(
                          '${natalText(h['heavenlyStem'])}${natalText(h['earthlyBranch'])} ${natalText(h['palaceNames'])}',
                        ),
                      );
                    },
                  ),
              ],
            ),
          ]),
        if (section == null || section == 'western')
          _section(context, '西方本命盘', western, [
            if (planets.isNotEmpty)
              Semantics(
                label: '西方本命星盘示意；精确数值见下方列表',
                child: SizedBox(
                  height: prefs.compactDensity ? 240 : 300,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: NatalWheelPainter(
                      planets,
                      natalList(western['houses']),
                      natalList(western['aspects']),
                      prefs,
                      subtitle:
                          '${natalText(natalMap(western['effective_profile'])['zodiac_mode'])} / ${natalText(natalMap(western['axes'])['effective_house_system'])}',
                      place: locationLabel ?? '',
                    ),
                  ),
                ),
              ),
            if (prefs.showTechnicalParameters)
              Text(
                '黄道 ${natalText(natalMap(western['effective_profile'])['zodiac_mode'])}；宫制 ${natalText(natalMap(western['axes'])['effective_house_system'])}',
              ),
            Text(
              '宫位状态 ${natalText(natalMap(western['axes'])['status'])}${natalMap(western['axes'])['reason'] == null ? '' : ' · ${natalText(natalMap(western['axes'])['reason'])}'}',
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
            if (prefs.showTechnicalParameters)
              Text('扩展点：${natalText(western['extensions_status'])}'),
          ]),
      ],
    );
  }
}

String _degrees(dynamic value) =>
    value is num ? '${value.toStringAsFixed(4)}°' : '未知';

class NatalWheelPainter extends CustomPainter {
  NatalWheelPainter(
    this.planets,
    this.houses,
    this.aspects,
    this.prefs, {
    this.subtitle = '',
    this.place = '',
  });
  final List<dynamic> planets, houses, aspects;
  final AstroChartDisplayPrefs prefs;
  final String subtitle, place;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2),
        radius = math.min(size.width, size.height) / 2 - 25;
    final line = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, line);
    canvas.drawCircle(center, radius * .72, line);
    Offset point(double degrees, double r) =>
        center +
        Offset(
          -math.cos(degrees * math.pi / 180) * r,
          math.sin(degrees * math.pi / 180) * r,
        );
    void label(String text, Offset at) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
    }

    for (var i = 0; i < 12; i++) {
      if (prefs.showChartSignGridLines) {
        canvas.drawLine(
          point(i * 30, radius * .72),
          point(i * 30, radius),
          line,
        );
      }
      if (prefs.showChartSignLabels) {
        label(
          const ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'][i],
          point(i * 30 + 15, radius * .88),
        );
      }
    }
    for (final raw in houses) {
      final h = natalMap(raw);
      if (h['cusp'] is num) {
        final d = (h['cusp'] as num).toDouble();
        if (prefs.showChartHouseLines) {
          canvas.drawLine(center, point(d, radius * .72), line);
        }
        if (prefs.showChartHouseNumbers) {
          label('${h['number']}', point(d + 5, radius * .5));
        }
      }
    }
    for (var i = 0; i < planets.length; i++) {
      final p = natalMap(planets[i]);
      if (p['longitude'] is num) {
        final d = (p['longitude'] as num).toDouble();
        final r = radius * (i.isEven ? 0.64 : 0.56);
        if (prefs.showChartPlanetConnectors) {
          canvas.drawLine(point(d, r), point(d, r - 10), line);
        }
        if (prefs.showChartPlanetMarkers) {
          canvas.drawCircle(point(d, r), 2, Paint()..color = Colors.deepPurple);
        }
        if (prefs.showChartPlanetLabels) {
          label(natalBodyLabel(p['name']), point(d, r - 10));
        }
      }
    }
    if (prefs.showChartAspectLines) {
      final byName = {
        for (final raw in planets)
          natalMap(raw)['name']: natalMap(raw)['longitude'],
      };
      for (final raw in aspects) {
        final edge = natalMap(raw);
        final a = byName[edge['a']], b = byName[edge['b']];
        if (a is num && b is num) {
          canvas.drawLine(
            point(a.toDouble(), radius * .4),
            point(b.toDouble(), radius * .4),
            line,
          );
        }
      }
    }
    if (prefs.showChartCenterTitle) label('本命盘', center + const Offset(0, -12));
    if (prefs.showChartCenterSubtitle) {
      label(subtitle, center + const Offset(0, 2));
    }
    if (prefs.showChartCenterPlace && place.isNotEmpty) {
      label(place, center + const Offset(0, 16));
    }
  }

  @override
  bool shouldRepaint(covariant NatalWheelPainter oldDelegate) => true;
}
