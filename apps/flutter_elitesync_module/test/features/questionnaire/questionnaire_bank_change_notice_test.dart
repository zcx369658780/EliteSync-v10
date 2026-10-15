import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

const _notice = '题目集合已变更，旧草稿已失效，请使用当前题目补答。';

class _Local extends LocalStorageService {
  @override
  Future<bool> remove(String key) async => true;
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async => true;
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  int questionFetches = 0;
  int draftSaves = 0;
  bool staleDraft = false;
  int? submitStatus;
  int submissions = 0;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path.endsWith('/draft')) {
      return const NetworkSuccess(<String, dynamic>{});
    }
    questionFetches++;
    final firstId = questionFetches * 100;
    return NetworkSuccess({
      'meta': {
        'version': 'q_v2',
        'bank_version': 'qb_v1',
        'bank_revision': questionFetches + 7,
        'draft_notice': _notice,
      },
      'questions': [
        for (var i = 0; i < 2; i++)
          {
            'id': firstId + i,
            'title': 'Current question $i',
            'question_version': 3,
            'option_items': [
              {
                'option_id': 'CURRENT_OPTION',
                'label': {'zh': '当前选项'},
              },
            ],
          },
      ],
    });
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    CancelToken? cancelToken,
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path.endsWith('/answers')) {
      submissions++;
      if (submitStatus != null) {
        return NetworkFailure(
          message: 'fixture submit failure',
          statusCode: submitStatus,
        );
      }
      return const NetworkSuccess({
        'profile': {'complete': true},
      });
    }
    if (!path.endsWith('/draft'))
      return const NetworkSuccess(<String, dynamic>{});
    draftSaves++;
    if (staleDraft) {
      return const NetworkFailure(
        message: 'stale draft version',
        statusCode: 422,
      );
    }
    return const NetworkSuccess(<String, dynamic>{});
  }
}

void main() {
  late _Api api;
  late ProviderContainer container;

  setUp(() {
    api = _Api();
    container = ProviderContainer(
      overrides: [
        questionnaireRemoteDataSourceProvider.overrideWithValue(
          QuestionnaireRemoteDataSource(
            apiClient: api,
            useMockQuestionnaire: false,
          ),
        ),
        localStorageProvider.overrideWithValue(_Local()),
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

  test(
    'server bank metadata reaches provider and survives option selection',
    () async {
      await container.read(questionnaireProvider.future);
      var notice = container.read(questionnaireBankNoticeProvider);
      expect(notice.draftNotice, _notice);
      expect(notice.bankRevision, 8);
      expect(notice.needsReload, isFalse);
      container.read(questionnaireProvider.notifier).selectOption(0);
      notice = container.read(questionnaireBankNoticeProvider);
      expect(notice.draftNotice, _notice);
      expect(notice.bankRevision, 8);
    },
  );

  test(
    'stale draft retains current answer and requires current-bank reload',
    () async {
      await container.read(questionnaireProvider.future);
      api.staleDraft = true;
      final notifier = container.read(questionnaireProvider.notifier);
      expect(await notifier.selectOptionAndProceed(0), isFalse);
      final failed = container.read(questionnaireProvider).requireValue;
      expect(failed.currentIndex, 0);
      expect(failed.answers, {100: 0});
      expect(failed.isSavingDraft, isFalse);
      expect(failed.errorMessage, contains('重新加载当前题目'));
      expect(
        container.read(questionnaireBankNoticeProvider).needsReload,
        isTrue,
      );
      expect(await notifier.selectOptionAndProceed(0), isFalse);
      expect(api.draftSaves, 1);
      container.invalidate(questionnaireProvider);
      final reloaded = await container.read(questionnaireProvider.future);
      expect(api.questionFetches, 2);
      expect(reloaded.questions.first.id, 200);
      expect(reloaded.answers, isEmpty);
      final notice = container.read(questionnaireBankNoticeProvider);
      expect(notice.bankRevision, 9);
      expect(notice.draftNotice, _notice);
      expect(notice.needsReload, isFalse);
    },
  );
  for (final status in [422, 409]) {
    test(
      'last answer submit $status keeps answers, blocks resubmit and reloads current bank',
      () async {
        await container.read(questionnaireProvider.future);
        final notifier = container.read(questionnaireProvider.notifier);
        expect(await notifier.selectOptionAndProceed(0), isFalse);
        expect(
          container.read(questionnaireProvider).requireValue.currentIndex,
          1,
        );
        api.submitStatus = status;
        expect(await notifier.selectOptionAndProceed(0), isFalse);
        final failed = container.read(questionnaireProvider).requireValue;
        expect(failed.answers, {100: 0, 101: 0});
        expect(failed.currentIndex, 1);
        expect(failed.isSubmitting, isFalse);
        expect(failed.submitted, isFalse);
        expect(failed.errorMessage, contains('题目集合已变更'));
        expect(failed.errorMessage, contains('重新加载当前题目'));
        expect(
          container.read(questionnaireBankNoticeProvider).needsReload,
          isTrue,
        );
        expect(await notifier.submit(), isFalse);
        expect(await notifier.selectOptionAndProceed(0), isFalse);
        expect(api.submissions, 1);
        expect(container.read(questionnaireProvider).requireValue.answers, {
          100: 0,
          101: 0,
        });
        container.invalidate(questionnaireProvider);
        final reloaded = await container.read(questionnaireProvider.future);
        expect(api.questionFetches, 2);
        expect(reloaded.questions.map((q) => q.id), [200, 201]);
        expect(reloaded.answers, isEmpty);
        expect(container.read(questionnaireBankNoticeProvider).bankRevision, 9);
        expect(
          container.read(questionnaireBankNoticeProvider).needsReload,
          isFalse,
        );
        api.submitStatus = null;
        final currentNotifier = container.read(questionnaireProvider.notifier);
        expect(await currentNotifier.selectOptionAndProceed(0), isFalse);
        expect(await currentNotifier.selectOptionAndProceed(0), isTrue);
        expect(api.submissions, 2);
        expect(
          container.read(questionnaireProvider).requireValue.submitted,
          isTrue,
        );
        expect(container.read(questionnaireProvider).requireValue.answers, {
          200: 0,
          201: 0,
        });
      },
    );
  }

  test(
    'network submit failure preserves answers without claiming a bank change',
    () async {
      await container.read(questionnaireProvider.future);
      final notifier = container.read(questionnaireProvider.notifier);
      await notifier.selectOptionAndProceed(0);
      api.submitStatus = 503;
      expect(await notifier.selectOptionAndProceed(0), isFalse);
      final failed = container.read(questionnaireProvider).requireValue;
      expect(failed.answers, {100: 0, 101: 0});
      expect(failed.isSubmitting, isFalse);
      expect(failed.errorMessage, contains('fixture submit failure'));
      expect(failed.errorMessage, isNot(contains('题目集合已变更')));
      expect(
        container.read(questionnaireBankNoticeProvider).needsReload,
        isFalse,
      );
      expect(await notifier.submit(), isFalse);
      expect(api.submissions, 2);
    },
  );
}
