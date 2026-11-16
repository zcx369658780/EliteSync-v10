import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';
import '../slow_dating_v1012/slow_dating_journey_page.dart';
import '../lifestyle_discovery/lifestyle_page.dart';

class UserStatePage extends ConsumerStatefulWidget {
  const UserStatePage({super.key});
  @override
  ConsumerState<UserStatePage> createState() => _UserStatePageState();
}

class _UserStatePageState extends SessionBoundPage<UserStatePage>
    with WidgetsBindingObserver {
  @override
  String get resource => '/user-state';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> _authorize(
    String action,
    Map<String, dynamic> authorization,
  ) async {
    if (action == 'grant' &&
        !await confirm(
          '授权持续参与？',
          '你授权系统在后续每周已有开放轮次中检查资格并协调报名。'
              '授权持续至你暂停、撤销或授权说明版本更新。'
              '暂停或撤销只暂停已委托给本授权的报名，独立手动报名保持原状态。当前提案按原规则保留。'
              '匹配选择、连接、消息同意和正式关系仍由你逐项决定。',
        )) {
      return;
    }
    await mutate('PUT', '/automations/weekly_slow_dating_participation', {
      'action': action,
      'expected_revision': authorization['source_revision'],
      'policy_version': authorization['policy_version'],
      'consent_version': authorization['consent_version'],
      'request_key': const Uuid().v4(),
    });
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) await refresh();
  }

  @override
  Widget build(BuildContext context) {
    final domains = objectMap(data?['domains']);
    final lifestyle = objectMap(domains['lifestyle']);
    final readiness = objectMap(domains['readiness']);
    final participation = objectMap(domains['participation']);
    final round = objectMap(domains['round']);
    final proposal = objectMap(domains['proposal']);
    final authorization = objectMap(domains['automation']);
    final task = objectMap(authorization['recent_task']);
    final ready =
        readiness['eligible'] == true && lifestyle['code'] == 'completed';
    final code = authorization['code'];
    const b3 = bool.fromEnvironment('ELITESYNC_V1017_LOCAL_BUILD');
    return frame(b3 ? '持续参与与自动化' : '状态与自动化', [
      if (data != null) ...[
        if (!b3) ...[
          Text('当前状态', style: Theme.of(context).textTheme.titleLarge),
          Text(
            objectMap(domains['account'])['code'] == 'AVAILABLE'
                ? '账号可用'
                : '请查看账号状态',
          ),
          Text(
            '生活方式探索 ${lifestyle['answered_count'] ?? 0} / ${lifestyle['scene_count'] ?? 5}',
          ),
          if (lifestyle['code'] != 'completed')
            OutlinedButton(
              onPressed: () => _open(const LifestyleDiscoveryPage()),
              child: const Text('继续生活方式探索'),
            ),
          Text(preparationReasonLabel(readiness['code'])),
          Text('慢约参与 ${journeyStateLabel(participation['code'])}'),
          Text('当前轮次 ${journeyStateLabel(round['code'])}'),
          Text(
            proposal['code'] == 'NONE'
                ? '当前没有提案'
                : proposal['code'] == 'RECONCILIATION_REQUIRED'
                ? '提案已到期，进入旅程查看业务更新'
                : '本人提案 ${journeyStateLabel(proposal['code'])}',
          ),
          OutlinedButton(
            onPressed: () => _open(const SlowDatingJourneyPage()),
            child: const Text('查看准备状态'),
          ),
          Text(
            '资料分享授权 ${objectMap(domains['privacy'])['shared_field_count'] ?? 0} 项',
          ),
          Text(
            objectMap(domains['notifications'])['silent'] == true
                ? '站内通知已设为静默'
                : '站内通知按本人分类偏好投递',
          ),
          const SizedBox(height: 12),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '每周慢约会持续参与',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(_authorizationLabel(code)),
                const SizedBox(height: 12),
                const Text(
                  '开启后，系统在已有开放轮次中检查准备状态并协调报名。'
                  '你仍独立决定匹配选择、连接、消息同意和正式关系。',
                ),
                const SizedBox(height: 12),
                Text(
                  authorization['expires_at'] == null
                      ? '有效期持续至你暂停、撤销或授权说明版本更新。'
                      : '有效期至 ${authorization['expires_at']}',
                ),
                const Text('暂停或撤销只暂停已委托给本授权的报名，独立手动报名保持原状态。当前提案按原规则保留。'),
                const SizedBox(height: 12),
                if (task.isNotEmpty) ...[
                  Text('最近任务 ${_taskLabel(task['code'])}'),
                  Text(_resultLabel(task['result_code'] ?? task['error_code'])),
                ],
                if (authorization['next_planned_at'] != null)
                  Text('下次计划 ${authorization['next_planned_at']}'),
                if (authorization['last_checked_at'] != null)
                  Text('最近检查 ${authorization['last_checked_at']}'),
                const SizedBox(height: 12),
                if (['OFF', 'REVOKED', 'EXPIRED'].contains(code)) ...[
                  if (!ready) const Text('完成生活方式探索与现有匹配准备后可开启。'),
                  FilledButton(
                    key: const Key('automation-grant'),
                    onPressed: !busy && ready
                        ? () => _authorize('grant', authorization)
                        : null,
                    child: const Text('授权持续参与'),
                  ),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (code == 'ACTIVE')
                      OutlinedButton(
                        key: const Key('automation-pause'),
                        onPressed: busy
                            ? null
                            : () => _authorize('pause', authorization),
                        child: const Text('暂停'),
                      ),
                    if (code == 'PAUSED')
                      OutlinedButton(
                        key: const Key('automation-resume'),
                        onPressed: !busy && ready
                            ? () => _authorize('resume', authorization)
                            : null,
                        child: const Text('恢复'),
                      ),
                    if (['ACTIVE', 'PAUSED'].contains(code))
                      TextButton(
                        key: const Key('automation-revoke'),
                        onPressed: busy
                            ? null
                            : () => _authorize('revoke', authorization),
                        child: const Text('撤销授权'),
                      ),
                  ],
                ),
                Text(
                  '授权说明 ${authorization['consent_version'] ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (b3) ...[
          Text(preparationReasonLabel(readiness['code'])),
          OutlinedButton(
            onPressed: () => _open(const SlowDatingJourneyPage()),
            child: const Text('查看准备状态'),
          ),
        ],
      ],
    ]);
  }
}

