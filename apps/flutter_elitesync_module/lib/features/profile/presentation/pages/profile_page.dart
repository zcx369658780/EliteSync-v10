import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/profile_glass_header_card.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/utils/profile_display_sanitizer.dart';
import 'package:flutter_elitesync_module/shared/models/user_role.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

final _profileAdminAccessProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final session = await ref.watch(sessionProvider.future);
  if (!session.isLoggedIn) return false;
  if (UserRole.isAdmin(session.user?.role)) return true;

  final result = await ref.read(apiClientProvider).get('/api/v1/admin/users');
  return result is NetworkSuccess;
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);

    return Scaffold(
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) => _EmptyProfileState(
          title: '资料加载失败',
          description: '暂时无法读取资料。可以稍后重试，或先查看设置。',
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (state) {
          final summary = state.summary;
          if (summary == null) {
            return _EmptyProfileState(
              title: '资料暂不可用',
              description: '当前没有可显示的资料。可以稍后刷新，或先管理基础资料。',
              onRetry: () => ref.invalidate(profileProvider),
            );
          }

          final showAdminEntry = ref
              .watch(_profileAdminAccessProvider)
              .maybeWhen(data: (value) => value, orElse: () => false);
          return _ProfileReadinessCenter(
            summary: summary,
            serverTruthFresh: state.error == null,
            showAdminEntry: showAdminEntry,
            onRefresh: () async {
              ref.invalidate(profileProvider);
              await ref.read(profileProvider.future);
            },
          );
        },
      ),
    );
  }
}

class _ProfileReadinessCenter extends StatelessWidget {
  const _ProfileReadinessCenter({
    required this.summary,
    required this.showAdminEntry,
    required this.onRefresh,
    required this.serverTruthFresh,
  });

  final ProfileSummaryEntity summary;
  final bool showAdminEntry;
  final Future<void> Function() onRefresh;
  final bool serverTruthFresh;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final displayNickname = sanitizeProfileDisplayName(summary.nickname);
    final displayCity = sanitizeProfileDisplayCity(summary.city);

    return BrowseScaffold(
      header: _ProfileHeaderBar(
        onSettingsTap: () {
          context.push(AppRouteNames.settings);
        },
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
          children: [
            ProfileGlassHeaderCard(
              nickname: displayNickname,
              city: displayCity,
              verified: summary.verified,
            ),
            SizedBox(height: t.spacing.sm),
            _MatchingReadinessCard(
              readiness: summary.readiness,
              serverTruthFresh: serverTruthFresh,
            ),
            SizedBox(height: t.spacing.sm),
            const _BaseProfileEditEntryCard(),
            SizedBox(height: t.spacing.sm),
            const _OptionalExpressionAndReferenceCard(),
            SizedBox(height: t.spacing.sm),
            _ProfileSettingsGroup(showAdminEntry: showAdminEntry),
          ],
        ),
      ),
    );
  }
}

class _MatchingReadinessCard extends StatelessWidget {
  const _MatchingReadinessCard({
    required this.readiness,
    required this.serverTruthFresh,
  });

  final ProfileReadinessEntity readiness;
  final bool serverTruthFresh;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final matching = readiness.matchingEligibility;
    final hasFreshTruth = serverTruthFresh && readiness.hasServerTruth;
    final title = !hasFreshTruth
        ? '匹配资格暂不可用'
        : matching.eligible
        ? '可以参与匹配'
        : '还不能参与匹配';
    final body = !hasFreshTruth
        ? '资料仍可查看，但无法确认最新服务器资格。请恢复连接后刷新。'
        : _matchingReason(matching);
    final showcase = _showcaseLabel(readiness.showcase);

