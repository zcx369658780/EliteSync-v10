import '../profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';

class MatchingInputPage extends ConsumerStatefulWidget {
  const MatchingInputPage({super.key});

  @override
  ConsumerState<MatchingInputPage> createState() => _MatchingInputState();
}

class _MatchingInputState extends SessionBoundPage<MatchingInputPage> {
  final _form = GlobalKey<FormState>();
  final _birthday = TextEditingController();
  final _city = TextEditingController();
  final _ageMin = TextEditingController();
  final _ageMax = TextEditingController();
  final _height = TextEditingController();
  final _occupation = TextEditingController();
  Map<String, dynamic>? _loadedData;
  String? _gender;
  String? _goal;
  String? _ageMode;
  String? _regionMode = 'same_city';
  String? _education;
  String? _maritalHistory;
  String? _childrenStatus;
  String? _childrenIntention;
  bool _saved = false;

  @override
  String get resource => '/matching-inputs';

  void _clear() {
    for (final controller in [
      _birthday,
      _city,
      _ageMin,
      _ageMax,
      _height,
      _occupation,
    ]) {
      controller.clear();
    }
    _loadedData = null;
    _gender = null;
    _goal = null;
    _ageMode = null;
    _regionMode = 'same_city';
    _education = null;
    _maritalHistory = null;
    _childrenStatus = null;
    _childrenIntention = null;
    _saved = false;
  }

  @override
  void onIdentityChanged() => _clear();

  @override
  void onAuthorityChanged() => _clear();

  void _load(Map<String, dynamic> value) {
    _loadedData = value;
    _birthday.text = '${value['birthday'] ?? ''}';
    _city.text = '${value['city_key'] ?? ''}';
    _ageMin.text = '${value['age_min'] ?? ''}';
    _ageMax.text = '${value['age_max'] ?? ''}';
    _height.text = '${value['height_cm'] ?? ''}';
    _occupation.text = '${value['occupation'] ?? ''}';
    _gender = value['gender'] as String?;
    _goal = value['relationship_goal'] as String?;
    _ageMode = value['age_mode'] as String?;
    _regionMode = value['region_mode'] as String? ?? 'same_city';
    _education = value['education'] as String?;
    _maritalHistory = value['marital_history'] as String?;
    _childrenStatus = value['children_status'] as String?;
    _childrenIntention = value['children_intention'] as String?;
  }

  Future<void> _save() async {
    if (busy || data == null || !(_form.currentState?.validate() ?? false)) {
      return;
    }
    final body = <String, dynamic>{
      'revision': data!['revision'],
      'birthday': _birthday.text.trim(),
      'gender': _gender,
      'city_key': _city.text.trim(),
      'relationship_goal': _goal,
      'age_mode': _ageMode,
      'age_min': _ageMode == 'range' ? int.tryParse(_ageMin.text) : null,
      'age_max': _ageMode == 'range' ? int.tryParse(_ageMax.text) : null,
      'region_mode': _regionMode,
      'height_cm': int.tryParse(_height.text),
      'education': _education,
      'occupation': _occupation.text.trim().isEmpty
          ? null
          : _occupation.text.trim(),
      'marital_history': _maritalHistory,
      'children_status': _childrenStatus,
      'children_intention': _childrenIntention,
      'confirm': true,
    };
    final result = await run(
      () => ref.read(relationshipApiProvider).call('PUT', resource, body),
    );
    if (result == null || !mounted) return;
    ref.invalidate(profileProvider);
    ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    setState(() => _saved = true);
  }

