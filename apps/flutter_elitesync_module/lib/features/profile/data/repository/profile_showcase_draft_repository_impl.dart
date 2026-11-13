import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_draft_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/update_profile_showcase_draft_request_dto.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_draft_repository.dart';

class ProfileShowcaseDraftRepositoryImpl
    implements ProfileShowcaseDraftRepository {
  const ProfileShowcaseDraftRepositoryImpl({required this.remote});

  final ProfileShowcaseDraftRemoteDataSource remote;

  @override
  Future<ProfileShowcaseDraftEntity?> getDraft() async {
    return (await remote.getDraft())?.toEntity();
  }

  @override
  Future<ProfileShowcaseDraftEntity?> saveDraft(
    ProfileShowcaseDraftInput input, {
    int expectedRevision = 0,
  }) async {
    final request = UpdateProfileShowcaseDraftRequestDto.fromInput(
      input,
      expectedRevision: expectedRevision,
    );
    return (await remote.saveDraft(request))?.toEntity();
  }

  @override
  Future<ProfileShowcaseDraftEntity?> submitForReview({
    int expectedRevision = 0,
  }) async {
    return (await remote.submitForReview(
      expectedRevision: expectedRevision,
    ))?.toEntity();
  }

  @override
  Future<void> clearDraft({int expectedRevision = 0}) =>
      remote.clearDraft(expectedRevision: expectedRevision);

  @override
  Future<ProfileShowcaseDraftEntity?> uploadPhoto({
    required String path,
    required String name,
    required int expectedRevision,
    required String clientUploadId,
  }) async => (await remote.uploadPhoto(
    path: path,
    name: name,
    expectedRevision: expectedRevision,
    clientUploadId: clientUploadId,
  ))?.toEntity();
}
