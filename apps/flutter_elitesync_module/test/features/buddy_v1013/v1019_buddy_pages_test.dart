import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/buddy_v1013/buddy_page.dart';
import 'package:flutter_elitesync_module/features/buddy_v1013/buddy_discovery_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-buddy-1',
    user: UserSummary(id: 1, phone: ''),
  );
}

class _Api extends RelationshipApi {
  _Api(this.handler) : super(ApiClient(dio: Dio()));
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

Future<void> _mount(WidgetTester tester, Widget child, _Api api) async {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        relationshipApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'discovery discards background late response and reloads on resume',
    (tester) async {
      final late = Completer<Map<String, dynamic>>();
      var reads = 0;
      final api = _Api((method, path, body) async {
        reads++;
        if (reads == 1) return late.future;
        return {'items': [], 'has_more': false};
      });
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_Session.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
          child: const MaterialApp(home: BuddyDiscoveryPage()),
        ),
      );
      await tester.pump();
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      late.complete({
        'items': [
          {'publication_id': 77, 'subject': 'STALE_PRIVATE_CARD'},
        ],
        'has_more': false,
      });
      await tester.pump();
      expect(find.textContaining('STALE_PRIVATE_CARD'), findsNothing);
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();
      expect(reads, 2);
      expect(find.textContaining('STALE_PRIVATE_CARD'), findsNothing);
    },
  );

  testWidgets('friend invitation selects authorized contact without ID input', (
    tester,
  ) async {
    Map<String, dynamic>? invitation;
    final api = _Api((method, path, body) async {
      if (path.startsWith('/social/contacts?')) {
        expect(Uri.parse(path).queryParameters['purpose'], 'buddy_invite');
        return {
          'items': [
            {
              'peer_id': 42,
              'label': '联系人甲',
              'allowed_actions': ['invite'],
            },
          ],
          'has_more': false,
        };
      }
      if (method == 'POST') {
        invitation = body;
        return {'id': 'a'};
      }
      return {
        'preferences': {'enabled': true, 'revision': 1},
        'activities': [
          {
            'id': 'a',
            'revision': 2,
            'state': 'OPEN',
            'type': 'STUDY',
            'subject': '阅读',
            'allowed_actions': ['invite'],
          },
        ],
      };
    });
    await _mount(tester, const BuddyPage(), api);
    expect(find.text('当前好友用户编号'), findsNothing);
    await tester.tap(find.byKey(const Key('buddy-a-invite')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('联系人甲'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();
    expect(invitation?['recipient_id'], 42);
    expect(invitation?['revision'], 2);
  });

  testWidgets('publication requires preview and explicit minimal label', (
    tester,
  ) async {
    Map<String, dynamic>? publication;
    final api = _Api((method, path, body) async {
      if (method == 'POST') {
        publication = body;
        expect(path, '/buddy/a/discovery');
        return {'id': 'a'};
      }
      return {
        'preferences': {'enabled': true, 'revision': 1},
        'activities': [
          {
            'id': 'a',
            'revision': 2,
            'state': 'OPEN',
            'type': 'STUDY',
            'subject': '阅读',
            'place_kind': 'ONLINE',
            'start_at': '2026-12-01T12:00:00Z',
            'end_at': '2026-12-01T13:00:00Z',
            'allowed_actions': [],
            'discovery_actions': ['publish'],
          },
        ],
      };
    });
    await _mount(tester, const BuddyPage(), api);
    await tester.tap(find.byKey(const Key('buddy-a-discovery-publish')));
    await tester.pumpAndSettle();
    expect(publication, isNull);
    expect(find.text('预览并发布到发现'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '小林',
    );
    await tester.tap(find.text('明确发布'));
    await tester.pumpAndSettle();
    expect(publication?['author_label'], '小林');
    expect(publication?['action'], 'publish');
  });

  testWidgets(
    'create retains draft and immutable command after lost response',
    (tester) async {
      final requests = <Map<String, dynamic>>[];
      final api = _Api((method, path, body) async {
        if (method == 'GET') {
          return {
            'preferences': {'enabled': true, 'revision': 1},
            'activities': [],
          };
        }
        requests.add(Map<String, dynamic>.from(body!));
        if (requests.length == 1) {
          throw const RelationshipFailure('response lost');
        }
        return {'id': 'new-activity'};
      });
      await _mount(tester, const BuddyPage(), api);
      await tester.tap(find.byKey(const Key('buddy-create-form')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('buddy-subject')), '一起学习');
      expect(
        find
            .byType(TextField)
            .evaluate()
            .any(
              (element) =>
                  (element.widget as TextField).decoration?.labelText?.contains(
                    'ISO',
                  ) ==
                  true,
            ),
        isFalse,
      );
      await tester.ensureVisible(find.byKey(const Key('buddy-create')));
      await tester.tap(find.byKey(const Key('buddy-create')));
      await tester.pumpAndSettle();
      expect(requests, hasLength(1));
      expect(find.text('一起学习'), findsOneWidget);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('buddy-create-form')));
      await tester.pumpAndSettle();
      expect(find.text('一起学习'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('buddy-retry-pending')));
      await tester.tap(find.byKey(const Key('buddy-retry-pending')));
      await tester.pumpAndSettle();
      expect(requests, hasLength(2));
      expect(requests[1], requests[0]);
      expect(DateTime.parse(requests[0]['start_at'] as String).isUtc, isTrue);
    },
  );

  testWidgets(
    'discovery pagination retains submitted city and application key',
    (tester) async {
      final paths = <String>[];
      final requests = <Map<String, dynamic>>[];
      final api = _Api((method, path, body) async {
        paths.add(path);
        if (method == 'POST') {
          requests.add(Map<String, dynamic>.from(body!));
          throw const RelationshipFailure('response lost');
        }
        return {
          'items': [
            {
              'publication_id': 9,
              'activity_id': 'a',
              'generation': 2,
              'revision': 4,
              'type': 'MEAL',
              'subject': '午餐',
              'author_label': '小林',
              'general_city': '线上',
              'place_kind': 'ONLINE',
              'start_at': '2026-12-01T12:00:00Z',
              'end_at': '2026-12-01T13:00:00Z',
              'expires_at': '2026-11-16T00:00:00Z',
            },
          ],
          'has_more': !path.contains('cursor='),
          'next_cursor': '9',
        };
      });
      await _mount(tester, const BuddyDiscoveryPage(), api);
      await tester.enterText(
        find.byKey(const Key('buddy-discovery-city')),
        '上海',
      );
      await tester.tap(find.byKey(const Key('buddy-discovery-more')));
      await tester.pumpAndSettle();
      expect(Uri.parse(paths.last).queryParameters['city'], '线上');
      await tester.tap(find.byKey(const Key('buddy-discovery-apply-9')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('buddy-discovery-retry')));
      await tester.pumpAndSettle();
      expect(requests, hasLength(2));
      expect(requests[0], requests[1]);
    },
  );
}