  String? _dateError(String? value) {
    final text = value?.trim() ?? '';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return '请按 YYYY-MM-DD 填写生日';
    }
    final parsed = DateTime.tryParse(text);
    if (parsed == null || parsed.toIso8601String().substring(0, 10) != text) {
      return '请填写有效日期';
    }
    return null;
  }

  String? _ageError(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null || age < 18) return '请输入不小于18的整数';
    return null;
  }

  Widget _choice(
    String key,
    String label,
    String? value,
    Map<String, String> options,
    ValueChanged<String?> change, {
    bool required = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$key-${value ?? ''}'),
      initialValue: options.containsKey(value) ? value : '',
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem(value: '', child: Text(required ? '请选择' : '未填写 / 清除')),
        for (final option in options.entries)
          DropdownMenuItem(value: option.key, child: Text(option.value)),
      ],
      onChanged: busy
          ? null
          : (next) => setState(() {
              _saved = false;
              change(next == '' ? null : next);
            }),
      validator: required
          ? (next) => next == null || next.isEmpty ? '请明确选择' : null
          : null,
    ),
  );

  Widget _text(
    String key,
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    int? maxLength,
    String? hint,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      key: ValueKey(key),
      controller: controller,
      enabled: !busy,
      keyboardType: keyboard,
      maxLength: maxLength,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
      onChanged: (_) {
        if (_saved) setState(() => _saved = false);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (data != null && !identical(data, _loadedData)) _load(data!);
    return frame('我的匹配输入', [
      const Text('这些输入默认私密，用于准备度和双方匹配条件。保存并确认后，仍需你主动报名。'),
      if (_saved)
        const Text('已保存并确认，正在读取服务器结果。', key: Key('matching-input-saved')),
      if (data != null) ...[
        Text(data!['confirmed'] == true ? '当前输入已确认' : '请确认本版关系目标与偏好'),
        if (_city.text.isEmpty && '${data!['legacy_city'] ?? ''}'.isNotEmpty)
          Text('旧资料现居地为 ${data!['legacy_city']}，请在下方明确填写并确认现居城市。'),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _text(
                'matching-birthday',
                '生日（仅本人输入，按业务日期判断周岁）',
                _birthday,
                keyboard: TextInputType.datetime,
                hint: 'YYYY-MM-DD',
                validator: _dateError,
              ),
              _choice(
                'matching-gender',
                '性别',
                _gender,
                const {'male': '男', 'female': '女'},
                (value) => _gender = value,
                required: true,
              ),
              _text(
                'matching-city',
                '现居城市（统一城市名称）',
                _city,
                maxLength: 64,
                hint: '例如 上海，同城双方使用一致名称',
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? '请明确填写现居城市' : null,
              ),
              _choice(
                'matching-goal',
                '当前关系目标',
                _goal,
                const {
                  'marriage': '以婚姻为目标',
                  'dating': '认真交往，以长期关系为方向',
                  'friendship': '仅交友',
                },
                (value) => _goal = value,
                required: true,
              ),
              if (_goal == 'friendship')
                const Text('仅交友可保留交友用途及历史，当前不能报名婚恋慢约。'),
              _choice(
                'matching-age-mode',
                '对方年龄范围',
                _ageMode,
                const {'adult_any': '成年范围不限（18周岁起）', 'range': '明确年龄区间'},
                (value) => _ageMode = value,
                required: true,
              ),
              if (_ageMode == 'range') ...[
                _text(
                  'matching-age-min',
                  '对方最低周岁（含）',
                  _ageMin,
                  keyboard: TextInputType.number,
                  validator: _ageError,
                ),
                _text(
                  'matching-age-max',
                  '对方最高周岁（含）',
                  _ageMax,
                  keyboard: TextInputType.number,
                  validator: (value) {
                    final error = _ageError(value);
                    if (error != null) return error;
                    final lower = int.tryParse(_ageMin.text) ?? 18;
                    return int.parse(value!.trim()) < lower
                        ? '最高年龄应不小于最低年龄'
                        : null;
                  },
                ),
              ],
              _choice(
                'matching-region',
                '地域偏好',
                _regionMode,
                const {'same_city': '仅同城', 'long_distance': '接受异地'},
                (value) => _regionMode = value,
                required: true,
              ),
              const SizedBox(height: 16),
              const Text('可选本人资料（默认私密，可留空或清除）'),
              _text(
                'matching-height',
                '身高（厘米）',
                _height,
                keyboard: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return null;
                  final height = int.tryParse(value!.trim());
                  return height == null || height < 50 || height > 250
                      ? '请填写50至250之间的整数，或留空'
                      : null;
                },
              ),
              _choice('matching-education', '学历', _education, const {
                'secondary': '中学及以下',
                'college': '专科',
                'bachelor': '本科',
                'master': '硕士',
                'doctor': '博士',
                'undisclosed': '不愿透露',
              }, (value) => _education = value),
              _text('matching-occupation', '职业', _occupation, maxLength: 100),
              _choice(
                'matching-marital-history',
                '婚姻经历',
                _maritalHistory,
                const {
                  'never_married': '未婚',
                  'divorced': '离异',
                  'widowed': '丧偶',
                  'undisclosed': '不愿透露',
                },
                (value) => _maritalHistory = value,
              ),
              _choice(
                'matching-children-status',
                '生育状况',
                _childrenStatus,
                const {
                  'none': '无子女',
                  'has_children': '有子女',
                  'undisclosed': '不愿透露',
                },
                (value) => _childrenStatus = value,
              ),
              _choice(
                'matching-children-intention',
                '未来生育意愿',
                _childrenIntention,
                const {
                  'want': '希望生育',
                  'not_want': '不希望生育',
                  'unsure': '暂不确定',
                  'undisclosed': '不愿透露',
                },
                (value) => _childrenIntention = value,
              ),
              FilledButton(
                key: const Key('matching-input-save'),
                onPressed: busy ? null : _save,
                child: const Text('保存并确认匹配输入'),
              ),
            ],
          ),
        ),
      ],
    ]);
  }

  @override
  void dispose() {
    for (final controller in [
      _birthday,
      _city,
      _ageMin,
      _ageMax,
      _height,
      _occupation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }
}
