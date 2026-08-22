import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_draft_ui_state.dart';

class ProfileShowcaseReviewFixturePage extends StatelessWidget {
  const ProfileShowcaseReviewFixturePage({super.key});

  static const statuses = [
    'pending',
    'approved',
    'rejected',
    'needs_revision',
    'manual_review_required',
    'error',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return BrowseScaffold(
      header: Row(
        children: [
          IconButton(
            tooltip: '返回',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: t.textPrimary),
          ),
          SizedBox(width: t.spacing.sm),
          Expanded(
            child: Text(
              '私有草稿审核状态夹具',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: t.spacing.huge),
        children: [
          _FixtureIntro(),
          SizedBox(height: t.spacing.md),
          ...statuses.map((status) {
            final state = _stateFor(status);
            return Padding(
              padding: EdgeInsets.only(bottom: t.spacing.sm),
              child: _ReviewFixtureCard(status: status, state: state),
            );
          }),
        ],
      ),
    );
  }
}

class _FixtureIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTag(label: 'DEBUG ONLY', variant: AppTagVariant.warning),
          SizedBox(height: t.spacing.sm),
          Text(
            '仅用于本地设备截图覆盖',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '这些状态来自 Flutter 本地夹具，不读取后端、不写入资料、不发布展示，也不会进入推荐评分。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewFixtureCard extends StatelessWidget {
  const _ReviewFixtureCard({required this.status, required this.state});

  final String status;
  final ProfileShowcaseDraftUiState state;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final title = switch (status) {
      'pending' => 'Pending / 等待审核',
      'approved' => 'Approved / 审核通过',
      'rejected' => 'Rejected / 审核未通过',
      'needs_revision' => 'Needs Revision / 需要修改',
      'manual_review_required' => 'Manual Review / 人工复核',
      'error' => 'Error Fallback / 状态不可用',
      _ => status,
    };

    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_outlined, color: _statusColor(t)),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Text(
                      state.statusLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              AppTag(
                label: state.compactReviewLabel,
                variant: _statusTagVariant(status),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          _BoundaryBox(text: state.boundaryText),
          SizedBox(height: t.spacing.sm),
          _BoundaryBox(text: state.ctaGuidanceText),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const AppTag(label: '仅私有草稿', variant: AppTagVariant.outlined),
              const AppTag(label: '不会公开展示', variant: AppTagVariant.outlined),
              const AppTag(label: '不会用于推荐评分', variant: AppTagVariant.outlined),
              AppTag(label: '状态：$status', variant: AppTagVariant.neutral),
              AppTag(
                label: state.isPendingReview || state.hasReviewResult
                    ? 'CTA：刷新审核状态'
                    : 'CTA：重新读取',
                variant: AppTagVariant.outlined,
              ),
              AppTag(
                label: '提交：${state.submitCtaLabel}',
                variant: state.canSubmitForReview
                    ? AppTagVariant.success
                    : AppTagVariant.neutral,
              ),
              AppTag(
                label: state.canSubmitForReview ? '提交可用' : '提交禁用',
                variant: state.canSubmitForReview
                    ? AppTagVariant.success
                    : AppTagVariant.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(AppThemeTokens t) {
    return switch (status) {
      'approved' => t.success,
      'rejected' || 'needs_revision' || 'error' => t.warning,
      'manual_review_required' => t.brandSecondary,
      _ => t.info,
    };
  }
}

class _BoundaryBox extends StatelessWidget {
  const _BoundaryBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.info.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined, size: 18, color: t.info),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ProfileShowcaseDraftUiState _stateFor(String moderationStatus) {
  return ProfileShowcaseDraftUiState(
    loaded: true,
    serverDraft: ProfileShowcaseDraftEntity(
      id: _statusId(moderationStatus),
      selfIntro: '这是一份用于设备截图的私有草稿夹具。',
      interestTags: const ['慢约会', '低压表达'],
      lifestyleTags: const ['常驻 Nanyang'],
      openerNote: '可以从最近的生活节奏聊起。',
      moderationStatus: moderationStatus,
      publicDisplayEligible: false,
      matchingScoringEligible: false,
    ),
    editor: const ProfileShowcaseDraftInput(
      selfIntro: '这是一份用于设备截图的私有草稿夹具。',
      interestTags: ['慢约会', '低压表达'],
      lifestyleTags: ['常驻 Nanyang'],
      openerNote: '可以从最近的生活节奏聊起。',
    ),
  );
}

int _statusId(String status) {
  return switch (status) {
    'pending' => 101,
    'approved' => 102,
    'rejected' => 103,
    'needs_revision' => 104,
    'manual_review_required' => 105,
    'error' => 106,
    _ => 100,
  };
}

AppTagVariant _statusTagVariant(String status) {
  return switch (status) {
    'approved' => AppTagVariant.success,
    'rejected' || 'needs_revision' || 'error' => AppTagVariant.warning,
    'manual_review_required' => AppTagVariant.brand,
    'pending' => AppTagVariant.warning,
    _ => AppTagVariant.neutral,
  };
}
