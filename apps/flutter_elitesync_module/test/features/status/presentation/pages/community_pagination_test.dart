import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState session(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'synthetic-$id',
  user: UserSummary(id: id, phone: ''),
);

class Sessions extends SessionNotifier {
  @override
  Future<SessionState> build() async => session(1);
  void change() => state = AsyncData(session(2));
}

Map<String, dynamic> page(int id, {String? next}) => {
  'items': [
    {
      'id': id,
      'title': 'page-$id',
      'body': 'body-$id',
      'audience': 'FRIENDS',
      'author': {'id': 2, 'name': 'Synthetic'},
    },
  ],
  'meta': {'has_more': next != null, 'next_cursor': next},
};

class Api extends ApiClient {
  Api(this.handle) : super(dio: Dio());
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) handle;
  final queries = <Map<String, dynamic>>[];
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/status/posts');
    queries.add(Map.of(query ?? {}));
    return NetworkSuccess(await handle(query ?? {}));
  }
}

ProviderContainer containerFor(Api api) => ProviderContainer(
  overrides: [
    sessionProvider.overrideWith(Sessions.new),
    statusRemoteDataSourceProvider.overrideWith(
      (ref) => StatusRemoteDataSource(
        apiClient: api,
        useMock: false,
        identity: () =>
            '${ref.read(sessionProvider).asData?.value.accessToken}:${ref.read(relationshipAuthorityEpochProvider)}',
      ),
    ),
  ],
);
void main() {
  test(
    'nonzero cursor reaches request and replaces the bounded page',
    () async {
      final api = Api(
        (q) async => page(
          q['cursor'] == null ? 1 : 21,
          next: q['cursor'] == null ? '20' : null,
        ),
      );
      final c = containerFor(api);
      addTearDown(c.dispose);
      c.listen(statusPostPageProvider, (_, __) {});
      await c.read(sessionProvider.future);
      expect((await c.read(statusPostPageProvider.future)).items.single.id, 1);
      c.read(statusPageCursorProvider.notifier).nextPage('20');
      expect(
        (await c.read(statusPostPageProvider.future)).items.map((p) => p.id),
        [21],
      );
      expect(api.queries.last, {'limit': 20, 'cursor': '20'});
    },
  );
  for (final changeAccount in [true, false]) {
    test(
      '${changeAccount ? 'account' : 'authority'} change resets cursor and discards late old page',
      () async {
        final late = Completer<Map<String, dynamic>>();
        final started = Completer<void>();
        final api = Api((q) async {
          if (q['cursor'] != null) {
            started.complete();
            return late.future;
          }
          return page(1, next: '20');
        });
        final c = containerFor(api);
        addTearDown(c.dispose);
        c.listen(statusPostPageProvider, (_, __) {});
        await c.read(sessionProvider.future);
        await c.read(statusPostPageProvider.future);
        c.read(statusPageCursorProvider.notifier).nextPage('20');
        final old = c.read(statusPostPageProvider.future);
        final replaced = expectLater(
          old.then((page) => page.items.single.id),
          completion(1),
        );
        await started.future;
        if (changeAccount) {
          (c.read(sessionProvider.notifier) as Sessions).change();
        } else {
          c.read(relationshipAuthorityEpochProvider.notifier).invalidate();
        }
        expect(
          (await c.read(statusPostPageProvider.future)).items.single.id,
          1,
        );
        expect(c.read(statusPageCursorProvider), isNull);
        expect(api.queries.last.containsKey('cursor'), isFalse);
        late.complete(page(99));
        await replaced;
        expect(c.read(statusPostPageProvider).requireValue.items.single.id, 1);
      },
    );
  }
  test('data source rejects old account or authority response', () async {
    for (final updatedIdentity in ['account-2:0', 'account-1:1']) {
      var identity = 'account-1:0';
      final response = Completer<Map<String, dynamic>>();
      final started = Completer<void>();
      final api = Api((_) {
        started.complete();
        return response.future;
      });
      final source = StatusRemoteDataSource(
        apiClient: api,
        useMock: false,
        identity: () => identity,
      );
      final result = source.fetchStatusPage(cursor: '20');
      final rejected = expectLater(result, throwsStateError);
      await started.future;
      identity = updatedIdentity;
      response.complete(page(99));
      await rejected;
    }
  });
  test(
    'invalid cursor rejected and nonadvancing server cursor cannot loop',
    () async {
      final api = Api((_) async => page(21, next: '20'));
      final ds = StatusRemoteDataSource(apiClient: api, useMock: false);
      await expectLater(ds.fetchStatusPage(cursor: '-1'), throwsArgumentError);
      final result = await ds.fetchStatusPage(cursor: '20');
      expect(result.hasMore, isFalse);
      expect(result.nextCursor, isNull);
    },
  );
  for (final changeAccount in [true, false]) {
    testWidgets(
      '${changeAccount ? 'account' : 'authority'} change removes visible old page while new request waits',
      (tester) async {
        tester.view.physicalSize = const Size(900, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pending = Completer<Map<String, dynamic>>();
        var requests = 0;
        final api = Api(
          (_) async => ++requests == 1 ? page(1) : pending.future,
        );
        final c = containerFor(api);
        addTearDown(c.dispose);
        await c.read(sessionProvider.future);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: ProviderScope(
              overrides: [
                profileProvider.overrideWith(
                  (ref) async => const ProfileUiState(),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.light,
                home: const StatusSquarePage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('page-1'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('page-1'), findsOneWidget);
        if (changeAccount) {
          (c.read(sessionProvider.notifier) as Sessions).change();
        } else {
          c.read(relationshipAuthorityEpochProvider.notifier).invalidate();
        }
        await tester.pump();
        expect(find.text('page-1'), findsNothing);
        pending.complete(page(2));
        await tester.pumpAndSettle();
        expect(find.text('page-1'), findsNothing);
        expect(find.text('page-2'), findsOneWidget);
      },
    );
  }
  testWidgets(
    'explicit next page replaces content and empty page returns home',
    (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = Api(
        (q) async => q['cursor'] == null
            ? page(1, next: '20')
            : {
                'items': [],
                'meta': {'has_more': false},
              },
      );
      final c = containerFor(api);
      addTearDown(c.dispose);
      await c.read(sessionProvider.future);
      final router = GoRouter(
        initialLocation: '/community',
        routes: [
          GoRoute(
            path: '/community',
            builder: (_, __) => const StatusSquarePage(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('HOME')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: ProviderScope(
            overrides: [
              profileProvider.overrideWith(
                (ref) async => const ProfileUiState(),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final next = find.byKey(const Key('community-next-page'));
      await tester.scrollUntilVisible(
        next,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(api.queries.last['cursor'], '20');
      expect(find.text('page-1'), findsNothing);
      await tester.ensureVisible(find.text('返回首页'));
      await tester.tap(find.text('返回首页'));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    },
  );
}
