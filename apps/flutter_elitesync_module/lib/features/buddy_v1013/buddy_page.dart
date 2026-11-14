import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/contact_picker_page.dart';
import 'buddy_discovery_page.dart';
import 'buddy_display.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';

/// A controlled activity list, never a directory of strangers or mock candidates.
class BuddyPage extends ConsumerStatefulWidget {
  const BuddyPage({super.key});

  @override
  ConsumerState<BuddyPage> createState() => _BuddyPageState();
}

class _BuddyPageState extends SessionBoundPage<BuddyPage>
    with WidgetsBindingObserver {
  @override
  String get resource => '/buddy';

  final _subject = TextEditingController();
  final _city = TextEditingController();
  final _redeem = TextEditingController();
  final _publicLabel = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(hours: 1));
  DateTime _end = DateTime.now().add(const Duration(hours: 2));
  String? _pendingMethod;
  String? _pendingPath;
  Map<String, dynamic>? _pendingBody;
  bool _pendingExposesToken = false;
  bool get _blocked => busy || _pendingBody != null;
  String _type = 'MEAL';
  String _place = 'ONLINE';
  String _budget = 'UNSPECIFIED';
  String? _issuedToken;
  String? _tokenExpiry;
  String? _issuedActivityId;
  int _localGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
      return;
    }
    _localGeneration++;
    _issuedToken = null;
    _tokenExpiry = null;
    _issuedActivityId = null;
    invalidatePendingProjection();
    Navigator.of(context).popUntil((route) => route is! PopupRoute);
  }

  void _clearSensitive() {
    _localGeneration++;
    for (final c in [_subject, _city, _redeem, _publicLabel]) {
      c.clear();
    }
    _issuedToken = null;
    _tokenExpiry = null;
    _issuedActivityId = null;
    _start = DateTime.now().add(const Duration(hours: 1));
    _end = DateTime.now().add(const Duration(hours: 2));
    _pendingMethod = null;
    _pendingPath = null;
    _pendingBody = null;
    _pendingExposesToken = false;
    _type = 'MEAL';
    _place = 'ONLINE';
    _budget = 'UNSPECIFIED';
  }

  @override
  void onIdentityChanged() => _clearSensitive();
  @override
  void onAuthorityChanged() => _clearSensitive();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in [_subject, _city, _redeem, _publicLabel]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _actions(Map<String, dynamic> activity) =>
      activity['allowed_actions'] is List
      ? (activity['allowed_actions'] as List).whereType<String>().toList()
      : const [];

  Future<void> _send(
    String method,
    String path,
    Map<String, dynamic> body, {
    bool exposesToken = false,
  }) async {
    if (busy || _pendingBody != null) return;
    _pendingMethod = method;
    _pendingPath = path;
    _pendingBody = Map<String, dynamic>.unmodifiable(body);
    _pendingExposesToken = exposesToken;
    await _retryPending();
  }

  @override
  Future<void> refresh() async {
    final generation = _localGeneration;
    final result = await run(
      () => ref.read(relationshipApiProvider).call('GET', resource),
    );
    if (!mounted || generation != _localGeneration) return;
    setState(() => data = result);
  }

  Future<void> _retryPending() async {
    if (busy || _pendingBody == null) return;
    final generation = _localGeneration;
    final exposesToken = _pendingExposesToken;
    final result = await run(
      () => ref
          .read(relationshipApiProvider)
          .call(_pendingMethod!, _pendingPath!, _pendingBody!),
    );
    if (!mounted || generation != _localGeneration) return;
    if (result == null) {
      setState(() {
        data = {'preferences': <String, dynamic>{}, 'activities': <Object>[]};
        _issuedToken = null;
        _tokenExpiry = null;
        _issuedActivityId = null;
      });
      return;
    }
    _pendingMethod = null;
    _pendingPath = null;
    _pendingBody = null;
    _pendingExposesToken = false;
    await refresh();
    if (!mounted || generation != _localGeneration || data == null) return;
    setState(() {
      if (exposesToken && result['token'] is String) {
        _issuedToken = result['token'] as String;
        _tokenExpiry = result['expires_at']?.toString();
        final activityId = objectMap(result['activity'])['id'];
        _issuedActivityId = activityId is String ? activityId : null;
      } else {
        _issuedToken = null;
        _tokenExpiry = null;
        _issuedActivityId = null;
      }
      _redeem.clear();
    });
  }

  Future<void> _create() async {
    final start = _start;
    final end = _end;
    if (_subject.text.trim().isEmpty ||
        !start.isAfter(DateTime.now()) ||
        !end.isAfter(start)) {
      setState(() => error = '请填写主题及有效的起止时间，结束须晚于开始。');
      return;
    }
    await _send('POST', '/buddy/activities', {
      'type': _type,
      'subject': _subject.text.trim(),
      'general_city': _city.text.trim().isEmpty ? null : _city.text.trim(),
      'place_kind': _place,
      'budget_band': _budget,
      'start_at': start.toUtc().toIso8601String(),
      'end_at': end.toUtc().toIso8601String(),
      'idempotency_key': requestKey(),
    });
  }

  Future<void> _act(Map<String, dynamic> activity, String action) async {
    final id = activity['id'];
    final revision = activity['revision'];
    if (id is! String || revision is! int) return;
    if (!await confirm(_actionLabel(action), switch (action) {
      'confirm' => '只确认本次双人搭子，不会建立好友、连接、消息同意或恋爱关系。',
      'cancel' || 'withdraw' => '本次搭子将结束。正常取消或撤回不会自动产生处罚，其他独立同意不受此操作替代。',
      'complete' => '记录本次活动完结，不授予私信、通话或资料权限。',
      _ => '仅代表你本人的本次决定；服务器会重新检查当前权限和版本。',
    })) {
      return;
    }
    await _send('POST', '/buddy/${Uri.encodeComponent(id)}/actions', {
      'action': action,
      'revision': revision,
      'idempotency_key': requestKey(),
    });
  }

  Future<void> _invite(Map<String, dynamic> activity) async {
    final generation = _localGeneration;
    final contact = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => const ContactPickerPage(purpose: 'buddy_invite'),
      ),
    );
    if (!mounted || generation != _localGeneration || contact == null) return;
    final peer = contact['peer_id'];
    if (peer is! int) return;
    final id = activity['id'];
    if (id is! String || activity['revision'] is! int) return;
    if (!await confirm(
      '邀请${contact['label'] ?? '这位好友'}？',
      '对方须已开启搭子请求；仍需对方主动申请和你确认，不会自动加入。',
    )) {
      return;
    }
    await _send('POST', '/buddy/${Uri.encodeComponent(id)}/invites', {
      'recipient_id': peer,
      'revision': activity['revision'],
      'idempotency_key': requestKey(),
    });
  }

  Future<void> _pickTime(bool start) async {
    final generation = _localGeneration;
    final current = start ? _start : _end;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (!mounted || generation != _localGeneration || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted || generation != _localGeneration || time == null) return;
    setState(() {
      final selected = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (start) {
        _start = selected;
      } else {
        _end = selected;
      }
    });
  }

  Future<void> _publish(Map<String, dynamic> activity, String action) async {
    final generation = _localGeneration;
    String? label;
    if (action == 'publish') {
      final controller = _publicLabel;
      controller.clear();
      label = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('预览并发布到发现'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity['type'] == 'STUDY' ? '学习' : '吃饭'} · ${activity['subject']}',
                ),
                Text(
                  activity['place_kind'] == 'ONLINE'
                      ? '线上'
                      : '${activity['general_city']} · 公共空间',
                ),
                Text('预算：${_budgetLabel(activity['budget_band'])}'),
                Text(
                  '${buddyLocalTime(activity['start_at'])} 至 ${buddyLocalTime(activity['end_at'])}',
                ),
                const Text('公开至发布后48小时或活动开始，取较早时间。申请后须由你确认。'),
                TextField(
                  controller: controller,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: '本次公开称呼',
                    helperText: '请勿填写联系方式或住址',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: const Text('明确发布'),
            ),
          ],
        ),
      );
      if (!mounted || generation != _localGeneration || label == null) return;
    } else if (!await confirm('从发现撤下？', '关闭新申请，已经成立且仍合法的参与状态保留。')) {
      return;
    }
    if (!mounted || generation != _localGeneration) return;
    await _send(
      'POST',
      '/buddy/${Uri.encodeComponent(activity['id'] as String)}/discovery',
      {
        'action': action,
        'revision': activity['revision'],
        'idempotency_key': requestKey(),
        'author_label': ?label,
      },
    );
  }

  Future<void> _resolvePending() async {
    final generation = _localGeneration;
    await refresh();
    if (!mounted || generation != _localGeneration || data == null) return;
    if (!await confirm('已重读服务器状态', '请核对当前活动。仅在已确认上次结果或决定放弃时结束本次待确认命令。')) return;
    setState(() {
      _pendingMethod = null;
      _pendingPath = null;
      _pendingBody = null;
      _pendingExposesToken = false;
    });
  }

  Widget _choice(
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: choices.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: _blocked
              ? null
              : (next) {
                  if (next != null) change(next);
                },
        ),
      ),
    ),
  );

  Widget _activity(Map<String, dynamic> activity) {
    final actions = _actions(activity);
    final id = activity['id'];
    final writable = id is String && activity['revision'] is int;
    return Card(
      key: ValueKey('buddy-card-$id'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(switch (activity['type']) {
              'STUDY' => '学习搭子',
              'MEAL' => '吃饭搭子',
              _ => '搭子活动',
            }),
            Text('状态：${_stateLabel(activity['state'])}'),
            if (activity['subject'] is String)
              Text(activity['subject'] as String),
            if (activity['general_city'] is String)
              Text('粗城市：${activity['general_city']}'),
            if (activity['place_kind'] != null)
              Text(activity['place_kind'] == 'ONLINE' ? '线上' : '公共空间（未指定具体地点）'),
            if (activity['start_at'] != null)
              Text('开始：${buddyLocalTime(activity['start_at'])}'),
            if (activity['end_at'] != null)
              Text('结束：${buddyLocalTime(activity['end_at'])}'),
            if (activity['budget_band'] != null)
              Text('预算档位：${_budgetLabel(activity['budget_band'])}'),
            if (writable && actions.contains('invite')) ...[
              OutlinedButton(
                key: ValueKey('buddy-$id-invite'),
                onPressed: _blocked ? null : () => _invite(activity),
                child: const Text('邀请当前好友'),
              ),
            ],
            if (writable)
              for (final action
                  in (activity['discovery_actions'] is List
                      ? (activity['discovery_actions'] as List)
                            .whereType<String>()
                      : <String>[]))
                OutlinedButton(
                  key: ValueKey('buddy-$id-discovery-$action'),
                  onPressed: _blocked ? null : () => _publish(activity, action),
                  child: Text(action == 'publish' ? '发布到搭子发现' : '从发现撤下'),
                ),
            if (activity['discovery'] is Map)
              Text('发现发布状态：${objectMap(activity['discovery'])['state']}'),
            if (writable && actions.contains('token'))
              OutlinedButton(
                key: ValueKey('buddy-$id-token'),
                onPressed: _blocked
                    ? null
                    : () async {
                        if (!await confirm(
                          '生成一次性邀请凭据？',
                          '凭据仅限本次活动，有效期由服务器给出。请只交给你明确选择的接收人，可随时撤销。',
                        )) {
                          return;
                        }
                        await _send(
                          'POST',
                          '/buddy/${Uri.encodeComponent(id)}/tokens',
                          {
                            'revision': activity['revision'],
                            'idempotency_key': requestKey(),
                          },
                          exposesToken: true,
                        );
                      },
                child: const Text('生成一次性邀请凭据'),
              ),
            if (writable && actions.contains('revoke_token'))
              OutlinedButton(
                key: ValueKey('buddy-$id-revoke-token'),
                onPressed: _blocked
                    ? null
                    : () async {
                        if (!await confirm(
                          '撤销本次邀请凭据？',
                          '旧凭据不能恢复；之后需要重新生成新的凭据。',
                        )) {
                          return;
                        }
                        await _send(
                          'DELETE',
                          '/buddy/${Uri.encodeComponent(id)}/tokens',
                          {
                            'revision': activity['revision'],
                            'idempotency_key': requestKey(),
                          },
                        );
                      },
                child: const Text('撤销邀请凭据'),
              ),
            if (writable)
              Wrap(
                spacing: 8,
                children: [
                  for (final action in [
                    'open',
                    'request',
                    'confirm',
                    'decline',
                    'decline_invite',
                    'withdraw',
                    'cancel',
                    'complete',
                  ])
                    if (actions.contains(action))
                      OutlinedButton(
                        key: ValueKey('buddy-$id-$action'),
                        onPressed: _blocked
                            ? null
                            : () => _act(activity, action),
                        child: Text(_actionLabel(action)),
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pref = objectMap(data?['preferences']);
    final activities = rows(data?['activities']);
    return frame('我的搭子', [
      if (_pendingBody != null) ...[
        const Text('上次操作结果尚未确认。草稿与原命令已保留。'),
        FilledButton(
          key: const Key('buddy-retry-pending'),
          onPressed: busy ? null : _retryPending,
          child: const Text('原编号重试'),
        ),
        TextButton(
          onPressed: busy ? null : _resolvePending,
          child: const Text('重读并核对上次结果'),
        ),
      ],
      OutlinedButton(
        key: const Key('buddy-open-discovery'),
        onPressed: _blocked
            ? null
            : () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const BuddyDiscoveryPage()),
                );
                if (mounted) refresh();
              },
        child: const Text('搭子发现'),
      ),
      const Text('吃饭或学习，两人自愿确认。无需参加婚恋匹配；不会自动建立好友、私信、通话或正式关系。'),
      if (data != null) ...[
        SwitchListTile(
          key: const Key('buddy-request-preference'),
          title: const Text('接收搭子请求'),
          subtitle: const Text('关闭后不再接受新申请；服务器按当前许可处理旧邀请。'),
          value: pref['enabled'] == true,
          onChanged: _blocked || pref['revision'] is! int
              ? null
              : (value) => _send('PUT', '/buddy/preferences', {
                  'enabled': value,
                  'revision': pref['revision'],
                }),
        ),
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '当前没有可见活动。可保存自己的草稿，或手动兑换对方给你的有效邀请凭据。',
              key: Key('buddy-empty'),
            ),
          ),
        for (final activity in activities) _activity(activity),
        if (_issuedToken != null &&
            activities.any(
              (a) =>
                  a['id'] == _issuedActivityId &&
                  _actions(a).contains('revoke_token'),
            )) ...[
          const Text('新邀请凭据（仅本次响应显示，切换账号或权限变化即清除）：'),
          SelectableText(_issuedToken!, key: const Key('buddy-issued-token')),
          if (_tokenExpiry != null)
            Text('服务器到期时间：${buddyLocalTime(_tokenExpiry)}'),
        ],
        const Divider(),
        ExpansionTile(
          key: const Key('buddy-create-form'),
          title: const Text('创建搭子草稿'),
          children: [
            _choice('搭子类型', _type, const {
              'MEAL': '吃饭',
              'STUDY': '学习',
            }, (v) => setState(() => _type = v)),
            TextField(
              key: const Key('buddy-subject'),
              controller: _subject,
              enabled: !_blocked,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: '简短主题',
                helperText: '不填写电话、账号、链接、精确地址或私人身份资料',
              ),
            ),
            TextField(
              key: const Key('buddy-city'),
              controller: _city,
              enabled: !_blocked,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: '粗城市（可留空）',
                helperText: '只写城市，不写街道、门牌、单位或住址',
              ),
            ),
            _choice('地点类型', _place, const {
              'ONLINE': '线上',
              'PUBLIC_PLACE_UNSPECIFIED': '公共空间（不指定具体地点）',
            }, (v) => setState(() => _place = v)),
            _choice('预算档位', _budget, const {
              'UNSPECIFIED': '未指定',
              'LOW': '低',
              'MID': '中',
              'HIGH': '高',
            }, (v) => setState(() => _budget = v)),
            ListTile(
              key: const Key('buddy-start'),
              title: const Text('开始时间'),
              subtitle: Text(buddyLocalTime(_start.toUtc().toIso8601String())),
              trailing: const Icon(Icons.calendar_month),
              onTap: _blocked ? null : () => _pickTime(true),
            ),
            ListTile(
              key: const Key('buddy-end'),
              title: const Text('结束时间'),
              subtitle: Text(buddyLocalTime(_end.toUtc().toIso8601String())),
              trailing: const Icon(Icons.calendar_month),
              onTap: _blocked ? null : () => _pickTime(false),
            ),
            FilledButton(
              key: const Key('buddy-create'),
              onPressed: _blocked ? null : _create,
              child: const Text('保存仅本人可见草稿'),
            ),
          ],
        ),
        ExpansionTile(
          key: const Key('buddy-redeem-form'),
          title: const Text('手动兑换一次性邀请'),
          children: [
            const Text('仅兑换创建人明确交给你的凭据。兑换只是申请，仍须创建人确认；旧凭据不可重放。'),
            TextField(
              key: const Key('buddy-redeem-token'),
              controller: _redeem,
              enabled: !_blocked,
              maxLength: 256,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(labelText: '一次性邀请凭据'),
            ),
            FilledButton(
              key: const Key('buddy-redeem'),
              onPressed: _blocked
                  ? null
                  : () async {
                      final token = _redeem.text.trim();
                      if (token.isEmpty) {
                        setState(() => error = '请先填写创建人给你的凭据。');
                        return;
                      }
                      if (!await confirm('自愿申请加入本次搭子？', '不会自动建立好友、连接或消息同意。')) {
                        return;
                      }
                      await _send('POST', '/buddy/redeem', {
                        'token': token,
                        'idempotency_key': requestKey(),
                      });
                    },
              child: const Text('兑换并申请参与'),
            ),
          ],
        ),
      ],
      if (data == null && !busy && error == null)
        const Text('正在等候当前账号的服务器状态；请刷新或重新登录。'),
    ]);
  }
}

String _actionLabel(String action) => switch (action) {
  'open' => '开放受控邀请',
  'request' => '自愿申请参与',
  'confirm' => '确认这位搭子',
  'decline' => '拒绝本次申请',
  'decline_invite' => '拒绝这次邀请',
  'withdraw' => '撤回并退出',
  'cancel' => '取消本次活动',
  'complete' => '记录活动完成',
  _ => '操作暂不可用',
};
String _stateLabel(Object? state) => switch (state) {
  'DRAFT' => '仅本人草稿',
  'OPEN' => '可受控邀请',
  'REQUESTED' => '已有申请，等待创建人确认',
  'CONFIRMED' => '双方已确认',
  'COMPLETED' => '已完成',
  'CANCELLED' => '已取消',
  'DECLINED' => '已拒绝',
  'WITHDRAWN' => '已撤回',
  'EXPIRED' => '已到期',
  _ => '状态暂未确认',
};
String _budgetLabel(Object? budget) => switch (budget) {
  'LOW' => '低',
  'MID' => '中',
  'HIGH' => '高',
  _ => '未指定',
};
