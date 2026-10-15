import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
        children: [
          if (restorationLocalBuild) ...[
            Text('本地恢复功能', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _MePurposeEntry(
              icon: Icons.dynamic_feed_outlined,
              title: '动态广场',
              subtitle: '查看、发布与管理本地开发环境中的真实动态。',
              route: AppRouteNames.statusSquare,
              push: true,
            ),
            _MePurposeEntry(
              icon: Icons.psychology_outlined,
              title: '可选 MBTI 测评',
              subtitle: '自愿答题与结果读回；不是心理诊断，不参与匹配排序。',
              route: AppRouteNames.mbtiCenter,
              push: true,
            ),
            _MePurposeEntry(
              icon: Icons.calendar_month_outlined,
              title: '本地真实八字',
              subtitle: '使用已保存出生资料计算；完整紫微与西占待恢复。',
              route: AppRouteNames.astroBazi,
              push: true,
            ),
            _MePurposeEntry(
              icon: Icons.notifications_none_rounded,
              title: '站内通知',
              subtitle: '读取当前账户的站内通知与已读状态；不代表系统 Push。',
              route: AppRouteNames.notificationCenter,
              push: true,
            ),
            _MePurposeEntry(
              icon: Icons.settings_outlined,
              title: '本地设置',
              subtitle: '主题、字体等设置只影响本设备展示，不授予服务端权限或开启外部推送。',
              route: AppRouteNames.settings,
              push: true,
            ),
            const SizedBox(height: 16),
          ],
          Text('按用途管理', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('以下内容各有独立用途和访问边界；它们不是一个默认公开的个人主页。'),
          const SizedBox(height: 16),
          _MePurposeEntry(
            key: privateIdentityKey,
            icon: Icons.badge_outlined,
            title: 'Private Identity · 私密身份',
            subtitle: '管理账户私密身份资料；不会因此向所有人公开。',
            route: AppRouteNames.mePrivateIdentity,
          ),
          _MePurposeEntry(
            key: matchingInputsKey,
            icon: Icons.tune_rounded,
            title: 'Matching Inputs · 匹配输入',
            subtitle: '查看或编辑用于匹配准备的输入；编辑不会自动加入匹配。',
            route: AppRouteNames.meMatchingInputs,
          ),
          _MePurposeEntry(
            key: readinessKey,
            icon: Icons.fact_check_outlined,
            title: 'Readiness · 准备状态',
            subtitle: '查看准备状态与下一步；准备状态不等于兼容性、安全或可信度判断。',
            route: AppRouteNames.meReadiness,
          ),
          _MePurposeEntry(
            key: showcaseKey,
            icon: Icons.auto_awesome_outlined,
            title: 'Showcase · 展示内容',
            subtitle: '管理候选人范围内的展示准备；当前不代表全局公开授权。',
            route: AppRouteNames.meShowcase,
          ),
          _MePurposeEntry(
            key: privacySettingsKey,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Settings · 隐私与设置',
            subtitle: '管理隐私说明与设备、账户设置；设置不替代用途授权。',
            route: AppRouteNames.mePrivacySettings,
          ),
        ],
      ),
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          if (push) {
            context.push(route);
          } else {
            context.go(route);
          }
        },
      ),
    );
  }
}
