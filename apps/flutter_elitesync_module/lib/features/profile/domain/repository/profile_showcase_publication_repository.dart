import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';

abstract class ProfileShowcasePublicationRepository {
  Future<ProfileShowcasePublicationEntity> getPublication();

  Future<ProfileShowcasePublicationEntity> publishApprovedDraft();
}
