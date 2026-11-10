import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class MbtiCenterPage extends ConsumerStatefulWidget {
  const MbtiCenterPage({super.key});

  @override
  ConsumerState<MbtiCenterPage> createState() => _MbtiCenterPageState();
}

class _MbtiCenterPageState extends ConsumerState<MbtiCenterPage> {
  static const _base = '/api/v1/profile/mbti';
  SessionState? _session;
  Map<String, dynamic>? _result;
  List<Map<String, dynamic>> _items = [];
  final Map<int, String> _answers = {};
  String _version = 'lite3_v1';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  bool _current(SessionState started) =>
      mounted && identical(ref.read(sessionProvider).asData?.value, started);

  Future<SessionState> _start() async {
    final started = await ref.read(sessionProvider.future);
    if (!started.isLoggedIn) throw StateError('请登录后使用测评。');
    if (!_current(started)) throw StateError('登录会话已变化，请刷新。');
    if (!identical(_session, started)) {
      _result = null;
      _items = [];
      _answers.clear();
    }
    _session = started;
    return started;
  }

  Map<String, dynamic> _data(NetworkResult<Map<String, dynamic>> response) {
    if (response is NetworkSuccess<Map<String, dynamic>>) return response.data;
    final failure = response as NetworkFailure<Map<String, dynamic>>;
    throw StateError('${failure.message}（HTTP ${failure.statusCode ?? "未知"}）');
  }

  Future<void> _refresh() async {
    await _request((started) async {
      final data = _data(
        await ref.read(apiClientProvider).get('$_base/result'),
      );
      if (_current(started)) _result = data;
    });
  }

  Future<void> _quiz() async {
    await _request((started) async {
      final data = _data(
        await ref
            .read(apiClientProvider)
            .get('$_base/quiz', query: {'version': _version}),
      );
      if (!_current(started)) return;
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
    await _request((started) async {
      final client = ref.read(apiClientProvider);
      final submitted = _data(
        await client.post(
          '$_base/submit',
          body: {
            'version_code': _version,
            'answers': [
              for (final item in _items)
                {
                  'question_id': item['question_id'],
                  'option': _answers[item['question_id']],
                },
            ],
          },
        ),
      );
      if (!_current(started)) return;
      if (submitted['ok'] != true) throw StateError('服务器未确认提交。');
      // Show only the persisted result read back from the server.
      final confirmed = _data(await client.get('$_base/result'));
      if (!_current(started)) return;
      if (confirmed['exists'] != true ||
          confirmed['result'] is! String ||
          (confirmed['result'] as String).isEmpty) {
        throw StateError('已提交，但持久化结果尚未确认，请刷新。');
      }
      _result = confirmed;
      _items = [];
      _answers.clear();
    });
  }

  Future<void> _request(Future<void> Function(SessionState) action) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    SessionState? started;
    try {
      started = await _start();
      await action(started);
    } catch (error) {
      if (mounted && (started == null || _current(started))) {
        _error = error.toString();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 20),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null && (current || _session == null))
            Text(
              '操作未确认：$_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (session != null && !session.isLoggedIn) const Text('请登录后使用测评。'),
          if (result != null)
            Text(
              result['exists'] == true
                  ? '服务端结果已确认：${result['result']}\n更新时间：${result['updated_at'] ?? "未提供"}'
                  : '暂无服务端测评结果',
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _refresh,
            child: const Text('刷新结果'),
          ),
          FilledButton(
            onPressed: _busy ? null : _quiz,
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
                  onPressed: _busy
                      ? null
                      : () => setState(
                          () => _answers[item['question_id'] as int] = option,
                        ),
                  style: _answers[item['question_id']] == option
                      ? OutlinedButton.styleFrom(
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
              onPressed: _busy || _answers.length != items.length
                  ? null
                  : _submit,
              child: const Text('提交测评'),
            ),
          ],
        ],
      ),
    );
  }
}
