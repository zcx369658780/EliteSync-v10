import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/personal_showcase_model.dart';

class PersonalShowcaseEntryCard extends StatelessWidget {
  const PersonalShowcaseEntryCard({
    super.key,
    required this.snapshot,
    required this.onPrimaryTap,
    required this.onPreviewTap,
    this.hasSavedPrivateDraft = false,
    this.reviewStatusLabel,
    this.reviewStatusVariant,
  });

  final PersonalShowcaseSnapshot snapshot;
  final VoidCallback onPrimaryTap;
  final VoidCallback onPreviewTap;
  final bool hasSavedPrivateDraft;
  final String? reviewStatusLabel;
  final AppTagVariant? reviewStatusVariant;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final suggestions = snapshot.checklist
        .where((item) => const ['自我介绍', '生活方式', '照片/头像'].contains(item.title))
        .take(3)
        .toList();
    final completedSignalCount = suggestions
        .where((item) => item.status == ShowcaseItemStatus.completed)
        .length;
    final reviewChipLabel =
        reviewStatusLabel == null || reviewStatusLabel == '私有草稿已保存'
        ? '已有私有草稿'
        : reviewStatusLabel!;
    return Container(
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.brandSecondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(t.radius.md),
                ),
                child: Icon(Icons.badge_outlined, color: t.brandSecondary),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '展示自己',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasSavedPrivateDraft
                          ? '${snapshot.readinessTitle}，可继续编辑私有草稿。'
                          : '${snapshot.readinessTitle}，先整理一版本地草稿。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onPreviewTap,
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('预览'),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          _ReadinessSignalLine(
            completion: snapshot.showcaseCompletion,
            completedSignalCount: completedSignalCount,
            totalSignalCount: suggestions.length,
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            snapshot.readinessHelper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          if (hasSavedPrivateDraft) ...[
            AppTag(
              label: reviewChipLabel,
              variant: reviewStatusVariant ?? AppTagVariant.success,
            ),
            SizedBox(height: t.spacing.sm),
          ],
          _LocalDraftBoundaryLine(text: snapshot.localDraft.boundary),
          if (suggestions.isNotEmpty) SizedBox(height: t.spacing.sm),
          if (suggestions.isNotEmpty)
            Column(
              children: suggestions
                  .map((item) => _ShowcaseSuggestionRow(item: item))
                  .toList(growable: false),
            ),
          SizedBox(height: t.spacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPrimaryTap,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text(hasSavedPrivateDraft ? '继续整理私有草稿' : '整理资料草稿'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessSignalLine extends StatelessWidget {
  const _ReadinessSignalLine({
    required this.completion,
    required this.completedSignalCount,
    required this.totalSignalCount,
  });

  final double completion;
  final int completedSignalCount;
  final int totalSignalCount;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final countLabel = totalSignalCount == 0
        ? '先从一条表达线索开始'
        : '已整理 $completedSignalCount / $totalSignalCount 条入口线索';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: t.secondarySurface.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 18, color: t.brandSecondary),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '准备线索',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  countLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: t.spacing.sm),
          SizedBox(
            width: 54,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(t.radius.pill),
              child: ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: completion,
                  minHeight: 6,
                  color: t.brandSecondary,
                  backgroundColor: t.overlay.withValues(alpha: 0.36),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalDraftBoundaryLine extends StatelessWidget {
  const _LocalDraftBoundaryLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: t.secondarySurface.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.pending_actions_outlined, size: 18, color: t.info),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: t.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseSuggestionRow extends StatelessWidget {
  const _ShowcaseSuggestionRow({required this.item});

  final ShowcaseChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.sm),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.sm,
          vertical: t.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: t.secondarySurface.withValues(alpha: 0.64),
          borderRadius: BorderRadius.circular(t.radius.md),
          border: Border.all(color: t.browseBorder),
        ),
        child: Row(
          children: [
            Icon(_statusIcon(item.status), size: 18, color: _statusColor(t)),
            SizedBox(width: t.spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: t.spacing.xs),
            AppTag(label: item.status.label, variant: _tagVariant(item.status)),
            SizedBox(width: t.spacing.xs),
            if (item.status != ShowcaseItemStatus.later)
              Text(
                '+ 去补充',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: t.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AppThemeTokens t) {
    return switch (item.status) {
      ShowcaseItemStatus.completed => t.success,
      ShowcaseItemStatus.available || ShowcaseItemStatus.empty => t.warning,
      ShowcaseItemStatus.later => t.textSecondary,
    };
  }

  IconData _statusIcon(ShowcaseItemStatus status) {
    return switch (status) {
      ShowcaseItemStatus.completed => Icons.check_circle_outline_rounded,
      ShowcaseItemStatus.available ||
      ShowcaseItemStatus.empty => Icons.add_circle_outline_rounded,
      ShowcaseItemStatus.later => Icons.schedule_rounded,
    };
  }

  AppTagVariant _tagVariant(ShowcaseItemStatus status) {
    return switch (status) {
      ShowcaseItemStatus.completed => AppTagVariant.success,
      ShowcaseItemStatus.available ||
      ShowcaseItemStatus.empty => AppTagVariant.warning,
      ShowcaseItemStatus.later => AppTagVariant.outlined,
    };
  }
}
