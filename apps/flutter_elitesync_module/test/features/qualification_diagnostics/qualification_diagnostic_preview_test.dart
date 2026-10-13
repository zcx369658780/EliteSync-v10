import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/qualification_diagnostics/presentation/widgets/qualification_diagnostic_preview.dart';

const contextId = 'fiction-session-pair:cn-a:cv-a';
const scenarioIds = {
  'pending_single_party', 'contract_satisfied', 'connection_paused',
  'connection_closed', 'conversation_paused', 'conversation_closed',
  'consent_revoked', 'stale', 'revision_mismatch', 'source_error',
  'source_missing', 'cross_context',
};
const completeLabel = '合同检查完成（不代表正式资格）';

void main() {
  late String raw;
  late Map<String, dynamic> original;
  String altered(void Function(Map<String, dynamic>) mutate) {
    final copy = jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
    mutate(copy);
    return jsonEncode(copy);
  }

  Future<void> render(
    WidgetTester tester, {
    required String? input,
    bool enabled = true,
    String scenario = 'contract_satisfied',
    String context = contextId,
    double scale = 1,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: QualificationDiagnosticPreview(
            key: const ValueKey('same-preview-instance'),
            enabled: enabled,
            sourceJson: input,
            expectedContextId: context,
            expectedScenarioIds: scenarioIds,
            scenarioId: scenario,
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  void notices() {
    for (final text in [
      QualificationDiagnosticPreview.syntheticNotice,
      QualificationDiagnosticPreview.trustNotice,
      QualificationDiagnosticPreview.qualificationNotice,
      QualificationDiagnosticPreview.permissionNotice,
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(TextField), findsNothing);
  }

  setUpAll(() {
    const path = String.fromEnvironment('QUALIFICATION_DIAGNOSTIC_FIXTURE');
    if (path.isEmpty || !File(path).existsSync()) {
      throw StateError('Same-run PHP JSON is mandatory; no static fallback');
    }
    final bytes = File(path).readAsBytesSync();
    raw = utf8.decode(bytes, allowMalformed: false);
    original = jsonDecode(raw) as Map<String, dynamic>;
    // ignore: avoid_print
    print('WIDGET_DIAGNOSTIC_INPUT_SHA256=${sha256.convert(bytes)}');
    // ignore: avoid_print
    print('WIDGET_DIAGNOSTIC_INPUT_BYTES=${bytes.length}');
  });

  test('production gate truth table cannot enable non-debug modes', () {
    expect(kDebugMode, isTrue); // Actual runtime here is Debug, not Release proof.
    for (final debug in [false, true]) {
      for (final enabled in [false, true]) {
        expect(QualificationDiagnosticPreview.displayAllowed(
          debugBuild: debug, enabled: enabled,
        ), debug && enabled);
      }
    }
  });

  testWidgets('default constructor is closed with malformed input', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QualificationDiagnosticPreview(
      sourceJson: '{malformed', expectedContextId: '',
      expectedScenarioIds: {}, scenarioId: '',
    )));
    expect(find.byKey(QualificationDiagnosticPreview.statusKey), findsNothing);
    expect(find.text(QualificationDiagnosticPreview.syntheticNotice), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit disable immediately removes previously valid diagnostics', (tester) async {
    await render(tester, input: raw);
    expect(find.text(completeLabel), findsOneWidget);
    await render(tester, input: '{bad', enabled: false);
    expect(find.text(completeLabel), findsNothing);
    expect(find.byKey(QualificationDiagnosticPreview.statusKey), findsNothing);
    await render(tester, input: raw);
    expect(find.text(completeLabel), findsOneWidget);
  });

  testWidgets('fresh PHP contract-evaluated result renders no message authority', (tester) async {
    await render(tester, input: raw);
    expect(find.text(completeLabel), findsOneWidget);
    expect(find.text('Reason: FICTIONAL_CONTRACT_ONLY_FORMAL_QUALIFICATION_UNKNOWN'), findsOneWidget);
    notices();
  });

  const rejectedReasons = {
    'pending_single_party': 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN',
    'connection_paused': 'CN_MC_CONTRACT_NOT_SATISFIED',
    'connection_closed': 'CN_MC_CONTRACT_NOT_SATISFIED',
    'conversation_paused': 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN',
    'conversation_closed': 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN',
    'consent_revoked': 'CN_MC_CONTRACT_NOT_SATISFIED',
    'stale': 'SOURCE_BINDING_OR_FRESHNESS_REJECTED:identity',
    'revision_mismatch': 'SOURCE_REVISION_NOT_CURRENT_OR_COMPARABLE:identity',
    'cross_context': 'SOURCE_PROVENANCE_MISMATCH:identity',
  };
  for (final entry in rejectedReasons.entries) {
    testWidgets('current ${entry.key} replaces old success with actual rejection', (tester) async {
      await render(tester, input: raw);
      expect(find.text(completeLabel), findsOneWidget);
      await render(tester, input: raw, scenario: entry.key);
      expect(find.text(completeLabel), findsNothing);
      expect(find.text('合同拒绝'), findsOneWidget);
      expect(find.text('Reason: ${entry.value}'), findsOneWidget);
      notices();
    });
  }

  for (final scenario in ['source_error', 'source_missing']) {
    testWidgets('$scenario replaces old success with unavailable input', (tester) async {
      await render(tester, input: raw);
      await render(tester, input: raw, scenario: scenario);
      expect(find.text(completeLabel), findsNothing);
      expect(find.text('输入/来源不可用'), findsOneWidget);
      notices();
    });
  }

  testWidgets('missing invalid and wrong-context inputs clear same widget immediately', (tester) async {
    for (final input in <String?>[null, '', '{', '$raw false', 'null']) {
      await render(tester, input: raw);
      expect(find.text(completeLabel), findsOneWidget);
      await render(tester, input: input);
      expect(find.text(completeLabel), findsNothing);
      expect(find.text(QualificationDiagnosticPreview.unavailableNotice), findsOneWidget);
      expect(find.textContaining('Reason:'), findsNothing);
      notices();
    }
    await render(tester, input: raw, context: 'other-context');
    expect(find.text(QualificationDiagnosticPreview.unavailableNotice), findsOneWidget);
    await render(tester, input: raw, scenario: 'unknown');
    expect(find.text(QualificationDiagnosticPreview.unavailableNotice), findsOneWidget);
  });

  testWidgets('fresh input removal missing keys extras wrong types and grants fail closed', (tester) async {
    final changes = <void Function(Map<String, dynamic>)>[
      (o) => o.remove('schema_version'),
      (o) => o['schema_version'] = 'other',
      (o) => o['token'] = 'forbidden',
      (o) => o['records'] = 'wrong-type',
      (o) => o['permission'] = true,
      (o) => o['records'][1]['live_grant'] = true,
      (o) => o['records'][1]['read_allowed'] = 'false',
      (o) => o['records'][1]['send_allowed'] = null,
      (o) => o['records'][1]['context_id'] = 'other',
      (o) => o['records'][1]['scenario_id'] = 'unknown',
      (o) => (o['records'] as List).removeAt(1),
      (o) => o['records'][1]['diagnostic_outcome'] = 'CV_ACTIVE',
    ];
    for (final change in changes) {
      await render(tester, input: raw);
      await render(tester, input: altered(change));
      expect(find.text(completeLabel), findsNothing);
      expect(find.text(QualificationDiagnosticPreview.unavailableNotice), findsOneWidget);
      notices();
    }
  });

  testWidgets('new revoked stale or source-error envelope replaces old valid content', (tester) async {
    for (final scenario in ['consent_revoked', 'stale', 'source_error']) {
      // Explicit derived invalidation case: replace current record's diagnostic
      // with a real negative record from the same fresh producer envelope.
      final negative = (original['records'] as List).singleWhere(
        (r) => r['scenario_id'] == scenario,
      );
      final changed = altered((o) {
        o['records'][1]['diagnostic_outcome'] = negative['diagnostic_outcome'];
        o['records'][1]['reason_codes'] = negative['reason_codes'];
      });
      await render(tester, input: raw);
      await render(tester, input: changed);
      expect(find.text(completeLabel), findsNothing);
      expect(find.text('Reason: ${negative['reason_codes'][0]}'), findsOneWidget);
      notices();
    }
  });

  testWidgets('180px narrow viewport long reason and 3x text scroll without overflow', (tester) async {
    tester.view.physicalSize = const Size(180, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final longReason = 'LAYOUT_STRESS_${List.filled(60, 'long_reason').join('_')}';
    final input = altered((o) => o['records'][1]['reason_codes'] = [longReason]);
    await render(tester, input: input, scale: 3);
    notices();
    final permission = find.text(QualificationDiagnosticPreview.permissionNotice);
    await tester.ensureVisible(permission);
    await tester.pump();
    expect(tester.getRect(permission).overlaps(const Rect.fromLTWH(0, 0, 180, 640)), isTrue);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Reason: $longReason'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
