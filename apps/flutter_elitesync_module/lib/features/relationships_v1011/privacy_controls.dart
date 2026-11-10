import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'relationship_api.dart';
import 'session_bound_page.dart';
import 'profile_projection_card.dart';

class ServerPrivacyPage extends ConsumerStatefulWidget {
  const ServerPrivacyPage({super.key});
  @override
  ConsumerState<ServerPrivacyPage> createState() => _PrivacyState();
}

class _PrivacyState extends SessionBoundPage<ServerPrivacyPage> {
  @override
  String get resource => '/privacy';
  final Map<String, String> _draft = {};
  Map<String, dynamic>? _preview;
  Object? _revision;
  String _audience = 'stranger';
  @override
  Widget build(BuildContext context) {
    if (data == null) {
      _draft.clear();
      _preview = null;
      _revision = null;
    }
    if (data != null && _revision != data!['revision']) {
      _revision = data!['revision'];
      _draft.clear();
      final fields = data!['fields'];
      for (final key in ['birthday', 'interests', 'resume', 'zodiac']) {
        _draft[key] = fields is Map && fields[key] == 'RELATIONSHIP_SHARED'
            ? 'RELATIONSHIP_SHARED'
            : 'SELF';
      }
    }
    return frame('资料受众与预览', [
      const Text('深层资料默认仅自己。恋爱分享是未来意向：本版没有建立正式恋爱关系的入口，保存意向不会让任何对方获得访问。'),
      for (final key in ['birthday', 'interests', 'resume', 'zodiac'])
        ListTile(
          title: Text(
            {
              'birthday': '生日',
              'interests': '喜好',
              'resume': '履历',
              'zodiac': '星座',
            }[key]!,
          ),
          trailing: DropdownButton<String>(
            value: _draft[key] ?? 'SELF',
            items: const [
              DropdownMenuItem(value: 'SELF', child: Text('仅自己')),
              DropdownMenuItem(
                value: 'RELATIONSHIP_SHARED',
                child: Text('未来恋爱分享意向'),
              ),
            ],
            onChanged: busy || data == null
                ? null
                : (v) => setState(() {
                    _draft[key] = v!;
                    _preview = null;
                  }),
          ),
        ),
      FilledButton(
        onPressed: busy || data == null
            ? null
            : () async {
                _preview = null;
                await mutate('PUT', '/privacy', {
                  'fields': Map<String, String>.from(_draft),
                  'expected_revision': _revision,
                });
              },
        child: const Text('保存受众 / 撤回分享意向'),
      ),
      const Divider(),
      DropdownButton<String>(
        value: _audience,
        items: const [
          DropdownMenuItem(value: 'stranger', child: Text('陌生人')),
          DropdownMenuItem(value: 'friend', child: Text('好友')),
          DropdownMenuItem(value: 'partner', child: Text('恋爱对象')),
        ],
        onChanged: busy
            ? null
            : (v) => setState(() {
                _audience = v!;
                _preview = null;
              }),
      ),
      OutlinedButton(
        onPressed: busy || data == null
            ? null
            : () async {
                final result = await run(
                  () => ref
                      .read(relationshipApiProvider)
                      .call('GET', '/privacy/preview?audience=$_audience'),
                );
                if (result != null && mounted) {
                  setState(() => _preview = result);
                }
              },
        child: const Text('获取服务端本人预览'),
      ),
      if (_preview != null) ...[
        const Text('仅为本人模拟受众；不建立对方实际访问权。'),
        if (_preview!['formal_relationship_available'] == false)
          const Text('尚无已成立的正式恋爱关系，恋爱专属深层资料不可见。'),
        if (_preview!['projection'] is Map)
          ProfileProjectionCard(projection: _preview!['projection'] as Map),
      ],
    ]);
  }
}
