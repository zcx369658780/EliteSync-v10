import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';

class ConversationAccessGate extends StatelessWidget {
  const ConversationAccessGate({
    super.key,
    required this.snapshot,
    required this.protectedBuilder,
    this.availableTransitions = const <ConversationTransition>[],
    this.onAction,
    this.onReset,
  });

  final ConversationAccessSnapshot snapshot;
  final WidgetBuilder protectedBuilder;
  final List<ConversationTransition> availableTransitions;
  final ValueChanged<ConversationLifecycleAction>? onAction;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    if (snapshot.canRevealPrivateContent) {
      return Builder(builder: protectedBuilder);
    }
    return ConversationAccessUnavailablePage(
      snapshot: snapshot,
      availableTransitions: availableTransitions,
      onAction: onAction,
      onReset: onReset,
    );
  }
}

class ConversationAccessUnavailablePage extends StatelessWidget {
  const ConversationAccessUnavailablePage({
    super.key,
    required this.snapshot,
    this.availableTransitions = const <ConversationTransition>[],
    this.onAction,
    this.onReset,
  });

  final ConversationAccessSnapshot snapshot;
  final List<ConversationTransition> availableTransitions;
  final ValueChanged<ConversationLifecycleAction>? onAction;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final pending = snapshot.state == ProductConversationState.pendingConsent;
    final isSynthetic = snapshot.hasSyntheticDevelopmentState;
    final hasAuthority = snapshot.hasAuthoritativeState;
    const unresolved = AppPresentationState.authorityNotEstablished(
      safeTitle: '消息权限尚未建立',
      safeBody: '当前来源不足以授权会话内容或操作；受保护的对方身份、消息预览、未读数和线程详情保持关闭。',
    );
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
                    isSynthetic
                        ? 'Synthetic Conversation · 开发演示'
                        : pending
                        ? '消息同意仍在等待'
                        : unresolved.safeTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSynthetic || hasAuthority
                        ? snapshot.state.code
                        : ProductConversationAuthority.notYetEstablishedLabel,
                  ),
                  const SizedBox(height: 8),
                  if (isSynthetic) ...[
                    const Text('这是本地开发 simulation，不是服务器或生产 messaging consent authority。'),
                    const SizedBox(height: 8),
                  ] else if (!hasAuthority) ...[
                    Text(unresolved.safeBody),
                    const SizedBox(height: 8),
                  ],
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
                  Text('只有连接保持 active，并另行完成双方消息同意后，本地 synthetic 会话才可见。'),
                  SizedBox(height: 8),
                  Text('生产路径仍严格要求权威 Connection 与权威消息同意证据。'),
                  SizedBox(height: 8),
                  Text('同意或生命周期状态不是安全认定；对话不会建立关系。'),
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
                  Text(
                    isSynthetic
                        ? '以下控件只推进本地内存 simulation，并且只展示 ProductConversationContract.transitions 当前允许的动作。'
                        : '当前没有已接入的消息同意写入权限；以下操作不会模拟成功，也不会保存为双方同意事实。',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: isSynthetic
                        ? [
                            for (final transition in availableTransitions)
                              OutlinedButton(
                                onPressed: onAction == null
                                    ? null
                                    : () => onAction!(transition.action),
                                child: Text(_syntheticLabel(transition.action)),
                              ),
                            if (onReset != null)
                              OutlinedButton(
                                onPressed: onReset,
                                child: const Text('重置本地演示（非领域 transition）'),
                              ),
                          ]
                        : [
                            for (final action
                                in ConversationLifecycleAction.values)
                              Chip(
                                avatar: const Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                ),
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

  String _syntheticLabel(ConversationLifecycleAction action) => switch (action) {
    ConversationLifecycleAction.requestMessagingConsent =>
      '本地演示：请求消息同意',
    ConversationLifecycleAction.acceptMessagingConsent =>
      '本地演示：模拟对方接受',
    ConversationLifecycleAction.declineMessagingConsent =>
      '本地演示：模拟对方谢绝',
    ConversationLifecycleAction.withdrawMessagingConsent =>
      '本地演示：撤回消息请求',
    ConversationLifecycleAction.pause => '本地演示：暂停对话',
    ConversationLifecycleAction.resume => '本地演示：恢复对话',
    ConversationLifecycleAction.close => '本地演示：关闭对话',
  };
}
