import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';
import 'buddy_display.dart';

class BuddyDiscoveryPage extends ConsumerStatefulWidget {
  const BuddyDiscoveryPage({super.key});

  @override
  ConsumerState<BuddyDiscoveryPage> createState() => _BuddyDiscoveryPageState();
}

class _BuddyDiscoveryPageState extends SessionBoundPage<BuddyDiscoveryPage>
    with WidgetsBindingObserver {
  final _city = TextEditingController(text: '线上');
  String _type = 'MEAL';
  String _appliedCity = '线上';
  String _appliedType = 'MEAL';
  List<Map<String, dynamic>> _items = [];
  String? _cursor;
  bool _hasMore = false;
  int _revision = 0;
  Map<String, dynamic>? _pendingBody;
  int? _pendingPublication;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
      return;
    }
    _revision++;
    _items = [];
    _cursor = null;
    _hasMore = false;
    invalidatePendingProjection();
    Navigator.of(context).popUntil((route) => route is! PopupRoute);
  }

  @override
  String get resource => _path();

  String _path({String? cursor}) =>
      '/buddy/discovery?${Uri(queryParameters: {'city': _appliedCity, 'type': _appliedType, 'limit': '20', 'cursor': ?cursor}).query}';

  void _clear() {
    _revision++;
    _items = [];
    _cursor = null;
    _hasMore = false;
    _pendingBody = null;
    _pendingPublication = null;
    _city.text = '线上';
    _type = 'MEAL';
    _appliedCity = '线上';
    _appliedType = 'MEAL';
  }

  @override
  void onIdentityChanged() => _clear();

  @override
  void onAuthorityChanged() => _clear();

  @override
  Future<void> refresh() async {
    final revision = ++_revision;
    _items = [];
    _cursor = null;
    _hasMore = false;
    final result = await run(
      () => ref.read(relationshipApiProvider).call('GET', _path()),
    );
    if (!mounted || revision != _revision || result == null) return;
    setState(() {
      _items = rows(result['items']);
      _cursor = result['next_cursor']?.toString();
      _hasMore = result['has_more'] == true;
    });
  }

  Future<void> _search() async {
    if (_city.text.trim().length < 2) {
      setState(() => error = '请选择粗城市或填写“线上”。');
      return;
    }
    _appliedCity = _city.text.trim();
    _appliedType = _type;
    await refresh();
  }

  Future<void> _more() async {
    if (busy || !_hasMore || _cursor == null) return;
    final revision = _revision;
    final result = await run(
      () =>
          ref.read(relationshipApiProvider).call('GET', _path(cursor: _cursor)),
      onFailure: (failure) {
        if (failure is RelationshipFailure &&
            const [401, 403].contains(failure.statusCode)) {
          _revision++;
          _items = [];
          _cursor = null;
          _hasMore = false;
          data = null;
          error = '搭子发现当前不可用，请重新检查搭子许可。';
        }
      },
    );
    if (!mounted || revision != _revision || result == null) return;
    setState(() {
      final seen = _items.map((item) => item['publication_id']).toSet();
      _items = [
        ..._items,
        ...rows(
          result['items'],
        ).where((item) => !seen.contains(item['publication_id'])),
      ];
      _cursor = result['next_cursor']?.toString();
      _hasMore = result['has_more'] == true;
    });
  }

  Future<void> _apply(Map<String, dynamic> item) async {
    if (busy || _pendingBody != null || item['publication_id'] is! int) return;
    if (!await confirm('申请本次搭子？', '申请后等待作者确认。仅建立本次活动参与，不授予好友、私信、通话或资料权限。')) {
      return;
    }
    _pendingPublication = item['publication_id'] as int;
    _pendingBody = Map<String, dynamic>.unmodifiable({
      'generation': item['generation'],
      'revision': item['revision'],
      'idempotency_key': requestKey(),
    });
    await _retry();
  }

  Future<void> _retry() async {
    if (busy || _pendingBody == null) return;
    final revision = _revision;
    final result = await run(
      () => ref
          .read(relationshipApiProvider)
          .call(
            'POST',
            '/buddy/discovery/$_pendingPublication/apply',
            _pendingBody,
          ),
    );
    if (!mounted || revision != _revision) return;
    if (result == null) {
      setState(() {
        _items = [];
        _cursor = null;
        _hasMore = false;
      });
      return;
    }
    _pendingBody = null;
    _pendingPublication = null;
    if (await confirm('申请已受理', '返回“我的搭子”查看等待确认状态。')) {
      if (mounted) Navigator.of(context).pop();
    } else {
      await refresh();
    }
  }

  @override
  Widget build(BuildContext context) => frame('搭子发现', [
    const Text('选择粗城市或线上、搭子类型。只展示明确发布且当前可申请的活动。请先在“我的搭子”开启搭子请求。'),
    TextField(
      key: const Key('buddy-discovery-city'),
      controller: _city,
      enabled: !busy && _pendingBody == null,
      maxLength: 40,
      decoration: const InputDecoration(labelText: '粗城市 / 线上'),
    ),
    DropdownButton<String>(
      key: const Key('buddy-discovery-type'),
      value: _type,
      items: const [
        DropdownMenuItem(value: 'MEAL', child: Text('吃饭')),
        DropdownMenuItem(value: 'STUDY', child: Text('学习')),
      ],
      onChanged: busy || _pendingBody != null
          ? null
          : (value) => setState(() => _type = value!),
    ),
    FilledButton(
      key: const Key('buddy-discovery-search'),
      onPressed: busy || _pendingBody != null ? null : _search,
      child: const Text('查找搭子'),
    ),
    if (_pendingBody != null) ...[
      const Text('申请结果尚未确认，原编号和内容已保留。可同号重试，或返回“我的搭子”重读结果。'),
      FilledButton(
        key: const Key('buddy-discovery-retry'),
        onPressed: busy ? null : _retry,
        child: const Text('原编号重试申请'),
      ),
    ],
    if (_items.isEmpty && !busy && error == null) const Text('当前没有符合条件的公开搭子。'),
    for (final item in _items)
      Card(
        key: ValueKey('buddy-discovery-${item['publication_id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item['type'] == 'STUDY' ? '学习' : '吃饭'} · ${item['subject']}',
              ),
              Text('发布称呼：${item['author_label']}'),
              Text(
                '${item['general_city']} · ${item['place_kind'] == 'ONLINE' ? '线上' : '公共空间'}',
              ),
              Text(
                '预算档位：${switch (item['budget_band']) {
                  'LOW' => '低',
                  'MID' => '中',
                  'HIGH' => '高',
                  _ => '未指定',
                }}',
              ),
              Text(
                '${buddyLocalTime(item['start_at'])} 至 ${buddyLocalTime(item['end_at'])}',
              ),
              Text('发现截止：${buddyLocalTime(item['expires_at'])}'),
              FilledButton(
                key: ValueKey(
                  'buddy-discovery-apply-${item['publication_id']}',
                ),
                onPressed: busy || _pendingBody != null
                    ? null
                    : () => _apply(item),
                child: const Text('申请本次搭子'),
              ),
            ],
          ),
        ),
      ),
    if (_hasMore)
      OutlinedButton(
        key: const Key('buddy-discovery-more'),
        onPressed: busy || _pendingBody != null ? null : _more,
        child: const Text('加载更多'),
      ),
  ]);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _city.dispose();
    super.dispose();
  }
}
