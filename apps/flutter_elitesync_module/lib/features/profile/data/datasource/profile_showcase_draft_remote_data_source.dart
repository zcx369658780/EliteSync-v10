import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_showcase_draft_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/update_profile_showcase_draft_request_dto.dart';

class ProfileShowcaseDraftRequestException implements Exception {
  const ProfileShowcaseDraftRequestException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ProfileShowcaseDraftRemoteDataSource {
  static const _path = '/api/v1/profile/showcase/draft';
  static const Duration _requestTimeout = Duration(seconds: 4);

  const ProfileShowcaseDraftRemoteDataSource({
    required this.apiClient,
    this.isCurrent,
  });

  final ApiClient apiClient;
  final bool Function()? isCurrent;
  Options get _options => Options(
    extra: {if (isCurrent != null) requestSessionGuardKey: isCurrent},
  );

  Future<ProfileShowcaseDraftDto?> getDraft() async {
    final result = await apiClient
        .get(_path, options: _options)
        .timeout(_requestTimeout);
    return _mapDraftResult(result);
  }

  Future<ProfileShowcaseDraftDto?> saveDraft(
    UpdateProfileShowcaseDraftRequestDto request,
  ) async {
    final result = await apiClient
        .put(_path, body: request.toJson(), options: _options)
        .timeout(_requestTimeout);
    return _mapDraftResult(result);
  }

  Future<ProfileShowcaseDraftDto?> submitForReview({
    int expectedRevision = 0,
  }) async {
    final result = await apiClient
        .post(
          '$_path/submit-review',
          body: {'expected_revision': expectedRevision},
          options: _options,
        )
        .timeout(_requestTimeout);
    return _mapDraftResult(result);
  }

  Future<void> clearDraft({int expectedRevision = 0}) async {
    final result = await apiClient
        .delete(
          _path,
          body: {'expected_revision': expectedRevision},
          options: _options,
        )
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) return;
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ProfileShowcaseDraftRequestException(
      message: failure.message,
      statusCode: failure.statusCode,
    );
  }

  Future<ProfileShowcaseDraftDto?> uploadPhoto({
    required String path,
    required String name,
    required int expectedRevision,
    required String clientUploadId,
  }) async {
    final file = await MultipartFile.fromFile(path, filename: name);
    if (isCurrent != null && !isCurrent!()) {
      throw const ProfileShowcaseDraftRequestException(message: '登录会话已变化');
    }
    final result = await apiClient
        .post(
          '/api/v1/profile/showcase/photos',
          body: FormData.fromMap({
            'photo': file,
            'expected_revision': expectedRevision,
            'client_upload_id': clientUploadId,
          }),
          options: _options,
        )
        .timeout(const Duration(seconds: 30));
    return _mapDraftResult(result);
  }

  ProfileShowcaseDraftDto? _mapDraftResult(
    NetworkResult<Map<String, dynamic>> result,
  ) {
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final draft = result.data['draft'];
      if (draft is Map<String, dynamic>) {
        return ProfileShowcaseDraftDto.fromJson({
          ...draft,
          'revision': result.data['revision'] ?? draft['revision'],
          'submission': result.data['submission'],
        });
      }
      if ((result.data['revision'] as num? ?? 0) > 0) {
        return ProfileShowcaseDraftDto.fromJson({
          'revision': result.data['revision'],
          'draft_status': 'cleared',
          'submission': result.data['submission'],
        });
      }
      return null;
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ProfileShowcaseDraftRequestException(
      message: failure.message,
      statusCode: failure.statusCode,
    );
  }
}
