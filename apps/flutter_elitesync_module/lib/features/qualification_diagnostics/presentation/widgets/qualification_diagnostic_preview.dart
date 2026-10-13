import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/qualification_diagnostic.dart';

/// Test-harness-only presentation. No navigation, capabilities or persisted state.
class QualificationDiagnosticPreview extends StatelessWidget {
  const QualificationDiagnosticPreview({
    super.key,
    this.enabled = false,
    required this.sourceJson,
    required this.expectedContextId,
    required this.expectedScenarioIds,
    required this.scenarioId,
  });

  final bool enabled;
  final String? sourceJson;
  final String expectedContextId;
  final Set<String> expectedScenarioIds;
  final String scenarioId;

  static const syntheticNotice = 'Synthetic dev-test / 仅测试诊断';
  static const trustNotice = 'source trust UNKNOWN';
  static const qualificationNotice = 'formal qualification NOT ESTABLISHED';
  static const permissionNotice = '不授予消息读取/发送权限';
  static const unavailableNotice = '无可靠诊断；不可用于实际许可';
  static const statusKey = ValueKey('qualification-diagnostic-status');

  /// A pure truth-table seam, not an injectable build-mode override on the widget.
  @visibleForTesting
  static bool displayAllowed({required bool debugBuild, required bool enabled}) =>
      debugBuild && enabled;

  @override
  Widget build(BuildContext context) {
    // This real build-mode constant is never caller-controlled. Check before
    // parsing; neither disabled nor non-debug builds retain a parsed projection.
    if (!displayAllowed(debugBuild: kDebugMode, enabled: enabled)) {
      return const SizedBox.shrink();
    }
    QualificationDiagnosticRecord? current;
    final source = sourceJson;
    if (source != null) {
      try {
        final parsed = QualificationDiagnostic.parse(
          source,
          expectedContextId: expectedContextId,
          expectedScenarioIds: expectedScenarioIds,
        );
        for (final record in parsed.records) {
          if (record.scenarioId == scenarioId) current = record;
        }
      } on FormatException {
        // Replace the whole diagnostic with the unavailable view below. Never
        // keep a last-success value, infer authority, or soften parser validation.
      }
    }
    final status = current == null
        ? unavailableNotice
        : switch (current.outcome) {
            DiagnosticOutcome.contractEvaluated => '合同检查完成（不代表正式资格）',
            DiagnosticOutcome.rejected => '合同拒绝',
            DiagnosticOutcome.unavailable => '输入/来源不可用',
          };
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(syntheticNotice),
            const Text(trustNotice),
            const Text(qualificationNotice),
            const Text(permissionNotice),
            const SizedBox(height: 12),
            Text(status, key: statusKey),
            if (current != null) ...[
              Text('虚构场景：${current.scenarioId}'),
              Text('虚构上下文：${current.contextId}'),
              for (final reason in current.reasonCodes) Text('Reason: $reason'),
            ],
          ],
        ),
      ),
    );
  }
}
