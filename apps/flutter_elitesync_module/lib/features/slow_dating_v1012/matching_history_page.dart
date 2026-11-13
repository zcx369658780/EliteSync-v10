import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import 'journey_components.dart';

class MatchingHistoryPage extends ConsumerStatefulWidget {
  const MatchingHistoryPage({super.key});

  @override
  ConsumerState<MatchingHistoryPage> createState() => _MatchingHistoryState();
}

class _MatchingHistoryState extends SessionBoundPage<MatchingHistoryPage>
    with WidgetsBindingObserver {
  int _page = 1;

  @override
  String get resource => '/journey/history?page=$_page&per_page=10';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onIdentityChanged() => _page = 1;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = data?['data'] is List ? data!['data'] as List : const [];
    return frame('本人慢约历史', [
      const Text('记录本人参与与选择过程。对方资料按当前发布及受众权限读取。'),
      if (data != null && rows.isEmpty) const Text('暂无已揭晓提案历史。'),
      for (final value in rows)
        Builder(
          builder: (context) {
            final row = objectMap(value);
            final showcase = objectMap(row['showcase']);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(journeyStateLabel(row['state'])),
                    Text('本人选择 ${decisionLabel(row['decision_me'])}'),
                    Text('揭晓 ${row['revealed_at'] ?? '—'}'),
                    Text('有效期 ${row['expires_at'] ?? '—'}'),
                    Text('轮次 ${row['round_id']} · 提案 ${row['id']}'),
                    if (showcase['summary'] != null)
                      Text('${showcase['summary']}')
                    else
                      const Text('对方展示资料当前不可见'),
                    const Text('此处保留过程记录，当前提案操作请返回慢约旅程。'),
                  ],
                ),
              ),
            );
          },
        ),
      if (data != null)
        Row(
          children: [
            TextButton(
              onPressed: busy || _page <= 1
                  ? null
                  : () {
                      _page--;
                      refresh();
                    },
              child: const Text('上一页'),
            ),
            Text('第 ${data!['current_page']} / ${data!['last_page']} 页'),
            TextButton(
              onPressed: busy || _page >= (data!['last_page'] as int? ?? 1)
                  ? null
                  : () {
                      _page++;
                      refresh();
                    },
              child: const Text('下一页'),
            ),
          ],
        ),
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
