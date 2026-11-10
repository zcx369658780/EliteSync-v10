import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/conversation_list_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_list_ui_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-only',
    user: UserSummary(id: 1, phone: 'synthetic'),
  );
}

final _remote = StateProvider<ConversationListUiState>(
  (ref) => const ConversationListUiState(
    items: [
      ConversationEntity(
        id: '1',
        name: '虚构对象',
        lastMessage: '合成已保存内容',
        lastTime: '12:00',
        unread: 1,
        entryKind: 'stored_conversation',
        conversationId: 1,
        peerUserId: 2,
      ),
    ],
  ),
);

void main() {
  testWidgets(
    'online success is hidden after clock rollback and cannot be restored by a mere retry',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final secure = _Secure();
      final now = DateTime.utc(2026, 10, 21);
      var wallOffset = Duration.zero;
      final cache = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now.add(wallOffset),
        elapsed: () => Duration.zero,
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          sessionProvider.overrideWith(_Session.new),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
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
          conversationListProvider.overrideWith(
            (ref) async => ref.watch(_remote),
          ),
        ],
      );
      await container.read(sessionProvider.future);
      final receipt = {
        'user_id': 1,
        'device_id': 'synthetic',
        'session_id': 1,
        'login_at': now.toIso8601String(),
        'server_now': now.toIso8601String(),
        'online_expires_at': now
            .add(const Duration(days: 15))
            .toIso8601String(),
        'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
      };
      await cache.establishLogin(userId: 1, retention: receipt);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: ConversationListPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('虚构对象'), findsOneWidget);
      expect(find.text('合成已保存内容'), findsOneWidget);
      wallOffset = const Duration(minutes: -2);
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();
      expect(find.text('虚构对象'), findsNothing);
      expect(find.text('合成已保存内容'), findsNothing);
      expect(find.text('私有缓存已锁定'), findsOneWidget);
      await tester.tap(find.text('在线重新核验'));
      await tester.pumpAndSettle();
      expect(find.text('虚构对象'), findsNothing);
      expect(find.text('合成已保存内容'), findsNothing);
      // Only a new trusted successful login can establish a fresh clock anchor.
      wallOffset = Duration.zero;
      await cache.establishLogin(
        userId: 1,
        retention: {...receipt, 'session_id': 2},
      );
      container.invalidate(conversationListProvider);
      await tester.pumpAndSettle();
      expect(find.text('合成已保存内容'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    },
  );
  testWidgets(
    'encrypted list survives same-process offline only, reconnect hides before current read, 30 days actually purges',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final secure = _Secure();
      final now = DateTime.utc(2026, 10, 21);
      var elapsed = Duration.zero;
      final cache = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now.add(elapsed),
        elapsed: () => elapsed,
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          sessionProvider.overrideWith(_Session.new),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
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
          conversationListProvider.overrideWith(
            (ref) async => ref.watch(_remote),
          ),
        ],
      );
      await container.read(sessionProvider.future);
      await cache.establishLogin(
        userId: 1,
        retention: {
          'user_id': 1,
          'device_id': 'synthetic',
          'session_id': 1,
          'login_at': now.toIso8601String(),
          'server_now': now.toIso8601String(),
          'online_expires_at': now
              .add(const Duration(days: 15))
              .toIso8601String(),
          'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
        },
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: ConversationListPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('合成已保存内容'), findsOneWidget);
      expect(
        secure.values.keys.any((key) => key.endsWith(':conversation-list')),
        isTrue,
      );
      elapsed = const Duration(days: 15);
      container.read(_remote.notifier).state = const ConversationListUiState(
        error: 'NETWORK_UNAVAILABLE',
      );
      await tester.pumpAndSettle();
      expect(find.text('离线只读'), findsOneWidget);
      expect(find.text('合成已保存内容'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('联网重新核验'));
      await tester.pumpAndSettle();
      expect(find.text('合成已保存内容'), findsNothing);
      expect(find.text('离线只读'), findsNothing);
      // Establish a new online login to grant another explicitly current-read copy.
      elapsed = Duration.zero;
      await cache.establishLogin(
        userId: 1,
        retention: {
          'user_id': 1,
          'device_id': 'synthetic',
          'session_id': 2,
          'login_at': now.toIso8601String(),
          'server_now': now.toIso8601String(),
          'online_expires_at': now
              .add(const Duration(days: 15))
              .toIso8601String(),
          'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
        },
      );
      container.read(_remote.notifier).state = const ConversationListUiState(
        items: [
          ConversationEntity(
            id: '1',
            name: '虚构对象',
            lastMessage: '重新核验的内容',
            lastTime: '12:01',
            unread: 0,
          ),
        ],
      );
      await tester.pumpAndSettle();
      elapsed = const Duration(days: 30);
      container.read(_remote.notifier).state = const ConversationListUiState(
        error: 'NETWORK_UNAVAILABLE',
      );
      await tester.pumpAndSettle();
      expect(find.text('重新核验的内容'), findsNothing);
      expect(find.text('私有缓存已到期并完成清理，请在线登录。'), findsOneWidget);
      expect(secure.values, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    },
  );
  testWidgets(
    'online list hides already rendered summaries at the exact 15-day boundary',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final secure = _Secure();
      final now = DateTime.utc(2026, 10, 21);
      var wallOffset = Duration.zero;
      final cache = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now.add(wallOffset),
        elapsed: () => wallOffset,
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          sessionProvider.overrideWith(_Session.new),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
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
          conversationListProvider.overrideWith(
            (ref) async => ref.watch(_remote),
          ),
        ],
      );
      await container.read(sessionProvider.future);
      final receipt = {
        'user_id': 1,
        'device_id': 'synthetic',
        'session_id': 1,
        'login_at': now.toIso8601String(),
        'server_now': now.toIso8601String(),
        'online_expires_at': now
            .add(const Duration(days: 15))
            .toIso8601String(),
        'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
      };
      await cache.establishLogin(userId: 1, retention: receipt);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: ConversationListPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('虚构对象'), findsOneWidget);
      expect(find.text('合成已保存内容'), findsOneWidget);
      wallOffset = const Duration(days: 15);
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();
      expect(find.text('合成已保存内容'), findsNothing);
      expect(find.text('虚构对象'), findsNothing);
      expect(find.text('私有缓存已锁定'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    },
  );
}
