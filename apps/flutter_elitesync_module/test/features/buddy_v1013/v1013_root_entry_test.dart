import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/buddy_v1013/buddy_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/calm_home_projection_provider.dart';
import 'package:flutter_elitesync_module/features/progress/presentation/pages/progress_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class Sessions extends SessionNotifier {
  @override
  Future<SessionState> build() async => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-no-dating-profile',
    user: UserSummary(id: 1, phone: ''),
  );
}

class Api extends RelationshipApi {
  Api() : super(ApiClient(dio: Dio()));
  final paths = <String>[];
  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    expect(method, 'GET');
    paths.add(path);
    if (path == '/journey')
      throw StateError('Synthetic user has no dating participation or profile');
    expect(path, '/buddy');
    return {
      'preferences': {'enabled': false, 'revision': 0},
      'activities': [],
    };
  }
}

void main() {
  test('test is compiled with the real v1013 build gate', () {
    expect(const bool.fromEnvironment('ELITESYNC_V1013_LOCAL_BUILD'), isTrue);
    expect(const bool.fromEnvironment('ELITESYNC_V1012_LOCAL_BUILD'), isFalse);
  });
  for (final home in [true, false]) {
    for (final buddy in [true, false]) {
      testWidgets(
        '${home ? 'HomePage' : 'ProgressPage'} independently opens ${buddy ? 'BuddyPage' : 'StatusSquarePage'} without dating readiness',
        (tester) async {
          tester.view.physicalSize = const Size(900, 2400);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final api = Api();
          var communityReads = 0;
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sessionProvider.overrideWith(Sessions.new),
                relationshipApiProvider.overrideWithValue(api),
                calmHomeProjectionProvider.overrideWith(
                  (ref) => throw StateError(
                    'Legacy dating readiness projection must not be required',
                  ),
                ),
                profileProvider.overrideWith(
                  (ref) async => const ProfileUiState(),
                ),
                statusPostPageProvider.overrideWith((ref) async {
                  communityReads++;
                  return const StatusPostPage(items: []);
                }),
              ],
              child: MaterialApp(
                theme: AppTheme.light,
                home: home ? const HomePage() : const ProgressPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('独立吃饭 / 学习搭子'), findsOneWidget);
          expect(find.text('好友可见社区'), findsOneWidget);
          expect(find.text('三阶段只读摘要'), findsNothing);
          final entry = find.text(buddy ? '独立吃饭 / 学习搭子' : '好友可见社区');
          await tester.ensureVisible(entry);
          await tester.tap(entry);
          await tester.pumpAndSettle();
          if (buddy) {
            expect(find.byType(BuddyPage), findsOneWidget);
            expect(api.paths, contains('/buddy'));
          } else {
            expect(find.byType(StatusSquarePage), findsOneWidget);
            expect(communityReads, 1);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
