import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/date_drop_journey_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/date_drop_readiness_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_hero_summary_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_weight_breakdown.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('journey card explains Date Drop path without runtime claims', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const DateDropJourneyCard(stage: DateDropJourneyStage.waiting)),
    );
    await tester.pumpAndSettle();

    expect(find.text('低频高质量'), findsOneWidget);
    expect(find.textContaining('路径卡'), findsOneWidget);
    expect(find.text('准备'), findsOneWidget);
    expect(find.text('等待'), findsOneWidget);
    expect(find.text('揭晓'), findsOneWidget);
    expect(find.text('理解'), findsOneWidget);
    expect(find.text('低压开场'), findsOneWidget);
    expect(find.text('反馈'), findsOneWidget);
    expect(find.text('下一轮'), findsOneWidget);
    expect(find.textContaining('不写资料或星盘真值'), findsOneWidget);
    expect(find.textContaining('不替对方打分'), findsOneWidget);
    expect(find.textContaining('不自动发送聊天消息'), findsOneWidget);
  });

  testWidgets('compact journey card summarizes current and next stage', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DateDropJourneyCard(
          stage: DateDropJourneyStage.chatPrep,
          compact: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('当前阶段：低压开场'), findsOneWidget);
    expect(find.textContaining('下一步：反馈'), findsOneWidget);
    expect(find.textContaining('路径卡'), findsOneWidget);
  });

  testWidgets('preparing journey card fits narrow width without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 292,
          child: DateDropJourneyCard(stage: DateDropJourneyStage.preparing),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('先准备好被理解的线索'), findsOneWidget);
    expect(find.text('低频高质量'), findsOneWidget);
    expect(find.textContaining('不给你打分'), findsOneWidget);
    expect(find.textContaining('不写资料或星盘真值'), findsOneWidget);
    expect(find.textContaining('不自动发送聊天消息'), findsOneWidget);
  });

  testWidgets('readiness card wraps long signals inside narrow width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 292,
          child: DateDropReadinessCard(
            stage: DateDropReadinessStage.waiting,
            primarySignal: '很长的资料表达信号用于验证窄屏不会跑出气泡',
            secondarySignal: '等待期间不需要反复刷新也不会自动改写资料',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('本轮行动确认'), findsOneWidget);
    expect(find.text('你来决定'), findsOneWidget);
    expect(find.textContaining('不需要反复刷新'), findsWidgets);
    expect(find.textContaining('不写资料或星盘真值'), findsOneWidget);
    expect(find.textContaining('不自动发送聊天消息'), findsOneWidget);
  });

  testWidgets('readiness card keeps chat and feedback user controlled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            DateDropReadinessCard(
              stage: DateDropReadinessStage.chatPrep,
              primarySignal: '草稿可编辑',
              secondarySignal: '手动发送',
              compact: true,
            ),
            SizedBox(height: 12),
            DateDropReadinessCard(
              stage: DateDropReadinessStage.feedback,
              primarySignal: '未来方向',
              secondarySignal: '主观感受',
              compact: true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('首聊前的手动确认'), findsOneWidget);
    expect(find.text('反馈方向确认'), findsOneWidget);
    expect(find.textContaining('写入草稿不等于自动发送消息'), findsOneWidget);
    expect(find.textContaining('反馈会帮助后续方向更贴近你'), findsWidgets);
    expect(find.textContaining('不会立刻给对方打分'), findsOneWidget);
    expect(find.textContaining('不合适也可以温和表达'), findsOneWidget);
    expect(find.textContaining('行动卡'), findsNWidgets(2));
    expect(find.textContaining('不替对方打分'), findsWidgets);
  });

  testWidgets('hero and explanation clue cards avoid score and weight truth', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            MatchHeroSummaryCard(
              headline: '你们适合先从轻松话题慢慢开始',
              score: 86,
              tags: ['同城', '高匹配', '节奏接近'],
            ),
            SizedBox(height: 12),
            MatchWeightBreakdown(weights: {'沟通节奏': 40, '共同兴趣': 30}),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本轮慢约会已揭晓'), findsOneWidget);
    expect(find.text('先理解，再决定'), findsOneWidget);
    expect(find.text('关系线索'), findsOneWidget);
    expect(find.text('解释线索'), findsOneWidget);
    expect(find.textContaining('只帮助你理解推荐理由'), findsOneWidget);
    expect(find.textContaining('综合匹配分'), findsNothing);
    expect(find.textContaining('分项权重'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });
}
