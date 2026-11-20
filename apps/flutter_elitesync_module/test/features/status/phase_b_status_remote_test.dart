import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a delayed featured search cannot return the prior account’s work',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid'));
      addTearDown(dio.close);
      var identity = 'first';
      final sent = Completer<void>();
      final release = Completer<void>();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            expect(
              options.queryParameters,
              containsPair('channel', 'featured'),
            );
            expect(options.queryParameters, containsPair('q', 'query'));
            sent.complete();
            await release.future;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'items': []},
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final source = StatusRemoteDataSource(
        apiClient: ApiClient(dio: dio),
        useMock: false,
        identity: () => identity,
      );
      final pending = source.fetchStatusPage(
        channel: 'featured',
        query: 'query',
      );
      final rejected = expectLater(pending, throwsStateError);
      await sent.future;
      identity = 'second';
      release.complete();
      await rejected;
    },
  );

  test(
    'audience expansion uses a read-only preview and its exact revision',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid'));
      addTearDown(dio.close);
      final methods = <String>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            methods.add(request.method);
            expect(request.path, '/api/v1/status/posts/8/audience');
            if (request.method == 'GET') {
              expect(request.queryParameters, {
                'audience': 'PUBLIC_AUTHENTICATED',
              });
            } else {
              expect(request.data, {
                'audience': 'PUBLIC_AUTHENTICATED',
                'confirm': true,
                'expected_revision': 4,
              });
            }
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {
                  'id': 8,
                  'audience': 'PUBLIC_AUTHENTICATED',
                  'comment_policy': 'FRIENDS_ONLY',
                  'audience_revision': 4,
                  'expands': true,
                  'cover_keeps_original_audience': true,
                },
              ),
            );
          },
        ),
      );
      final source = StatusRemoteDataSource(
        apiClient: ApiClient(dio: dio),
        useMock: false,
      );
      final preview = await source.previewAudience(8, 'PUBLIC_AUTHENTICATED');
      expect(preview.revision, 4);
      expect(preview.commentPolicy, 'FRIENDS_ONLY');
      await source.updateAudience(
        8,
        'PUBLIC_AUTHENTICATED',
        revision: preview.revision,
      );
      expect(methods, ['GET', 'PUT']);
    },
  );

  test(
    'an uncertain publication is read back by original command key',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid'));
      addTearDown(dio.close);
      const key = 'e4cf6b62-c014-40e5-8ed4-3ca148a08df4';
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            expect(request.method, 'GET');
            expect(request.path, '/api/v1/status/posts/command-result/$key');
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {'state': 'APPLIED', 'id': 8},
              ),
            );
          },
        ),
      );
      final source = StatusRemoteDataSource(
        apiClient: ApiClient(dio: dio),
        useMock: false,
      );
      expect(await source.publicationResult(key), 'APPLIED');
    },
  );
}
