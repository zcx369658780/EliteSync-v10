import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/feedback/domain/inner_test_feedback_category.dart';

typedef ClipboardWriter = Future<bool> Function(String text);

Future<bool> _writeClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  return true;
}

class InnerTestFeedbackPage extends ConsumerStatefulWidget {
  const InnerTestFeedbackPage({
    super.key,
    this.initialCategoryId,
    this.sourceSurface,
    this.clipboardWriter = _writeClipboard,
  });

  final String? initialCategoryId;
  final String? sourceSurface;
  final ClipboardWriter clipboardWriter;

  @override
  ConsumerState<InnerTestFeedbackPage> createState() =>
      _InnerTestFeedbackPageState();
}

class _InnerTestFeedbackPageState extends ConsumerState<InnerTestFeedbackPage> {
  late InnerTestFeedbackCategory _category;
  late String _sourceLabel;
  final TextEditingController _contentController = TextEditingController();
  String _draft = '';
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _detail;
  Map<String, dynamic>? _pending;
  int? _next;
  int? _owner;
  int _operation = 0;
  bool _busy = false;
  bool _denied = false;
  String? _message;
  late final ProviderSubscription<AsyncValue<SessionState>>
  _sessionSubscription;
  late final ProviderSubscription<int> _authoritySubscription;

