import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _CompletedFirstUseStorage extends LocalStorageService {
  @override
  Future<String?> getString(String key) async =>
      key == CacheKeys.firstUseOnboardingV1Status ? 'completed' : null;

  @override
  Future<bool?> getBool(String key) async =>
      key == CacheKeys.performanceLiteMode ? true : null;

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;
}

const _available = ConversationAccessSnapshot.syntheticDevelopment(
  ProductConversationState.active,
);
const _unavailable = ConversationAccessSnapshot.notYetEstablished();

ConversationEntity _detail({
  String? entryKind = 'stored_conversation',
  int? id = 41,
}) => ConversationEntity(
  id: 'legacy-peer-alias',
  name: 'RAW PRIVATE PEER NAME',
  lastMessage: 'RAW PRIVATE MESSAGE',
  lastTime: '',
  unread: 0,
  entryKind: entryKind,
  conversationId: id,
  peerUserId: 23,
);

Widget _app({
  required ConversationAccessSnapshot access,
  required Future<ConversationEntity> Function(int) resolve,
  void Function(GoRouter)? onRouter,
}) {
  const navigation = NavigationSnapshot(
    authStatus: AuthStatus.authenticated,
    verificationStatus: VerificationStatus.unknown,
    questionnaireStatus: QuestionnaireStatus.unknown,
    matchStatus: MatchStatus.unknown,
    canChat: false,
    readinessState: ReadinessGuardState.unknown,
    isBootstrapLoading: false,
  );
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Synthetic Chat direct route binding',
          apiBaseUrl: 'http://127.0.0.1:9/',
          useMockData: true,
          useMockChat: true,
          initialRoute: '${AppRouteNames.chatRoom}/conversation-41',
        ),
      ),
      authStatusProvider.overrideWithValue(AuthStatus.authenticated),
      navigationGuardProvider.overrideWithValue(navigation),
      localStorageProvider.overrideWithValue(_CompletedFirstUseStorage()),
      conversationAccessProvider.overrideWithBuild((ref, notifier) => access),
      conversationDetailProvider.overrideWith(
        (ref, conversationId) => resolve(conversationId),
      ),
    ],
    child: Consumer(
      builder: (context, ref, child) {
        final router = ref.watch(appRouterProvider);
        onRouter?.call(router);
        return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
      },
    ),
  );
}

Future<void> _showDirectRoute(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  for (final (caseName, segment, typedState)
      in <(String, String, ChatRouteState)>[
        (
          'stored typed state with numeric legacy path',
          '23',
          ChatRouteState.stored(
            conversationId: 41,
            peerUserId: 23,
            title: 'Stored',
          ),
        ),
        (
          'eligible typed state with numeric legacy path',
          '23',
          ChatRouteState.eligibleMatch(
            peerUserId: 23,
            matchId: 7,
            title: 'Eligible',
          ),
        ),
        (
          'stored typed state with different stored URL',
          'conversation-42',
          ChatRouteState.stored(
            conversationId: 41,
            peerUserId: 23,
            title: 'Stored',
          ),
        ),
      ]) {
    testWidgets('typed Chat mismatch rejects $caseName without detail lookup', (
      tester,
    ) async {
      final requested = <int>[];
      GoRouter? router;
      await _showDirectRoute(
        tester,
        _app(
          access: _available,
          resolve: (id) async {
            requested.add(id);
            return _detail();
          },
          onRouter: (value) => router = value,
        ),
      );
      expect(requested, [41]);

      router!.go('${AppRouteNames.chatRoom}/$segment', extra: typedState);
      await tester.pumpAndSettle();

      expect(find.text('当前会话地址无效，请返回消息列表重新选择'), findsOneWidget);
      expect(find.byType(ChatRoomPage), findsNothing);
      expect(find.textContaining('RAW PRIVATE'), findsNothing);
      expect(requested, [41]);
    });
  }

  testWidgets('matching stored detail opens the local Chat room', (
    tester,
  ) async {
    final requested = <int>[];
    await _showDirectRoute(
      tester,
      _app(
        access: _available,
        resolve: (id) async {
          requested.add(id);
          return _detail();
        },
      ),
    );

    expect(requested, [41]);
    final room = tester.widget<ChatRoomPage>(find.byType(ChatRoomPage));
    expect(room.routeState.entryKind, ChatEntryKind.storedConversation);
    expect(room.routeState.conversationId, 41);
    expect(room.routeState.peerUserId, 23);
    expect(find.text('暂时无法打开这段会话，请稍后重试'), findsNothing);
  });

  for (final (caseName, kind, id) in <(String, String?, int?)>[
    ('missing ID', 'stored_conversation', null),
    ('different ID', 'stored_conversation', 42),
    ('legacy kind', 'legacy_peer', 41),
    ('eligible kind', 'eligible_match', 41),
    ('unknown kind', null, 41),
  ]) {
    testWidgets('direct stored route rejects $caseName', (tester) async {
      final requested = <int>[];
      await _showDirectRoute(
        tester,
        _app(
          access: _available,
          resolve: (conversationId) async {
            requested.add(conversationId);
            return _detail(entryKind: kind, id: id);
          },
        ),
      );

      expect(requested, [41]);
      expect(find.text('暂时无法打开这段会话，请稍后重试'), findsOneWidget);
      expect(find.byType(ChatRoomPage), findsNothing);
      expect(find.textContaining('RAW PRIVATE'), findsNothing);
    });
  }

  testWidgets('detail resolution failure stays on the safe page', (
    tester,
  ) async {
    var requested = 0;
    await _showDirectRoute(
      tester,
      _app(
        access: _available,
        resolve: (id) async {
          requested++;
          throw StateError('RAW PRIVATE FAILURE');
        },
      ),
    );

    expect(requested, 1);
    expect(find.text('暂时无法打开这段会话，请稍后重试'), findsOneWidget);
    expect(find.byType(ChatRoomPage), findsNothing);
    expect(find.textContaining('RAW PRIVATE'), findsNothing);
  });

  testWidgets('unestablished access does not request detail', (tester) async {
    var requested = 0;
    await _showDirectRoute(
      tester,
      _app(
        access: _unavailable,
        resolve: (id) async {
          requested++;
          return _detail();
        },
      ),
    );

    expect(requested, 0);
    expect(find.text('消息权限尚未建立'), findsOneWidget);
    expect(find.byType(ChatRoomPage), findsNothing);
    expect(find.textContaining('RAW PRIVATE'), findsNothing);
  });
}
