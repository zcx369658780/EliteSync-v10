import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/relationship_runtime_local_preview_entry.dart';

/// Standalone developer-only harness for the local relationship preview entry.
class RelationshipRuntimeLocalPreviewHarness extends StatelessWidget {
  const RelationshipRuntimeLocalPreviewHarness({
    super.key,
    this.enabled = kDebugMode,
    this.scenarios,
    this.compact = true,
    this.maxEntries = 2,
  }) : assert(maxEntries > 0);

  final bool enabled;
  final List<RelationshipRuntimeLocalPreviewScenario>? scenarios;
  final bool compact;
  final int maxEntries;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final activeScenarios = scenarios ?? _defaultHarnessScenarios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HarnessHeader(enabled: enabled),
        SizedBox(height: t.spacing.sm),
        if (!enabled)
          const _HarnessDisabledCard()
        else ...[
          const _HarnessAccessCard(),
          SizedBox(height: t.spacing.sm),
          for (var i = 0; i < activeScenarios.length; i++) ...[
            RelationshipRuntimeLocalPreviewEntry(
              scenario: activeScenarios[i],
              compact: compact,
              maxEntries: maxEntries,
            ),
            if (i != activeScenarios.length - 1) SizedBox(height: t.spacing.sm),
          ],
        ],
      ],
    );
  }
}

const _defaultHarnessScenarios = <RelationshipRuntimeLocalPreviewScenario>[
  RelationshipRuntimeLocalPreviewScenario.waiting,
  RelationshipRuntimeLocalPreviewScenario.reveal,
  RelationshipRuntimeLocalPreviewScenario.opener,
  RelationshipRuntimeLocalPreviewScenario.noCandidate,
  RelationshipRuntimeLocalPreviewScenario.paused,
];

class _HarnessHeader extends StatelessWidget {
  const _HarnessHeader({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPadding),
      border: Border.all(
        color: (enabled ? t.info : t.warning).withValues(alpha: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '开发者预览入口检查',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppChoiceChip(
                label: enabled ? '仅调试 / 开发' : '未启用',
                selected: true,
              ),
              const AppChoiceChip(label: '独立检查面'),
              const AppChoiceChip(label: '未注册路由'),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '仅用于开发阶段手动挂载或测试渲染；不注册公开路由、不接 AppShell、不进入生产 Match 流程。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HarnessAccessCard extends StatelessWidget {
  const _HarnessAccessCard();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPadding),
      border: Border.all(color: t.info.withValues(alpha: 0.14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xxs,
            children: const [
              AppChoiceChip(label: '本地样例', selected: true),
              AppChoiceChip(label: '只读预览'),
              AppChoiceChip(label: '不触发 API'),
              AppChoiceChip(label: '不写 DB'),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '此检查面只组合本地入口和文件内样例；真实用户路径、远端运行时、发送、反馈持久化与通知推送仍保持未接入。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HarnessDisabledCard extends StatelessWidget {
  const _HarnessDisabledCard();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPadding),
      border: Border.all(color: t.warning.withValues(alpha: 0.16)),
      child: Text(
        '开发者本地预览未启用：默认仅在调试 / 开发场景渲染，release 或未授权环境保持空入口。',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.45),
      ),
    );
  }
}
