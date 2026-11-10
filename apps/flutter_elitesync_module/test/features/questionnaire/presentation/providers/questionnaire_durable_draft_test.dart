import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_bundle_dto.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_submission_result_dto.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _Local extends LocalStorageService {
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async => true;
}

class _Remote extends QuestionnaireRemoteDataSource {
  _Remote({this.lastQuestion = false})
    : super(apiClient: ApiClient(dio: Dio()), useMockQuestionnaire: false);
  final bool lastQuestion;
  final save = Completer<void>();
  final submission = Completer<QuestionnaireSubmissionResultDto>();
  int saves = 0;
  int submissions = 0;
  int? savedIndex;
  Map<int, int>? savedAnswers;

  @override
  Future<QuestionnaireBundleDto> fetchQuestionnaire() async =>
      QuestionnaireBundleDto.fromJson({
        'questions': [
          {
            'id': 10,
            'title': 'First',
            'options': ['A', 'B'],
          },
          if (!lastQuestion)
            {
              'id': 11,
              'title': 'Second',
              'options': ['A', 'B'],
            },
        ],
      });
  @override
  Future<Map<String, dynamic>> fetchDraft() async => {};
  @override
  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  }) {
    saves++;
    savedIndex = currentIndex;
    savedAnswers = Map.of(answers);
    return save.future;
  }

  @override
  Future<QuestionnaireSubmissionResultDto> submitAnswers(
    Map<int, int> answers,
  ) {
    submissions++;
    return submission.future;
  }
}

void main() {
  Future<ProviderContainer> create(_Remote remote) async {
    final container = ProviderContainer(
      overrides: [
        questionnaireRemoteDataSourceProvider.overrideWithValue(remote),
        localStorageProvider.overrideWithValue(_Local()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(questionnaireProvider.future);
    return container;
  }

  test(
    'advances only after server draft acknowledges current answer and next index',
    () async {
      final remote = _Remote();
      final container = await create(remote);
      final pending = container
          .read(questionnaireProvider.notifier)
          .selectOptionAndProceed(1);
      expect(remote.saves, 1);
      expect(remote.savedAnswers, {10: 1});
      expect(remote.savedIndex, 1);
      expect(
        container.read(questionnaireProvider).requireValue.currentIndex,
        0,
      );
      expect(
        container.read(questionnaireProvider).requireValue.isSavingDraft,
        isTrue,
      );
      remote.save.complete();
      await pending;
      final state = container.read(questionnaireProvider).requireValue;
      expect(state.currentIndex, 1);
      expect(state.isSavingDraft, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'failed durable write retains current question and exposes retry error',
    () async {
      final remote = _Remote();
      final container = await create(remote);
      final pending = container
          .read(questionnaireProvider.notifier)
          .selectOptionAndProceed(1);
      remote.save.completeError(Exception('server unavailable'));
      await pending;
      final state = container.read(questionnaireProvider).requireValue;
      expect(state.currentIndex, 0);
      expect(state.answers, {10: 1});
      expect(state.isSavingDraft, isFalse);
      expect(state.errorMessage, contains('草稿未保存'));
    },
  );

  test(
    'repeated clicks during draft save do not change selection or duplicate writes',
    () async {
      final remote = _Remote();
      final container = await create(remote);
      final notifier = container.read(questionnaireProvider.notifier);
      final pending = notifier.selectOptionAndProceed(1);
      expect(await notifier.selectOptionAndProceed(0), isFalse);
      expect(remote.saves, 1);
      expect(container.read(questionnaireProvider).requireValue.answers, {
        10: 1,
      });
      remote.save.complete();
      await pending;
      expect(
        container.read(questionnaireProvider).requireValue.currentIndex,
        1,
      );
    },
  );

  test(
    'repeated clicks during final submission do not duplicate requests',
    () async {
      final remote = _Remote(lastQuestion: true);
      final container = await create(remote);
      final notifier = container.read(questionnaireProvider.notifier);
      final pending = notifier.selectOptionAndProceed(1);
      expect(
        container.read(questionnaireProvider).requireValue.isSubmitting,
        isTrue,
      );
      expect(await notifier.selectOptionAndProceed(0), isFalse);
      expect(remote.submissions, 1);
      expect(remote.saves, 0);
      expect(container.read(questionnaireProvider).requireValue.answers, {
        10: 1,
      });
      remote.submission.completeError(Exception('server unavailable'));
      expect(await pending, isFalse);
      expect(
        container.read(questionnaireProvider).requireValue.isSubmitting,
        isFalse,
      );
    },
  );
}
