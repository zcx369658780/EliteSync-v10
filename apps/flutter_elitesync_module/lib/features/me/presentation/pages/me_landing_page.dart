import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/avatar/avatar_management_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'account_status_page.dart';

class MeLandingPage extends StatelessWidget {
  const MeLandingPage({super.key, this.restorationLocalBuild = false});
  final bool restorationLocalBuild;
  static const privateIdentityKey = ValueKey<String>(
    'me-private-identity-entry',
  );
  static const matchingInputsKey = ValueKey<String>('me-matching-inputs-entry');
  static const readinessKey = ValueKey<String>('me-readiness-entry');
  static const showcaseKey = ValueKey<String>('me-showcase-entry');
  static const privacySettingsKey = ValueKey<String>(
    'me-privacy-settings-entry',
  );
  static const accountStatusKey = ValueKey<String>('me-account-status-entry');

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouteNames.settings),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.md,
          t.spacing.pageHorizontal,
          112,
        ),
        children: [
          const AvatarManagementEntry(),
          SizedBox(height: t.spacing.md),
          const _MeGroup(
            title: '个人资料',
            children: [
              _MePurposeEntry(
                key: privateIdentityKey,
                icon: Icons.badge_outlined,
                title: '私密资料',
                subtitle: '管理昵称与个人信息，不会因此向所有人公开。',
                route: AppRouteNames.mePrivateIdentity,
              ),
              _MePurposeEntry(
                key: matchingInputsKey,
                icon: Icons.tune_rounded,
                title: '匹配问卷',
                subtitle: '继续填写与修改，完成后仍需自主报名。',
                route: AppRouteNames.meMatchingInputs,
              ),
              _MePurposeEntry(
                key: readinessKey,
                icon: Icons.fact_check_outlined,
                title: '准备状态',
                subtitle: '查看参与条件与下一步，不作匹配结果保证。',
                route: AppRouteNames.meReadiness,
              ),
              _MePurposeEntry(
                key: showcaseKey,
                icon: Icons.auto_awesome_outlined,
                title: '展示资料',
                subtitle: '编辑展示内容，发布状态单独确认。',
                route: AppRouteNames.meShowcase,
              ),
            ],
          ),
          _MeGroup(
            title: '账户与隐私',
            children: [
              const _MePurposeEntry(
                key: privacySettingsKey,
                icon: Icons.privacy_tip_outlined,
                title: '隐私控制',
                subtitle: '管理资料受众，查看各项隐私说明。',
                route: AppRouteNames.mePrivacySettings,
              ),
              if (restorationLocalBuild ||
                  const bool.fromEnvironment('ELITESYNC_V1014_LOCAL_BUILD') ||
                  const bool.fromEnvironment('ELITESYNC_V1015_R1_LOCAL_BUILD'))
                SettingsItemTile(
                  key: accountStatusKey,
                  title: '资格、状态与申诉',
                  subtitle: '查看参与资格、本人处理状态与申诉入口。',
                  icon: Icons.shield_outlined,
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AccountStatusPage(
                        restorationLocalBuild: restorationLocalBuild,
                      ),
                    ),
                  ),
                ),
              if (restorationLocalBuild)
                const _MePurposeEntry(
                  icon: Icons.notifications_none_rounded,
                  title: '站内通知',
                  subtitle: '查看当前账户的提醒与已读状态。',
                  route: AppRouteNames.notificationCenter,
                  push: true,
                ),
            ],
          ),
          if (restorationLocalBuild)
            const _MeGroup(
              title: '兴趣与记录',
              children: [
                _MePurposeEntry(
                  icon: Icons.dynamic_feed_outlined,
                  title: '动态广场',
                  subtitle: '查看、发布与管理动态。',
                  route: AppRouteNames.statusSquare,
                  push: true,
                ),
                _MePurposeEntry(
                  icon: Icons.psychology_outlined,
                  title: '可选 MBTI 测评',
                  subtitle: '自愿参与，不是心理诊断，不参与匹配排序。',
                  route: AppRouteNames.mbtiCenter,
                  push: true,
                ),
                _MePurposeEntry(
                  icon: Icons.auto_awesome_outlined,
                  title: '三盘本命',
                  subtitle: '管理私有出生资料，查看排盘与核验状态。',
                  route: AppRouteNames.astroProfile,
                  push: true,
                ),
                _MePurposeEntry(
                  icon: Icons.calendar_month_outlined,
                  title: '动态星盘与关系盘',
                  subtitle: '本人私有盘与手填双盘，不读取他人生辰。',
                  route: AppRouteNames.astroAdvancedPreview,
                  push: true,
                ),
                _MePurposeEntry(
                  icon: Icons.history_outlined,
                  title: '已存八字',
                  subtitle: '查看已保存的八字记录。',
                  route: AppRouteNames.astroBazi,
                  push: true,
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: t.spacing.sm),
            child: Text(
              '资料、展示与各项互动分别授权，没有默认公开的个人主页。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeGroup extends StatelessWidget {
  const _MeGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SettingsGroup(
      title: title,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
          children[i],
        ],
      ],
    );
  }
}

class _MePurposeEntry extends StatelessWidget {
  const _MePurposeEntry({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.push = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final bool push;
  @override
  Widget build(BuildContext context) => SettingsItemTile(
    title: title,
    subtitle: subtitle,
    icon: icon,
    onTap: () {
      if (push) {
        context.push(route);
      } else {
        context.go(route);
      }
    },
  );
}
