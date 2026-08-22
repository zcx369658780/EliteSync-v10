import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_attempt.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_failure.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/send_message_result.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

class FakeChatRepository implements ChatRepository {
  int sendMessageCount = 0;
  String? lastSentText;
  List<int>? lastAttachmentIds;
  List<MessageEntity> messages = const [];
  bool failMessages = false;
  bool failSend = false;
  Object? nextSendFailure;
  final List<String?> sentClientMessageIds = <String?>[];

  @override
  Future<List<ConversationEntity>> getConversations() async => const [];

  @override
  Future<ConversationEntity> getConversation(int conversationId) async =>
      ConversationEntity(
        id: '23',
        name: 'Stored Peer',
        lastMessage: '',
        lastTime: '',
        unread: 0,
        conversationId: conversationId,
        peerUserId: 23,
      );

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async {
    if (failMessages) throw Exception('network unavailable');
    return messages;
  }

  @override
  Stream<MessageEntity> observeMessages(String conversationId) =>
      const Stream<MessageEntity>.empty();

  @override
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
    String? clientMessageId,
  }) async {
    sendMessageCount += 1;
    lastSentText = text;
    lastAttachmentIds = List<int>.of(attachmentIds);
    sentClientMessageIds.add(clientMessageId);
    final nextFailure = nextSendFailure;
    nextSendFailure = null;
    if (nextFailure != null) throw nextFailure;
    if (failSend) throw StateError('raw send failure detail');
    return SendMessageResult(
      serverMessageId: 1,
      conversationId: 1,
      clientMessageId: clientMessageId,
      idempotentReplay: false,
      message: MessageEntity(
        id: '1',
        mine: true,
        text: text,
        time: '2026-08-03T00:00:00Z',
        attachments: const [],
        clientMessageId: clientMessageId,
      ),
    );
  }
}

class FakeChatMediaGateway implements ChatMediaGateway {
  ChatPickedMedia? picked = const ChatPickedMedia(
    path: r'D:\G1P2_FAKE_ONLY\synthetic.png',
    name: 'synthetic.png',
  );
  Object? pickError;
  ChatMediaUploadResponse response = const ChatMediaUploadResponse(
    assetId: 42,
    publicUrl: 'https://example.invalid/synthetic.png',
    status: 'ready',
  );
  Object? uploadError;
  int pickCount = 0;
  int uploadCount = 0;

  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) async {
    pickCount += 1;
    if (pickError != null) throw pickError!;
    return picked;
  }

  @override
  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  ) async {
    uploadCount += 1;
    if (uploadError != null) throw uploadError!;
    return response;
  }
}

class RecordingAttachmentTelemetry implements ChatAttachmentTelemetry {
  final List<String> events = <String>[];

  @override
  void pickerOpened(ChatAttachmentKind kind) {
    events.add('${kind.mediaType}:picker');
  }

  @override
  void uploadStarted(ChatAttachmentKind kind) {
    events.add('${kind.mediaType}:started');
  }

  @override
  void uploadSucceeded(ChatAttachmentKind kind, int assetId) {
    events.add('${kind.mediaType}:success:$assetId');
  }

  @override
  void uploadFailed(ChatAttachmentKind kind, String errorCode) {
    events.add('${kind.mediaType}:failed:$errorCode');
  }
}

Widget _chatMediaApp({
  required FakeChatRepository repository,
  required FakeChatMediaGateway gateway,
  required RecordingAttachmentTelemetry telemetry,
}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://localhost',
          useMockData: false,
          useMockChat: false,
        ),
      ),
      localStorageProvider.overrideWithValue(FakeLocalStorageService()),
      chatRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: ChatRoomPage(
        routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '合成测试用户'),
        mediaGateway: gateway,
        attachmentTelemetry: telemetry,
      ),
    ),
  );
}

Widget _basicChatApp(FakeChatRepository repository) => ProviderScope(
  overrides: [
    appEnvProvider.overrideWithValue(
      const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'EliteSync',
        apiBaseUrl: 'http://localhost',
        useMockData: false,
        useMockChat: false,
      ),
    ),
    localStorageProvider.overrideWithValue(FakeLocalStorageService()),
    chatRepositoryProvider.overrideWithValue(repository),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: ChatRoomPage(
      routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '重试测试用户'),
    ),
  ),
);

