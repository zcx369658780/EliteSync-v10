import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_showcase_review_fixture_page.dart';

void main() {
  testWidgets(
    'fixture displays review states without public or scoring claims',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ProfileShowcaseReviewFixturePage(),
        ),
      );
      await tester.pumpAndSettle();

      final visibleText = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .where((text) => text.isNotEmpty)
          .join('\n');

      expect(visibleText, contains('Pending / 等待审核'));
      expect(visibleText, contains('Approved / 审核通过'));
      expect(visibleText, contains('Rejected / 审核未通过'));
      expect(visibleText, contains('Needs Revision / 需要修改'));
      expect(visibleText, contains('Manual Review / 人工复核'));
      expect(visibleText, contains('Error Fallback / 状态不可用'));
      expect(visibleText, contains('审核通过，仍是私有草稿'));
      expect(visibleText, contains('需要人工复核，仍是私有草稿'));
      expect(visibleText, contains('CTA：刷新审核状态'));
      expect(visibleText, contains('提交：重新提交审核'));
      expect(visibleText, contains('提交：审核通过，仍是私有草稿'));
      expect(visibleText, contains('提交禁用'));
      expect(visibleText, contains('不会公开展示'));
      expect(visibleText, contains('不会用于推荐评分'));

      for (final forbidden in [
        '已公开',
        '已发布',
        '公开展示成功',
        '已进入推荐',
        '已更新推荐权重',
        '已用于推荐',
        '已进入匹配池',
      ]) {
        expect(visibleText, isNot(contains(forbidden)));
      }
    },
  );
}
