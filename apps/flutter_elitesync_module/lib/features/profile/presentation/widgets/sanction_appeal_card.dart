import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

/// Only the authenticated user's current restrict sanctions are requested.
/// Rendering this card or submitting an appeal grants no business permissions.
class SanctionAppealCard extends ConsumerStatefulWidget {
  const SanctionAppealCard({super.key});

  @override
  ConsumerState<SanctionAppealCard> createState() => _SanctionAppealCardState();
}

class _SanctionAppealCardState extends ConsumerState<SanctionAppealCard> {
  List<_Sanction>? _items;
  bool _loading = false;
  int? _sending;
  String? _error;
  final Map<int, TextEditingController> _drafts = {};

  @override
  void dispose() {
    for (final controller in _drafts.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load({bool preserveError = false}) async {
    setState(() {
      _loading = true;
      if (!preserveError) _error = null;
    });
    try {
      final result = await ref
          .read(apiClientProvider)
          .get('/api/v1/moderation/sanctions');
      if (!mounted) return;
      if (result is! NetworkSuccess<Map<String, dynamic>>) {
        throw const FormatException();
      }
      final raw = result.data['items'];
      if (raw is! List) throw const FormatException();
      final items = raw.map((item) => _Sanction.parse(item)).toList();
      if (items.map((item) => item.id).toSet().length != items.length) {
        throw const FormatException();
      }
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = null;
        _error = '无法确认当前本人处罚，请重试读取。';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit(_Sanction sanction) async {
    if (_loading || _sending != null || sanction.appeal != null) return;
    final note = _drafts[sanction.id]!.text.trim();
    if (note.isEmpty || note.runes.length > 1000) {
      setState(() => _error = '请填写1至1000字的申诉说明。');
      return;
    }
    setState(() {
      _sending = sanction.id;
      _error = null;
    });
    try {
      final result = await ref
          .read(apiClientProvider)
          .post(
            '/api/v1/moderation/sanctions/${sanction.id}/appeals',
            body: {'note': note},
          );
      if (!mounted) return;
      if (result is NetworkSuccess<Map<String, dynamic>> &&
          const [200, 201].contains(result.statusCode) &&
          result.data['sanction_id'] == sanction.id) {
        final appeal = _Appeal.parse(result.data['appeal']);
        if (appeal.note != note) throw const FormatException();
        setState(() {
          _items = _items
              ?.map(
                (item) => item.id == sanction.id
                    ? _Sanction(item.id, item.createdAt, appeal)
                    : item,
              )
              .toList();
        });
      } else {
        final status = result is NetworkFailure<Map<String, dynamic>>
            ? result.statusCode
            : null;
        setState(
          () => _error = switch (status) {
            401 || 403 => '申诉未提交：当前身份无权操作，请确认登录状态。',
            404 => '申诉未提交：该处罚已失效或不可访问。',
            409 => '未重复提交：该处罚已有申诉，请核对服务器记录。',
            _ => '未确认申诉提交成功，请核对服务器记录后重试。',
          },
        );
        await _load(preserveError: true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '未确认申诉提交成功，请核对服务器记录后重试。');
      await _load(preserveError: true);
    } finally {
      if (mounted) setState(() => _sending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _sending != null;
    return AppInfoSectionCard(
      title: '本人处罚与申诉',
      subtitle: '申诉不自动解除处罚或恢复匹配、私信及旧凭据。',
      leadingIcon: Icons.gavel_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: busy ? null : () => _load(),
            child: Text(_items == null ? '查看本人处罚与申诉' : '刷新本人处罚'),
          ),
          if (_loading) const Text('正在读取本人当前处罚…'),
          if (_error != null) Text(_error!),
          if (!_loading && _items != null) ...[
            if (_items!.isEmpty) const Text('当前没有可申诉的有效受限处罚。'),
            for (final sanction in _items!) ...[
              const Divider(),
              Text('受限处罚 #${sanction.id}'),
              Text('开始时间：${sanction.createdAt}'),
              const Text('受限期间保留合法历史只读及申诉；新匹配、公开发布和新私信收发暂停。'),
              if (sanction.appeal case final appeal?) ...[
                const Text('申诉已提交，等待管理员查看'),
                Text('提交时间：${appeal.submittedAt}'),
                Text('本人申诉：${appeal.note}'),
              ] else ...[
                TextField(
                  key: ValueKey('sanction-appeal-note-${sanction.id}'),
                  controller: _drafts.putIfAbsent(
                    sanction.id,
                    TextEditingController.new,
                  ),
                  enabled: !busy,
                  minLines: 2,
                  maxLines: 5,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: '本人申诉说明',
                    hintText: '请勿填写密码、验证码或无关私密内容',
                    alignLabelWithHint: true,
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : () => _submit(sanction),
                  child: Text(_sending == sanction.id ? '正在提交…' : '提交本人处罚申诉'),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _Appeal {
  const _Appeal(this.submittedAt, this.note);
  final String submittedAt;
  final String note;

  static _Appeal parse(dynamic raw) {
    if (raw is! Map<String, dynamic> ||
        raw['id'] is! int ||
        (raw['id'] as int) <= 0 ||
        raw['status'] != 'submitted' ||
        raw['note'] is! String ||
        (raw['note'] as String).trim().isEmpty ||
        (raw['note'] as String).runes.length > 1000 ||
        raw['submitted_at'] is! String ||
        DateTime.tryParse(raw['submitted_at'] as String) == null) {
      throw const FormatException();
    }
    return _Appeal(raw['submitted_at'] as String, raw['note'] as String);
  }
}

class _Sanction {
  const _Sanction(this.id, this.createdAt, this.appeal);
  final int id;
  final String createdAt;
  final _Appeal? appeal;

  static _Sanction parse(dynamic raw) {
    if (raw is! Map<String, dynamic> ||
        raw['id'] is! int ||
        (raw['id'] as int) <= 0 ||
        raw['kind'] != 'restrict' ||
        raw['created_at'] is! String ||
        DateTime.tryParse(raw['created_at'] as String) == null ||
        !raw.containsKey('appeal')) {
      throw const FormatException();
    }
    return _Sanction(
      raw['id'] as int,
      raw['created_at'] as String,
      raw['appeal'] == null ? null : _Appeal.parse(raw['appeal']),
    );
  }
}
