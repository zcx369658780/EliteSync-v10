import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:uuid/uuid.dart';
import '../providers/natal_restoration_provider.dart';

class _MbtiFailure implements Exception {
  const _MbtiFailure(this.message, this.statusCode);
  final String message;
  final int? statusCode;
}

class MbtiCenterPage extends ConsumerStatefulWidget {
  const MbtiCenterPage({super.key});

  @override
  ConsumerState<MbtiCenterPage> createState() => _MbtiCenterPageState();
}

class _MbtiCenterPageState extends ConsumerState<MbtiCenterPage> {
  static const _base = '/api/v1/profile/mbti';
  SessionState? _session;
  Map<String, dynamic>? _result;
  Map<String, dynamic>? _selectedAttempt;
  Map<String, dynamic>? _pendingBody;
  List<Map<String, dynamic>> _history = [];
  int? _nextBefore;
  int _generation = 0, _operation = 0;
  List<Map<String, dynamic>> _items = [];
  final Map<int, String> _answers = {};
  String _version = 'lite3_v1';
  String? _error;
  bool _busy = false;
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  bool _current(SessionState started, int generation, int operation) =>
      mounted &&
      generation == _generation &&
      operation == _operation &&
      natalSessionMatches(started, ref.read(sessionProvider).asData?.value);

  void _clearPrivate({bool draft = false}) {
    _result = null;
    _selectedAttempt = null;
    _history = [];
    _nextBefore = null;
    if (draft) {
      _items = [];
      _answers.clear();
      _pendingBody = null;
    }
  }

  Future<SessionState> _start(int generation, int operation) async {
    final started = await ref.read(sessionProvider.future);
    if (!started.isLoggedIn) throw StateError('请登录后使用测评。');
    if (!_current(started, generation, operation)) {
      throw StateError('登录会话已变化，请刷新。');
    }
    if (!identical(_session, started)) {
      _clearPrivate(draft: true);
    }
    _session = started;
    return started;
  }

  Map<String, dynamic> _data(NetworkResult<Map<String, dynamic>> response) {
    if (response is NetworkSuccess<Map<String, dynamic>>) return response.data;
    final failure = response as NetworkFailure<Map<String, dynamic>>;
    throw _MbtiFailure(failure.message, failure.statusCode);
  }

  Future<void> _refresh() async {
    await _request((started, current) async {
      final data = _data(
        await ref
            .read(apiClientProvider)
            .get('$_base/result', options: natalSessionOptions(current)),
      );
      if (current()) {
        _result = data;
        _blocked = false;
      }
    });
  }

  List<Map<String, dynamic>> _rows(dynamic value) => value is List
      ? value.map((row) => Map<String, dynamic>.from(row as Map)).toList()
      : [];

  Future<void> _loadHistory({bool more = false}) async {
    final before = more ? _nextBefore : null;
    if (more && before == null) return;
    await _request((started, current) async {
      final data = _data(
        await ref
            .read(apiClientProvider)
            .get(
              '$_base/history',
              query: {'before_id': ?before},
              options: natalSessionOptions(current),
            ),
      );
      if (!current()) return;
      final rows = _rows(data['items']);
      final known = more
          ? _history.map((row) => row['id']).toSet()
          : <dynamic>{};
      _history = [
        if (more) ..._history,
        ...rows.where((row) => !known.contains(row['id'])),
      ];
      _nextBefore = (data['next_before_id'] as num?)?.toInt();
    });
  }

  Future<void> _openAttempt(int id) async {
    _selectedAttempt = null;
    await _request((started, current) async {
      final data = _data(
        await ref
            .read(apiClientProvider)
            .get('$_base/history/$id', options: natalSessionOptions(current)),
      );
      if (!current()) return;
      final row = Map<String, dynamic>.from(data['attempt'] as Map);
      if (row['id'] != id) throw StateError('历史记录身份不一致，请重新读取。');
      _selectedAttempt = row;
    });
  }

