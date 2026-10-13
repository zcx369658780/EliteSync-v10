import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/qualification_diagnostics/domain/qualification_diagnostic.dart';

const contextId = 'fiction-session-pair:cn-a:cv-a';
const expected = <String, (DiagnosticOutcome, String)>{
  'pending_single_party': (
    DiagnosticOutcome.rejected, 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN',
  ),
  'contract_satisfied': (
    DiagnosticOutcome.contractEvaluated,
    'FICTIONAL_CONTRACT_ONLY_FORMAL_QUALIFICATION_UNKNOWN',
  ),
  'connection_paused': (
    DiagnosticOutcome.rejected, 'CN_MC_CONTRACT_NOT_SATISFIED',
  ),
  'connection_closed': (
    DiagnosticOutcome.rejected, 'CN_MC_CONTRACT_NOT_SATISFIED',
  ),
  'conversation_paused': (
    DiagnosticOutcome.rejected, 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN',
  ),
  'conversation_closed': (
    DiagnosticOutcome.rejected, 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN',
  ),
  'consent_revoked': (
    DiagnosticOutcome.rejected, 'CN_MC_CONTRACT_NOT_SATISFIED',
  ),
  'stale': (
    DiagnosticOutcome.rejected, 'SOURCE_BINDING_OR_FRESHNESS_REJECTED:identity',
  ),
  'revision_mismatch': (
    DiagnosticOutcome.rejected,
    'SOURCE_REVISION_NOT_CURRENT_OR_COMPARABLE:identity',
  ),
  'source_error': (DiagnosticOutcome.unavailable, 'SOURCE_READ_FAILED'),
  'source_missing': (
    DiagnosticOutcome.unavailable, 'SOURCE_NOT_YET_ESTABLISHED:identity',
  ),
  'cross_context': (
    DiagnosticOutcome.rejected, 'SOURCE_PROVENANCE_MISMATCH:identity',
  ),
};

