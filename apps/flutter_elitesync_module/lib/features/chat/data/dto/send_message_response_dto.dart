import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';

class SendMessageResponseDto {
  const SendMessageResponseDto({
    required this.serverMessageId,
    required this.conversationId,
    required this.clientMessageId,
    required this.idempotentReplay,
    required this.message,
  });

  final int serverMessageId;
  final int conversationId;
  final String? clientMessageId;
  final bool idempotentReplay;
  final MessageDto message;

  factory SendMessageResponseDto.fromJson(Map<String, dynamic> json) {
    final serverMessageId = _positiveInt(json['id']);
    final conversationId = _positiveInt(json['conversation_id']);
    final messageJson = json['message'];
    if (serverMessageId == null || conversationId == null) {
      throw const FormatException(
        'Send response requires positive message and conversation identities.',
      );
    }
    if (messageJson is! Map<String, dynamic>) {
      throw const FormatException('Send response requires a shaped message.');
    }

    return SendMessageResponseDto(
      serverMessageId: serverMessageId,
      conversationId: conversationId,
      clientMessageId: _nullableString(json['client_message_id']),
      idempotentReplay: json['idempotent_replay'] == true,
      message: MessageDto.fromJson(messageJson),
    );
  }

  static int? _positiveInt(dynamic value) {
    final int? parsed;
    if (value is int) {
      parsed = value;
    } else if (value is num) {
      parsed = value.isFinite && value == value.truncateToDouble()
          ? value.toInt()
          : null;
    } else {
      parsed = int.tryParse(value?.toString() ?? '');
    }
    return parsed != null && parsed > 0 ? parsed : null;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString();
    return parsed.isEmpty ? null : parsed;
  }
}
