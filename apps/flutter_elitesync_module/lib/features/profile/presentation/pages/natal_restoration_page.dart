import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_detail_dto.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import '../providers/natal_restoration_provider.dart';
import '../providers/astro_chart_settings_provider.dart';
import '../widgets/natal_restoration_charts.dart';
import '../widgets/tool_revision_history.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

Future<bool> _launchExternalMap(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

typedef _BirthPlace = ({
  String label,
  String address,
  String area,
  String pointKind,
  String city,
  String source,
  String matchedName,
  bool approximate,
  double latitude,
  double longitude,
});

class NatalRestorationPage extends ConsumerStatefulWidget {
  const NatalRestorationPage({super.key, this.launchMap = _launchExternalMap});

  final Future<bool> Function(Uri) launchMap;
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
  Map<String, dynamic>? _pendingBody;
  String? _error;

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _sessionEpoch &&
      natalSessionMatches(session, ref.read(sessionProvider).asData?.value);

  bool get _canChangeDraft =>
      _loaded && !_busy && !_conflict && _pendingBody == null;

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
        _pendingBody = null;
      });
    } catch (error) {
      if (mounted && (started == null || _current(started, epoch))) {
        _failure(error, fallback: '读取失败，当前输入已保留，请重新读取。');
      }
    } finally {
      if (mounted && epoch == _sessionEpoch) setState(() => _busy = false);
    }
  }

  Future<void> _importBirthProfile() async {
    final session = _inputSession;
    final epoch = _sessionEpoch;
    if (!_canChangeDraft || session == null || !_current(session, epoch)) {
      return;
    }
    setState(() => _busy = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/profile/basic',
            options: natalSessionOptions(
              () => _current(session, epoch),
            ).copyWith(headers: const {'X-EliteSync-Natal-Places': 'osm-v1'}),
          );
      if (!_current(session, epoch)) return;
      setState(() => _busy = false);
      if (response is! NetworkSuccess<Map<String, dynamic>>) {
        _notice('读取已保存的出生资料失败，请重试。');
        return;
      }
      final saved = ProfileDetailDto.fromJson(response.data);
      final date = saved.birthday.trim();
      final time = saved.birthTime.trim();
      final place = saved.birthPlace?.trim() ?? '';
      final hasDate = _dateError(date) == null;
      final addDate = _date.text.trim().isEmpty && hasDate;
      final addTime =
          hasDate &&
          (addDate || _date.text.trim() == date) &&
          _time.text.trim().isEmpty &&
          _precision == 'unknown' &&
          RegExp(r'^([01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$').hasMatch(time);
      final coordinatesBlank =
          _latitude.text.trim().isEmpty && _longitude.text.trim().isEmpty;
      final currentPlace = _place.text.trim();
      final addPlace =
          currentPlace.isEmpty && coordinatesBlank && place.isNotEmpty;
      final latitude = saved.birthLat;
      final longitude = saved.birthLng;
      final addCoordinates =
          coordinatesBlank &&
          (currentPlace.isEmpty || currentPlace == place) &&
          latitude != null &&
          longitude != null &&
          await _confirm(
            title: '确认坐标系',
            message:
                '只有确认资料中的经纬度为 WGS84 时才可带入。'
                '百度 BD-09、高德 GCJ-02 或来源不明的坐标请选择跳过。',
            confirm: '确认使用 WGS84 坐标',
            cancel: '跳过坐标',
          );
      if (!_current(session, epoch)) return;
      if (!addDate && !addTime && !addPlace && !addCoordinates) {
        _notice('没有可带入的资料，当前输入已保留。');
        return;
      }
      setState(() {
        if (addDate) _date.text = date;
        if (addTime) {
          _time.text = time;
          _precision = time.length == 5 ? 'minute' : 'second';
        }
        if (addPlace) _place.text = place;
        if (addCoordinates) {
          _latitude.text = latitude.toString();
          _longitude.text = longitude.toString();
        }
        _profile = null;
      });
      _notice('已带入可用资料，请核对后提交。');
    } on Exception {
      if (_current(session, epoch)) {
        _notice('读取已保存的出生资料失败，请重试。');
      }
    } finally {
      if (_current(session, epoch) && _busy) setState(() => _busy = false);
    }
  }

  Future<void> _searchBirthPlaces() async {
    final session = _inputSession;
    final epoch = _sessionEpoch;
    final query = _place.text.trim();
    if (!_canChangeDraft ||
        session == null ||
        !_current(session, epoch) ||
        query.isEmpty) {
      return;
    }
    if (query.runes.length > 100) {
      _notice('地点关键词最多 100 字，请缩短后重试。');
      return;
    }

    final form = GlobalKey<FormState>();
    var city = '';
    var submitted = false;
    final region = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('搜索并带入坐标'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '优先查离线地点库。未收录时，点击搜索会将地点关键词和城市'
                '发送给百度地点检索一次。',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '搜索城市',
                  hintText: '可用拼音选字，例如北京市',
                ),
                maxLength: 50,
                keyboardType: TextInputType.text,
                enableSuggestions: true,
                enableIMEPersonalizedLearning: false,
                autocorrect: false,
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? '请输入出生地点所在城市' : null,
                onChanged: (value) => city = value.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (!submitted && form.currentState!.validate()) {
                submitted = true;
                Navigator.pop(dialogContext, city);
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
    if (region == null || !_current(session, epoch)) return;

    setState(() => _busy = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .post(
            '/api/v1/profile/natal/places',
            body: {'query': query, 'region': region, 'allow_baidu': true},
            options: natalSessionOptions(
              () => _current(session, epoch),
            ).copyWith(headers: const {'X-EliteSync-Natal-Places': 'wgs84-v2'}),
          );
      if (!_current(session, epoch)) return;
      if (response is! NetworkSuccess<Map<String, dynamic>>) {
        final status = response is NetworkFailure<Map<String, dynamic>>
            ? response.statusCode
            : null;
        _notice(switch (status) {
          404 || 405 => '当前服务器尚未开通地点搜索，可先打开百度地图查看。',
          422 => '请核对城市和地点名称，可用拼音选字后再搜索。',
          429 => '搜索额度暂不可用，请稍后重试或手填坐标。',
          401 || 403 => '当前登录状态无法使用地点搜索，请检查登录状态。',
          503 => '地点搜索服务暂不可用，可先打开百度地图查看或手填坐标。',
          _ => '连接地点搜索失败，请检查网络后重试。',
        });
        return;
      }
      final rawPlaces = response.data['places'];
      final baiduLookup = response.data['lookup_provider'] == 'Baidu';
      final sample = response.data['coverage'] == 'sample';
      if (response.data['coordinate_system'] != 'WGS84' || rawPlaces is! List) {
        _notice('搜索结果缺少有效的 WGS84 坐标。');
        return;
      }
      final places = <_BirthPlace>[];
      for (final item in rawPlaces.take(10).whereType<Map>()) {
        final label = item['label'];
        final latitude = item['lat'];
        final longitude = item['lng'];
        if (label is! String ||
            label.trim().isEmpty ||
            latitude is! num ||
            longitude is! num ||
            _coordinate(latitude.toString(), 90) != null ||
            _coordinate(longitude.toString(), 180) != null) {
          continue;
        }
        final address = item['address'];
        places.add((
          label: label.trim(),
          address: address is String ? address.trim() : '',
          area: [item['province'], item['city'], item['area']]
              .whereType<String>()
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toSet()
              .join(' · '),
          city: item['city'] is String ? (item['city'] as String).trim() : '',
          source: (item['source'] ?? response.data['source']) is String
              ? (item['source'] ?? response.data['source']) as String
              : '',
          matchedName: item['matched_name'] is String
              ? (item['matched_name'] as String).trim()
              : '',
          approximate:
              item['approximate'] == true ||
              const {'city', 'district'}.contains(item['point_kind']),
          pointKind: switch (item['point_kind']) {
            'campus' => '院区代表点',
            'landmark' => '地标代表点',
            'district' => '区县代表点',
            'city' => '城市代表点',
            _ => '',
          },
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
        ));
      }
      if (places.isEmpty) {
        _notice(
          sample ? '离线样本库未收录此地点，可手动填写已确认的 WGS84 坐标。' : '没有找到带坐标的地点，请核对城市和地点名称。',
        );
        return;
      }
      if (!mounted) return;
      setState(() => _busy = false);
      final choice = await showDialog<_BirthPlace>(
        context: context,
        builder: (dialogContext) => Consumer(
          builder: (_, ref, _) {
            ref.watch(sessionProvider);
            ref.watch(relationshipAuthorityEpochProvider);
            final active = _current(session, epoch);
            return SimpleDialog(
              title: Text(active ? '选择地点并填入坐标' : '搜索结果已失效'),
              children: [
                if (active && sample)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('离线样本 · 请核对地点和代表点层级。'),
                  ),
                if (active)
                  for (final place in places)
                    ListTile(
                      title: Text(place.label),
                      subtitle: Text(
                        [
                          if (place.area.isNotEmpty) place.area,
                          if (place.address.isNotEmpty) place.address,
                          if (place.pointKind.isNotEmpty)
                            place.approximate
                                ? '${place.pointKind} · 约略位置'
                                : place.pointKind,
                          if (place.matchedName.isNotEmpty)
                            '百度匹配 · ${place.matchedName}',
                          'WGS84 ${place.latitude}, ${place.longitude}',
                        ].join('\n'),
                      ),
                      onTap: () => Navigator.pop(dialogContext, place),
                    ),
                if (active &&
                    places.any((place) => place.source == 'OpenStreetMap'))
                  SimpleDialogOption(
                    onPressed: () => launchUrl(
                      Uri.https('www.openstreetmap.org', '/copyright'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: const Text('© OpenStreetMap 贡献者 · ODbL'),
                  ),
                if (active && places.any((place) => place.source == 'GeoNames'))
                  SimpleDialogOption(
                    onPressed: () => launchUrl(
                      Uri.https('www.geonames.org', '/about.html'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: const Text('GeoNames · CC BY 4.0'),
                  ),
                if (active && baiduLookup)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('地点匹配 · 百度地图'),
                  ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消'),
                ),
              ],
            );
          },
        ),
      );
      if (choice == null || !_current(session, epoch)) return;
      final address = choice.address;
      var label = address.isEmpty || address == choice.label
          ? choice.label
          : '${choice.label}（$address）';
      if (choice.approximate) {
        final area = choice.city == choice.label
            ? choice.label
            : '${choice.city}${choice.label}';
        final confirmed = await _confirm(
          title: '使用约略位置？',
          message: '将使用${area}的${choice.pointKind}计算。请先确认此范围。',
          confirm: '确认使用代表点',
          cancel: '取消',
        );
        if (!confirmed || !_current(session, epoch)) return;
        label = '$area（${choice.pointKind}）';
      }
      setState(() {
        _place.text = String.fromCharCodes(label.runes.take(255));
        _latitude.text = choice.latitude.toString();
        _longitude.text = choice.longitude.toString();
        _profile = null;
      });
    } finally {
      if (_current(session, epoch) && _busy) setState(() => _busy = false);
    }
  }

  Future<void> _searchBaiduMap() async {
    final session = _inputSession;
    final epoch = _sessionEpoch;
    final place = _place.text.trim();
    if (!_canChangeDraft ||
        session == null ||
        !_current(session, epoch) ||
        place.isEmpty) {
      return;
    }
    final confirmed = await _confirm(
      title: '打开百度地图查看',
      message:
          '百度地图会收到当前地点名称。查完后用手机的返回键或返回手势，'
          '也可以在最近任务里切回 EliteSync。选中的地点和坐标需要手动填写。',
      confirm: '打开百度地图',
      cancel: '取消',
    );
    if (!confirmed || !_current(session, epoch)) return;
    final uri = Uri(
      scheme: 'baidumap',
      host: 'map',
      path: '/place/search',
      query:
          'query=${Uri.encodeComponent(place)}'
          '&region=${Uri.encodeComponent('全国')}&src=andr.elitesync.app',
    );
    try {
      if (await widget.launchMap(uri)) return;
    } on Exception {
      // Android can reject the launch if no activity can handle the URI.
    }
    if (_current(session, epoch)) {
      _notice('未能打开百度地图，请确认已安装，或继续手填。');
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirm,
    required String cancel,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirm),
            ),
          ],
        ),
      ) ??
      false;

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_busy ||
        !_loaded ||
        _conflict ||
        (_pendingBody == null && !_form.currentState!.validate())) {
      return;
    }
    final epoch = _sessionEpoch;
    final session = _inputSession;
    if (session == null || !_current(session, epoch)) return;
    final body =
        _pendingBody ??
        {
          'input': {
            'civil_date': _date.text.trim(),
            'civil_time': _precision == 'unknown' ? null : _time.text.trim(),
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
        };
    _pendingBody = body;
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
            options: natalSessionOptions(
              () => _current(session, epoch),
            ).copyWith(headers: const {'X-EliteSync-Natal-Places': 'osm-v1'}),
            body: body,
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
        _pendingBody = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存并重新读取。计算与独立核验状态见各盘。')));
    } catch (error) {
      if (_current(session, epoch)) {
        _failure(error, fallback: '保存结果未确认，输入及原操作已保留。可按原操作重试或重新读取确认。');
      }
    } finally {
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  void _failure(Object error, {required String fallback}) {
    final status = error is NatalRequestException ? error.statusCode : null;
    setState(() {
      if ([401, 403, 404, 410].contains(status)) {
        _profile = null;
        _pendingBody = null;
        _loaded = false;
        _conflict = true;
        _error = '当前本命资料不可用，请检查登录和权限后重新读取。';
      } else if (status == 409) {
        _pendingBody = null;
        _conflict = true;
        _error =
            '${error is NatalRequestException ? error.message : '资料版本冲突。'} 输入已保留，请重新读取确认后再编辑。';
      } else if (status == 422) {
        _pendingBody = null;
        _conflict = false;
        _error = '输入未通过校验，请检查日期、时区、夏令时选择和坐标后重试。';
      } else {
        _error = fallback;
      }
    });
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
    onChanged: _busy || _pendingBody != null
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
    bool enableSuggestions = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      controller: controller,
      enabled: !_busy && _pendingBody == null,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
      keyboardType: keyboard,
      autocorrect: false,
      enableSuggestions: enableSuggestions,
      enableIMEPersonalizedLearning: false,
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

  String? _dateError(String? value) {
    final text = value?.trim() ?? '';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return '请输入 YYYY-MM-DD';
    final date = DateTime.tryParse(text);
    return date == null || date.toIso8601String().substring(0, 10) != text
        ? '日期不存在'
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
          _pendingBody = null;
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
    ref.listen(relationshipAuthorityEpochProvider, (before, after) {
      if (before != after) {
        setState(() {
          _sessionEpoch++;
          _profile = null;
          _loaded = false;
          _busy = false;
          _conflict = true;
          _error = '当前权限已变化，请重新读取。输入已保留。';
        });
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('三盘本命排盘')),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    OutlinedButton.icon(
                      onPressed: _canChangeDraft ? _importBirthProfile : null,
                      icon: const Icon(Icons.person_outline),
                      label: const Text('使用已保存的出生资料'),
                    ),
                    _field(
                      '出生日期',
                      _date,
                      hint: 'YYYY-MM-DD',
                      validator: _dateError,
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
                    _field(
                      '出生地点名称（可选）',
                      _place,
                      hint: '例如医院、街道或县区',
                      keyboard: TextInputType.text,
                      enableSuggestions: true,
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _canChangeDraft && _place.text.trim().isNotEmpty
                          ? _searchBirthPlaces
                          : null,
                      icon: const Icon(Icons.search),
                      label: const Text('搜索并带入坐标'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _canChangeDraft && _place.text.trim().isNotEmpty
                          ? _searchBaiduMap
                          : null,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('打开百度地图查看'),
                    ),
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
                    ExpansionTile(
                      title: const Text('高级计算参数'),
                      children: [
                        _choice('黄道', _zodiac, {
                          'tropical': '回归黄道',
                          'sidereal': '自定义恒星黄道（CRC1956）',
                        }, (v) => _zodiac = v),
                        if (_zodiac == 'sidereal')
                          const Text('CRC1956 自定义重建，非官方 Lahiri；定义与核验状态见盘面详情。'),
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
                          onChanged: _busy || _pendingBody != null
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
                      ],
                    ),
                    if (_pendingBody != null)
                      const Text('未确认操作保留原输入与版本。重新读取会替换当前表单，请先确认操作结果。'),
                    FilledButton.icon(
                      onPressed: _busy || _conflict ? null : _save,
                      icon: const Icon(Icons.save),
                      label: Text(
                        _pendingBody == null ? '保存、计算并持久重读' : '按原操作重试',
                      ),
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
            if (_loaded)
              ToolRevisionHistory(
                key: ValueKey('natal-revisions:$_revision:$_sessionEpoch'),
                endpoint: '/api/v1/profile/natal/history',
                detailKey: 'profile',
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
