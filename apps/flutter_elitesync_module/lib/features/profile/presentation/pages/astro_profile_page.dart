import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/app/router/app_route_observer.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/utils/profile_display_sanitizer.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/shared/widgets/a5_relationship_understanding_card.dart';

class AstroProfilePage extends ConsumerStatefulWidget {
  const AstroProfilePage({super.key});

  @override
  ConsumerState<AstroProfilePage> createState() => _AstroProfilePageState();
}

class _AstroProfilePageState extends ConsumerState<AstroProfilePage>
    with RouteAware {
  RouteObserver<PageRoute<dynamic>>? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ref.read(appRouteObserverProvider);
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      if (_routeObserver != observer) {
        _routeObserver?.unsubscribe(this);
        _routeObserver = observer;
        _routeObserver?.subscribe(this, route);
      }
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    ref.invalidate(astroSummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: const AppTopBar(title: '星盘画像', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          SectionReveal(
            child: PageTitleRail(
              title: '星座 / 星盘 / 八字画像',
              subtitle: '用于匹配结果中的过程与结论解释，先看生活化摘要',
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 35),
            child: AppInfoSectionCard(
              title: '西洋本命盘详情',
              subtitle: '行星、宫位列表与已保存来源状态',
              leadingIcon: Icons.public_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '进入详情页查看行星、宫位列表、黄道与宫位口径，以及外部对照未完成状态。本入口只读取已保存资料，不改变资料或匹配算法。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push(AppRouteNames.astroNatalChart),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('查看行星落宫'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          const SectionReveal(
            delay: Duration(milliseconds: 45),
            child: A5RelationshipUnderstandingCard(
              title: '画像关系解释摘要',
              subtitle: '把星盘、八字、紫微转成可理解的相处提醒',
              summary: '画像页只帮助你理解自己如何表达、适合怎样慢聊，不把任何玄学结果写成命运判断。',
              dimensions: [
                A5UnderstandingDimension(
                  title: '理解自己',
                  label: '摘要',
                  body: '把复杂画像转成自己容易被怎样看见。',
                ),
                A5UnderstandingDimension(
                  title: '理解关系',
                  label: '维度',
                  body: '把匹配解释拆成共同点、差异点和节奏提醒。',
                ),
                A5UnderstandingDimension(
                  title: '降低压力',
                  label: '建议',
                  body: '只给开场和表达参考，决定权仍在你手里。',
                ),
              ],
              suggestions: ['先用生活化语言介绍自己。', '把玄学提示改写成表达偏好。'],
              avoidances: ['避免绝对性格判断。', '避免把解释当成系统决定。'],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppInfoSectionCard(
              title: '当前画像',
              subtitle: '八字 / 星象 / 五行 / 大运 / 流年 / 参考状态',
              leadingIcon: Icons.auto_graph_rounded,
              child: astroAsync.when(
                loading: () =>
                    AstroProfileStateView(spec: astroProfileLoadingSpec('画像')),
                error: (e, _) {
                  final spec = astroProfileErrorSpec('画像', e);
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: spec.actionLabel == '去登录'
                        ? () => context.go(AppRouteNames.login)
                        : reloadAstro,
                  );
                },
                data: (profile) {
                  if (profile == null) {
                    final spec = astroProfileEmptySpec('画像');
                    return AstroProfileStateView(
                      spec: spec,
                      onAction: () {
                        reloadAstro();
                      },
                    );
                  }
                  final birthTime = (profile['birth_time'] ?? '').toString();
                  final birthPlace = sanitizeProfileDisplayBirthPlace(
                    (profile['birth_place'] ??
                            profile['private_birth_place'] ??
                            '')
                        .toString(),
                    emptyValue: '',
                  );
                  final birthLat = profile['birth_lat'];
                  final birthLng = profile['birth_lng'];
                  final bazi = (profile['bazi'] ?? '').toString();
                  final trueSolarTime = (profile['true_solar_time'] ?? '')
                      .toString();
                  final locationShiftMinutes =
                      profile['location_shift_minutes'];
                  final longitudeOffsetMinutes =
                      profile['longitude_offset_minutes'];
                  final equationOfTimeMinutes =
                      profile['equation_of_time_minutes'];
                  final positionSignature =
                      (profile['position_signature'] ?? '').toString();
                  final locationSource = (profile['location_source'] ?? '')
                      .toString();
                  final accuracy = _astroAccuracyLabel(
                    (profile['accuracy'] ?? '').toString(),
                  );
                  final confidence = _astroConfidenceLabel(
                    (profile['confidence'] ?? '').toString(),
                  );
                  final westernEngine = _westernEngineLabel(
                    (profile['western_engine'] ?? '').toString(),
                  );
                  final westernPrecision = _westernPrecisionLabel(
                    (profile['western_precision'] ?? '').toString(),
                  );
                  final westernConfidence = _westernConfidenceLabel(
                    (profile['western_confidence'] ?? '').toString(),
                  );
                  final sunSign = (profile['sun_sign'] ?? '').toString();
                  final moonSign = (profile['moon_sign'] ?? '').toString();
                  final ascSign = (profile['asc_sign'] ?? '').toString();
                  final ziwei =
                      (profile['ziwei'] as Map<String, dynamic>? ?? const {});
                  final majorThemes =
                      (ziwei['major_themes'] as Map<String, dynamic>? ??
                      const {});
                  final ziweiEngine = (ziwei['engine'] ?? '').toString();
                  final ziweiPrecision = (ziwei['precision'] ?? '').toString();
                  final ziweiConfidence = (ziwei['confidence'] ?? '')
                      .toString();
                  final daYun =
                      (profile['da_yun'] as List<dynamic>? ?? const [])
                          .take(4)
                          .toList();
                  final liuNian =
                      (profile['liu_nian'] as List<dynamic>? ?? const [])
                          .take(5)
                          .toList();
                  final wuXing =
                      (profile['wu_xing'] as Map<String, dynamic>? ?? const {});
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AstroSectionCard(
                        title: '西洋本命盘详情',
                        subtitle: '查看行星落宫、宫位状态与星盘来源说明',
                        icon: Icons.public_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前页保留画像摘要；行星宫位列表、星盘来源与外部对照状态请进入详情页查看。外部对照未完成时，以详情页状态提示为准。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: t.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                            SizedBox(height: t.spacing.sm),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    context.push(AppRouteNames.astroNatalChart),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('查看行星落宫'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '反馈星盘 / 紫微显示问题',
                        subtitle: '生成本地体验反馈草稿',
                        icon: Icons.rate_review_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '如果星盘、八字或紫微展示和你的对照结果不一致，请生成反馈草稿；不会自动修改资料、星盘或匹配结果。',
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
                                    'category': 'astro_display',
                                    'source': 'astro',
                                  },
                                ).toString(),
                              ),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('反馈星盘 / 紫微显示'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '基础输入',
                        subtitle: '出生时间、出生地点与校正信息',
                        icon: Icons.pin_drop_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (birthTime.isNotEmpty)
                              AstroKeyValueRow(
                                label: '出生时间',
                                value: birthTime,
                                emphasis: true,
                              ),
                            if (birthTime.isNotEmpty && birthPlace.isNotEmpty)
                              SizedBox(height: t.spacing.xxs),
                            if (birthPlace.isNotEmpty)
                              AstroKeyValueRow(
                                label: '出生地点',
                                value: birthPlace,
                                emphasis: true,
                              ),
                            if (birthPlace.isNotEmpty &&
                                (birthLat != null || birthLng != null))
                              SizedBox(height: t.spacing.xxs),
                            if (birthLat != null || birthLng != null)
                              AstroKeyValueRow(
                                label: '出生地校正',
                                value: '已记录，用于排盘校正；页面不展示具体坐标数值',
                              ),
                            if (bazi.isNotEmpty) ...[
                              SizedBox(height: t.spacing.xs),
                              AstroKeyValueRow(
                                label: '八字',
                                value: bazi,
                                emphasis: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroDisclosureCard(
                        title: '来源与展示边界',
                        subtitle: '排盘校正、参考状态和说明标签默认收起',
                        icon: Icons.tune_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (trueSolarTime.isNotEmpty)
                              AstroKeyValueRow(
                                label: '真太阳时',
                                value: trueSolarTime,
                                emphasis: true,
                              ),
                            if (trueSolarTime.isNotEmpty)
                              SizedBox(height: t.spacing.xxs),
                            if (locationShiftMinutes != null ||
                                longitudeOffsetMinutes != null ||
                                equationOfTimeMinutes != null)
                              AstroKeyValueRow(
                                label: '位置修正',
                                value:
                                    '${locationShiftMinutes ?? '-'} 分钟（经度${longitudeOffsetMinutes ?? '-'} / 均时差${equationOfTimeMinutes ?? '-'}）',
                              ),
                            if (positionSignature.isNotEmpty) ...[
                              SizedBox(height: t.spacing.xxs),
                              AstroKeyValueRow(
                                label: '位置签名',
                                value:
                                    '$positionSignature${locationSource.isNotEmpty ? '（$locationSource）' : ''}',
                              ),
                            ],
                            if (accuracy.isNotEmpty ||
                                confidence.isNotEmpty ||
                                westernEngine.isNotEmpty ||
                                westernPrecision.isNotEmpty ||
                                westernConfidence.isNotEmpty) ...[
                              SizedBox(height: t.spacing.xs),
                              if (accuracy.isNotEmpty ||
                                  confidence.isNotEmpty) ...[
                                Text(
                                  '八字参考状态',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '${accuracy.isEmpty ? '-' : accuracy} / 参考程度 ${confidence.isEmpty ? '-' : confidence}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                              if (westernEngine.isNotEmpty ||
                                  westernPrecision.isNotEmpty ||
                                  westernConfidence.isNotEmpty) ...[
                                SizedBox(height: t.spacing.sm),
                                Text(
                                  '西洋星盘参考状态',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '资料来源 ${westernEngine.isEmpty ? '-' : westernEngine} · 计算口径 ${westernPrecision.isEmpty ? '-' : westernPrecision} · 参考程度 ${westernConfidence.isEmpty ? '-' : westernConfidence}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                            ],
                            if (ziweiEngine.isNotEmpty ||
                                ziweiPrecision.isNotEmpty ||
                                ziweiConfidence.isNotEmpty) ...[
                              SizedBox(height: t.spacing.sm),
                              Text(
                                '紫微主星状态',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              Text(
                                '资料来源 ${ziweiEngine.isEmpty ? '-' : ziweiEngine} · 展示口径 ${ziweiPrecision.isEmpty ? '-' : _ziweiPrecisionLabel(ziweiPrecision)} · 参考程度 ${ziweiConfidence.isEmpty ? '-' : ziweiConfidence} · 主星字段已作为低权重辅助参考',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                            ],
                            if (profile['notes'] != null &&
                                (profile['notes'] as List).isNotEmpty) ...[
                              SizedBox(height: t.spacing.sm),
                              Text(
                                '说明标签',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: astroList(profile['notes'])
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
                                                color: t.textSecondary
                                                    .withValues(alpha: 0.82),
                                                height: 1.35,
                                              ),
                                        ),
                                      );
                                    })
                                    .toList(growable: false),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '模块摘要',
                        subtitle: '星象、五行与紫微主星参考',
                        icon: Icons.auto_awesome_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sunSign.isNotEmpty ||
                                moonSign.isNotEmpty ||
                                ascSign.isNotEmpty)
                              Text(
                                '星象：太阳$sunSign  月亮$moonSign  上升$ascSign',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                            if (sunSign.isNotEmpty ||
                                moonSign.isNotEmpty ||
                                ascSign.isNotEmpty)
                              SizedBox(height: t.spacing.xxs),
                            if (wuXing.isNotEmpty)
                              Text(
                                '五行：木${wuXing['木'] ?? 0} 火${wuXing['火'] ?? 0} 土${wuXing['土'] ?? 0} 金${wuXing['金'] ?? 0} 水${wuXing['水'] ?? 0}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                            if (wuXing.isNotEmpty)
                              SizedBox(height: t.spacing.sm),
                            if (ziwei.isNotEmpty) ...[
                              Text(
                                '紫微主星参考',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              if (_ziweiSummaryLabel(
                                ziwei['summary'],
                              ).isNotEmpty) ...[
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '摘要：${_ziweiSummaryLabel(ziwei['summary'])}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                              if ((ziwei['life_palace'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  '命宫：${ziwei['life_palace']}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              if ((ziwei['body_palace'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  '身宫：${ziwei['body_palace']}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              if (majorThemes.isNotEmpty)
                                Text(
                                  '主题：关系${majorThemes['relationship_bias'] ?? '-'} / 事业${majorThemes['career_bias'] ?? '-'} / 财帛${majorThemes['wealth_bias'] ?? '-'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              SizedBox(height: t.spacing.sm),
                              Text(
                                '十二宫、主星与高级字段扩展状态详见紫微主星详情。',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.textSecondary,
                                      height: 1.45,
                                    ),
                              ),
                              SizedBox(height: t.spacing.sm),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push(AppRouteNames.astroZiwei),
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: const Text('查看紫微主星详情'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '阶段信息',
                        subtitle: '大运与流年节选',
                        icon: Icons.timeline_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (daYun.isNotEmpty) ...[
                              Text(
                                '大运（节选）',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              ...daYun.map(
                                (e) => Text(
                                  '• ${e is Map ? (e['gan_zhi'] ?? '-') : '-'} ${e is Map ? ((e['start_year'] ?? '').toString()) : ''}~${e is Map ? ((e['end_year'] ?? '').toString()) : ''}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ),
                              SizedBox(height: t.spacing.sm),
                            ],
                            if (liuNian.isNotEmpty) ...[
                              Text(
                                '流年（节选）',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              ...liuNian.map(
                                (e) => Text(
                                  '• ${e is Map ? (e['year'] ?? '-') : '-'}年 ${e is Map ? (e['gan_zhi'] ?? '-') : '-'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 120),
            child: AppInfoSectionCard(
              title: '画像数据来源',
              subtitle: '保存资料后会自动整理并刷新各页',
              leadingIcon: Icons.storage_rounded,
              child: Text(
                '当前页面读取已保存的画像摘要（八字 / 大运 / 流年 / 五行），并同步展示星盘与紫微的关键字段。若你刚在编辑资料页修改了出生时间或出生地，返回本页时会自动读取最新结果；本地只负责展示，不参与计算。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _westernEngineLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'legacy_input' => '资料输入口径',
    'kerykeion' => '本命盘计算服务',
    'unknown' || '' => '',
    _ => '本命盘计算服务',
  };
}

String _astroAccuracyLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'canonical_server' => '后端标准口径',
    'calendar_canonical' => '历法口径',
    'legacy_input' => '资料输入口径',
    'legacy_estimate' => '估算口径，待外部校验',
    'unknown' || '' => '',
    _ => '已记录，待外部校验',
  };
}

String _astroConfidenceLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == '0.0') return '';
  return '仅供展示参考';
}

String _westernPrecisionLabel(String value) {
  final normalized = value.toLowerCase().trim();
  return switch (normalized) {
    'legacy_estimate' => '估算口径，待外部校验',
    'calendar_canonical' => '历法口径',
    'not_validated' => '待外部校验',
    'unknown' || '' => '',
    _ => '已记录，待外部校验',
  };
}

String _ziweiPrecisionLabel(String value) {
  final normalized = value.toLowerCase().trim();
  if (normalized.isEmpty) return '';
  if (normalized.contains('not_validated') ||
      normalized.contains('selected_fields') ||
      normalized.contains('p0')) {
    return '主星字段 / 高级字段后续扩展';
  }
  return '主星字段';
}

String _ziweiSummaryLabel(dynamic value) {
  final raw = astroText(value, '').trim();
  if (raw.isEmpty) return '';
  if (_hasTechnicalZiweiMarker(raw)) {
    return '当前展示十二宫、地支、命宫、身宫与十四主星，用于关系理解的低权重辅助参考；高级字段仍待后续校验。';
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

String _westernConfidenceLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == '0.0') return '';
  return '仅供展示参考';
}
