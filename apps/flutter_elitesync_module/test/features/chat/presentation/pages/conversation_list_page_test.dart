import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/conversation_list_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_list_ui_state.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:go_router/go_router.dart';

class FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = <String, Object?>{};
  final List<String> stringReads = [];
  final List<String> stringWrites = [];
  final List<String> removals = [];

  void seedString(String key, String value) => _values[key] = value;
  String? storedString(String key) => _values[key] as String?;

  @override
  Future<String?> getString(String key) async {
    stringReads.add(key);
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    stringWrites.add(key);
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    removals.add(key);
    _values.remove(key);
    return true;
  }
}

final _conversationStateProvider = StateProvider<ConversationListUiState>(
  (ref) => const ConversationListUiState(items: []),
);

final _syntheticAuthorizedConversationAccess =
    ProductConversationAccessAdapter.resolve(
      connection: const ProductConnectionEvidence.authoritative(
        ProductConnectionState.active,
      ),
      messagingConsent: const MessagingConsentEvidence.authoritative(
        MessagingConsentState.mutual,
      ),
    );

void main() {
  testWidgets('ConversationListPage hides legacy snapshot while loading', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    localStorage.seedString(
      CacheKeys.messagesConversationSnapshot,
      jsonEncode([
        {
          'id': '2',
          'name': '缓存用户',
          'lastMessage': '先显示缓存消息',
          'lastTime': '09:30',
          'unread': 1,
        },
      ]),
    );
    final pending = Completer<ConversationListUiState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockChat: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          conversationListProvider.overrideWith((ref) => pending.future),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ConversationListPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('缓存用户'), findsNothing);
    expect(find.text('先显示缓存消息'), findsNothing);
    expect(find.text('正在更新 · 以下为上次内容'), findsNothing);
    expect(localStorage.stringReads, isNot(contains(CacheKeys.messagesConversationSnapshot)));
    expect(find.text('待回复'), findsNothing);
    expect(find.text('1'), findsNothing);

    pending.complete(const ConversationListUiState(items: []));
    await tester.pumpAndSettle();

    expect(find.text('缓存用户'), findsNothing);
    expect(find.text('先显示缓存消息'), findsNothing);
    expect(find.text('正在更新 · 以下为上次内容'), findsNothing);
    expect(find.text('还没有可聊对象'), findsOneWidget);
    expect(localStorage.storedString(CacheKeys.messagesConversationSnapshot), isNotNull);
    expect(localStorage.stringWrites, isNot(contains(CacheKeys.messagesConversationSnapshot)));
    expect(localStorage.removals, isNot(contains(CacheKeys.messagesConversationSnapshot)));
  });

  testWidgets(
    'ConversationListPage hides legacy snapshot when refresh fails',
    (tester) async {
      final localStorage = FakeLocalStorageService();
      localStorage.seedString(
        CacheKeys.messagesConversationSnapshot,
        jsonEncode([
          {
            'id': '2',
            'name': '缓存用户',
            'lastMessage': '上次会话内容',
            'lastTime': '09:30',
            'unread': 3,
          },
        ]),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild((ref, notifier) =>
              _syntheticAuthorizedConversationAccess,
            ),
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.dev,
                appName: 'EliteSync',
                apiBaseUrl: 'http://localhost',
                useMockData: true,
                useMockChat: true,
              ),
            ),
            localStorageProvider.overrideWithValue(localStorage),
            conversationListProvider.overrideWith(
              (ref) async => const ConversationListUiState(
                items: [],
                error: 'refresh unavailable',
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 9),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: const ConversationListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('缓存用户'), findsNothing);
      expect(find.text('上次会话内容'), findsNothing);
      expect(find.text('当前无法更新 · 以下为上次内容'), findsNothing);
      expect(find.text('会话加载失败'), findsOneWidget);
      expect(find.text('待回复'), findsNothing);
      expect(find.text('3'), findsNothing);
      expect(find.text('通知 9'), findsNothing);
      expect(find.bySemanticsLabel('缓存用户，上次会话内容，仅供参考'), findsNothing);
      expect(localStorage.stringReads, isNot(contains(CacheKeys.messagesConversationSnapshot)));
      expect(localStorage.stringWrites, isNot(contains(CacheKeys.messagesConversationSnapshot)));
      expect(localStorage.removals, isNot(contains(CacheKeys.messagesConversationSnapshot)));
      expect(localStorage.storedString(CacheKeys.messagesConversationSnapshot), isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('legacy search history stays unread and current search stays local', (
    tester,
  ) async {
    final storage = FakeLocalStorageService();
    const oldHistory = '["OLD SECRET SEARCH"]';
    storage.seedString(CacheKeys.messagesSearchHistory, oldHistory);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          localStorageProvider.overrideWithValue(storage),
          conversationListProvider.overrideWith(
            (ref) async => const ConversationListUiState(items: [
              ConversationEntity(
                id: '2', name: '九紫瑶瑶', lastMessage: '你好',
                lastTime: '10:00', unread: 1,
              ),
              ConversationEntity(
                id: '3', name: '另一位用户', lastMessage: '再见',
                lastTime: '09:00', unread: 0,
              ),
            ]),
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ConversationListPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('OLD SECRET SEARCH'), findsNothing);
    expect(storage.stringReads, isNot(contains(CacheKeys.messagesSearchHistory)));

    await tester.enterText(find.byType(TextField), '九紫');
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();
    expect(find.text('九紫瑶瑶'), findsOneWidget);
    expect(find.text('另一位用户'), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('九紫'), findsOneWidget);
    expect(storage.storedString(CacheKeys.messagesSearchHistory), oldHistory);
    expect(storage.stringWrites, isNot(contains(CacheKeys.messagesSearchHistory)));
    expect(storage.removals, isNot(contains(CacheKeys.messagesSearchHistory)));
  });

  testWidgets('ConversationListPage removes redundant status shortcuts', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockChat: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          notificationUnreadCountProvider.overrideWith((ref) async => 81),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ConversationListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('会话说明'), findsNothing);
    expect(find.text('去匹配'), findsNothing);
    expect(find.text('通知中心'), findsNothing);
    expect(find.text('通知 81'), findsNothing);
    expect(find.textContaining('开场建议只进草稿'), findsNothing);
  });

  testWidgets('ConversationListPage explains empty confirmed-chat state', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockChat: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          conversationListProvider.overrideWith(
            (ref) async => const ConversationListUiState(items: []),
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ConversationListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('还没有可聊对象'), findsOneWidget);
    expect(find.text('暂无未读'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('未读'), findsNothing);
    expect(find.text('看未读'), findsNothing);
    expect(find.text('仅看未读'), findsNothing);
    expect(find.textContaining('互相确认慢约会后，对话会出现在这里'), findsOneWidget);
    expect(find.text('回到慢约会'), findsOneWidget);
  });

  testWidgets('transport failure without snapshot is never rendered as empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
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
          conversationListProvider.overrideWith(
            (ref) async =>
                const ConversationListUiState(error: 'transport unavailable'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ConversationListPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('会话加载失败'), findsOneWidget);
    expect(find.text('还没有可聊对象'), findsNothing);
    expect(find.text('回到慢约会'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('provider recovery replaces failure without app restart', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
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
          _conversationStateProvider.overrideWith(
            (ref) => const ConversationListUiState(error: 'offline'),
          ),
          conversationListProvider.overrideWith(
            (ref) async => ref.watch(_conversationStateProvider),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ConversationListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('会话加载失败'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationListPage)),
    );
    container
        .read(_conversationStateProvider.notifier)
        .state = const ConversationListUiState(
      items: [
        ConversationEntity(
          id: '12',
          name: '恢复后的会话',
          lastMessage: '服务器已恢复',
          lastTime: '11:00',
          unread: 0,
          entryKind: 'stored_conversation',
          conversationId: 34,
          peerUserId: 12,
          matchId: 56,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('会话加载失败'), findsNothing);
    expect(find.text('恢复后的会话'), findsOneWidget);
    expect(find.text('服务器已恢复'), findsOneWidget);
  });

  testWidgets('ConversationListPage explains filtered empty state', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockChat: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          conversationListProvider.overrideWith(
            (ref) async => const ConversationListUiState(
              items: [
                ConversationEntity(
                  id: '2',
                  name: '九紫瑶瑶',
                  lastMessage: '我们可以先慢慢聊',
                  lastTime: '10:00',
                  unread: 1,
                ),
                ConversationEntity(
                  id: '3',
                  name: '另一位用户',
                  lastMessage: '另一段真实会话',
                  lastTime: '09:00',
                  unread: 0,
                ),
              ],
            ),
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ConversationListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '不存在的关键词');
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();

    expect(find.text('没有符合当前筛选的会话'), findsOneWidget);
    expect(find.textContaining('查看本轮慢约会对话'), findsOneWidget);
    expect(find.text('清空筛选'), findsOneWidget);
  });

  testWidgets(
    'ConversationListPage keeps unread row cues compact and truthful',
    (tester) async {
      final localStorage = FakeLocalStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild((ref, notifier) =>
              _syntheticAuthorizedConversationAccess,
            ),
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.dev,
                appName: 'EliteSync',
                apiBaseUrl: 'http://localhost',
                useMockData: true,
                useMockChat: true,
              ),
            ),
            localStorageProvider.overrideWithValue(localStorage),
            conversationListProvider.overrideWith(
              (ref) async => const ConversationListUiState(
                items: [
                  ConversationEntity(
                    id: '2',
                    name: '九紫瑶瑶',
                    lastMessage: '你好，我们可以先慢慢聊',
                    lastTime: '10:00',
                    unread: 2,
                  ),
                ],
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: const ConversationListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('九紫瑶瑶'), findsOneWidget);
      expect(find.text('你好，我们可以先慢慢聊'), findsOneWidget);
      expect(find.text('慢约会'), findsWidgets);
      expect(find.text('2 条未读'), findsWidgets);
      expect(find.text('待回复'), findsNothing);
      expect(find.text('会话正常'), findsNothing);
      expect(find.text('2'), findsOneWidget);
    },
  );

  testWidgets(
    'ConversationListPage uses only unread truth when every row is read',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild((ref, notifier) =>
              _syntheticAuthorizedConversationAccess,
            ),
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
            conversationListProvider.overrideWith(
              (ref) async => const ConversationListUiState(
                items: [
                  ConversationEntity(
                    id: '2',
                    name: '九紫瑶瑶',
                    lastMessage: '你好，系统显示匹配后开始破冰',
                    lastTime: '10:00',
                    unread: 0,
                  ),
                ],
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: const ConversationListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('暂无未读'), findsWidgets);
      expect(find.text('未读'), findsNothing);
      expect(find.text('破冰中'), findsNothing);
      expect(find.text('新匹配'), findsNothing);
      expect(find.text('已开启聊天'), findsNothing);
    },
  );

  testWidgets(
    'saved unread tab normalizes to all before unread conversations return',
    (tester) async {
      final storage = FakeLocalStorageService();
      await storage.setInt(CacheKeys.messagesSelectedTab, 1);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild((ref, notifier) =>
              _syntheticAuthorizedConversationAccess,
            ),
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.dev,
                appName: 'EliteSync',
                apiBaseUrl: 'http://localhost',
                useMockData: true,
                useMockChat: true,
              ),
            ),
            localStorageProvider.overrideWithValue(storage),
            conversationListProvider.overrideWith(
              (ref) async => ref.watch(_conversationStateProvider),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: const ConversationListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('未读'), findsNothing);
      expect(await storage.getInt(CacheKeys.messagesSelectedTab), 0);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConversationListPage)),
      );
      container
          .read(_conversationStateProvider.notifier)
          .state = const ConversationListUiState(
        items: [
          ConversationEntity(
            id: 'unread',
            name: '未读会话',
            lastMessage: '新消息',
            lastTime: '10:00',
            unread: 1,
          ),
          ConversationEntity(
            id: 'read',
            name: '已读会话',
            lastMessage: '旧消息',
            lastTime: '09:00',
            unread: 0,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('未读'), findsOneWidget);
      expect(find.text('未读会话'), findsOneWidget);
      expect(find.text('已读会话'), findsOneWidget);
      expect(await storage.getInt(CacheKeys.messagesSelectedTab), 0);
    },
  );

  testWidgets(
    'single-state list hides filters until mixed unread truth exists',
    (tester) async {
      final storage = FakeLocalStorageService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild((ref, notifier) =>
              _syntheticAuthorizedConversationAccess,
            ),
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.dev,
                appName: 'EliteSync',
                apiBaseUrl: 'http://localhost',
                useMockData: true,
                useMockChat: true,
              ),
            ),
            localStorageProvider.overrideWithValue(storage),
            _conversationStateProvider.overrideWith(
              (ref) => const ConversationListUiState(
                items: [
                  ConversationEntity(
                    id: 'read',
                    name: '已读会话',
                    lastMessage: '旧消息',
                    lastTime: '09:00',
                    unread: 0,
                  ),
                ],
              ),
            ),
            conversationListProvider.overrideWith(
              (ref) async => ref.watch(_conversationStateProvider),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            home: const ConversationListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('已读'), findsNothing);
      expect(find.text('未读'), findsNothing);
      expect(await storage.getInt(CacheKeys.messagesSelectedTab), isNull);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConversationListPage)),
      );
      container
          .read(_conversationStateProvider.notifier)
          .state = const ConversationListUiState(
        items: [
          ConversationEntity(
            id: 'unread',
            name: '未读会话',
            lastMessage: '新消息',
            lastTime: '10:00',
            unread: 1,
          ),
          ConversationEntity(
            id: 'read',
            name: '已读会话',
            lastMessage: '旧消息',
            lastTime: '09:00',
            unread: 0,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('未读'), findsOneWidget);
      expect(find.text('未读会话'), findsOneWidget);
      expect(find.text('已读会话'), findsOneWidget);
      expect(await storage.getInt(CacheKeys.messagesSelectedTab), isNull);
    },
  );

  testWidgets(
    'ConversationListPage keeps redundant shortcuts absent on narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final localStorage = FakeLocalStorageService();
      final router = GoRouter(
        initialLocation: '/messages',
        routes: [
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationListPage(),
          ),
          GoRoute(
            path: '/match',
            builder: (context, state) => const Text('MATCH ROUTE'),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const Text('NOTIFICATION ROUTE'),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild((ref, notifier) =>
              _syntheticAuthorizedConversationAccess,
            ),
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.dev,
                appName: 'EliteSync',
                apiBaseUrl: 'http://localhost',
                useMockData: true,
                useMockChat: true,
              ),
            ),
            localStorageProvider.overrideWithValue(localStorage),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('会话说明'), findsNothing);
      expect(find.text('通知中心'), findsNothing);
      expect(find.text('MATCH ROUTE'), findsNothing);
    },
  );

  testWidgets('conversation list pushes canonical typed route state', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    Object? capturedExtra;
    String? capturedSegment;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ConversationListPage(),
        ),
        GoRoute(
          path: '${AppRouteNames.chatRoom}/:chatIdentity',
          builder: (context, state) {
            capturedExtra = state.extra;
            capturedSegment = state.pathParameters['chatIdentity'];
            return const Scaffold(body: Text('TYPED CHAT ROUTE'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockChat: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          conversationListProvider.overrideWith(
            (ref) async => const ConversationListUiState(
              items: [
                ConversationEntity(
                  id: 'legacy-peer-alias',
                  name: 'Typed Peer',
                  lastMessage: 'hello',
                  lastTime: 'now',
                  unread: 0,
                  entryKind: 'stored_conversation',
                  conversationId: 41,
                  peerUserId: 23,
                  matchId: 7,
                ),
              ],
            ),
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Typed Peer'));
    await tester.pumpAndSettle();

    expect(find.text('TYPED CHAT ROUTE'), findsOneWidget);
    expect(capturedSegment, 'conversation-41');
    expect(capturedExtra, isA<ChatRouteState>());
    final routeState = capturedExtra! as ChatRouteState;
    expect(routeState.entryKind, ChatEntryKind.storedConversation);
    expect(routeState.conversationId, 41);
    expect(routeState.peerUserId, 23);
  });

  for (final (caseName, entryKind, conversationId) in <(String, String?, int?)>[
    ('legacy kind with ID', 'legacy_peer', 41),
    ('eligible kind with ID', 'eligible_match', 41),
    ('unknown kind with ID', null, 41),
    ('stored kind missing ID', 'stored_conversation', null),
  ]) {
    testWidgets('conversation list rejects $caseName before Chat route', (
      tester,
    ) async {
      final itemName = 'Conflict $caseName';
      var chatRouteBuilt = false;
      Object? capturedExtra;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: ConversationListPage()),
          ),
          GoRoute(
            path: '${AppRouteNames.chatRoom}/:chatIdentity',
            builder: (context, state) {
              chatRouteBuilt = true;
              capturedExtra = state.extra;
              return const Scaffold(body: Text('RAW PRIVATE CHAT TARGET'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild(
              (ref, notifier) => _syntheticAuthorizedConversationAccess,
            ),
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
            conversationListProvider.overrideWith(
              (ref) async => ConversationListUiState(
                items: [
                  ConversationEntity(
                    id: 'legacy-peer-alias',
                    name: itemName,
                    lastMessage: 'Private preview stays on the source list',
                    lastTime: 'now',
                    unread: 0,
                    entryKind: entryKind,
                    conversationId: conversationId,
                    peerUserId: 23,
                    matchId: 7,
                  ),
                ],
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text(itemName));
      await tester.pumpAndSettle();

      expect(find.text('当前会话暂时无法打开，请刷新后重试'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(chatRouteBuilt, isFalse);
      expect(capturedExtra, isNull);
      expect(find.text('RAW PRIVATE CHAT TARGET'), findsNothing);
      expect(find.text(itemName), findsOneWidget);
    });
  }

  for (final peerUserId in <int?>[null, 0, -1]) {
    testWidgets('stored list row rejects unresolved peer $peerUserId', (
      tester,
    ) async {
      const itemName = 'Stored peer requires source binding';
      var chatRouteBuilt = false;
      Object? capturedExtra;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: ConversationListPage()),
          ),
          GoRoute(
            path: '${AppRouteNames.chatRoom}/:chatIdentity',
            builder: (context, state) {
              chatRouteBuilt = true;
              capturedExtra = state.extra;
              return const Scaffold(body: Text('RAW PRIVATE CHAT TARGET'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild(
              (ref, notifier) => _syntheticAuthorizedConversationAccess,
            ),
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
            conversationListProvider.overrideWith(
              (ref) async => ConversationListUiState(
                items: [
                  ConversationEntity(
                    id: '23',
                    name: itemName,
                    lastMessage: 'Private preview stays on the source list',
                    lastTime: 'now',
                    unread: 0,
                    entryKind: 'stored_conversation',
                    conversationId: 41,
                    peerUserId: peerUserId,
                  ),
                ],
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text(itemName));
      await tester.pumpAndSettle();

      expect(find.text('当前会话暂时无法打开，请刷新后重试'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(chatRouteBuilt, isFalse);
      expect(capturedExtra, isNull);
      expect(find.text('RAW PRIVATE CHAT TARGET'), findsNothing);
      expect(find.text(itemName), findsOneWidget);
    });
  }

  for (final (matchId, peerUserId) in <(int?, int?)>[
    (null, 23),
    (0, null),
    (-1, 23),
  ]) {
    testWidgets('eligible list row rejects invalid match ID $matchId', (
      tester,
    ) async {
      final itemName = 'Eligible match needs ID $matchId';
      var chatRouteBuilt = false;
      Object? capturedExtra;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: ConversationListPage()),
          ),
          GoRoute(
            path: '${AppRouteNames.chatRoom}/:chatIdentity',
            builder: (context, state) {
              chatRouteBuilt = true;
              capturedExtra = state.extra;
              return const Scaffold(body: Text('RAW PRIVATE CHAT TARGET'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationAccessProvider.overrideWithBuild(
              (ref, notifier) => _syntheticAuthorizedConversationAccess,
            ),
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
            conversationListProvider.overrideWith(
              (ref) async => ConversationListUiState(
                items: [
                  ConversationEntity(
                    id: '23',
                    name: itemName,
                    lastMessage: 'Private preview stays on the source list',
                    lastTime: 'now',
                    unread: 0,
                    entryKind: 'eligible_match',
                    peerUserId: peerUserId,
                    matchId: matchId,
                  ),
                ],
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text(itemName));
      await tester.pumpAndSettle();

      expect(find.text('当前会话暂时无法打开，请刷新后重试'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(chatRouteBuilt, isFalse);
      expect(capturedExtra, isNull);
      expect(find.text('RAW PRIVATE CHAT TARGET'), findsNothing);
      expect(find.text(itemName), findsOneWidget);
    });
  }

  testWidgets('conversation list refuses an invalid untyped identity', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
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
          conversationListProvider.overrideWith(
            (ref) async => const ConversationListUiState(
              items: [
                ConversationEntity(
                  id: 'not-a-peer',
                  name: '无效会话',
                  lastMessage: '不可进入',
                  lastTime: 'now',
                  unread: 0,
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ConversationListPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('无效会话'));
    await tester.pumpAndSettle();

    expect(find.text('当前会话暂时无法打开，请刷新后重试'), findsOneWidget);
    expect(find.text('无效会话'), findsOneWidget);
  });

  testWidgets('R5 disposable integrated conversation truth recovery smoke', (
    tester,
  ) async {
    final storage = FakeLocalStorageService();
    Object? capturedExtra;
    final router = GoRouter(
      initialLocation: '/messages',
      routes: [
        GoRoute(
          path: '/messages',
          builder: (context, state) => const ConversationListPage(),
        ),
        GoRoute(
          path: '${AppRouteNames.chatRoom}/:chatIdentity',
          builder: (context, state) {
            capturedExtra = state.extra;
            return const Scaffold(body: Text('DISPOSABLE CHAT'));
          },
        ),
        GoRoute(
          path: AppRouteNames.match,
          builder: (context, state) => const Text('CANONICAL MATCH'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationAccessProvider.overrideWithBuild((ref, notifier) =>
            _syntheticAuthorizedConversationAccess,
          ),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: false,
              useMockChat: false,
            ),
          ),
          localStorageProvider.overrideWithValue(storage),
          _conversationStateProvider.overrideWith(
            (ref) => const ConversationListUiState(items: []),
          ),
          conversationListProvider.overrideWith(
            (ref) async => ref.watch(_conversationStateProvider),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('还没有可聊对象'), findsOneWidget);
    expect(find.text('回到慢约会'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationListPage)),
    );
    container
        .read(_conversationStateProvider.notifier)
        .state = const ConversationListUiState(
      items: [
        ConversationEntity(
          id: '22',
          name: '可会话对象',
          lastMessage: '新的未读消息',
          lastTime: '12:00',
          unread: 1,
          entryKind: 'stored_conversation',
          conversationId: 44,
          peerUserId: 22,
          matchId: 66,
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('可会话对象'), findsOneWidget);
    expect(find.text('错误对象'), findsNothing);
    await tester.tap(find.text('可会话对象'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('DISPOSABLE CHAT'), findsOneWidget);
    final route = capturedExtra! as ChatRouteState;
    expect(route.conversationId, 44);
    expect(route.peerUserId, 22);
    expect(route.matchId, 66);

    router.pop();
    await tester.pumpAndSettle();
    container
        .read(_conversationStateProvider.notifier)
        .state = const ConversationListUiState(
      items: [
        ConversationEntity(
          id: '22',
          name: '可会话对象',
          lastMessage: '已读后的服务器事实',
          lastTime: '12:01',
          unread: 0,
          entryKind: 'stored_conversation',
          conversationId: 44,
          peerUserId: 22,
          matchId: 66,
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('已读后的服务器事实'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    container.read(_conversationStateProvider.notifier).state =
        const ConversationListUiState(error: 'temporary transport loss');
    await tester.pumpAndSettle();
    expect(find.text('会话加载失败'), findsOneWidget);
    expect(find.text('可会话对象'), findsNothing);
    expect(find.text('已读后的服务器事实'), findsNothing);
    capturedExtra = null;
    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/messages');
    expect(capturedExtra, isNull);
    expect(find.text('DISPOSABLE CHAT'), findsNothing);

    container
        .read(_conversationStateProvider.notifier)
        .state = const ConversationListUiState(
      items: [
        ConversationEntity(
          id: '22',
          name: '可会话对象',
          lastMessage: '恢复后的当前事实',
          lastTime: '12:02',
          unread: 0,
          entryKind: 'stored_conversation',
          conversationId: 44,
          peerUserId: 22,
          matchId: 66,
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('恢复后的当前事实'), findsOneWidget);
    expect(find.text('会话加载失败'), findsNothing);
    expect(find.text('错误对象'), findsNothing);
  });
}
