import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

abstract class ProfileShowcaseDraftRepository {
  Future<ProfileShowcaseDraftEntity?> getDraft();

  Future<ProfileShowcaseDraftEntity?> saveDraft(
    ProfileShowcaseDraftInput input, {
    int expectedRevision = 0,
  });

  Future<ProfileShowcaseDraftEntity?> submitForReview({
    int expectedRevision = 0,
  });

  Future<void> clearDraft({int expectedRevision = 0});

  Future<ProfileShowcaseDraftEntity?> uploadPhoto({
    required String path,
    required String name,
    required int expectedRevision,
    required String clientUploadId,
  });
}
