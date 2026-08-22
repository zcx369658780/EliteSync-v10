import 'dart:async';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_showcase_publication_dto.dart';

class ProfileShowcasePublicationRequestException implements Exception {
  const ProfileShowcasePublicationRequestException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ProfileShowcasePublicationRemoteDataSource {
  static const _path = '/api/v1/profile/showcase/publication';
  static const Duration _requestTimeout = Duration(seconds: 4);

  const ProfileShowcasePublicationRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<ProfileShowcasePublicationDto> getPublication() async {
    final result = await apiClient.get(_path).timeout(_requestTimeout);
    return _mapPublicationResult(result);
  }

  Future<ProfileShowcasePublicationDto> publishApprovedDraft() async {
    final result = await apiClient
        .post(_path, body: const {'confirm_public_display': true})
        .timeout(_requestTimeout);
    return _mapPublicationResult(result);
  }

  ProfileShowcasePublicationDto _mapPublicationResult(
    NetworkResult<Map<String, dynamic>> result,
  ) {
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return ProfileShowcasePublicationDto.fromJson(result.data);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ProfileShowcasePublicationRequestException(
      message: failure.message,
      statusCode: failure.statusCode,
    );
  }
}
