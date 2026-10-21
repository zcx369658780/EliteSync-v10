import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../relationships_v1011/relationship_api.dart';
import '../relationships_v1011/session_bound_page.dart';
import '../relationships_v1011/profile_projection_card.dart';
import 'journey_components.dart';

class RelationshipPrivacyPage extends ConsumerStatefulWidget {
  const RelationshipPrivacyPage({super.key, this.peerId});
  final int? peerId;
  @override
  ConsumerState<RelationshipPrivacyPage> createState() => _PrivacyState();
}

class _PrivacyState extends SessionBoundPage<RelationshipPrivacyPage> {
  @override
  String get resource => '/privacy';
  final Map<String, String> _fields = {};
  final _resume = TextEditingController();
  String? _resumeSource;
  bool _resumeLoaded = false;
  Object? _revision;
  Map<String, dynamic>? _peer;
  void _clear() {
    _fields.clear();
    _revision = null;
    _peer = null;
    _resume.clear();
    _resumeSource = null;
    _resumeLoaded = false;
  }

  @override
  void onIdentityChanged() => _clear();
  @override
  void onAuthorityChanged() => _clear();

  @override
  void dispose() {
    _resume.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      final resume = objectMap(data!['self_profile'])['resume']?.toString();
      if (!_resumeLoaded || resume != _resumeSource) {
        _resumeSource = resume;
        _resumeLoaded = true;
        _resume.text = resume ?? '';
      }
    }
    if (data != null && _revision != data!['revision']) {
      _revision = data!['revision'];
      final fields = objectMap(data!['fields']);
      for (final key in ['birthday', 'interests', 'resume', 'zodiac']) {
        _fields[key] = fields[key] == 'RELATIONSHIP_SHARED'
            ? 'RELATIONSHIP_SHARED'
            : 'SELF';
      }
    }
    return frame('正式关系字段分享', [
      const Text(
        '默认仅自己。选择分享只指定最大受众；实际可见还要求正式关系ACTIVE、双有效核验、双方确认且未Block。未提供的值不会生成。证件、精确出生时地、私聊和内部Safety始终不分享。',
      ),
      if (data != null) ...[
        TextField(
          key: const Key('privacy-resume'),
          controller: _resume,
          enabled: !busy,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '本人履历（选填）',
            helperText: '仅保存本人提供的内容；留空可清除。保存不改变分享受众。',
          ),
        ),
        OutlinedButton(
          key: const Key('privacy-resume-save'),
          onPressed: busy
              ? null
              : () async {
                  _peer = null;
                  final resume = _resume.text.trim();
                  await mutate('PUT', '/privacy/resume', {
                    'resume': resume.isEmpty ? null : resume,
                  });
                },
          child: const Text('保存 / 清除本人履历'),
        ),
        const Divider(),
        for (final entry in const {
          'birthday': '生日',
          'interests': '喜好',
          'resume': '履历',
          'zodiac': '星座',
        }.entries)
          ListTile(
            title: Text(entry.value),
            trailing: DropdownButton<String>(
              value: _fields[entry.key] ?? 'SELF',
              items: const [
                DropdownMenuItem(value: 'SELF', child: Text('仅自己')),
                DropdownMenuItem(
                  value: 'RELATIONSHIP_SHARED',
                  child: Text('正式关系分享'),
                ),
              ],
              onChanged: busy
                  ? null
                  : (value) => setState(() {
                      _fields[entry.key] = value!;
                      _peer = null;
                    }),
            ),
          ),
        FilledButton(
          onPressed: busy || _revision is! int
              ? null
              : () async {
                  _peer = null;
                  await mutate('PUT', resource, {
                    'fields': Map<String, String>.from(_fields),
                    'expected_revision': _revision,
                  });
                },
          child: const Text('保存受众 / 撤回分享'),
        ),
        if (widget.peerId != null)
          OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    setState(() => _peer = null);
                    final result = await run(
                      () => ref
                          .read(relationshipApiProvider)
                          .call('GET', '/privacy/peers/${widget.peerId}'),
                    );
                    if (result != null && mounted) {
                      setState(() => _peer = result);
                    }
                  },
            child: const Text('读取对方当前授权资料'),
          ),
        if (_peer != null)
          ProfileProjectionCard(
            projection: objectMap(_peer!['projection'] ?? _peer!['profile']),
          ),
      ],
    ]);
  }
}
