import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/chat_mock.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const defaultDevEnv = AppEnv(
  flavor: AppFlavor.dev,
  appName: 'Default dev',
  apiBaseUrl: 'http://127.0.0.1:9/',
  useMockData: true,
);

ProviderContainer demoContainer() => ProviderContainer(
  overrides: [appEnvProvider.overrideWithValue(createDemoAppEnv())],
);

void makeSyntheticConnectionActive(ProviderContainer container) {
  final controller = container.read(connectionPresentationProvider.notifier);
  controller.apply(ConnectionLifecycleAction.request);
  controller.apply(ConnectionLifecycleAction.accept);
  expect(
    container.read(connectionPresentationProvider).state,
    ProductConnectionState.active,
  );
}

void activateSyntheticConversation(ProviderContainer container) {
  makeSyntheticConnectionActive(container);
  final controller = container.read(conversationAccessProvider.notifier);
  expect(
    container.read(conversationAccessProvider).state,
    ProductConversationState.locked,
  );
  controller.apply(ConversationLifecycleAction.requestMessagingConsent);
  controller.apply(ConversationLifecycleAction.acceptMessagingConsent);
  expect(
    container.read(conversationAccessProvider).state,
    ProductConversationState.active,
  );
}

void main() {
  test('synthetic Conversation requires the explicit demo flag', () {
    expect(defaultDevEnv.useSyntheticConversationLifecycle, isFalse);
    expect(createDemoAppEnv().useSyntheticConversationLifecycle, isTrue);

    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(defaultDevEnv)],
    );
    addTearDown(container.dispose);
    final snapshot = container.read(conversationAccessProvider);
    expect(snapshot.authority, ConversationEvidenceAuthority.notYetEstablished);
    expect(snapshot.canRevealPrivateContent, isFalse);
    expect(snapshot.canSend, isFalse);
  });

  test('independent messaging consent unlocks only synthetic local access', () {
    final container = demoContainer();
    addTearDown(container.dispose);

    final initial = container.read(conversationAccessProvider);
    expect(initial.authority, ConversationEvidenceAuthority.syntheticDevelopment);
    expect(initial.state, ProductConversationState.locked);
    expect(initial.canRevealPrivateContent, isFalse);
    expect(initial.canSend, isFalse);

    makeSyntheticConnectionActive(container);
    expect(
      container.read(conversationAccessProvider).state,
      ProductConversationState.locked,
    );

    final controller = container.read(conversationAccessProvider.notifier);
    controller.apply(ConversationLifecycleAction.requestMessagingConsent);
    expect(
      container.read(conversationAccessProvider).state,
      ProductConversationState.pendingConsent,
    );
    expect(container.read(conversationAccessProvider).canSend, isFalse);

    controller.apply(ConversationLifecycleAction.acceptMessagingConsent);
    final active = container.read(conversationAccessProvider);
    expect(active.state, ProductConversationState.active);
    expect(active.authority, ConversationEvidenceAuthority.syntheticDevelopment);
    expect(active.hasAuthoritativeState, isFalse);
    expect(active.canRevealPrivateContent, isTrue);
    expect(active.canSend, isTrue);
    expect(controller.hasLocalMutualConsent, isTrue);
    expect(ProductConversationAuthority.authoritativeActions, isEmpty);
  });

  test('production access adapter remains strict and never emits synthetic evidence', () {
    final unresolved = ProductConversationAccessAdapter.resolve(
      connection: const ProductConnectionEvidence.notYetEstablished(),
      messagingConsent: const MessagingConsentEvidence.notYetEstablished(),
    );
    expect(unresolved.authority, ConversationEvidenceAuthority.notYetEstablished);
    expect(unresolved.canRevealPrivateContent, isFalse);

    final insufficient = ProductConversationAccessAdapter.resolve(
      connection: const ProductConnectionEvidence.authoritative(
        ProductConnectionState.active,
      ),
      messagingConsent: const MessagingConsentEvidence.notYetEstablished(),
    );
    expect(insufficient.authority, ConversationEvidenceAuthority.notYetEstablished);
    expect(insufficient.canSend, isFalse);
  });

  test('decline and withdraw return fresh pending consent to locked', () {
    for (final action in <ConversationLifecycleAction>[
      ConversationLifecycleAction.declineMessagingConsent,
      ConversationLifecycleAction.withdrawMessagingConsent,
    ]) {
      final container = demoContainer();
      addTearDown(container.dispose);
      makeSyntheticConnectionActive(container);
      final controller = container.read(conversationAccessProvider.notifier);
      controller.apply(ConversationLifecycleAction.requestMessagingConsent);
      controller.apply(action);
      final snapshot = container.read(conversationAccessProvider);
      expect(snapshot.state, ProductConversationState.locked);
      expect(snapshot.canRevealPrivateContent, isFalse);
      expect(controller.hasLocalMutualConsent, isFalse);
    }
  });

  test('pause resume close follow the contract and connection invalidation relocks', () {
    final lifecycle = demoContainer();
    addTearDown(lifecycle.dispose);
    activateSyntheticConversation(lifecycle);
    final controller = lifecycle.read(conversationAccessProvider.notifier);

    controller.apply(ConversationLifecycleAction.pause);
    expect(
      lifecycle.read(conversationAccessProvider).state,
      ProductConversationState.paused,
    );
    controller.apply(ConversationLifecycleAction.resume);
    expect(
      lifecycle.read(conversationAccessProvider).state,
      ProductConversationState.active,
    );
    controller.apply(ConversationLifecycleAction.close);
    expect(
      lifecycle.read(conversationAccessProvider).state,
      ProductConversationState.closed,
    );
    expect(lifecycle.read(conversationAccessProvider).canSend, isFalse);

    final invalidated = demoContainer();
    addTearDown(invalidated.dispose);
    activateSyntheticConversation(invalidated);
    invalidated
        .read(connectionPresentationProvider.notifier)
        .apply(ConnectionLifecycleAction.pause);
    final relocked = invalidated.read(conversationAccessProvider);
    expect(relocked.state, ProductConversationState.locked);
    expect(relocked.canRevealPrivateContent, isFalse);
    expect(relocked.canSend, isFalse);
  });

  test('mock list read send and socket remain completely local', () async {
    final api = _CountingApiClient();
    final storage = LocalStorageService();
    final remote = ChatRemoteDataSource(
      apiClient: api,
      localStorage: storage,
      useMock: true,
    );

    final conversations = await remote.getConversations();
    expect(conversations, hasLength(1));
    final conversation = conversations.single;
    expect(conversation.conversationId, ChatMock.syntheticConversationId);
    expect(conversation.peerUserId, ChatMock.syntheticPeerUserId);
    expect(conversation.matchId, ChatMock.syntheticMatchId);
    expect(conversation.name, contains('Synthetic Demo'));

    final detail = await remote.getConversation(
      ChatMock.syntheticConversationId,
    );
    expect(detail.peerUserId, ChatMock.syntheticPeerUserId);

    final messages = await remote.getMessages(
      ChatMock.syntheticPeerUserId.toString(),
    );
    expect(messages, isNotEmpty);
    expect(messages.every((message) => message.text.contains('开发演示假消息')), isTrue);

    const text = 'Synthetic hello from APP-INT-04';
    final sent = await remote.sendMessage(
      ChatMock.syntheticPeerUserId.toString(),
      text,
      clientMessageId: 'synthetic-client-message-1',
    );
    expect(sent.conversationId, ChatMock.syntheticConversationId);
    expect(sent.message.text, text);

    final socket = ChatSocketDataSource(
      apiClient: api,
      localStorage: storage,
      env: createDemoAppEnv(),
    );
    expect(
      await socket.observe(ChatMock.syntheticPeerUserId.toString()).toList(),
      isEmpty,
    );
    expect(api.requestCount, 0);
  });
}

class _CountingApiClient extends ApiClient {
  _CountingApiClient() : super(dio: Dio());

  int requestCount = 0;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    requestCount += 1;
    throw StateError('mock path must return before ApiClient.get');
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    requestCount += 1;
    throw StateError('mock path must return before ApiClient.post');
  }
}
