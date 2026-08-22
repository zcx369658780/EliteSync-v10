import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/feedback/presentation/pages/inner_test_feedback_page.dart';

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}

void main() {
  void expectNoForbiddenVisibleTerms(String text, List<String> forbidden) {
    for (final term in forbidden) {
      expect(text, isNot(contains(term)));
      expect(text.toLowerCase(), isNot(contains(term.toLowerCase())));
    }
  }

  testWidgets('Feedback page shows support categories and boundaries', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const InnerTestFeedbackPage(
          initialCategoryId: 'astro_display',
          sourceSurface: 'astro',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('体验反馈'), findsOneWidget);
    expect(find.text('帮我们改进体验'), findsOneWidget);
    expect(find.text('把你遇到的问题或建议整理成一份可复制反馈'), findsOneWidget);
    expect(find.text('从星盘进入'), findsOneWidget);
    expect(find.text('匹配推荐'), findsOneWidget);
    expect(find.text('搭子体验'), findsOneWidget);
    expect(find.text('聊天体验'), findsOneWidget);
    expect(find.text('资料与展示'), findsOneWidget);
    expect(find.text('星盘 / 八字 / 紫微显示'), findsOneWidget);
    expect(find.text('紫微显示校准'), findsOneWidget);
    expect(find.text('页面异常'), findsOneWidget);
    expect(find.text('其他建议'), findsOneWidget);
    expect(find.textContaining('不会自动改资料、星盘、匹配结果或推荐权重'), findsWidgets);
    expect(find.textContaining('复制后发给支持人员'), findsOneWidget);
    expect(
      _visibleText(tester).indexOf('反馈类别'),
      lessThan(_visibleText(tester).indexOf('反馈内容')),
    );
    expect(
      _visibleText(tester).indexOf('反馈内容'),
      lessThan(_visibleText(tester).indexOf('生成反馈草稿')),
    );
    expect(find.textContaining('已提交成功'), findsNothing);
    expect(find.textContaining('客服已收到'), findsNothing);
    expect(find.textContaining('将自动优化你的匹配'), findsNothing);
    expect(find.textContaining('production readiness'), findsNothing);
  });

  testWidgets('Feedback page uses general Settings profile description', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const InnerTestFeedbackPage(
          initialCategoryId: 'profile_data',
          sourceSurface: 'settings',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('从设置进入'), findsOneWidget);
    expect(find.text('资料与展示'), findsOneWidget);
    expect(find.text('应用设置、功能体验、资料展示或页面问题。'), findsOneWidget);
  });

  testWidgets('Feedback page generates local copyable draft', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const InnerTestFeedbackPage(
          initialCategoryId: 'ziwei_flying_star_oracle',
          sourceSurface: 'ziwei',
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '命宫飞星候选线条和文墨截图方向不一致。');
    await tester.scrollUntilVisible(
      find.text('生成反馈草稿'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成反馈草稿'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('反馈草稿已生成'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('反馈草稿已生成'), findsOneWidget);
    expect(find.textContaining('EliteSync 体验反馈'), findsOneWidget);
    expect(find.textContaining('来源：从紫微进入'), findsOneWidget);
    expect(find.textContaining('类别：紫微显示校准'), findsOneWidget);
    expect(find.textContaining('命宫飞星候选线条和文墨截图方向不一致'), findsWidgets);
    expect(find.textContaining('不会自动改资料、星盘、匹配结果或推荐权重'), findsWidgets);
    expect(find.textContaining('宫位、方向、对照结果'), findsWidgets);
  });

  testWidgets('Feedback page reports false clipboard write without success', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: InnerTestFeedbackPage(
          clipboardWriter: (text) async {
            attempts += 1;
            return false;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('复制反馈内容'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('复制反馈内容'));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(find.text('复制未完成，请稍后重试'), findsOneWidget);
    expect(find.text('已复制反馈内容'), findsNothing);
    expect(find.textContaining('已提交'), findsNothing);
  });

  testWidgets('Feedback page sanitizes thrown clipboard failure', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: InnerTestFeedbackPage(
          clipboardWriter: (text) async => throw Exception('raw clipboard'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('复制反馈内容'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('复制反馈内容'));
    await tester.pumpAndSettle();

    expect(find.text('复制未完成，请稍后重试'), findsOneWidget);
    expect(find.text('已复制反馈内容'), findsNothing);
    expect(find.textContaining('raw clipboard'), findsNothing);
  });

  testWidgets('Feedback page does not expose forbidden support copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const InnerTestFeedbackPage(
          initialCategoryId: 'profile_data',
          sourceSurface: 'settings',
        ),
      ),
    );

    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expectNoForbiddenVisibleTerms(visibleText, [
      'mock',
      'test',
      'debug',
      'payload',
      'release-chain',
      'gate',
      'oracle',
      '不做真正持久化',
      '本地/mock 卡片',
      'RTC 骨架',
      'Alpha',
      'internal',
      'dev',
      'dating',
      '接口',
      '/api/v1/app/health',
      '/api/v1/app/version/check',
      '已提交到服务端',
      '已写入反馈数据库',
      '系统会立即调整推荐权重',
      '开发者调试 payload',
      'smoke',
      'staging',
      'endpoint',
      'schema',
      'API',
      '必须',
      '立即',
      '精准',
      '保证',
    ]);
  });
}
