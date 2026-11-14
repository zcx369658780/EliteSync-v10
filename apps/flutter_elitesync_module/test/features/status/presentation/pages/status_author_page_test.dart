import 'dart:async';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_author_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fixture'),
    accessToken: 'fixture',
  );
  void logout() =>
      state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
}

void main() {
  for (final entry in const {
    'showcase_not_published': '对方尚未发布展示资料。',
    'showcase_withdrawn': '对方已撤回展示资料。',
    'showcase_unavailable': '当前无法访问此资料，请确认双方的关系和展示范围。',
  }.entries) {
    testWidgets('author route distinguishes ${entry.key}', (tester) async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              if (request.path == '/api/v1/status/authors/42') {
                handler.resolve(
                  Response(
                    requestOptions: request,
                    data: {
                      'items': [],
                      'meta': {'has_more': false, 'next_cursor': null},
                    },
                  ),
                );
                return;
              }
              expect(request.path, '/api/v1/profile/showcase/42');
              handler.reject(
                DioException(
                  requestOptions: request,
                  response: Response(
                    requestOptions: request,
                    statusCode: 404,
                    data: {
                      'error': {'message': entry.key},
                    },
                  ),
                ),
              );
            },
          ),
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_Session.new),
            dioProvider.overrideWithValue(dio),
          ],
          child: const MaterialApp(home: StatusAuthorPage(userId: 42)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    });
  }
  testWidgets('only current server publication is shown', (tester) async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            if (request.path.startsWith('/api/v1/status/authors/')) {
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: {
                    'items': [],
                    'meta': {'has_more': false, 'next_cursor': null},
                  },
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {
                  'publication': {
                    'publication_status': 'published',
                    'public_fields': {'display_name': 'Approved display'},
                  },
                },
              ),
            );
          },
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          dioProvider.overrideWithValue(dio),
        ],
        child: const MaterialApp(home: StatusAuthorPage(userId: 42)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Approved display'), findsOneWidget);
  });
  testWidgets('logout clears details and discards late response', (
    tester,
  ) async {
    final response = Completer<void>();
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) async {
            await response.future;
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: request.path.startsWith('/api/v1/status/authors/')
                    ? {
                        'items': [_post(99, 'Old account post')],
                        'meta': {'has_more': false, 'next_cursor': null},
                      }
                    : {
                        'publication': {
                          'publication_status': 'published',
                          'public_fields': {'display_name': 'Old account data'},
                        },
                      },
              ),
            );
          },
        ),
      );
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        dioProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: StatusAuthorPage(userId: 42)),
      ),
    );
    await tester.pump();
    (container.read(sessionProvider.notifier) as _Session).logout();
    await tester.pump();
    response.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining('Old account data'), findsNothing);
    expect(find.text('Old account post'), findsNothing);
    expect(find.text('请登录后查看。'), findsOneWidget);
  });
  testWidgets(
    'Showcase denial preserves posts and uses scan cursor on empty pages',
    (tester) async {
      final cursors = <dynamic>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              if (request.path == '/api/v1/profile/showcase/42') {
                handler.reject(
                  DioException(
                    requestOptions: request,
                    response: Response(
                      requestOptions: request,
                      statusCode: 404,
                      data: {
                        'error': {'message': 'showcase_not_published'},
                      },
                    ),
                  ),
                );
                return;
              }
              expect(request.path, '/api/v1/status/authors/42');
              expect(request.queryParameters['limit'], 20);
              cursors.add(request.queryParameters['cursor']);
              final second = cursors.length == 2;
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: {
                    'items': second ? [_post(18, 'Visible author post')] : [],
                    'meta': {
                      'has_more': !second,
                      'next_cursor': second ? null : 23,
                    },
                  },
                ),
              );
            },
          ),
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_Session.new),
            dioProvider.overrideWithValue(dio),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const StatusAuthorPage(userId: 42),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('对方尚未发布展示资料。'), findsOneWidget);
      expect(find.text('暂无可查看的动态。'), findsNothing);
      await tester.tap(find.text('加载更多动态'));
      await tester.pumpAndSettle();
      expect(cursors, [null, 23]);
      expect(find.byType(StatusPostCard), findsOneWidget);
      expect(find.text('Visible author post'), findsOneWidget);
      expect(find.text('加载更多动态'), findsNothing);
    },
  );

  testWidgets('post failure leaves Showcase readable', (tester) async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            if (request.path.startsWith('/api/v1/status/authors/')) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  response: Response(requestOptions: request, statusCode: 403),
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'publication': {
                    'publication_status': 'published',
                    'public_fields': {'display_name': 'Readable Showcase'},
                  },
                },
              ),
            );
          },
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          dioProvider.overrideWithValue(dio),
        ],
        child: const MaterialApp(home: StatusAuthorPage(userId: 42)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Readable Showcase'), findsOneWidget);
    expect(find.text('当前无法查看此作者动态。'), findsOneWidget);
  });

  testWidgets('authority change clears both sections and rejects late page', (
    tester,
  ) async {
    final delayed = Completer<void>();
    var revoked = false;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) async {
            final posts = request.path.startsWith('/api/v1/status/authors/');
            final wasRevoked = revoked;
            if (posts && request.queryParameters['cursor'] != null) {
              await delayed.future;
            }
            handler.resolve(
              Response(
                requestOptions: request,
                data: posts
                    ? {
                        'items': wasRevoked
                            ? []
                            : [_post(31, 'Old visible post')],
                        'meta': {
                          'has_more': !wasRevoked,
                          'next_cursor': wasRevoked ? null : 21,
                        },
                      }
                    : {
                        'publication': {
                          'publication_status': 'published',
                          'public_fields': {
                            'display_name': wasRevoked
                                ? 'New projection'
                                : 'Old display',
                          },
                        },
                      },
              ),
            );
          },
        ),
      );
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        dioProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StatusAuthorPage(userId: 42),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StatusPostCard), findsOneWidget);
    await tester.ensureVisible(find.text('加载更多动态'));
    await tester.tap(find.text('加载更多动态'));
    await tester.pump();
    revoked = true;
    container.read(relationshipAuthorityEpochProvider.notifier).state++;
    await tester.pumpAndSettle();
    expect(find.byType(StatusPostCard), findsNothing);
    delayed.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining('Old display'), findsNothing);
    expect(find.text('Old visible post'), findsNothing);
    expect(find.textContaining('New projection'), findsOneWidget);
  });
}

Map<String, dynamic> _post(int id, String title) => {
  'id': id,
  'title': title,
  'body': 'A currently visible status',
  'author': {'id': 42, 'name': 'Author'},
  'audience': 'FRIENDS',
  'created_at': '2026-11-14T00:00:00Z',
};
