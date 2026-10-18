import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import '../providers/natal_restoration_provider.dart';
import '../widgets/natal_restoration_charts.dart';
import '../widgets/dynamic_chart_wheel.dart';

class DynamicChartPage extends ConsumerStatefulWidget {
  const DynamicChartPage({super.key});
  @override
  ConsumerState<DynamicChartPage> createState() => _DynamicChartPageState();
}

class _Input {
  final fields = {
    for (final k in [
      'civil_date',
      'civil_time',
      'timezone',
      'latitude',
      'longitude',
      'location_label',
      'year',
    ])
      k: TextEditingController(),
  };
  String source = 'manual', precision = 'unknown', fold = 'unspecified';
  int? ownRevision;
  void clear() {
    for (final c in fields.values) {
      c.clear();
    }
    source = 'manual';
    precision = 'unknown';
    fold = 'unspecified';
    ownRevision = null;
  }

  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
  }

  Map<String, dynamic> input({bool solar = false}) => {
    if (!solar) 'civil_date': fields['civil_date']!.text.trim(),
    if (!solar)
      'civil_time': precision == 'unknown'
          ? null
          : fields['civil_time']!.text.trim(),
    if (!solar) 'time_precision': precision,
    if (!solar) 'fold': int.tryParse(fold),
    if (!solar)
      'time_source': precision == 'unknown' ? 'unknown' : 'user_provided',
    if (solar) 'year': int.tryParse(fields['year']!.text.trim()),
    'timezone': fields['timezone']!.text.trim(),
    'latitude': double.tryParse(fields['latitude']!.text.trim()),
    'longitude': double.tryParse(fields['longitude']!.text.trim()),
    'location_label': fields['location_label']!.text.trim(),
  };
  Map<String, dynamic> payload() => source == 'own_natal'
      ? {'source': source, 'revision': ownRevision}
      : {'source': source, 'input': input()};
  void load(Map<String, dynamic> data, {bool event = false}) {
    clear();
    source = event ? 'manual' : data['source']?.toString() ?? 'manual';
    ownRevision = (data['revision'] as num?)?.toInt();
    final i = event ? data : natalMap(data['input']);
    for (final e in fields.entries) {
      e.value.text = i[e.key]?.toString() ?? '';
    }
    precision = i['time_precision']?.toString() ?? 'unknown';
    fold = i['fold']?.toString() ?? 'unspecified';
  }
}

class _DynamicChartPageState extends ConsumerState<DynamicChartPage> {
  final _form = GlobalKey<FormState>();
  final _first = _Input(), _second = _Input(), _event = _Input();
  String _type = 'synastry';
  final _settings = <String, String>{
    'zodiac_mode': 'tropical',
    'house_system': 'placidus',
    'aspect_mode': 'major',
    'orb_preset': 'standard',
    'point_set': 'core',
  };
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _row;
  SessionState? _session;
  int _epoch = 0, _operation = 0, _revision = 0;
  dynamic _id;
  int? _selected;
  int? _nextHistoryId;
  bool _busy = false, _dirty = false, _conflict = false;
  String? _error;
  bool get _dual => _type == 'synastry' || _type == 'comparison';
  bool _current(SessionState? s, int epoch, int op) =>
      s != null &&
      mounted &&
      _epoch == epoch &&
      _operation == op &&
      natalSessionMatches(s, ref.read(sessionProvider).asData?.value);
  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  @override
  void dispose() {
    _epoch++;
    _operation++;
    _first.dispose();
    _second.dispose();
    _event.dispose();
    super.dispose();
  }

  void _edited() {
    _row = null;
    _dirty = true;
    _selected = null;
  }

  void _clear() {
    _first.clear();
    _second.clear();
    _event.clear();
    _row = null;
    _history = [];
    _nextHistoryId = null;
    _id = null;
    _revision = 0;
    _selected = null;
    _error = null;
    _busy = false;
    _dirty = false;
    _conflict = false;
  }

