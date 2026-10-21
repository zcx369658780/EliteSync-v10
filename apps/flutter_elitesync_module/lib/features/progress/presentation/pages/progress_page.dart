import 'package:flutter_elitesync_module/features/buddy_v1013/buddy_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/calm_home_projection_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  static const matchEntryKey = ValueKey<String>('progress-match-entry');
  static const connectionEntryKey = ValueKey<String>(
    'progress-connection-entry',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const v1013 = bool.fromEnvironment('ELITESYNC_V1013_LOCAL_BUILD');
    final projection = v1013
        ? CalmHomeProjection.current
        : ref.watch(calmHomeProjectionProvider);
    final summaries = projection.summaries.where(
      (summary) => summary.domain != HomeProjectedDomain.conversation,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('进展')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (v1013) ...[
              Text('独立活动与社区', style: Theme.of(context).textTheme.titleMedium),
              const Text('不要求婚恋资料或慢约参与；搭子、好友与消息同意分别确认。'),
              Card(
                child: ListTile(
                  key: const ValueKey('progress-buddy-entry'),
                  leading: const Icon(Icons.restaurant_outlined),
                  title: const Text('独立吃饭 / 学习搭子'),
                  subtitle: const Text('创建或查看受控活动；不会报名慢约或建立正式关系。'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const BuddyPage()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  key: const ValueKey('progress-community-entry'),
                  leading: const Icon(Icons.dynamic_feed_outlined),
                  title: const Text('好友可见社区'),
                  subtitle: const Text('查看当前有权读取的动态与一级评论。'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StatusSquarePage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
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
            Card(
              child: ListTile(
                title: const Text('正式恋爱关系'),
                subtitle: const Text('独立申请与双向确认；真实实人供应商待配置'),
                leading: const Icon(Icons.favorite_border),
                onTap: () => context.push('/formal-relationship'),
              ),
            ),
            if (!const bool.fromEnvironment('ELITESYNC_V1012_LOCAL_BUILD') &&
                !v1013) ...[
              Text('三阶段只读摘要', style: Theme.of(context).textTheme.titleMedium),
              const Text('摘要不授予匹配、连接或消息权限；准备状态未知不会自动撤销已有连接。'),
              if (summaries.any(
                (summary) =>
                    summary.authority ==
                    HomeProjectionAuthority.syntheticDevelopment,
              ))
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('开发演示（Synthetic）· 非正式事实，不代表匹配、连接或消息权限'),
                ),
              for (final summary in summaries)
                Card(
                  key: ValueKey('progress-state-${summary.domain.name}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.domain.label,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(_stateLabel(summary)),
                        Text(_sourceLabel(summary.authority)),
                      ],
                    ),
                  ),
                ),
            ],
            Card(
              child: ListTile(
                key: const ValueKey('progress-readiness-entry'),
                title: const Text('查看准备状态'),
                subtitle: const Text('查看状态来源与现有设置入口，不产生正式资格结论。'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppRouteNames.meReadiness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _sourceLabel(HomeProjectionAuthority authority) => switch (authority) {
  HomeProjectionAuthority.syntheticDevelopment => '来源：开发演示（Synthetic）',
  HomeProjectionAuthority.authoritative => '来源：所属功能',
  HomeProjectionAuthority.notYetEstablished => '来源：尚未建立',
  HomeProjectionAuthority.unknown => '来源：未知',
};

// Interpret only domain-specific codes already carried by the Home contract.
// A missing or unfamiliar code provides no evidence of a lifecycle outcome.
String _stateLabel(HomeStateSummary summary) {
  if (summary.authority == HomeProjectionAuthority.unknown ||
      summary.authority == HomeProjectionAuthority.notYetEstablished) {
    return '当前无法确认';
  }
  return switch ((summary.domain, summary.stateCode)) {
    (HomeProjectedDomain.readiness, 'READY') => '准备状态就绪',
    (HomeProjectedDomain.readiness, 'SETUPREQUIRED') => '准备设置尚待继续',
    (HomeProjectedDomain.readiness, 'UNAUTHENTICATED') => '尚未登录',
    (HomeProjectedDomain.match, 'MT_ACTIVE') => '匹配进行中',
    (HomeProjectedDomain.match, 'MT_PROPOSAL_PRESENTED') => '已有匹配提案',
    (HomeProjectedDomain.connection, 'CN_NONE') => '尚未发起连接',
    (HomeProjectedDomain.connection, 'CN_PENDING') => '等待另一方独立确认',
    (HomeProjectedDomain.connection, 'CN_ACTIVE') => '双方已同意连接',
    (HomeProjectedDomain.connection, 'CN_PAUSED') => '连接已暂停',
    (HomeProjectedDomain.connection, 'CN_CLOSED') => '连接已关闭',
    (HomeProjectedDomain.connection, 'CN_DECLINED') => '连接请求已谢绝',
    (HomeProjectedDomain.connection, 'CN_WITHDRAWN') => '连接请求已撤回',
    (HomeProjectedDomain.connection, 'CN_EXPIRED') => '连接请求已过期',
    _ => '当前无法确认',
  };
}
