import 'dart:convert';

/// A contract diagnostic, never a Conversation state or a permission.
enum DiagnosticOutcome { contractEvaluated, rejected, unavailable }

final class QualificationDiagnosticRecord {
  QualificationDiagnosticRecord._(
    this.scenarioId,
    this.contextId,
    this.outcome,
    List<String> reasons,
  ) : reasonCodes = List.unmodifiable(reasons);

  final String scenarioId;
  final String contextId;
  final DiagnosticOutcome outcome;
  final List<String> reasonCodes;
}

/// Immutable diagnostic projection with no callbacks or access capabilities.
final class QualificationDiagnostic {
  QualificationDiagnostic._(List<QualificationDiagnosticRecord> records)
    : records = List.unmodifiable(records);

  static const schemaVersion = 'elitesync.qualification-diagnostic.v1';
  static const notice =
      'Synthetic dev-test diagnostic only. No message permission is granted.';
  final List<QualificationDiagnosticRecord> records;

  static QualificationDiagnostic parse(
    String source, {
    required String expectedContextId,
    required Set<String> expectedScenarioIds,
  }) {
    _nonempty(expectedContextId);
    if (expectedScenarioIds.isEmpty) {
      throw const FormatException('Nonempty expected scenario set required');
    }
    final expectedScenarios = Set<String>.unmodifiable(
      expectedScenarioIds.map(_nonempty),
    );
    final envelope = _object(_UniqueKeyJson(source).decode(), const {
      'schema_version', 'kind', 'synthetic_dev_test_only', 'diagnostic_only',
      'permission', 'live_grant', 'read_allowed', 'send_allowed', 'records',
    });
    if (envelope['schema_version'] != schemaVersion ||
        envelope['kind'] != 'QUALIFICATION_DIAGNOSTIC' ||
        envelope['synthetic_dev_test_only'] != true ||
        envelope['diagnostic_only'] != true) {
      throw const FormatException('Invalid diagnostic envelope');
    }
    _zeroPermissions(envelope);
    final entries = envelope['records'];
    if (entries is! List || entries.isEmpty) {
      throw const FormatException('Nonempty records required');
    }
    final seen = <String>{};
    final records = <QualificationDiagnosticRecord>[];
    for (final entry in entries) {
      final record = _object(entry, const {
        'scenario_id', 'context_id', 'diagnostic_outcome', 'reason_codes',
        'permission', 'live_grant', 'read_allowed', 'send_allowed',
      });
      _zeroPermissions(record);
      final scenario = _nonempty(record['scenario_id']);
      if (!expectedScenarios.contains(scenario)) {
        throw const FormatException('Unexpected scenario identity');
      }
      if (!seen.add(scenario)) {
        throw const FormatException('Duplicate scenario identity');
      }
      final context = _nonempty(record['context_id']);
      if (context != expectedContextId) {
        throw const FormatException('Context mismatch');
      }
      final outcome = switch (record['diagnostic_outcome']) {
        'CONTRACT_EVALUATED' => DiagnosticOutcome.contractEvaluated,
        'REJECTED' => DiagnosticOutcome.rejected,
        'UNAVAILABLE' => DiagnosticOutcome.unavailable,
        _ => throw const FormatException('Unknown diagnostic outcome'),
      };
      final reasons = record['reason_codes'];
      if (reasons is! List || reasons.isEmpty) {
        throw const FormatException('Nonempty reason codes required');
      }
      records.add(QualificationDiagnosticRecord._(
        scenario, context, outcome, reasons.map(_nonempty).toList(),
      ));
    }
    if (seen.length != expectedScenarios.length) {
      throw const FormatException('Missing expected scenario identity');
    }
    return QualificationDiagnostic._(records);
  }

  static Map<String, dynamic> _object(Object? value, Set<String> keys) {
    if (value is! Map<String, dynamic> ||
        value.length != keys.length ||
        !value.keys.every(keys.contains)) {
      throw const FormatException('Exact diagnostic object shape required');
    }
    return value;
  }

  static String _nonempty(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Nonempty string required');
    }
    return value;
  }

  static void _zeroPermissions(Map<String, dynamic> object) {
    for (final key in const [
      'permission', 'live_grant', 'read_allowed', 'send_allowed',
    ]) {
      if (object[key] is! bool || object[key] != false) {
        throw const FormatException('Diagnostic must carry Boolean false');
      }
    }
  }
}

/// Standard JSON token decoding with duplicate decoded object keys rejected.
/// dart:convert alone keeps the last duplicate, which is unsafe for this wire
/// contract. This decoder rejects ambiguous raw input before schema validation.
final class _UniqueKeyJson {
  _UniqueKeyJson(this.source);
  final String source;
  int offset = 0;

  Object? decode() {
    final value = _value(0);
    _space();
    if (offset != source.length) _invalid();
    return value;
  }

  Never _invalid() => throw const FormatException('Invalid or ambiguous JSON');

  void _space() {
    while (offset < source.length &&
        const [32, 9, 10, 13].contains(source.codeUnitAt(offset))) {
      offset++;
    }
  }

  bool _take(String token) {
    _space();
    if (source.startsWith(token, offset)) {
      offset += token.length;
      return true;
    }
    return false;
  }

  Object? _value(int depth) {
    if (depth > 64) _invalid();
    _space();
    if (offset >= source.length) _invalid();
    if (_take('{')) {
      final object = <String, dynamic>{};
      if (_take('}')) return object;
      do {
        _space();
        if (offset >= source.length || source[offset] != '"') _invalid();
        final key = _string();
        if (object.containsKey(key) || !_take(':')) _invalid();
        object[key] = _value(depth + 1);
        if (_take('}')) return object;
      } while (_take(','));
      _invalid();
    }
    if (_take('[')) {
      final array = <Object?>[];
      if (_take(']')) return array;
      do {
        array.add(_value(depth + 1));
        if (_take(']')) return array;
      } while (_take(','));
      _invalid();
    }
    if (source[offset] == '"') return _string();
    final start = offset;
    while (offset < source.length &&
        !const [32, 9, 10, 13, 44, 93, 125].contains(source.codeUnitAt(offset))) {
      offset++;
    }
    if (offset == start) _invalid();
    return jsonDecode(source.substring(start, offset));
  }

  String _string() {
    final start = offset++;
    while (offset < source.length) {
      final character = source[offset++];
      if (character == '\\') {
        if (offset >= source.length) _invalid();
        offset++;
      } else if (character == '"') {
        return jsonDecode(source.substring(start, offset)) as String;
      }
    }
    _invalid();
  }
}