  Map<String, dynamic> _body(NetworkResult<Map<String, dynamic>> response) {
    if (response is NetworkFailure<Map<String, dynamic>>) {
      throw NatalRequestException(
        response.statusCode == 409 ? '资料版本冲突，请重新读取后编辑。' : '请求失败，请检查输入、登录和网络。',
        response.statusCode,
      );
    }
    return (response as NetworkSuccess<Map<String, dynamic>>).data;
  }

  Future<void> _reload() async {
    final epoch = _epoch, op = ++_operation;
    setState(() {
      _busy = true;
      _error = null;
      _row = null;
    });
    SessionState? session;
    try {
      session = await ref.read(sessionProvider.future);
      if (!_current(session, epoch, op)) return;
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/profile/dynamic',
            options: natalSessionOptions(() => _current(session!, epoch, op)),
          );
      if (!_current(session, epoch, op)) return;
      final data = _body(response);
      setState(() {
        _session = session;
        _history = natalList(data['charts']).map(natalMap).toList();
        _nextHistoryId = (data['next_before_id'] as num?)?.toInt();
        _conflict = false;
      });
    } catch (e) {
      if (mounted && epoch == _epoch && op == _operation) {
        setState(() => _error = '读取失败，未展示旧结果。');
      }
    } finally {
      if (mounted && epoch == _epoch && op == _operation) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _open(dynamic id) async {
    final session = _session, epoch = _epoch, op = ++_operation;
    if (session == null || !_current(session, epoch, op)) return;
    setState(() {
      _busy = true;
      _row = null;
      _error = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/profile/dynamic/$id',
            options: natalSessionOptions(() => _current(session, epoch, op)),
          );
      if (!_current(session, epoch, op)) return;
      final row = natalMap(_body(response)['chart']);
      if (row['id'].toString() != id.toString() ||
          row['input_revision'] is! num) {
        throw const NatalRequestException('记录身份无效');
      }
      _accept(row);
    } catch (_) {
      if (_current(session, epoch, op)) {
        setState(() {
          _error = '读取失败，不能使用旧记录。';
          _conflict = true;
        });
      }
    } finally {
      if (_current(session, epoch, op)) setState(() => _busy = false);
    }
  }

  Future<void> _older() async {
    final before = _nextHistoryId, session = _session;
    final epoch = _epoch, op = ++_operation;
    if (before == null || session == null || !_current(session, epoch, op)) {
      return;
    }
    setState(() => _busy = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/profile/dynamic',
            query: {'before_id': before},
            options: natalSessionOptions(() => _current(session, epoch, op)),
          );
      if (!_current(session, epoch, op)) return;
      final data = _body(response);
      setState(() {
        final known = _history.map((row) => row['id']).toSet();
        _history.addAll(
          natalList(
            data['charts'],
          ).map(natalMap).where((row) => !known.contains(row['id'])),
        );
        _nextHistoryId = (data['next_before_id'] as num?)?.toInt();
      });
    } catch (_) {
      if (_current(session, epoch, op)) {
        setState(() => _error = '更早历史读取失败，请重试。');
      }
    } finally {
      if (_current(session, epoch, op)) setState(() => _busy = false);
    }
  }

  void _accept(Map<String, dynamic> row) {
    final request = natalMap(row['request']);
    setState(() {
      _id = row['id'];
      _revision = (row['input_revision'] as num).toInt();
      _type =
          request['type']?.toString() ??
          request['chart_type']?.toString() ??
          row['type']?.toString() ??
          _type;
      _first.load(natalMap(request['first']));
      _second.load(natalMap(request['second']));
      _event.load(natalMap(request['event']), event: true);
      final settings = natalMap(request['settings'] ?? row['settings']);
      for (final k in _settings.keys) {
        _settings[k] = settings[k]?.toString() ?? _settings[k]!;
      }
      _selected =
          (request['selected_event_index'] as num?)?.toInt() ??
          (row['selected_event_index'] as num?)?.toInt();
      _row = row;
      _dirty = false;
      _conflict = false;
    });
  }

