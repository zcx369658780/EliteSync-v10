import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../slow_dating_v1012/journey_components.dart';

/// Only the server's current invitations and registrations are shown here.
class PlatformEventsPage extends ConsumerStatefulWidget {
  const PlatformEventsPage({super.key});

  @override
  ConsumerState<PlatformEventsPage> createState() => _PlatformEventsPageState();
}

class _PlatformEventsPageState extends SessionBoundPage<PlatformEventsPage> {
  @override
  String get resource => '/platform-events';

  final _token = TextEditingController();
  final _statement = TextEditingController();
  final Map<String, String> _commandKeys = {};
  String? _reportEvent;
  String? _reportTarget;
  String _category = 'CONDUCT';
  int _localGeneration = 0;

  void _clearPrivateForm() {
    _localGeneration++;
    _token.clear();
    _statement.clear();
    _commandKeys.clear();
    _reportEvent = null;
    _reportTarget = null;
    _category = 'CONDUCT';
  }

  @override
  void onIdentityChanged() => _clearPrivateForm();
  @override
  void onAuthorityChanged() => _clearPrivateForm();

  @override
  void dispose() {
    _token.dispose();
    _statement.dispose();
    super.dispose();
  }

  String _key(String command) => _commandKeys.putIfAbsent(command, requestKey);

  Future<void> _write(String path, Map<String, dynamic> body) async {
    final generation = _localGeneration;
    final result = await run(
      () => ref.read(relationshipApiProvider).call('POST', path, body),
    );
    if (!mounted || generation != _localGeneration) return;
    _token.clear();
    if (result == null) {
      // A rejected or uncertain write must not leave an old permission card.
      setState(() {
        data = null;
        _statement.clear();
        _reportEvent = null;
        _reportTarget = null;
      });
      return;
    }
    ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
  }