    return AppInfoSectionCard(
      title: title,
      subtitle: hasFreshTruth ? '来自服务器的最新匹配资格' : '本地完善度不等于匹配资格',
      leadingIcon: !hasFreshTruth
          ? Icons.cloud_off_outlined
          : matching.eligible
          ? Icons.check_circle_outline_rounded
          : Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            showcase,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            readiness.showcase.affectsMatchingEligibility
                ? 'Showcase 与匹配资格的关系暂不可确认，请刷新'
                : 'Showcase 状态不改变匹配资格',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: t.brandPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasFreshTruth &&
              (matching.eligible ||
                  (matching.reasonCode == 'questionnaire_incomplete' &&
                      matching.nextActionCode ==
                          'complete_questionnaire'))) ...[
            SizedBox(height: t.spacing.sm),
            AppPrimaryButton(
              label: matching.eligible ? '进入匹配' : '继续完成问卷',
              fullWidth: true,
              onPressed: () {
                if (matching.eligible) {
                  context.go(AppRouteNames.match);
                  return;
                }
                context.go(AppRouteNames.questionnaire);
              },
            ),
          ],
        ],
      ),
    );
  }

  String _matchingReason(MatchingEligibilityEntity matching) {
    if (matching.eligible) return '服务器已确认当前满足匹配准入条件。';
    return switch (matching.reasonCode) {
      'questionnaire_incomplete' => '还需完成 ${matching.missingAnswerCount} 项匹配问卷',
      'account_disabled' => '账号当前不可参与匹配，请联系支持。',
      'synthetic_account_excluded' => '此测试账号不参与普通匹配。',
      'questionnaire_unavailable' => '匹配问卷服务暂不可用，请稍后刷新。',
      _ => '服务器尚未确认匹配资格，请刷新后重试。',
    };
  }

  String _showcaseLabel(ShowcaseReadinessEntity showcase) {
    if (showcase.publicationStatus == 'published') {
      return showcase.publishedVersionCurrent
          ? 'Showcase：已发布当前版本'
          : 'Showcase：已发布版本保留，另有新的私密编辑';
    }
    return switch (showcase.reviewStatus) {
      'pending' => 'Showcase：审核中，内容仍为私密',
      'approved' => 'Showcase：已通过审核，等待你明确发布',
      'rejected' => 'Showcase：审核未通过，内容仍为私密',
      'needs_revision' => 'Showcase：需要修改，内容仍为私密',
      'manual_review_required' => 'Showcase：等待人工审核，内容仍为私密',
      _ =>
        showcase.draftState == 'private_draft'
            ? 'Showcase：仅私密草稿'
            : 'Showcase：尚未创建私密草稿',
    };
  }
}

class _ProfileHeaderBar extends StatelessWidget {
  const _ProfileHeaderBar({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Text(
            '我的',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onSettingsTap,
            tooltip: '打开设置',
            icon: Icon(Icons.settings_rounded, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  const _EmptyProfileState({
    required this.title,
    required this.description,
    required this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return BrowseScaffold(
      header: _ProfileHeaderBar(
        onSettingsTap: () {
          context.push(AppRouteNames.settings);
        },
      ),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
        children: [
          AppErrorState(
            title: title,
            description: description,
            retryLabel: '重新加载',
            onRetry: onRetry,
          ),
          SizedBox(height: t.spacing.sm),
          const _BaseProfileEditEntryCard(),
          SizedBox(height: t.spacing.sm),
          const _OptionalExpressionAndReferenceCard(),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '我的',
            subtitle: '身份与个人内容会在资料恢复后显示。',
            leadingIcon: Icons.account_circle_outlined,
            child: Text(
              '请稍后重试。',
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

class _BaseProfileEditEntryCard extends StatelessWidget {
  const _BaseProfileEditEntryCard();

  @override
  Widget build(BuildContext context) {
    return AppInfoSectionCard(
      title: '基础资料',
      subtitle: '管理昵称、城市和个人信息',
      leadingIcon: Icons.person_outline_rounded,
      child: _ProfileNavigationRow(
        title: '编辑个人资料',
        subtitle: '查看并修改基础资料',
        icon: Icons.edit_outlined,
        onTap: () => context.push(AppRouteNames.editProfile),
      ),
    );
  }
}

class _OptionalExpressionAndReferenceCard extends StatelessWidget {
  const _OptionalExpressionAndReferenceCard();

  @override
  Widget build(BuildContext context) {
    return AppInfoSectionCard(
      title: '可选表达与参考',
      subtitle: '按需管理个人表达或查看关系参考',
      leadingIcon: Icons.badge_outlined,
      child: Column(
        children: [
          _ProfileNavigationRow(
            title: '个人展示',
            subtitle: '可选的自我表达内容',
            icon: Icons.badge_outlined,
            onTap: () => context.push(AppRouteNames.personalShowcase),
          ),
          _ProfileNavigationRow(
            title: '星盘关系参考',
            subtitle: '仅作理解参考，不决定匹配或关系结果',
            icon: Icons.auto_awesome_outlined,
            onTap: () => context.push(AppRouteNames.astroOverview),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsGroup extends StatelessWidget {
  const _ProfileSettingsGroup({required this.showAdminEntry});

  final bool showAdminEntry;

  @override
  Widget build(BuildContext context) {
    return AppInfoSectionCard(
      title: '更多',
      subtitle: '设置与账号操作',
      leadingIcon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileNavigationRow(
            title: '设置',
            subtitle: '账号、安全、隐私、提醒、帮助与版本',
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppRouteNames.settings),
          ),
          if (showAdminEntry) ...[
            const _ProfileSectionLabel('运营工具'),
            _ProfileNavigationRow(
              title: '运营看板',
              subtitle: '管理员可见的入口展示',
              icon: Icons.admin_panel_settings_outlined,
              onTap: () => context.push(AppRouteNames.adminDashboard),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileSectionLabel extends StatelessWidget {
  const _ProfileSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xxs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: t.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileNavigationRow extends StatelessWidget {
  const _ProfileNavigationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radius.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: t.spacing.xs),
          child: Row(
            children: [
              Icon(icon, size: 18, color: t.brandPrimary),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: t.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
