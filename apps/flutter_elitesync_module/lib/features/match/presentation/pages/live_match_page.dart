import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class LiveMatchPage extends ConsumerStatefulWidget {
  const LiveMatchPage({super.key});
  @override
  ConsumerState<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends ConsumerState<LiveMatchPage> {
  Map<String, dynamic>? _current;
  List<dynamic> _history = [];
  String? _error;
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final principal = ref.read(sessionProvider).asData?.value.user?.id;
    final api = ref.read(apiClientProvider);
    final current = await api.get('/api/v1/matches/current');
    final history = await api.get('/api/v1/matches/history');
    if (!mounted ||
        principal != ref.read(sessionProvider).asData?.value.user?.id) {
      return;
    }
    setState(() {
      _current = current is NetworkSuccess<Map<String, dynamic>>
          ? current.data
          : null;
      _error = _current == null ? '尚无已发布结果。请先完成问卷，等待匹配。' : null;
      _history = history is NetworkSuccess<Map<String, dynamic>>
          ? (history.data['items'] as List? ?? [])
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (a, b) {
      if (a?.asData?.value.user?.id != b.asData?.value.user?.id) {
        setState(() {
          _current = null;
          _history = [];
          _error = '账号已变化，请刷新。';
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('匹配'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) Text(_error!),
          if (_current case final match?) ...[
            Text(
              match['partner_nickname']?.toString() ?? '匹配伙伴',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(match['highlights']?.toString() ?? ''),
            const Text('匹配是规则参考，不能替代双方独立连接和消息同意。未恢复的完整排盘不作为事实判断。'),
            FilledButton(
              onPressed: () => context.push(
                '/live-connection?peerId=${match['partner_id']}',
              ),
              child: const Text('连接与消息同意'),
            ),
          ],
          Text('历史结果 ${_history.length} 条'),
          for (final item in _history)
            Card(
              child: ListTile(
                title: Text(item['partner_nickname']?.toString() ?? '历史匹配'),
                subtitle: Text(item['highlights']?.toString() ?? ''),
              ),
            ),
        ],
      ),
    );
  }
}
