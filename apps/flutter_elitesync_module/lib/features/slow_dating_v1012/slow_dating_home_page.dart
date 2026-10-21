import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../relationships_v1011/session_bound_page.dart';
import 'journey_components.dart';

class SlowDatingHomePage extends ConsumerStatefulWidget {
  const SlowDatingHomePage({super.key});
  @override
  ConsumerState<SlowDatingHomePage> createState() => _HomeState();
}

class _HomeState extends SessionBoundPage<SlowDatingHomePage> {
  @override
  String get resource => '/journey';

  @override
  Widget build(BuildContext context) {
    final participation = objectMap(data?['participation']);
    final round = objectMap(data?['round']);
    return frame('慢约进展', [
      const Text('按自己的节奏，认真认识一个人。'),
      if (data != null) ...[
        const SizedBox(height: 24),
        Text('当前参与：${journeyStateLabel(participation['state'])}'),
        Text('本轮：${journeyStateLabel(round['state'])}'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.go('/progress/match'),
          child: const Text('查看准备与慢约旅程'),
        ),
      ],
      const SizedBox(height: 24),
      const Text('匹配、连接、消息同意与正式关系分别确认。首页只读取状态，不会替你报名或同意。'),
    ]);
  }
}
