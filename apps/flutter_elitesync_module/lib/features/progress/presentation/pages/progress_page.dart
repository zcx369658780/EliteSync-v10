import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  static const matchEntryKey = ValueKey<String>('progress-match-entry');
  static const connectionEntryKey = ValueKey<String>(
    'progress-connection-entry',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('进展')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
        children: [
          Text('当前可用', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: matchEntryKey,
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('匹配'),
              subtitle: const Text('进入现有匹配流程；匹配不会自动建立连接或开启对话。'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go(AppRouteNames.progressMatch),
            ),
          ),
          const SizedBox(height: 20),
          Text('连接生命周期', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: connectionEntryKey,
              leading: const Icon(Icons.link_outlined),
              title: const Text('连接'),
              subtitle: const Text('查看独立的双方同意状态；连接不会自动开启消息或关系。'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go(AppRouteNames.progressConnection),
            ),
          ),
        ],
      ),
    );
  }
}
