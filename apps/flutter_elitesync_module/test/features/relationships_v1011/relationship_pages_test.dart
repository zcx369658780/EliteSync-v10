import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_center_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/privacy_controls.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/peer_relationship_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState session(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'test-$id',
  user: UserSummary(id: id, phone: ''),
);

class TestSession extends SessionNotifier {
  @override
  Future<SessionState> build() async => session(1);
  void change(int id) => state = AsyncData(session(id));
}

class FakeApi extends RelationshipApi {
  FakeApi(this.handler) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>?,
  )
  handler;
  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) => handler(method, path, body);
}

void main() {
  testWidgets(
    'successful peer projection is cleared when authority refresh returns unavailable',
    (tester) async {
      var reads = 0;
      final api = FakeApi((method, path, body) async {
        if (path.startsWith('/profile-peers/')) {
          return {
            'profile': {'public_id': 'ES-PRIVATE-OLD'},
          };
        }
        if (++reads > 1) throw const RelationshipFailure('404 unavailable');
        return {
          'connection': {'state': 'CN_ACTIVE', 'id': 17, 'revision': 1},
          'consent': {'state': 'MC_ACTIVE', 'id': 18, 'revision': 1},
          'gates': {},
        };
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(TestSession.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
          child: const MaterialApp(home: PeerRelationshipPage(peerId: 2)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('读取当前可见资料'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ES-PRIVATE-OLD'), findsOneWidget);
      await tester.tap(find.byTooltip('刷新'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ES-PRIVATE-OLD'), findsNothing);
      expect(find.text('连接：双方已确认'), findsNothing);
      expect(find.textContaining('404 unavailable'), findsOneWidget);
    },
  );
  for (final terminal in ['MC_REVOKED', 'MC_DECLINED', 'MC_WITHDRAWN']) {
    testWidgets(
      '$terminal can request a new consent generation with both lifecycle ids',
      (tester) async {
        Map<String, dynamic>? sent;
        final api = FakeApi((method, path, body) async {
          if (method == 'POST') sent = body;
          return {
            'connection': {'id': 17, 'state': 'CN_ACTIVE', 'revision': 4},
            'consent': {
              'id': 29,
              'state': terminal,
              'revision': 6,
              'generation': 2,
            },
            'gates': {},
          };
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sessionProvider.overrideWith(TestSession.new),
              relationshipApiProvider.overrideWithValue(api),
            ],
            child: const MaterialApp(home: PeerRelationshipPage(peerId: 2)),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('重新申请消息同意'));
        await tester.pumpAndSettle();
        expect(sent?['action'], 'request');
        expect(sent?['expected_connection_id'], 17);
        expect(sent?['expected_consent_id'], 29);
        expect(sent?['expected_revision'], 6);
      },
    );
  }
  testWidgets(
    'accepted message participants can independently enter CN and MC for the correct peer',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final paths = <String>[];
      final api = FakeApi((method, path, body) async {
        paths.add(path);
        if (path == '/social') {
          return {
            'requests': [
              {
                'id': 21,
                'sender_id': 2,
                'recipient_id': 1,
                'purpose': 'message',
                'state': 'ACCEPTED',
              },
              {
                'id': 22,
                'sender_id': 1,
                'recipient_id': 3,
                'purpose': 'message',
                'state': 'ACCEPTED',
                'peer': {'public_id': 'ES-3'},
              },
              {
                'id': 23,
                'sender_id': 4,
                'recipient_id': 5,
                'purpose': 'message',
                'state': 'ACCEPTED',
              },
              {
                'id': 24,
                'sender_id': 6,
                'recipient_id': 1,
                'purpose': 'message',
                'state': 'PENDING',
              },
              {
                'id': 25,
                'sender_id': 7,
                'recipient_id': 1,
                'purpose': 'friendship',
                'state': 'ACCEPTED',
              },
            ],
          };
        }
        return {
          'connection': {'id': null, 'state': 'CN_NONE', 'revision': 0},
          'consent': {'state': 'MC_NONE', 'revision': 0},
          'gates': {},
        };
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(TestSession.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
          child: const MaterialApp(home: RelationshipCenterPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ES-2 · 消息请求'), findsOneWidget);
      expect(find.text('ES-3 · 消息请求'), findsOneWidget);
      expect(find.text('分别确认连接与消息同意'), findsNWidgets(2));
      expect(find.byKey(const ValueKey('message-consent-23')), findsNothing);
      expect(find.byKey(const ValueKey('message-consent-24')), findsNothing);
      expect(find.byKey(const ValueKey('message-consent-25')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('message-consent-21')));
      await tester.pumpAndSettle();
      expect(paths, contains('/connections/2'));
      expect(
        tester
            .widget<PeerRelationshipPage>(find.byType(PeerRelationshipPage))
            .peerId,
        2,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('message-consent-22')));
      await tester.pumpAndSettle();
      expect(paths, contains('/connections/3'));
      expect(
        tester
            .widget<PeerRelationshipPage>(find.byType(PeerRelationshipPage))
            .peerId,
        3,
      );
    },
  );
  testWidgets(
    'new connection lifecycle binds previous server id and revision',
    (tester) async {
      Map<String, dynamic>? sent;
      final api = FakeApi((method, path, body) async {
        if (method == 'POST') sent = body;
        return {
          'connection': {
            'id': 17,
            'state': 'CN_CLOSED',
            'revision': 4,
            'generation': 1,
          },
          'consent': {'state': 'MC_REVOKED', 'revision': 2},
          'gates': {},
        };
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(TestSession.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
          child: const MaterialApp(home: PeerRelationshipPage(peerId: 2)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('发起新的连接申请'));
      await tester.pumpAndSettle();
      expect(sent?['expected_connection_id'], 17);
      expect(sent?['expected_revision'], 4);
      expect(sent?['action'], 'request');
    },
  );
  testWidgets(
    'incoming request has recipient actions; rejected write stays pending',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final calls = <String>[];
      final api = FakeApi((method, path, body) async {
        calls.add('$method $path');
        if (method == 'POST') throw const RelationshipFailure('不可接受');
        return {
          'requests_enabled': false,
          'requests': [
            {
              'id': 8,
              'recipient_id': 1,
              'sender_id': 2,
              'state': 'PENDING',
              'purpose': 'friendship',
            },
          ],
        };
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(TestSession.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
          child: const MaterialApp(home: RelationshipCenterPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('接受'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('撤回'), findsNothing);
      await tester.tap(find.text('接受'));
      await tester.pumpAndSettle();
      expect(calls, contains('POST /social/requests/8/accept'));
      expect(find.textContaining('不可接受'), findsOneWidget);
      expect(find.text('接受'), findsOneWidget);
    },
  );
  testWidgets('late account A projection never appears after account B login', (
    tester,
  ) async {
    final old = Completer<Map<String, dynamic>>();
    var count = 0;
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(TestSession.new),
        relationshipApiProvider.overrideWithValue(
          FakeApi((m, p, b) async {
            if (++count == 1) return old.future;
            return {'requests_enabled': false, 'requests': []};
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RelationshipCenterPage()),
      ),
    );
    await tester.pump();
    await tester.pump();
    (container.read(sessionProvider.notifier) as TestSession).change(2);
    await tester.pumpAndSettle();
    old.complete({
      'requests_enabled': true,
      'requests': [
        {
          'id': 7,
          'peer': {'public_id': 'OLD_ACCOUNT_SECRET'},
          'state': 'PENDING',
        },
      ],
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('OLD_ACCOUNT_SECRET'), findsNothing);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });
  testWidgets('privacy saves server revision and explicit SELF withdrawal', (
    tester,
  ) async {
    Map<String, dynamic>? saved;
    final api = FakeApi((m, p, b) async {
      if (m == 'PUT') saved = b;
      return {
        'revision': 3,
        'fields': {
          'birthday': 'SELF',
          'interests': 'SELF',
          'resume': 'SELF',
          'zodiac': 'SELF',
        },
      };
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(TestSession.new),
          relationshipApiProvider.overrideWithValue(api),
        ],
        child: const MaterialApp(home: ServerPrivacyPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存受众 / 撤回分享意向'));
    await tester.pumpAndSettle();
    expect(saved?['expected_revision'], 3);
    expect((saved?['fields'] as Map)['birthday'], 'SELF');
  });
}
