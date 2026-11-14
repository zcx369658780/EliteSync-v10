import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/progress/presentation/pages/progress_page.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Restoration progress prioritizes personal state at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const ProgressPage(),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('我的进展'), findsOneWidget);
        expect(find.text('慢约会与连接'), findsOneWidget);
        expect(find.text('平台活动 · 合成演练'), findsNothing);
        await tester.ensureVisible(find.text('活动与社区'));
        await tester.tap(find.text('活动与社区'));
        await tester.pumpAndSettle();
        expect(find.text('平台活动 · 合成演练'), findsOneWidget);
        expect(find.text('独立吃饭 / 学习搭子'), findsOneWidget);
        expect(find.text('好友可见社区'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
