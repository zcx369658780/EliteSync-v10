/// A server receipt delivered by the authenticated current-message reader.
final class OfflineChatText {
  static const maxDuration = Duration(hours: 24);

  static Duration? remaining({
    required Object? receipt,
    required DateTime now,
    required DateTime loginAt,
    required int accountId,
    required int peerId,
    required String deviceId,
    required String sessionId,
    required String roomKey,
  }) {
    if (receipt is! Map ||
        receipt['scope'] != 'conversation_text_v1' ||
        receipt['account_id'] != accountId ||
        receipt['peer_id'] != peerId ||
        receipt['room_key'] != roomKey ||
        receipt['device_id'] != deviceId ||
        receipt['session_id'] != sessionId) {
      return null;
    }
    final issued = DateTime.tryParse(receipt['issued_at']?.toString() ?? '');
    final expiry = DateTime.tryParse(receipt['expires_at']?.toString() ?? '');
    if (issued == null ||
        expiry == null ||
        !issued.isUtc ||
        !expiry.isUtc ||
        issued.isBefore(loginAt) ||
        now.isBefore(issued) ||
        !now.isBefore(expiry) ||
        expiry.difference(issued) > maxDuration) {
      return null;
    }
    return expiry.difference(now);
  }

  static Map<String, dynamic>? project(Object? row, String roomKey) {
    if (row is! Map ||
        row['room_id'] != roomKey ||
        row['message_type'] != 'text' ||
        row['has_attachments'] != false ||
        row['attachments'] is! List ||
        (row['attachments'] as List).isNotEmpty ||
        row['id'] is! int ||
        row['sender_id'] is! int ||
        row['content'] is! String) {
      return null;
    }
    final reply = row['reply'];
    return {
      'id': row['id'],
      'room_id': roomKey,
      'sender_id': row['sender_id'],
      'content': row['content'],
      'message_type': 'text',
      'has_attachments': false,
      'attachments': const <Object>[],
      if (reply is Map &&
          reply['available'] == true &&
          reply['offline_text'] == true &&
          reply['summary'] is String)
        'reply': {
          'available': true,
          'offline_text': true,
          'summary': reply['summary'],
        },
    };
  }
}
