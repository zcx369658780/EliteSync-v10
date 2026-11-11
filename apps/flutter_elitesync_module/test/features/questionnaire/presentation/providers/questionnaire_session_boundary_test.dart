import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState _identity(int id, [String? token]) => SessionState(
  status: AuthStatus.authenticated,
  user: UserSummary(id: id, phone: 'fictional-$id'),
  accessToken: token ?? 'fictional-token-$id',
);

class _Session extends SessionNotifier {
  @override
  SessionState build() => _identity(1);
  void change(SessionState next) => state = AsyncData(next);
}

class _Local extends LocalStorageService {
  final writes = <String>[];
  final removals = <String>[];
  String label = 'Snapshot A';
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    writes.add(key);
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    removals.add(key);
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => {'label': label};
}

class _Api extends ApiClient {
  _Api(this.owner) : super(dio: Dio());
  final int Function() owner;
  Completer<void>? draftAck;
  Completer<void>? submissionAck;
  Completer<void>? firstDispatch;
  int gets = 0;
  final dispatchedQuestionOwners = <int>[];
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    gets++;
    final actor = owner();
    if (path.endsWith('/questions')) {
      if (actor == 1 && firstDispatch != null) await firstDispatch!.future;
      final request = RequestOptions(path: path, extra: options?.extra);
      if (!requestSessionIsCurrent(request)) {
        return const NetworkFailure(message: 'stale session');
      }
      dispatchedQuestionOwners.add(owner());
      return NetworkSuccess({
        'questions': [
          for (var i = 0; i < 2; i++)
            {
              'id': actor * 10 + i,
              'title': 'Account $actor question $i',
              'option_items': [
                {
                  'option_id': 'A',
                  'label': {'zh': 'A'},
                },
                {
                  'option_id': 'B',
                  'label': {'zh': 'B'},
                },
              ],
            },
        ],
      });
    }
    if (path.endsWith('/history')) {
      return NetworkSuccess({
        'items': [
          {'id': actor, 'result_label': 'Account $actor history'},
        ],
      });
    }
    return const NetworkSuccess(<String, dynamic>{});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    CancelToken? cancelToken,
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path.endsWith('/draft') && draftAck != null) await draftAck!.future;
    if (path.endsWith('/answers')) {
      if (submissionAck != null) await submissionAck!.future;
      return const NetworkSuccess({
        'profile': {
          'complete': true,
          'summary': {'label': 'Old account A result'},
        },
      });
    }
    return const NetworkSuccess(<String, dynamic>{});
  }
}

