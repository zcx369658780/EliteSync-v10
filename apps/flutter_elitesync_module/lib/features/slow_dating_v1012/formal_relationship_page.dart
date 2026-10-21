import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import 'journey_components.dart';
import 'relationship_privacy_page.dart';

class FormalRelationshipPage extends ConsumerStatefulWidget {
  const FormalRelationshipPage({super.key});
  @override
  ConsumerState<FormalRelationshipPage> createState() => _FormalState();
}

class _FormalState extends SessionBoundPage<FormalRelationshipPage> {
  @override
  String get resource => '/formal-relationships';
  final _peer = TextEditingController();
  @override
  void onIdentityChanged() => _peer.clear();
  @override
  void dispose() {
    _peer.dispose();
    super.dispose();
  }

  List<String> _actions(Map<String, dynamic> relation) =>
      relation['allowed_actions'] is List
      ? (relation['allowed_actions'] as List).whereType<String>().toList()
      : const [];

  @override
  Widget build(BuildContext context) => frame('正式恋爱关系', [
    const Text('正式关系需要双方自愿逐次确认同一关系，以及双方当前有效的实人凭据。Match、好友、连接和消息同意不等于正式关系。'),
    if (data != null) ...[
      IdentityGateCard(identity: objectMap(data!['identity'])),
      const Text('开发默认每人同时最多一个ACTIVE关系；服务器事务裁决。未配置真实供应商时，真实账号不可激活。'),
      const Text(
        '可在好友与请求中心管理接收请求开关。撤回后重发有24小时冷却；被拒后不能换键重复请求。双方确认、实人核验及字段分享仍分别处理。',
      ),
      TextField(
        key: const Key('formal-peer'),
        controller: _peer,
        enabled: !busy,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: '对方用户编号',
          helperText: '仅限已有好友或生效连接，且对方已开启接收请求',
        ),
      ),
      FilledButton(
        key: const Key('formal-request'),
        onPressed: busy
            ? null
            : () async {
                final peerId = int.tryParse(_peer.text.trim());
                if (peerId == null || peerId <= 0) {
                  setState(() => error = '请输入有效的对方用户编号');
                  return;
                }
                if (!await confirm('自愿发起正式关系申请？', '对方仍需独立确认，激活还需服务器验证双方凭据。')) {
                  return;
                }
                await mutate('POST', resource, {
                  'peer_id': peerId,
                  'idempotency_key': requestKey(),
                });
              },
        child: const Text('发起正式关系申请'),
      ),
      if (rows(data!['relationships']).isEmpty) const Text('尚无正式关系记录。'),
      for (final relation in rows(data!['relationships'])) ...[
        const Divider(),
        Text('与 ES-${relation['peer_id']} 的正式关系'),
        if (relation['test_only'] == true)
          const Text('TEST_ONLY · 合成开发关系，非真实身份核验'),
        Text('关系状态：${journeyStateLabel(relation['state'])}'),
        Text(
          '本人确认：${relation['confirmed_me'] == true ? '已确认' : '尚未确认'}；对方确认：${relation['confirmed_peer'] == true ? '已确认' : '尚未确认'}',
        ),
        if (relation['revision'] is int && relation['id'] != null)
          Wrap(
            spacing: 8,
            children: [
              for (final action in _actions(relation))
                OutlinedButton(
                  key: ValueKey('formal-${relation['id']}-$action'),
                  onPressed: busy
                      ? null
                      : () async {
                          if (!await confirm(
                            _label(action),
                            action == 'end'
                                ? '任一方均可结束；旧关系不可恢复。现有合法连接与消息同意由其独立合同管理。'
                                : '本操作只代表你本人的决定。激活或恢复仍由服务器核对双方确认与有效凭据。',
                          )) {
                            return;
                          }
                          await mutate(
                            'POST',
                            '$resource/${relation['id']}/actions',
                            {
                              'action': action,
                              'revision': relation['revision'],
                              'idempotency_key': requestKey(),
                            },
                          );
                        },
                  child: Text(_label(action)),
                ),
            ],
          ),
        if (relation['peer_id'] is int)
          TextButton(
            onPressed: busy
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RelationshipPrivacyPage(
                        peerId: relation['peer_id'] as int,
                      ),
                    ),
                  ),
            child: const Text('管理字段分享 / 读取对方当前授权资料'),
          ),
      ],
      const Text(
        '暂停、结束、Block或凭据失效立即停止恋爱专属分享。核验恢复不会自动重新开放；需双方重新确认。退出不要求对方同意或当前有效核验，也不产生Safety结论。',
      ),
    ],
  ]);

  String _label(String action) => {
    'confirm': '本人确认正式关系',
    'decline': '拒绝关系申请',
    'withdraw': '撤回关系申请',
    'pause': '暂停关系与分享',
    'end': '结束正式关系',
    'resume': '申请重新确认恢复',
  }[action]!;
}