  Future<void> _own(_Input target) async {
    final session = _session, epoch = _epoch, op = ++_operation;
    if (session == null || !_current(session, epoch, op)) return;
    setState(() {
      _busy = true;
      _error = null;
      _edited();
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/profile/natal',
            options: natalSessionOptions(() => _current(session, epoch, op)),
          );
      if (!_current(session, epoch, op)) return;
      final profile = natalProfileFromResponse(response);
      if (profile == null || profile['input_revision'] is! num) {
        throw const NatalRequestException('尚无本人已确认快照');
      }
      setState(() {
        target.source = 'own_natal';
        target.ownRevision = (profile['input_revision'] as num).toInt();
      });
    } catch (_) {
      if (_current(session, epoch, op)) {
        setState(() => _error = '本人本命快照不可用，请确认后重读或手填。');
      }
    } finally {
      if (_current(session, epoch, op)) setState(() => _busy = false);
    }
  }

  Future<void> _save({int? eventIndex}) async {
    if (_busy || _conflict || !_form.currentState!.validate()) return;
    final session = _session, epoch = _epoch, op = ++_operation;
    if (session == null || !_current(session, epoch, op)) return;
    final body = <String, dynamic>{
      'chart_type': _type,
      'first': _first.payload(),
      if (_dual) 'second': _second.payload(),
      if (!_dual) 'event': _event.input(solar: _type == 'solar_return'),
      'settings': Map<String, String>.from(_settings),
      'expected_revision': _revision,
      'selected_event_index': eventIndex ?? _selected,
    };
    setState(() {
      _busy = true;
      _error = null;
      _row = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/api/v1/profile/dynamic${_id == null ? '' : '/$_id'}',
        body: body,
        options: natalSessionOptions(() => _current(session, epoch, op)),
      );
      if (!_current(session, epoch, op)) return;
      final written = natalMap(_body(response)['chart']);
      if (written['id'] == null) throw const NatalRequestException('写入身份缺失');
      final read = await client.get(
        '/api/v1/profile/dynamic/${written['id']}',
        options: natalSessionOptions(() => _current(session, epoch, op)),
      );
      if (!_current(session, epoch, op)) return;
      final fresh = natalMap(_body(read)['chart']);
      if (fresh['id'] != written['id'] ||
          fresh['input_revision'] != written['input_revision'] ||
          fresh['result_revision'] != written['result_revision']) {
        throw const NatalRequestException('持久重读版本发生变化', 409);
      }
      _accept(fresh);
      setState(() {
        _history.removeWhere((r) => r['id'] == fresh['id']);
        _history.insert(0, fresh);
      });
    } catch (_) {
      if (_current(session, epoch, op)) {
        setState(() {
          _error = '保存或持久重读失败。请重新读取，未展示旧盘。';
          _conflict = true;
        });
      }
    } finally {
      if (_current(session, epoch, op)) setState(() => _busy = false);
    }
  }

