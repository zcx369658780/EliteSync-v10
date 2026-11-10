import 'package:flutter/material.dart';
import '../buddy_v1013/buddy_page.dart';
import '../status/presentation/pages/status_square_page.dart';
import 'platform_events_page.dart';

class PlatformHomePage extends StatelessWidget {
  const PlatformHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('受控活动与社交')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('平台活动仅为虚构开发演练；不招募、不预订、不付款。'),
        ListTile(
          title: const Text('平台活动 · 合成演练'),
          subtitle: const Text('查看受控邀请、自愿报名、候补与退出'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PlatformEventsPage()),
          ),
        ),
        ListTile(
          title: const Text('独立吃饭 / 学习搭子'),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const BuddyPage())),
        ),
        ListTile(
          title: const Text('好友可见社区'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const StatusSquarePage()),
          ),
        ),
        const Text('活动、搭子、好友、消息同意与正式关系保持独立。'),
      ],
    ),
  );
}
