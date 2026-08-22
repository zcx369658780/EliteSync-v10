import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/shared/widgets/a5_relationship_understanding_card.dart';

void main() {
  testWidgets('A5RelationshipUnderstandingCard renders layered explanation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: A5RelationshipUnderstandingCard(
            summary: '解释只帮助理解关系节奏，不替用户做决定。',
            dimensions: [
              A5UnderstandingDimension(
                title: '摘要句',
                label: 'summary',
                body: '先用一句话说明为什么值得聊。',
              ),
              A5UnderstandingDimension(
                title: '维度卡',
                label: 'dimension',
                body: '再拆成共同点、差异点、节奏和表达方式。',
              ),
              A5UnderstandingDimension(
                title: '建议与避免',
                label: 'action',
                body: '最后给出可以做和先别做的表达。',
              ),
            ],
            suggestions: ['先从共同兴趣开始。', '用生活化语言表达。'],
            avoidances: ['避免命运断言。', '避免自动代聊。'],
          ),
        ),
      ),
    );

    expect(find.text('我的慢约会理解卡'), findsOneWidget);
    expect(find.text('解释只帮助理解关系节奏，不替用户做决定。'), findsOneWidget);
    expect(find.text('摘要句'), findsOneWidget);
    expect(find.text('维度卡'), findsOneWidget);
    expect(find.text('建议与避免'), findsOneWidget);
    expect(find.text('建议'), findsOneWidget);
    expect(find.text('先避免'), findsOneWidget);
    expect(find.textContaining('关系理解辅助'), findsOneWidget);
    expect(find.textContaining('不会写入资料、星盘记录或匹配算法'), findsOneWidget);
  });
}