  Widget _choice(
    String label,
    String value,
    Map<String, String> options,
    void Function(String) change,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$label:$value'),
    initialValue: options.containsKey(value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: options.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList(),
    onChanged: _busy
        ? null
        : (v) {
            if (v != null) {
              setState(() {
                change(v);
                _edited();
              });
            }
          },
  );
  Widget _input(String label, _Input input, {bool event = false}) {
    final solar = event && _type == 'solar_return';
    Widget field(String key, String name, {bool required = true}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        key: ValueKey('$label.$key'),
        controller: input.fields[key],
        enabled: !_busy,
        decoration: InputDecoration(labelText: name),
        keyboardType: key == 'latitude' || key == 'longitude'
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : TextInputType.text,
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return '请明确填写';
          if (v != null &&
              v.isNotEmpty &&
              (key == 'latitude' || key == 'longitude')) {
            final n = double.tryParse(v);
            if (n == null ||
                !n.isFinite ||
                n.abs() > (key == 'latitude' ? 90 : 180)) {
              return '坐标无效';
            }
          }
          return null;
        },
        onChanged: (_) => setState(_edited),
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            if (!event) ...[
              _choice(
                '$label来源',
                input.source,
                {'manual': '本人明确手填资料', 'own_natal': '本人私有本命快照'},
                (v) {
                  input.source = v;
                  input.ownRevision = null;
                },
              ),
              if (input.source == 'own_natal') ...[
                Text('仅当前账号资料；已选择版本 ${input.ownRevision ?? '未读取'}'),
                OutlinedButton(
                  onPressed: _busy ? null : () => _own(input),
                  child: const Text('明确选择并读取本人快照'),
                ),
                FormField<int>(
                  validator: (_) =>
                      input.ownRevision == null ? '请先读取本人快照' : null,
                  builder: (s) => s.hasError
                      ? Text(
                          s.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
            if (event || input.source == 'manual') ...[
              if (solar)
                field('year', '目标公历年 YYYY')
              else ...[
                field(
                  'civil_date',
                  event ? '目标／起点当地日期 YYYY-MM-DD' : '出生日期 YYYY-MM-DD',
                ),
                _choice('$label时间精度', input.precision, {
                  'unknown': '时间未知（不填补正午）',
                  'minute': '精确到分钟',
                  'second': '精确到秒',
                }, (v) => input.precision = v),
                if (input.precision != 'unknown')
                  field('civil_time', '当地时间 HH:mm 或 HH:mm:ss'),
                if (event && input.precision == 'unknown')
                  const Text('事件必须明确时间；服务器会拒绝未知事件时间。'),
                _choice('$label重复时刻', input.fold, {
                  'unspecified': '未指定／非重复时刻',
                  '0': '重复时刻第一次',
                  '1': '重复时刻第二次',
                }, (v) => input.fold = v),
              ],
              field('timezone', 'IANA 时区（如 Asia/Shanghai）'),
              field('latitude', '纬度（北为正）'),
              field('longitude', '经度（东为正）'),
              field('location_label', '地点名称'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      final before = previous?.asData?.value, after = next.asData?.value;
      if (before != null && !identical(before, after)) {
        _epoch++;
        _operation++;
        _session = null;
        setState(_clear);
        Future.microtask(_reload);
      }
    });
    final session = ref.watch(sessionProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态星盘与关系盘'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh),
            tooltip: '重新读取',
          ),
        ],
      ),
      body: session?.isLoggedIn != true
          ? const Center(child: Text('请先登录后读取私有排盘。'))
          : Form(
              key: _form,
              child: ListView(
                key: const ValueKey('dynamic-chart-scroll'),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('仅供私有排盘参考，不是关系事实或匹配评分。第二盘仅手填或本人快照，不读取其他账号资料。'),
                  if (_busy) const LinearProgressIndicator(),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (_history.isNotEmpty)
                    DropdownButtonFormField<String>(
                      key: ValueKey('history:$_id:${_history.length}'),
                      initialValue: _history.any((r) => '${r['id']}' == '$_id')
                          ? '$_id'
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: '本人持久历史'),
                      items: _history
                          .map(
                            (r) => DropdownMenuItem(
                              value: '${r['id']}',
                              child: Text(
                                '#${r['id']} ${r['type'] ?? r['chart_type']} · 版本 ${r['input_revision']}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _busy
                          ? null
                          : (v) {
                              if (v != null) _open(v);
                            },
                    ),
                  OutlinedButton(
                    onPressed: _busy || _nextHistoryId == null ? null : _older,
                    child: const Text('加载更早历史'),
                  ),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _id = null;
                            _revision = 0;
                            _conflict = false;
                            _error = null;
                            _edited();
                          }),
                    child: const Text('另建私有盘（保留当前表单）'),
                  ),
                  _choice('盘型', _type, {
                    'synastry': 'Synastry 跨盘相位',
                    'comparison': 'Comparison 双盘对照',
                    'transit': 'Transits 行运',
                    'solar_return': '太阳回归',
                    'lunar_return': '月亮回归',
                  }, (v) => _type = v),
                  if (_type == 'comparison') const Text('双盘对照不是中点 Composite。'),
                  if (_type == 'solar_return')
                    const Text('搜索所选时区目标年的半开窗口；零根明确显示，多根请逐一选择。'),
                  if (_type == 'lunar_return')
                    const Text('搜索明确起点处或之后首次事件；旧年份不自动替代起点。'),
                  _input('第一盘', _first),
                  if (_dual)
                    _input('第二盘', _second)
                  else
                    _input('事件输入', _event, event: true),
                  _choice(
                    '黄道',
                    _settings['zodiac_mode']!,
                    {'tropical': '回归黄道', 'sidereal': '自定义 CRC1956（非官方 Lahiri）'},
                    (v) => _settings['zodiac_mode'] = v,
                  ),
                  _choice(
                    '宫制',
                    _settings['house_system']!,
                    {
                      'placidus': 'Placidus',
                      'whole': '整宫制',
                      'alcabitius': 'Alcabitius',
                    },
                    (v) => _settings['house_system'] = v,
                  ),
                  _choice(
                    '相位集合',
                    _settings['aspect_mode']!,
                    {'major': '主要相位', 'standard': '标准相位', 'extended': '扩展相位'},
                    (v) => _settings['aspect_mode'] = v,
                  ),
                  _choice(
                    '容许度',
                    _settings['orb_preset']!,
                    {'tight': '紧 3°', 'standard': '标准 6°', 'wide': '宽 8°'},
                    (v) => _settings['orb_preset'] = v,
                  ),
                  _choice('点集合', _settings['point_set']!, {
                    'core': '核心十主体',
                    'extended': '扩展',
                    'full': '完整准入点',
                  }, (v) => _settings['point_set'] = v),
                  if (_dirty) const Text('输入／设置已变化，旧结果已隐藏。请保存重算。'),
                  FilledButton(
                    onPressed: _busy || _conflict ? null : () => _save(),
                    child: const Text('保存、计算并持久重读'),
                  ),
                  if (_row != null) _results(_row!),
                ],
              ),
            ),
    );
  }

