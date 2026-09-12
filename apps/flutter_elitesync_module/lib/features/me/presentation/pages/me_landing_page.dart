import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

class MeLandingPage extends StatelessWidget {
  const MeLandingPage({super.key});

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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.go(route),
      ),
    );
  }
}