  Future<void> _redeem() async {
    final token = _token.text.trim();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      setState(() => error = '请输入完整的受控活动邀请凭据。');
      return;
    }
    await _write('/platform-events/redeem', {
      'token': token,
      'idempotency_key': _key('redeem:$token'),
    });
  }

  Future<void> _action(Map<String, dynamic> event, String action) async {
    final id = event['id']?.toString();
    final revision = event['revision'];
    if (id == null || revision is! int) return;
    final approved = await confirm(
      switch (action) {
        'apply' => '主动报名合成活动',
        'cancel' => '取消本人活动参与',
        _ => '提交本人测试到场声明',
      },
      switch (action) {
        'apply' => '报名不等于已确认席位；名额和候补状态以服务器回读为准。',
        'cancel' => '可以自主取消；取消不会自动形成违规或处罚。',
        _ => '这只是 SELF_REPORTED / UNVERIFIED 测试声明，不证明实际到场，不使用定位。',
      },
    );
    if (!approved) return;
    await _write('/platform-events/${Uri.encodeComponent(id)}/actions', {
      'action': action,
      'revision': revision,
      'idempotency_key': _key('$id:$revision:$action'),
    });
  }

  Future<void> _report(Map<String, dynamic> event) async {
    final id = event['id']?.toString();
    final statement = _statement.text.trim();
    if (id == null || _reportTarget == null || statement.isEmpty) return;
    await _write('/platform-events/${Uri.encodeComponent(id)}/reports', {
      'target_registration_id': _reportTarget,
      'category': _category,
      'statement': statement,
      'idempotency_key': _key('report:$id:${event['revision']}'),
    });
  }

  List<String> _actions(Map<String, dynamic> event) =>
      event['allowed_actions'] is List
      ? (event['allowed_actions'] as List).whereType<String>().toList()
      : const [];

  String _registrationLabel(Object? state) => switch (state) {
    'INVITED' => '已受邀，尚未主动报名',
    'APPLIED' => '已主动报名，等待名额确认',
    'WAITLISTED' => '正在候补，尚未确认席位',
    'CONFIRMED' => '席位已确认，仍可自主取消',
    'CANCELLED_BY_USER' => '本人已取消',
    'CANCELLED_BY_ORGANIZER' => '主办方已取消',
    'DECLINED' => '本次未确认',
    'EXPIRED' => '本次参与已到期',
    _ => '当前没有已确认的参与状态',
  };

  String _eventLabel(Object? state) => switch (state) {
    'OPEN' => '开放受控报名',
    'CLOSED' => '报名已关闭',
    'COMPLETED' => '平台排程已完成（不证明出席）',
    'CANCELLED' => '活动已取消',
    'EXPIRED' => '活动已到期',
    'DRAFT' => '尚未开放',
    _ => '活动状态待刷新确认',
  };

  Widget _reportForm(Map<String, dynamic> event) {
    final participants = rows(event['participants']);
    final targets = participants
        .where((p) => p['registration_id'] != null)
        .toList();
    final targetIds = targets
        .map((p) => p['registration_id'].toString())
        .toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('举报仅登记指控；取消、未回复或未声明到场不是违规事实。'),
        DropdownButtonFormField<String>(
          key: ValueKey('report-target-${event['id']}'),
          initialValue: targetIds.contains(_reportTarget)
              ? _reportTarget
              : null,
          decoration: const InputDecoration(labelText: '本活动内可举报的关联参与记录'),
          items: targets
              .map(
                (p) => DropdownMenuItem(
                  value: p['registration_id'].toString(),
                  child: Text(p['label']?.toString() ?? '活动参与记录'),
                ),
              )
              .toList(),
          onChanged: busy ? null : (v) => setState(() => _reportTarget = v),
        ),
        DropdownButtonFormField<String>(
          key: ValueKey('report-category-${event['id']}'),
          initialValue: _category,
          decoration: const InputDecoration(labelText: '需要人工核查的类别'),
          items: const [
            DropdownMenuItem(value: 'CONDUCT', child: Text('行为安全疑虑')),
            DropdownMenuItem(value: 'ATTENDANCE', child: Text('到场情况有待核查')),
            DropdownMenuItem(value: 'RESOURCE', child: Text('资源使用情况有待核查')),
          ],
          onChanged: busy
              ? null
              : (v) => setState(() => _category = v ?? 'CONDUCT'),
        ),
        TextField(
          key: const Key('platform-report-statement'),
          controller: _statement,
          enabled: !busy,
          maxLength: 500,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '本人陈述（不要填写私信、证件、电话或精确位置）',
          ),
          onChanged: (_) => setState(() {}),
        ),
        FilledButton(
          onPressed:
              busy ||
                  !targetIds.contains(_reportTarget) ||
                  _statement.text.trim().isEmpty
              ? null
              : () => _report(event),
          child: const Text('提交关联活动举报'),
        ),
        TextButton(
          onPressed: busy
              ? null
              : () => setState(() {
                  _reportEvent = null;
                  _reportTarget = null;
                  _statement.clear();
                }),
          child: const Text('收起举报表单'),
        ),
      ],
    );
  }

  Widget _eventCard(Map<String, dynamic> event) {
    final actions = _actions(event);
    final registration = objectMap(event['registration']);
    final mayReport =
        [
          'APPLIED',
          'WAITLISTED',
          'CONFIRMED',
        ].contains(registration['state']) &&
        rows(event['participants']).isNotEmpty;
    return Card(
      key: ValueKey('platform-event-${event['id']}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title']?.toString() ?? '受控合成活动',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('DEV_SYNTHETIC_EVENT · NOT_REAL_BOOKING'),
            Text(_eventLabel(event['state'])),
            Text('虚构城市：${event['city'] ?? ''}'),
            Text('合成公共场所：${event['venue'] ?? ''}'),
            Text('开始：${event['start_at'] ?? ''}'),
            Text('结束：${event['end_at'] ?? ''}'),
            Text('活动席位上限：${event['capacity'] ?? '待确认'}'),
            Text(_registrationLabel(registration['state'])),
            if (registration['state'] == 'WAITLISTED')
              Text('服务端候补序号：${registration['wait_order'] ?? '等待回读'}'),
            if (registration['attendance'] == 'SELF_REPORTED')
              const Text('本人到场声明：SELF_REPORTED / UNVERIFIED'),
            Wrap(
              spacing: 8,
              children: [
                if (actions.contains('apply'))
                  FilledButton(
                    key: ValueKey('event-apply-${event['id']}'),
                    onPressed: busy ? null : () => _action(event, 'apply'),
                    child: const Text('主动报名'),
                  ),
                if (actions.contains('cancel'))
                  OutlinedButton(
                    key: ValueKey('event-cancel-${event['id']}'),
                    onPressed: busy ? null : () => _action(event, 'cancel'),
                    child: const Text('取消本人参与'),
                  ),
                if (actions.contains('attendance'))
                  OutlinedButton(
                    onPressed: busy ? null : () => _action(event, 'attendance'),
                    child: const Text('自愿测试到场声明'),
                  ),
                if (mayReport)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            _reportEvent = event['id'].toString();
                            _reportTarget = null;
                            _statement.clear();
                          }),
                    child: const Text('活动相关举报'),
                  ),
              ],
            ),
            if (mayReport && _reportEvent == event['id']) _reportForm(event),
          ],
        ),
      ),
    );
  }

  bool _validExitTicket(Map<String, dynamic> ticket) =>
      ticket['id'] is String &&
      (ticket['id'] as String).isNotEmpty &&
      ticket['revision'] is int &&
      _actions(ticket).contains('cancel');

  Widget _exitTicketCard(Map<String, dynamic> ticket) => Card(
    key: ValueKey('platform-exit-ticket-${ticket['id']}'),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本人最小退出入口', style: Theme.of(context).textTheme.titleMedium),
          const Text('当前受限仍可自主取消；此入口不展示活动详情或他人资料。'),
          OutlinedButton(
            key: ValueKey('event-exit-cancel-${ticket['id']}'),
            onPressed: busy ? null : () => _action(ticket, 'cancel'),
            child: const Text('取消本人参与'),
          ),
        ],
      ),
    ),
  );

  Widget _historyReportCard(Map<String, dynamic> context) => Card(
    key: ValueKey('platform-report-context-${context['id']}'),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本人历史参与安全报告',
            style: Theme.of(this.context).textTheme.titleMedium,
          ),
          const Text('REPORT_ONLY：退出或拉黑不影响限时提交本人最小陈述；此入口不恢复活动详情、他人资料或私人接触。'),
          Text('合成开发报告窗口截止：${context['report_until'] ?? '以服务器校验为准'}'),
          if (_reportEvent != 'history:${context['id']}')
            TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() {
                      _reportEvent = 'history:${context['id']}';
                      _reportTarget = null;
                      _statement.clear();
                    }),
              child: const Text('提交历史参与安全疑虑'),
            ),
          if (_reportEvent == 'history:${context['id']}') _reportForm(context),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final items = rows(data?['items']);
    final exitTickets = rows(data?['exit_tickets']).where(_validExitTicket);
    final reportContexts = rows(data?['report_contexts']).where(
      (e) =>
          e['scope'] == 'REPORT_ONLY' &&
          e['id'] is String &&
          rows(e['participants']).isNotEmpty,
    );
    return frame('平台合成活动', [
      const Text('仅限受控开发邀请；没有真实招募、预订、费用支付或安全保障承诺。'),
      const Text('报名不建立好友、私信同意、搭子或正式恋爱关系。'),
      TextField(
        key: const Key('platform-invite-token'),
        controller: _token,
        enabled: !busy,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(labelText: '手动输入受控活动邀请凭据'),
      ),
      FilledButton(
        key: const Key('platform-redeem'),
        onPressed: busy ? null : _redeem,
        child: const Text('主动兑换活动邀请'),
      ),
      if (data != null && items.isEmpty && exitTickets.isEmpty)
        const Text('当前没有有权查看的活动；这里只展示本人获准邀请或参与记录。'),
      if (data != null && items.isEmpty && exitTickets.isNotEmpty)
        const Text('当前没有有权查看的完整活动卡；本人保留报名可通过下方最小入口退出。'),
      ...items.map(_eventCard),
      ...exitTickets.map(_exitTicketCard),
      ...reportContexts.map(_historyReportCard),
    ]);
  }
}
