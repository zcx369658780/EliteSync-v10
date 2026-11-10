import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/question_item_dto.dart';

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  String? postPath;
  Object? postBody;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async => NetworkSuccess({
    'meta': {'version': 'q_v7', 'bank_version': 'bank7'},
    'questions': [
      {
        'id': 42,
        'title': 'Question',
        'question_version': 7,
        'option_items': [
          {
            'option_id': 'A',
            'label': {'zh': 'first'},
          },
          {
            'option_id': 'E',
            'label': {'zh': 'last'},
          },
        ],
      },
    ],
  });
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    CancelToken? cancelToken,
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    postPath = path;
    postBody = body;
    return NetworkSuccess(<String, dynamic>{});
  }
}

void main() {
  test('option IDs stay aligned when empty labels are omitted', () {
    final dto = QuestionItemDto.fromJson({
      'option_items': [
        {
          'option_id': 'A',
          'label': {'zh': ''},
        },
        {
          'option_id': 'D',
          'label': {'en': 'English label'},
        },
        {
          'option_id': 'E',
          'label': {'zh': '最后'},
        },
      ],
    });
    expect(dto.options, ['English label', '最后']);
    expect(dto.optionIds, ['D', 'E']);
  });
  late _Api api;
  late QuestionnaireRemoteDataSource source;
  setUp(() {
    api = _Api();
    source = QuestionnaireRemoteDataSource(
      apiClient: api,
      useMockQuestionnaire: false,
    );
  });
  test(
    'submits canonical option identity and fetched question version',
    () async {
      await source.fetchQuestionnaire();
      await source.submitAnswers({42: 1});
      expect(api.postBody, {
        'answers': [
          {'question_id': 42, 'option_id': 'E', 'importance': 2, 'version': 7},
        ],
      });
    },
  );
  test('persists indexed draft with fetched bank identity', () async {
    await source.fetchQuestionnaire();
    await source.saveDraft(currentIndex: 3, answers: {42: 1});
    expect(api.postPath, '/api/v1/questionnaire/draft');
    expect(api.postBody, {
      'answers': {'42': 1},
      'current_index': 3,
      'version': 'q_v7',
      'bank_version': 'bank7',
    });
  });
  test('rejects invalid option index before any submission', () async {
    await source.fetchQuestionnaire();
    await expectLater(
      source.submitAnswers({42: 2}),
      throwsA(isA<ValidationException>()),
    );
    expect(api.postPath, isNull);
  });
  test('rejects unknown questions before any draft write', () async {
    await source.fetchQuestionnaire();
    await expectLater(
      source.saveDraft(currentIndex: 0, answers: {999: 0}),
      throwsA(isA<ValidationException>()),
    );
    expect(api.postPath, isNull);
  });
  test('submission fetches mapping when no bundle is cached', () async {
    await source.submitAnswers({42: 0});
    expect(api.postBody, {
      'answers': [
        {'question_id': 42, 'option_id': 'A', 'importance': 2, 'version': 7},
      ],
    });
  });
}
