import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/private_video_player.dart';

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'synthetic-test-only',
  );
  void relogin() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'second-synthetic-test-only',
    ),
  );
}

class _Player extends VideoPlayerController {
  _Player(super.uri, Map<String, String> headers)
    : super.networkUrl(httpHeaders: headers);
  bool disposed = false;
  @override
  Future<void> initialize() async {
    value = VideoPlayerValue(
      duration: const Duration(seconds: 5),
      size: const Size(320, 240),
      isInitialized: true,
    );
  }

  @override
  Future<void> setLooping(bool looping) async {}
  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await super.dispose();
  }
}

void main() {
  testWidgets(
    'private player uses current header and server ID; revoke stops native buffer',
    (tester) async {
      var revoked = false;
      var requests = 0;
      _Player? player;
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8001'));
      dio.interceptors.add(
        AuthInterceptor(accessTokenProvider: () async => 'synthetic-test-only'),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            expect(options.path, '/api/v1/media/42/content');
            expect(options.headers['Range'], 'bytes=0-0');
            expect(
              options.headers['Authorization'],
              'Bearer synthetic-test-only',
            );
            if (revoked) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(requestOptions: options, statusCode: 404),
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 206,
                  data: <int>[0],
                ),
              );
            }
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
      await container.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: PrivateVideoPlayer(
                assetId: 42,
                controllerFactory: (uri, headers) {
                  expect(
                    uri.toString(),
                    'http://127.0.0.1:8001/api/v1/media/42/content',
                  );
                  expect(
                    headers['Authorization'],
                    'Bearer synthetic-test-only',
                  );
                  return player = _Player(uri, headers);
                },
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(player, isNotNull);
      await tester.tap(find.byTooltip('播放视频'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(player!.value.isPlaying, isTrue);
      revoked = true;
      await tester.pump(const Duration(seconds: 2));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(player!.disposed, isTrue);
      expect(player!.value.isPlaying, isFalse);
      expect(find.textContaining('视频不可用'), findsOneWidget);
      expect(requests, greaterThanOrEqualTo(4));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('server denies preflight: no native player is created', (
    tester,
  ) async {
    var created = false;
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8001'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        dioProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: PrivateVideoPlayer(
              assetId: 42,
              controllerFactory: (uri, headers) {
                created = true;
                return _Player(uri, headers);
              },
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(created, isFalse);
    expect(find.textContaining('视频不可用'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
