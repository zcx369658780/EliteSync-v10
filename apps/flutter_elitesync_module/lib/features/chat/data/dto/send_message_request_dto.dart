class SendMessageRequestDto {
  const SendMessageRequestDto({
    required this.receiverId,
    required this.content,
    this.attachmentIds = const [],
    this.clientMessageId,
  });
  final int receiverId;
  final String content;
  final List<int> attachmentIds;
  final String? clientMessageId;

  Map<String, dynamic> toJson() => {
    'receiver_id': receiverId,
    'content': content,
    if (attachmentIds.isNotEmpty) 'attachment_ids': attachmentIds,
    if (clientMessageId != null && clientMessageId!.isNotEmpty)
      'client_message_id': clientMessageId,
  };
}
