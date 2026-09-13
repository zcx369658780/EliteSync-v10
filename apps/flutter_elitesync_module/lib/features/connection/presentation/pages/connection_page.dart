import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/state/connection_presentation_state.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/widgets/connection_authority_panel.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({
    super.key,
    this.snapshot = const ConnectionPresentationState.notYetEstablished(),
  });

  final ConnectionPresentationState snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('连接')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _ConnectionStatusCard(snapshot: snapshot),
          const SizedBox(height: 12),
          const _ConnectionBoundaryCard(),
          const SizedBox(height: 12),
          const ConnectionAuthorityPanel(),
        ],
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  const _ConnectionStatusCard({required this.snapshot});

  final ConnectionPresentationState snapshot;

  @override
  Widget build(BuildContext context) {
    final state = snapshot.state;
    final hasAuthority = snapshot.hasAuthoritativeState && state != null;
    const unresolved = AppPresentationState.authorityNotEstablished(
      safeTitle: '连接状态尚未建立',
      safeBody:
          '尚无已接入的权威 Product Connection 快照；这里不会把传输连接、匹配结果或本地状态当作连接事实。受保护内容与操作保持关闭。',
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasAuthority ? '当前连接状态' : unresolved.safeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasAuthority
                  ? state!.code
                  : ProductConnectionAuthority.notYetEstablishedLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(hasAuthority ? state!.label : unresolved.safeBody),
            if (hasAuthority && state!.isTerminalRequestOutcome) ...[
              const SizedBox(height: 8),
              const Text('该结果不代表过错、安全认定，也不是客观不合适的结论。'),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConnectionBoundaryCard extends StatelessWidget {
  const _ConnectionBoundaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('独立的双方同意', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('匹配或双方表达兴趣都不会自动建立连接；连接需要双方在独立流程中同意。'),
            const SizedBox(height: 8),
            const Text('连接也不会自动授权消息或关系。消息同意与关系声明属于各自独立的生命周期。'),
            const SizedBox(height: 8),
            const Text('谢绝、撤回或过期只描述本次请求结果，不代表过错、安全认定或客观不合适。'),
          ],
        ),
      ),
    );
  }
}
