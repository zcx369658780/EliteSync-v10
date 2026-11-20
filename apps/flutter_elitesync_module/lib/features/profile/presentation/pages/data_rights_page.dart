import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../relationships_v1011/relationship_api.dart';
import '../../../relationships_v1011/session_bound_page.dart';

class ShowcasePurposePage extends ConsumerStatefulWidget {
  const ShowcasePurposePage({super.key});

  @override
  ConsumerState<ShowcasePurposePage> createState() => _ShowcasePurposeState();
}

class _ShowcasePurposeState extends SessionBoundPage<ShowcasePurposePage> {
  @override
  String get resource => '/data-rights/showcase-city';

  Future<void> _decide(String state, int revision) async {
    final label = switch (state) {
      'GRANTED' => '允许复用',
      'REVOKED' => '撤销用途许可',
      _ => '拒绝复用',
    };
    if (await confirm(label, '此决定仅用于展示草稿中的现居城市。发布受众仍需单独确认。')) {
      await mutate('PUT', resource, {
        'state': state,
        'expected_revision': revision,
        'confirm': true,
      });
    }
  }

  Future<void> _reuse(int revision) async {
    if (await confirm('复用现居城市', '将账号中的现居城市带入本人的展示草稿。')) {
      await mutate('POST', '$resource/reuse', {
        'expected_revision': revision,
        'confirm': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = data;
    final eligible =
        current?['available'] == true && current?['test_only'] == true;
    final state = current?['state'];
    final revision = current?['revision'];
    final draft = current?['draft_revision'];
    return frame('展示草稿的资料用途', [
      const Text('字段为现居城市。用途是填写本人展示草稿。发布时另行确认受众。'),
      if (state == 'LEGAL_BASIS_UNVERIFIED')
        const Text('目前缺少可核实的处理依据，暂不能复用账号资料。你仍可直接编辑展示草稿。'),
      if (eligible) ...[
        const Text('仅隔离测试'),
        Text(switch (state) {
          'GRANTED' => '当前用途许可有效',
          'REVOKED' => '用途许可已撤销',
          'DECLINED' => '已拒绝复用',
          'EXPIRED' => '用途许可已到期',
          _ => '等待你的决定',
        }),
        if (current?['derivation_state'] == 'NEEDS_REVIEW')
          const Text('现居城市已更正，相关草稿需要核查后才能发布新版本。'),
        if (!busy && revision is int)
          Wrap(
            spacing: 8,
            children: [
              if (state == 'GRANTED') ...[
                if (draft is int)
                  FilledButton(
                    onPressed: () => _reuse(draft),
                    child: const Text('复用到草稿'),
                  ),
                OutlinedButton(
                  onPressed: () => _decide('REVOKED', revision),
                  child: const Text('撤销用途许可'),
                ),
              ] else ...[
                FilledButton(
                  onPressed: () => _decide('GRANTED', revision),
                  child: const Text('允许复用'),
                ),
                OutlinedButton(
                  onPressed: () => _decide('DECLINED', revision),
                  child: const Text('拒绝复用'),
                ),
              ],
            ],
          ),
      ],
    ]);
  }
}

class OwnedDataRightsPage extends ConsumerStatefulWidget {
  const OwnedDataRightsPage({super.key, required this.type});

  final String type;
  @override
  ConsumerState<OwnedDataRightsPage> createState() => _OwnedDataRightsState();
}

class _OwnedDataRightsState extends SessionBoundPage<OwnedDataRightsPage> {
  int _page = 1;
  @override
  String get resource => '/data-rights/objects?type=${widget.type}&page=$_page';

  @override
  void onIdentityChanged() => _page = 1;

  @override
  Widget build(BuildContext context) =>
      frame(widget.type == 'work' ? '本人作品的数据删除' : '本人评论的数据删除', [
        for (final item in rows(data?['items']))
          if (item['key'] is String)
            ListTile(
              title: Text('创建于 ${item['created_at'] ?? '时间未知'}'),
              subtitle: Text('对象 ${item['key']}'),
              onTap: busy
                  ? null
                  : () => openObjectDataRights(
                      context,
                      widget.type,
                      item['key'] as String,
                    ),
            ),
        if (data?['has_more'] == true && !busy)
          TextButton(
            onPressed: () {
              _page++;
              invalidatePendingProjection();
              refresh();
            },
            child: const Text('下一页'),
          ),
        if (_page > 1 && !busy)
          TextButton(
            onPressed: () {
              _page--;
              invalidatePendingProjection();
              refresh();
            },
            child: const Text('上一页'),
          ),
      ]);
}

Future<void> openObjectDataRights(
  BuildContext context,
  String type,
  String key,
) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ObjectDataRightsPage(type: type, objectKey: key),
    ),
  );
}

