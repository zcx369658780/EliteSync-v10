import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class InnerTestFeedbackPage extends StatefulWidget {
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
  State<InnerTestFeedbackPage> createState() => _InnerTestFeedbackPageState();
}

class _InnerTestFeedbackPageState extends State<InnerTestFeedbackPage> {
  late InnerTestFeedbackCategory _category;
  late String _sourceLabel;
  final TextEditingController _contentController = TextEditingController();
  String _draft = '';

  @override
  void initState() {
    super.initState();
    _category = innerTestFeedbackCategoryById(widget.initialCategoryId);
    _sourceLabel = innerTestFeedbackSourceLabel(widget.sourceSurface);
  }

  @override
  void dispose() {
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
              subtitle: '把你遇到的问题或建议整理成一份可复制反馈',
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
                    '边界说明：本页内容用于本地整理与沟通，不会自动改资料、星盘、匹配结果或推荐权重。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '复制后发给支持人员继续跟进。',
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
