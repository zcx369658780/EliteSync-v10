import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
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
    compatibilityNote: '使用既有问卷页保存答案；当前必要项与报名资格请在进展中的慢约旅程查看。',
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
    final env = ref.watch(appEnvProvider);
    final presentation = _readinessPresentation(
      readiness,
      isSyntheticDemo:
          readiness == ReadinessGuardState.ready &&
          env.isDev &&
          env.useSyntheticReadinessProjection,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Readiness · 准备状态')),
      body: ListView(
        // AppShell's floating dock overlays the body; keep recovery actions
        // scrollable above it, including with enlarged text.
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
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
          _ReadinessExplanationCard(
            key: const ValueKey('readiness-source-explanation'),
            title: '当前状态来源',
            body: presentation.source,
          ),
          const SizedBox(height: 12),
          const _ReadinessExplanationCard(
            title: '正式准备条件尚未确定',
            body:
                '具体必需或可选条件及其权威来源尚未建立，不能据此判断你已满足匹配资格。状态未知也不表示你不合格。'
                '\n验证结果、问卷完成、正式准入与有效准备状态分别判断；其中一项不能替代其它结论。',
          ),
          const SizedBox(height: 16),
          const Text(
            '准备状态只用于判断能否继续进入匹配准备，不是兼容性、安全、可信度或个人价值判断。即使准备完成，也仍需另行选择是否加入匹配。',
          ),
          const SizedBox(height: 20),
          const Text('兼容验证状态查看'),
          const SizedBox(height: 8),
          const Text('查看既有验证流程的状态。该兼容页面的旧要求不代表正式准备条件，也不确定最低身份保证或准入政策。'),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => context.push(AppRouteNames.verificationStatus),
            child: const Text('查看兼容验证状态页'),
          ),
          const SizedBox(height: 12),
          const Text('兼容问卷继续设置'),
          const SizedBox(height: 8),
          const Text('前往既有问卷继续设置；已有草稿能否恢复由原问卷流程判断。填写或完成问卷不会自动加入匹配，也不授予消息许可。'),
          const SizedBox(height: 8),
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
  const _ReadinessPresentation(this.title, this.body, this.source);

  final String title;
  final String body;
  final String source;
}

// Readiness-only explanation: no evidence fetching, policy or permission write.
class _ReadinessExplanationCard extends StatelessWidget {
  const _ReadinessExplanationCard({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    ),
  );
}

_ReadinessPresentation _readinessPresentation(
  ReadinessGuardState state, {
  required bool isSyntheticDemo,
}) {
  if (state == ReadinessGuardState.ready && isSyntheticDemo) {
    return const _ReadinessPresentation(
      'Synthetic 准备状态已建立 · 开发演示',
      '这是仅用于演练 Match 流程的本地 synthetic projection；它不证明服务器或生产 readiness authority 已确认。',
      '来源：明确开启的本地 Synthetic 投影，仅用于开发演示，不是正式资格。整体状态显示不提供一份已确认的正式条件清单。',
    );
  }
  return switch (state) {
    ReadinessGuardState.unauthenticated => const _ReadinessPresentation(
      '尚未登录',
      '登录后才能查看账户私有的准备状态。',
      '当前显示登录状态；它不提供正式准备条件或匹配资格结论。',
    ),
    ReadinessGuardState.setupRequired => const _ReadinessPresentation(
      '需要继续设置',
      '当前状态提示继续设置，但没有具名正式条件来源，不能据此判断具体缺少哪项或是否不合格。',
      '来源：当前应用准备状态提示，不是一份已确认的正式条件清单。',
    ),
    ReadinessGuardState.ready => const _ReadinessPresentation(
      '准备状态来源未确认',
      '当前虽显示准备状态值，但没有可依赖的正式来源佐证，不能据此判断匹配资格。',
      '来源：未确认。状态值本身不能代替来源证据，也不证明正式条件已满足。',
    ),
    ReadinessGuardState.unknown => const _ReadinessPresentation(
      '准备状态尚未确定',
      '当前没有可依赖的权威准备状态，因此不会按“已准备”放行匹配。可以从下方入口恢复现有设置流程。',
      '来源：尚无可依赖的正式准备状态来源。未知不是不合格，也不是条件全部完成。',
    ),
  };
}
