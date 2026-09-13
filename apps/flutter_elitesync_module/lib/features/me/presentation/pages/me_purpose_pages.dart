import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';

class PrivateIdentityPurposePage extends StatelessWidget {
  const PrivateIdentityPurposePage({super.key});

  @override
  Widget build(BuildContext context) => const _CompatibilityPurposePage(
    title: 'Private Identity · 私密身份',
    description: '这里用于账户私密身份资料，不代表公开个人主页，也不自动授权匹配使用。',
    compatibilityNote: '现阶段暂时使用原有资料编辑页；其字段尚未迁移到新的用途数据契约。',
    actionLabel: '打开兼容资料编辑页',
    actionRoute: AppRouteNames.editProfile,
  );
}

class MatchingInputsPurposePage extends StatelessWidget {
  const MatchingInputsPurposePage({super.key});

  @override
  Widget build(BuildContext context) => const _CompatibilityPurposePage(
    title: 'Matching Inputs · 匹配输入',
    description: '这里用于查看或编辑匹配准备输入。填写、修改或完成问卷都不会自动加入匹配。',
    compatibilityNote: '现阶段暂时使用原有问卷页；必填字段和正式资格规则尚未确定。',
    actionLabel: '打开兼容问卷页',
    actionRoute: AppRouteNames.questionnaire,
  );
}

class ReadinessPurposePage extends ConsumerWidget {
  const ReadinessPurposePage({super.key});

  static const statusKey = ValueKey<String>('me-readiness-status');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(navigationGuardProvider).readinessState;
    final presentation = _readinessPresentation(readiness);

    return Scaffold(
      appBar: AppBar(title: const Text('Readiness · 准备状态')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            key: statusKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presentation.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(presentation.body),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '准备状态只用于判断能否继续进入匹配准备，不是兼容性、安全、可信度或个人价值判断。即使准备完成，也仍需另行选择是否加入匹配。',
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () => context.push(AppRouteNames.verificationStatus),
            child: const Text('查看兼容验证状态页'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push(AppRouteNames.questionnaire),
            child: const Text('继续兼容问卷页'),
          ),
          const SizedBox(height: 12),
          Text(
            '上述页面仅用于恢复或继续现有设置流程；它们不会在本任务中生成新的资格结论。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class ShowcasePurposePage extends StatelessWidget {
  const ShowcasePurposePage({super.key});

  @override
  Widget build(BuildContext context) => const _CompatibilityPurposePage(
    title: 'Showcase · 展示内容',
    description: '这里面向候选人范围内的展示准备；没有全局公开个人主页授权。',
    compatibilityNote: '现阶段暂时使用原有 Personal Showcase 页面；其发布模型不代表新的候选人范围契约已经完成。',
    actionLabel: '打开兼容 Showcase 页面',
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
        padding: const EdgeInsets.all(20),
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

class _ReadinessPresentation {
  const _ReadinessPresentation(this.title, this.body);

  final String title;
  final String body;
}

_ReadinessPresentation _readinessPresentation(ReadinessGuardState state) {
  return switch (state) {
    ReadinessGuardState.unauthenticated => const _ReadinessPresentation(
      '尚未登录',
      '登录后才能查看账户私有的准备状态。',
    ),
    ReadinessGuardState.setupRequired => const _ReadinessPresentation(
      '需要继续设置',
      '准备所需步骤尚未完成；可以从下方入口恢复，但具体资格规则仍未确定。',
    ),
    ReadinessGuardState.ready => const _ReadinessPresentation(
      '准备状态已由权威来源确认',
      '这只表示当前准备要求已满足；不会自动加入匹配。',
    ),
    ReadinessGuardState.unknown => const _ReadinessPresentation(
      '准备状态尚未确定',
      '当前没有可依赖的权威准备状态，因此不会按“已准备”放行匹配。可以从下方入口恢复现有设置流程。',
    ),
  };
}
