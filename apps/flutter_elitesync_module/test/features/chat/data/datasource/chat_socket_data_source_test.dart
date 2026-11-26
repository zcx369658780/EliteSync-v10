import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';

void main() {
  test('buildChatSocketUri uses the development loopback gateway', () {
    final uri = buildChatSocketUri(
      apiBaseUrl: 'http://127.0.0.1:8021',
      selfId: 37,
      peerId: 52,
    );

    expect(uri.toString(), 'ws://127.0.0.1:8081/api/v1/messages/ws/37?peer_id=52');
  });

  test('buildChatSocketUri rejects public plaintext and cross-origin gateways', () {
    expect(
      () => buildChatSocketUri(apiBaseUrl: 'http://192.0.2.20', selfId: 37),
      throwsStateError,
    );
    expect(
      () => buildChatSocketUri(
        apiBaseUrl: 'https://qa.example',
        wsBaseUrl: 'wss://other.example',
        selfId: 37,
      ),
      throwsStateError,
    );
  });

  test('buildChatSocketUri maps https api base to wss gateway without port', () {
    final uri = buildChatSocketUri(
      apiBaseUrl: 'https://slowdate.top',
      selfId: 8,
    );

    expect(uri.toString(), 'wss://slowdate.top/api/v1/messages/ws/8');
  });

  test('decodeChatSocketEvent keeps only paired message events', () {
    final dto = decodeChatSocketEvent(
      '{"type":"message","id":11,"sender_id":7,"receiver_id":8,"content":"hello","created_at":"2026-04-19T12:00:00Z"}',
      selfId: 8,
      peerId: 7,
    );

    expect(dto, isNotNull);
    expect(dto!.id, '11');
    expect(dto.mine, isFalse);
    expect(dto.text, 'hello');
  });
}
