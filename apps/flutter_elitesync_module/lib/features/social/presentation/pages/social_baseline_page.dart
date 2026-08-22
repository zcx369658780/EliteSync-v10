import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/widgets/a5_relationship_understanding_card.dart';

class SocialBaselinePage extends StatefulWidget {
  const SocialBaselinePage({super.key});

  @override
  State<SocialBaselinePage> createState() => _SocialBaselinePageState();
}

class _SocialBaselinePageState extends State<SocialBaselinePage> {
  String _selectedIntention = '认真慢聊的人';
  String _selectedPlan = '周末轻活动';
  String? _preview;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return BrowseScaffold(
      header: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: t.textSecondary),
          ),
          Expanded(
            child: Text(
              '社交表达',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
        children: [
          AppInfoSectionCard(
            title: '社交表达预览',
            subtitle: '仅供编辑预览，不会公开发布或更改真实资料',
            leadingIcon: Icons.handshake_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '先把“我想认识谁、最近想做什么、适合怎样被打招呼”讲清楚，再决定是否进入 Match、Buddy 或 Chat。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChoiceChip(label: '草稿预览', selected: true),
                    AppChoiceChip(label: '可编辑草稿', selected: true),
                    AppChoiceChip(label: '不会自动发送', selected: true),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          const A5RelationshipUnderstandingCard(
            title: '怎样表达更自然',
            subtitle: '把关系目标、兴趣和玄学解释接成一句能说出口的话',
            icon: Icons.psychology_alt_outlined,
            summary: '把“我想认识谁”和“我适合怎样表达”连起来：先看摘要和不同角度，再看建议与注意事项。',
            dimensions: [
              A5UnderstandingDimension(
                title: '关系目标',
                label: '我想认识谁',
                body: '用慢聊、共同兴趣、长期关系可能等温和表达替代强标签。',
              ),
              A5UnderstandingDimension(
                title: '表达方式',
                label: '怎样被打招呼',
                body: '把星盘/八字/紫微提示转成生活化开场建议。',
              ),
              A5UnderstandingDimension(
                title: '下一步选择',
                label: '下一步',
                body: '可回到 Match、Buddy 或 Chat，不需要一次公开发布。',
              ),
            ],
            suggestions: ['先生成自我介绍草稿。', '把兴趣和关系节奏说清楚。'],
            avoidances: ['避免命运断言和一定会匹配的承诺。', '避免把反馈说成已经正式提交。'],
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '我想认识什么样的人',
            subtitle: '交友意图可以温和表达，不给关系贴死标签',
            leadingIcon: Icons.favorite_border_rounded,
            child: _ChoiceBlock(
              value: _selectedIntention,
              options: const ['认真慢聊的人', '共同兴趣伙伴', '先做朋友', '有长期关系意愿'],
              onSelected: (value) => setState(() => _selectedIntention = value),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '我最近想做什么',
            subtitle: '最近状态先作为表达线索，不是真实动态发布',
            leadingIcon: Icons.edit_calendar_outlined,
            child: _ChoiceBlock(
              value: _selectedPlan,
              options: const ['周末轻活动', '一起看电影', '自习打卡', '先线上慢聊'],
              onSelected: (value) => setState(() => _selectedPlan = value),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '自我介绍草稿',
            subtitle: '先生成草稿，暂不公开，后续再决定是否发布',
            leadingIcon: Icons.article_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '这不是动态发布入口，也不会上传隐私资料。你可以先查看自我介绍草稿，再手动编辑。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                AppChoiceChip(
                  label: '生成草稿预览',
                  leading: const Icon(Icons.auto_fix_high_outlined),
                  selected: true,
                  onTap: () => setState(() {
                    _preview =
                        '我最近更想认识$_selectedIntention，也想从$_selectedPlan开始。比起很快下判断，我更希望先聊得舒服一点。';
                  }),
                ),
                if (_preview != null) ...[
                  SizedBox(height: t.spacing.sm),
                  _SoftPanel(text: _preview!),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '这份草稿不会公开发布、不会写入正式资料记录，也不会触发真实通知。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '标签表达',
            subtitle: '标签帮助理解，不作为确定判断',
            leadingIcon: Icons.local_offer_outlined,
            child: const _TagSections(),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '接下来可以做什么',
            subtitle: '按你的意愿返回匹配、搭子、聊天或体验反馈',
            leadingIcon: Icons.notifications_none_rounded,
            child: const _ReturnFlowList(),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '记录体验感受',
            subtitle: '记录这次体验感受，方便后续优化参考',
            leadingIcon: Icons.rate_review_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChoiceBlock(
                  value: _feedback ?? '',
                  options: const ['哪里看不懂', '推荐不合适', '聊天有压力', '想要更多搭子'],
                  onSelected: (value) => setState(() => _feedback = value),
                ),
                if (_feedback != null) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '已记录本次体验感受：$_feedback。不会自动发送、改写资料或改变匹配结果。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '安全与非目标',
            subtitle: '保持慢约会边界',
            leadingIcon: Icons.shield_outlined,
            child: const _SafetyList(),
          ),
        ],
      ),
    );
  }
}

class _ChoiceBlock extends StatelessWidget {
  const _ChoiceBlock({
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          AppChoiceChip(
            label: option,
            selected: value == option,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.sm),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: t.textPrimary, height: 1.5),
        ),
      ),
    );
  }
}

class _TagSections extends StatelessWidget {
  const _TagSections();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const sections = <String, List<String>>{
      '关系目标': ['慢慢了解', '长期关系可能', '先做朋友'],
      '兴趣方向': ['电影', '学习', '散步', '轻运动'],
      '生活节奏': ['工作日慢聊', '周末见面', '先线上'],
      '慢约会表达': ['不催回复', '尊重边界', '公共场所优先'],
      '搭子偏好': ['预算 AA 先说清', '非速约', '共同目标'],
      '适合开启的话题': ['最近状态', '共同兴趣', '周末安排'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in sections.entries) ...[
          Text(
            entry.key,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in entry.value)
                AppChoiceChip(label: label, selected: true),
            ],
          ),
          SizedBox(height: t.spacing.sm),
        ],
        Text(
          '这些标签只是表达建议，不会更改资料、星盘或画像，也不会改变匹配结果。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _ReturnFlowList extends StatelessWidget {
  const _ReturnFlowList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlowLine(text: '匹配即将揭晓：回到 Match 看本轮节奏。'),
        _FlowLine(text: 'Buddy 候选已生成：回到搭子页看有限候选。'),
        _FlowLine(text: '聊天可以从容继续：回到聊天页手动编辑草稿。'),
        _FlowLine(text: '活动后可记录主观感受：不会自动提交或公开。'),
      ],
    );
  }
}

class _SafetyList extends StatelessWidget {
  const _SafetyList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlowLine(text: '不做真实动态发布、关注制社交、礼物商城或自动代聊。'),
        _FlowLine(text: '不自动发送聊天，不写真实消息记录。'),
        _FlowLine(text: '不做真实通知推送，不声称反馈已正式提交。'),
        _FlowLine(text: '不展示精确实时位置，也不会更改资料、星盘或画像。'),
      ],
    );
  }
}

class _FlowLine extends StatelessWidget {
  const _FlowLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: t.brandPrimary,
          ),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
