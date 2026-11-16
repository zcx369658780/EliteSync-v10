import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_route_names.dart';
import '../../shared/providers/session_provider.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';

/// A current projection of existing authorities. All decisions remain commands
/// to their original services; opening this page never submits a command.
class JourneyOverviewPage extends ConsumerStatefulWidget {
  const JourneyOverviewPage({super.key, this.detailed = false});
  final bool detailed;

  @override
  ConsumerState<JourneyOverviewPage> createState() => _JourneyOverviewState();
}

class _JourneyOverviewState extends SessionBoundPage<JourneyOverviewPage>
    with WidgetsBindingObserver {
  GoRouter? _router;
  bool _foreground = true;
  bool _routeActive = true;

  @override
  String get resource => '/user-state';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.maybeOf(context);
    if (router == _router) return;
    _router?.routeInformationProvider.removeListener(_routeChanged);
    _router = router;
    _router?.routeInformationProvider.addListener(_routeChanged);
    _routeChanged();
  }

  void _routeChanged() {
    final path = _router?.routeInformationProvider.value.uri.path;
    final active =
        path == null || path == (widget.detailed ? '/progress' : '/home');
    if (_routeActive == active) return;
    _routeActive = active;
    invalidatePendingProjection();
    if (active && _foreground) refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    invalidatePendingProjection();
    if (_foreground && _routeActive) refresh();
  }

  @override
  void dispose() {
    _router?.routeInformationProvider.removeListener(_routeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> refresh() async {
    if (!_foreground || !_routeActive) return;
    final session = ref.read(sessionProvider).asData?.value;
    await run(() async {
      Future<Map<String, dynamic>> read(String path) async {
        if (!mounted ||
            !identical(session, ref.read(sessionProvider).asData?.value)) {
          throw StateError('账号已变化，请重新读取');
        }
        final result = await ref
            .read(relationshipApiProvider)
            .call('GET', path);
        if (!mounted ||
            !identical(session, ref.read(sessionProvider).asData?.value)) {
          throw StateError('账号已变化，请重新读取');
        }
        return result;
      }

      Future<Map<String, dynamic>> optional(String path) async {
        try {
          return await read(path);
        } catch (_) {
          return {'_unavailable': true};
        }
      }

      Map<String, dynamic> validate(Map<String, dynamic> state) {
        if (state['contract_version'] != 'user_state_v1' ||
            state['subject_user_id'] != session?.user?.id ||
            state['domains'] is! Map ||
            state['next_actions'] is! List) {
          throw StateError('本人状态未通过核验，请刷新');
        }
        return state;
      }

      var state = validate(await read(resource));
      if (!widget.detailed) return state;
      // These existing endpoints retain their ordinary deadline reconciliation.
      final journey = await optional('/journey');
      final proposal = objectMap(journey['proposal']);
      final peer = proposal['peer_id'];
      final connection = peer is int && peer > 0
          ? await optional('/connections/$peer')
          : <String, dynamic>{};
      final other = await Future.wait([
        optional('/conversations'),
        optional('/formal-relationships'),
      ]);
      state = validate(await read(resource));
      return {
        ...state,
        '_journey': journey,
        '_connection': connection,
        '_conversations': other[0],
        '_formal': other[1],
      };
    }, replace: true);
  }

  Future<void> _open(String path) async {
    invalidatePendingProjection();
    await context.push(path);
    if (mounted && _foreground) await refresh();
  }

  Widget _link(String title, String path, {String? subtitle, Key? key}) => Card(
    child: ListTile(
      key: key,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: busy ? null : () => _open(path),
    ),
  );

  Widget _domain(String title, String value, String source, {Key? key}) =>
      ListTile(
        key: key,
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text('$title · $value'),
        subtitle: Text(source),
      );

  List<Widget> _home(Map<String, dynamic> domains) {
    final actions = rows(data?['next_actions']);
    final first = actions.isEmpty ? null : actions.first['code'];
    final action = switch (first) {
      'complete_lifestyle' => ('继续生活方式探索', '/lifestyle-discovery'),
      'review_preparation' => ('查看必要准备', AppRouteNames.progressMatch),
      'view_journey' => ('查看我的进展', AppRouteNames.progress),
      _ => null,
    };
    return [
      Text('当前状态', style: Theme.of(context).textTheme.headlineSmall),
      Text(
        objectMap(domains['account'])['code'] == 'AVAILABLE'
            ? '账号可用'
            : '账号状态暂不可用',
      ),
      Text(preparationReasonLabel(objectMap(domains['readiness'])['code'])),
      Text('生活方式 ${_lifestyleLabel(objectMap(domains['lifestyle'])['code'])}'),
      Text(
        '慢约参与 ${journeyStateLabel(objectMap(domains['participation'])['code'])}',
      ),
      Text(
        '持续参与 ${_automationLabel(objectMap(domains['automation'])['code'])}',
      ),
      if (objectMap(objectMap(domains['automation'])['recent_task']).isNotEmpty)
        Text(
          '后台任务 ${_taskLabel(objectMap(objectMap(domains['automation'])['recent_task'])['code'])}',
        ),
      Text(
        '轮次 ${journeyStateLabel(objectMap(domains['round'])['state'] ?? objectMap(domains['round'])['code'])}',
      ),
      Text('提案 ${_proposalLabel(objectMap(domains['proposal'])['code'])}'),
      if (action != null)
        FilledButton(
          key: const Key('home-primary-action'),
          onPressed: busy
              ? null
              : () async {
                  if (action.$2 == AppRouteNames.progress) {
                    context.go(action.$2);
                  } else {
                    await _open(action.$2);
                  }
                },
          child: Text(action.$1),
        )
      else
        const Text('下一步暂未识别，请刷新状态'),
      const SizedBox(height: 8),
      Text('相约与交流', style: Theme.of(context).textTheme.titleMedium),
      _link('独立吃饭 / 学习搭子', '/buddy-v1013', subtitle: '独立参与，联系前仍需双方同意'),
      _link(
        '好友可见社区',
        AppRouteNames.statusSquare,
        subtitle: '有限好友动态，按本人选择的受众发布',
      ),
      _link('平台活动 · 合成演练', '/platform-events', subtitle: '虚构开发演练，不招募、预订或付款'),
    ];
  }

  List<Widget> _progress(Map<String, dynamic> domains) {
    final journey = objectMap(data?['_journey']);
    final proposal = objectMap(journey['proposal']);
    final pair = objectMap(data?['_connection']);
    final conversations = objectMap(data?['_conversations']);
    final formal = objectMap(data?['_formal']);
    final peer = proposal['peer_id'];
    final conversation = rows(
      conversations['items'],
    ).where((item) => item['peer_user_id'] == peer);
    final canRead =
        pair['_unavailable'] != true &&
        objectMap(pair['gates'])['live_read_allowed'] == true &&
        conversations['_unavailable'] != true &&
        conversation.isNotEmpty;
    return [
      Text('我的关系旅程', style: Theme.of(context).textTheme.headlineSmall),
      const Text('匹配、连接、消息同意、会话和正式关系分别确认。'),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('当前提案', style: Theme.of(context).textTheme.titleMedium),
              Text(
                journey['_unavailable'] == true
                    ? '提案读取未完成，请刷新'
                    : _proposalLabel(
                        proposal['state'] ??
                            objectMap(domains['proposal'])['code'],
                      ),
              ),
              if (proposal.isNotEmpty &&
                  proposal['state'] != 'MUTUALLY_ACCEPTED') ...[
                Text(
                  '我的回应 ${decisionLabel(proposal['decision_me'])} · 对方回应 ${decisionLabel(proposal['decision_peer'])}',
                ),
                if (proposal['expires_at'] != null)
                  Text('服务器有效期至 ${proposal['expires_at']}'),
                const Text('来源 /journey。选择不会自动分享、连接、同意消息或建立正式关系。'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final action in ['accept', 'decline', 'withdraw'])
                      if (proposal['revision'] is int &&
                          proposal['id'] is String &&
                          (action == 'withdraw'
                              ? proposal['withdraw_available'] == true
                              : proposal['decision_available'] == true))
                        OutlinedButton(
                          key: Key('overview-proposal-$action'),
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
                          child: Text(switch (action) {
                            'accept' => '独立接受候选',
                            'decline' => '拒绝候选',
                            _ => '撤回当前提案',
                          }),
                        ),
                  ],
                ),
              ],
              TextButton(
                onPressed: busy
                    ? null
                    : () => _open(AppRouteNames.progressMatch),
                child: const Text('提案详情与慢约操作'),
              ),
            ],
          ),
        ),
      ),
      _domain(
        'Connection',
        _pairLabel(objectMap(pair['connection'])),
        '来源 /connections/{peer}',
        key: const Key('domain-connection'),
      ),
      _domain(
        'Messaging Consent',
        _pairLabel(objectMap(pair['consent'])),
        '来源 /connections/{peer}，独立于连接',
        key: const Key('domain-consent'),
      ),
      if (canRead && peer is int)
        FilledButton(
          onPressed: busy ? null : () => _open('/live-chat/$peer'),
          child: const Text('进入有权会话'),
        ),
      _link(
        '连接与消息许可',
        peer is int && peer > 0
            ? '/live-connection?peerId=$peer'
            : AppRouteNames.progressConnection,
        subtitle: '按服务端当前权限分别申请、回应或撤销',
      ),
      _domain(
        'Conversation',
        conversations['_unavailable'] == true
            ? '状态暂未确认'
            : '${rows(conversations['items']).length} 个当前获准会话',
        '来源 /conversations，进入仍需重新核验',
        key: const Key('domain-conversation'),
      ),
      _domain(
        'Relationship',
        formal['_unavailable'] == true
            ? '正式关系读取未完成，请刷新'
            : rows(formal['relationships']).isEmpty
            ? '尚无正式关系记录'
            : rows(
                formal['relationships'],
              ).map((item) => journeyStateLabel(item['state'])).join('、'),
        '来源 /formal-relationships，各关系独立',
        key: const Key('domain-formal'),
      ),
      _link('正式恋爱关系', '/formal-relationship', subtitle: '独立自愿申请与逐次确认'),
      Text('我的准备与参与', style: Theme.of(context).textTheme.titleMedium),
      _domain(
        '资料准备',
        preparationReasonLabel(objectMap(domains['readiness'])['code']),
        '来源 B2 /user-state → ProfileReadinessService',
      ),
      _link(
        '生活方式与偏好',
        '/lifestyle-discovery',
        subtitle: _lifestyleLabel(objectMap(domains['lifestyle'])['code']),
      ),
      _link(
        '我的匹配输入',
        AppRouteNames.meMatchingInputs,
        subtitle: '查看已有输入，修改后明确确认',
      ),
      _domain(
        '每周参与',
        journeyStateLabel(objectMap(domains['participation'])['code']),
        '来源 B2 /user-state → SlowDatingService',
      ),
      _domain(
        '当前轮次',
        journeyStateLabel(
          objectMap(domains['round'])['state'] ??
              objectMap(domains['round'])['code'],
        ),
        '来源 B2 /user-state → MatchRoundProjectionService',
      ),
      _link(
        '持续参与与自动化',
        '/user-state',
        subtitle: _automationLabel(objectMap(domains['automation'])['code']),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final domains = objectMap(data?['domains']);
    final current = _foreground && _routeActive && data != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.detailed ? '进展' : '首页'),
        actions: [
          IconButton(
            tooltip: '持续参与与自动化',
            onPressed: busy ? null : () => _open('/user-state'),
            icon: const Icon(Icons.manage_accounts_outlined),
          ),
          IconButton(
            tooltip: '刷新状态',
            onPressed: busy ? null : refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
        children: [
          if (busy) const LinearProgressIndicator(),
          if (error != null)
            Text('状态读取未完成，请刷新。$error', key: const Key('server-error')),
          if (current) ...[
            for (final child
                in widget.detailed ? _progress(domains) : _home(domains))
              Padding(padding: const EdgeInsets.only(bottom: 10), child: child),
            Text(
              '来源 B2 /user-state · ${data?['generated_at'] ?? '读取时间未知'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else if (!busy && error == null)
            const Text('状态暂未确认，请刷新后查看'),
        ],
      ),
    );
  }

  String _pairLabel(Map<String, dynamic> value) {
    final code = value['state'];
    if (code == 'CN_PENDING' || code == 'MC_PENDING') {
      final requester = value['requester_id'];
      if (requester is! int) return '等待回应，请查看许可';
      return requester == ref.read(sessionProvider).asData?.value.user?.id
          ? '等待对方决定'
          : '需要本人回应';
    }
    return _pairStateLabel(code);
  }
}