  @override
  void initState() {
    super.initState();
    _category = innerTestFeedbackCategoryById(widget.initialCategoryId);
    _sourceLabel = innerTestFeedbackSourceLabel(widget.sourceSurface);
    _sessionSubscription = ref.listenManual(sessionProvider, (before, after) {
      final previous = before?.asData?.value;
      final current = after.asData?.value;
      final owner = current?.isLoggedIn == true ? current?.user?.id : null;
      if (_owner == owner && previous?.accessToken == current?.accessToken) {
        return;
      }
      final changedOwner = _owner != owner;
      _owner = owner;
      setState(() {
        _invalidateProjection();
        if (changedOwner) {
          _contentController.clear();
          _draft = '';
          _pending = null;
          _category = innerTestFeedbackCategoryById(widget.initialCategoryId);
        }
      });
      if (owner != null) Future.microtask(_readHistory);
    }, fireImmediately: true);
    _authoritySubscription = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (before, after) {
        if (before == after) return;
        setState(_invalidateProjection);
      },
    );
  }

  void _invalidateProjection() {
    _operation++;
    _history = [];
    _detail = null;
    _next = null;
    _busy = false;
    _denied = false;
    _message = null;
  }

  bool _current(int operation, String? token, int authority) =>
      mounted &&
      operation == _operation &&
      token == ref.read(sessionProvider).asData?.value.accessToken &&
      authority == ref.read(relationshipAuthorityEpochProvider);

  void _failure(Object error, {required bool submitting}) {
    final code = error is RelationshipFailure ? error.statusCode : null;
    if ([401, 403, 404, 410].contains(code)) {
      _history = [];
      _detail = null;
      _next = null;
      _denied = true;
      _message = '当前账号暂不能使用此反馈记录，请核对权限后重新读取。';
    } else if (submitting && code == 422) {
      _pending = null;
      _message = '输入校验未通过，填写内容已保留，请修正后提交。';
    } else if (submitting && code == 409) {
      _message = '原提交编号与记录冲突，请保留当前内容并核对本人回执。';
    } else {
      _message = submitting
          ? '提交结果尚未确认，可重试原提交或读取本人记录。当前填写已保留。'
          : '反馈记录读取失败，可重新读取。当前填写已保留。';
    }
  }

  Future<void> _readHistory({bool more = false, int? id}) async {
    if (_busy || _owner == null) return;
    final operation = ++_operation;
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    final authority = ref.read(relationshipAuthorityEpochProvider);
    setState(() {
      _busy = true;
      _message = null;
      if (id != null) _detail = null;
    });
    try {
      final suffix = id != null
          ? '/$id'
          : more && _next != null
          ? '?before_id=$_next'
          : '';
      final result = await ref
          .read(relationshipApiProvider)
          .call('GET', '/support/feedback$suffix');
      if (!_current(operation, token, authority)) return;
      setState(() {
        _denied = false;
        if (id != null) {
          if (result['feedback'] is! Map) {
            throw const RelationshipFailure('Invalid feedback detail');
          }
          _detail = Map<String, dynamic>.from(result['feedback'] as Map);
        } else {
          if (result['items'] is! List) {
            throw const RelationshipFailure('Invalid feedback list');
          }
          final incoming = rows(result['items']);
          final known = more
              ? _history.map((row) => row['id']).toSet()
              : <dynamic>{};
          _history = [
            if (more) ..._history,
            ...incoming.where((row) => !known.contains(row['id'])),
          ];
          _next = (result['next_before_id'] as num?)?.toInt();
        }
      });
    } catch (error) {
      if (_current(operation, token, authority)) {
        setState(() => _failure(error, submitting: false));
      }
    } finally {
      if (_current(operation, token, authority)) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_busy || _owner == null || _denied) return;
    if (_pending == null && _contentController.text.trim().isEmpty) {
      setState(() => _message = '请填写反馈内容。');
      return;
    }
    const sources = {
      'settings',
      'version_center',
      'profile',
      'match',
      'buddy',
      'astro',
      'ziwei',
    };
    final command = _pending ??= {
      'request_key': const Uuid().v4(),
      'source': sources.contains(widget.sourceSurface)
          ? widget.sourceSurface
          : 'feedback',
      'category': _category.id,
      'content': _contentController.text.trim(),
    };
    final operation = ++_operation;
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    final authority = ref.read(relationshipAuthorityEpochProvider);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final api = ref.read(relationshipApiProvider);
      final submitted = await api.call(
        'POST',
        '/support/feedback',
        Map<String, dynamic>.from(command),
      );
      if (!_current(operation, token, authority)) return;
      final receipt = submitted['feedback'];
      final id = receipt is Map ? receipt['id'] : null;
      if (id is! int) {
        throw const RelationshipFailure('Invalid feedback receipt');
      }
      final persisted = await api.call('GET', '/support/feedback/$id');
      if (!_current(operation, token, authority)) return;
      if (persisted['feedback'] is! Map) {
        throw const RelationshipFailure('Invalid feedback detail');
      }
      final detail = Map<String, dynamic>.from(persisted['feedback'] as Map);
      if (detail['id'] != id || detail['content'] != command['content']) {
        throw const RelationshipFailure('Feedback receipt not confirmed');
      }
      setState(() {
        _pending = null;
        _detail = detail;
        _message = '提交回执 #$id 已确认。';
        if (_contentController.text.trim() == command['content'] &&
            _category.id == command['category']) {
          _contentController.clear();
          _draft = '';
        }
      });
    } catch (error) {
      if (_current(operation, token, authority)) {
        setState(() => _failure(error, submitting: true));
      }
    } finally {
      if (_current(operation, token, authority)) setState(() => _busy = false);
    }
  }

  String _statusLabel(Object? value) => switch (value) {
    'OPEN' => '已接收',
    'IN_REVIEW' => '处理中',
    'RESOLVED' => '已解决',
    'CLOSED' => '已关闭',
    _ => '状态待读取',
  };

  @override
  void dispose() {
    _sessionSubscription.close();
    _authoritySubscription.close();
    _operation++;
    _contentController.dispose();
    super.dispose();
  }

  void _selectCategory(InnerTestFeedbackCategory category) {
    setState(() {
      _category = category;
      _draft = '';
    });
  }

  void _generateDraft() {
    final content = _contentController.text.trim();
    final text = [
      'EliteSync 体验反馈',
      '来源：$_sourceLabel',
      '类别：${_category.label}',
      if (content.isNotEmpty) '反馈内容：$content' else '反馈内容：待补充',
      '边界：这是一份本地可复制反馈，不会自动改资料、星盘、匹配结果或推荐权重。',
      if (_category.id == 'ziwei_flying_star_oracle')
        '紫微显示提示：请尽量补充宫位、方向、对照结果和截图来源。',
    ].join('\n');
    setState(() => _draft = text);
  }

  Future<void> _copyDraft() async {
    if (_draft.trim().isEmpty) {
      _generateDraft();
    }
    final text = _draft.trim().isNotEmpty ? _draft : '';
    if (text.isEmpty) return;
    try {
      final copied = await widget.clipboardWriter(text);
      if (!mounted) return;
      if (copied) {
        AppFeedback.showSuccess(context, '已复制反馈内容');
      } else {
        AppFeedback.showInfo(context, '复制未完成，请稍后重试');
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.showInfo(context, '复制未完成，请稍后重试');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return AppScaffold(
      appBar: const AppTopBar(title: '体验反馈', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '帮我们改进体验',
              subtitle: '提交反馈并查看本人回执和处理状态',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 55),
            child: AppInfoSectionCard(
              title: '反馈类别',
              subtitle: _sourceLabel,
              leadingIcon: _category.icon,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: innerTestFeedbackCategories
                    .map((category) {
                      return AppChoiceChip(
                        label: category.label,
                        selected: category.id == _category.id,
                        leading: Icon(category.icon),
                        onTap: () => _selectCategory(category),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 80),
            child: AppInfoSectionCard(
              title: '反馈内容',
              subtitle: _category.description,
              leadingIcon: Icons.edit_note_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _contentController,
                    label: '你想反馈什么？',
                    hint: '例如：紫微飞星线条方向和参考截图不一致，可以写下页面位置和截图来源。',
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 800,
                    onChanged: (_) {
                      if (_draft.isNotEmpty) {
                        setState(() => _draft = '');
                      }
                    },
                  ),
                  SizedBox(height: t.spacing.sm),
                  const Text('提交内容仅本人和获授权支持管理员可读。请填写最少必要信息。'),
                  if (_busy) const LinearProgressIndicator(),
                  if (_message != null)
                    Text(_message!, key: const Key('support-message')),
                  if (_owner == null) const Text('登录后可提交和读取本人反馈。'),
                  FilledButton(
                    key: const Key('support-submit'),
                    onPressed: _busy || _owner == null || _denied
                        ? null
                        : _submit,
                    child: Text(_pending == null ? '提交反馈' : '重试原提交并确认回执'),
                  ),
                  OutlinedButton(
                    key: const Key('support-history'),
                    onPressed: _busy || _owner == null ? null : _readHistory,
                    child: const Text('读取本人提交记录'),
                  ),
                  for (final item in _history)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _readHistory(id: (item['id'] as num).toInt()),
                      child: Text(
                        '反馈 #${item['id']} · ${_statusLabel(item['status'])} · ${item['updated_at'] ?? ''}',
                      ),
                    ),
                  if (_next != null)
                    TextButton(
                      onPressed: _busy ? null : () => _readHistory(more: true),
                      child: const Text('加载更早反馈'),
                    ),
                  if (_detail != null) ...[
                    Text(
                      '反馈 #${_detail!['id']} · ${_statusLabel(_detail!['status'])} · 版本 ${_detail!['revision']}',
                    ),
                    SelectableText('${_detail!['content'] ?? ''}'),
                    if (_detail!['public_reply'] != null)
                      SelectableText('支持回复 ${_detail!['public_reply']}'),
                    for (final update in rows(_detail!['updates']))
                      Text(
                        '${update['created_at']} · ${_statusLabel(update['status'])}${update['public_reply'] == null ? '' : '\n${update['public_reply']}'}',
                      ),
                  ],
                  const Divider(),
                  AppPrimaryButton(
                    label: '生成反馈草稿',
                    prefixIcon: const Icon(Icons.description_outlined),
                    onPressed: _generateDraft,
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppSecondaryButton(
                    label: '复制反馈内容',
                    fullWidth: true,
                    style: AppSecondaryButtonStyle.outline,
                    prefixIcon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: _copyDraft,
                  ),
                  SizedBox(height: t.spacing.md),
                  Text(
                    '反馈不会自动改资料、星盘、匹配结果或推荐权重。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '生成和复制草稿仅保存在本机。点击提交并确认回执后，可在本人记录中查看处理状态。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_draft.isNotEmpty) ...[
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 30),
              child: AppInfoSectionCard(
                title: '反馈草稿已生成',
                subtitle: '已整理为本地可复制反馈',
                leadingIcon: Icons.task_alt_rounded,
                child: SelectableText(
                  _draft,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textPrimary,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
