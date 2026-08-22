import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/buddy/presentation/pages/buddy_companion_page.dart';

Widget _wrap() {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: const Scaffold(body: BuddyCompanionPage()),
  );
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(ListView).first, const Offset(0, -360));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Buddy page shows four type cards and safe demand-card copy', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('搭子精准陪伴'), findsOneWidget);
    expect(find.textContaining('不替代婚恋匹配'), findsOneWidget);
    expect(find.text('搭子活动适配提示'), findsOneWidget);
    expect(find.text('共同点'), findsOneWidget);
    expect(find.text('节奏'), findsOneWidget);
    expect(find.text('边界'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('学习搭子'));
    expect(find.text('学习搭子'), findsOneWidget);
    expect(find.text('电影搭子'), findsOneWidget);
    expect(find.text('吃饭搭子'), findsOneWidget);
    expect(find.text('健身搭子'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('电影搭子'));
    await tester.tap(find.text('电影搭子'));
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('需求卡填写'));
    expect(find.text('需求卡填写'), findsOneWidget);
    expect(find.text('片类偏好'), findsOneWidget);
    expect(find.text('交流意愿'), findsOneWidget);
    expect(find.textContaining('先表达目标、时间、地点语义'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('需求卡预览'));
    expect(find.textContaining('我想找电影搭子'), findsOneWidget);
    expect(find.textContaining('公共场所优先'), findsOneWidget);
    expect(find.textContaining('本地/mock 展示，不发布到服务端'), findsOneWidget);
  });

  testWidgets('Buddy candidates explain why recommended and manual chat only', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('吃饭搭子'));
    await tester.tap(find.text('吃饭搭子'));
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('本地候选推荐'));
    expect(find.textContaining('仅展示 2 位 mock 候选'), findsOneWidget);
    expect(find.text('为什么推荐'), findsWidgets);
    expect(find.textContaining('预算边界清楚'), findsOneWidget);
    expect(find.textContaining('公共餐厅'), findsOneWidget);
    expect(find.text('手动聊天入口'), findsWidgets);

    await tester.tap(find.text('手动聊天入口').first);
    await tester.pumpAndSettle();

    expect(find.text('手动开启聊天'), findsOneWidget);
    expect(find.textContaining('可编辑草稿'), findsOneWidget);
    expect(find.textContaining('不会写入真实消息记录'), findsOneWidget);
    expect(find.text('我知道，需要手动发送'), findsOneWidget);
  });

  testWidgets('Buddy feedback remains local and safety/reporting is visible', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('活动后主观反馈'));
    expect(find.textContaining('不声称正式持久化'), findsOneWidget);
    expect(find.textContaining('不实时训练算法'), findsOneWidget);

    await tester.tap(find.text('边界清楚'));
    await tester.pumpAndSettle();
    expect(find.text('已记录本机主观反馈：边界清楚'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('安全与边界'));
    expect(find.textContaining('不展示精确实时位置'), findsOneWidget);
    expect(find.textContaining('预算、时间、AA'), findsOneWidget);
    expect(find.textContaining('举报/拉黑展示入口'), findsOneWidget);
  });
}
