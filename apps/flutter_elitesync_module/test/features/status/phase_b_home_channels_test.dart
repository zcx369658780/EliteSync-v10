import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/home/presentation/widgets/home_content_channels.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 2, phone: ''),
    accessToken: 'synthetic-session',
  );
}

Dio _fixtureTransport(Map<String, dynamic> Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, flow) {
        flow.resolve(
          Response(
            requestOptions: request,
            statusCode: 200,
            data: handler(request),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  testWidgets('visitor editorial renders only official title and body', (
    tester,
  ) async {
    final dio = _fixtureTransport((request) {
      expect(request.path, '/api/v1/home/editorial');
      return {
        'items': [
          {'id': 'fixture', 'title': '获准专题', 'body': '获准正文'},
        ],
      };
    });
    addTearDown(dio.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statusRemoteDataSourceProvider.overrideWithValue(
            StatusRemoteDataSource(
              apiClient: ApiClient(dio: dio),
              useMock: false,
            ),
          ),
        ],
        child: const MaterialApp(home: PublicEditorialPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('获准专题'), findsOneWidget);
    await tester.tap(find.text('获准专题'));
    await tester.pumpAndSettle();
    expect(find.text('获准正文'), findsOneWidget);
    expect(find.text('好友'), findsNothing);
    expect(find.text('评论'), findsNothing);
  });

  testWidgets(
    'friends is requested separately and authority changes hide old results',
    (tester) async {
      var revoked = false;
      final calls = <String>[];
      final dio = _fixtureTransport((request) {
        expect(request.path, '/api/v1/status/posts');
        final channel = request.queryParameters['channel'] as String;
        calls.add(channel);
        return {
          'items': [
            if (!revoked)
              {
                'id': 8,
                'title': channel == 'friends' ? '旧好友作品' : '精选公开作品',
                'audience': channel == 'friends'
                    ? 'FRIENDS'
                    : 'PUBLIC_AUTHENTICATED',
              },
          ],
        };
      });
      addTearDown(dio.close);
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          statusRemoteDataSourceProvider.overrideWithValue(
            StatusRemoteDataSource(
              apiClient: ApiClient(dio: dio),
              useMock: false,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: HomeContentChannels())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('精选公开作品'), findsOneWidget);
      await tester.tap(find.text('好友'));
      await tester.pumpAndSettle();
      expect(find.text('旧好友作品'), findsOneWidget);
      expect(find.text('精选公开作品'), findsNothing);
      revoked = true;
      container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      await tester.pumpAndSettle();
      expect(find.text('旧好友作品'), findsNothing);
      expect(calls, ['featured', 'friends', 'friends']);
      expect(find.text('当前没有可见作品。'), findsOneWidget);
    },
  );
}
