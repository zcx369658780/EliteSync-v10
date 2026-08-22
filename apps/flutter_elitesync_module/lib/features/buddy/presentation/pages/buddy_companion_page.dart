import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/widgets/a5_relationship_understanding_card.dart';

enum BuddyType { study, movie, meal, fitness }

extension BuddyTypeCopy on BuddyType {
  String get title => switch (this) {
    BuddyType.study => '学习搭子',
    BuddyType.movie => '电影搭子',
    BuddyType.meal => '吃饭搭子',
    BuddyType.fitness => '健身搭子',
  };

  String get subtitle => switch (this) {
    BuddyType.study => '一起自习、备考或线上打卡',
    BuddyType.movie => '先对齐片类偏好和观影后交流',
    BuddyType.meal => '把口味、预算和 AA 先说清',
    BuddyType.fitness => '尊重体能差异，只做互相陪伴',
  };

  IconData get icon => switch (this) {
    BuddyType.study => Icons.menu_book_rounded,
    BuddyType.movie => Icons.movie_filter_rounded,
    BuddyType.meal => Icons.restaurant_rounded,
    BuddyType.fitness => Icons.fitness_center_rounded,
  };

  Color get accent => switch (this) {
    BuddyType.study => const Color(0xFF5DA8FF),
    BuddyType.movie => const Color(0xFF8C7BFF),
    BuddyType.meal => const Color(0xFFFFA85C),
    BuddyType.fitness => const Color(0xFF49C99A),
  };

  String get targetHint => switch (this) {
    BuddyType.study => '完成一段 90 分钟专注学习',
    BuddyType.movie => '找一位同片类偏好的轻松观影伙伴',
    BuddyType.meal => '周末找一家公共餐厅轻松吃顿饭',
    BuddyType.fitness => '找一位节奏接近的运动打卡伙伴',
  };

  List<String> get fieldTags => switch (this) {
    BuddyType.study => ['目标', '时间', '公共学习空间', '学习方向', '监督强度'],
    BuddyType.movie => ['片类偏好', '时间', '地点语义', '交流意愿'],
    BuddyType.meal => ['口味', '预算', '位置', '时间', 'AA 偏好'],
    BuddyType.fitness => ['运动类型', '强度', '时段', '地点'],
  };
}

class BuddyCompanionPage extends StatefulWidget {
  const BuddyCompanionPage({super.key});

  @override
  State<BuddyCompanionPage> createState() => _BuddyCompanionPageState();
}

class _BuddyCompanionPageState extends State<BuddyCompanionPage> {
  BuddyType _type = BuddyType.study;
  String _time = '本周末白天';
  String _place = '线上或公共空间';
  String _intensity = '轻松交流';
  String? _feedback;