void main() {
  late ProviderContainer container;
  late _Api api;
  late _Local local;
  setUp(() {
    local = _Local();
    api = _Api(
      () => container.read(sessionProvider).asData?.value.user?.id ?? 0,
    );
    container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        apiClientProvider.overrideWithValue(api),
        localStorageProvider.overrideWithValue(local),
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'fixture',
            apiBaseUrl: 'http://127.0.0.1',
            useMockData: false,
          ),
        ),
        frontendTelemetryProvider.overrideWithValue(
          FrontendTelemetry(
            telemetry: AppTelemetryService(
              apiClient: api,
              appVersionProvider: () async => 'fixture',
            ),
          ),
        ),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> switchTo(SessionState session) async {
    (container.read(sessionProvider.notifier) as _Session).change(session);
    await container.pump();
  }

  test(
    'account switch reloads questions, history and cached summary without A answers',
    () async {
      await container.read(questionnaireProvider.future);
      container.read(questionnaireProvider.notifier).selectOption(0);
      expect(
        (await container.read(questionnaireHistoryProvider.future)).single.id,
        1,
      );
      expect(
        (await container.read(
          questionnaireProfileSnapshotProvider.future,
        ))?.label,
        'Snapshot A',
      );
      local.label = 'Snapshot B';
      await switchTo(_identity(2));
      final fresh = await container.read(questionnaireProvider.future);
      expect(fresh.questions.first.id, 20);
      expect(fresh.answers, isEmpty);
      expect(
        (await container.read(questionnaireHistoryProvider.future)).single.id,
        2,
      );
      expect(
        (await container.read(
          questionnaireProfileSnapshotProvider.future,
        ))?.label,
        'Snapshot B',
      );
    },
  );

  test(
    'old draft acknowledgement cannot advance B or write B local cache',
    () async {
      await container.read(questionnaireProvider.future);
      api.draftAck = Completer<void>();
      final pending = container
          .read(questionnaireProvider.notifier)
          .selectOptionAndProceed(0);
      await Future<void>.delayed(Duration.zero);
      await switchTo(_identity(2));
      await container.read(questionnaireProvider.future);
      final writes = local.writes.length;
      api.draftAck!.complete();
      expect(await pending, isFalse);
      final fresh = container.read(questionnaireProvider).requireValue;
      expect(fresh.questions.first.id, 20);
      expect(fresh.currentIndex, 0);
      expect(fresh.answers, isEmpty);
      expect(local.writes.length, writes);
    },
  );

  test(
    'old submission cannot clear B draft, cache A result or signal navigation success',
    () async {
      await container.read(questionnaireProvider.future);
      final notifier = container.read(questionnaireProvider.notifier);
      notifier.selectOption(0);
      notifier.next();
      notifier.selectOption(0);
      api.submissionAck = Completer<void>();
      final pending = notifier.submit();
      await switchTo(_identity(2));
      await container.read(questionnaireProvider.future);
      final removals = local.removals.length;
      final writes = local.writes.length;
      api.submissionAck!.complete();
      expect(await pending, isFalse);
      expect(local.removals.length, removals);
      expect(local.writes.length, writes);
      final fresh = container.read(questionnaireProvider).requireValue;
      expect(fresh.questions.first.id, 20);
      expect(fresh.submitted, isFalse);
      expect(fresh.resultLabel, isNull);
      expect(
        local.writes.where(
          (key) => key == CacheKeys.questionnaireProfileSnapshot,
        ),
        isEmpty,
      );
    },
  );

  test(
    'logout clears questionnaire and history without new private requests',
    () async {
      await container.read(questionnaireProvider.future);
      await container.read(questionnaireHistoryProvider.future);
      final gets = api.gets;
      await switchTo(const SessionState(status: AuthStatus.unauthenticated));
      expect(
        (await container.read(questionnaireProvider.future)).questions,
        isEmpty,
      );
      expect(
        await container.read(questionnaireHistoryProvider.future),
        isEmpty,
      );
      expect(
        await container.read(questionnaireProfileSnapshotProvider.future),
        isNull,
      );
      expect(api.gets, gets);
    },
  );

  for (final next in [_identity(2), _identity(1, 'fictional-replaced-token')]) {
    test(
      'queued request rejects old session after switch to ${next.accessToken}',
      () async {
        await container.read(sessionProvider.future);
        api.firstDispatch = Completer<void>();
        final first = container.read(questionnaireProvider.future);
        unawaited(
          first.then<void>((_) {}, onError: (Object _, StackTrace _) {}),
        );
        await Future<void>.delayed(Duration.zero);
        await switchTo(next);
        api.firstDispatch!.complete();
        final fresh = await container.read(questionnaireProvider.future);
        expect(fresh.questions.first.id, next.user!.id * 10);
        expect(api.dispatchedQuestionOwners, [next.user!.id]);
      },
    );
  }

  test(
    'A to B to the same A identity never revives an old submission',
    () async {
      await container.read(questionnaireProvider.future);
      final original = container.read(sessionProvider).requireValue;
      final notifier = container.read(questionnaireProvider.notifier);
      notifier.selectOption(0);
      notifier.next();
      notifier.selectOption(0);
      api.submissionAck = Completer<void>();
      final pending = notifier.submit();
      await switchTo(_identity(2));
      await container.read(questionnaireProvider.future);
      await switchTo(original);
      await container.read(questionnaireProvider.future);
      final removals = local.removals.length;
      final writes = local.writes.length;
      api.submissionAck!.complete();
      expect(await pending, isFalse);
      final fresh = container.read(questionnaireProvider).requireValue;
      expect(fresh.questions.first.id, 10);
      expect(fresh.answers, isEmpty);
      expect(fresh.submitted, isFalse);
      expect(local.removals.length, removals);
      expect(local.writes.length, writes);
    },
  );
}
