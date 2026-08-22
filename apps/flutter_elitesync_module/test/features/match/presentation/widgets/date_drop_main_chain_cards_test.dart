import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/date_drop_main_chain_model.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/date_drop_main_chain_cards.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  test('DateDropMainChainModel keeps the spine copy on safe boundaries', () {
    final model = DateDropMainChainModel.fromMatch(
      result: const MatchResultEntity(
        headline: '你们适合先从轻松话题慢慢开始',
        score: 86,
        tags: ['同城', '节奏接近'],
        highlights: [
          MatchHighlightEntity(
            title: '沟通节奏',
            value: 52,
            desc: '先交换真实感受，再逐步深入。',
          ),
        ],
      ),
      detail: const MatchDetailEntity(
        reasons: ['匹配亮点：沟通节奏较顺'],
        weights: {'沟通节奏': 40},
      ),
      showcaseComplete: true,
    );

    expect(model.state, DateDropChainState.revealed);
    expect(model.showcasePrompt, contains('展示资料已经比较完整'));
    expect(model.stageLabel, '当前：先理解再开场');
    expect(model.nextStepLabel, contains('手动带着草稿去消息'));
    expect(model.boundaryLabel, contains('发送始终由你确认'));
    expect(model.containsForbiddenCopy(), isFalse);
  });

  testWidgets('DateDropMainChainCard renders waiting and reveal spine copy', (
    tester,
  ) async {
    final waitingModel = DateDropMainChainModel.fromMatch(
      candidateUnavailable: true,
    );
    final revealedModel = DateDropMainChainModel.fromMatch(
      result: const MatchResultEntity(
        headline: '你们在沟通与情绪节奏上较契合',
        score: 86,
        tags: ['同城', '高匹配', '节奏接近'],
        highlights: [
          MatchHighlightEntity(title: '依恋安全感', value: 51, desc: '都倾向稳定关系。'),
        ],
      ),
      detail: const MatchDetailEntity(
        reasons: ['匹配亮点｜沟通节奏：你们都适合先从轻松话题慢慢熟悉'],
        weights: {'沟通节奏': 40},
      ),
    );

    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            DateDropMainChainCard(model: waitingModel, onShowcaseTap: () {}),
            const SizedBox(height: 12),
            DateDropMainChainCard(
              model: revealedModel,
              result: const MatchResultEntity(
                headline: '你们在沟通与情绪节奏上较契合',
                score: 86,
                tags: ['同城', '高匹配', '节奏接近'],
                highlights: [
                  MatchHighlightEntity(
                    title: '依恋安全感',
                    value: 51,
                    desc: '都倾向稳定关系。',
                  ),
                ],
              ),
              onDetailTap: () {},
              onMessagesTap: () {},
              onFeedbackTap: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本轮慢约会还在等待揭晓'), findsOneWidget);
    expect(find.textContaining('当前：等待本轮揭晓'), findsOneWidget);
    expect(find.textContaining('下一步：等待揭晓后阅读解释'), findsOneWidget);
    expect(find.textContaining('等待态不会提前打开解释或聊天'), findsOneWidget);
    expect(find.text('当前重点'), findsNWidgets(2));
    expect(find.text('下一步'), findsNWidgets(2));
    expect(find.text('边界'), findsNWidgets(2));
    expect(find.text('理解线索'), findsNothing);
    expect(find.text('更多可做的事'), findsNothing);
    expect(find.text('完善展示自己'), findsWidgets);
    expect(find.text('记录反馈意向'), findsOneWidget);
    expect(find.text('本轮慢约会已可继续了解'), findsOneWidget);
    expect(find.textContaining('当前：先理解再开场'), findsOneWidget);
    expect(find.textContaining('发送始终由你确认'), findsOneWidget);
    expect(find.text('查看完整解释'), findsOneWidget);
    expect(find.text('打开消息草稿'), findsOneWidget);
    expect(find.text('展开等待说明'), findsOneWidget);
    expect(find.text('展开解释、开场与反馈'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('展开解释、开场与反馈'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('展开解释、开场与反馈'));
    await tester.pumpAndSettle();

    expect(find.text('理解线索'), findsOneWidget);
    expect(find.text('更多可做的事'), findsOneWidget);
    expect(find.text('草稿开场 · 手动发送'), findsOneWidget);
    expect(find.text('反馈意向 · 只作方向参考'), findsOneWidget);
    expect(find.textContaining('当前候选：你们在沟通与情绪节奏上较契合'), findsOneWidget);
    expect(find.textContaining('不声称已经改变真实推荐权重'), findsWidgets);
  });

  testWidgets('DateDropMainChainCard keeps preparing copy inside narrow card', (
    tester,
  ) async {
    final model = DateDropMainChainModel.fromMatch();

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 292,
          child: DateDropMainChainCard(
            model: model,
            onShowcaseTap: () {},
            onFeedbackTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('本轮慢约会正在整理资料'), findsOneWidget);
    expect(find.text('先准备'), findsOneWidget);
    expect(find.textContaining('当前：准备表达线索'), findsOneWidget);
    expect(find.textContaining('准备是为了被理解，不是提高匹配分'), findsOneWidget);
    expect(find.text('展开准备与边界'), findsOneWidget);
    expect(find.text('草稿开场 · 手动发送'), findsNothing);
    await tester.tap(find.text('展开准备与边界'));
    await tester.pumpAndSettle();
    expect(find.text('草稿开场 · 手动发送'), findsOneWidget);
    expect(find.textContaining('不是替你做决定'), findsWidgets);
    expect(find.textContaining('不声称已经改变真实推荐权重'), findsOneWidget);
    expect(find.textContaining('算法权重已调整'), findsNothing);
    expect(find.textContaining('自动发送'), findsNothing);
  });
}
