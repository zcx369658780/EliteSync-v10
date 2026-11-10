import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/natal_restoration_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/natal_restoration_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_restoration_charts.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 101, phone: 'fictional-A'),
    accessToken: 'fictional-token-A',
  );
  void switchToB() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 202, phone: 'fictional-B'),
      accessToken: 'fictional-token-B',
    ),
  );
  void replaceTokenForA() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 101, phone: 'fictional-A'),
      accessToken: 'fictional-refreshed-token-A',
    ),
  );
}

Map<String, dynamic> _profile() => {
  'exists': true,
  'profile': {
    'input': {
      'civil_date': '1990-01-01',
      'civil_time': null,
      'time_precision': 'unknown',
      'timezone': 'Asia/Shanghai',
      'algorithm_sex': 'unknown',
    },
    'settings': {},
    'context': {},
    'results': {},
    'input_revision': 1,
    'result_revision': 1,
    'status': 'COMPUTED_UNVERIFIED',
  },
};

class _DelayedTokenApi {
  _DelayedTokenApi(this.delayedMethod) {
    dio.interceptors.add(
      AuthInterceptor(
        accessTokenProvider: () {
          if (activeMethod == delayedMethod) {
            if (!entered.isCompleted) entered.complete();
            return token.future;
          }
          return Future.value('fictional-token-A');
        },
      ),
    );
    // This request observer is downstream of the real AuthInterceptor. A stale
    // request reaching it would already be eligible for transport dispatch.
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (request, handler) {
          activeMethod = request.method;
          request.extra['test-only-request-id'] = ++requestId;
          handler.next(request);
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          dispatched.add(request.method);
          dispatchedRequestIds.add(
            request.extra['test-only-request-id'] as int,
          );
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: _profile(),
            ),
          );
        },
      ),
    );
  }
  final String delayedMethod;
  final dio = Dio();
  String? activeMethod;
  final entered = Completer<void>();
  final token = Completer<String?>();
  final dispatched = <String>[];
  int requestId = 0;
  final dispatchedRequestIds = <int>[];
}

class _ConcurrentApi extends ApiClient {
  _ConcurrentApi() : super(dio: Dio());
  int reads = 0;
  int writes = 0;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    reads++;
    final result = _profile();
    final profile = result['profile'] as Map<String, dynamic>;
    profile['input_revision'] = reads == 1 ? 1 : 3;
    profile['input_signature'] = reads == 1 ? 'signature-A' : 'signature-C';
    if (reads > 1) {
      (profile['input'] as Map<String, dynamic>)['civil_date'] = '1991-02-03';
    }
    return NetworkSuccess(result);
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    writes++;
    final result = _profile();
    final profile = result['profile'] as Map<String, dynamic>;
    profile['input_revision'] = 2;
    profile['input_signature'] = 'signature-B';
    return NetworkSuccess(result);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final provider in [astroSummaryProvider, astroNatalChartProvider]) {
    test(
      'legacy profile provider discards A request across delayed B token',
      () async {
        final network = _DelayedTokenApi('GET');
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(ApiClient(dio: network.dio)),
            sessionProvider.overrideWith(_Session.new),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(() => network.dio.close(force: true));
        await container.read(sessionProvider.future);
        unawaited(
          container
              .read(provider.future)
              .then<void>((_) {}, onError: (Object _) {}),
        );
        await network.entered.future;
        (container.read(sessionProvider.notifier) as _Session).switchToB();
        network.token.complete('fictional-token-B');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(network.dispatchedRequestIds, isNot(contains(1)));
        expect(container.read(sessionProvider).asData?.value.user?.id, 202);
      },
    );
  }
  testWidgets(
    'concurrent edit between POST and GET never rebinds old form to new revision',
    (tester) async {
      final api = _ConcurrentApi();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          sessionProvider.overrideWith(_Session.new),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NatalRestorationPage()),
        ),
      );
      await tester.pumpAndSettle();
      final save = find.text('保存、计算并持久重读');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(api.writes, 1);
      expect(api.reads, 2);
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(of: save, matching: find.byType(FilledButton)),
            )
            .onPressed,
        isNull,
      );
      expect(find.textContaining('已保存并重新读取。'), findsNothing);
      await tester.drag(find.byType(ListView).first, const Offset(0, 4000));
      await tester.pumpAndSettle();
      expect(find.textContaining('保存后资料已被另一处更新'), findsOneWidget);
      // Only an explicit reload may populate C's inputs and revision.
      await tester.tap(find.text('重新读取已保存资料（替换当前输入）'));
      await tester.pumpAndSettle();
      expect(api.reads, 3);
      final date = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(date.controller!.text, '1991-02-03');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('real ziwei schema renders natal transformation beside star', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NatalRestorationCharts(
              results: {
                'ziwei': {
                  'calculation_status': 'CALCULATED',
                  'oracle_status': 'UNVERIFIED',
                  'palaces': [
                    {
                      'name': '命宫',
                      'heavenly_stem': '甲',
                      'earthly_branch': '子',
                      'major_stars': [
                        {
                          'name': '紫微',
                          'brightness': '庙',
                          'natal_transformation': '禄',
                        },
                      ],
                    },
                  ],
                },
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('紫微 庙 禄'), findsOneWidget);
    expect(find.textContaining('待核验 (UNVERIFIED)'), findsOneWidget);
  });

  test(
    'GET captured as A does not dispatch with B token after storage await',
    () async {
      final network = _DelayedTokenApi('GET');
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient(dio: network.dio)),
          sessionProvider.overrideWith(_Session.new),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(() => network.dio.close(force: true));
      await container.read(sessionProvider.future);
      final future = container.read(natalRestorationProvider.future);
      // Attach error handling before invalidating the request's session.
      unawaited(future.then<void>((_) {}, onError: (Object _) {}));
      await network.entered.future;
      (container.read(sessionProvider.notifier) as _Session).switchToB();
      network.token.complete('fictional-token-B');
      // Riverpod may discard the disposed A future when sessionProvider changes.
      // Wait for the real interceptor to process token completion, not that future.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(network.dispatched, isEmpty);
    },
  );

  for (final sameUser in [false, true]) {
    testWidgets(
      'POST is blocked during token await: ${sameUser ? 'same user new session token' : 'A to B'}',
      (tester) async {
        final network = _DelayedTokenApi('POST');
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(ApiClient(dio: network.dio)),
            sessionProvider.overrideWith(_Session.new),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(() => network.dio.close(force: true));
        await container.read(sessionProvider.future);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: NatalRestorationPage()),
          ),
        );
        await tester.pumpAndSettle();
        final save = find.text('保存、计算并持久重读');
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        for (var i = 0; i < 15 && !network.entered.isCompleted; i++) {
          await tester.pump(const Duration(milliseconds: 10));
        }
        expect(network.entered.isCompleted, isTrue);
        final session = container.read(sessionProvider.notifier) as _Session;
        if (sameUser) {
          session.replaceTokenForA();
        } else {
          session.switchToB();
        }
        await tester.pump();
        network.token.complete(
          sameUser ? 'fictional-refreshed-token-A' : 'fictional-token-B',
        );
        await tester.pumpAndSettle();
        expect(network.dispatched.where((method) => method == 'POST'), isEmpty);
        expect(find.textContaining('已保存并重新读取。'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
