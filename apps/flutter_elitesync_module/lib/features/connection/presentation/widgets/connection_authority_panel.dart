import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

class ConnectionAuthorityPanel extends StatelessWidget {
  const ConnectionAuthorityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('可用操作', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('当前没有已接入的产品连接写入权限。以下操作不会模拟成功，也不会在本机保存为双方同意事实。'),
            const SizedBox(height: 12),
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
