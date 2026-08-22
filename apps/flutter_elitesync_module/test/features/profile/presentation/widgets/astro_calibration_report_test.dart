import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_calibration_report.dart';

void main() {
  test(
    'calibration report keeps sample calibration and deviation archive stable',
    () {
      final report = buildAstroCalibrationReport();
      final lines = report.toMarkdownLines();

      expect(report.sampleSet.entries, hasLength(2));
      expect(lines, contains('# 3.8 校准报告'));
      expect(lines, contains('- 报告性质：展示参考 / 不改写已保存记录'));
      expect(lines, contains('- 样例数量：2'));
      expect(lines, contains('- 说明：以下差异只用于校准与归档，不回写已保存的星盘记录。'));
      expect(lines, contains('- 已知偏差：'));
      expect(lines.where((line) => line.contains('baseline')).length, 0);
      expect(lines.where((line) => line.contains('dense-modern')).length, 0);
      expect(
        lines.where((line) => line.contains('基线样例')).length,
        greaterThanOrEqualTo(1),
      );
      expect(
        lines.where((line) => line.contains('现代扩展样例')).length,
        greaterThanOrEqualTo(1),
      );
    },
  );

  testWidgets('calibration report renders without demo or placeholder action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: AstroCalibrationReportCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('校准样例'), findsOneWidget);
    expect(find.text('已知偏差'), findsOneWidget);
    expect(find.text('打开校准演示'), findsNothing);
    expect(find.text('查看校准报告'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });
}