  List<_BuddyCandidate> get _candidates => _mockCandidates[_type]!;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return BrowseScaffold(
      header: SizedBox(
        height: 44,
        child: Row(
          children: [
            Text(
              '搭子',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
        children: [
          const PageTitleRail(
            title: '搭子精准陪伴',
            subtitle: '从共同兴趣和共同目标开始认识人，不替代婚恋匹配，也不是速约或陪玩。',
          ),
          SizedBox(height: t.spacing.md),
          _PositioningCard(onOpenSafety: _scrollToSafetyHint),
          SizedBox(height: t.spacing.md),
          const A5RelationshipUnderstandingCard(
            title: '搭子活动适配提示',
            subtitle: '把共同兴趣解释成低压力相处方式',
            icon: Icons.diversity_1_outlined,
            summary: '搭子解释只帮助你判断活动是否舒服：共同目标、时间地点和边界比“立刻推进关系”更重要。',
            dimensions: [
              A5UnderstandingDimension(
                title: '共同点',
                label: '一起做什么',
                body: '先看活动目标是否接近，例如学习、电影、吃饭或健身。',
              ),
              A5UnderstandingDimension(
                title: '节奏',
                label: '什么时候',
                body: '用时间和交流强度判断是否适合低压开始。',
              ),
              A5UnderstandingDimension(
                title: '边界',
                label: '怎样更舒服',
                body: '预算、AA、公共场所和结束时间要先说清。',
              ),
            ],
            suggestions: ['先确认共同目标和公共场所。', '把活动反馈当作主观体验记录。'],
            avoidances: ['避免把搭子做成速约。', '避免把反馈变成人格或婚恋结论。'],
          ),
          SizedBox(height: t.spacing.md),
          _BuddyTypeSelector(
            selected: _type,
            onSelected: (type) => setState(() {
              _type = type;
              _feedback = null;
            }),
          ),
          SizedBox(height: t.spacing.md),
          _DemandCardForm(
            type: _type,
            time: _time,
            place: _place,
            intensity: _intensity,
            onTimeChanged: (value) => setState(() => _time = value),
            onPlaceChanged: (value) => setState(() => _place = value),
            onIntensityChanged: (value) => setState(() => _intensity = value),
          ),
          SizedBox(height: t.spacing.md),
          _DemandPreviewCard(
            type: _type,
            time: _time,
            place: _place,
            intensity: _intensity,
          ),
          SizedBox(height: t.spacing.md),
          _CandidateSection(
            candidates: _candidates,
            onChatDraft: _showManualChatDraft,
            onReport: _showLocalReportNotice,
          ),
          SizedBox(height: t.spacing.md),
          _FeedbackCard(
            feedback: _feedback,
            onFeedback: (value) => setState(() => _feedback = value),
          ),
          SizedBox(height: t.spacing.md),
          const _SafetyCard(key: ValueKey('buddy-safety-card')),
        ],
      ),
    );
  }

  void _scrollToSafetyHint() {
    AppFeedback.showInfo(context, '安全提示在页面底部，当前版本仅展示本地说明');
  }

  Future<void> _showManualChatDraft(_BuddyCandidate candidate) async {
    final t = context.appTokens;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          0,
          t.spacing.pageHorizontal,
          t.spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '手动开启聊天',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: t.spacing.xs),
            Text(
              '这是可编辑草稿，必须由你确认后再发送；当前不会写入真实消息记录。',
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: t.spacing.sm),
            AppCard(
              backgroundColor: t.browseSurface,
              child: Text(
                '你好 ${candidate.name}，我看到我们都适合${candidate.sharedGoal}。如果你也愿意，我们可以先把时间、预算和边界说清，再决定要不要一起参与。',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: t.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
            SizedBox(height: t.spacing.md),
            AppPrimaryButton(
              label: '我知道，需要手动发送',
              prefixIcon: const Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocalReportNotice(_BuddyCandidate candidate) {
    AppFeedback.showInfo(context, '${candidate.name} 的举报/拉黑入口为展示状态，当前不提交服务端');
  }
}

class _PositioningCard extends StatelessWidget {
  const _PositioningCard({required this.onOpenSafety});

  final VoidCallback onOpenSafety;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake_rounded, color: t.brandPrimary),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Text(
                  '共同兴趣陪伴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '搭子帮助你从低压力共同活动开始认识人。推荐数量有限，先看共同目标、时间、地点语义和边界是否接近。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: const [
              _BoundaryPill(label: '共同目标'),
              _BoundaryPill(label: '边界清楚'),
              _BoundaryPill(label: '公共场所优先'),
              _BoundaryPill(label: '手动开启聊天'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          AppSecondaryButton(
            label: '查看安全边界',
            prefixIcon: Icon(Icons.shield_outlined, color: t.textPrimary),
            onPressed: onOpenSafety,
          ),
        ],
      ),
    );
  }
}

class _BoundaryPill extends StatelessWidget {
  const _BoundaryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xs,
        vertical: t.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: t.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.pill),
        border: Border.all(color: t.brandPrimary.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: t.brandPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BuddyTypeSelector extends StatelessWidget {
  const _BuddyTypeSelector({required this.selected, required this.onSelected});

  final BuddyType selected;
  final ValueChanged<BuddyType> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择搭子类型',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: t.spacing.sm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: t.spacing.sm,
          mainAxisSpacing: t.spacing.sm,
          childAspectRatio: 1.12,
          children: [
            for (final type in BuddyType.values)
              _BuddyTypeCard(
                type: type,
                selected: type == selected,
                onTap: () => onSelected(type),
              ),
          ],
        ),
      ],
    );
  }
}

