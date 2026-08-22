class ChatSendFailure implements Exception {
  const ChatSendFailure({
    required this.message,
    this.statusCode,
    this.serverCode,
  });

  static const payloadMismatchCode = 'client_message_id_payload_mismatch';
  static const conversationIdentityConflictCode =
      'conversation_identity_conflict';

  final String message;
  final int? statusCode;
  final String? serverCode;

  bool get isPayloadMismatch =>
      statusCode == 409 && serverCode == payloadMismatchCode;

  bool get isConversationIdentityConflict =>
      serverCode == conversationIdentityConflictCode;

  @override
  String toString() => message;
}
