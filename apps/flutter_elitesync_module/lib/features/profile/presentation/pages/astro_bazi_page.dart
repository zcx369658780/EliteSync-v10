import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_relationship_narrative_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/bazi_timeline_section.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/professional_bazi_grid.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/wu_xing_energy_bar.dart';

class AstroBaziPage extends ConsumerWidget {
  const AstroBaziPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroSummaryProvider);

    Future<void> reloadAstro() async {
      ref.invalidate(astroSummaryProvider);
      try {
        await ref.read(astroSummaryProvider.future);
      } catch (_) {
        // Error state is rendered by the provider consumer below.
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '八字详情', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: AstroDetailScopeHint(
                key: ValueKey('bazi-detail-scope-hint'),
                text: '先看四柱与五行，再读关系节律参考',
                icon: Icons.view_timeline_outlined,
              ),
            ),
            SizedBox(height: t.spacing.md),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('八字')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('八字', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('八字');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: () {
                      reloadAstro();
                    },
                  );
                }

                final bazi = astroText(profile['bazi'], '暂无八字');
                final baziDetails = astroMap(profile['bazi_details']);
                final trueSolarTime = astroText(profile['true_solar_time']);
                final birthTime = astroText(profile['birth_time']);
                final birthPlace = astroText(
                  profile['birth_place'] ?? profile['private_birth_place'],
                );
                final birthday = astroText(profile['birthday']);
                final locationShift = astroText(
                  profile['location_shift_minutes'],
                  '0',
                );
                final longitudeOffset = astroText(
                  profile['longitude_offset_minutes'],
                  '0',
                );
                final equationOfTime = astroText(
                  profile['equation_of_time_minutes'],
                  '0',
                );
                final locationSource = astroText(
                  profile['location_source'],
                  '未标注',
                );
                final accuracy = astroText(profile['accuracy'], '系统整理');
                final confidence = astroText(profile['confidence'], '0.0');
                final wuXing = astroMap(profile['wu_xing']);
                final notes = astroList(profile['notes']);
                final daYun = astroList(profile['da_yun']);
                final liuNian = astroList(profile['liu_nian']);

                return Column(
                  children: [
                    AstroSectionCard(
                      key: const ValueKey('bazi-chart-first-grid'),
                      title: '四柱矩阵',
                      subtitle: '先看已保存四柱结构，再按需展开关系说明',
                      icon: Icons.fact_check_outlined,
                      fullWidth: true,
                      edgeToEdge: true,
                      child: ProfessionalBaziGrid(
                        bazi: bazi,
                        baziDetails: baziDetails,
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      key: const ValueKey('bazi-chart-first-wuxing'),
                      title: '五行能量',
                      subtitle: '从已显示数据读取分布，只作为节律参考',
                      icon: Icons.waterfall_chart_outlined,
                      child: WuXingEnergyBar(wuXing: wuXing),
                    ),
                    SizedBox(height: t.spacing.sm),
                    const AstroRelationshipNarrativeCard(
                      key: ValueKey('bazi-readable-narrative'),
                      title: '八字关系节律参考',
                      subtitle: '一句话理解相处节律',
                      icon: Icons.view_timeline_outlined,
                      leadingText: '八字在这里只帮你看',
                      emphasisText: '相处节律',
                      trailingText: '：长期稳定感、推进快慢和表达方式可以作为沟通提醒，不代表关系固定走向。',
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '大运 / 流年',
                      subtitle: '展开后查看阶段变化',
                      icon: Icons.timeline_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BaziTimelineSection(
                            title: '大运',
                            subtitle: '以起止年份和年龄段呈现大运流向',
                            items: daYun,
                            isDaYun: true,
                          ),
                          SizedBox(height: t.spacing.sm),
                          BaziTimelineSection(
                            title: '流年',
                            subtitle: '以年份节点和流年干支呈现年度变化',
                            items: liuNian,
                            isDaYun: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '来源与边界',
                      subtitle: '八字只作为关系节律参考',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前页面读取已保存的八字、五行和阶段摘要；如果出生时间或地点变化，展示结果可能改变。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          const AstroKeyValueRow(
                            label: '边界',
                            value: '这是一条理解参考，不是关系结论；不替你做决定，也不直接改变匹配结果。',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '来源与展示参数',
                      subtitle: '展开后确认资料输入与展示口径',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AstroKeyValueRow(label: '生日', value: birthday),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '出生时间', value: birthTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '出生地', value: birthPlace),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '真太阳时', value: trueSolarTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '位置修正',
                            value: '$locationShift 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '经度修正',
                            value: '$longitudeOffset 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '均时差',
                            value: '$equationOfTime 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '位置说明',
                            value: locationSource,
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '展示口径', value: accuracy),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '参考状态', value: confidence),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '备注',
                      subtitle: '展开后查看系统整理的补充说明',
                      icon: Icons.notes_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notes.isEmpty
                            ? [
                                Text(
                                  '无备注',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: t.textSecondary.withValues(
                                          alpha: 0.78,
                                        ),
                                      ),
                                ),
                              ]
                            : notes
                                  .take(8)
                                  .map((e) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: t.spacing.xxs,
                                      ),
                                      child: Text(
                                        '• ${e.toString()}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: t.textSecondary.withValues(
                                                alpha: 0.82,
                                              ),
                                              height: 1.35,
                                            ),
                                      ),
                                    );
                                  })
                                  .toList(growable: false),
                      ),
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
