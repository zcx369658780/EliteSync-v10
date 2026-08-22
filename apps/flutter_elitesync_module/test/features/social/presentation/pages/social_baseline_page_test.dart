import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/social/presentation/pages/social_baseline_page.dart';

Widget _wrap() {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: const Scaffold(body: SocialBaselinePage()),
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
  testWidgets('SocialBaselinePage shows intention and self-intro preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('社交表达'), findsOneWidget);
    expect(find.text('社交表达预览'), findsOneWidget);
    expect(find.textContaining('仅供编辑预览'), findsOneWidget);
    expect(find.textContaining('本地'), findsNothing);
    expect(find.text('怎样表达更自然'), findsOneWidget);
    expect(find.text('摘要'), findsOneWidget);
    expect(find.text('维度'), findsOneWidget);
    expect(find.text('建议'), findsOneWidget);
    expect(find.text('先避免'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('我想认识什么样的人'));
    expect(find.text('我想认识什么样的人'), findsOneWidget);
    expect(find.text('认真慢聊的人'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('自我介绍草稿'));
    expect(find.text('自我介绍草稿'), findsOneWidget);
    await tester.tap(find.text('生成草稿预览'));
    await tester.pumpAndSettle();

    expect(find.textContaining('我最近更想认识认真慢聊的人'), findsOneWidget);
    expect(find.textContaining('不会公开发布'), findsOneWidget);
    expect(find.textContaining('不会写入正式资料记录'), findsOneWidget);
  });

  testWidgets(
    'SocialBaselinePage shows tags, return cards, feedback, and non-claims',
    (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _scrollUntilVisible(tester, find.text('标签表达'));
      expect(find.text('关系目标'), findsOneWidget);
      expect(find.text('兴趣方向'), findsOneWidget);
      expect(find.text('生活节奏'), findsOneWidget);
      expect(find.text('慢约会表达'), findsOneWidget);
      expect(find.text('搭子偏好'), findsOneWidget);
      expect(find.text('适合开启的话题'), findsOneWidget);
      expect(find.textContaining('不会更改资料、星盘或画像'), findsOneWidget);
      expect(find.textContaining('反写'), findsNothing);

      await _scrollUntilVisible(tester, find.text('接下来可以做什么'));
      expect(find.text('匹配即将揭晓：回到 Match 看本轮节奏。'), findsOneWidget);
      expect(find.text('Buddy 候选已生成：回到搭子页看有限候选。'), findsOneWidget);
      expect(find.text('聊天可以从容继续：回到聊天页手动编辑草稿。'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('记录体验感受'));
      await tester.tap(find.text('聊天有压力'));
      await tester.pumpAndSettle();
      expect(find.textContaining('已记录本次体验感受：聊天有压力'), findsOneWidget);
      expect(find.textContaining('不会自动发送、改写资料或改变匹配结果'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('安全与非目标'));
      expect(find.textContaining('不自动发送聊天'), findsOneWidget);
      expect(find.textContaining('不做真实通知推送'), findsOneWidget);
      expect(find.textContaining('不展示精确实时位置'), findsOneWidget);
      expect(find.textContaining('画像真值'), findsNothing);
    },
  );
}
