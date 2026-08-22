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
    ProfileShowcaseDraftInput input,
  ) async {
    final request = UpdateProfileShowcaseDraftRequestDto.fromInput(input);
    return (await remote.saveDraft(request))?.toEntity();
  }

  @override
  Future<ProfileShowcaseDraftEntity?> submitForReview() async {
    return (await remote.submitForReview())?.toEntity();
  }

  @override
  Future<void> clearDraft() => remote.clearDraft();
}
