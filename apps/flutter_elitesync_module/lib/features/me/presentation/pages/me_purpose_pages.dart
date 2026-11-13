import '../../../slow_dating_v1012/matching_input_page.dart';
import '../../../slow_dating_v1012/slow_dating_journey_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';

class PrivateIdentityPurposePage extends StatelessWidget {
  const PrivateIdentityPurposePage({super.key});

  @override
  Widget build(BuildContext context) => const _CompatibilityPurposePage(
    title: '私密资料',
    description: '这里用于账户私密身份资料，不代表公开个人主页，也不自动授权匹配使用。',
    compatibilityNote: '在资料编辑页管理个人信息。编辑资料不会自动改变受众，也不代表已满足匹配参与条件。',
    actionLabel: '编辑私密资料',
    actionRoute: AppRouteNames.editProfile,
  );
}

class MatchingInputsPurposePage extends StatelessWidget {
  const MatchingInputsPurposePage({super.key});
  @override
  Widget build(BuildContext context) => const MatchingInputPage();
}

class ReadinessPurposePage extends StatelessWidget {
  const ReadinessPurposePage({super.key});
  static const statusKey = ValueKey<String>('me-readiness-status');
  @override
  Widget build(BuildContext context) => const SlowDatingJourneyPage();
}

class ShowcasePurposePage extends StatelessWidget {
  const ShowcasePurposePage({super.key});

  @override
  Widget build(BuildContext context) => const _CompatibilityPurposePage(
    title: '展示资料',
    description: '编辑本人展示资料和照片，选择可查看的关系范围。',
    compatibilityNote: '草稿保存后可提交审核。审核通过后由你明确发布，已有发布版也可撤回。',
    actionLabel: '编辑展示资料',
    actionRoute: AppRouteNames.personalShowcase,
  );
}

class PrivacySettingsPurposePage extends StatelessWidget {
  const PrivacySettingsPurposePage({super.key});

  @override
  Widget build(BuildContext context) => const PrivacySettingsPage();
}

class _CompatibilityPurposePage extends StatelessWidget {
  const _CompatibilityPurposePage({
    required this.title,
    required this.description,
    required this.compatibilityNote,
    required this.actionLabel,
    required this.actionRoute,
  });

  final String title;
  final String description;
  final String compatibilityNote;
  final String actionLabel;
  final String actionRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        children: [
          Text(description, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(compatibilityNote),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () => context.push(actionRoute),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
