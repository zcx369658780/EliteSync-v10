import 'dart:async';

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

  const ProfileShowcaseDraftRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<ProfileShowcaseDraftDto?> getDraft() async {
    final result = await apiClient.get(_path).timeout(_requestTimeout);
    return _mapDraftResult(result);
  }

  Future<ProfileShowcaseDraftDto?> saveDraft(
    UpdateProfileShowcaseDraftRequestDto request,
  ) async {
    final result = await apiClient
        .put(_path, body: request.toJson())
        .timeout(_requestTimeout);
    return _mapDraftResult(result);
  }

  Future<ProfileShowcaseDraftDto?> submitForReview() async {
    final result = await apiClient
        .post('$_path/submit-review')
        .timeout(_requestTimeout);
    return _mapDraftResult(result);
  }

  Future<void> clearDraft() async {
    final result = await apiClient.delete(_path).timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) return;
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ProfileShowcaseDraftRequestException(
      message: failure.message,
      statusCode: failure.statusCode,
    );
  }

  ProfileShowcaseDraftDto? _mapDraftResult(
    NetworkResult<Map<String, dynamic>> result,
  ) {
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final draft = result.data['draft'];
      if (draft is Map<String, dynamic>) {
        return ProfileShowcaseDraftDto.fromJson(draft);
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
