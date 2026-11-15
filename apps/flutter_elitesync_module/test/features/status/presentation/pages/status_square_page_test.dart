import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'QA-author',
  );

  void changeAccount() => state = const AsyncData(
    SessionState(status: AuthStatus.authenticated, accessToken: 'QA-other'),
  );
}

void main() {
  for (final changeAccount in [false, true]) {
    testWidgets(
      changeAccount
          ? 'an old picker result cannot upload into another account'
          : 'a picker result uploads after peer authority revalidation',
      (tester) async {
        tester.view.physicalSize = const Size(900, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final directory = Directory.systemTemp.createTempSync('status-picker-');
        final file = File('${directory.path}/clip.mp4')
          ..writeAsBytesSync([1, 2, 3]);
        addTearDown(() {
          file.deleteSync();
          directory.deleteSync();
        });
        final picked = Completer<String?>();
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async {
            expect(call.method, 'pickVideo');
            return picked.future;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          ),
        );
        var uploads = 0;
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (request, handler) {
                if (request.path == '/api/v1/media') uploads++;
                handler.resolve(
                  Response(
                    requestOptions: request,
                    statusCode: 200,
                    data: {
                      'asset': {'id': 42, 'status': 'ready'},
                    },
                  ),
                );
              },
            ),
          );
        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(_Session.new),
            profileProvider.overrideWith((ref) async => const ProfileUiState()),
            apiClientProvider.overrideWithValue(ApiClient(dio: dio)),
            statusPostPageProvider.overrideWith(
              (ref) async => const StatusPostPage(items: []),
            ),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const StatusSquarePage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), 'Private draft');
        await tester.ensureVisible(find.text('选择视频'));
        await tester.tap(find.text('选择视频'));
        await tester.pump();
        if (changeAccount) {
          (container.read(sessionProvider.notifier) as _Session)
              .changeAccount();
        } else {
          container
              .read(relationshipAuthorityEpochProvider.notifier)
              .invalidate();
        }
        await tester.pump();
        await tester.runAsync(() async {
          picked.complete(file.path);
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        expect(uploads, changeAccount ? 0 : 1);
        expect(
          find.text('Private draft'),
          changeAccount ? findsNothing : findsOneWidget,
        );
        expect(find.text('已完成'), changeAccount ? findsNothing : findsOneWidget);
      },
    );
  }

  testWidgets(
    'real page provider removes an old feed while revalidating and keeps the private draft',
    (tester) async {
      tester.view.physicalSize = const Size(900, 2800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final refreshed = Completer<void>();
      var reads = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) async {
              reads++;
              if (reads > 1) await refreshed.future;
              handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: 200,
                  data: {
                    'items': reads == 1
                        ? [
                            {
                              'id': 1,
                              'title': 'Old authorized post',
                              'body': 'Old peer body',
                            },
                          ]
                        : [],
                    'meta': {'has_more': false},
                  },
                ),
              );
            },
          ),
        );
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          profileProvider.overrideWith((ref) async => const ProfileUiState()),
          statusRemoteDataSourceProvider.overrideWith(
            (ref) => StatusRemoteDataSource(
              apiClient: ApiClient(dio: dio),
              useMock: false,
              identity: () =>
                  '${ref.read(sessionProvider).asData?.value.accessToken}:${ref.read(relationshipAuthorityEpochProvider)}',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const StatusSquarePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Old authorized post'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'My private draft');
      container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      await tester.pump();
      await tester.pump();
      expect(find.text('Old authorized post'), findsNothing);
      expect(find.text('Old peer body'), findsNothing);
      expect(find.text('My private draft'), findsOneWidget);
      refreshed.complete();
      await tester.pumpAndSettle();
      expect(find.text('Old authorized post'), findsNothing);
    },
  );

  for (final changeAccount in [false, true]) {
    testWidgets(
      changeAccount
          ? 'account change clears the community draft'
          : 'authority revalidation preserves the private unpublished draft',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(_Session.new),
            profileProvider.overrideWith((ref) async => const ProfileUiState()),
            statusPostPageProvider.overrideWith(
              (ref) async => const StatusPostPage(items: []),
            ),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const StatusSquarePage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), 'Private title');
        await tester.enterText(find.byType(TextField).at(1), 'Private caption');
        if (changeAccount) {
          (container.read(sessionProvider.notifier) as _Session)
              .changeAccount();
        } else {
          container
              .read(relationshipAuthorityEpochProvider.notifier)
              .invalidate();
        }
        await tester.pumpAndSettle();
        expect(
          find.text('Private title'),
          changeAccount ? findsNothing : findsOneWidget,
        );
        expect(
          find.text('Private caption'),
          changeAccount ? findsNothing : findsOneWidget,
        );
      },
    );
  }
}
