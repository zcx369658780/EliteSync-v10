import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_overview_components.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';

class AstroOverviewPage extends ConsumerWidget {
  const AstroOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final astroAsync = ref.watch(astroSummaryProvider);

    Future<void> reloadAstro() async {
      ref.invalidate(astroSummaryProvider);
      try {
        await ref.read(astroSummaryProvider.future);
      } catch (_) {
        // Error state is rendered by the provider consumer below.
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '星盘关系参考', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const AstroLayeredBoundaryCard(),
            SizedBox(height: t.spacing.sm),
            astroAsync.when(
              loading: () => AstroProfileStateView(
                spec: astroProfileLoadingSpec('星盘关系参考'),
              ),
              error: (e, _) {
                final spec = astroProfileErrorSpec('星盘关系参考', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('星盘关系参考');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: reloadAstro,
                  );
                }

                return Column(
                  children: [
                    AstroSectionCard(
                      title: '三种参考',
                      subtitle: '分别查看本命盘、紫微斗数和八字参考',
                      icon: Icons.auto_awesome_motion_rounded,
                      child: Column(
                        children: [
                          _AstroPrimaryChoice(
                            label: '查看本命盘详情',
                            onTap: () =>
                                context.push(AppRouteNames.astroNatalChart),
                            child: AstroLayeredSystemCard(
                              title: '西洋本命盘',
                              subtitle: '互动风格和第一印象参考',
                              oneLine: '先看太阳、月亮、上升如何提示表达方式。',
                              relationshipMeaning:
                                  '适合帮助你理解自己更自然的沟通方式、情绪表达和初次互动风格。',
                              sourceStatus: '根据当前已保存的信息提供简要说明；信息不完整时可能暂不可用。',
                              boundary: '不判断两个人是否合适，也不决定匹配、排序或关系结果。',
                              detailLabel: '查看本命盘详情',
                              icon: Icons.public_rounded,
                              accent: const Color(0xFF5AA8FF),
                              onTap: () {},
                            ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          _AstroPrimaryChoice(
                            label: '查看八字详情',
                            onTap: () => context.push(AppRouteNames.astroBazi),
                            child: AstroLayeredSystemCard(
                              title: '八字节律',
                              subtitle: '生活节奏和稳定感参考',
                              oneLine: '先看长期节律、压力处理和相处节奏。',
                              relationshipMeaning:
                                  '适合提醒聊天推进、见面频率和安全感表达，不用来判断命运走向。',
                              sourceStatus: '根据当前已保存的信息提供节奏摘要；信息变化时展示也可能变化。',
                              boundary: '这是相处节奏参考，不是固定结果，也不决定匹配或关系结果。',
                              detailLabel: '查看八字详情',
                              icon: Icons.view_timeline_outlined,
                              accent: const Color(0xFF4BCB92),
                              onTap: () {},
                            ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          _AstroPrimaryChoice(
                            label: '查看紫微详情',
                            onTap: () => context.push(AppRouteNames.astroZiwei),
                            child: AstroLayeredSystemCard(
                              title: '紫微主星',
                              subtitle: '角色感和表达位置参考',
                              oneLine: '先看命宫、身宫和主星如何提示表达角色。',
                              relationshipMeaning:
                                  '适合把“我容易怎样被感受到”转成表达提醒，也给对方留下选择空间。',
                              sourceStatus: '根据当前已保存的信息提供表达摘要；部分内容可能暂不可用。',
                              boundary: '只帮助理解表达方式，不作为匹配、排序或关系结论。',
                              detailLabel: '查看紫微详情',
                              icon: Icons.grid_view_rounded,
                              accent: const Color(0xFF8F7BFF),
                              onTap: () {},
                            ),
                          ),
                        ],
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

class _AstroPrimaryChoice extends StatelessWidget {
  const _AstroPrimaryChoice({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: Focus(
        key: ValueKey('astro-primary-focus-$label'),
        descendantsAreFocusable: false,
        child: InkWell(
          excludeFromSemantics: true,
          onTap: onTap,
          child: IgnorePointer(child: ExcludeSemantics(child: child)),
        ),
      ),
    );
  }
}