  Widget _results(Map<String, dynamic> row) {
    final results = natalMap(row['results']),
        events = natalList(results['events']);
    final selected = _selected;
    final event = selected != null && selected >= 0 && selected < events.length
        ? natalMap(events[selected])
        : <String, dynamic>{};
    final first = natalMap(results['first']),
        second = natalMap(event['chart'] ?? results['second']);
    final aspects = natalList(
      event['cross_aspects'] ?? results['cross_aspects'],
    );
    final overlays = natalMap(
      event['house_overlays'] ?? results['house_overlays'],
    );
    final current =
        row['input_revision'] == row['result_revision'] &&
        ['COMPUTED_UNVERIFIED', 'COMPUTED'].contains(row['status']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '输入版本 ${row['input_revision']} · 结果版本 ${row['result_revision']} · ${row['status']}',
        ),
        Text('计算状态 ${results['status']}；独立核验以逐字段来源为准，UNVERIFIED 不表示已验证。'),
        if (results['window'] is Map)
          Text(
            '窗口 ${natalMap(results['window'])['start']} → ${natalMap(results['window'])['end_exclusive']}（终点不包含）',
          ),
        if (results['reason'] != null) Text('原因 ${results['reason']}'),
        if (!current) const Text('结果版本已过期，请重新读取或重算。'),
        if (current) ...[
          if (_type == 'solar_return' || _type == 'lunar_return') ...[
            Text(
              events.isEmpty
                  ? '本窗口无可用事件。请核对搜索状态、范围和输入。'
                  : '找到 ${events.length} 个事件，请明确选择。',
            ),
            for (var i = 0; i < events.length; i++)
              ListTile(
                key: ValueKey('event.$i'),
                title: Text('事件 ${i + 1} · ${natalMap(events[i])['utc']}'),
                subtitle: Text(
                  'bracket ${natalMap(events[i])['bracket_seconds']} 秒 · 残差 ${natalMap(events[i])['residual_degrees']}°',
                ),
                selected: _selected == i,
                trailing: _selected == i ? const Icon(Icons.check) : null,
                onTap: _busy ? null : () => _save(eventIndex: i),
              ),
          ],
          if (first.isNotEmpty &&
              (events.isEmpty ||
                  event.isNotEmpty ||
                  _dual ||
                  _type == 'transit')) ...[
            DynamicChartWheel(
              first: first,
              second: second.isEmpty ? null : second,
              aspects: aspects,
            ),
            _points('第一盘（蓝色）', first),
            if (second.isNotEmpty) _points('第二盘／选定事件（橙色）', second),
            ExpansionTile(
              title: Text('跨盘相位（${aspects.length}）'),
              children: [
                for (final raw in aspects)
                  ListTile(
                    title: Text(
                      '${natalBodyLabel(natalMap(raw)['first'] ?? natalMap(raw)['a'] ?? natalMap(raw)['first_point'])} → ${natalBodyLabel(natalMap(raw)['second'] ?? natalMap(raw)['b'] ?? natalMap(raw)['second_point'])} · ${natalMap(raw)['type']}',
                    ),
                    subtitle: Text(
                      '角差 ${natalMap(raw)['separation']}° · orb ${natalMap(raw)['orb']}° · ${natalMap(raw)['status'] ?? 'UNVERIFIED'} · ${natalMap(raw)['source'] ?? '来源见计算记录'}',
                    ),
                  ),
              ],
            ),
            for (final direction in ['first_in_second', 'second_in_first'])
              ExpansionTile(
                title: Text(
                  '${direction == 'first_in_second' ? '第一盘落第二盘宫位' : '第二盘落第一盘宫位'} · ${natalMap(overlays[direction])['status']}',
                ),
                children: [
                  for (final raw in natalList(
                    natalMap(overlays[direction])['points'],
                  ))
                    ListTile(
                      title: Text(
                        '${natalBodyLabel(natalMap(raw)['name'])} → 第 ${natalMap(raw)['house']} 宫',
                      ),
                    ),
                ],
              ),
          ],
        ],
      ],
    );
  }

  Widget _points(String title, Map<String, dynamic> chart) => ExpansionTile(
    title: Text(title),
    children: [
      Text(
        '状态 ${chart['status']} · profile ${chart['effective_profile']} · 来源 ${chart['source'] ?? chart['provenance'] ?? '见持久计算记录'}',
      ),
      for (final raw in natalList(chart['planets']))
        ListTile(
          title: Text(natalBodyLabel(natalMap(raw)['name'])),
          subtitle: Text(
            '黄经 ${natalMap(raw)['longitude']}° · 速度 ${natalMap(raw)['speed_degrees_per_day'] ?? natalMap(raw)['speed'] ?? natalMap(raw)['speed_longitude']}°/日 · ${natalMap(raw)['retrograde'] == true ? '逆行' : '顺行／以返回状态为准'} · ${natalMap(raw)['status'] ?? 'UNVERIFIED'}',
          ),
        ),
      Text(
        '四轴状态 ${natalMap(chart['axes'])['status']} · ${natalMap(chart['axes'])['reason'] ?? ''}',
      ),
      for (final axis in ['ascendant', 'midheaven', 'descendant', 'imum_coeli'])
        ListTile(
          title: Text(axis),
          subtitle: Text('${natalMap(chart['axes'])[axis] ?? '未知'}°'),
        ),
      for (final raw in natalList(chart['houses']))
        ListTile(
          title: Text('第 ${natalMap(raw)['number']} 宫'),
          subtitle: Text('宫头 ${natalMap(raw)['cusp']}°'),
        ),
    ],
  );
}
