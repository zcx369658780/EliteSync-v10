import 'package:flutter_elitesync_module/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_request_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_response_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/mapper/chat_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversationDto typed identity', () {
    test('stored entry keeps distinct conversation and peer identities', () {
      final dto = ConversationDto.fromJson({
        'id': 'legacy-peer-alias',
        'name': 'Peer',
        'entry_kind': 'stored_conversation',
        'conversation_id': 501,
        'peer_user_id': 23,
      });
      final entity = const ChatMapper().conversation(dto);

      expect(dto.id, 'legacy-peer-alias');
      expect(entity.entryKind, 'stored_conversation');
      expect(entity.conversationId, 501);
      expect(entity.peerUserId, 23);
      expect(entity.matchId, isNull);
    });

    test('eligible match keeps null conversation plus peer and match IDs', () {
      final entity = const ChatMapper().conversation(
        ConversationDto.fromJson({
          'id': '31',
          'name': 'Eligible Peer',
          'entry_kind': 'eligible_match',
          'peer_user_id': 31,
          'match_id': 77,
        }),
      );

      expect(entity.entryKind, 'eligible_match');
      expect(entity.conversationId, isNull);
      expect(entity.peerUserId, 31);
      expect(entity.matchId, 77);
    });

    test(
      'legacy id remains a peer alias without fabricating conversation ID',
      () {
        final entity = const ChatMapper().conversation(
          ConversationDto.fromJson({'id': '29', 'name': 'Legacy Peer'}),
        );

        expect(entity.id, '29');
        expect(entity.peerUserId, 29);
        expect(entity.conversationId, isNull);
        expect(entity.entryKind, isNull);
      },
    );
  });

  group('SendMessageRequestDto', () {
    test('legacy request omits client key', () {
      final json = const SendMessageRequestDto(
        receiverId: 23,
        content: 'hello',
        attachmentIds: [9, 4],
      ).toJson();

      expect(json, {
        'receiver_id': 23,
        'content': 'hello',
        'attachment_ids': [9, 4],
      });
      expect(json, isNot(contains('client_message_id')));
    });

    test('keyed request emits exact key and preserves attachment order', () {
      final json = const SendMessageRequestDto(
        receiverId: 23,
        content: ' hello ',
        attachmentIds: [7, 2, 7],
        clientMessageId: 'client-key-1',
      ).toJson();

      expect(json['content'], ' hello ');
      expect(json['attachment_ids'], [7, 2, 7]);
      expect(json['client_message_id'], 'client-key-1');
    });
  });

  group('SendMessageResponseDto', () {
    Map<String, dynamic> success({
      String? clientMessageId = 'client-key-1',
      bool replay = false,
    }) => {
      'id': 91,
      'conversation_id': 37,
      'client_message_id': clientMessageId,
      'idempotent_replay': replay,
      'message': {
        'id': 91,
        'mine': true,
        'content': 'hello',
        'time': '2026-08-03T10:00:00Z',
        'client_message_id': clientMessageId,
        'attachments': const <dynamic>[],
      },
    };

    test('parses first success and shaped message client key', () {
      final dto = SendMessageResponseDto.fromJson(success());

      expect(dto.serverMessageId, 91);
      expect(dto.conversationId, 37);
      expect(dto.clientMessageId, 'client-key-1');
      expect(dto.idempotentReplay, isFalse);
      expect(dto.message.id, '91');
      expect(dto.message.text, 'hello');
      expect(dto.message.clientMessageId, 'client-key-1');
    });

    test('parses replay and accepts unkeyed legacy success', () {
      final dto = SendMessageResponseDto.fromJson(
        success(clientMessageId: null, replay: true),
      );

      expect(dto.clientMessageId, isNull);
      expect(dto.message.clientMessageId, isNull);
      expect(dto.idempotentReplay, isTrue);
    });

    test('rejects malformed successful identities', () {
      expect(
        () => SendMessageResponseDto.fromJson({...success(), 'id': 0}),
        throwsFormatException,
      );
      expect(
        () => SendMessageResponseDto.fromJson({
          ...success(),
          'conversation_id': null,
        }),
        throwsFormatException,
      );
    });
  });
}
