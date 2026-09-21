class ChatMock {
  static const syntheticPeerUserId = 990000201;
  static const syntheticMatchId = 990000101;
  static const syntheticConversationId = 990000301;

  static const conversationsHappy = [
    {
      'id': '$syntheticPeerUserId',
      'entry_kind': 'stored_conversation',
      'conversation_id': syntheticConversationId,
      'peer_user_id': syntheticPeerUserId,
      'match_id': syntheticMatchId,
      'name': 'Synthetic Demo Partner',
      'avatar': null,
      'last_message': 'Synthetic 开发演示假消息：这是本地会话摘要。',
      'last_time': 'Demo',
      'unread': 0,
    },
  ];

  static const conversationsEmpty = <Map<String, Object?>>[];

  static const conversationsError = {
    'ok': false,
    'code': 'CHAT_LIST_ERROR',
    'message': '会话列表加载失败',
  };

  static const messagesHappy = [
    {
      'id': '990000401',
      'mine': false,
      'text': 'Synthetic 开发演示假消息：这里没有真实参与者数据。',
      'time': 'Demo 10:15',
    },
    {
      'id': '990000402',
      'mine': true,
      'text': 'Synthetic 开发演示假消息：读取与发送只发生在本地。',
      'time': 'Demo 10:16',
    },
  ];
}