  Future<void> _quiz() async {
    await _request((started, current) async {
      final data = _data(
        await ref
            .read(apiClientProvider)
            .get(
              '$_base/quiz',
              query: {'version': _version},
              options: natalSessionOptions(current),
            ),
      );
      if (!current()) return;
      final raw = data['items'];
      if (raw is! List || raw.isEmpty || data['version_code'] is! String) {
        throw StateError('题库响应无效，未开始测评。');
      }
      final items = raw
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final ids = items.map((item) => item['question_id']).toList();
      if (ids.any((id) => id is! int) ||
          ids.toSet().length != ids.length ||
          items.any(
            (item) => [
              'content',
              'option_a_text',
              'option_b_text',
            ].any((key) => item[key] is! String),
          )) {
        throw StateError('题库题目格式无效，未开始测评。');
      }
      _version = data['version_code'] as String;
      _items = items;
      _answers.clear();
    });
  }

  Future<void> _submit() async {
    _pendingBody ??= {
      'request_key': const Uuid().v4(),
      'version_code': _version,
      'answers': [
        for (final item in _items)
          {
            'question_id': item['question_id'],
            'option': _answers[item['question_id']],
          },
      ],
    };
    await _request((started, current) async {
      final client = ref.read(apiClientProvider);
      final submitted = _data(
        await client.post(
          '$_base/submit',
          body: _pendingBody,
          options: natalSessionOptions(current),
        ),
      );
      if (!current()) return;
      if (submitted['ok'] != true) throw StateError('服务器未确认提交。');
      final id = submitted['attempt_id'];
      if (id is! int) throw StateError('已提交，但记录身份尚未确认，请按原操作重试。');
      final detail = _data(
        await client.get(
          '$_base/history/$id',
          options: natalSessionOptions(current),
        ),
      );
      if (!current()) return;
      final confirmed = Map<String, dynamic>.from(detail['attempt'] as Map);
      if (confirmed['id'] != id ||
          confirmed['result'] is! String ||
          (confirmed['result'] as String).isEmpty) {
        throw StateError('已提交，但持久化结果尚未确认，请按原操作重试。');
      }
      _result = {
        ...confirmed,
        'exists': true,
        'attempt_id': id,
        'updated_at': confirmed['submitted_at'],
      };
      _history.removeWhere((row) => row['id'] == id);
      _history.insert(0, confirmed);
      _selectedAttempt = null;
      _pendingBody = null;
      _items = [];
      _answers.clear();
    });
  }

