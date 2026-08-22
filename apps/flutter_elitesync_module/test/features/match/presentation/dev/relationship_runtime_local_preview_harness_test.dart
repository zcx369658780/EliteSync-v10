import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/presentation/dev/relationship_runtime_local_preview_harness.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/relationship_runtime_local_preview_entry.dart';
import 'package:flutter_test/flutter_test.dart';

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
  testWidgets('renders enabled standalone developer-only local harness', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const RelationshipRuntimeLocalPreviewHarness(
          enabled: true,
          scenarios: [
            RelationshipRuntimeLocalPreviewScenario.waiting,
            RelationshipRuntimeLocalPreviewScenario.reveal,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('开发者预览入口检查'), findsOneWidget);
    expect(find.text('仅调试 / 开发'), findsOneWidget);
    expect(find.text('独立检查面'), findsOneWidget);
    expect(find.text('未注册路由'), findsOneWidget);
    expect(find.text('本地样例'), findsWidgets);
    expect(find.text('只读预览'), findsOneWidget);
    expect(find.text('不触发 API'), findsOneWidget);
    expect(find.text('不写 DB'), findsOneWidget);
    expect(find.textContaining('不注册公开路由'), findsWidgets);
    expect(find.textContaining('不接 AppShell'), findsWidgets);
    expect(find.textContaining('不进入生产 Match 流程'), findsOneWidget);
    expect(find.text('本地关系预览：等待揭晓'), findsOneWidget);
    expect(find.text('本地关系预览：可查看线索'), findsOneWidget);
    expect(find.text('本地关系预览：开场草稿'), findsNothing);
  });

  testWidgets('disabled harness does not render local preview entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const RelationshipRuntimeLocalPreviewHarness(enabled: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('开发者预览入口检查'), findsOneWidget);
    expect(find.text('未启用'), findsOneWidget);
    expect(find.textContaining('开发者本地预览未启用'), findsOneWidget);
    expect(find.text('本地关系预览：等待揭晓'), findsNothing);
    expect(find.text('本地关系预览：可查看线索'), findsNothing);
  });

  testWidgets('smokes default waiting reveal fallback and paused scenarios', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const RelationshipRuntimeLocalPreviewHarness(enabled: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('开发者预览入口检查'), findsOneWidget);
    expect(find.text('本地关系预览：等待揭晓'), findsOneWidget);
    expect(find.text('本地关系预览：可查看线索'), findsOneWidget);
    expect(find.text('本地关系预览：开场草稿'), findsOneWidget);
    expect(find.text('本地关系预览：暂无候选'), findsOneWidget);
    expect(find.text('本地关系预览：暂不可用'), findsOneWidget);
    expect(find.textContaining('no_candidate_local_fixture'), findsOneWidget);
    expect(find.textContaining('paused_local_fixture'), findsOneWidget);
    expect(find.text('仅本地开场草稿'), findsOneWidget);
    expect(find.text('运行面禁用'), findsNWidgets(5));
  });

  testWidgets(
    'visual text avoids stale gate marker and runtime readiness claim',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const RelationshipRuntimeLocalPreviewHarness(enabled: true)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('B22 开发者本地预览 Harness'), findsNothing);
      expect(find.text('B22 再决策'), findsNothing);
      expect(find.text('待后续决策'), findsNWidgets(5));
      expect(find.textContaining('runtime ready'), findsNothing);
      expect(find.textContaining('production ready'), findsNothing);
      expect(find.textContaining('生产可用'), findsNothing);
      expect(find.textContaining('runtime readiness'), findsNothing);
    },
  );

  test('harness imports no public navigation or runtime dependencies', () {
    final source = File(
      'lib/features/match/presentation/dev/'
      'relationship_runtime_local_preview_harness.dart',
    ).readAsStringSync();
    final importLines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('import '))
        .toList(growable: false);

    expect(importLines, hasLength(6));
    expect(
      importLines,
      contains(
        "import 'package:flutter_elitesync_module/features/match/"
        "presentation/widgets/relationship_runtime_local_preview_entry.dart';",
      ),
    );

    const forbidden = <String>[
      'go_router',
      'app_router',
      'app_shell',
      'app_route_names',
      'match_portal_page',
      'match_providers',
      'repository',
      'usecase',
      'datasource',
      'remote',
      'api',
      'dio',
      'client',
      'storage',
      'database',
      'backend',
      'notification',
    ];

    for (final line in importLines) {
      final lower = line.toLowerCase();
      for (final term in forbidden) {
        expect(
          lower.contains(term),
          isFalse,
          reason: 'forbidden import token: $term',
        );
      }
    }
  });

  test('harness remains outside router shell and match runtime graph', () {
    const forbiddenTargets = <String>[
      'lib/app/router/app_route_names.dart',
      'lib/app/router/app_router.dart',
      'lib/app/router/app_shell.dart',
      'lib/features/match/presentation/pages/match_portal_page.dart',
      'lib/features/match/presentation/providers/match_providers.dart',
    ];
    final references = <String>[];

    for (final path in forbiddenTargets) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final content = file.readAsStringSync();
      if (content.contains('relationship_runtime_local_preview_harness.dart') ||
          content.contains('RelationshipRuntimeLocalPreviewHarness') ||
          content.contains('relationship_runtime_local_preview_entry.dart') ||
          content.contains('RelationshipRuntimeLocalPreviewEntry')) {
        references.add(path);
      }
    }

    expect(references, isEmpty);
  });
}
