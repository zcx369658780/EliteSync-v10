import '../user_automation/user_state_page.dart';
import '../lifestyle_discovery/lifestyle_page.dart';
import '../relationships_v1011/relationship_api.dart';
import 'matching_input_page.dart';
import 'matching_history_page.dart';
import '../questionnaire/presentation/pages/questionnaire_page.dart';
import '../buddy_v1013/buddy_page.dart';
import '../status/presentation/pages/status_square_page.dart';
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

class _JourneyState extends SessionBoundPage<SlowDatingJourneyPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    }
  }

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
    WidgetsBinding.instance.removeObserver(this);
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
    return frame('每周慢约', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const UserStatePage()),
              );
              if (mounted) await refresh();
            },
            child: const Text('持续参与与自动化'),
          ),
          OutlinedButton(
            key: const Key('journey-matching-inputs'),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MatchingInputPage(),
                ),
              );
              if (mounted) await refresh();
            },
            child: const Text('我的匹配输入'),
          ),
          OutlinedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QuestionnairePage(),
                ),
              );
              if (mounted) await refresh();
            },
            child: const Text('填写或修改必要问卷'),
          ),
          OutlinedButton(
            key: const Key('journey-matching-history'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MatchingHistoryPage(),
              ),
            ),
            child: const Text('匹配记录'),
          ),
          if (!const bool.fromEnvironment('ELITESYNC_V1017_LOCAL_BUILD')) ...[
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BuddyPage()),
              ),
              child: const Text('独立吃饭 / 学习搭子'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StatusSquarePage(),
                ),
              ),
              child: const Text('好友可见社区'),
            ),
          ],
        ],
      ),
      if (data != null) ...[
        if (objectMap(data!['lifestyle_discovery'])['completed'] == false)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('参加每周慢约会前，请完成生活方式探索。社区和搭子可继续使用。'),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LifestyleDiscoveryPage(),
                        ),
                      );
                      if (mounted) await refresh();
                    },
                    child: const Text('继续生活方式探索'),
                  ),
                ],
              ),
            ),
          ),
        Text('参与状态：${journeyStateLabel(participation['state'])}'),
        const SizedBox(height: 16),
        Text('报名准备：${readiness['eligible'] == true ? '符合当前参与资格' : '尚未符合参与资格'}'),
        Text(
          '运营审核（非实人）：${objectMap(readiness['operational_review'])['status'] == 'approved' ? '已通过' : '待审核或尚未通过'}',
        ),
        Text(
          '候选展示资料：${objectMap(readiness['showcase'])['publication_status'] == 'published' ? '已发布' : '尚未发布'}',
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
                              '停止未来轮次参与，并撤回当前未决提案；现有连接与消息同意独立管理。',
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
        const Divider(),
        Text(
          '当前轮次：${round['state'] == 'scheduled' && round['next_action_code'] == 'wait_for_reveal' ? '结果已生成，等待揭晓' : journeyStateLabel(round['state'])}',
        ),
        if (round['reason_code'] != null || round['failure_code'] != null)
          Text('轮次说明：${journeyStateLabel(round['state'])}'),
        if (round['retry_eligible'] == true) const Text('本轮暂未完成，请稍后刷新'),
        if (round['scheduled_at'] != null)
          Text('本轮时间 ${round['scheduled_at']}'),
        if (round['next_transition_at'] != null)
          Text('下次更新 ${round['next_transition_at']}'),
        if (proposal.isEmpty) const Text('当前没有待回应的候选'),
        if (proposal.isNotEmpty) ...[
          Text(
            '候选：${showcase['display_name'] ?? showcase['public_id'] ?? '暂不可见'}',
          ),
          if (showcase['summary'] != null) Text('${showcase['summary']}'),
          Text('提案状态：${journeyStateLabel(proposal['state'])}'),
          if (proposal['availability_reason'] != null)
            const Text('当前参与已暂停、退出或换代际；候选不再提供新的选择或联系资格。未决提案可独立撤回。'),
          if (proposal['withdraw_available'] == true &&
              ['PAUSED', 'EXITED'].contains(participation['state']))
            const Text('如需重新报名，请先撤回当前候选'),
          Text(
            '我的回应：${decisionLabel(proposal['decision_me'])}；对方回应：${decisionLabel(proposal['decision_peer'])}',
          ),
          if (proposal['expires_at'] != null)
            Text('有效期至：${proposal['expires_at']}'),
          const Text('依据你确认的资料与问卷偏好生成'),
          if (!terminal &&
              proposal['revision'] is int &&
              proposal['id'] != null)
            Wrap(
              spacing: 8,
              children: [
                for (final action in ['accept', 'decline', 'withdraw'])
                  if ((action == 'withdraw' &&
                          proposal['withdraw_available'] == true) ||
                      (action != 'withdraw' &&
                          proposal['decision_available'] == true))
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
                          'accept': '接受候选',
                          'decline': '拒绝候选',
                          'withdraw': '撤回当前提案',
                        }[action]!,
                      ),
                    ),
              ],
            ),
          if (proposal['state'] == 'MUTUALLY_ACCEPTED' &&
              proposal['connection_eligible'] == true &&
              peer is int)
            FilledButton(
              onPressed: busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PeerRelationshipPage(peerId: peer),
                      ),
                    ),
              child: const Text('连接与消息许可'),
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
          child: const Text('管理正式恋爱关系'),
        ),
      ],
    ]);
  }
}
