import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/relationship_runtime_local_presentation_state.dart';
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
  testWidgets('renders developer-only local warning and waiting preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const RelationshipRuntimeLocalPreviewEntry()),
    );
    await tester.pumpAndSettle();

    expect(find.text('开发者本地入口'), findsOneWidget);
    expect(find.text('仅开发者'), findsOneWidget);
    expect(find.text('本地样例'), findsOneWidget);
    expect(find.text('当前：等待揭晓'), findsOneWidget);
    expect(find.text('入口：未挂载'), findsOneWidget);
    expect(find.text('待后续决策'), findsOneWidget);
    expect(find.textContaining('不触发刷新、请求或真实倒计时'), findsOneWidget);
    expect(find.textContaining('不注册公开路由'), findsOneWidget);
    expect(find.textContaining('不接 AppShell'), findsOneWidget);
    expect(find.textContaining('不连接生产 Match 流程'), findsOneWidget);
    expect(find.text('本地关系预览：等待揭晓'), findsOneWidget);
    expect(find.textContaining('本地状态：waiting'), findsOneWidget);
    expect(find.text('运行面禁用'), findsOneWidget);
    expect(find.text('不会自动发送'), findsOneWidget);
  });

  testWidgets('renders reveal and fallback local scenarios', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            RelationshipRuntimeLocalPreviewEntry(
              scenario: RelationshipRuntimeLocalPreviewScenario.reveal,
            ),
            SizedBox(height: 12),
            RelationshipRuntimeLocalPreviewEntry(
              scenario: RelationshipRuntimeLocalPreviewScenario.noCandidate,
            ),
            SizedBox(height: 12),
            RelationshipRuntimeLocalPreviewEntry(
              scenario: RelationshipRuntimeLocalPreviewScenario.paused,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地关系预览：可查看线索'), findsOneWidget);
    expect(find.textContaining('候选摘要可见'), findsOneWidget);
    expect(find.textContaining('解释块可见'), findsOneWidget);
    expect(find.text('本地关系预览：暂无候选'), findsOneWidget);
    expect(find.textContaining('no_candidate_local_fixture'), findsOneWidget);
    expect(find.text('本地关系预览：暂不可用'), findsOneWidget);
    expect(find.textContaining('paused_local_fixture'), findsOneWidget);
    expect(find.textContaining('不建议重试'), findsOneWidget);
    expect(find.text('仅本地揭晓'), findsOneWidget);
    expect(find.text('手动发送'), findsOneWidget);
    expect(find.text('本地反馈'), findsOneWidget);
    expect(find.text('仅本地开场草稿'), findsNothing);
  });

  testWidgets('supports injected compact state and folded entries locally', (
    tester,
  ) async {
    const guards = RelationshipRuntimeLocalPresentationGuards.disabled();
    const injectedState = RelationshipRuntimeLocalPresentationState(
      phase: RelationshipRuntimeLocalPresentationPhase.revealAvailable,
      entries: <RelationshipRuntimeLocalPresentationEntry>[
        RelationshipRuntimeLocalPresentationEntry(
          runtimeState: 'reveal_available',
          phase: RelationshipRuntimeLocalPresentationPhase.revealAvailable,
          roundId: 'round-local-preview-a',
          fallbackCopyKey: 'relationship.runtime.preview.local_entry.a',
          evidenceLevel: 'L2',
          candidateSummaryAvailable: true,
          candidateDetailAvailable: false,
          explanationBlocksAvailable: false,
          guards: guards,
        ),
        RelationshipRuntimeLocalPresentationEntry(
          runtimeState: 'feedback_recorded_local',
          phase:
              RelationshipRuntimeLocalPresentationPhase.feedbackRecordedLocal,
          roundId: 'round-local-preview-b',
          fallbackCopyKey: 'relationship.runtime.preview.local_entry.b',
          evidenceLevel: 'L2',
          candidateSummaryAvailable: false,
          candidateDetailAvailable: false,
          explanationBlocksAvailable: false,
          guards: guards,
          reasonCode: 'folded_by_local_entry',
        ),
      ],
      evidenceLevel: 'L2',
      guards: guards,
    );

    await tester.pumpWidget(
      _wrap(
        const RelationshipRuntimeLocalPreviewEntry(
          state: injectedState,
          compact: true,
          maxEntries: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('状态：外部注入'), findsOneWidget);
    expect(find.textContaining('入口仍保持未挂载'), findsOneWidget);
    expect(find.textContaining('展示 1 / 2'), findsOneWidget);
    expect(find.textContaining('另有 1 条已折叠'), findsOneWidget);
    expect(find.textContaining('round-local-preview-a'), findsOneWidget);
    expect(find.textContaining('round-local-preview-b'), findsNothing);
  });

  testWidgets('fallback scenarios do not advertise reveal or send capability', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            RelationshipRuntimeLocalPreviewEntry(
              scenario: RelationshipRuntimeLocalPreviewScenario.noCandidate,
            ),
            SizedBox(height: 12),
            RelationshipRuntimeLocalPreviewEntry(
              scenario: RelationshipRuntimeLocalPreviewScenario.paused,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('仅本地揭晓'), findsNothing);
    expect(find.text('手动发送'), findsNothing);
    expect(find.text('本地反馈'), findsNothing);
    expect(find.text('运行面禁用'), findsNWidgets(2));
    expect(find.text('不会自动发送'), findsNWidgets(2));
  });

  testWidgets(
    'accepts injected local state without provider or runtime wiring',
    (tester) async {
      const guards = RelationshipRuntimeLocalPresentationGuards.disabled();
      const injectedState = RelationshipRuntimeLocalPresentationState(
        phase: RelationshipRuntimeLocalPresentationPhase.inactive,
        entries: <RelationshipRuntimeLocalPresentationEntry>[],
        evidenceLevel: 'L2',
        guards: guards,
      );

      await tester.pumpWidget(
        _wrap(const RelationshipRuntimeLocalPreviewEntry(state: injectedState)),
      );
      await tester.pumpAndSettle();

      expect(find.text('开发者本地入口'), findsOneWidget);
      expect(find.text('本地关系预览未激活'), findsOneWidget);
      expect(find.textContaining('默认空态或异常载荷'), findsOneWidget);
    },
  );

  test('preview entry imports no public navigation or runtime dependencies', () {
    final source = File(
      'lib/features/match/presentation/widgets/'
      'relationship_runtime_local_preview_entry.dart',
    ).readAsStringSync();
    final importLines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('import '))
        .toList(growable: false);

    expect(importLines, hasLength(6));
    expect(importLines, contains("import 'package:flutter/material.dart';"));
    expect(
      importLines,
      contains(
        "import 'package:flutter_elitesync_module/features/match/"
        "presentation/widgets/relationship_runtime_local_preview_panel.dart';",
      ),
    );

    const forbidden = <String>[
      'go_router',
      'app_router',
      'app_shell',
      'app_route_names',
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

  test('preview entry remains unreferenced by production pages and routes', () {
    const sourcePath =
        'lib/features/match/presentation/widgets/'
        'relationship_runtime_local_preview_entry.dart';
    final libDir = Directory('lib');
    final references = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.endsWith(sourcePath)) {
        continue;
      }
      if (normalized.endsWith(
        'lib/features/match/presentation/dev/'
        'relationship_runtime_local_preview_harness.dart',
      )) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains('relationship_runtime_local_preview_entry.dart') ||
          content.contains('RelationshipRuntimeLocalPreviewEntry') ||
          content.contains('RelationshipRuntimeLocalPreviewScenario')) {
        references.add(normalized);
      }
    }

    expect(references, isEmpty);
  });
}
