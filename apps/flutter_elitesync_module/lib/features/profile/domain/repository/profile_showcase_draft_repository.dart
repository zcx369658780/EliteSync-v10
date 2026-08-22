import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

abstract class ProfileShowcaseDraftRepository {
  Future<ProfileShowcaseDraftEntity?> getDraft();

  Future<ProfileShowcaseDraftEntity?> saveDraft(
    ProfileShowcaseDraftInput input,
  );

  Future<ProfileShowcaseDraftEntity?> submitForReview();

  Future<void> clearDraft();
}
