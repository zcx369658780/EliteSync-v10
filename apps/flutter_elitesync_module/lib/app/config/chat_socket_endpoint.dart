/// Only the API authority (or an explicit port on that authority) may receive
/// the chat bearer. Plain WS is restricted to controlled development loopback.
String resolveChatSocketBaseUrl({
  required String apiBaseUrl,
  String override = '',
  bool allowLocalInsecure = false,
}) {
  final api = Uri.tryParse(apiBaseUrl.trim());
  if (api == null ||
      !const ['http', 'https'].contains(api.scheme) ||
      api.host.isEmpty ||
      api.userInfo.isNotEmpty ||
      api.hasQuery ||
      api.hasFragment) {
    throw StateError('Invalid API authority for websocket');
  }
  final local = const {
    '127.0.0.1',
    'localhost',
    '::1',
    '10.0.2.2',
  }.contains(api.host.toLowerCase());
  final value = override.trim();
  if (value.isNotEmpty) {
    final ws = Uri.tryParse(value);
    if (ws == null ||
        !const ['ws', 'wss'].contains(ws.scheme) ||
        ws.host.toLowerCase() != api.host.toLowerCase() ||
        ws.userInfo.isNotEmpty ||
        ws.hasQuery ||
        ws.hasFragment ||
        (ws.path.isNotEmpty && ws.path != '/') ||
        (ws.scheme == 'ws' &&
            (api.scheme == 'https' || !allowLocalInsecure || !local))) {
      throw StateError('Untrusted websocket authority or TLS downgrade');
    }
    return ws.replace(path: '').toString();
  }
  if (api.scheme == 'https') {
    return Uri(
      scheme: 'wss',
      host: api.host,
      port: api.hasPort ? api.port : null,
    ).toString();
  }
  if (allowLocalInsecure && local) {
    // The existing local chat gateway has its own port, not the HTTP API port.
    return Uri(scheme: 'ws', host: api.host, port: 8081).toString();
  }
  // The legacy public HTTP API remains unchanged. Never infer a bearer WS
  // destination from that unqualified non-TLS entry.
  return '';
}