String _authorizationLabel(Object? code) => switch (code) {
  'ACTIVE' => '持续参与已授权',
  'PAUSED' => '已暂停',
  'REVOKED' => '已撤销',
  'EXPIRED' => '授权已到期或说明版本已更新',
  _ => '尚未授权',
};

String _taskLabel(Object? code) => switch (code) {
  'QUEUED' => '等待执行',
  'RUNNING' => '正在处理',
  'SUCCEEDED' => '已完成',
  'SKIPPED' => '已跳过',
  'FAILED' => '处理失败',
  'UNKNOWN' => '正在核对结果',
  'CANCELLED' => '已取消',
  'EXPIRED' => '已到期',
  _ => '等待安排',
};

String _resultLabel(Object? code) => switch (code) {
  'NO_OPEN_ROUND' => '等待下一开放轮次',
  'ROUND_NOT_OPEN' => '当前轮次报名阶段已结束',
  'EXISTING_PROPOSAL' => '已有提案，请先按原规则处理',
  'LIFESTYLE_INCOMPLETE' => '生活方式探索尚未完成',
  'PARTICIPATION_COORDINATED' => '本轮报名已协调',
  'RECONCILED_EFFECT' => '已核对先前处理结果',
  'RECONCILED_EFFECT_SOURCE_CHANGED' => '已核对先前结果，参与状态随后已有更新',
  'AUTHORIZATION_CHANGED' => '授权已变化，任务已停止',
  'RETRY_EXHAUSTED' => '本轮尝试已用完，请查看当前状态',
  'EXECUTION_UNCERTAIN' => '处理结果待核对',
  'ACCOUNT_UNAVAILABLE' => '当前账号不可参与',
  null => '等待系统检查已有轮次与资格',
  _ => preparationReasonLabel(code),
};
