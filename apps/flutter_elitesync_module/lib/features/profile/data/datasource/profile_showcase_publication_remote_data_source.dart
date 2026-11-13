import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';

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

  const ProfileShowcasePublicationRemoteDataSource({
    required this.apiClient,
    this.isCurrent,
  });

  final ApiClient apiClient;
  final bool Function()? isCurrent;
  Options get _options => Options(
    extra: {if (isCurrent != null) requestSessionGuardKey: isCurrent},
  );

  Future<ProfileShowcasePublicationDto> getPublication() async {
    final result = await apiClient
        .get(_path, options: _options)
        .timeout(_requestTimeout);
    return _mapPublicationResult(result);
  }

  Future<ProfileShowcasePublicationDto> publishApprovedDraft({
    int expectedRevision = 0,
    int publicationRevision = 0,
  }) async {
    final result = await apiClient
        .post(
          _path,
          body: {
            'confirm_public_display': true,
            'expected_revision': expectedRevision,
            'publication_revision': publicationRevision,
          },
          options: _options,
        )
        .timeout(_requestTimeout);
    return _mapPublicationResult(result);
  }

  Future<ProfileShowcasePublicationDto> withdraw({
    required int expectedRevision,
  }) async {
    final result = await apiClient
        .delete(
          _path,
          body: {'expected_revision': expectedRevision},
          options: _options,
        )
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
