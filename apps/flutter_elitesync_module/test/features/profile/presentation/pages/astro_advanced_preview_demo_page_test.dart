import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_sample_set.dart';

import '../fixtures/astro_advanced_preview_demo_fixture.dart';

void main() {
  testWidgets('test-only advanced preview fixture renders stable matrix', (
    tester,
  ) async {
    final first = buildTestOnlyAdvancedPreviewFixture();
    final second = buildTestOnlyAdvancedPreviewFixture();

    expect(first.toMarkdownLines(), second.toMarkdownLines());
    expect(first.offlineFallback, isTrue);
    expect(first.requests.pair['pair_mode'], 'synastry');
    expect(first.requests.comparison['pair_mode'], 'comparison');

    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AstroAdvancedSampleSetView(bundle: first),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('关系与时间样例'), findsOneWidget);
    expect(
      find.text('高级样例矩阵把合盘、对比盘、行运、返照和时法放在一起，方便你比较不同样例的关注角度与已知偏差。'),
      findsOneWidget,
    );
    expect(find.text('合盘预览（测试样例）'), findsWidgets);
    expect(find.text('对比盘预览（测试样例）'), findsWidgets);
    expect(find.text('行运预览（测试样例）'), findsWidgets);
    expect(find.text('返照预览（测试样例）'), findsWidgets);
  });
}
