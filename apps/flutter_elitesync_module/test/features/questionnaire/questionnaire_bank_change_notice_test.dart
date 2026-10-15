import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

const _notice = '题目集合已变更，旧草稿已失效，请使用当前题目补答。';

class _Local extends LocalStorageService {
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async => true;
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  int questionFetches = 0;
  int draftSaves = 0;
  bool staleDraft = false;

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
}
