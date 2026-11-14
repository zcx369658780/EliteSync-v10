import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/session_bound_page.dart';

/// Selects a contact from the server-authorized set for [purpose].
/// The returned map contains the server peer id and its minimal display label.
class ContactPickerPage extends ConsumerStatefulWidget {
  const ContactPickerPage({super.key, required this.purpose});

  final String purpose;

  @override
  ConsumerState<ContactPickerPage> createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends SessionBoundPage<ContactPickerPage> {
  static const _purposes = {
    'buddy_invite',
    'friend_request',
    'chat',
    'connection',
  };

  final _queryController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  String? _cursor;
  bool _hasMore = false;
  int _queryRevision = 0;
  String _appliedQuery = '';

  String get _query => _queryController.text.trim();

  @override
  String get resource => _path();

  String _path({String? cursor, String? query}) {
    final params = <String, String>{
      'purpose': widget.purpose,
      'limit': '20',
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (query != null && query.isNotEmpty) 'query': query,
    };
    return '/social/contacts?${Uri(queryParameters: params).query}';
  }

  void _clearPickerState() {
    _items = [];
    _cursor = null;
    _hasMore = false;
    _queryController.clear();
    _appliedQuery = '';
    _queryRevision++;
  }

  @override
  void onIdentityChanged() => _clearPickerState();

  @override
  void onAuthorityChanged() => _clearPickerState();

  @override
  Future<void> refresh() async {
    if (!_purposes.contains(widget.purpose)) {
      _items = [];
      _cursor = null;
      _hasMore = false;
      _appliedQuery = '';
      return;
    }
    final revision = ++_queryRevision;
    _appliedQuery = _query;
    _items = [];
    _cursor = null;
    _hasMore = false;
    final result = await run(
      () => ref
          .read(relationshipApiProvider)
          .call('GET', _path(query: _appliedQuery)),
      replace: true,
    );
    if (!mounted || result == null || revision != _queryRevision) return;
    setState(() {
      _items = rows(result['items']);
      _cursor = result['next_cursor']?.toString();
      _hasMore = result['has_more'] == true;
    });
  }

  Future<void> _loadMore() async {
    final cursor = _cursor;
    if (busy || !_hasMore || cursor == null || cursor.isEmpty) return;
    final revision = _queryRevision;
    final result = await run(
      () => ref
          .read(relationshipApiProvider)
          .call('GET', _path(cursor: cursor, query: _appliedQuery)),
    );
    if (!mounted || result == null || revision != _queryRevision) return;
    setState(() {
      final seen = _items.map((item) => item['peer_id']).toSet();
      _items = [
        ..._items,
        ...rows(
          result['items'],
        ).where((item) => !seen.contains(item['peer_id'])),
      ];
      _cursor = result['next_cursor']?.toString();
      _hasMore = result['has_more'] == true;
    });
  }

  void _submitQuery() {
    if (!busy) refresh();
  }

  void _select(Map<String, dynamic> item) {
    final peerId = item['peer_id'];
    if (peerId == null) return;
    Navigator.of(context).pop(<String, dynamic>{
      'peer_id': peerId,
      'label': item['label']?.toString() ?? '联系人',
      'allowed_actions': item['allowed_actions'] is List
          ? List<String>.from(
              (item['allowed_actions'] as List).whereType<String>(),
            )
          : <String>[],
    });
  }

  @override
  Widget build(BuildContext context) {
    final validPurpose = _purposes.contains(widget.purpose);
    return frame('选择联系人', [
      Text(validPurpose ? '仅显示服务器允许用于当前操作的联系人。' : '当前用途无效，请返回后重新选择操作。'),
      Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('contact-picker-query'),
              controller: _queryController,
              enabled: !busy && validPurpose,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submitQuery(),
              decoration: const InputDecoration(labelText: '筛选联系人名称'),
            ),
          ),
          IconButton(
            key: const Key('contact-picker-search'),
            tooltip: '筛选',
            onPressed: busy || !validPurpose ? null : _submitQuery,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      if (_items.isEmpty && !busy && error == null)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('没有可选择的联系人。'),
        ),
      for (final item in _items)
        ListTile(
          key: ValueKey('contact-picker-peer-${item['peer_id']}'),
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(item['label']?.toString() ?? '联系人'),
          trailing: const Icon(Icons.chevron_right),
          onTap: busy ? null : () => _select(item),
        ),
      if (_hasMore)
        OutlinedButton(
          key: const Key('contact-picker-load-more'),
          onPressed: busy ? null : _loadMore,
          child: const Text('加载更多'),
        ),
    ]);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
