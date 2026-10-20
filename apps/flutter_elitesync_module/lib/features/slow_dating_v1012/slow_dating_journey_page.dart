import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../relationships_v1011/peer_relationship_page.dart';
import 'formal_relationship_page.dart';
import 'journey_components.dart';

class SlowDatingJourneyPage extends ConsumerStatefulWidget {
  const SlowDatingJourneyPage({super.key});
  @override
  ConsumerState<SlowDatingJourneyPage> createState() => _JourneyState();
}

class _JourneyState extends SessionBoundPage<SlowDatingJourneyPage> {
  @override
  String get resource => '/journey';
  final _intent = TextEditingController();
  Object? _revision;

  void _clear() {
    _intent.clear();
    _revision = null;
  }

  @override
  void onIdentityChanged() => _clear();
  @override
  void onAuthorityChanged() => _clear();
  @override
  void dispose() {
    _intent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participation = objectMap(data?['participation']);
    final readiness = objectMap(data?['readiness']);
    final proposal = objectMap(data?['proposal']);
    final roundEnvelope = objectMap(data?['round']);
    final round = roundEnvelope['data'] is Map
        ? objectMap(roundEnvelope['data'])
        : roundEnvelope;
    if (data != null && _revision != participation['revision']) {
      _revision = participation['revision'];
      _intent.text = '${participation['intent'] ?? ''}';
    }
    final canWrite = !busy && participation['revision'] is int;
    final peer = proposal['peer_id'];
    final terminal = [
      'DECLINED',
      'WITHDRAWN',
      'EXPIRED',
      'MUTUALLY_ACCEPTED',
    ].contains(proposal['state']);
    final showcase = objectMap(proposal['showcase']);
    final explanation = objectMap(proposal['explanation']);
    return frame('慢约会旅程', [
      const Text('准备 → 主动报名 → 等待揭晓 → 独立选择。匹配不会自动建立连接、消息同意或正式恋爱关系。'),
      if (data != null) ...[
        IdentityGateCard(identity: objectMap(data!['identity'])),
        Text(
          '参与状态：${journeyStateLabel(participation['state'])} · 代际 ${participation['generation'] ?? '—'}',
        ),
        const SizedBox(height: 16),
        Text('报名准备：${readiness['eligible'] == true ? '符合当前参与资格' : '尚未符合参与资格'}'),
        Text(
          '运营审核（非实人）：${objectMap(readiness['operational_review'])['status'] == 'approved' ? '已通过' : '待审核或尚未通过'}',
        ),
        Text(
          '候选展示资料：${objectMap(readiness['showcase'])['publication_status'] == 'published' ? '已发布' : '尚未发布'}',
        ),
        const Text(
          '按服务器逐项提示完成必要问卷。Showcase仅作信息展示，报名资格以服务器结果为准。可选人格、玄学、私聊及内部记录不作为额外必填。',
        ),
        if ((readiness['reasons'] is! List ||
                (readiness['reasons'] as List).isEmpty) &&
            readiness['reason_code'] != null)
          Text('准备提示：${preparationReasonLabel(readiness['reason_code'])}'),
        if ((readiness['reasons'] is! List ||
                (readiness['reasons'] as List).isEmpty) &&
            readiness['missing_answer_count'] != null)
          Text('尚缺必要问卷答案：${readiness['missing_answer_count']}'),
        for (final reason
            in readiness['reasons'] is List
                ? readiness['reasons'] as List
                : const [])
          Text(
            '准备提示：${reason is Map ? reason['message'] ?? reason['code'] ?? '请刷新准备状态' : reason}',
          ),
        TextField(
          key: const Key('journey-intent'),
          controller: _intent,
          enabled: canWrite,
          maxLength: 1000,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '我的长期关系意图',
            hintText: '可以先保存草稿，再决定是否报名',
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final action in ['draft', 'opt_in', 'pause', 'exit'])
              OutlinedButton(
                key: ValueKey('participation-$action'),
                onPressed:
                    !canWrite ||
                        (action == 'opt_in' && readiness['eligible'] != true)
                    ? null
                    : () async {
                        if (action == 'exit' &&
                            !await confirm(
                              '退出本轮参与？',
                              '停止未来轮次参与；现有连接与消息同意独立管理。',
                            )) {
                          return;
                        }
                        await mutate('PUT', '/journey/participation', {
                          'action': action,
                          'revision': participation['revision'],
                          'intent': _intent.text,
                        });
                      },
                child: Text(
                  {
                    'draft': '保存草稿',
                    'opt_in':
                        participation['state'] == 'PAUSED' ||
                            participation['state'] == 'EXITED'
                        ? '明确重新报名'
                        : '主动报名',
                    'pause': '暂停报名',
                    'exit': '退出报名',
                  }[action]!,
                ),
              ),
          ],
        ),
        const Text('暂停停止未来轮次纳入；当前未决提案可单独撤回。恢复报名进入新代际，不复活旧提案。'),
        const Divider(),
        Text('当前轮次：${journeyStateLabel(round['state'])}'),
        if (round['reason_code'] != null || round['failure_code'] != null)
          Text('轮次说明：${journeyStateLabel(round['state'])}'),
        if (round['retry_eligible'] == true)
          const Text('服务器标记轮次可重试；由获准运营处理，刷新可查看进展。'),
        if (proposal.isEmpty) const Text('当前没有可回应的候选。请按本轮状态等待或稍后刷新。'),
        if (proposal.isNotEmpty) ...[
          Text(
            '候选：${showcase['display_name'] ?? showcase['public_id'] ?? '暂不可见'}',
          ),
          if (showcase['summary'] != null) Text('${showcase['summary']}'),
          Text('提案状态：${journeyStateLabel(proposal['state'])}'),
          Text(
            '我的回应：${decisionLabel(proposal['decision_me'])}；对方回应：${decisionLabel(proposal['decision_peer'])}',
          ),
          if (proposal['expires_at'] != null)
            Text('服务器有效期至：${proposal['expires_at']}；到期由服务器判断。'),
          const Text('原因类别：本人提供的问卷偏好与基础匹配输入'),
          const Text('来源：本轮实际匹配结果；不展示对方原始答案'),
          Text('不确定性：${explanation['uncertainty'] ?? '不能保证现实相处结果'}'),
          Text('非目标：${explanation['non_goals'] ?? '不判定爱情、身份或安全结论'}'),
          const Text('不会展示对方原问卷、精确生辰、私聊或内部记录；没有权威兼容分。'),
          if (!terminal &&
              proposal['revision'] is int &&
              proposal['id'] != null)
            Wrap(
              spacing: 8,
              children: [
                for (final action in ['accept', 'decline', 'withdraw'])
                  OutlinedButton(
                    key: ValueKey('proposal-$action'),
                    onPressed: busy
                        ? null
                        : () => mutate(
                            'POST',
                            '/journey/proposals/${proposal['id']}/decision',
                            {
                              'action': action,
                              'revision': proposal['revision'],
                              'idempotency_key': requestKey(),
                            },
                          ),
                    child: Text(
                      {
                        'accept': '独立接受候选',
                        'decline': '拒绝候选',
                        'withdraw': '撤回当前提案',
                      }[action]!,
                    ),
                  ),
              ],
            ),
          if (proposal['state'] == 'MUTUALLY_ACCEPTED' && peer is int)
            FilledButton(
              onPressed: busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PeerRelationshipPage(peerId: peer),
                      ),
                    ),
              child: const Text('分别申请连接（CN）与消息同意（MC）'),
            ),
        ],
        const Divider(),
        OutlinedButton(
          onPressed: busy
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FormalRelationshipPage(),
                  ),
                ),
          child: const Text('自愿申请 / 管理正式恋爱关系'),
        ),
      ],
    ]);
  }
}