void main() {
  late String raw;
  late Map<String, dynamic> original;

  QualificationDiagnostic parse(String value, {String context = contextId}) =>
      QualificationDiagnostic.parse(
        value,
        expectedContextId: context,
        expectedScenarioIds: expected.keys.toSet(),
      );

  Map<String, dynamic> copy() =>
      jsonDecode(jsonEncode(original)) as Map<String, dynamic>;

  void reject(void Function(Map<String, dynamic>) mutate) {
    final changed = copy();
    mutate(changed);
    expect(() => parse(jsonEncode(changed)), throwsFormatException);
  }

  setUpAll(() {
    const path = String.fromEnvironment('QUALIFICATION_DIAGNOSTIC_FIXTURE');
    if (path.isEmpty || !File(path).existsSync()) {
      throw StateError('Same-run PHP diagnostic fixture is mandatory');
    }
    final bytes = File(path).readAsBytesSync();
    raw = utf8.decode(bytes, allowMalformed: false);
    // This receipt binds the actual input bytes, before any decode/re-encode.
    // ignore: avoid_print
    print('QUALIFICATION_DIAGNOSTIC_INPUT_SHA256=${sha256.convert(bytes)}');
    // ignore: avoid_print
    print('QUALIFICATION_DIAGNOSTIC_INPUT_BYTES=${bytes.length}');
    original = jsonDecode(raw) as Map<String, dynamic>;
  });

  test('same-run PHP outcomes and reasons match independent scenario oracle', () {
    final projection = parse(raw);
    expect(projection.records.map((record) => record.scenarioId).toSet(),
        expected.keys.toSet());
    expect(projection.records.length, expected.length);
    for (final record in projection.records) {
      final oracle = expected[record.scenarioId]!;
      expect(record.contextId, contextId);
      expect(record.outcome, oracle.$1, reason: record.scenarioId);
      expect(record.reasonCodes, [oracle.$2], reason: record.scenarioId);
    }
    expect(QualificationDiagnostic.notice, contains('No message permission'));
    // Evaluate raw declarations separately from the DTO's diagnostic outcome.
    for (final object in [original, ...original['records'] as List]) {
      for (final field in [
        'permission', 'live_grant', 'read_allowed', 'send_allowed',
      ]) {
        expect(object[field], isFalse);
      }
    }
  });

  test('projection collections are immutable and detached from wire objects', () {
    final projection = parse(raw);
    expect(() => projection.records.clear(), throwsUnsupportedError);
    expect(() => projection.records.first.reasonCodes.add('forged'),
        throwsUnsupportedError);
    expect(() => projection.records.first.reasonCodes[0] = 'forged',
        throwsUnsupportedError);
    final changed = copy();
    (changed['records'] as List).clear();
    expect(projection.records.length, expected.length);
  });

  test('every envelope field is required, extras and wrong literals fail', () {
    for (final key in original.keys) {
      reject((object) => object.remove(key));
    }
    reject((object) => object['token'] = 'fictional-forbidden-field');
    for (final key in ['schema_version', 'kind']) {
      for (final wrong in [null, false, 1, [], {}, 'unknown']) {
        reject((object) => object[key] = wrong);
      }
    }
    for (final key in ['synthetic_dev_test_only', 'diagnostic_only']) {
      for (final wrong in [null, false, 1, 'true', [], {}]) {
        reject((object) => object[key] = wrong);
      }
    }
    for (final wrong in [null, false, 1, 'records', {}, []]) {
      reject((object) => object['records'] = wrong);
    }
    expect(() => parse('[]'), throwsFormatException);
    expect(() => parse('null'), throwsFormatException);
  });

  test('every record field is required and undeclared fields fail', () {
    final first = (original['records'] as List).first as Map<String, dynamic>;
    for (final key in first.keys) {
      reject((object) => (object['records'][0] as Map).remove(key));
    }
    reject((object) => object['records'][0]['canChat'] = true);
    for (final wrong in [null, false, 1, 'record', []]) {
      reject((object) => object['records'][0] = wrong);
    }
  });

  test('all envelope and record permission bits require original false bool', () {
    for (final key in [
      'permission', 'live_grant', 'read_allowed', 'send_allowed',
    ]) {
      for (final wrong in [true, null, 0, 1, 'false', [], {}]) {
        reject((object) => object[key] = wrong);
        reject((object) => object['records'][0][key] = wrong);
      }
    }
  });

  test('identity, context, outcome and reasons fail closed without coercion', () {
    for (final key in ['scenario_id', 'context_id']) {
      for (final wrong in [null, false, 1, [], {}, '', '  ']) {
        reject((object) => object['records'][0][key] = wrong);
      }
    }
    reject((object) => object['records'][0]['context_id'] = 'other-context');
    reject((object) => object['records'][1]['scenario_id'] =
        object['records'][0]['scenario_id']);
    reject((object) => (object['records'] as List).add(object['records'][0]));
    for (final wrong in [null, false, 1, [], {}, '', 'ACTIVE']) {
      reject((object) => object['records'][0]['diagnostic_outcome'] = wrong);
    }
    for (final wrong in [null, false, 1, {}, '', [], [''], [' '], [null], [1]]) {
      reject((object) => object['records'][0]['reason_codes'] = wrong);
    }
    expect(() => parse(raw, context: ''), throwsFormatException);
    expect(() => parse(raw, context: 'other-context'), throwsFormatException);
  });

  test('ambiguous duplicate JSON keys including escaped aliases are rejected', () {
    expect(() => parse(raw.replaceFirst('{', '{"permission":true,')),
        throwsFormatException);
    expect(() => parse(raw.replaceFirst('{', '{"permission":false,')),
        throwsFormatException);
    expect(() => parse(raw.replaceFirst('{', '{"\\u0070ermission":false,')),
        throwsFormatException);
    final duplicateRecord = raw.replaceFirst(
      '"scenario_id":', '"permission":false,"scenario_id":',
    );
    expect(duplicateRecord, isNot(raw));
    expect(() => parse(duplicateRecord), throwsFormatException);
  });

  test('scenario identities must exactly match caller expectations', () {
    reject((object) => object['records'][0]['scenario_id'] = 'unknown_unique');
    reject((object) => (object['records'] as List).removeLast());
    for (final ids in <Set<String>>[
      {},
      {''},
      {'  '},
      {'unknown_unique'},
      {...expected.keys, 'unexpected_extra'},
      expected.keys.skip(1).toSet(),
    ]) {
      expect(
        () => QualificationDiagnostic.parse(
          raw,
          expectedContextId: contextId,
          expectedScenarioIds: ids,
        ),
        throwsFormatException,
      );
    }
  });

  test('malformed JSON, trailing tokens and excessive nesting are rejected', () {
    for (final invalid in [
      '', '{', '$raw false', raw.substring(0, raw.length ~/ 2),
      '{"permission":false,}', '[1,]', '{"x":"\\q"}',
      List.filled(66, '[').join() + '0' + List.filled(66, ']').join(),
    ]) {
      expect(() => parse(invalid), throwsFormatException);
    }
    expect(parse(' \n$raw\t ').records.length, expected.length);
  });
}
