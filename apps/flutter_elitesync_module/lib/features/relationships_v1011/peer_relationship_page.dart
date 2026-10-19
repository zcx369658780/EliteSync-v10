import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'relationship_api.dart';
import 'session_bound_page.dart';
import 'profile_projection_card.dart';

class PeerRelationshipPage extends ConsumerStatefulWidget {
  const PeerRelationshipPage({super.key, required this.peerId});
  final int peerId;
  @override
  ConsumerState<PeerRelationshipPage> createState() => _PeerState();
}

class _PeerState extends SessionBoundPage<PeerRelationshipPage> {
  @override
  String get resource => '/connections/${widget.peerId}';
  Map<String, dynamic>? _profile;
  @override
  void onIdentityChanged() => _profile = null;
  @override
  void onAuthorityChanged() => _profile = null;

  List<String> _actions(Map row, bool consent, int? actor) {
    final state = '${row['state']}';
    if (state.endsWith('_NONE')) return ['request'];
    if (state.endsWith('_PENDING')) {
      return row['requester_id'] == actor
          ? ['withdraw']
          : ['accept', 'decline'];
    }
    if (state.endsWith('_ACTIVE')) {
      return consent ? ['revoke'] : ['pause', 'close'];
    }
    if (!consent && state.endsWith('_PAUSED')) return ['close'];
    if (consent &&
        ['MC_REVOKED', 'MC_DECLINED', 'MC_WITHDRAWN'].contains(state)) {
      return ['request'];
    }
    if (!consent &&
        [
          'CN_CLOSED',
          'CN_DECLINED',
          'CN_WITHDRAWN',
          'CN_EXPIRED',
        ].contains(state)) {
      return ['request'];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final actor = ref.watch(sessionProvider).asData?.value.user?.id;
    return frame('好友资料与独立授权', [
      const Text('好友只影响所选受众。双方另行确认连接（CN）与消息同意（MC）后，服务器才能开放普通交流。撤销可停止新的交流。'),
      OutlinedButton(
        onPressed: busy
            ? null
            : () async {
                setState(() => _profile = null);
                final result = await run(
                  () => ref
                      .read(relationshipApiProvider)
                      .call('GET', '/profile-peers/${widget.peerId}'),
                );
                if (result != null && mounted) {
                  setState(() => _profile = result);
                }
              },
        child: const Text('读取当前可见资料'),
      ),
      if (_profile?['profile'] is Map)
        ProfileProjectionCard(projection: _profile!['profile'] as Map),
      for (final kind in ['connection', 'consent'])
        if (data?[kind] is Map) ...[
          const Divider(),
          Text(
            '${kind == 'connection' ? '连接' : '消息同意'}：${relationshipStateLabel((data![kind] as Map)['state'])}',
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final action in _actions(
                data![kind] as Map,
                kind == 'consent',
                actor,
              ))
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () async {
                          _profile = null;
                          await mutate(
                            'POST',
                            '/connections/${widget.peerId}/$kind',
                            {
                              'action': action,
                              'expected_connection_id':
                                  (data!['connection'] as Map)['id'],
                              'expected_consent_id':
                                  (data!['consent'] as Map)['id'],
                              'expected_revision':
                                  (data![kind] as Map)['revision'],
                            },
                          );
                        },
                  child: Text(
                    {
                      'request':
                          kind == 'consent' &&
                              (data![kind] as Map)['id'] != null
                          ? '重新申请消息同意'
                          : kind == 'connection' &&
                                (data![kind] as Map)['id'] != null
                          ? '发起新的连接申请'
                          : '发起申请',
                      'accept': '接受',
                      'decline': '拒绝',
                      'withdraw': '撤回',
                      'pause': '暂停连接',
                      'close': '关闭连接',
                      'revoke': '撤销消息同意',
                    }[action]!,
                  ),
                ),
            ],
          ),
        ],
      if (data?['gates'] is Map)
        Text(
          '当前聊天记录：${data!['gates']['live_read_allowed'] == true ? '可读取' : '不可读取'}；发送消息：${data!['gates']['live_send_allowed'] == true ? '已获授权' : '未获授权'}',
        ),
      const Text('拉黑可在既有会话安全入口执行；拉黑会撤销相关授权，解黑不会恢复。'),
    ]);
  }
}