class _ObjectDataRightsPage extends ConsumerStatefulWidget {
  const _ObjectDataRightsPage({required this.type, required this.objectKey});

  final String type;
  final String objectKey;
  @override
  ConsumerState<_ObjectDataRightsPage> createState() =>
      _ObjectDataRightsState();
}

class _ObjectDataRightsState extends SessionBoundPage<_ObjectDataRightsPage>
    with WidgetsBindingObserver {
  (String, String)? _pending;
  bool _checked = false;

  @override
  String get resource =>
      '/data-rights/objects/${widget.type}/${Uri.encodeComponent(widget.objectKey)}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _checked = false;
    invalidatePendingProjection();
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void onIdentityChanged() {
    _pending = null;
    _checked = false;
  }

  @override
  void onAuthorityChanged() => _checked = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _submit(String version) async {
    if (!await confirm('提交测试请求', '仅测试此对象的请求状态。原记录及其他人的材料会保留。')) return;
    final pending = _pending ?? (const Uuid().v4(), version);
    setState(() {
      _pending = pending;
      _checked = false;
    });
    final result = await run(
      () => ref.read(relationshipApiProvider).call('POST', resource, {
        'request_key': pending.$1,
        'expected_version': pending.$2,
        'confirm': true,
      }),
      onFailure: (_) {
        data = null;
        error = '提交结果待核对';
      },
    );
    if (!mounted || !identical(pending, _pending) || result == null) return;
    if (!_applied(result)) return;
    setState(() => _pending = null);
    await refresh();
  }

  Future<void> _check() async {
    final pending = _pending;
    if (pending == null) return;
    setState(() => _checked = false);
    final result = await run(
      () => ref
          .read(relationshipApiProvider)
          .call('GET', '$resource/result?request_key=${pending.$1}'),
    );
    if (!mounted || !identical(pending, _pending) || result == null) return;
    final state = result['state'];
    final applied = _applied(result);
    if (!applied && state != 'NOT_APPLIED') return;
    await refresh();
    if (!mounted || !identical(pending, _pending)) return;
    setState(() {
      if (applied) _pending = null;
      _checked = !applied;
    });
  }

  bool _applied(Map<String, dynamic> response) =>
      response['test_only'] == true &&
      const [
        'REQUESTED_TEST_ONLY',
        'ACCEPTED_TEST_ONLY',
        'PROCESSING_TEST_ONLY',
      ].contains(response['state']);

  @override
  Widget build(BuildContext context) {
    final current = data;
    final test =
        current?['channel'] == 'TEST_ONLY' && current?['test_only'] == true;
    final version = current?['object_version'];
    final state = current?['state'];
    return frame('申请删除数据', [
      Text(
        widget.type == 'work'
            ? '对象范围为你的这条作品。其他人发表的评论和独立资料有各自的处理范围。'
            : '对象范围为你发表的这条评论。作品正文与其他人的回复另有各自的处理范围。',
      ),
      const Text('改变展示范围与申请删除数据是两项操作。'),
      if (current?['channel'] == 'REQUEST_CHANNEL_UNAVAILABLE')
        const Text('目前没有已核实可受理此对象的渠道。'),
      if (test) ...[
        Text(switch (state) {
          'REQUESTED_TEST_ONLY' => '测试请求已记录',
          'ACCEPTED_TEST_ONLY' => '隔离测试已受理',
          'PROCESSING_TEST_ONLY' => '隔离测试处理中',
          'NO_REQUEST' => '仅隔离测试',
          _ => '当前状态待核对',
        }),
        if (!busy &&
            state == 'NO_REQUEST' &&
            version is String &&
            (_pending == null || (_checked && _pending?.$2 == version)))
          FilledButton(
            onPressed: () => _submit(version),
            child: Text(_pending == null ? '提交测试请求' : '用原请求重试'),
          ),
      ],
      if (_pending != null)
        OutlinedButton(
          onPressed: busy ? null : _check,
          child: const Text('核对原请求'),
        ),
    ]);
  }
}
