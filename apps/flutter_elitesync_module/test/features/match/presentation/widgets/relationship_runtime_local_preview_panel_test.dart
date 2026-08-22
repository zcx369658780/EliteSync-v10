import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/relationship_runtime_local_presentation_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/relationship_runtime_local_preview_panel.dart';
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

RelationshipRuntimeLocalPresentationState _state({
  required RelationshipRuntimeLocalPresentationPhase phase,
  required List<RelationshipRuntimeLocalPresentationEntry> entries,
  RelationshipRuntimeLocalPresentationGuards guards =
      const RelationshipRuntimeLocalPresentationGuards.disabled(),
}) {
  return RelationshipRuntimeLocalPresentationState(
    phase: phase,
    entries: entries,
    evidenceLevel: 'L2',
    guards: guards,
  );
}

RelationshipRuntimeLocalPresentationEntry _entry({
  required String runtimeState,
  required RelationshipRuntimeLocalPresentationPhase phase,
  String roundId = 'round-local-1',
  String fallbackCopyKey = 'relationship.runtime.preview.local',
  bool candidateSummaryAvailable = false,
  bool candidateDetailAvailable = false,
  bool explanationBlocksAvailable = false,
  RelationshipRuntimeLocalPresentationGuards guards =
      const RelationshipRuntimeLocalPresentationGuards.disabled(),
  String? reasonCode,
  bool? retryable,
}) {
  return RelationshipRuntimeLocalPresentationEntry(
    runtimeState: runtimeState,
    phase: phase,
    roundId: roundId,
    fallbackCopyKey: fallbackCopyKey,
    evidenceLevel: 'L2',
    candidateSummaryAvailable: candidateSummaryAvailable,
    candidateDetailAvailable: candidateDetailAvailable,
    explanationBlocksAvailable: explanationBlocksAvailable,
    guards: guards,
    reasonCode: reasonCode,
    retryable: retryable,
  );
}

const _manualLocalGuards = RelationshipRuntimeLocalPresentationGuards(
  hasEndpointDependency: false,
  hasDatabaseDependency: false,
  hasProductionRuntimeImport: false,
  canRevealLocally: true,
  canOpenConversationLocally: false,
  manualSendOnly: true,
  automaticSendAllowed: false,
  localFeedbackOnly: true,
  remoteFeedbackInactive: true,
  notificationPushInactive: true,
  readModelOnly: true,
  canSend: false,
  scoringMutationAllowed: false,
  profileTruthMutationAllowed: false,
  astroTruthMutationAllowed: false,
);

