import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/mapper/chat_mapper.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _Repository implements ChatRepository {
  int reads = 0;
  String content = 'initial authorized read';
  final frames = StreamController<MessageEntity>.broadcast();
  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async {
    reads++;
    return [
      MessageEntity(
        id: 'server-message',
        mine: false,
        text: content,
        time: '',
        attachments: const [],
      ),
    ];
  }

  @override
  Stream<MessageEntity> observeMessages(String conversationId) => frames.stream;
  @override
  Future<List<ConversationEntity>> getConversations() async => const [];
  @override
  Future<ConversationEntity> getConversation(int conversationId) async =>
      ConversationEntity(
        id: '2',
        name: 'synthetic peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        conversationId: conversationId,
        peerUserId: 2,
      );
  @override
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) => throw StateError('This read-only contract test cannot send.');
}

void main() {
  test(
    'configured gateway 8022 and peer scope are preserved instead of legacy 8081',
    () {
      final uri = buildChatSocketUri(
        apiBaseUrl: 'http://127.0.0.1:8021',
        wsBaseUrl: 'ws://127.0.0.1:8022',
        selfId: 8,
        peerId: 2,
      );
      expect(uri.port, 8022);
      expect(uri.path, '/api/v1/messages/ws/8');
      expect(uri.queryParameters, {'peer_id': '2'});
      expect(
        () => buildChatSocketUri(
          apiBaseUrl: 'http://127.0.0.1',
          wsBaseUrl: 'https://invalid.invalid',
          selfId: 8,
          peerId: 2,
        ),
        throwsStateError,
      );
    },
  );

  testWidgets(
    'minimal conversation_changed frame causes current HTTP readback without displaying frame body',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _Repository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.dev,
                appName: 'test',
                apiBaseUrl: 'http://unused.invalid',
                useMockData: false,
                useMockChat: false,
              ),
            ),
            conversationAccessProvider.overrideWithBuild(
              (ref, notifier) => ProductConversationAccessAdapter.resolve(
                connection: const ProductConnectionEvidence.authoritative(
                  ProductConnectionState.active,
                ),
                messagingConsent: const MessagingConsentEvidence.authoritative(
                  MessagingConsentState.mutual,
                ),
              ),
            ),
            chatRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatRoomPage(
              routeState: ChatRouteState.legacyPeer(
                peerUserId: 2,
                title: 'synthetic peer',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('initial authorized read'), findsOneWidget);
      final beforeReadback = repository.reads;
      repository.content = 'new authorized HTTP read';
      final frame = decodeChatSocketEvent(
        '{"type":"conversation_changed","id":9,"content":"untrusted frame private text","nickname":"untrusted name","attachments":[{"url":"untrusted"}]}',
        selfId: 8,
        peerId: 2,
      );
      expect(frame, isNotNull);
      expect(frame!.text, isEmpty);
      expect(frame.attachments, isEmpty);
      repository.frames.add(const ChatMapper().message(frame));
      await tester.pumpAndSettle();
      expect(repository.reads, beforeReadback + 1);
      expect(find.text('new authorized HTTP read'), findsOneWidget);
      expect(find.text('untrusted frame private text'), findsNothing);
      expect(find.text('untrusted name'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.frames.close();
    },
  );
}
