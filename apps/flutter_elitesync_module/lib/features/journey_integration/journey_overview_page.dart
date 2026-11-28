import 'package:flutter_elitesync_module/design_system/components/layout/ui_s3_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_route_names.dart';
import '../../shared/providers/session_provider.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';
import '../slow_dating_v1012/matching_history_page.dart';

/// A current projection of existing authorities. All decisions remain commands
/// to their original services; opening this page never submits a command.
class JourneyOverviewPage extends ConsumerStatefulWidget {
  const JourneyOverviewPage({
    super.key,
    this.detailed = false,
    this.homeContent,
  });
  final bool detailed;
  final Widget? homeContent;

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
    _router?.routerDelegate.removeListener(_routeChanged);
    _router = router;
    _router?.routerDelegate.addListener(_routeChanged);
    _routeChanged();
  }

  void _routeChanged() {
    final path = _router?.state.uri.path;
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
    _router?.routerDelegate.removeListener(_routeChanged);
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

  Widget _domain(String title, String value, {Key? key}) => ListTile(
    key: key,
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text('$title · $value'),
  );

  List<Widget> _home(Map<String, dynamic> domains) {
    final actions = rows(data?['next_actions']);
    final first = actions.isEmpty ? null : actions.first['code'];
    final action = switch (first) {
      'complete_lifestyle' => ('继续生活方式探索', '/lifestyle-discovery'),
      'review_preparation' => ('完善匹配资料', AppRouteNames.progressMatch),
      'view_journey' => ('查看匹配', AppRouteNames.progress),
      _ => null,
    };
    return [
      Text('当前状态', style: Theme.of(context).textTheme.headlineSmall),
      Text(switch (objectMap(domains['account'])['code']) {
        'AVAILABLE' => '欢迎回来',
        'UNAVAILABLE' => '当前账号受限，请查看账号状态',
        _ => '账号状态暂时无法确认',
      }),
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
        const Text('暂时无法确认下一步，请刷新'),
      const SizedBox(height: 8),
      Text('相约与交流', style: Theme.of(context).textTheme.titleMedium),
      _link('吃饭 / 学习搭子', '/buddy-v1013'),
      _link('好友可见社区', AppRouteNames.statusSquare),
      _link('平台活动 · 合成演练', '/platform-events', subtitle: '虚构开发演练，不招募、预订或付款'),
    ];
  }

  (Widget, Widget) _uiS3Home(Map<String, dynamic> domains) {
    final actions = rows(data?['next_actions']);
    final task = switch (actions.firstOrNull?['code']) {
      'complete_lifestyle' => ('继续生活方式探索', '/lifestyle-discovery'),
      'review_preparation' => ('完善匹配资料', AppRouteNames.progressMatch),
      'view_journey' => ('查看匹配进度', AppRouteNames.progress),
      _ => null,
    };
    return (
      DecoratedBox(
        decoration: BoxDecoration(
          color: UiS3Backdrop.bazi.surfaceOf(context),
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('下一步', style: Theme.of(context).textTheme.titleSmall),
              Text(
                preparationReasonLabel(objectMap(domains['readiness'])['code']),
              ),
              if (task != null)
                TextButton(
                  key: const Key('home-primary-action'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 48),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: busy
                      ? null
                      : () {
                          if (task.$2 == AppRouteNames.progress) {
                            context.go(task.$2);
                          } else {
                            _open(task.$2);
                          }
                        },
                  child: Text(task.$1),
                ),
            ],
          ),
        ),
      ),
      ExpansionTile(
        title: const Text('查看当前状态'),
        children: [
          _domain('账号', switch (objectMap(domains['account'])['code']) {
            'AVAILABLE' => '可用',
            'UNAVAILABLE' => '受限，请查看账号状态',
            _ => '状态暂未确认',
          }),
          _domain(
            '生活方式',
            _lifestyleLabel(objectMap(domains['lifestyle'])['code']),
          ),
          _domain(
            '每周参与',
            journeyStateLabel(objectMap(domains['participation'])['code']),
          ),
          _domain(
            '持续参与',
            _automationLabel(objectMap(domains['automation'])['code']),
          ),
          if (objectMap(
            objectMap(domains['automation'])['recent_task'],
          ).isNotEmpty)
            _domain(
              '最近一次处理',
              _taskLabel(
                objectMap(
                  objectMap(domains['automation'])['recent_task'],
                )['code'],
              ),
            ),
          _domain(
            '轮次',
            journeyStateLabel(
              objectMap(domains['round'])['state'] ??
                  objectMap(domains['round'])['code'],
            ),
          ),
          _domain('候选', _proposalLabel(objectMap(domains['proposal'])['code'])),
        ],
      ),
    );
  }

  Widget _homeLink(
    String title,
    String path,
    IconData icon, {
    String? subtitle,
  }) => Material(
    color: UiS3Backdrop.base.surfaceOf(context),
    child: ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: subtitle == null ? null : Text(subtitle),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      trailing: const Icon(Icons.arrow_forward),
      onTap: busy ? null : () => _open(path),
    ),
  );

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
    final gates = objectMap(pair['gates']);
    // The first authorized send creates the conversation. An empty inventory
    // must not hide the entry while the current pair allows both operations.
    final canOpenChat =
        pair['_unavailable'] != true &&
        gates['live_read_allowed'] == true &&
        (gates['live_send_allowed'] == true ||
            (conversations['_unavailable'] != true && conversation.isNotEmpty));
    final roundStatus = journeyStateLabel(
      objectMap(domains['round'])['state'] ??
          objectMap(domains['round'])['code'],
    );
    final proposalStatus = journey['_unavailable'] == true
        ? '匹配结果暂时无法加载，请刷新'
        : _proposalLabel(
            proposal['state'] ?? objectMap(domains['proposal'])['code'],
          );
    return [
      _link(
        '持续参与与自动化',
        '/user-state',
        subtitle: _automationLabel(objectMap(domains['automation'])['code']),
        key: const Key('match-automation-entry'),
      ),
      if (UiS3Design.enabled)
        _RelationshipPath(
          steps: [
            _domain(
              '资料准备',
              preparationReasonLabel(objectMap(domains['readiness'])['code']),
            ),
            _domain('当前轮次', roundStatus),
            _domain('双方决定', proposalStatus),
            _domain(
              '联系',
              _pairLabel(objectMap(pair['connection'])),
              key: const Key('domain-connection'),
            ),
            _domain(
              '聊天许可',
              _pairLabel(objectMap(pair['consent'])),
              key: const Key('domain-consent'),
            ),
          ],
        )
      else
        _domain('当前轮次', roundStatus),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('匹配结果', style: Theme.of(context).textTheme.titleMedium),
              if (!UiS3Design.enabled) Text(proposalStatus),
              if (proposal.isNotEmpty &&
                  proposal['state'] != 'MUTUALLY_ACCEPTED') ...[
                Text(
                  '我的回应 ${decisionLabel(proposal['decision_me'])} · 对方回应 ${decisionLabel(proposal['decision_peer'])}',
                ),
                if (proposal['expires_at'] != null)
                  Text('有效期至 ${proposal['expires_at']}'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final action in ['accept', 'decline', 'withdraw'])
                      if (proposal['revision'] is int &&
                          proposal['id'] is String &&
                          proposalActionAvailable(proposal, action))
                        OutlinedButton(
                          key: Key('overview-proposal-$action'),
                          onPressed: busy
                              ? null
                              : () => decideProposal(
                                  proposal['id'] as String,
                                  proposal['revision'] as int,
                                  action,
                                ),
                          child: Text(switch (action) {
                            'accept' => '接受候选',
                            'decline' => '拒绝候选',
                            _ => '撤回匹配结果',
                          }),
                        ),
                  ],
                ),
              ],
              TextButton(
                onPressed: busy
                    ? null
                    : () => _open(AppRouteNames.progressMatch),
                child: const Text(UiS3Design.enabled ? '匹配准备与候选' : '报名与候选详情'),
              ),
            ],
          ),
        ),
      ),
      if (!UiS3Design.enabled)
        _domain(
          '连接',
          _pairLabel(objectMap(pair['connection'])),
          key: const Key('domain-connection'),
        ),
      if (!UiS3Design.enabled)
        _domain(
          '消息许可',
          _pairLabel(objectMap(pair['consent'])),
          key: const Key('domain-consent'),
        ),
      if (canOpenChat && peer is int && peer > 0)
        FilledButton(
          onPressed: busy ? null : () => _open('/live-chat/$peer'),
          child: const Text('进入聊天'),
        ),
      _link(
        UiS3Design.enabled ? '联系与聊天许可' : '连接与消息许可',
        pair.isNotEmpty &&
                pair['_unavailable'] != true &&
                peer is int &&
                peer > 0
            ? '/live-connection?peerId=$peer'
            : AppRouteNames.progressConnection,
      ),
      _domain(
        '聊天',
        conversations['_unavailable'] == true
            ? '状态暂未确认'
            : '${rows(conversations['items']).length} 个会话',
        key: const Key('domain-conversation'),
      ),
      _domain(
        '正式关系',
        formal['_unavailable'] == true
            ? '正式关系暂时无法加载，请刷新'
            : rows(formal['relationships']).isEmpty
            ? '尚无正式关系记录'
            : rows(
                formal['relationships'],
              ).map((item) => journeyStateLabel(item['state'])).join('、'),
        key: const Key('domain-formal'),
      ),
      _link('正式恋爱关系', '/formal-relationship'),
      Card(
        child: ListTile(
          title: const Text('匹配记录'),
          trailing: const Icon(Icons.chevron_right),
          onTap: busy
              ? null
              : () async {
                  invalidatePendingProjection();
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MatchingHistoryPage(),
                    ),
                  );
                  if (mounted && _foreground) await refresh();
                },
        ),
      ),
      Text('我的准备与参与', style: Theme.of(context).textTheme.titleMedium),
      if (!UiS3Design.enabled)
        _domain(
          '资料准备',
          preparationReasonLabel(objectMap(domains['readiness'])['code']),
        ),
      _link(
        '生活方式与偏好',
        '/lifestyle-discovery',
        subtitle: _lifestyleLabel(objectMap(domains['lifestyle'])['code']),
      ),
      _link('匹配资料与偏好', AppRouteNames.meMatchingInputs),
      _domain(
        '每周参与',
        journeyStateLabel(objectMap(domains['participation'])['code']),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final domains = objectMap(data?['domains']);
    final current = _foreground && _routeActive && data != null;
    final redesignedHome = UiS3Design.enabled && !widget.detailed;
    final overview = redesignedHome && current ? _uiS3Home(domains) : null;
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        UiS3Design.enabled ? 32 : 112,
      ),
      children: [
        if (redesignedHome) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '慢慢认识彼此',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const UiS3BrandArt(aspectRatio: 2.2),
          const SizedBox(height: 12),
        ],
        if (!redesignedHome &&
            _routeActive &&
            _foreground &&
            widget.homeContent != null)
          widget.homeContent!,
        if (busy) const LinearProgressIndicator(),
        if (error != null)
          Semantics(
            liveRegion: true,
            child: const Text('暂时无法加载，请刷新重试', key: Key('server-error')),
          ),
        if (overview != null)
          overview.$1
        else if (current)
          for (final child
              in widget.detailed ? _progress(domains) : _home(domains))
            Padding(padding: const EdgeInsets.only(bottom: 10), child: child)
        else if (!busy && error == null)
          const Text('状态暂未确认，请刷新后查看'),
        if (redesignedHome) ...[
          const SizedBox(height: 12),
          _homeLink(
            '我的三盘',
            AppRouteNames.myCharts,
            Icons.grid_view,
            subtitle: '八字、紫微与西洋占星',
          ),
          const Divider(height: 1),
          _homeLink(
            '好友动态',
            AppRouteNames.statusSquare,
            Icons.auto_stories_outlined,
          ),
          ?overview?.$2,
          _link('吃饭 / 学习搭子', '/buddy-v1013'),
          _link('平台活动', '/platform-events', subtitle: '合成演练'),
          if (_routeActive && _foreground && widget.homeContent != null)
            widget.homeContent!,
        ],
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.detailed
              ? '匹配'
              : redesignedHome
              ? 'EliteSync'
              : '首页',
          style: redesignedHome
              ? const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.5)
              : null,
        ),
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
      body: UiS3Design.enabled
          ? UiS3Canvas(
              kind: widget.detailed
                  ? UiS3Backdrop.relationship
                  : UiS3Backdrop.base,
              child: body,
            )
          : body,
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
  'ACTIVE' => '已开启',
  'PAUSED' => '已暂停',
  'REVOKED' => '已撤销',
  'EXPIRED' => '授权已到期或说明已更新',
  'OFF' => '尚未授权',
  _ => '状态暂未确认',
};

String _proposalLabel(Object? code) => switch (code) {
  'NONE' => '当前没有提案',
  null => '状态暂未确认',
  'RECONCILIATION_REQUIRED' => '结果正在更新，请查看详情',
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

class _RelationshipPath extends StatelessWidget {
  const _RelationshipPath({required this.steps});

  final List<Widget> steps;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: UiS3Backdrop.relationship.surfaceOf(context),
        border: Border(left: BorderSide(color: colors.primary, width: 2)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ExcludeSemantics(
                    child: Transform.rotate(
                      angle: 0.7853981634,
                      child: SizedBox.square(
                        dimension: 8,
                        child: ColoredBox(color: colors.primary),
                      ),
                    ),
                  ),
                ),
                Expanded(child: steps[index]),
              ],
            ),
        ],
      ),
    );
  }
}
