import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  static const matchEntryKey = ValueKey<String>('progress-match-entry');

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
        ],
      ),
    );
  }
}
