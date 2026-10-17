import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import '../providers/natal_restoration_provider.dart';
import '../providers/astro_chart_settings_provider.dart';
import '../widgets/natal_restoration_charts.dart';

class NatalRestorationPage extends ConsumerStatefulWidget {
  const NatalRestorationPage({super.key});
  @override
  ConsumerState<NatalRestorationPage> createState() =>
      _NatalRestorationPageState();
}

class _NatalRestorationPageState extends ConsumerState<NatalRestorationPage> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController(),
      _time = TextEditingController(),
      _timezone = TextEditingController(text: 'Asia/Shanghai'),
      _latitude = TextEditingController(),
      _longitude = TextEditingController(),
      _place = TextEditingController(),
      _year = TextEditingController();
  String _precision = 'unknown',
      _sex = 'unknown',
      _fold = 'unspecified',
      _zodiac = 'tropical',
      _house = 'placidus',
      _aspect = 'major',
      _orb = 'standard',
      _points = 'core';
  bool _solar = false,
      _explanation = false,
      _busy = false,
      _conflict = false,
      _loaded = false;
  int _revision = 0;
  int _sessionEpoch = 0;
  SessionState? _inputSession;
  Map<String, dynamic>? _profile;
  String? _error;

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _sessionEpoch &&
      natalSessionMatches(session, ref.read(sessionProvider).asData?.value);

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  @override
  void dispose() {
    for (final c in [
      _date,
      _time,
      _timezone,
      _latitude,
      _longitude,
      _place,
      _year,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _reload() async {
    if (_busy) return;
    final epoch = _sessionEpoch;
    setState(() {
      _busy = true;
      _error = null;
      _profile = null;
      _loaded = false;
    });
    SessionState? started;
    try {
      final session = await ref.read(sessionProvider.future);
      started = session;
      if (!_current(session, epoch)) return;
      ref.invalidate(natalRestorationProvider);
      final p = await ref.read(natalRestorationProvider.future);
      if (!_current(session, epoch)) return;
      final input = natalMap(p?['input']), settings = natalMap(p?['settings']);
      setState(() {
        _profile = p;
        _inputSession = session;
        _revision = (p?['input_revision'] as num?)?.toInt() ?? 0;
        _date.text = input['civil_date'] as String? ?? '';
        _time.text = input['civil_time'] as String? ?? '';
        _timezone.text = input['timezone'] as String? ?? 'Asia/Shanghai';
        _latitude.text = input['latitude']?.toString() ?? '';
        _longitude.text = input['longitude']?.toString() ?? '';
        _place.text = input['location_label'] as String? ?? '';
        _precision = input['time_precision'] as String? ?? 'unknown';
        if (_precision == 'minute' && _time.text.length == 8) {
          _time.text = _time.text.substring(0, 5);
        }
        _sex = input['algorithm_sex'] as String? ?? 'unknown';
        _fold = input['fold']?.toString() ?? 'unspecified';
        _zodiac = settings['zodiac_mode'] as String? ?? 'tropical';
        _house = settings['house_system'] as String? ?? 'placidus';
        _aspect = settings['aspect_mode'] as String? ?? 'major';
        _orb = settings['orb_preset'] as String? ?? 'standard';
        _points = settings['point_set'] as String? ?? 'core';
        _solar = settings['true_solar_time'] == true;
        _year.text = settings['target_year']?.toString() ?? '';
        _loaded = true;
        _conflict = false;
      });
    } catch (_) {
      if (mounted && (started == null || _current(started, epoch))) {
        setState(() => _error = '读取失败。未显示之前的结果，请重新读取。');
      }
    } finally {
      if (mounted && epoch == _sessionEpoch) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_busy || !_loaded || _conflict || !_form.currentState!.validate()) {
      return;
    }
    final epoch = _sessionEpoch;
    final session = _inputSession;
    if (session == null || !_current(session, epoch)) return;
    setState(() {
      _busy = true;
      _error = null;
      _profile = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .post(
            '/api/v1/profile/natal',
            options: natalSessionOptions(() => _current(session, epoch)),
            body: {
              'input': {
                'civil_date': _date.text.trim(),
                'civil_time': _precision == 'unknown'
                    ? null
                    : _time.text.trim(),
                'time_precision': _precision,
                'timezone': _timezone.text.trim(),
                'latitude': double.tryParse(_latitude.text.trim()),
                'longitude': double.tryParse(_longitude.text.trim()),
                'fold': int.tryParse(_fold),
                'algorithm_sex': _sex,
                'time_source': _precision == 'unknown'
                    ? 'unknown'
                    : 'user_provided',
                'location_label': _place.text.trim(),
              },
              'settings': {
                'zodiac_mode': _zodiac,
                'house_system': _house,
                'aspect_mode': _aspect,
                'orb_preset': _orb,
                'point_set': _points,
                'true_solar_time': _solar,
                'target_year': int.tryParse(_year.text.trim()),
              },
              'expected_revision': _revision,
            },
          );
      if (!_current(session, epoch)) return;
      final written = natalProfileFromResponse(response);
      // A successful write alone is insufficient: render only a fresh persistent read.
      ref.invalidate(natalRestorationProvider);
      final saved = await ref.read(natalRestorationProvider.future);
      if (!_current(session, epoch)) return;
      if (saved == null) throw const NatalRequestException('保存后未读到持久化资料。');
      if (written == null ||
          written['input_revision'] != saved['input_revision'] ||
          written['input_signature'] != saved['input_signature']) {
        throw const NatalRequestException('保存后资料已被另一处更新，请重新读取再编辑。', 409);
      }
      setState(() {
        _profile = saved;
        _revision = (saved['input_revision'] as num?)?.toInt() ?? _revision;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存并重新读取。计算与独立核验状态见各盘。')));
    } on NatalRequestException catch (e) {
      if (_current(session, epoch)) {
        setState(() {
          _error = '${e.message} 请重新读取后再保存。';
          _conflict = true;
        });
      }
    } catch (_) {
      if (_current(session, epoch)) {
        setState(() {
          _error = '保存或持久化重读失败，当前未展示结果。请重新读取确认。';
          _conflict = true;
        });
      }
    } finally {
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  Widget _choice(
    String label,
    String value,
    Map<String, String> options,
    void Function(String) change,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$label:$value'),
    initialValue: options.containsKey(value) ? value : options.keys.first,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final e in options.entries)
        DropdownMenuItem(value: e.key, child: Text(e.value)),
    ],
    onChanged: _busy
        ? null
        : (v) {
            if (v != null) {
              setState(() {
                change(v);
                _profile = null;
              });
            }
          },
  );
  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      controller: controller,
      enabled: !_busy,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
      keyboardType: keyboard,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: (_) => setState(() => _profile = null),
    ),
  );
  String? _coordinate(String? value, double limit) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final n = double.tryParse(text);
    return n == null || !n.isFinite || n.abs() > limit
        ? '请输入 -$limit 至 $limit 的有限数值'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      final prior = previous?.asData?.value;
      if (prior?.isLoggedIn == true &&
          !natalSessionMatches(prior!, next.asData?.value)) {
        setState(() {
          _sessionEpoch++;
          _profile = null;
          _inputSession = null;
          _busy = false;
          _loaded = false;
          _revision = 0;
          for (final field in [
            _date,
            _time,
            _latitude,
            _longitude,
            _place,
            _year,
          ]) {
            field.clear();
          }
          _error = '登录身份已变化，请重新读取。';
        });
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('三盘本命排盘')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '出生资料是私有计算镜像，不会悄悄修改正式资料。算法性别单独选择；不从公开性别推断。本页结果不参与匹配评分或硬筛选。',
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('重新读取已保存资料（替换当前输入）'),
            ),
            if (_loaded)
              Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field(
                      '出生日期',
                      _date,
                      hint: 'YYYY-MM-DD',
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
                          return '请输入 YYYY-MM-DD';
                        }
                        final d = DateTime.tryParse(s);
                        return d == null ||
                                d.toIso8601String().substring(0, 10) != s
                            ? '日期不存在'
                            : null;
                      },
                    ),
                    _choice('出生时间精度', _precision, {
                      'unknown': '时间未知（不补默认时间）',
                      'minute': '精确到分',
                      'second': '精确到秒',
                    }, (v) => _precision = v),
                    if (_precision != 'unknown')
                      _field(
                        '出生当地时间',
                        _time,
                        hint: _precision == 'second' ? 'HH:mm:ss' : 'HH:mm',
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          final pattern = _precision == 'second'
                              ? r'^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$'
                              : r'^([01]\d|2[0-3]):[0-5]\d$';
                          return RegExp(pattern).hasMatch(s)
                              ? null
                              : '时间格式与精度不一致';
                        },
                      ),
                    _field(
                      'IANA时区',
                      _timezone,
                      hint: 'Asia/Shanghai / America/New_York',
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? '必须明确选择时区' : null,
                    ),
                    _choice('夏令时重叠时间（fold）', _fold, {
                      'unspecified': '未指定（遇重叠时须选择）',
                      '0': '第一次当地时间',
                      '1': '第二次当地时间',
                    }, (v) => _fold = v),
                    _field('出生地点名称（可选）', _place),
                    _field(
                      '纬度 WGS84（可选）',
                      _latitude,
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (v) => _coordinate(v, 90),
                    ),
                    _field(
                      '经度 WGS84（可选）',
                      _longitude,
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (v) {
                        final err = _coordinate(v, 180);
                        if (err != null) return err;
                        return _latitude.text.trim().isEmpty !=
                                _longitude.text.trim().isEmpty
                            ? '经纬度须成对提供'
                            : null;
                      },
                    ),
                    _choice('算法使用性别', _sex, {
                      'unknown': '未知（相关运限不计算）',
                      'male': '男（算法规则）',
                      'female': '女（算法规则）',
                    }, (v) => _sex = v),
                    const SizedBox(height: 12),
                    Text('计算设置', style: Theme.of(context).textTheme.titleLarge),
                    _choice('黄道', _zodiac, {
                      'tropical': '回归黄道',
                      'sidereal': '恒星黄道（以服务端准入规则为准）',
                    }, (v) => _zodiac = v),
                    _choice('宫制', _house, {
                      'placidus': 'Placidus',
                      'whole': '整宫制',
                      'alcabitius': 'Alcabitius',
                    }, (v) => _house = v),
                    _choice('相位集合', _aspect, {
                      'major': '主要相位',
                      'standard': '标准相位',
                      'extended': '扩展相位',
                    }, (v) => _aspect = v),
                    _choice('容许度', _orb, {
                      'tight': '紧（3°）',
                      'standard': '标准（6°）',
                      'wide': '宽（8°）',
                    }, (v) => _orb = v),
                    _choice('本命点集合', _points, {
                      'core': '核心十主体',
                      'extended': '扩展点',
                      'full': '完整准入点',
                    }, (v) => _points = v),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('使用真太阳时'),
                      subtitle: const Text('需要明确坐标；以返回的时间来源与计算规则为准'),
                      value: _solar,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() {
                              _solar = v;
                              _profile = null;
                            }),
                    ),
                    _field(
                      '运限目标年份（可选）',
                      _year,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final y = int.tryParse(v.trim());
                        return y == null || y < 1800 || y > 2100
                            ? '请输入支持范围内的年份'
                            : null;
                      },
                    ),
                    FilledButton.icon(
                      onPressed: _busy || _conflict ? null : _save,
                      icon: const Icon(Icons.save),
                      label: const Text('保存、计算并持久重读'),
                    ),
                  ],
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示解释提示'),
              subtitle: const Text('关闭后仍可查看基础盘与计算详情'),
              value: _explanation,
              onChanged: (v) => setState(() => _explanation = v),
            ),
            if (_profile != null) ...[
              Text(
                '输入版本 $_revision · 结果版本 ${natalText(_profile!['result_revision'])} · ${natalText(_profile!['status'])}',
              ),
              Text(
                '时区 ${natalText(natalMap(_profile!['context'])['timezone'])}；UTC ${natalText(natalMap(_profile!['context'])['utc'])}',
              ),
              NatalRestorationCharts(
                results: natalMap(_profile!['results']),
                explanation: _explanation,
                displayPrefs: ref.watch(astroChartSettingsProvider),
                locationLabel: _place.text,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
