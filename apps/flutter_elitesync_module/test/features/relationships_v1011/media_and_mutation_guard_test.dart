import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/moderation/data/datasource/moderation_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'relationship_pages_test.dart' as support;

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'notification read started by A cannot dispatch using B after token read',
    () async {
      var identity = 'A';
      var sent = 0;
      final token = Completer<String?>();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.interceptors.add(
        AuthInterceptor(accessTokenProvider: () => token.future),
      );
      dio.httpClientAdapter = _Adapter((_) async {
        sent++;
        return ResponseBody.fromString(
          '{"items":[]}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      });
      final source = NotificationRemoteDataSource(
        apiClient: ApiClient(dio: dio),
        useMock: false,
        identity: () => identity,
      );
      final read = source.fetchNotifications();
      final assertion = expectLater(read, throwsException);
      await Future<void>.delayed(Duration.zero);
      identity = 'B';
      token.complete('B-token');
      await assertion;
      expect(sent, 0);
      dio.close();
    },
  );
  for (final stage in ['version', 'token']) {
    test(
      'block started by A is never dispatched as B while $stage is suspended',
      () async {
        var identity = 'A';
        var sent = 0;
        var blocked = false;
        final version = Completer<String>();
        final token = Completer<String?>();
        final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
        dio.interceptors.add(
          AuthInterceptor(accessTokenProvider: () => token.future),
        );
        dio.httpClientAdapter = _Adapter((options) async {
          sent++;
          return ResponseBody.fromString(
            '{"ok":true}',
            200,
            headers: {
              'content-type': ['application/json'],
            },
          );
        });
        final telemetry = AppTelemetryService(
          apiClient: ApiClient(dio: dio),
          appVersionProvider: () => version.future,
          sessionIdentity: () => identity,
        );
        final remote = ModerationRemoteDataSource(
          telemetry: telemetry,
          useMock: false,
          onBlocked: () => blocked = true,
        );
        final operation = remote.blockUser(
          blockedUserId: 2,
          sourcePage: 'test',
        );
        final assertion = expectLater(operation, throwsException);
        if (stage == 'token') {
          version.complete('test');
          await Future<void>.delayed(Duration.zero);
        }
        identity = 'B';
        if (!version.isCompleted) version.complete('test');
        token.complete('B-token');
        await assertion;
        expect(sent, 0);
        expect(blocked, false);
        dio.close();
      },
    );
  }
  testWidgets(
    'private image sends bearer credential and clears old memory on epoch and account changes',
    (tester) async {
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
      );
      final requests = <RequestOptions>[];
      final pending = <Completer<ResponseBody>>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _Adapter((options) {
        requests.add(options);
        final response = Completer<ResponseBody>();
        pending.add(response);
        return response.future;
      });
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(support.TestSession.new),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(dio.close);
      await container.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: AuthenticatedStatusImage(assetId: 99)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(requests.single.path, '/api/v1/media/99/content');
      expect(requests.single.headers['Authorization'], 'Bearer test-1');
      pending[0].complete(
        ResponseBody.fromBytes(
          png,
          200,
          headers: {
            'content-type': ['image/png'],
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      (container.read(sessionProvider.notifier) as support.TestSession).change(
        2,
      );
      await tester.pumpAndSettle();
      expect(requests.last.headers['Authorization'], 'Bearer test-2');
      pending[1].complete(ResponseBody.fromBytes(png, 200));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      pending[2].complete(ResponseBody.fromBytes(png, 200));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
    },
  );
}
