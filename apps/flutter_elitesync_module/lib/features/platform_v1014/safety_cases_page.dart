import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';

/// A person's own minimum outcome and sanction appeal, never a safety directory.
class SafetyCasesPage extends ConsumerStatefulWidget {
  const SafetyCasesPage({super.key});

  @override
  ConsumerState<SafetyCasesPage> createState() => _SafetyCasesPageState();
}

class _SafetyCasesPageState extends SessionBoundPage<SafetyCasesPage> {
  @override
  String get resource => '/safety/own';

  final _appealNote = TextEditingController();
  String? _selectedSanction;
  int _localGeneration = 0;

  void _clearPrivateForm() {
    _localGeneration++;
    _appealNote.clear();
    _selectedSanction = null;
  }

  @override
  void onIdentityChanged() => _clearPrivateForm();
  @override
  void onAuthorityChanged() => _clearPrivateForm();

  @override
  void dispose() {
    _appealNote.dispose();
    super.dispose();
  }

  String _appealLabel(Map<String, dynamic> appeal) =>
      switch (appeal['outcome'] ?? appeal['status']) {
        'submitted' => '本人申诉已提交，等待人工复核',
        'UPHELD' => '人工复核：维持本次处理',
        'OVERTURNED' => '人工复核：推翻本次处理',
        'CORRECTED' => '人工复核：已记录纠错结果',
        _ => '申诉状态待刷新确认',
      };

  String _caseLabel(Object? state) => switch (state) {
    'OPEN' => '报告已登记，尚未形成认定',
    'TRIAGED' => '正在分类核查，非违规结论',
    'INVESTIGATING' => '正在人工核查',
    'DISMISSED' => '本次报告已驳回',
    'SUBSTANTIATED' => '已记录具名人工判断',
    'ACTIONED' => '已记录具名人工处理',
    'CLOSED' => '本案已结案',
    'REOPENED_FOR_APPEAL' => '本人申诉进入人工复核',
    'CORRECTED' => '本案已记录纠错',
    _ => '本案状态待刷新确认',
  };

  Future<void> _submit(Map<String, dynamic> sanction) async {
    final id = sanction['id']?.toString();
    final note = _appealNote.text.trim();
    if (id == null || note.isEmpty || id != _selectedSanction) return;
    final generation = _localGeneration;
    final result = await run(
      () => ref.read(relationshipApiProvider).call(
        'POST',
        '/moderation/sanctions/${Uri.encodeComponent(id)}/appeals',
        {'note': note},
      ),
    );
    if (!mounted || generation != _localGeneration) return;
    _appealNote.clear();
    if (result == null) {
      setState(() {
        data = null;
        _selectedSanction = null;
      });
      return;
    }
    ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
  }

  Widget _caseCard(Map<String, dynamic> item) {
    final appeal = objectMap(item['appeal']);
    return Card(
      key: ValueKey('safety-case-${item['id']}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['role'] == 'reporter' ? '本人提交的关联报告' : '与本人有关的处理状态'),
            Text(_caseLabel(item['state'])),
            if (appeal.isNotEmpty) Text(_appealLabel(appeal)),
            const Text('这里只显示本人可被告知的最小状态，不公开他人负面档案或内部证据。'),
          ],
        ),
      ),
    );
  }

  Widget _sanctionCard(Map<String, dynamic> sanction) {
    final appeal = objectMap(sanction['appeal']);
    final id = sanction['id']?.toString();
    final maySubmit =
        id != null && sanction['kind'] == 'restrict' && appeal.isEmpty;
    return Card(
      key: ValueKey('own-sanction-$id'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('本人当前受限记录'),
            Text('记录时间：${sanction['created_at'] ?? '等待回读'}'),
            if (appeal.isNotEmpty) Text(_appealLabel(appeal)),
            if (maySubmit && _selectedSanction != id)
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                        _selectedSanction = id;
                        _appealNote.clear();
                      }),
                child: const Text('对此记录提出本人申诉'),
              ),
            if (maySubmit && _selectedSanction == id) ...[
              TextField(
                key: const Key('safety-appeal-note'),
                controller: _appealNote,
                enabled: !busy,
                maxLength: 1000,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '本人申诉说明（不要填写密码、私信或他人隐私）',
                ),
                onChanged: (_) => setState(() {}),
              ),
              FilledButton(
                onPressed: busy || _appealNote.text.trim().isEmpty
                    ? null
                    : () => _submit(sanction),
                child: const Text('提交本人申诉'),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                        _appealNote.clear();
                        _selectedSanction = null;
                      }),
                child: const Text('收起申诉表单'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cases = rows(data?['items']);
    final sanctions = rows(data?['sanctions']);
    return frame('本人Safety状态与申诉', [
      const Text('举报不等于已核实；规则提示不是处罚。结果由有权管理员具名人工决定。'),
      const Text('提交申诉不会自动恢复权限；纠错也不会重新建立好友、消息同意或其他关系。'),
      if (data != null && cases.isEmpty) const Text('当前没有本人可查看的活动报告或处理状态。'),
      ...cases.map(_caseCard),
      if (data != null && sanctions.isEmpty) const Text('当前没有可通过此入口申诉的本人受限记录。'),
      ...sanctions.map(_sanctionCard),
    ]);
  }
}
