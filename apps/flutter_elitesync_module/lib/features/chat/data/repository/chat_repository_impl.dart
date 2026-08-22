import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/mapper/chat_mapper.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required this.remote,
    required this.socket,
    required this.mapper,
  });

  final ChatRemoteDataSource remote;
  final ChatSocketDataSource socket;
  final ChatMapper mapper;

  @override
  Future<List<ConversationEntity>> getConversations() async =>
      (await remote.getConversations()).map(mapper.conversation).toList();

  @override
  Future<ConversationEntity> getConversation(int conversationId) async =>
      mapper.conversation(await remote.getConversation(conversationId));

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async =>
      (await remote.getMessages(conversationId)).map(mapper.message).toList();

  @override
  Stream<MessageEntity> observeMessages(String conversationId) =>
      socket.observe(conversationId).map(mapper.message);

  @override
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) async {
    final response = await remote.sendMessage(
      conversationId,
      text,
      attachmentIds: attachmentIds,
      clientMessageId: clientMessageId,
    );
    return mapper.sendMessageResult(response);
  }
}
