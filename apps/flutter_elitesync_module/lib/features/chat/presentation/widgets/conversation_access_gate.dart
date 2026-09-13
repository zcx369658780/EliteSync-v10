import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';

class ConversationAccessGate extends StatelessWidget {
  const ConversationAccessGate({
    super.key,
    required this.snapshot,
    required this.protectedBuilder,
  });

  final ConversationAccessSnapshot snapshot;
  final WidgetBuilder protectedBuilder;

  @override
  Widget build(BuildContext context) {
    if (snapshot.canRevealPrivateContent) {
      return Builder(builder: protectedBuilder);
    }
    return ConversationAccessUnavailablePage(snapshot: snapshot);
  }
}

class ConversationAccessUnavailablePage extends StatelessWidget {
  const ConversationAccessUnavailablePage({super.key, required this.snapshot});

  final ConversationAccessSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final pending = snapshot.state == ProductConversationState.pendingConsent;
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pending ? '消息同意仍在等待' : '消息权限尚未建立',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.authority ==
                            ConversationEvidenceAuthority.authoritative
                        ? snapshot.state.code
                        : ProductConversationAuthority.notYetEstablishedLabel,
                  ),
                  const SizedBox(height: 8),
                  const Text('锁定或等待同意时，不会加载或显示会话、对方身份、消息预览、未读数或私密线程详情。'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('独立的消息同意'),
                  SizedBox(height: 8),
                  Text('匹配不会开启对话；连接本身也不会开启对话。'),
                  SizedBox(height: 8),
                  Text('只有权威的 CN_ACTIVE 与另一项独立的双方消息同意同时成立，私密对话才可用。'),
                  SizedBox(height: 8),
                  Text('拉黑与举报是两个独立控制，都不是消息同意或对话生命周期事实。'),
                  SizedBox(height: 8),
                  Text('同意或生命周期状态也不是安全认定；对话不会建立关系。'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('可用操作', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('当前没有已接入的消息同意写入权限；以下操作不会模拟成功，也不会在本机保存为双方同意事实。'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in ConversationLifecycleAction.values)
                        Chip(
                          avatar: const Icon(Icons.lock_outline, size: 16),
                          label: Text(
                            '${action.label} · ${ProductConversationAuthority.notYetEstablishedLabel}',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