class _BuddyTypeCard extends StatelessWidget {
  const _BuddyTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final BuddyType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(t.spacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? type.accent.withValues(alpha: 0.12)
                : t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(
              color: selected
                  ? type.accent.withValues(alpha: 0.40)
                  : t.browseBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(type.icon, color: type.accent),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: type.accent),
                ],
              ),
              const Spacer(),
              Text(
                type.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: t.spacing.xxs),
              Text(
                type.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemandCardForm extends StatelessWidget {
  const _DemandCardForm({
    required this.type,
    required this.time,
    required this.place,
    required this.intensity,
    required this.onTimeChanged,
    required this.onPlaceChanged,
    required this.onIntensityChanged,
  });

  final BuddyType type;
  final String time;
  final String place;
  final String intensity;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onPlaceChanged;
  final ValueChanged<String> onIntensityChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '需求卡填写',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '先表达目标、时间、地点语义、交流强度和安全偏好；首版只在本机展示。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _OptionGroup(
            title: '希望什么时候',
            values: const ['本周末白天', '工作日晚上', '午休或下班后'],
            selected: time,
            onSelected: onTimeChanged,
          ),
          SizedBox(height: t.spacing.sm),
          _OptionGroup(
            title: '希望在哪里或线上',
            values: const ['线上或公共空间', '同城商圈', '熟悉的公共场所'],
            selected: place,
            onSelected: onPlaceChanged,
          ),
          SizedBox(height: t.spacing.sm),
          _OptionGroup(
            title: '我能接受的交流强度',
            values: const ['轻松交流', '安静陪伴', '活动后再聊'],
            selected: intensity,
            onSelected: onIntensityChanged,
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              for (final tag in type.fieldTags) _BoundaryPill(label: tag),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.title,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: t.spacing.xs),
        Wrap(
          spacing: t.spacing.xs,
          runSpacing: t.spacing.xs,
          children: [
            for (final value in values)
              AppChoiceChip(
                label: value,
                selected: value == selected,
                onTap: () => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _DemandPreviewCard extends StatelessWidget {
  const _DemandPreviewCard({
    required this.type,
    required this.time,
    required this.place,
    required this.intensity,
  });

  final BuddyType type;
  final String time;
  final String place;
  final String intensity;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: type.accent.withValues(alpha: 0.08),
      border: Border.all(color: type.accent.withValues(alpha: 0.18)),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '需求卡预览',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '我想找${type.title}：${type.targetHint}。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '时间：$time；地点：$place；交流强度：$intensity。安全偏好：公共场所优先，预算、AA、时间和边界先说清。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '已生成需求卡：本地/mock 展示，不发布到服务端。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateSection extends StatelessWidget {
  const _CandidateSection({
    required this.candidates,
    required this.onChatDraft,
    required this.onReport,
  });

  final List<_BuddyCandidate> candidates;
  final ValueChanged<_BuddyCandidate> onChatDraft;
  final ValueChanged<_BuddyCandidate> onReport;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本地候选推荐',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: t.spacing.xxs),
        Text(
          '仅展示 ${candidates.length} 位 mock 候选，保持克制，不提供无限浏览。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
        SizedBox(height: t.spacing.sm),
        for (final candidate in candidates) ...[
          _CandidateCard(
            candidate: candidate,
            onChatDraft: () => onChatDraft(candidate),
            onReport: () => onReport(candidate),
          ),
          SizedBox(height: t.spacing.sm),
        ],
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.onChatDraft,
    required this.onReport,
  });

  final _BuddyCandidate candidate;
  final VoidCallback onChatDraft;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: candidate.accent.withValues(alpha: 0.14),
                child: Text(
                  candidate.name.characters.first,
                  style: TextStyle(
                    color: candidate.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      candidate.summary,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '为什么推荐',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          ...candidate.reasons.map(
            (reason) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: candidate.accent,
                  ),
                  SizedBox(width: t.spacing.xs),
                  Expanded(
                    child: Text(
                      reason,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  label: '手动聊天入口',
                  prefixIcon: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onChatDraft,
                ),
              ),
              SizedBox(width: t.spacing.sm),
              AppSecondaryButton(
                label: '举报/拉黑',
                prefixIcon: Icon(Icons.flag_outlined, color: t.textPrimary),
                onPressed: onReport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback, required this.onFeedback});

  final String? feedback;
  final ValueChanged<String> onFeedback;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活动后主观反馈',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '反馈只作为本机回看姿态，不声称正式持久化，也不实时训练算法或反写资料记录。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AppChoiceChip(
                label: '节奏舒服',
                selected: feedback == '节奏舒服',
                onTap: () => onFeedback('节奏舒服'),
              ),
              AppChoiceChip(
                label: '边界清楚',
                selected: feedback == '边界清楚',
                onTap: () => onFeedback('边界清楚'),
              ),
              AppChoiceChip(
                label: '下次再说',
                selected: feedback == '下次再说',
                onTap: () => onFeedback('下次再说'),
              ),
            ],
          ),
          if (feedback != null) ...[
            SizedBox(height: t.spacing.sm),
            Text(
              '已记录本机主观反馈：$feedback',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const items = [
      '初次线下建议公共场所，避免私密地点默认邀约。',
      '不展示精确实时位置，只表达城市、商圈或线上偏好。',
      '预算、时间、AA 和活动边界先说清。',
      '遇到不舒服可以结束聊天，也可以使用举报/拉黑展示入口。',
    ];
    return AppCard(
      backgroundColor: t.warning.withValues(alpha: 0.08),
      border: Border.all(color: t.warning.withValues(alpha: 0.22)),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: t.warning),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Text(
                  '安全与边界',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: t.warning),
                  SizedBox(width: t.spacing.xs),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BuddyCandidate {
  const _BuddyCandidate({
    required this.name,
    required this.summary,
    required this.sharedGoal,
    required this.reasons,
    required this.accent,
  });

  final String name;
  final String summary;
  final String sharedGoal;
  final List<String> reasons;
  final Color accent;
}

const _mockCandidates = <BuddyType, List<_BuddyCandidate>>{
  BuddyType.study: [
    _BuddyCandidate(
      name: '林一',
      summary: '考证复习 · 周末白天 · 安静陪伴',
      sharedGoal: '在公共学习空间完成专注学习',
      accent: Color(0xFF5DA8FF),
      reasons: [
        '共同目标接近：都希望完成一段清晰学习任务。',
        '时间合适：偏本周末白天，不需要临时赶场。',
        '边界相近：安静陪伴，监督强度不过高。',
      ],
    ),
    _BuddyCandidate(
      name: '阿芷',
      summary: '线上打卡 · 工作日晚 · 轻提醒',
      sharedGoal: '线上互相打卡和复盘',
      accent: Color(0xFF5DA8FF),
      reasons: [
        '共同兴趣接近：都关注持续学习和复盘。',
        '地点语义匹配：线上优先，不暴露具体位置。',
        '交流强度接近：轻提醒，不强监督。',
      ],
    ),
  ],
  BuddyType.movie: [
    _BuddyCandidate(
      name: '小满',
      summary: '剧情片 · 周末下午 · 观后再聊',
      sharedGoal: '轻松看一部剧情片',
      accent: Color(0xFF8C7BFF),
      reasons: [
        '共同兴趣接近：都偏剧情片和轻讨论。',
        '时间合适：周末下午更容易从容安排。',
        '边界清楚：不默认私密观影，先公共影院。',
      ],
    ),
    _BuddyCandidate(
      name: '岑野',
      summary: '动画/科幻 · 工作日晚 · 低压讨论',
      sharedGoal: '找一部轻松片单一起看',
      accent: Color(0xFF8C7BFF),
      reasons: [
        '片类偏好接近：动画和科幻都有重叠。',
        '节奏匹配：先看完再聊，不强行线下。',
        '交流强度接近：低压讨论，不做情绪逼近。',
      ],
    ),
  ],
  BuddyType.meal: [
    _BuddyCandidate(
      name: '南乔',
      summary: '清淡口味 · 预算清楚 · AA 优先',
      sharedGoal: '找公共餐厅轻松吃顿饭',
      accent: Color(0xFFFFA85C),
      reasons: [
        '共同目标接近：都希望先轻松吃饭再决定是否继续聊。',
        '预算边界清楚：愿意提前对齐 AA 和范围。',
        '地点语义匹配：公共餐厅优先，不暴露精确位置。',
      ],
    ),
    _BuddyCandidate(
      name: '予安',
      summary: '周末探店 · 可提前订位 · 轻松交流',
      sharedGoal: '在熟悉商圈找一家餐厅',
      accent: Color(0xFFFFA85C),
      reasons: ['共同兴趣接近：都愿意从口味和餐厅氛围开始。', '时间匹配：周末安排更从容。', '边界相近：先说清预算和结束时间。'],
    ),
  ],
  BuddyType.fitness: [
    _BuddyCandidate(
      name: '言川',
      summary: '跑步打卡 · 中低强度 · 尊重节奏',
      sharedGoal: '完成一次轻量运动打卡',
      accent: Color(0xFF49C99A),
      reasons: [
        '共同目标接近：都想稳定运动而不是互相比较。',
        '强度匹配：中低强度，更适合首次搭子。',
        '边界清楚：尊重体能差异，不做身体评价。',
      ],
    ),
    _BuddyCandidate(
      name: '若晴',
      summary: '健身房 · 晚间时段 · 安静陪练',
      sharedGoal: '按各自计划完成一轮训练',
      accent: Color(0xFF49C99A),
      reasons: ['地点语义匹配：公共健身空间优先。', '节奏接近：偏晚间，不急于临时约定。', '交流强度相近：安静陪练，活动后再复盘。'],
    ),
  ],
};
