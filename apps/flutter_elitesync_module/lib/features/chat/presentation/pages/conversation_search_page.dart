import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class ConversationSearchPage extends ConsumerStatefulWidget {
  const ConversationSearchPage({super.key, required this.peerId});
  final int peerId;
  @override
  ConsumerState<ConversationSearchPage> createState() =>
      _ConversationSearchPageState();
}

class _ConversationSearchPageState extends ConsumerState<ConversationSearchPage>
    with WidgetsBindingObserver {
  final _query = TextEditingController();
  final _items = <Map<String, dynamic>>[];
  SessionState? _session;
  int _generation = 0;
  int? _cursor;
  bool _more = false;
  bool _busy = false;
  bool _foreground = true;
  String? _status;
  Timer? _timer;

  bool _current(int generation) =>
      mounted &&
      _foreground &&
      generation == _generation &&
      _session?.isLoggedIn == true &&
      identical(ref.read(sessionProvider).asData?.value, _session);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = ref.read(sessionProvider).asData?.value;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _validate());
  }

  void _clear([String? status]) {
    if (!mounted) return;
    setState(() {
      _generation++;
      _items.clear();
      _cursor = null;
      _more = false;
      _busy = false;
      _status = status;
    });
  }

  Future<void> _validate() async {
    final generation = _generation;
    if (!_current(generation) || _items.isEmpty || _busy) return;
    final result = await ref
        .read(apiClientProvider)
        .get(
          '/api/v1/connections/${widget.peerId}',
          options: Options(
            extra: {requestSessionGuardKey: () => _current(generation)},
          ),
        );
    if (!_current(generation)) return;
    if (result is! NetworkSuccess<Map<String, dynamic>> ||
        (result.data['gates'] as Map?)?['live_read_allowed'] != true) {
      _clear('当前读取权限未能核验，请返回会话重新验证。');
    }
  }

  Future<void> _search({bool older = false}) async {
    if (_busy) return;
    final query = _query.text.trim();
    if (query.isEmpty || query.runes.length > 100) {
      _clear('请输入1–100个字符。');
      return;
    }
    if (!older) _clear();
    final generation = _generation;
    if (!_current(generation)) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    final result = await ref
        .read(apiClientProvider)
        .get(
          '/api/v1/messages/search',
          query: {
            'peer_id': widget.peerId,
            'query': query,
            if (older && _cursor != null) 'before_id': _cursor,
          },
          options: Options(
            extra: {requestSessionGuardKey: () => _current(generation)},
          ),
        );
    if (!_current(generation)) return;
    if (result is! NetworkSuccess<Map<String, dynamic>>) {
      _clear('搜索未完成，请检查网络和当前权限后重试。');
      return;
    }
    setState(() {
      _items.addAll(
        (result.data['items'] as List? ?? []).whereType<Map<String, dynamic>>(),
      );
      _more = result.data['has_more'] == true;
      _cursor = (result.data['next_before_id'] as num?)?.toInt();
      _busy = false;
      _status = _more
          ? '本次检索范围已处理，可继续搜索更早消息。'
          : (_items.isEmpty ? '当前会话文字无匹配结果。' : '已搜索至会话起点。');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _clear('返回后请重新搜索。');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (_, next) {
      if (!identical(next.asData?.value, _session)) _clear('账号已变化，请返回。');
    });
    return Scaffold(
      appBar: AppBar(title: const Text('搜索当前会话')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _query,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: '文字关键词',
                suffixIcon: IconButton(
                  tooltip: '搜索',
                  onPressed: _busy ? null : () => _search(),
                  icon: const Icon(Icons.search),
                ),
              ),
              onChanged: (_) => _clear(),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_status != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(_status!)),
          Expanded(
            child: ListView(
              children: _items
                  .map(
                    (m) => ListTile(
                      title: Text(m['content']?.toString() ?? ''),
                      subtitle: Text(m['created_at']?.toString() ?? ''),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_more)
            TextButton(
              onPressed: _busy ? null : () => _search(older: true),
              child: const Text('继续搜索更早消息'),
            ),
        ],
      ),
    );
  }
}