void main() {
  testWidgets('renders waiting state with local preview boundaries', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RelationshipRuntimeLocalPreviewPanel(
          state: _state(
            phase: RelationshipRuntimeLocalPresentationPhase.waiting,
            guards: _manualLocalGuards,
            entries: [
              _entry(
                runtimeState: 'waiting',
                phase: RelationshipRuntimeLocalPresentationPhase.waiting,
                guards: _manualLocalGuards,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地关系预览：等待揭晓'), findsOneWidget);
    expect(find.text('本地预览'), findsOneWidget);
    expect(find.text('证据 L2'), findsOneWidget);
    expect(find.textContaining('阶段：等待揭晓'), findsOneWidget);
    expect(find.textContaining('展示 1 / 1'), findsOneWidget);
    expect(find.text('本地守卫'), findsOneWidget);
    expect(find.text('仅本地揭晓'), findsOneWidget);
    expect(find.text('等待揭晓'), findsOneWidget);
    expect(find.textContaining('本地状态：waiting'), findsOneWidget);
    expect(find.text('手动发送'), findsOneWidget);
    expect(find.text('不会自动发送'), findsOneWidget);
    expect(find.text('本地反馈'), findsOneWidget);
    expect(find.text('远端反馈未启用'), findsOneWidget);
    expect(find.text('通知推送未启用'), findsOneWidget);
    expect(find.text('只读模型'), findsOneWidget);
    expect(find.text('运行面禁用'), findsOneWidget);
    expect(find.textContaining('真实用户路径仍需后续单独授权'), findsOneWidget);
  });

  testWidgets('renders reveal state without enabling conversation runtime', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RelationshipRuntimeLocalPreviewPanel(
          state: _state(
            phase: RelationshipRuntimeLocalPresentationPhase.revealAvailable,
            guards: _manualLocalGuards,
            entries: [
              _entry(
                runtimeState: 'reveal_available',
                phase:
                    RelationshipRuntimeLocalPresentationPhase.revealAvailable,
                candidateSummaryAvailable: true,
                explanationBlocksAvailable: true,
                guards: _manualLocalGuards,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地关系预览：可查看线索'), findsOneWidget);
    expect(find.textContaining('阶段：可查看线索'), findsOneWidget);
    expect(find.text('可查看线索'), findsOneWidget);
    expect(find.textContaining('候选摘要可见'), findsOneWidget);
    expect(find.textContaining('解释块可见'), findsOneWidget);
    expect(find.textContaining('不进入真实聊天'), findsOneWidget);
    expect(find.textContaining('自动发送'), findsNWidgets(2));
    expect(find.textContaining('打开会话'), findsNothing);
  });

  testWidgets('renders no candidate paused and malformed fallback states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            RelationshipRuntimeLocalPreviewPanel(
              state: _state(
                phase: RelationshipRuntimeLocalPresentationPhase.noCandidate,
                entries: [
                  _entry(
                    runtimeState: 'no_candidate',
                    phase:
                        RelationshipRuntimeLocalPresentationPhase.noCandidate,
                    reasonCode: 'no_candidate_local',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RelationshipRuntimeLocalPreviewPanel(
              state: _state(
                phase: RelationshipRuntimeLocalPresentationPhase
                    .pausedOrUnavailable,
                entries: [
                  _entry(
                    runtimeState: 'paused_or_unavailable',
                    phase: RelationshipRuntimeLocalPresentationPhase
                        .pausedOrUnavailable,
                    reasonCode: 'paused_local',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RelationshipRuntimeLocalPreviewPanel(
              state: RelationshipRuntimeLocalPresentationState.inactive(),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地关系预览：暂无候选'), findsOneWidget);
    expect(find.text('暂无候选'), findsOneWidget);
    expect(find.textContaining('原因：no_candidate_local'), findsOneWidget);
    expect(find.text('本地关系预览：暂不可用'), findsOneWidget);
    expect(find.text('暂不可用'), findsOneWidget);
    expect(find.textContaining('原因：paused_local'), findsOneWidget);
    expect(find.text('本地关系预览未激活'), findsOneWidget);
    expect(find.textContaining('默认空态或异常载荷'), findsOneWidget);
  });

  testWidgets('renders opener feedback retry and folded local entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RelationshipRuntimeLocalPreviewPanel(
          maxEntries: 2,
          state: _state(
            phase: RelationshipRuntimeLocalPresentationPhase.openerPrepared,
            guards: _manualLocalGuards,
            entries: [
              _entry(
                runtimeState: 'opener_prepared',
                phase: RelationshipRuntimeLocalPresentationPhase.openerPrepared,
                guards: _manualLocalGuards,
                retryable: true,
              ),
              _entry(
                runtimeState: 'feedback_pending',
                phase:
                    RelationshipRuntimeLocalPresentationPhase.feedbackPending,
                guards: _manualLocalGuards,
                retryable: false,
              ),
              _entry(
                runtimeState: 'next_round_pending',
                phase:
                    RelationshipRuntimeLocalPresentationPhase.nextRoundPending,
                guards: _manualLocalGuards,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地关系预览：开场草稿'), findsOneWidget);
    expect(find.textContaining('阶段：开场草稿'), findsOneWidget);
    expect(find.textContaining('展示 2 / 3'), findsOneWidget);
    expect(find.textContaining('另有 1 条已折叠'), findsOneWidget);
    expect(find.text('仅本地开场草稿'), findsNothing);
    expect(find.text('开场草稿'), findsOneWidget);
    expect(find.text('反馈整理'), findsOneWidget);
    expect(find.textContaining('可本地重试'), findsOneWidget);
    expect(find.textContaining('不建议重试'), findsOneWidget);
    expect(find.textContaining('next_round_pending'), findsNothing);
  });

  test('preview panel imports no production wiring dependencies', () {
    final source = File(
      'lib/features/match/presentation/widgets/'
      'relationship_runtime_local_preview_panel.dart',
    ).readAsStringSync();
    final importLines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('import '))
        .toList(growable: false);

    expect(importLines, hasLength(5));
    expect(importLines, contains("import 'package:flutter/material.dart';"));
    expect(
      importLines,
      contains(
        "import 'package:flutter_elitesync_module/features/match/"
        "presentation/state/relationship_runtime_local_presentation_state.dart';",
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

  test('preview panel remains unreferenced by production pages and routes', () {
    const sourcePath =
        'lib/features/match/presentation/widgets/'
        'relationship_runtime_local_preview_panel.dart';
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
        'lib/features/match/presentation/widgets/'
        'relationship_runtime_local_preview_entry.dart',
      )) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains('relationship_runtime_local_preview_panel.dart') ||
          content.contains('RelationshipRuntimeLocalPreviewPanel')) {
        references.add(normalized);
      }
    }

    expect(references, isEmpty);
  });
}