  Future<void> _request(
    Future<void> Function(SessionState, bool Function()) action,
  ) async {
    if (_busy || !mounted) return;
    final generation = _generation, operation = ++_operation;
    setState(() {
      _busy = true;
      _error = null;
    });
    SessionState? started;
    try {
      started = await _start(generation, operation);
      await action(started, () => _current(started!, generation, operation));
    } catch (error) {
      if (mounted &&
          generation == _generation &&
          operation == _operation &&
          (started == null || _current(started, generation, operation))) {
        if (error is _MbtiFailure) {
          final code = error.statusCode;
          if ([401, 403, 410].contains(code)) {
            _clearPrivate(draft: true);
            _blocked = true;
            _error = '当前测评不可用，请检查登录或功能许可。${error.message}（HTTP $code）';
          } else if ([404, 409, 422].contains(code)) {
            if (code == 404) _clearPrivate();
            if (code == 409 || code == 422) _pendingBody = null;
            _error = '请求已被明确拒绝，请核对输入或重新读取。${error.message}（HTTP $code）';
          } else {
            _error = '结果未确认，输入已保留，可按原操作重试。${error.message}';
          }
        } else {
          _error = error.toString();
        }
      }
    } finally {
      if (mounted && generation == _generation && operation == _operation) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (_session != null && !identical(_session, next.asData?.value)) {
        setState(() {
          _generation++;
          _clearPrivate(draft: true);
          _session = null;
          _busy = false;
          _blocked = false;
          _error = '登录身份已变化，请刷新结果。';
        });
      }
    });
    ref.listen(relationshipAuthorityEpochProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _generation++;
          _clearPrivate();
          _busy = false;
          _blocked = false;
          _error = '权限状态已变化，请刷新结果。';
        });
      }
    });
    final session = ref.watch(sessionProvider).asData?.value;
    final current = session?.isLoggedIn == true && identical(session, _session);
    final result = current ? _result : null;
    final items = current ? _items : <Map<String, dynamic>>[];
    return AppScaffold(
      appBar: const AppTopBar(title: '可选性格测评', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('可选 MBTI 测评', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('本测评仅供自我了解，不是心理诊断，不用于匹配排序。你可以自主选择是否答题。'),
          const Text('当前为 lite3_v1 简版配置计分，与20题匹配问卷分开，不用于匹配硬筛选。'),
          const SizedBox(height: 20),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null && (current || _session == null))
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (session != null && !session.isLoggedIn) const Text('请登录后使用测评。'),
          if (result != null)
            Text(
              result['exists'] == true
                  ? '服务端结果已确认：${result['result']}\n版本：${result['version_code'] ?? "历史来源未提供"}\n更新时间：${result['updated_at'] ?? "未提供"}'
                  : '暂无服务端测评结果',
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _refresh,
            child: const Text('刷新结果'),
          ),
          FilledButton(
            onPressed: _busy || _blocked || _pendingBody != null ? null : _quiz,
            child: Text(items.isEmpty ? '开始测评' : '重新开始测评'),
          ),
          if (items.isNotEmpty) ...[
            Text('题库版本：$_version；已答 ${_answers.length}/${items.length}'),
            for (final item in items) ...[
              const SizedBox(height: 20),
              Text(item['content'] as String),
              for (final option in ['A', 'B'])
                OutlinedButton(
                  key: ValueKey('mbti-${item['question_id']}-$option'),
                  onPressed: _busy || _pendingBody != null
                      ? null
                      : () => setState(
                          () => _answers[item['question_id'] as int] = option,
                        ),
                  style: _answers[item['question_id']] == option
                      ? OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                        )
                      : null,
                  child: Text(
                    '$option：${item[option == 'A' ? 'option_a_text' : 'option_b_text']}',
                  ),
                ),
            ],
            FilledButton(
              onPressed:
                  _busy ||
                      _blocked ||
                      _pendingBody != null ||
                      _answers.length != items.length
                  ? null
                  : _submit,
              child: const Text('提交测评'),
            ),
          ],
          if (current && _pendingBody != null)
            FilledButton(
              onPressed: _busy || _blocked ? null : _submit,
              child: const Text('重试原提交并确认结果'),
            ),
          OutlinedButton(
            onPressed: _busy || _blocked ? null : _loadHistory,
            child: const Text('读取测评历史'),
          ),
          if (current) ...[
            for (final row in _history)
              ListTile(
                title: Text(
                  '历史 #${row['id']} · ${row['result']} · ${row['version_code']}',
                ),
                subtitle: Text('${row['submitted_at'] ?? "时间未提供"}'),
                onTap: _busy || _blocked
                    ? null
                    : () => _openAttempt((row['id'] as num).toInt()),
              ),
            if (_nextBefore != null)
              OutlinedButton(
                onPressed: _busy || _blocked
                    ? null
                    : () => _loadHistory(more: true),
                child: const Text('更早测评历史'),
              ),
            if (_selectedAttempt != null) ...[
              Text(
                '历史测评 #${_selectedAttempt!['id']}\n结果：${_selectedAttempt!['result']}\n版本：${_selectedAttempt!['version_code']}\n时间：${_selectedAttempt!['submitted_at']}',
              ),
              Text('简版配置计分 · 四维得分 ${_selectedAttempt!['scores'] ?? "未记录"}'),
              Text('已保存作答 ${_selectedAttempt!['answers'] ?? "未记录"}'),
              const Text('这是历史记录。主动开始新的测评会保存一条新记录。'),
            ],
          ],
        ],
      ),
    );
  }
}
