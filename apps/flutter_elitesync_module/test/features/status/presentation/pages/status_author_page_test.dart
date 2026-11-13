import 'dart:async';
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
                data: {
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
    expect(find.text('请登录后查看。'), findsOneWidget);
  });
}
