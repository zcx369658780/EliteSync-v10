// Bounded SDK metadata fixture only. No stdin content, network, devices or pub.
// Getter contracts: dart-sdk/lib/io/stdio.dart, SDK revision
// c70f78e7d682c158c15ca0c26c729b3ccb932284 (Dart 3.11.5).
import 'dart:convert';
import 'dart:io';

const markerPath = r'C:\ProbeOutput\stdio-stages.jsonl';
var sequence = 0;

void mark(String query, String event, {Object? value, String? kind}) {
  final row = <String, Object>{
    'sequence': sequence++,
    'query': query,
    'event': event,
    if (value != null) 'value': value,
    if (kind != null) 'kind': kind,
  };
  File(markerPath).writeAsStringSync(
    '${jsonEncode(row)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

void query(String name, Object Function() read) {
  mark(name, 'before');
  final Object value;
  try {
    value = read();
  } catch (error) {
    // Runtime type only; do not persist exception messages or stream content.
    mark(name, 'error', kind: error.runtimeType.toString());
    return;
  }
  // Marker I/O failures must escape; they are not getter failures.
  mark(name, 'after', value: value);
}

void main() {
  mark('main', 'entered');
  query('stdout_has_terminal', () => stdout.hasTerminal);
  query('stdout_supports_ansi', () => stdout.supportsAnsiEscapes);
  query('stdout_terminal_columns', () => stdout.terminalColumns);
  query('stdout_terminal_lines', () => stdout.terminalLines);
  query('stdin_has_terminal', () => stdin.hasTerminal);
  query('stdin_supports_ansi', () => stdin.supportsAnsiEscapes);
  mark('main', 'completed');
}