String _lifestyleLabel(Object? code) => switch (code) {
  'completed' => '已保存，可随时修改',
  'in_progress' => '已保存进度，可继续',
  'skipped' => '已跳过，可随时继续',
  'not_started' => '尚未开始',
  _ => '状态暂未确认',
};

String _automationLabel(Object? code) => switch (code) {
  'ACTIVE' => '已授权，系统按现有轮次检查',
  'PAUSED' => '已暂停',
  'REVOKED' => '已撤销',
  'EXPIRED' => '授权已到期或说明已更新',
  'OFF' => '尚未授权',
  _ => '状态暂未确认',
};

String _proposalLabel(Object? code) => switch (code) {
  'NONE' => '当前没有提案',
  null => '状态暂未确认',
  'RECONCILIATION_REQUIRED' => '提案期限待服务端核对，请进入详情',
  _ => journeyStateLabel(code),
};

String _pairStateLabel(Object? code) => switch (code) {
  'CN_ACTIVE' => '已连接',
  'MC_ACTIVE' => '已同意',
  'CN_NONE' || 'MC_NONE' => '尚未建立',
  'CN_CLOSED' => '已关闭',
  'CN_DECLINED' || 'MC_DECLINED' => '已拒绝',
  'CN_WITHDRAWN' || 'MC_WITHDRAWN' => '已撤回',
  'CN_EXPIRED' => '已到期',
  'MC_REVOKED' => '已撤销',
  _ => '状态暂未确认',
};

String _taskLabel(Object? code) => switch (code) {
  'QUEUED' => '等待执行',
  'RUNNING' => '系统正在处理',
  'UNKNOWN' => '结果待核对，请查看自动化',
  'SUCCEEDED' => '已完成本次处理',
  'FAILED' => '处理失败，请查看结果',
  'SKIPPED' => '本次已跳过，请查看原因',
  'CANCELLED' => '已取消',
  'EXPIRED' => '已到期',
  _ => '状态暂未确认',
};
