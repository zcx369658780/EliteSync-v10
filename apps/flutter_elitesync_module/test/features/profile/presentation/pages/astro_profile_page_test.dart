import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_bazi_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_natal_chart_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_overview_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_ziwei_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_overview_components.dart';

void main() {
  testWidgets('AstroOverviewPage presents visual relationship reading cards', (
    tester,
  ) async {
    await _pumpAstroOverviewRoute(tester, _astroSummaryProfile());

    await tester.pumpAndSettle();

    expect(find.text('星盘关系参考'), findsOneWidget);
    expect(find.text('星盘仅供自愿参考，不决定匹配、排序或关系结果。'), findsOneWidget);
    expect(find.text('你的三类星盘线索'), findsNothing);
    expect(find.textContaining('本命盘、八字和紫微详情'), findsNothing);
    expect(find.text('星盘摘要'), findsNothing);
    expect(find.textContaining('沟通、情绪、节奏'), findsNothing);
    expect(find.text('太阳 摩羯'), findsNothing);
    expect(find.text('月亮 巨蟹'), findsNothing);
    expect(find.text('上升 双子'), findsNothing);
    expect(find.text('沟通'), findsNothing);
    expect(find.text('情绪'), findsNothing);
    expect(find.text('节奏'), findsNothing);
    expect(find.text('先看表达方式。'), findsNothing);
    expect(find.text('留意安全感。'), findsNothing);
    expect(find.text('慢一点确认。'), findsNothing);

    expect(find.text('西洋本命盘'), findsOneWidget);
    expect(find.text('八字节律'), findsOneWidget);
    expect(find.text('紫微主星'), findsWidgets);
    expect(find.textContaining('如何提示表达方式'), findsOneWidget);
    expect(find.textContaining('先看长期节律'), findsOneWidget);
    expect(find.textContaining('先看命宫、身宫'), findsOneWidget);
    expect(find.text('查看详细说明'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('使用说明'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('星盘是可选参考'), findsOneWidget);
    expect(find.textContaining('不决定匹配、排序或关系结果'), findsOneWidget);
    expect(find.textContaining('来源与边界'), findsNothing);
    expect(find.textContaining('星盘真值'), findsNothing);
    expect(find.textContaining('技术内容'), findsNothing);
    expect(find.textContaining('不直接改变匹配结果'), findsNothing);
    expect(find.textContaining('每个系统都标注'), findsNothing);
    expect(find.textContaining('玄学总览'), findsNothing);
    expect(find.textContaining('关系评分'), findsNothing);
    expect(find.textContaining('derived-only'), findsNothing);
    expect(find.textContaining('display-only'), findsNothing);
    expect(find.textContaining('advanced-context'), findsNothing);
    expect(find.text('详情入口'), findsNothing);
    expect(find.text('画像详情'), findsNothing);
    expect(find.byType(AstroLayeredSystemCard), findsNWidgets(3));
    final accessibleCopy = tester
        .widgetList<Tooltip>(find.byType(Tooltip))
        .map((tooltip) => tooltip.message ?? '')
        .join('\n');
    for (final forbidden in [
      'Placidus',
      'Tropical',
      '字段级',
      '外部样例',
      '四化',
      '飞星',
      '校验',
      '全量验收',
      '匹配评分',
    ]) {
      expect(accessibleCopy, isNot(contains(forbidden)));
    }
  });

  testWidgets('AstroOverviewPage exposes exactly three primary routes', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final route in [
      ('查看本命盘详情', 'NATAL ROUTE'),
      ('查看八字详情', 'BAZI ROUTE'),
      ('查看紫微详情', 'ZIWEI ROUTE'),
    ]) {
      await _pumpAstroOverviewRoute(tester, _astroSummaryProfile());
      await tester.pumpAndSettle();
      final action = find.bySemanticsLabel(route.$1);
      expect(action, findsOneWidget);
      await tester.scrollUntilVisible(
        action,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      final inkWell = find.descendant(
        of: action,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsWidgets);
      expect(tester.getSize(inkWell.first).height, greaterThanOrEqualTo(48));
      await tester.tap(inkWell.first);
      await tester.pumpAndSettle();
      expect(find.text(route.$2), findsOneWidget);
    }
    semantics.dispose();
  });

  testWidgets('AstroOverviewPage tabs through the three primary choices', (
    tester,
  ) async {
    await _pumpAstroOverviewRoute(tester, _astroSummaryProfile());
    await tester.pumpAndSettle();

    final labels = ['查看本命盘详情', '查看八字详情', '查看紫微详情'];
    var next = 0;
    for (var press = 0; press < 20 && next < labels.length; press++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focusedContext = tester.binding.focusManager.primaryFocus?.context;
      if (focusedContext != null &&
          find
              .descendant(
                of: find.byElementPredicate(
                  (element) => element == focusedContext,
                ),
                matching: find.text(labels[next]),
              )
              .evaluate()
              .isNotEmpty) {
        next++;
      }
    }
    expect(next, labels.length);
  });

  testWidgets(
    'AstroOverviewPage keeps loading error and unavailable distinct',
    (tester) async {
      final pending = Completer<Map<String, dynamic>?>();
      await _pumpAstroOverviewState(tester, () => pending.future);
      expect(find.textContaining('加载'), findsWidgets);

      await _pumpAstroOverviewState(
        tester,
        () => Future<Map<String, dynamic>?>.error(StateError('failed')),
      );
      await tester.pumpAndSettle();
      expect(find.text('星盘关系参考加载失败'), findsOneWidget);
      expect(find.textContaining('暂无'), findsNothing);

      await _pumpAstroOverviewState(tester, () async => null);
      await tester.pumpAndSettle();
      expect(find.textContaining('暂无'), findsWidgets);
      expect(find.text('星盘关系参考加载失败'), findsNothing);
    },
  );

  testWidgets('AstroOverviewPage supports narrow large-text reduced-motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await _pumpAstroOverviewRoute(tester, _astroSummaryProfile());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('星盘仅供自愿参考，不决定匹配、排序或关系结果。'), findsOneWidget);
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  testWidgets(
    'AstroProfilePage exposes conservative Western natal detail entry',
    (tester) async {
      await _pumpAstroProfileRoute(tester, _astroSummaryProfile());

      await tester.pumpAndSettle();

      expect(find.text('西洋本命盘详情'), findsWidgets);
      expect(find.text('查看行星落宫'), findsWidgets);
      expect(find.textContaining('行星、宫位列表'), findsWidgets);
      expect(find.textContaining('外部对照未完成'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('当前画像'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('参考状态'), findsWidgets);
      expect(find.textContaining('可信度'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('反馈星盘 / 紫微显示问题'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('反馈星盘 / 紫微显示问题'), findsWidgets);
      expect(find.text('反馈星盘 / 紫微显示'), findsWidgets);
      expect(find.textContaining('已验证'), findsNothing);
      expect(find.textContaining('精准'), findsNothing);
      expect(find.textContaining('已校准'), findsNothing);
    },
  );

  testWidgets('AstroProfilePage detail entry navigates to natal chart route', (
    tester,
  ) async {
    await _pumpAstroProfileRoute(tester, _astroSummaryProfile());

    await tester.pumpAndSettle();
    final cta = find.widgetWithText(FilledButton, '查看行星落宫').first;
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('NATAL ROUTE'), findsOneWidget);
  });

  testWidgets('AstroProfilePage exposes clickable Ziwei detail CTA', (
    tester,
  ) async {
    await _pumpAstroProfileRoute(tester, _astroSummaryProfile());

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('查看紫微主星详情'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final cta = find.widgetWithText(OutlinedButton, '查看紫微主星详情').first;
    expect(cta, findsOneWidget);

    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.textContaining('紫微主星排盘'), findsWidgets);
    expect(find.textContaining('命宫：太阴 / 卯'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('阅读边界').first,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('阅读边界').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('武曲禄(财帛/甲戌) / 贪狼权(福德/戊辰)'), findsOneWidget);
  });

  testWidgets('AstroBaziPage presents chart surfaces before long details', (
    tester,
  ) async {
    await _pumpBaziPage(tester, _astroSummaryProfile());

    expect(find.byKey(const ValueKey('bazi-chart-first-grid')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bazi-chart-first-wuxing')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bazi-detail-scope-hint')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bazi-readable-narrative')),
      findsOneWidget,
    );
    expect(find.text('八字'), findsNothing);
    expect(find.text('关系节律说明'), findsNothing);
    expect(find.text('八字关系节律参考'), findsOneWidget);
    expect(find.text('一句话理解相处节律'), findsOneWidget);
    expect(find.textContaining('相处节律', findRichText: true), findsWidgets);
    expect(find.text('摘要'), findsNothing);
    expect(find.text('维度'), findsNothing);
    expect(find.text('建议'), findsNothing);
    expect(find.text('先避免'), findsNothing);
    expect(find.text('来源与展示参数'), findsOneWidget);
    expect(find.text('生日'), findsNothing);

    final gridTop = tester.getTopLeft(
      find.byKey(const ValueKey('bazi-chart-first-grid')),
    );
    final summaryTop = tester.getTopLeft(find.text('八字关系节律参考').first);
    expect(gridTop.dy, lessThan(summaryTop.dy));

    await tester.scrollUntilVisible(
      find.text('来源与展示参数'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('来源与展示参数'));
    await tester.pumpAndSettle();

    expect(find.text('生日'), findsOneWidget);
    expect(find.text('出生地'), findsOneWidget);
    expect(find.textContaining('0.88'), findsOneWidget);
  });

  testWidgets('AstroProfilePage keeps technical details collapsed by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          astroSummaryProvider.overrideWith((ref) async {
            return {
              'birth_time': '1998-01-01 10:30',
              'birth_place': '北京动物园',
              'bazi': '戊寅 乙丑 庚午 辛巳',
              'true_solar_time': '1998-01-01 10:17',
              'accuracy': 'canonical_server',
              'confidence': '0.88',
              'western_engine': 'legacy_input',
              'western_precision': 'legacy_estimate',
              'western_confidence': '0.66',
              'sun_sign': '摩羯',
              'moon_sign': '巨蟹',
              'asc_sign': '双子',
              'ziwei': {
                'engine': 'ziwei_seed_estimate',
                'precision': 'approximate_not_validated',
                'confidence': '0.32',
                'external_oracle_status': 'not_validated',
                'display_only': true,
                'scoring_status': 'excluded_from_core_matching',
                'disclaimer': '当前为紫微试算参考，待外部排盘校验，不作为真实紫微排盘结论，暂不参与核心匹配评分。',
                'summary': '关系节奏偏慢',
              },
            };
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const AstroProfilePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('画像关系解释摘要'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('基础输入'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('北京动物园'), findsNothing);
    expect(find.text('已填写示例地点'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('来源与展示边界'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('来源与展示边界'), findsOneWidget);
    expect(find.textContaining('canonical_server'), findsNothing);
    expect(find.textContaining('legacy_input'), findsNothing);
    expect(find.textContaining('legacy_estimate'), findsNothing);

    await tester.tap(find.text('来源与展示边界'));
    await tester.pumpAndSettle();

    expect(find.textContaining('canonical_server'), findsNothing);
    expect(find.textContaining('legacy_input'), findsNothing);
    expect(find.textContaining('legacy_estimate'), findsNothing);
    expect(find.textContaining('后端标准口径'), findsWidgets);
    expect(find.textContaining('资料输入口径'), findsOneWidget);
    expect(find.textContaining('估算口径，待外部校验'), findsOneWidget);
  });

  testWidgets(
    'AstroZiweiPage shows formalized main-star copy with boundaries',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            astroSummaryProvider.overrideWith(
              (ref) async => _astroSummaryProfile(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: const AstroZiweiPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('紫微主星排盘'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ziwei-detail-scope-hint')),
        findsOneWidget,
      );
      expect(find.text('紫微分视图盘面'), findsOneWidget);
      expect(find.text('紫微主星关系参考'), findsWidgets);
      expect(find.textContaining('不进入匹配评分'), findsWidgets);
      expect(find.textContaining('不作关系结论'), findsWidgets);
      expect(find.text('反馈紫微显示问题'), findsOneWidget);
      expect(find.text('反馈紫微 / 飞星显示'), findsOneWidget);
      expect(find.textContaining('当前为紫微试算参考'), findsNothing);
      expect(find.textContaining('暂不参与核心匹配评分'), findsNothing);
      expect(find.textContaining('紫微主星排盘测试版'), findsNothing);
      expect(find.textContaining('CECE P0 oracle transcript'), findsNothing);
      expect(find.textContaining('selected Ziwei fields'), findsNothing);
      expect(find.textContaining('ziwei_cece_p0_oracle_minimum'), findsNothing);
      expect(find.textContaining('整理方式'), findsNothing);
      expect(find.textContaining('置信'), findsNothing);
      expect(find.textContaining('0.58'), findsNothing);
      expect(find.textContaining('命宫：太阴 / 卯'), findsOneWidget);
      expect(find.textContaining('身宫：父母宫'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ziwei-readable-narrative')),
        findsOneWidget,
      );
      expect(find.text('一句话理解互动角色'), findsOneWidget);
      expect(
        find.textContaining('互动角色和表达边界', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('自我角色'), findsNothing);
      expect(find.text('互动位置'), findsNothing);
      expect(find.text('表达边界'), findsNothing);
      expect(find.text('摘要'), findsNothing);
      expect(find.text('维度'), findsNothing);
      expect(find.text('建议'), findsNothing);
      expect(find.text('先避免'), findsNothing);
      expect(find.text('不作关系结论 / 不进入匹配评分'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ziwei-chart-first-split-view')),
        findsOneWidget,
      );

      final splitTop = tester.getTopLeft(
        find.byKey(const ValueKey('ziwei-chart-first-split-view')),
      );
      final summaryTop = tester.getTopLeft(find.text('紫微主星关系参考').first);
      expect(splitTop.dy, lessThan(summaryTop.dy));
      expect(find.text('飞星候选 / 人工校准中'), findsNothing);
      expect(find.textContaining('候选线条'), findsNothing);
      expect(find.textContaining('人工复核'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('四化参考说明'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('四化参考说明'));
      await tester.pumpAndSettle();

      expect(find.textContaining('四化参考会保留在下方来源详情中'), findsWidgets);
      expect(find.textContaining('不作为关系结论'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('阅读边界').first,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('阅读边界').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('已对照字段参考'), findsWidgets);
      expect(find.textContaining('武曲禄(财帛/甲戌) / 贪狼权(福德/戊辰)'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('紫微分视图盘面'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('紫微分视图盘面'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ziwei-split-view-tabs')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ziwei-view-tab-sanhe')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ziwei-view-tab-flying-star')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ziwei-view-tab-sihua')),
        findsOneWidget,
      );

      expect(
        find.byKey(const ValueKey('ziwei-split-grid-sanhe')),
        findsOneWidget,
      );
      expect(find.textContaining('三合视图：聚焦主盘宫位'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ziwei-flying-star-overlay-lines')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('ziwei-sihua-badge-武曲禄')), findsNothing);
      expect(find.byKey(const ValueKey('ziwei-flying-badge-禄')), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('ziwei-view-tab-flying-star')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ziwei-split-grid-flying-star')),
        findsOneWidget,
      );
      expect(find.textContaining('飞星视图：进阶线索'), findsWidgets);
      expect(find.textContaining('起止语义需要进一步人工复核'), findsNothing);
      expect(
        find.byKey(const ValueKey('ziwei-flying-star-overlay-lines')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('ziwei-flying-badge-禄')), findsWidgets);
      expect(find.byKey(const ValueKey('ziwei-sihua-badge-武曲禄')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('ziwei-view-tab-sihua')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ziwei-split-grid-sihua')),
        findsOneWidget,
      );
      expect(find.textContaining('四化视图：把四化参考'), findsWidgets);
      expect(
        find.byKey(const ValueKey('ziwei-sihua-badge-武曲禄')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ziwei-sihua-badge-贪狼权')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ziwei-flying-star-overlay-lines')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('ziwei-flying-badge-禄')), findsNothing);

      await tester.scrollUntilVisible(
        find.text('进阶线索详情'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('进阶线索详情'));
      await tester.pumpAndSettle();

      expect(find.text('进阶线索详情'), findsOneWidget);
      expect(find.textContaining('仍在校准'), findsWidgets);
      expect(find.textContaining('human_review_required'), findsNothing);
      expect(find.textContaining('进阶线索：化禄 -> 疾厄宫/癸酉'), findsOneWidget);
      expect(find.textContaining('命宫相关线索'), findsWidgets);
      expect(find.textContaining('待真人校准'), findsNothing);
      expect(find.textContaining('只作进阶辅助参考'), findsWidgets);
      expect(find.textContaining('不代表命宫飞星正确性'), findsNothing);
      expect(find.textContaining(_joinedText('飞星已', '正确')), findsNothing);
      expect(find.textContaining(_joinedText('命宫飞星已', '正确')), findsNothing);
      expect(find.textContaining(_joinedText('完整紫微斗数', '正确')), findsNothing);
      expect(find.textContaining(_joinedText('已完成飞星', '验收')), findsNothing);

      await tester.scrollUntilVisible(
        find.text('阅读边界').first,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('待补充校验'), findsWidgets);
      expect(
        find.textContaining('十二宫 / 主星 / 四化参考 / 辅星 / 星曜状态'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.textContaining('紫微、天府').first,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('紫微、天府'), findsWidgets);
      expect(find.textContaining('廉贞、天相'), findsWidgets);
      expect(find.textContaining('用于关系节奏参考'), findsWidgets);
      expect(find.textContaining('太阴陷'), findsWidgets);
      expect(find.textContaining('待校验'), findsNothing);
      expect(find.textContaining('已验证'), findsNothing);
      expect(find.textContaining('精准'), findsNothing);
      expect(find.textContaining('正统'), findsNothing);
      expect(find.textContaining('标准紫微地盘'), findsNothing);
      expect(find.textContaining(_joinedText('完整紫微斗数', '正确性')), findsNothing);
      expect(find.textContaining('命宫飞星已修复'), findsNothing);
      expect(find.textContaining('四化完整飞星校准'), findsNothing);
      expect(find.textContaining('canonical'), findsNothing);
    },
  );

  testWidgets('AstroZiweiPage falls back safely for legacy Ziwei payload', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          astroSummaryProvider.overrideWith(
            (ref) async => _legacyZiweiProfile(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const AstroZiweiPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('命宫：天机 / 地支未返回'), findsOneWidget);
    expect(find.textContaining('身宫：夫妻宫'), findsOneWidget);
    expect(find.text('不作关系结论 / 不进入匹配评分'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('阅读边界').first,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('阅读边界').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('待补充校验'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('进阶线索详情'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('进阶线索详情'));
    await tester.pumpAndSettle();

    expect(find.text('进阶线索详情'), findsOneWidget);
    expect(find.text('暂无进阶线索详情'), findsOneWidget);
    expect(find.textContaining('当前样本未返回进阶线索详情'), findsWidgets);
    expect(find.textContaining('不补写内容'), findsOneWidget);
    expect(find.textContaining(_joinedText('飞星已', '正确')), findsNothing);
    expect(find.textContaining(_joinedText('已完成飞星', '验收')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AstroNatalChartPage presents chart before details', (
    tester,
  ) async {
    await _pumpNatalChartPage(tester, _westernNatalProfile());

    const chartKey = ValueKey('western-natal-chart-first-svg');
    const narrativeKey = ValueKey('western-natal-readable-narrative');

    expect(find.byKey(chartKey), findsOneWidget);
    expect(find.byKey(narrativeKey), findsOneWidget);
    expect(
      find.byKey(const ValueKey('western-natal-detail-scope-hint')),
      findsOneWidget,
    );
    expect(find.text('西洋星盘'), findsNothing);
    expect(find.text('西洋本命盘阅读引导'), findsOneWidget);
    expect(find.text('来源摘要'), findsOneWidget);
    expect(find.text('来源与显示详情'), findsOneWidget);
    expect(find.text('行星与落宫明细'), findsOneWidget);
    expect(find.text('显示参数'), findsOneWidget);
    expect(find.text('已保存星盘来源'), findsNothing);

    final chartTop = tester.getTopLeft(find.byKey(chartKey));
    final narrativeTop = tester.getTopLeft(find.byKey(narrativeKey));
    final sourceTop = tester.getTopLeft(find.text('来源摘要').first);

    expect(chartTop.dy, lessThan(narrativeTop.dy));
    expect(narrativeTop.dy, lessThan(sourceTop.dy));
    expect(chartTop.dy, lessThan(sourceTop.dy));
  });

  testWidgets(
    'AstroNatalChartPage explains chart in readable narrative first',
    (tester) async {
      await _pumpNatalChartPage(tester, _westernNatalProfile());

      await _scrollToText(tester, '西洋本命盘阅读引导');

      expect(find.text('一句话理解沟通风格'), findsOneWidget);
      expect(find.textContaining('沟通风格地图', findRichText: true), findsOneWidget);
      expect(
        find.textContaining('表达、情绪节奏和互动切入点', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('摘要'), findsNothing);
      expect(find.text('维度'), findsNothing);
      expect(find.text('建议'), findsNothing);
      expect(find.text('先避免'), findsNothing);
      expect(find.text('表达方式'), findsNothing);
      expect(find.text('情绪节奏'), findsNothing);
      expect(find.text('互动切入'), findsNothing);
      expect(find.textContaining('关系结论'), findsWidgets);
      expect(find.textContaining('匹配结果'), findsWidgets);
      expect(find.textContaining(['关系', '证明'].join()), findsNothing);
      expect(find.textContaining(['必然', '适合'].join()), findsNothing);
      expect(find.textContaining(['改变匹配', '排序'].join()), findsNothing);
      expect(find.textContaining(['自动同步到正式', '资料'].join()), findsNothing);
    },
  );

  testWidgets('AstroNatalChartPage displays saved planet house summary', (
    tester,
  ) async {
    await _pumpNatalChartPage(
      tester,
      _westernNatalProfile(
        planetsData: [
          {'name': 'Sun', 'sign': '狮子', 'house': '第五宫', 'position': '12°34′'},
        ],
      ),
    );

    await _scrollToText(tester, '行星与落宫明细');
    await tester.tap(find.text('行星与落宫明细'));
    await tester.pumpAndSettle();
    await _scrollToText(tester, '第五宫');

    expect(find.textContaining('展开查看已保存字段'), findsOneWidget);
    expect(find.textContaining('狮子 / 第五宫'), findsOneWidget);
    expect(find.textContaining('planets_data'), findsNothing);
  });

  testWidgets('AstroNatalChartPage localizes interaction angle labels', (
    tester,
  ) async {
    await _pumpNatalChartPage(
      tester,
      _westernNatalProfile(
        aspectsData: [
          {'p1_name': 'Sun', 'aspect': 'sextile', 'p2_name': 'Moon'},
          {'p1_name': 'Chiron', 'aspect': 'sextile', 'p2_name': 'Moon'},
          {'p1_name': 'Mystery_Point', 'aspect': 'sextile', 'p2_name': 'Moon'},
        ],
      ),
    );

    await _scrollToText(tester, '互动角度摘要');

    expect(find.text('互动角度摘要'), findsOneWidget);
    expect(find.textContaining('可读标签'), findsOneWidget);
    expect(find.text('太阳 · 六合 · 月亮'), findsOneWidget);
    expect(find.text('凯龙星 · 六合 · 月亮'), findsOneWidget);
    expect(find.text('Mystery_Point · 六合 · 月亮'), findsOneWidget);
    expect(find.textContaining('Sun · sextile · Moon'), findsNothing);
    expect(find.textContaining('Chiron · sextile · Moon'), findsNothing);
    expect(find.textContaining('关系结果'), findsOneWidget);
  });

  testWidgets(
    'AstroNatalChartPage softens raw degree and enum placement labels',
    (tester) async {
      await _pumpNatalChartPage(
        tester,
        _westernNatalProfile(
          planetsData: [
            {
              'name': 'Sun',
              'sign': 'Vir',
              'house': 'Ninth_House',
              'position': '12.638327575804595',
            },
          ],
          extra: {
            'houses_data': [
              {'name': 'First_House', 'sign': 'Virgo', 'position': 204.454321},
            ],
          },
        ),
      );

      await _scrollToText(tester, '行星与落宫明细');
      await tester.tap(find.text('行星与落宫明细'));
      await tester.pumpAndSettle();
      await _scrollToText(tester, '处女座 / 第九宫');

      expect(find.text('12.6°'), findsOneWidget);
      expect(find.textContaining('12.638327575804595'), findsNothing);
      expect(find.textContaining('Vir / Ninth_House'), findsNothing);
      expect(find.textContaining('处女座 / 第九宫'), findsOneWidget);

      await _scrollToText(tester, '宫位摘要');

      expect(find.text('第一宫'), findsOneWidget);
      expect(find.text('204.5°'), findsOneWidget);
      expect(find.textContaining('First_House'), findsNothing);
    },
  );

  testWidgets('AstroNatalChartPage does not infer house from legacy signs', (
    tester,
  ) async {
    await _pumpNatalChartPage(
      tester,
      _westernNatalProfile(
        extra: {'sun_sign': '第五宫', 'moon_sign': '第七宫', 'asc_sign': '第一宫'},
        planetsData: [
          {'name': 'Sun', 'sign': '狮子', 'position': '12°34′'},
        ],
      ),
    );

    await _scrollToText(tester, '行星与落宫明细');
    await tester.tap(find.text('行星与落宫明细'));
    await tester.pumpAndSettle();
    await _scrollToText(tester, '宫位未返回');

    expect(find.textContaining('狮子 / 宫位未返回'), findsOneWidget);
    expect(find.textContaining('狮子 / 第五宫'), findsNothing);
  });

  testWidgets('AstroNatalChartPage guards degraded house truth display', (
    tester,
  ) async {
    await _pumpNatalChartPage(
      tester,
      _westernNatalProfile(
        houseTruthStatus: 'not_house_truth',
        planetsData: [
          {'name': 'Sun', 'sign': '狮子', 'house': '第五宫', 'position': '12°34′'},
        ],
      ),
    );

    await _scrollToText(tester, '来源与显示详情');
    await tester.tap(find.text('来源与显示详情'));
    await tester.pumpAndSettle();
    await _scrollToText(tester, '行星与落宫明细');
    await tester.tap(find.text('行星与落宫明细'));
    await tester.pumpAndSettle();

    expect(find.textContaining('宫位待来源确认'), findsOneWidget);
    expect(find.textContaining('宫位待确认'), findsOneWidget);
    expect(find.textContaining('已验证'), findsNothing);
    expect(find.textContaining('精准落宫'), findsNothing);
  });

  testWidgets(
    'AstroNatalChartPage keeps oracle and policy wording conservative',
    (tester) async {
      await _pumpNatalChartPage(tester, _westernNatalProfile());

      await _scrollToText(tester, '来源与显示详情');
      await tester.tap(find.text('来源与显示详情'));
      await tester.pumpAndSettle();

      expect(find.textContaining('外部对照：未完成'), findsWidgets);
      expect(find.textContaining('保存黄道：Tropical / 回归黄道'), findsWidgets);
      expect(find.textContaining('保存宫位：Placidus / 普拉西德宫制'), findsWidgets);
      expect(find.textContaining('已通过外部星盘校验'), findsNothing);
      expect(find.textContaining('已验证'), findsNothing);
      expect(find.textContaining('已校准'), findsNothing);
      expect(find.textContaining('Astro.com 校验通过'), findsNothing);
    },
  );

  testWidgets('AstroNatalChartPage labels Whole as local workbench context', (
    tester,
  ) async {
    await _pumpNatalChartPage(tester, _westernNatalProfile());

    await _scrollToText(tester, '显示参数');
    await tester.tap(find.text('显示参数'));
    await tester.pumpAndSettle();

    expect(find.textContaining('本机显示参数：'), findsWidgets);
    expect(find.textContaining('整宫制 / 普拉西德宫制'), findsOneWidget);
    expect(find.textContaining('Whole / Placidus'), findsNothing);
    expect(find.textContaining('宫位=整宫制'), findsWidgets);
    expect(find.textContaining('宫位=Whole'), findsNothing);
    expect(find.textContaining('保存宫位：Whole'), findsNothing);
  });

  testWidgets('AstroNatalChartPage hides raw engineering source markers', (
    tester,
  ) async {
    await _pumpNatalChartPage(
      tester,
      _westernNatalProfile(
        extra: {
          'western_engine': 'legacy_input',
          'western_precision': 'legacy_estimate',
          'western_confidence': '0.66',
          'location_source': 'longitude_based',
          'notes': [
            'recomputed_from_basic_profile',
            'location_source:longitude_based',
            'location_shift_minutes:-62',
            'canonical_confidence:0.88',
            'western_confidence:0.66',
            'ziwei_engine:ziwei_canonical_server',
            'ziwei_confidence:0.84',
            'canonical_source:lunar_php',
            'canonical_accuracy:canonical_server',
            'precision:calendar_canonical',
            'rollout_bazi:bazi_global_enabled',
          ],
        },
      ),
    );

    await _scrollToText(tester, '显示参数');
    await tester.tap(find.text('显示参数'));
    await tester.pumpAndSettle();
    await _scrollToText(tester, '星盘来源参数');
    await _scrollToText(tester, '来源与参考状态');

    expect(find.textContaining('legacy_input'), findsNothing);
    expect(find.textContaining('legacy_estimate'), findsNothing);
    expect(find.textContaining('canonical_source'), findsNothing);
    expect(find.textContaining('canonical_accuracy'), findsNothing);
    expect(find.textContaining('canonical_confidence'), findsNothing);
    expect(find.textContaining('western_confidence'), findsNothing);
    expect(find.textContaining('ziwei_engine'), findsNothing);
    expect(find.textContaining('ziwei_confidence'), findsNothing);
    expect(find.textContaining('location_shift_minutes'), findsNothing);
    expect(find.textContaining('参数与追踪字段'), findsNothing);
    expect(find.textContaining('rollout_bazi'), findsNothing);
    expect(find.textContaining('资料输入口径'), findsOneWidget);
    expect(find.textContaining('估算口径，待外部校验'), findsOneWidget);
    expect(find.textContaining('出生地经度校正'), findsWidgets);
    expect(find.textContaining('已按当前基础资料重新计算'), findsOneWidget);
    expect(find.textContaining('时间修正参考：-62 分钟'), findsOneWidget);
    expect(find.textContaining('综合参考状态：已记录'), findsOneWidget);
    expect(find.textContaining('西洋星盘参考状态：仅供展示参考'), findsOneWidget);
    expect(find.textContaining('紫微展示来源：标准排盘服务'), findsOneWidget);
    expect(find.textContaining('紫微展示参考状态：仅供展示参考'), findsOneWidget);
  });
}

Future<void> _pumpAstroProfileRoute(
  WidgetTester tester,
  Map<String, dynamic> profile,
) async {
  final router = GoRouter(
    initialLocation: AppRouteNames.astroProfile,
    routes: [
      GoRoute(
        path: AppRouteNames.astroProfile,
        builder: (context, state) => const AstroProfilePage(),
      ),
      GoRoute(
        path: AppRouteNames.astroNatalChart,
        builder: (context, state) => const Scaffold(body: Text('NATAL ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.astroZiwei,
        builder: (context, state) => const AstroZiweiPage(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [astroSummaryProvider.overrideWith((ref) async => profile)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    ),
  );
}

Future<void> _pumpAstroOverviewState(
  WidgetTester tester,
  Future<Map<String, dynamic>?> Function() load,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [astroSummaryProvider.overrideWith((ref) => load())],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const AstroOverviewPage(),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpAstroOverviewRoute(
  WidgetTester tester,
  Map<String, dynamic> profile,
) async {
  final router = GoRouter(
    initialLocation: AppRouteNames.astroOverview,
    routes: [
      GoRoute(
        path: AppRouteNames.astroOverview,
        builder: (context, state) => const AstroOverviewPage(),
      ),
      GoRoute(
        path: AppRouteNames.astroProfile,
        builder: (context, state) =>
            const Scaffold(body: Text('PROFILE ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.astroNatalChart,
        builder: (context, state) => const Scaffold(body: Text('NATAL ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.astroBazi,
        builder: (context, state) => const Scaffold(body: Text('BAZI ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.astroZiwei,
        builder: (context, state) => const Scaffold(body: Text('ZIWEI ROUTE')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [astroSummaryProvider.overrideWith((ref) async => profile)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    ),
  );
}

Future<void> _pumpNatalChartPage(
  WidgetTester tester,
  Map<String, dynamic> profile,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [astroNatalChartProvider.overrideWith((ref) async => profile)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const AstroNatalChartPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpBaziPage(
  WidgetTester tester,
  Map<String, dynamic> profile,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [astroSummaryProvider.overrideWith((ref) async => profile)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const AstroBaziPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.textContaining(text).first,
    500,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Map<String, dynamic> _astroSummaryProfile() {
  return {
    'birth_time': '1998-01-01 10:30',
    'birth_place': '北京动物园',
    'bazi': '戊寅 乙丑 庚午 辛巳',
    'true_solar_time': '1998-01-01 10:17',
    'accuracy': 'canonical_server',
    'confidence': '0.88',
    'western_engine': 'legacy_input',
    'western_precision': 'legacy_estimate',
    'western_confidence': '0.66',
    'sun_sign': '摩羯',
    'moon_sign': '巨蟹',
    'asc_sign': '双子',
    'ziwei': {
      'engine': 'ziwei_cece_p0_oracle_minimum',
      'precision': 'p0_selected_fields_only',
      'confidence': '0.58',
      'oracle_source': 'cece',
      'rule_mouthpiece': 'cece_p0',
      'validation_status': 'p0_fixture_supported',
      'external_oracle_status': 'not_validated',
      'display_only': true,
      'scoring_status': 'excluded_from_core_matching',
      'disclaimer': '当前为紫微试算参考，CECE 口径待校验，待外部排盘校验，不作为真实紫微排盘结论，暂不参与核心匹配评分。',
      'summary':
          'CECE P0 selected Ziwei fields retained with Wenmo preliminary palace-name mapping correction; flying-star and full Ziwei correctness remain unresolved.',
      'life_palace': '命宫',
      'life_palace_detail': {
        'palace_name': '命宫',
        'branch': '卯',
        'main_stars': ['太阴'],
      },
      'body_palace': '父母宫',
      'body_palace_detail': {'palace_name': '父母宫', 'branch': '辰'},
      'palaces': [
        {
          'index': 1,
          'name': '命宫',
          'branch': '卯',
          'main_star': '太阴',
          'main_stars': ['太阴'],
          'star_status_map': {'太阴': '陷'},
          'summary': '命宫在卯，主星太阴；CECE P0 oracle transcript only.',
        },
        {
          'index': 2,
          'name': '兄弟宫',
          'branch': '寅',
          'main_star': '紫微',
          'main_stars': ['紫微', '天府'],
          'star_status_map': {'紫微': '旺', '天府': '庙'},
          'summary': '兄弟宫在寅，主星紫微、天府；CECE P0 oracle transcript only.',
        },
        {
          'index': 3,
          'name': '夫妻宫',
          'branch': '子',
          'main_star': '破军',
          'main_stars': ['破军'],
          'summary': '夫妻宫在子，主星破军；CECE P0 oracle transcript only.',
        },
        {
          'index': 4,
          'name': '子女宫',
          'branch': '亥',
          'main_star': '太阳',
          'main_stars': ['太阳', '文曲'],
          'summary': '子女宫在亥，主星太阳、文曲；CECE P0 oracle transcript only.',
        },
        {
          'index': 5,
          'name': '财帛宫',
          'branch': '戌',
          'main_star': '武曲',
          'main_stars': ['武曲'],
          'summary': '财帛宫在戌，主星武曲；CECE P0 oracle transcript only.',
        },
        {
          'index': 6,
          'name': '疾厄宫',
          'branch': '酉',
          'main_star': '天同',
          'main_stars': ['天同'],
          'summary': '疾厄宫在酉，主星天同；CECE P0 oracle transcript only.',
        },
        {
          'index': 7,
          'name': '迁移宫',
          'branch': '申',
          'main_star': '七杀',
          'main_stars': ['七杀'],
          'summary': '迁移宫在申，主星七杀；CECE P0 oracle transcript only.',
        },
        {
          'index': 8,
          'name': '交友宫',
          'branch': '未',
          'main_star': '天梁',
          'main_stars': ['天梁'],
          'summary': '交友宫在未，主星天梁；CECE P0 oracle transcript only.',
        },
        {
          'index': 9,
          'name': '官禄宫',
          'branch': '午',
          'main_star': '廉贞',
          'main_stars': ['廉贞', '天相'],
          'star_status_map': {'廉贞': '平', '天相': '庙'},
          'summary': '官禄宫在午，主星廉贞、天相；CECE P0 oracle transcript only.',
        },
        {
          'index': 10,
          'name': '田宅宫',
          'branch': '巳',
          'main_star': '巨门',
          'main_stars': ['巨门'],
          'summary': '田宅宫在巳，主星巨门；CECE P0 oracle transcript only.',
        },
        {
          'index': 11,
          'name': '福德宫',
          'branch': '辰',
          'main_star': '贪狼',
          'main_stars': ['贪狼'],
          'summary': '福德宫在辰，主星贪狼；CECE P0 oracle transcript only.',
        },
        {
          'index': 12,
          'name': '父母宫',
          'branch': '辰',
          'main_star': '贪狼',
          'main_stars': ['贪狼'],
          'star_status_map': {'贪狼': '庙'},
          'summary': '父母宫在辰，主星贪狼；CECE P0 oracle transcript only.',
        },
      ],
      'four_transformations': [
        {'transform': '化禄', 'star': '武曲', 'palace': '财帛宫', 'branch': '甲戌'},
        {'transform': '化权', 'star': '贪狼', 'palace': '福德宫', 'branch': '戊辰'},
        {'transform': '化科', 'star': '天梁', 'palace': '交友宫', 'branch': '辛未'},
        {'transform': '化忌', 'star': '文曲', 'palace': '子女宫', 'branch': '乙亥'},
      ],
      'ziwei_advanced_fields': {
        'status': 'accepted_oracle_sihua_display_only',
        'field_status': {
          'sihua': 'oracle_display_only',
          'auxiliary_stars': 'accepted_selected_fields_only',
          'brightness': 'accepted_selected_fields_only',
          'flying_stars': 'pending_oracle',
          'ming_gong_flying_star': 'pending_oracle',
        },
        'sihua': {'status': 'accepted_oracle'},
        'flying_star_candidate': {
          'status': 'candidate_visualization',
          'review_status': 'human_review_required',
          'matching_policy': 'display_only_no_matching_scoring',
          'lines': [
            {
              'from_palace': null,
              'to_palace': '疾厄宫',
              'line_start_palace': null,
              'line_end_palace': '疾厄宫',
              'transform_type': '化禄',
              'star': '待真人复核',
              'branch': '癸酉',
              'badge_location_candidate': '疾厄宫/癸酉',
              'source_status': 'candidate',
              'review_status': 'human_review_required',
              'confidence': 'low',
            },
            {
              'from_palace': null,
              'to_palace': '财帛宫',
              'line_start_palace': null,
              'line_end_palace': '财帛宫',
              'transform_type': '化禄',
              'star': '待真人复核',
              'branch': '甲戌',
              'badge_location_candidate': '财帛宫/甲戌',
              'source_status': 'candidate',
              'review_status': 'human_review_required',
              'confidence': 'low',
            },
          ],
        },
        'ming_gong_flying_star_candidate': {
          'status': 'candidate_visualization',
          'review_status': 'human_review_required',
          'life_palace': '命宫',
          'life_branch': '寅',
          'lines_touching_life_palace': [],
          'matching_policy': 'display_only_no_matching_scoring',
        },
      },
      'flying_star_status': {
        'status': 'insufficient_oracle',
        'implementation': 'not_implemented',
      },
    },
  };
}

Map<String, dynamic> _legacyZiweiProfile() {
  return {
    'birth_time': '1998-01-01 10:30',
    'birth_place': '北京动物园',
    'bazi': '戊寅 乙丑 庚午 辛巳',
    'true_solar_time': '1998-01-01 10:17',
    'ziwei': {
      'engine': 'ziwei_seed_estimate',
      'precision': 'approximate_not_validated',
      'confidence': '0.32',
      'external_oracle_status': 'not_validated',
      'display_only': true,
      'scoring_status': 'excluded_from_core_matching',
      'summary': '旧摘要仅返回命身宫。',
      'life_palace': '命宫',
      'body_palace': '夫妻宫',
      'palaces': [
        {
          'index': 1,
          'name': '命宫',
          'main_star': '天机',
          'summary': '旧 payload 未返回地支与多主星。',
        },
        {'index': 3, 'name': '夫妻宫', 'main_star': '天梁'},
      ],
    },
  };
}

String _joinedText(String first, String second) => '$first$second';

Map<String, dynamic> _westernNatalProfile({
  String houseTruthStatus = 'available',
  List<Map<String, dynamic>>? planetsData,
  List<Map<String, dynamic>>? aspectsData,
  Map<String, dynamic>? extra,
}) {
  return {
    'birth_time': '1998-01-01 10:30',
    'birth_place': '北京',
    'true_solar_time': '1998-01-01 10:30',
    'western_engine': 'kerykeion',
    'western_precision': 'western_natal_v1',
    'western_confidence': '0.80',
    'house_truth_status': houseTruthStatus,
    'external_oracle_status': 'not_validated',
    'western_natal_policy': {
      'engine': 'kerykeion',
      'zodiac_mode': 'tropical',
      'house_system': 'placidus',
      'timezone': 'Asia/Shanghai',
      'generated_at': '2026-05-24T10:00:00Z',
    },
    'chart_data': {
      'subject': {
        'name': 'EliteSync',
        'city': '北京',
        'iso_formatted_local_datetime': '1998-01-01T10:30:00+08:00',
        'sun': {'name': 'Sun', 'abs_pos': 145.43},
        'moon': {'name': 'Moon', 'abs_pos': 187.44},
        'ascendant': {'name': 'Ascendant', 'abs_pos': 204.45},
        'first_house': {'name': 'First_House', 'abs_pos': 204.45},
        'second_house': {'name': 'Second_House', 'abs_pos': 234.45},
        'seventh_house': {'name': 'Seventh_House', 'abs_pos': 24.45},
      },
      'aspects': const [],
    },
    'planets_data':
        planetsData ??
        [
          {'name': 'Sun', 'sign': '狮子', 'house': '第五宫', 'position': '12°34′'},
        ],
    'houses_data': const [],
    'aspects_data': aspectsData ?? const [],
    ...?extra,
  };
}
