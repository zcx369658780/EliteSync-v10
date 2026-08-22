import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_capability_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_explanation_layer_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_sample_set.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_timing_framework_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_parity_report.dart';

class AstroAdvancedPreviewPage extends ConsumerWidget {
  const AstroAdvancedPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroAdvancedPreviewProvider);
    final workbenchPrefs = ref.watch(astroChartWorkbenchProvider);

    Future<void> reloadPreview() async {
      ref.invalidate(astroAdvancedPreviewProvider);
      try {
        await ref.read(astroAdvancedPreviewProvider.future);
      } catch (_) {
        // Error state is rendered below.
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '高级时法', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadPreview,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('高级时法')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('高级时法', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadPreview,
                );
              },
              data: (bundle) {
                if (bundle == null) {
                  final spec = astroProfileEmptySpec('高级时法');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: reloadPreview,
                  );
                }

                return Column(
                  children: [
                    AppInfoSectionCard(
                      title: '这页内容怎么用',
                      subtitle: '用于理解与比较，不是个人星盘结论',
                      leadingIcon: Icons.auto_awesome_rounded,
                      child: Text(
                        '页面会结合已保存画像与对照样例，帮助你理解合盘、行运、返照和不同路线。对照内容与离线可用内容都是样例，不会更改已保存的星盘记录，也不能替代个人星盘结论。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroTimingFrameworkCard(bundle: bundle.timing),
                    SizedBox(height: t.spacing.sm),
                    AstroAdvancedExplanationLayerCard(bundle: bundle),
                    SizedBox(height: t.spacing.sm),
                    if (bundle.offlineFallback) ...[
                      AppInfoSectionCard(
                        title: '离线预览',
                        subtitle: '在线高级预览暂不可用，当前展示本地样例矩阵与离线摘要',
                        leadingIcon: Icons.cloud_off_rounded,
                        child: Text(
                          '现在展示的是离线样例，方便你了解页面会怎样比较关系和时间线索。样例不是你的正式结果，也不会影响已保存的星盘记录；在线内容恢复后可以再刷新查看。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                    ],
                    AstroRouteParityReportCard(
                      currentRouteMode: bundle.routeMode,
                      currentWorkbench: workbenchPrefs,
                      compact: false,
                      title: '路线差异怎么读',
                      subtitle: '比较标准、古典与现代路线的表达方式',
                      onOpenDetails: () =>
                          context.push(AppRouteNames.astroChartSettings),
                    ),
                    SizedBox(height: t.spacing.sm),
                    const AstroAdvancedCapabilityCard(),
                    SizedBox(height: t.spacing.sm),
                    AstroAdvancedSampleSetView(bundle: bundle),
                    SizedBox(height: t.spacing.sm),
                    AppInfoSectionCard(
                      title: '本页样例一览',
                      subtitle: '用普通文字回顾关系与时间样例',
                      leadingIcon: Icons.receipt_long_rounded,
                      child: SelectableText(
                        _ordinaryAdvancedSummaryLines(bundle).join('\n'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AppPrimaryButton(
                      label: '返回设置中心',
                      onPressed: () =>
                          context.push(AppRouteNames.astroChartSettings),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _ordinaryAdvancedSummaryLines(
  AstroAdvancedPreviewBundle bundle,
) => [
  '这里汇总本页展示的对照样例：',
  ...bundle.items.map(
    (item) => '• ${item.title}：${_ordinaryAdvancedSummaryCopy(item.summary)}',
  ),
  '• 年度视角：${_ordinaryAdvancedSummaryCopy(bundle.timing.formalSignal.summary)}',
  '• 主时段示意：${_ordinaryAdvancedSummaryCopy(bundle.timing.placeholderSignal.summary)}',
  '以上内容只帮助理解页面结构，不是你的个人星盘结论，也不会更改已保存的星盘记录。',
];

String _ordinaryAdvancedSummaryCopy(String text) => text
    .replaceAllMapped(
      RegExp(r'(^|[^A-Za-z0-9_])EliteSync(?=$|[^A-Za-z0-9_])'),
      (match) => '${match[1]}示例人物',
    )
    .replaceAll('占位', '示意')
    .replaceAll('待接入', '暂无个人内容')
    .replaceAll('接入位', '展示位置')
    .replaceAll('容器', '样例')
    .replaceAll('回写', '更改');
