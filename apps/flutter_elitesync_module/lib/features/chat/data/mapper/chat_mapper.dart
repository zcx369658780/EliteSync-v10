import 'package:flutter_elitesync_module/features/chat/data/dto/message_attachment_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_response_dto.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';

class ChatMapper {
  const ChatMapper();
  ConversationEntity conversation(ConversationDto dto) => ConversationEntity(
    id: dto.id,
    name: dto.name,
    lastMessage: dto.lastMessage,
    lastTime: dto.lastTime,
    unread: dto.unread,
    entryKind: dto.entryKind,
    conversationId: dto.conversationId,
    peerUserId: dto.peerUserId,
    matchId: dto.matchId,
  );
  MessageEntity message(MessageDto dto) => MessageEntity(
    id: dto.id,
    mine: dto.mine,
    text: dto.text,
    time: dto.time,
    clientMessageId: dto.clientMessageId,
    attachments: dto.attachments.map(_attachment).toList(),
  );
  SendMessageResult sendMessageResult(SendMessageResponseDto dto) =>
      SendMessageResult(
        serverMessageId: dto.serverMessageId,
        conversationId: dto.conversationId,
        clientMessageId: dto.clientMessageId,
        idempotentReplay: dto.idempotentReplay,
        message: message(dto.message),
      );

  MessageAttachmentEntity _attachment(MessageAttachmentDto dto) =>
      MessageAttachmentEntity(
        id: dto.id,
        attachmentType: dto.attachmentType,
        mediaAssetId: dto.mediaAssetId,
        mediaType: dto.mediaType,
        publicUrl: dto.publicUrl,
        status: dto.status,
        mimeType: dto.mimeType,
        sizeBytes: dto.sizeBytes,
        width: dto.width,
        height: dto.height,
        durationMs: dto.durationMs,
      );
}
