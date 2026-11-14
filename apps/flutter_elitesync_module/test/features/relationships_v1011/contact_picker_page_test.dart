import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/contact_picker_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState _session(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'picker-test-$id',
  user: UserSummary(id: id, phone: ''),
);

class _TestSession extends SessionNotifier {
  @override
  SessionState build() => _session(1);
}

class _FakeApi extends RelationshipApi {
  _FakeApi(this.handler) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(String, String) handler;

  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) => handler(method, path);
}

void main() {
  testWidgets('filters authorized contacts and returns selected peer map', (
    tester,
  ) async {
    final paths = <String>[];
    final api = _FakeApi((method, path) async {
      paths.add(path);
      return {
        'items': [
          {
            'peer_id': 42,
            'label': '小林',
            'avatar': null,
            'allowed_actions': ['invite'],
          },
        ],
        'next_cursor': null,
        'has_more': false,
      };
    });
    Map<String, dynamic>? selected;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
          relationshipApiProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await Navigator.of(context)
                    .push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) =>
                            const ContactPickerPage(purpose: 'buddy_invite'),
                      ),
                    );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(paths.single, '/social/contacts?purpose=buddy_invite&limit=20');
    expect(find.text('小林'), findsOneWidget);
    await tester.tap(find.text('小林'));
    await tester.pumpAndSettle();
    expect(selected, {
      'peer_id': 42,
      'label': '小林',
      'allowed_actions': ['invite'],
    });
  });

  testWidgets('submits only name filter and uses server cursor for next page', (
    tester,
  ) async {
    final paths = <String>[];
    final api = _FakeApi((method, path) async {
      paths.add(path);
      if (path.contains('cursor=')) {
        return {
          'items': [
            {
              'peer_id': 2,
              'label': '乙',
              'allowed_actions': ['request'],
            },
          ],
          'next_cursor': null,
          'has_more': false,
        };
      }
      return {
        'items': [
          {
            'peer_id': 1,
            'label': '甲',
            'allowed_actions': ['request'],
          },
        ],
        'next_cursor': 'peer-1',
        'has_more': true,
      };
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
          relationshipApiProvider.overrideWithValue(api),
        ],
        child: const MaterialApp(
          home: ContactPickerPage(purpose: 'friend_request'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contact-picker-query')),
      'Ada',
    );
    await tester.tap(find.byKey(const Key('contact-picker-search')));
    await tester.pumpAndSettle();
    expect(
      paths.last,
      '/social/contacts?purpose=friend_request&limit=20&query=Ada',
    );
    await tester.tap(find.byKey(const Key('contact-picker-load-more')));
    await tester.pumpAndSettle();
    expect(paths.last, contains('cursor=peer-1'));
    expect(find.text('乙'), findsOneWidget);
  });

  testWidgets('unsubmitted filter draft does not alter pagination query', (
    tester,
  ) async {
    final paths = <String>[];
    final api = _FakeApi((method, path) async {
      paths.add(path);
      return {
        'items': [
          {
            'peer_id': paths.length,
            'label': '联系人 ${paths.length}',
            'allowed_actions': ['invite'],
          },
        ],
        'next_cursor': paths.length == 1 ? 'peer-1' : null,
        'has_more': paths.length == 1,
      };
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
          relationshipApiProvider.overrideWithValue(api),
        ],
        child: const MaterialApp(
          home: ContactPickerPage(purpose: 'buddy_invite'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contact-picker-query')),
      'draft',
    );
    await tester.tap(find.byKey(const Key('contact-picker-load-more')));
    await tester.pumpAndSettle();
    expect(paths[1], contains('cursor=peer-1'));
    expect(paths[1], isNot(contains('query=')));
  });

  testWidgets(
    'invalid purpose makes no request and exposes no selectable rows',
    (tester) async {
      var calls = 0;
      final api = _FakeApi((method, path) async {
        calls++;
        return {
          'items': [
            {
              'peer_id': 42,
              'label': '不应显示',
              'allowed_actions': ['request'],
            },
          ],
        };
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_TestSession.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
          child: const MaterialApp(
            home: ContactPickerPage(purpose: 'unsupported'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.textContaining('用途无效'), findsOneWidget);
      expect(find.text('不应显示'), findsNothing);
    },
  );
}