Future<void> _pickSyntheticImage(WidgetTester tester) async {
  await tester.tap(find.byTooltip('添加图片或视频'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('选择图片'));
  await tester.pumpAndSettle();
}

Future<void> _pickSyntheticVideo(WidgetTester tester) async {
  await tester.tap(find.byTooltip('添加图片或视频'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('选择视频'));
  await tester.pumpAndSettle();
}

Future<void> _showSyntheticAttachmentCard(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('synthetic.png'),
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _confirmManualSend(WidgetTester tester) async {
  tester.widget<MessageInputBar>(find.byType(MessageInputBar)).onSend();
  await tester.pumpAndSettle();
}

void main() {
  test('ChatSendAttempt creates canonical UUID-v4 and immutable payload', () {
    final attempt = ChatSendAttempt.create(
      peerUserId: 2,
      content: 'trimmed',
      attachmentIds: [7, 2, 7],
    );

    expect(
      attempt.clientMessageId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(attempt.localMessageId, 'local-${attempt.clientMessageId}');
    expect(attempt.attachmentIds, [7, 2, 7]);
    expect(() => attempt.attachmentIds.add(9), throwsUnsupportedError);
  });

  test('ChatSendAttempt payload equality preserves order and trimmed text', () {
    final attempt = ChatSendAttempt(
      clientMessageId: '00000000-0000-4000-8000-000000000001',
      peerUserId: 2,
      content: 'same',
      attachmentIds: [4, 8],
    );

    expect(
      attempt.hasSamePayload(
        peerUserId: 2,
        content: ' same ',
        attachmentIds: [4, 8],
      ),
      isTrue,
    );
    expect(
      attempt.hasSamePayload(
        peerUserId: 2,
        content: 'same',
        attachmentIds: [8, 4],
      ),
      isFalse,
    );
  });

  testWidgets('unchanged explicit retry reuses the exact client key', (
    tester,
  ) async {
    final repository = FakeChatRepository()
      ..nextSendFailure = StateError('first attempt failed');
    await tester.pumpWidget(_basicChatApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'same payload');
    await _confirmManualSend(tester);
    await tester.pumpAndSettle();
    await _confirmManualSend(tester);
    await tester.pumpAndSettle();

    expect(repository.sentClientMessageIds, hasLength(2));
    expect(
      repository.sentClientMessageIds[1],
      repository.sentClientMessageIds[0],
    );
  });

  testWidgets('changed payload creates a new client key', (tester) async {
    final repository = FakeChatRepository()
      ..nextSendFailure = StateError('first attempt failed');
    await tester.pumpWidget(_basicChatApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'first payload');
    await _confirmManualSend(tester);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'changed payload');
    await _confirmManualSend(tester);
    await tester.pumpAndSettle();

    expect(repository.sentClientMessageIds, hasLength(2));
    expect(
      repository.sentClientMessageIds[1],
      isNot(repository.sentClientMessageIds[0]),
    );
  });

  testWidgets('payload mismatch blocks unchanged same-key retry', (
    tester,
  ) async {
    final repository = FakeChatRepository()
      ..nextSendFailure = const ChatSendFailure(
        message: 'payload mismatch',
        statusCode: 409,
        serverCode: ChatSendFailure.payloadMismatchCode,
      );
    await tester.pumpWidget(_basicChatApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'conflicting payload');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(repository.sendMessageCount, 1);
    expect(find.textContaining('原发送请求冲突'), findsOneWidget);
  });

  testWidgets('ChatRoomPage hides engineering test messages', (tester) async {
    final repository = FakeChatRepository()
      ..messages = const [
        MessageEntity(
          id: 'm-engineering',
          mine: true,
          text: 'codex test message after fix',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-333',
          mine: true,
          text: '333',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-444',
          mine: true,
          text: '444',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-222',
          mine: true,
          text: '222',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-new-message-test',
          mine: true,
          text: '新消息测试',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-234',
          mine: true,
          text: '234',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-556',
          mine: true,
          text: '556',
          time: '10:00',
          attachments: <MessageAttachmentEntity>[],
        ),
        MessageEntity(
          id: 'm-user',
          mine: false,
          text: '我也喜欢慢节奏散步。',
          time: '10:01',
          attachments: <MessageAttachmentEntity>[],
        ),
      ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockChat: true,
            ),
          ),
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '九紫瑶瑶'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('codex test message after fix'), findsNothing);
    expect(find.text('333'), findsNothing);
    expect(find.text('444'), findsNothing);
    expect(find.text('222'), findsNothing);
    expect(find.text('新消息测试'), findsNothing);
    expect(find.text('234'), findsNothing);
    expect(find.text('556'), findsNothing);
    expect(find.text('我也喜欢慢节奏散步。'), findsOneWidget);
  });

  testWidgets('ChatRoomPage neutralizes SmokeUser in visible header', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(
              peerUserId: 2,
              title: 'SmokeUser',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('示例用户'), findsOneWidget);
    expect(find.text('SmokeUser'), findsNothing);
  });

  testWidgets('ChatRoomPage renders voice rhythm guidance for valid chat', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '九紫瑶瑶'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('语音节奏'), findsOneWidget);
    expect(find.text('本轮慢约会对话'), findsOneWidget);
    expect(find.textContaining('这段对话来自你已经确认的慢约会'), findsOneWidget);
    expect(find.text('查看语音前提示'), findsOneWidget);
    expect(find.text('今天适合怎样表达'), findsOneWidget);
    expect(find.text('从哪里开始'), findsOneWidget);
    expect(find.text('手动确认'), findsOneWidget);

    await tester.tap(find.text('查看语音前提示'));
    await tester.pumpAndSettle();

    expect(find.text('语音前先确认节奏'), findsOneWidget);
    expect(find.text('继续文字'), findsOneWidget);
    expect(find.text('现在语音'), findsOneWidget);

    await tester.tap(find.text('继续文字'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('关系节奏提示'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('关系节奏提示'), findsOneWidget);
    expect(find.textContaining('仍需你手动确认发送'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('冷场恢复建议'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('冷场恢复建议'), findsOneWidget);
    expect(find.textContaining('不会读取私密聊天'), findsOneWidget);
  });

  testWidgets('ChatRoomPage renders 5.9 low-pressure opening contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '九紫瑶瑶'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('低压开场建议'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('低压开场建议'), findsOneWidget);
    expect(find.textContaining('这只是开场建议，不会自动发出'), findsOneWidget);
    expect(find.text('从共同点开始'), findsOneWidget);
    expect(find.text('换个更自然的说法'), findsOneWidget);
    expect(find.text('低压问候建议'), findsOneWidget);
    expect(find.text('不要太急'), findsOneWidget);
    expect(find.text('可编辑草稿'), findsOneWidget);
    expect(find.text('冷场恢复'), findsOneWidget);
    expect(find.text('续话提示'), findsOneWidget);
    expect(find.text('填入后仍需你自己确认发送'), findsOneWidget);
    expect(find.textContaining('不会读取私密聊天'), findsOneWidget);
    expect(find.textContaining('不会写入资料'), findsOneWidget);
    expect(find.textContaining('不会自动发送消息'), findsOneWidget);
    expect(find.textContaining('自己确认是否发送'), findsOneWidget);
    expect(find.byTooltip('添加图片或视频'), findsOneWidget);

    await tester.tap(find.byTooltip('添加图片或视频'));
    await tester.pumpAndSettle();

    expect(find.text('选择图片'), findsOneWidget);
    expect(find.text('选择视频'), findsOneWidget);
  });

  testWidgets('ChatRoomPage opening suggestions write drafts without sending', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '九紫瑶瑶'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    const drafts = <String, String>{
      '从共同点开始': '我看到我们有些相近的地方，想从一个轻松的问题开始：你最近最愿意投入的一件事是什么？',
      '换个更自然的说法': '刚刚那句话我想换个轻松点的问法：你平时更喜欢怎么慢慢认识一个人？',
      '低压问候建议': '嗨，今天过得怎么样？不用急着回，我只是想先从一个轻松的问候开始。',
      '不要太急': '我不想聊得太急。我们可以先从最近让你放松的一件小事聊起。',
    };

    for (final entry in drafts.entries) {
      await tester.scrollUntilVisible(
        find.text(entry.key),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      final input = tester.widget<TextField>(find.byType(TextField));
      expect(input.controller?.text, entry.value);
      expect(repository.sendMessageCount, 0);
      expect(repository.lastSentText, isNull);
    }
  });

  testWidgets('ChatRoomPage explains empty chat lifecycle state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '九紫瑶瑶'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('还没有消息'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有消息'), findsOneWidget);
    expect(find.textContaining('这段对话来自本轮慢约会'), findsOneWidget);
    expect(find.textContaining('编辑好后再决定是否发送'), findsOneWidget);
    expect(find.text('返回会话列表'), findsOneWidget);
  });

  testWidgets('ChatRoomPage explains recoverable message loading failure', (
    tester,
  ) async {
    final repository = FakeChatRepository()..failMessages = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ChatRoomPage(
            routeState: ChatRouteState.legacyPeer(peerUserId: 2, title: '九紫瑶瑶'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('消息加载失败'), findsOneWidget);
    expect(find.textContaining('暂时无法加载消息'), findsOneWidget);
    expect(find.textContaining('当前网络不稳定'), findsNothing);
    expect(find.textContaining('继续编辑草稿'), findsOneWidget);
    expect(find.text('返回会话列表'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets(
    'ChatRoomPage rolls back failed text send and restores a sanitized draft',
    (tester) async {
      final repository = FakeChatRepository()..failSend = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(FakeLocalStorageService()),
            chatRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: ChatRoomPage(
              routeState: ChatRouteState.legacyPeer(
                peerUserId: 2,
                title: '九紫瑶瑶',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const draft = '这条消息发送失败后应保留';
      await tester.enterText(find.byType(TextField), draft);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(repository.sendMessageCount, 1);
      expect(repository.lastSentText, draft);
      expect(repository.lastAttachmentIds, isEmpty);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        draft,
      );
      expect(
        find.descendant(
          of: find.byType(MessageBubble),
          matching: find.text(draft),
        ),
        findsNothing,
      );
      expect(find.text('发送失败，已恢复输入框，请稍后重试'), findsOneWidget);
      expect(find.textContaining('raw send failure detail'), findsNothing);
      expect(find.textContaining('发送成功'), findsNothing);
    },
  );

  test('attachment response contract is finite and fail closed', () {
    ChatMediaResponseContract contract(String? status, {int? id, String? url}) {
      return ChatMediaResponseContract.evaluate(
        ChatMediaUploadResponse(assetId: id, publicUrl: url, status: status),
      );
    }

    for (final status in ['pending', 'uploading', 'processing']) {
      expect(
        contract(status).disposition,
        ChatMediaResponseDisposition.processing,
      );
    }
    for (final status in [
      null,
      '',
      'failed',
      'blocked',
      'deleted',
      'mystery',
    ]) {
      expect(contract(status).disposition, ChatMediaResponseDisposition.failed);
    }
    expect(
      contract(
        'ready',
        id: 42,
        url: 'https://example.invalid/fake.png',
      ).disposition,
      ChatMediaResponseDisposition.ready,
    );
    expect(
      contract(
        'uploaded',
        id: 42,
        url: 'https://example.invalid/fake.png',
      ).disposition,
      ChatMediaResponseDisposition.ready,
    );
    expect(
      contract('ready', id: null, url: null).errorCode,
      'invalid_response',
    );
  });

  testWidgets('attachment picker cancel selects nothing and does not fail', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway()..picked = null;
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticImage(tester);

    expect(gateway.pickCount, 1);
    expect(gateway.uploadCount, 0);
    expect(find.text('synthetic.png'), findsNothing);
    expect(telemetry.events, ['image:picker']);
  });

  testWidgets('attachment picker throw is sanitized and never uploads', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway()
      ..pickError = StateError('raw picker path and permission detail');
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticImage(tester);

    expect(gateway.uploadCount, 0);
    expect(find.text('图片选择失败，请重新选择'), findsOneWidget);
    expect(find.textContaining('raw picker'), findsNothing);
    expect(telemetry.events, ['image:picker', 'image:failed:picker_error']);
    expect(
      telemetry.events.where((event) => event.contains(':success:')),
      isEmpty,
    );
  });

  testWidgets('attachment upload throw is failed and not send ready', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway()
      ..uploadError = StateError('raw object storage failure');
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticImage(tester);
    await _showSyntheticAttachmentCard(tester);

    expect(find.text('上传失败'), findsOneWidget);
    expect(find.text('图片上传失败，请重新选择。'), findsOneWidget);
    expect(find.textContaining('object storage'), findsNothing);
    expect(telemetry.events, [
      'image:picker',
      'image:started',
      'image:failed:upload_failed',
    ]);
    expect(
      telemetry.events.where((event) => event.contains(':success:')),
      isEmpty,
    );
  });

  testWidgets('explicit failed metadata is quarantined from manual send', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway()
      ..response = const ChatMediaUploadResponse(
        assetId: 999,
        publicUrl: 'https://example.invalid/must-not-send.png',
        status: 'failed',
      );
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticImage(tester);
    await _showSyntheticAttachmentCard(tester);
    await tester.enterText(find.byType(TextField), '仅发送合成文本');
    await _confirmManualSend(tester);

    expect(repository.sendMessageCount, 1);
    expect(repository.lastSentText, '仅发送合成文本');
    expect(repository.lastAttachmentIds, isEmpty);
    expect(find.text('可以发送'), findsNothing);
    expect(find.text('重新选择'), findsOneWidget);
    expect(find.text('重试上传'), findsNothing);
    expect(telemetry.events, [
      'image:picker',
      'image:started',
      'image:failed:failed_status',
    ]);
    expect(
      telemetry.events.where((event) => event.contains(':success:')),
      isEmpty,
    );
  });

  testWidgets('processing attachment remains visible but non-send-ready', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway()
      ..response = const ChatMediaUploadResponse(
        assetId: 77,
        publicUrl: 'https://example.invalid/processing.png',
        status: 'processing',
      );
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticImage(tester);
    await _showSyntheticAttachmentCard(tester);
    expect(find.text('正在处理'), findsOneWidget);
    expect(find.text('图片正在处理，完成前不能发送。'), findsOneWidget);
    expect(telemetry.events, ['image:picker', 'image:started']);

    await tester.enterText(find.byType(TextField), '处理期间只发文本');
    await _confirmManualSend(tester);
    expect(repository.lastAttachmentIds, isEmpty);
  });

  testWidgets('known ready fake stays manual and sends only after tap', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway();
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticImage(tester);
    await _showSyntheticAttachmentCard(tester);
    expect(find.text('可以发送'), findsOneWidget);
    expect(repository.sendMessageCount, 0);
    expect(telemetry.events, [
      'image:picker',
      'image:started',
      'image:success:42',
    ]);

    await tester.enterText(find.byType(TextField), '合成文本与附件');
    await _confirmManualSend(tester);
    expect(repository.sendMessageCount, 1);
    expect(repository.lastAttachmentIds, [42]);
  });

  testWidgets(
    'video upload failure stays non-ready without success telemetry',
    (tester) async {
      final repository = FakeChatRepository();
      final gateway = FakeChatMediaGateway()
        ..picked = const ChatPickedMedia(
          path: r'D:\G1P2_FAKE_ONLY\synthetic.mp4',
          name: 'synthetic.mp4',
        )
        ..response = const ChatMediaUploadResponse(
          assetId: 88,
          publicUrl: 'https://example.invalid/must-not-send.mp4',
          status: 'failed',
        );
      final telemetry = RecordingAttachmentTelemetry();
      await tester.pumpWidget(
        _chatMediaApp(
          repository: repository,
          gateway: gateway,
          telemetry: telemetry,
        ),
      );
      await tester.pumpAndSettle();

      await _pickSyntheticVideo(tester);
      await tester.scrollUntilVisible(
        find.text('synthetic.mp4'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('上传失败'), findsOneWidget);
      expect(find.text('可以发送'), findsNothing);
      expect(telemetry.events, [
        'video:picker',
        'video:started',
        'video:failed:failed_status',
      ]);
      expect(
        telemetry.events.where((event) => event.contains(':success:')),
        isEmpty,
      );
    },
  );

  testWidgets('known ready video remains manual until text send', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final gateway = FakeChatMediaGateway()
      ..picked = const ChatPickedMedia(
        path: r'D:\G1P2_FAKE_ONLY\synthetic.mp4',
        name: 'synthetic.mp4',
      )
      ..response = const ChatMediaUploadResponse(
        assetId: 88,
        publicUrl: 'https://example.invalid/synthetic.mp4',
        status: 'ready',
      );
    final telemetry = RecordingAttachmentTelemetry();
    await tester.pumpWidget(
      _chatMediaApp(
        repository: repository,
        gateway: gateway,
        telemetry: telemetry,
      ),
    );
    await tester.pumpAndSettle();

    await _pickSyntheticVideo(tester);
    await tester.scrollUntilVisible(
      find.text('synthetic.mp4'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('可以发送'), findsOneWidget);
    expect(repository.sendMessageCount, 0);
    expect(telemetry.events, [
      'video:picker',
      'video:started',
      'video:success:88',
    ]);

    await tester.enterText(find.byType(TextField), '合成视频与文本');
    await _confirmManualSend(tester);
    expect(repository.sendMessageCount, 1);
    expect(repository.lastAttachmentIds, [88]);
  });
}
