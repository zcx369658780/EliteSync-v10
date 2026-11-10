import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/state/connection_presentation_state.dart';

class ConnectionAuthorityPanel extends StatelessWidget {
  const ConnectionAuthorityPanel({
    super.key,
    this.snapshot = const ConnectionPresentationState.notYetEstablished(),
    this.availableTransitions = const <ConnectionTransition>[],
    this.onAction,
    this.onReset,
  });

  final ConnectionPresentationState snapshot;
  final List<ConnectionTransition> availableTransitions;
  final ValueChanged<ConnectionLifecycleAction>? onAction;
  final VoidCallback? onReset;

  String _label(ConnectionLifecycleAction action) => switch (action) {
    ConnectionLifecycleAction.request => '本地演示：请求连接',
    ConnectionLifecycleAction.accept => '本地演示：模拟对方接受',
    ConnectionLifecycleAction.decline => '本地演示：模拟对方谢绝',
    ConnectionLifecycleAction.withdraw => '本地演示：撤回请求',
    ConnectionLifecycleAction.expire => '本地演示：模拟请求过期',
    ConnectionLifecycleAction.pause => '本地演示：暂停连接',
    ConnectionLifecycleAction.resume => '本地演示：恢复连接',
    ConnectionLifecycleAction.close => '本地演示：关闭连接',
  };

  @override
  Widget build(BuildContext context) {
    final isSynthetic = snapshot.hasSyntheticDevelopmentState;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSynthetic ? '本地演示操作' : '可用操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isSynthetic
                  ? '以下控件只推进本地内存 simulation，并且只展示当前状态在 ProductConnectionContract.transitions 中允许的动作。它们不写入服务器，也不建立生产 Connection authority。'
                  : '当前没有已接入的产品连接写入权限。以下操作不会模拟成功，也不会在本机保存为双方同意事实。',
            ),
            const SizedBox(height: 12),
            if (isSynthetic) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final transition in availableTransitions)
                    FilledButton.tonal(
                      onPressed: onAction == null
                          ? null
                          : () => onAction!(transition.action),
                      child: Text(_label(transition.action)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('重置本地演示（非领域 transition）'),
              ),
            ] else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final action in ConnectionLifecycleAction.values)
                    Semantics(
                      label:
                          '${action.label}，${ProductConnectionAuthority.notYetEstablishedLabel}',
                      child: Chip(
                        avatar: const Icon(Icons.lock_outline, size: 16),
                        label: Text(
                          '${action.label} · ${ProductConnectionAuthority.notYetEstablishedLabel}',
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
