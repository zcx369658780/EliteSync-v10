import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState _session(String token) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: token,
  user: const UserSummary(id: 1, phone: ''),
);

class _Sessions extends SessionNotifier {
  @override
  SessionState build() => _session('first');
  void change() => state = AsyncData(_session('second'));
}

class _Api extends RelationshipApi {
  _Api(this.handler) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) handler;
  final writes = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) {
    expect(method, 'PUT');
    expect(path, '/status/posts/9/favorite');
    writes.add(Map.of(body!));
    return handler(body);
  }
}

Future<ProviderContainer> _mount(
  WidgetTester tester,
  _Api api, {
  bool Function()? saved,
}) async {
  tester.view.physicalSize = const Size(1000, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: base64Decode(
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
              ),
            ),
          );
        },
      ),
    );
  final c = ProviderContainer(
    overrides: [
      sessionProvider.overrideWith(_Sessions.new),
      relationshipApiProvider.overrideWithValue(api),
      dioProvider.overrideWithValue(dio),
      profileProvider.overrideWith((ref) async => const ProfileUiState()),
      statusPostPageProvider.overrideWith((ref) async {
        final token = ref.watch(sessionProvider).asData?.value.accessToken;
        final epoch = ref.watch(relationshipAuthorityEpochProvider);
        final current = token == 'second' || epoch != 0;
        return StatusPostPage(
          items: [
            StatusPostEntity.fromJson({
              'id': current ? 10 : 9,
              'title': current ? 'NEW_TITLE' : 'OLD_TITLE',
              'body': current ? 'NEW_BODY' : 'OLD_BODY',
              'audience': 'FRIENDS',
              'author': {'id': 2, 'name': 'ES-2'},
              'cover_media_asset_id': 9001,
              'favorited_by_viewer': saved?.call() ?? false,
            }),
          ],
        );
      }),
    ],
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(theme: AppTheme.light, home: const StatusSquarePage()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('收藏'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  expect(find.text('OLD_BODY'), findsOneWidget);
  expect(find.byType(AuthenticatedStatusImage), findsOneWidget);
  return c;
}

void main() {
  testWidgets(
    'displayed post favorite404 removes body image and old actions without clearing draft',
    (tester) async {
      final api = _Api(
        (_) async =>
            throw const RelationshipFailure('unavailable', statusCode: 404),
      );
      await _mount(tester, api);
      await tester.enterText(find.byType(TextField).at(0), 'LEGAL_DRAFT_TITLE');
      await tester.enterText(find.byType(TextField).at(1), 'LEGAL_DRAFT_BODY');
      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();
      expect(find.text('OLD_BODY'), findsNothing);
      expect(find.byType(AuthenticatedStatusImage), findsNothing);
      expect(find.byType(StatusPostCard), findsNothing);
      expect(find.text('收藏'), findsNothing);
      expect(find.text('低压私聊'), findsNothing);
      expect(find.textContaining('当前动态已不可用'), findsWidgets);
      expect(find.textContaining('收藏状态未确认'), findsNothing);
      expect(find.text('LEGAL_DRAFT_TITLE'), findsOneWidget);
      expect(find.text('LEGAL_DRAFT_BODY'), findsOneWidget);
    },
  );

  for (final code in <int?>[null, 503]) {
    testWidgets(
      'favorite $code unknown result retains content draft and immutable set request',
      (tester) async {
        var saved = false;
        var attempts = 0;
        final api = _Api((_) async {
          if (++attempts == 1) {
            throw RelationshipFailure('temporary failure', statusCode: code);
          }
          saved = true;
          return {'favorited': true};
        });
        await _mount(tester, api, saved: () => saved);
        await tester.enterText(find.byType(TextField).at(0), 'LEGAL_DRAFT');
        await tester.tap(find.text('收藏'));
        await tester.pumpAndSettle();
        expect(find.text('OLD_BODY'), findsOneWidget);
        expect(find.byType(AuthenticatedStatusImage), findsOneWidget);
        expect(find.text('LEGAL_DRAFT'), findsOneWidget);
        expect(find.textContaining('收藏状态未确认'), findsOneWidget);
        await tester.tap(find.text('收藏'));
        await tester.pumpAndSettle();
        expect(api.writes, [
          {'favorited': true},
          {'favorited': true},
        ]);
        expect(find.text('取消收藏'), findsOneWidget);
      },
    );
  }

  for (final account in [true, false]) {
    testWidgets(
      'late favorite404 from old ${account ? 'account' : 'authority'} cannot clear current page',
      (tester) async {
        final pending = Completer<Map<String, dynamic>>();
        final api = _Api((_) => pending.future);
        final c = await _mount(tester, api);
        await tester.tap(find.text('收藏'));
        await tester.pump();
        if (account) {
          (c.read(sessionProvider.notifier) as _Sessions).change();
        } else {
          c.read(relationshipAuthorityEpochProvider.notifier).invalidate();
        }
        await tester.pumpAndSettle();
        expect(find.text('NEW_BODY'), findsOneWidget);
        pending.completeError(
          const RelationshipFailure('unavailable', statusCode: 404),
        );
        await tester.pumpAndSettle();
        expect(find.text('NEW_BODY'), findsOneWidget);
        expect(find.text('OLD_BODY'), findsNothing);
        expect(find.textContaining('当前动态已不可用'), findsNothing);
      },
    );
  }
}
