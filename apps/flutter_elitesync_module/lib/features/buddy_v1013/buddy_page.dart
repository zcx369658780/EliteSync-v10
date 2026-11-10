import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';

/// A controlled activity list, never a directory of strangers or mock candidates.
class BuddyPage extends ConsumerStatefulWidget {
  const BuddyPage({super.key});

  @override
  ConsumerState<BuddyPage> createState() => _BuddyPageState();
}

class _BuddyPageState extends SessionBoundPage<BuddyPage> {
  @override
  String get resource => '/buddy';

  final _subject = TextEditingController();
  final _city = TextEditingController();
  final _recipient = TextEditingController();
  final _redeem = TextEditingController();
  final _start = TextEditingController(
    text: DateTime.now()
        .toUtc()
        .add(const Duration(hours: 1))
        .toIso8601String(),
  );
  final _end = TextEditingController(
    text: DateTime.now()
        .toUtc()
        .add(const Duration(hours: 2))
        .toIso8601String(),
  );
  String _type = 'MEAL';
  String _place = 'ONLINE';
  String _budget = 'UNSPECIFIED';
  String? _issuedToken;
  String? _tokenExpiry;
  String? _issuedActivityId;
  int _localGeneration = 0;

  void _clearSensitive() {
    _localGeneration++;
    for (final c in [_subject, _city, _recipient, _redeem]) {
      c.clear();
    }
    _issuedToken = null;
    _tokenExpiry = null;
    _issuedActivityId = null;
    _start.text = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 1))
        .toIso8601String();
    _end.text = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 2))
        .toIso8601String();
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
    for (final c in [_subject, _city, _recipient, _redeem, _start, _end]) {
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
    final generation = _localGeneration;
    final result = await run(
      () => ref.read(relationshipApiProvider).call(method, path, body),
    );
    if (!mounted || generation != _localGeneration) return;
    if (result == null) {
      setState(() {
        data = null;
        _clearSensitive();
      });
      return;
    }
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
    final start = DateTime.tryParse(_start.text.trim());
    final end = DateTime.tryParse(_end.text.trim());
    if (_subject.text.trim().isEmpty ||
        start == null ||
        end == null ||
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
    final peer = int.tryParse(_recipient.text.trim());
    if (peer == null || peer <= 0) {
      setState(() => error = '请输入当前好友的用户编号。');
      return;
    }
    final id = activity['id'];
    if (id is! String || activity['revision'] is! int) return;
    if (!await confirm('定向邀请这位好友？', '对方须已开启搭子请求；仍需对方主动申请和你确认，不会自动加入。')) {
      return;
    }
    await _send('POST', '/buddy/${Uri.encodeComponent(id)}/invites', {
      'recipient_id': peer,
      'revision': activity['revision'],
      'idempotency_key': requestKey(),
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
          onChanged: busy
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
            Text(activity['type'] == 'STUDY' ? '学习搭子' : '吃饭搭子'),
            Text('状态：${_stateLabel(activity['state'])}'),
            if (activity['subject'] is String)
              Text(activity['subject'] as String),
            if (activity['general_city'] is String)
              Text('粗城市：${activity['general_city']}'),
            if (activity['place_kind'] != null)
              Text(activity['place_kind'] == 'ONLINE' ? '线上' : '公共空间（未指定具体地点）'),
            if (activity['start_at'] != null)
              Text('开始（UTC）：${activity['start_at']}'),
            if (activity['end_at'] != null)
              Text('结束（UTC）：${activity['end_at']}'),
            if (activity['budget_band'] != null)
              Text('预算档位：${_budgetLabel(activity['budget_band'])}'),
            if (writable && actions.contains('invite')) ...[
              TextField(
                key: ValueKey('buddy-recipient-$id'),
                controller: _recipient,
                enabled: !busy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '当前好友用户编号'),
              ),
              OutlinedButton(
                key: ValueKey('buddy-$id-invite'),
                onPressed: busy ? null : () => _invite(activity),
                child: const Text('邀请当前好友'),
              ),
            ],
            if (writable && actions.contains('token'))
              OutlinedButton(
                key: ValueKey('buddy-$id-token'),
                onPressed: busy
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
                onPressed: busy
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
                        onPressed: busy ? null : () => _act(activity, action),
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
    return frame('独立搭子', [
      const Text('吃饭或学习，两人自愿确认。无需参加婚恋匹配；不会自动建立好友、私信、通话或正式关系。'),
      if (data != null) ...[
        SwitchListTile(
          key: const Key('buddy-request-preference'),
          title: const Text('接收搭子请求'),
          subtitle: const Text('关闭后不再接受新申请；服务器按当前许可处理旧邀请。'),
          value: pref['enabled'] == true,
          onChanged: busy || pref['revision'] is! int
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
          if (_tokenExpiry != null) Text('服务器到期时间：$_tokenExpiry'),
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
              enabled: !busy,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: '简短主题',
                helperText: '不填写电话、账号、链接、精确地址或私人身份资料',
              ),
            ),
            TextField(
              key: const Key('buddy-city'),
              controller: _city,
              enabled: !busy,
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
            TextField(
              key: const Key('buddy-start'),
              controller: _start,
              enabled: !busy,
              decoration: const InputDecoration(
                labelText: '开始时间（UTC / ISO 8601）',
              ),
            ),
            TextField(
              key: const Key('buddy-end'),
              controller: _end,
              enabled: !busy,
              decoration: const InputDecoration(
                labelText: '结束时间（UTC / ISO 8601）',
              ),
            ),
            FilledButton(
              key: const Key('buddy-create'),
              onPressed: busy ? null : _create,
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
              enabled: !busy,
              maxLength: 256,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(labelText: '一次性邀请凭据'),
            ),
            FilledButton(
              key: const Key('buddy-redeem'),
              onPressed: busy
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
