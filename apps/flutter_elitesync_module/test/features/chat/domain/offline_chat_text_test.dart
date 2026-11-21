import 'package:flutter_elitesync_module/features/chat/domain/offline_chat_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final issued = DateTime.utc(2026, 11, 22, 8);
  const room = 'cn:5:mc:8';
  final grant = {
    'scope': 'conversation_text_v1',
    'account_id': 1,
    'peer_id': 2,
    'device_id': 'device-a',
    'session_id': 'session-a',
    'room_key': room,
    'issued_at': issued.toIso8601String(),
    'expires_at': issued.add(const Duration(hours: 24)).toIso8601String(),
  };
  Duration? remaining(Map<String, dynamic> receipt, DateTime now) =>
      OfflineChatText.remaining(
        receipt: receipt,
        now: now,
        loginAt: issued.subtract(const Duration(minutes: 5)),
        accountId: 1,
        peerId: 2,
        deviceId: 'device-a',
        sessionId: 'session-a',
        roomKey: room,
      );

  test('24-hour lease closes exactly at the UTC deadline', () {
    expect(remaining(grant, issued), const Duration(hours: 24));
    expect(remaining(grant, issued.add(const Duration(hours: 24))), isNull);
    expect(
      remaining(grant, issued.subtract(const Duration(seconds: 1))),
      isNull,
    );
    expect(
      remaining({
        ...grant,
        'expires_at': issued.add(const Duration(hours: 25)).toIso8601String(),
      }, issued),
      isNull,
    );
  });

  test('account, peer, device, login, scope and generation must all match', () {
    for (final entry in {
      'account_id': 3,
      'peer_id': 3,
      'device_id': 'foreign-device',
      'session_id': 'previous-login',
      'scope': 'media',
      'room_key': 'cn:5:mc:9',
    }.entries) {
      expect(remaining({...grant, entry.key: entry.value}, issued), isNull);
    }
  });

  test('only same-room text and explicitly text-only replies are retained', () {
    final message = {
      'id': 7,
      'room_id': room,
      'sender_id': 2,
      'content': 'fictional body',
      'message_type': 'text',
      'has_attachments': false,
      'attachments': [],
      'reply': {
        'available': true,
        'offline_text': true,
        'summary': 'text reply',
      },
    };
    expect(OfflineChatText.project(message, room)?['reply'], message['reply']);
    expect(
      OfflineChatText.project({...message, 'room_id': 'cn:5:mc:9'}, room),
      isNull,
    );
    expect(
      OfflineChatText.project({...message, 'has_attachments': true}, room),
      isNull,
    );
    final mediaReply = {
      ...message,
      'reply': {'available': true, 'offline_text': false, 'summary': 'media'},
    };
    expect(
      OfflineChatText.project(mediaReply, room)?.containsKey('reply'),
      isFalse,
    );
  });
}
