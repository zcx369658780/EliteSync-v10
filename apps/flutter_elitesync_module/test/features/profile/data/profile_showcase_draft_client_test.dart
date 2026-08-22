import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_draft_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_showcase_draft_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/update_profile_showcase_draft_request_dto.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: Dio());

  String? method;
  String? path;
  Object? body;
  NetworkResult<Map<String, dynamic>> nextResult = const NetworkSuccess(
    <String, dynamic>{'ok': true, 'draft': null},
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

  @override
  Future<NetworkResult<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    method = 'PUT';
    this.path = path;
    this.body = body;
    return nextResult;
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    method = 'DELETE';
    this.path = path;
    return nextResult;
  }
}

void main() {
  test('draft dto maps supported fields and safety metadata', () {
    final dto = ProfileShowcaseDraftDto.fromJson({
      'id': 7,
      'self_intro': '最近喜欢慢慢认识人',
      'interest_tags': ['咖啡', '徒步'],
      'lifestyle_tags': ['周末早起'],
      'opener_note': '可以从周末计划聊起',
      'visibility_intent': 'private_draft',
      'draft_status': 'draft',
      'moderation_status': 'not_submitted',
      'source_type': 'user_confirmed',
      'public_display_eligible': false,
      'matching_scoring_eligible': false,
      'updated_at': '2026-06-15T10:00:00+00:00',
    });

    final entity = dto.toEntity();

    expect(entity.id, 7);
    expect(entity.selfIntro, '最近喜欢慢慢认识人');
    expect(entity.interestTags, ['咖啡', '徒步']);
    expect(entity.lifestyleTags, ['周末早起']);
    expect(entity.openerNote, '可以从周末计划聊起');
    expect(entity.visibilityIntent, 'private_draft');
    expect(entity.moderationStatus, 'not_submitted');
    expect(entity.publicDisplayEligible, isFalse);
    expect(entity.matchingScoringEligible, isFalse);
  });

  test('draft dto preserves owner visible review result statuses', () {
    for (final status in const [
      'pending',
      'approved',
      'rejected',
      'needs_revision',
      'manual_review_required',
      'error',
    ]) {
      final dto = ProfileShowcaseDraftDto.fromJson({
        'id': 8,
        'self_intro': '私有草稿',
        'moderation_status': status,
        'visibility_intent': 'private_draft',
        'public_display_eligible': false,
        'matching_scoring_eligible': false,
      });

      final entity = dto.toEntity();

      expect(entity.moderationStatus, status);
      expect(entity.visibilityIntent, 'private_draft');
      expect(entity.publicDisplayEligible, isFalse);
      expect(entity.matchingScoringEligible, isFalse);
    }
  });

  test('request dto serializes only accepted private draft fields', () {
    final request = UpdateProfileShowcaseDraftRequestDto.fromInput(
      const ProfileShowcaseDraftInput(
        selfIntro: '  你好  ',
        interestTags: ['咖啡', '咖啡', ''],
        lifestyleTags: ['周末早起'],
        openerNote: '  从咖啡聊起  ',
      ),
    ).toJson();

    expect(request, {
      'self_intro': '你好',
      'interest_tags': ['咖啡'],
      'lifestyle_tags': ['周末早起'],
      'opener_note': '从咖啡聊起',
    });
    expect(request.containsKey('visibility_intent'), isFalse);
    expect(request.containsKey('moderation_status'), isFalse);
    expect(request.containsKey('public_display_eligible'), isFalse);
    expect(request.containsKey('matching_scoring_eligible'), isFalse);
    expect(request.containsKey('user_id'), isFalse);
  });

  test('remote data source uses accepted draft methods and path', () async {
    final client = _FakeApiClient();
    final remote = ProfileShowcaseDraftRemoteDataSource(apiClient: client);

    await remote.getDraft();
    expect(client.method, 'GET');
    expect(client.path, '/api/v1/profile/showcase/draft');

    await remote.saveDraft(
      UpdateProfileShowcaseDraftRequestDto.fromInput(
        const ProfileShowcaseDraftInput(selfIntro: '保存私有草稿'),
      ),
    );
    expect(client.method, 'PUT');
    expect(client.path, '/api/v1/profile/showcase/draft');
    expect(client.body, containsPair('self_intro', '保存私有草稿'));

    await remote.clearDraft();
    expect(client.method, 'DELETE');
    expect(client.path, '/api/v1/profile/showcase/draft');

    await remote.submitForReview();
    expect(client.method, 'POST');
    expect(client.path, '/api/v1/profile/showcase/draft/submit-review');
  });

  test('remote data source maps failure without claiming saved', () async {
    final client = _FakeApiClient()
      ..nextResult = const NetworkFailure<Map<String, dynamic>>(
        message: 'Unauthorized',
        statusCode: 401,
      );
    final remote = ProfileShowcaseDraftRemoteDataSource(apiClient: client);

    expect(
      remote.getDraft,
      throwsA(isA<ProfileShowcaseDraftRequestException>()),
    );
  });
}
