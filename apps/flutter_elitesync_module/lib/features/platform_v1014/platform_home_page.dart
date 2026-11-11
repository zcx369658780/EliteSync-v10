import 'package:flutter/material.dart';
import '../buddy_v1013/buddy_page.dart';
import '../status/presentation/pages/status_square_page.dart';
import 'platform_events_page.dart';

class PlatformHomePage extends StatelessWidget {
  const PlatformHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('首页')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
      children: [
        Text('相约与交流', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('按自己的节奏参与活动、寻找搭子，或看看好友动态。'),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('平台活动 · 合成演练'),
            subtitle: const Text('查看受控邀请、自愿报名、候补与退出'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PlatformEventsPage(),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('独立吃饭 / 学习搭子'),
            subtitle: const Text('自主寻找搭子，联系前仍需双方同意。'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const BuddyPage())),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.dynamic_feed_outlined),
            title: const Text('好友可见社区'),
            subtitle: const Text('查看与分享好友范围内的动态。'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatusSquarePage()),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前为开发环境', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                const Text('平台活动仅为虚构开发演练；不招募、不预订、不付款。'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '活动、搭子、好友、消息同意与正式关系分别确认，参与其中一项不会自动开启其他互动。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
