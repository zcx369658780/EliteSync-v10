import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'relationship_api.dart';
import 'session_bound_page.dart';
import 'peer_relationship_page.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class RelationshipCenterPage extends ConsumerStatefulWidget {
  const RelationshipCenterPage({super.key});
  @override
  ConsumerState<RelationshipCenterPage> createState() =>
      _RelationshipCenterState();
}

class _RelationshipCenterState
    extends SessionBoundPage<RelationshipCenterPage> {
  final _invitation = TextEditingController();
  String _purpose = 'friendship';
  String? _issuedToken;
  String? _requestKey;
  String? _requestPayload;
  @override
  String get resource => '/social';
  @override
  void onIdentityChanged() {
    _invitation.clear();
    _issuedToken = null;
    _requestKey = null;
    _requestPayload = null;
  }

  Future<void> _send() async {
    final token = _invitation.text.trim();
    if (token.isEmpty) return;
    final payload = '$token:$_purpose';
    if (_requestPayload != payload) {
      _requestPayload = payload;
      _requestKey = const Uuid().v4();
    }
    final result = await run(
      () => ref.read(relationshipApiProvider).call('POST', '/social/requests', {
        'invitation_token': token,
        'purpose': _purpose,
        'idempotency_key': _requestKey,
      }),
    );
    if (result != null) {
      _invitation.clear();
      _requestKey = null;
      await refresh();
    }
  }

  Future<void> _invite() async {
    final result = await run(
      () => ref.read(relationshipApiProvider).call('POST', '/social/invites', {
        'purpose': _purpose,
      }),
    );
    if (result == null || !mounted) return;
    setState(() => _issuedToken = result['token']?.toString());
    await refresh();
  }

  int? _requestPeerId(Map<String, dynamic> item, int? actor) {
    if (actor == null) return null;
    final sender = int.tryParse('${item['sender_id']}');
    final recipient = int.tryParse('${item['recipient_id']}');
    final peer = sender == actor
        ? recipient
        : recipient == actor
        ? sender
        : null;
    return peer != null && peer > 0 && peer != actor ? peer : null;
  }

  String _peer(Map<String, dynamic> item, int? actor) {
    final peer = item['peer'] ?? item['user'];
    if (peer is Map && peer['public_id'] != null) return '${peer['public_id']}';
    if (item['public_id'] != null) return '${item['public_id']}';
    final peerId =
        _requestPeerId(item, actor) ?? int.tryParse('${item['peer_id']}');
    return peerId != null && peerId > 0 ? 'ES-$peerId' : '身份暂不可用';
  }

  @override
  Widget build(BuildContext context) {
    // A token is private to this page's account; clear when its projection clears.
    if (data == null) _issuedToken = null;
    final requests = rows(data?['requests']);
    final actor = ref.watch(sessionProvider).asData?.value.user?.id;
    return frame('好友与请求', [
      const Text('好友、消息请求与连接/消息同意分别成立。接受请求不会开放普通私信、附件或通话。'),
      SwitchListTile(
        title: const Text('接收新请求'),
        subtitle: const Text('默认关闭；开启后仍需有效邀请或服务端认可的上下文'),
        value: data?['requests_enabled'] == true,
        onChanged: busy || data == null
            ? null
            : (value) => mutate('POST', '/social/preferences', {
                'requests_enabled': value,
              }),
      ),
      DropdownButtonFormField<String>(
        initialValue: _purpose,
        decoration: const InputDecoration(labelText: '固定用途'),
        items: const [
          DropdownMenuItem(value: 'friendship', child: Text('好友申请')),
          DropdownMenuItem(value: 'message', child: Text('消息请求')),
        ],
        onChanged: busy ? null : (value) => setState(() => _purpose = value!),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: busy ? null : _invite,
        child: const Text('生成定向邀请'),
      ),
      if (_issuedToken != null) ...[
        const Text('请仅将邀请交给指定对象。默认24小时有效，可在下方撤销。'),
        SelectableText(_issuedToken!),
        TextButton(
          onPressed: () =>
              Clipboard.setData(ClipboardData(text: _issuedToken!)),
          child: const Text('复制邀请凭据'),
        ),
      ],
      TextField(
        controller: _invitation,
        decoration: const InputDecoration(labelText: '对方交给你的邀请凭据'),
        maxLines: 2,
      ),
      FilledButton(onPressed: busy ? null : _send, child: const Text('提交请求')),
      const Text('24小时最多向5位账号发起请求；未决7天到期。被拒绝后须等接收方主动发出新邀请。'),
      const Divider(),
      const Text('请求记录'),
      if (data != null && requests.isEmpty) const Text('暂无请求'),
      for (final item in requests)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_peer(item, actor)} · ${item['purpose'] == 'message' ? '消息请求' : '好友申请'}',
                ),
                Text('${item['state'] ?? ''} · ${item['expires_at'] ?? ''}'),
                if (item['purpose'] == 'message' &&
                    item['state'] == 'ACCEPTED' &&
                    _requestPeerId(item, actor) != null)
                  OutlinedButton(
                    key: ValueKey('message-consent-${item['id']}'),
                    onPressed: busy
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PeerRelationshipPage(
                                peerId: _requestPeerId(item, actor)!,
                              ),
                            ),
                          ),
                    child: const Text('分别确认连接与消息同意'),
                  ),
                if ('${item['state']}'.toLowerCase() == 'pending')
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final action
                          in item['recipient_id'] == actor
                              ? ['accept', 'decline']
                              : ['withdraw'])
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => mutate(
                                  'POST',
                                  '/social/requests/${item['id']}/$action',
                                ),
                          child: Text(
                            {
                              'accept': '接受',
                              'decline': '拒绝',
                              'withdraw': '撤回',
                            }[action]!,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      const Divider(),
      const Text('双向好友'),
      for (final item in rows(data?['friends']))
        ListTile(
          title: Text(_peer(item, actor)),
          subtitle: const Text('好友不等于连接或消息同意'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  PeerRelationshipPage(peerId: item['peer_id'] as int),
            ),
          ),
          trailing: TextButton(
            onPressed: busy
                ? null
                : () async {
                    if (await confirm(
                      '解除好友？',
                      '撤回好友专属展示；独立的连接与消息同意不会因此自动关闭。停止交流或拉黑请使用已有安全入口。',
                    )) {
                      await mutate(
                        'DELETE',
                        '/social/friends/${item['peer_id'] ?? item['id']}',
                      );
                    }
                  },
            child: const Text('解除好友'),
          ),
        ),
      const Divider(),
      const Text('已发出的邀请'),
      for (final item in rows(data?['invites']))
        ListTile(
          title: Text('${item['purpose'] ?? ''} · ${item['status'] ?? ''}'),
          subtitle: Text('到期：${item['expires_at'] ?? ''}'),
          trailing: TextButton(
            onPressed: busy
                ? null
                : () => mutate('DELETE', '/social/invites/${item['id']}'),
            child: const Text('撤销邀请'),
          ),
        ),
    ]);
  }

  @override
  void dispose() {
    _invitation.dispose();
    super.dispose();
  }
}
