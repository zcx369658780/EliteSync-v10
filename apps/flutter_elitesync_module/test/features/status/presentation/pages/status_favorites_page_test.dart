import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_favorites_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Sessions extends SessionNotifier {
  @override
  SessionState build() => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'favorite-test',
    user: const UserSummary(id: 1, phone: ''),
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

Map<String, dynamic> _page(String body) => {
  'items': [
    {
      'post_id': 9,
      'available': true,
      'post': {
        'id': 9,
        'title': '收藏动态',
        'body': body,
        'author': {'id': 2, 'name': 'ES-2'},
        'favorited_by_viewer': true,
      },
    },
  ],
  'meta': {'has_more': false, 'next_cursor': null},
};

void main() {
  testWidgets(
    'background invalidates pending favorite bodies before foreground refresh',
    (tester) async {
      final stale = Completer<Map<String, dynamic>>();
      var reads = 0;
      final api = _Api((method, path, body) async {
        reads++;
        return reads == 1 ? stale.future : _page('CURRENT_FAVORITE_BODY');
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_Sessions.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
        child: MaterialApp(theme: AppTheme.light, home: const StatusFavoritesPage()),
        ),
      );
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      stale.complete(_page('STALE_FAVORITE_BODY'));
      await tester.pump();
      expect(find.textContaining('STALE_FAVORITE_BODY'), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('CURRENT_FAVORITE_BODY'), findsOneWidget);
      expect(find.textContaining('STALE_FAVORITE_BODY'), findsNothing);
    },
  );

  testWidgets(
    'unavailable favorite has only a tombstone and explicit false removal',
    (tester) async {
      final writes = <Map<String, dynamic>?>[];
      final api = _Api((method, path, body) async {
        if (method == 'PUT') {
          expect(path, '/status/posts/9/favorite');
          writes.add(body);
          return {'post_id': 9, 'favorited': false};
        }
        return {
          'items': writes.isEmpty
              ? [
                  {
                    'post_id': 9,
                    'available': false,
                    'post': null,
                    'saved_at': '2026-11-14',
                  },
                ]
              : [],
          'meta': {'has_more': false},
        };
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_Sessions.new),
            relationshipApiProvider.overrideWithValue(api),
          ],
        child: MaterialApp(theme: AppTheme.light, home: const StatusFavoritesPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('这条收藏当前不可用'), findsOneWidget);
      await tester.tap(find.text('取消收藏'));
      await tester.pumpAndSettle();
      expect(writes, [
        {'favorited': false},
      ]);
      expect(find.text('这条收藏当前不可用'), findsNothing);
    },
  );
}
