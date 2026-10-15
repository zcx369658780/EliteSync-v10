import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_attempt_dto.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_bundle_dto.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_submission_result_dto.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/questionnaire_mock.dart';

class QuestionnaireRemoteDataSource {
  QuestionnaireRemoteDataSource({
    required ApiClient apiClient,
    required bool useMockQuestionnaire,
  }) : _apiClient = apiClient,
       _useMockQuestionnaire = useMockQuestionnaire;

  final ApiClient _apiClient;
  final bool _useMockQuestionnaire;
  QuestionnaireBundleDto? _lastBundle;
  String _draftNotice = '';
  int? _bankRevision;

  String get draftNotice => _draftNotice;
  int? get bankRevision => _bankRevision;

  QuestionnaireBundleDto _readBundle(Map<String, dynamic> data) {
    final meta = data['meta'];
    _draftNotice = meta is Map ? (meta['draft_notice'] ?? '').toString() : '';
    _bankRevision = meta is Map
        ? int.tryParse((meta['bank_revision'] ?? '').toString())
        : null;
    return _lastBundle = QuestionnaireBundleDto.fromJson(data);
  }

  Future<QuestionnaireBundleDto> fetchQuestionnaire() async {
    if (_useMockQuestionnaire) {
      return _readBundle({
        'meta': QuestionnaireMock.meta,
        'questions': QuestionnaireMock.questions,
      });
    }

    final result = await _apiClient.get('/api/v1/questionnaire/questions');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return _readBundle(result.data);
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_FETCH_FAILED',
    );
  }

  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  }) async {
    if (_useMockQuestionnaire) {
      return;
    }
    final bundle = _lastBundle ?? await fetchQuestionnaire();
    _canonicalAnswers(answers, bundle);
    final result = await _apiClient.post(
      '/api/v1/questionnaire/draft',
      body: {
        'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
        'current_index': currentIndex,
        'version': bundle.version,
        'bank_version': bundle.bankVersion,
      },
    );
    if (result is NetworkSuccess<Map<String, dynamic>>) return;
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    if (failure.statusCode == 422 || failure.statusCode == 409) {
      throw const ValidationException(
        '草稿与当前题目不兼容，请重新加载当前题目后补答。',
        code: 'QUESTIONNAIRE_DRAFT_STALE',
      );
    }
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_DRAFT_SAVE_FAILED',
    );
  }

  Future<Map<String, dynamic>> fetchDraft() async {
    if (_useMockQuestionnaire) return {};
    final result = await _apiClient.get('/api/v1/questionnaire/draft');
    if (result is NetworkSuccess<Map<String, dynamic>>) return result.data;
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_DRAFT_FETCH_FAILED',
    );
  }

  List<Map<String, dynamic>> _canonicalAnswers(
    Map<int, int> answers,
    QuestionnaireBundleDto bundle,
  ) {
    final questions = {
      for (final question in bundle.questions) question.id: question,
    };
    return answers.entries.map((entry) {
      final question = questions[entry.key];
      final index = entry.value;
      if (question == null ||
          index < 0 ||
          index >= question.optionIds.length ||
          question.optionIds[index].isEmpty) {
        throw ValidationException(
          '问卷选项与当前题库不一致，请重新载入。',
          code: 'QUESTIONNAIRE_INVALID_OPTION',
        );
      }
      return <String, dynamic>{
        'question_id': question.id,
        'option_id': question.optionIds[index],
        'importance': 2,
        'version': question.version,
      };
    }).toList();
  }

  Future<QuestionnaireSubmissionResultDto> submitAnswers(
    Map<int, int> answers,
  ) async {
    if (_useMockQuestionnaire) {
      return QuestionnaireSubmissionResultDto.fromJson(
        QuestionnaireMock.submitHappy,
      );
    }

    final bundle = _lastBundle ?? await fetchQuestionnaire();
    final normalizedAnswers = _canonicalAnswers(answers, bundle);

    final result = await _apiClient.post(
      '/api/v1/questionnaire/answers',
      body: {'answers': normalizedAnswers},
    );

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return QuestionnaireSubmissionResultDto.fromJson(result.data);
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    if (failure.statusCode == 422 || failure.statusCode == 409) {
      throw const ValidationException(
        '题目集合已变更，提交未保存；已保留当前答案，请重新加载当前题目后补答。',
        code: 'QUESTIONNAIRE_SUBMIT_STALE',
      );
    }
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_SUBMIT_FAILED',
    );
  }

  Future<List<QuestionnaireAttemptDto>> fetchHistory() async {
    if (_useMockQuestionnaire) {
      return QuestionnaireMock.history
          .whereType<Map<String, dynamic>>()
          .map(QuestionnaireAttemptDto.fromJson)
          .toList();
    }

    final result = await _apiClient.get('/api/v1/questionnaire/history');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final items = (result.data['items'] as List?) ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(QuestionnaireAttemptDto.fromJson)
          .toList();
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_HISTORY_FETCH_FAILED',
    );
  }
}
