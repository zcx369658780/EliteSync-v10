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
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/standard_ziwei_grid.dart';

class AstroZiweiPage extends ConsumerWidget {
  const AstroZiweiPage({super.key});

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
      appBar: const AppTopBar(title: '紫微主星排盘', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: AstroDetailScopeHint(
                key: ValueKey('ziwei-detail-scope-hint'),
                text: '聚焦十二宫、命宫、身宫和主星的关系参考',
                icon: Icons.grid_view_rounded,
              ),
            ),
            SizedBox(height: t.spacing.md),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('紫微')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('紫微', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('紫微');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: () {
                      reloadAstro();
                    },
                  );
                }

                final ziwei = astroMap(profile['ziwei']);
                final palaces = astroList(ziwei['palaces']);
                final lifePalace = astroText(ziwei['life_palace'], '-');
                final bodyPalace = astroText(ziwei['body_palace'], '-');
                final lifePalaceRow = _palaceByName(palaces, lifePalace);
                final bodyPalaceRow = _palaceByName(palaces, bodyPalace);
                final lifePalaceDetail = _asAstroMap(
                  ziwei['life_palace_detail'],
                );
                final bodyPalaceDetail = _asAstroMap(
                  ziwei['body_palace_detail'],
                );
                final lifePalaceBranch = _branchText(
                  lifePalaceRow,
                  lifePalaceDetail,
                );
                final bodyPalaceBranch = _branchText(
                  bodyPalaceRow,
                  bodyPalaceDetail,
                );
                final lifePalaceStars = _mainStarsText(
                  lifePalaceRow,
                  detail: lifePalaceDetail,
                );
                final fourTransformations = astroList(
                  ziwei['four_transformations'],
                );
                final flyingStarStatus = _asAstroMap(
                  ziwei['flying_star_status'],
                );
                final advancedFields = _asAstroMap(
                  ziwei['ziwei_advanced_fields'],
                );
                final flyingStarCandidate = _asAstroMap(
                  advancedFields['flying_star_candidate'],
                );
                final mingGongFlyingStarCandidate = _asAstroMap(
                  advancedFields['ming_gong_flying_star_candidate'],
                );
                final summary = _ziweiSummaryLabel(ziwei['summary']);
                final precision = astroText(
                  ziwei['precision'],
                  'approximate_not_validated',
                );
                const disclaimer =
                    '四化参考会保留在下方来源详情中，适合辅助阅读主星关系节奏；进阶飞星线索只作辅助观察，不作为关系结论。';
                final bazi = astroText(profile['bazi'], '');
                final birthTime = astroText(profile['birth_time']);
                final trueSolarTime = astroText(profile['true_solar_time']);
                final locationShift = astroText(
                  profile['location_shift_minutes'],
                  '0',
                );

                return Column(
                  children: [
                    _ZiweiSplitViewSection(
                      key: const ValueKey('ziwei-chart-first-split-view'),
                      palaces: palaces,
                      lifePalace: lifePalace,
                      bodyPalace: bodyPalace,
                      lifePalaceSummary:
                          '命宫：$lifePalaceStars / $lifePalaceBranch',
                      bodyPalaceSummary:
                          '身宫：$bodyPalace${bodyPalaceBranch == '-' ? '' : ' / $bodyPalaceBranch'}',
                      bazi: bazi,
                      fourTransformations: fourTransformations,
                      flyingStarLines: astroList(flyingStarCandidate['lines']),
                      mingGongFlyingStarCandidate: mingGongFlyingStarCandidate,
                    ),
                    SizedBox(height: t.spacing.sm),
                    const AstroRelationshipNarrativeCard(
                      key: ValueKey('ziwei-readable-narrative'),
                      title: '紫微主星关系参考',
                      subtitle: '一句话理解互动角色',
                      icon: Icons.grid_view_rounded,
                      leadingText: '紫微在这里先看',
                      emphasisText: '互动角色和表达边界',
                      trailingText: '：用命宫、身宫和主星描述自己怎样被感受到，不替你给关系下结论，也不进入匹配评分。',
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '四化参考说明',
                      subtitle: '展开后查看四化参考和阅读边界',
                      icon: Icons.grid_view_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            disclaimer,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Text(
                            summary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: t.textPrimary, height: 1.45),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '命宫：$lifePalaceStars / $lifePalaceBranch',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.brandPrimary.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              Text(
                                '身宫：$bodyPalace${bodyPalaceBranch == '-' ? '' : ' / $bodyPalaceBranch'}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.brandPrimary.withValues(
                                        alpha: 0.76,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '阅读边界',
                      subtitle: '展开后查看进阶资料和适用范围',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AstroKeyValueRow(
                            label: '四化状态',
                            value: _fourTransformationsText(
                              fourTransformations,
                              advancedFields,
                            ),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '辅星 / 小星',
                            value: _advancedStatusText(
                              advancedFields,
                              'auxiliary_stars',
                            ),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '庙旺陷平得',
                            value: _advancedStatusText(
                              advancedFields,
                              'brightness',
                            ),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '命宫飞星',
                            value: _flyingStarText(
                              flyingStarStatus,
                              advancedFields,
                            ),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          const AstroKeyValueRow(
                            label: '关系边界',
                            value: '只作关系阅读参考，不替你判断结果，也不进入匹配评分',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          const AstroKeyValueRow(
                            label: '参考范围',
                            value: '十二宫 / 主星 / 四化参考 / 辅星 / 星曜状态',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '来源详情',
                      subtitle: '紫微只作为主星关系阅读参考',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前紫微页面以主星、命宫和身宫阅读为主；四化和进阶飞星线索保留在详情中，帮助你理解来源范围，不作为关系结论。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          const AstroKeyValueRow(
                            label: '边界',
                            value: '不替你判断关系结果，不进入匹配评分，不声称完整紫微斗数校准。',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '反馈紫微显示问题',
                      subtitle: '发现宫位或线索显示不一致时反馈',
                      icon: Icons.rate_review_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '如果你发现三合、飞星或四化视图和手边资料不一致，请生成本地反馈草稿，并尽量写明宫位、方向和对照结果。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              Uri(
                                path: AppRouteNames.innerTestFeedback,
                                queryParameters: {
                                  'category': 'ziwei_flying_star_oracle',
                                  'source': 'ziwei',
                                },
                              ).toString(),
                            ),
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('反馈紫微 / 飞星显示'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '进阶线索详情',
                      subtitle:
                          _hasFlyingStarCandidate(
                            flyingStarCandidate,
                            mingGongFlyingStarCandidate,
                          )
                          ? '展开后查看飞星线索和校准说明'
                          : '当前样本未返回进阶线索详情',
                      icon: Icons.device_hub_outlined,
                      child:
                          _hasFlyingStarCandidate(
                            flyingStarCandidate,
                            mingGongFlyingStarCandidate,
                          )
                          ? _FlyingStarCandidatePanel(
                              flyingStarCandidate: flyingStarCandidate,
                              mingGongFlyingStarCandidate:
                                  mingGongFlyingStarCandidate,
                            )
                          : const _FlyingStarCandidateEmptyPanel(),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroDisclosureCard(
                      title: '关键字段',
                      subtitle: '展开后确认排盘基础输入',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AstroKeyValueRow(
                            label: '生日',
                            value: astroText(profile['birthday']),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '出生时间', value: birthTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '真太阳时', value: trueSolarTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '位置修正',
                            value: '$locationShift 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '资料口径',
                            value: _precisionLabel(precision),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
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

class _ZiweiSplitViewSection extends StatefulWidget {
  const _ZiweiSplitViewSection({
    super.key,
    required this.palaces,
    required this.lifePalace,
    required this.bodyPalace,
    required this.lifePalaceSummary,
    required this.bodyPalaceSummary,
    required this.bazi,
    required this.fourTransformations,
    required this.flyingStarLines,
    required this.mingGongFlyingStarCandidate,
  });

  final List<dynamic> palaces;
  final String lifePalace;
  final String bodyPalace;
  final String lifePalaceSummary;
  final String bodyPalaceSummary;
  final String bazi;
  final List<dynamic> fourTransformations;
  final List<dynamic> flyingStarLines;
  final Map<String, dynamic> mingGongFlyingStarCandidate;

  @override
  State<_ZiweiSplitViewSection> createState() => _ZiweiSplitViewSectionState();
}

class _ZiweiSplitViewSectionState extends State<_ZiweiSplitViewSection> {
  ZiweiGridViewMode _mode = ZiweiGridViewMode.sanhe;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AstroSectionCard(
      title: '紫微分视图盘面',
      subtitle: '三合 / 飞星 / 四化分别渲染，便于对照参考排盘',
      icon: Icons.grid_on_rounded,
      fullWidth: true,
      edgeToEdge: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.sm,
              t.spacing.xs,
              t.spacing.sm,
              t.spacing.xxs,
            ),
            child: _ZiweiViewSegmentedControl(
              value: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.spacing.sm,
              vertical: t.spacing.xxs,
            ),
            child: Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: [
                AstroPill(label: widget.lifePalaceSummary),
                AstroPill(label: widget.bodyPalaceSummary),
                const AstroPill(label: '关系参考'),
                const AstroPill(label: '不作关系结论 / 不进入匹配评分'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.spacing.sm,
              vertical: t.spacing.xs,
            ),
            child: Text(
              _splitViewBoundaryText(_mode),
              key: ValueKey(_splitViewBoundaryKey(_mode)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          StandardZiweiGrid(
            palaces: widget.palaces,
            lifePalace: widget.lifePalace,
            bodyPalace: widget.bodyPalace,
            bazi: widget.bazi,
            viewMode: _mode,
            fourTransformations: widget.fourTransformations,
            flyingStarLines: widget.flyingStarLines,
            mingGongFlyingStarCandidate: widget.mingGongFlyingStarCandidate,
          ),
        ],
      ),
    );
  }
}

class _ZiweiViewSegmentedControl extends StatelessWidget {
  const _ZiweiViewSegmentedControl({
    required this.value,
    required this.onChanged,
  });

  final ZiweiGridViewMode value;
  final ValueChanged<ZiweiGridViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final items = <(ZiweiGridViewMode, String, IconData)>[
      (ZiweiGridViewMode.sanhe, '三合', Icons.grid_view_rounded),
      (ZiweiGridViewMode.flyingStar, '飞星', Icons.device_hub_outlined),
      (ZiweiGridViewMode.sihua, '四化', Icons.auto_awesome_motion_rounded),
    ];
    return Container(
      key: const ValueKey('ziwei-split-view-tabs'),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.browseSurface.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder),
      ),
      child: Row(
        children: items
            .map((item) {
              final selected = item.$1 == value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    key: ValueKey('ziwei-view-tab-${_modeSlug(item.$1)}'),
                    borderRadius: BorderRadius.circular(t.radius.sm),
                    onTap: () => onChanged(item.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: EdgeInsets.symmetric(
                        horizontal: t.spacing.xs,
                        vertical: t.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? t.brandPrimary.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(t.radius.sm),
                        border: Border.all(
                          color: selected
                              ? t.brandPrimary.withValues(alpha: 0.70)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.$3,
                            size: 15,
                            color: selected ? t.brandPrimary : t.textSecondary,
                          ),
                          SizedBox(width: t.spacing.xxs),
                          Text(
                            item.$2,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: selected
                                      ? t.brandPrimary
                                      : t.textSecondary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

String _splitViewBoundaryText(ZiweiGridViewMode mode) {
  switch (mode) {
    case ZiweiGridViewMode.sanhe:
      return '三合视图：聚焦主盘宫位、命宫、身宫、主星与辅星，适合先看整体关系节奏。';
    case ZiweiGridViewMode.flyingStar:
      return '飞星视图：进阶线索只作辅助观察，暂不作为第一层阅读重点。';
    case ZiweiGridViewMode.sihua:
      return '四化视图：把四化参考放在图上辅助理解，不替你下关系结论。';
  }
}

String _splitViewBoundaryKey(ZiweiGridViewMode mode) =>
    'ziwei-split-view-boundary-${_modeSlug(mode)}';

String _modeSlug(ZiweiGridViewMode mode) {
  switch (mode) {
    case ZiweiGridViewMode.sanhe:
      return 'sanhe';
    case ZiweiGridViewMode.flyingStar:
      return 'flying-star';
    case ZiweiGridViewMode.sihua:
      return 'sihua';
  }
}

class _FlyingStarCandidateEmptyPanel extends StatelessWidget {
  const _FlyingStarCandidateEmptyPanel();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前样本未返回进阶线索详情。本页会保留主星、命宫、身宫和四化参考；缺少进阶线索不是错误，也不代表紫微或匹配结论可被确认。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: t.textSecondary,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: t.spacing.sm),
        const AstroKeyValueRow(label: '线索状态', value: '暂无进阶线索详情'),
        SizedBox(height: t.spacing.xxs),
        const AstroKeyValueRow(label: '阅读边界', value: '仅说明当前样本未返回该字段，不补写内容'),
      ],
    );
  }
}

class _FlyingStarCandidatePanel extends StatelessWidget {
  const _FlyingStarCandidatePanel({
    required this.flyingStarCandidate,
    required this.mingGongFlyingStarCandidate,
  });

  final Map<String, dynamic> flyingStarCandidate;
  final Map<String, dynamic> mingGongFlyingStarCandidate;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final lines = astroList(flyingStarCandidate['lines'])
        .map(_asAstroMap)
        .where((line) => line.isNotEmpty)
        .take(8)
        .toList(growable: false);
    final lifePalace = astroText(
      mingGongFlyingStarCandidate['life_palace'],
      '命宫',
    );
    final lifeBranch = astroText(
      mingGongFlyingStarCandidate['life_branch'],
      '',
    );
    final lifeLabel = lifeBranch.isEmpty
        ? lifePalace
        : '$lifePalace / $lifeBranch';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '这里保留进阶飞星线索，帮助你在需要时对照宫位方向；它只作辅助参考，不作为关系结论或匹配依据。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: t.textSecondary,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (lines.isNotEmpty) ...[
          SizedBox(height: t.spacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map((line) => _FlyingStarCandidateLine(line: line))
                .toList(growable: false),
          ),
        ],
        SizedBox(height: t.spacing.sm),
        AstroKeyValueRow(
          label: '线索状态',
          value: _candidateStatusText(flyingStarCandidate),
        ),
        SizedBox(height: t.spacing.xxs),
        AstroKeyValueRow(label: '命宫相关线索', value: '$lifeLabel · 仍在校准，暂不作为阅读重点'),
        SizedBox(height: t.spacing.xxs),
        const AstroKeyValueRow(label: '阅读边界', value: '只作进阶辅助参考'),
      ],
    );
  }
}

class _FlyingStarCandidateLine extends StatelessWidget {
  const _FlyingStarCandidateLine({required this.line});

  final Map<String, dynamic> line;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final transform = astroText(line['transform_type'], '飞星');
    final badgeLocation = astroText(
      line['badge_location_candidate'],
      _candidatePalaceText(line),
    );
    final reviewStatus = astroText(
      line['review_status'],
      'human_review_required',
    );

    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 34,
            margin: EdgeInsets.only(top: 2, right: t.spacing.sm),
            decoration: BoxDecoration(
              color: t.brandPrimary.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '进阶线索：$transform -> $badgeLocation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: t.spacing.xxs),
                Text(
                  '${_candidateReviewStatusText(reviewStatus)} · 起止方向仍在校准',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _asAstroMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return const <String, dynamic>{};
}

Map<String, dynamic> _palaceByName(List<dynamic> palaces, String name) {
  for (final item in palaces) {
    final palace = _asAstroMap(item);
    if (astroText(palace['name'], '') == name ||
        astroText(palace['palace_name'], '') == name) {
      return palace;
    }
  }
  return const <String, dynamic>{};
}

bool _hasFlyingStarCandidate(
  Map<String, dynamic> flyingStarCandidate,
  Map<String, dynamic> mingGongFlyingStarCandidate,
) {
  final flyingStatus = astroText(flyingStarCandidate['status'], '');
  final mingStatus = astroText(mingGongFlyingStarCandidate['status'], '');
  return flyingStatus == 'candidate_visualization' ||
      mingStatus == 'candidate_visualization';
}

String _candidateStatusText(Map<String, dynamic> candidate) {
  final status = astroText(candidate['status'], 'candidate_visualization');
  final review = astroText(candidate['review_status'], 'human_review_required');
  if (status == 'candidate_visualization') {
    return '进阶线索 / ${_candidateReviewStatusText(review)}';
  }
  return '${_candidateVisualizationStatusText(status)} / ${_candidateReviewStatusText(review)}';
}

String _candidateVisualizationStatusText(String status) {
  final normalized = status.toLowerCase().trim();
  return switch (normalized) {
    'candidate_visualization' => '进阶线索',
    'pending_oracle' => '来源详情待补充',
    'unknown' || '' => '未标记',
    _ => '进阶线索',
  };
}

String _candidateReviewStatusText(String status) {
  final normalized = status.toLowerCase().trim();
  return switch (normalized) {
    'human_review_required' => '仍在校准',
    'pending_oracle' => '来源详情待补充',
    'accepted' || 'accepted_oracle' => '已有对照记录',
    'unknown' || '' => '未标记',
    _ => '仍在校准',
  };
}

String _candidatePalaceText(Map<String, dynamic> line) {
  final palace = astroText(line['to_palace'], '').replaceAll('宫', '').trim();
  final branch = astroText(line['branch'], '').trim();
  if (palace.isEmpty) return '宫位待复核';
  if (branch.isEmpty) return palace;
  return '$palace/$branch';
}

String _mainStarsText(
  Map<String, dynamic> palace, {
  Map<String, dynamic> detail = const <String, dynamic>{},
}) {
  final detailStars = astroList(detail['main_stars']);
  final stars =
      (detailStars.isNotEmpty ? detailStars : astroList(palace['main_stars']))
          .map((star) => star.toString().trim())
          .where((star) => star.isNotEmpty)
          .toList(growable: false);
  if (stars.isNotEmpty) return stars.join('、');
  return astroText(palace['main_star'], '待补充');
}

String _branchText(Map<String, dynamic> palace, Map<String, dynamic> detail) {
  final detailBranch = astroText(detail['branch'], '');
  if (detailBranch.isNotEmpty) return detailBranch;
  return astroText(palace['branch'], '地支未返回');
}

String _fourTransformationsText(
  List<dynamic> items,
  Map<String, dynamic> advancedFields,
) {
  final labels = items
      .map(_asAstroMap)
      .map((row) {
        final star = astroText(row['star'], '');
        final transform = astroText(row['transform'], '').replaceFirst('化', '');
        if (star.isEmpty || transform.isEmpty) return '';
        final palace = _sihuaPalaceText(row);
        return palace.isEmpty ? '$star$transform' : '$star$transform($palace)';
      })
      .where((label) => label.isNotEmpty)
      .toList(growable: false);
  if (labels.isEmpty) return _advancedStatusText(advancedFields, 'sihua');
  final status = _advancedStatusText(advancedFields, 'sihua');
  return '${labels.join(' / ')} · $status';
}

String _flyingStarText(
  Map<String, dynamic> status,
  Map<String, dynamic> advancedFields,
) {
  final fieldStatus = _advancedStatusText(advancedFields, 'flying_stars');
  if (fieldStatus != '待补充校验') return fieldStatus;
  final state = astroText(status['status'], '');
  final implementation = astroText(status['implementation'], '');
  if (state == 'insufficient_oracle' || implementation == 'not_implemented') {
    return '待补充校验';
  }
  return '待补充校验';
}

String _advancedStatusText(Map<String, dynamic> advancedFields, String field) {
  final fieldStatus = _asAstroMap(advancedFields['field_status']);
  final status = astroText(fieldStatus[field], '').trim();
  final fieldPayload = _asAstroMap(advancedFields[field]);
  final payloadStatus = astroText(fieldPayload['status'], '').trim();
  if (field == 'sihua' && payloadStatus == 'accepted_oracle') {
    return '四化参考已保留来源详情';
  }
  if (status.contains('accepted')) return '已对照字段参考';
  if (status == 'available_unverified') return '可返回，待校验复核';
  if (status == 'unsupported') return '暂不展示';
  return '待补充校验';
}

String _sihuaPalaceText(Map<String, dynamic> row) {
  final palace = astroText(row['palace'], '').replaceAll('宫', '').trim();
  final branch = astroText(row['branch'], '').trim();
  if (palace.isEmpty) return '';
  if (branch.isEmpty) return palace;
  return '$palace/$branch';
}

String _precisionLabel(String precision) {
  final normalized = precision.toLowerCase().trim();
  if (normalized.isEmpty) return '主星字段';
  if (normalized.contains('not_validated') ||
      normalized.contains('selected_fields') ||
      normalized.contains('p0')) {
    return '主星阅读 / 进阶资料参考';
  }
  return precision;
}

String _ziweiSummaryLabel(dynamic value) {
  final raw = astroText(value, '').trim();
  if (raw.isEmpty || _hasTechnicalZiweiMarker(raw)) {
    return '当前展示十二宫、地支、命宫、身宫与十四主星；四化和进阶飞星线索只作辅助阅读，不替你判断关系结果。';
  }
  return raw;
}

bool _hasTechnicalZiweiMarker(String value) {
  final lower = value.toLowerCase();
  return lower.contains('cece p0') ||
      lower.contains('oracle transcript') ||
      lower.contains('selected ziwei fields') ||
      lower.contains('ziwei_cece') ||
      lower.contains('p0_selected_fields') ||
      lower.contains('not_validated') ||
      value.contains('待校验');
}
