import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_publication_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_showcase_publication_dto.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: Dio());

  String? method;
  String? path;
  Object? body;
  NetworkResult<Map<String, dynamic>> nextResult = const NetworkSuccess(
    <String, dynamic>{
      'ok': true,
      'publication': null,
      'copy_state': {
        'publication_status': 'not_published',
        'public_display_eligible': false,
        'matching_scoring_eligible': false,
      },
    },
  );

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    method = 'GET';
    this.path = path;
    return nextResult;
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    method = 'POST';
    this.path = path;
    this.body = body;
    return nextResult;
  }
}

void main() {
  test('publication dto maps published owner projection safely', () {
    final dto = ProfileShowcasePublicationDto.fromJson({
      'ok': true,
      'publication': {
        'id': 9,
        'publication_status': 'published',
        'source_draft_id': 6,
        'moderation_status': 'approved',
        'public_display_eligible': true,
        'matching_scoring_eligible': false,
        'public_fields': {
          'self_intro': '公开展示的一句话',
          'interest_tags': ['咖啡'],
          'lifestyle_tags': ['慢生活'],
          'opener_note': '可以从咖啡聊起',
        },
        'published_at': '2026-06-16T08:00:00+00:00',
      },
    });

    final entity = dto.toEntity();

    expect(entity.isPublished, isTrue);
    expect(entity.id, 9);
    expect(entity.sourceDraftId, 6);
    expect(entity.moderationStatus, 'approved');
    expect(entity.publicFields.selfIntro, '公开展示的一句话');
    expect(entity.publicDisplayEligible, isTrue);
    expect(entity.matchingScoringEligible, isFalse);
  });

  test('publication dto fails closed for unsafe published scoring payload', () {
    final dto = ProfileShowcasePublicationDto.fromJson({
      'ok': true,
      'publication': {
        'publication_status': 'published',
        'public_display_eligible': true,
        'matching_scoring_eligible': true,
      },
    });

    final entity = dto.toEntity();

    expect(entity.isPublished, isFalse);
    expect(entity.publicationStatus, 'unavailable');
    expect(entity.publicDisplayEligible, isFalse);
    expect(entity.matchingScoringEligible, isFalse);
  });

  test(
    'remote data source uses accepted publication path and confirmation',
    () async {
      final client = _FakeApiClient();
      final remote = ProfileShowcasePublicationRemoteDataSource(
        apiClient: client,
      );

      await remote.getPublication();
      expect(client.method, 'GET');
      expect(client.path, '/api/v1/profile/showcase/publication');

      await remote.publishApprovedDraft();
      expect(client.method, 'POST');
      expect(client.path, '/api/v1/profile/showcase/publication');
      expect(client.body, {'confirm_public_display': true});
    },
  );

  test('remote data source maps failure without claiming published', () {
    final client = _FakeApiClient()
      ..nextResult = const NetworkFailure<Map<String, dynamic>>(
        message: 'Validation failed',
        statusCode: 422,
      );
    final remote = ProfileShowcasePublicationRemoteDataSource(
      apiClient: client,
    );

    expect(
      remote.publishApprovedDraft,
      throwsA(isA<ProfileShowcasePublicationRequestException>()),
    );
  });
}
