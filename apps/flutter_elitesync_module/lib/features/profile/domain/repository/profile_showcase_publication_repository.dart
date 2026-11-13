import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';

abstract class ProfileShowcasePublicationRepository {
  Future<ProfileShowcasePublicationEntity> getPublication();

  Future<ProfileShowcasePublicationEntity> publishApprovedDraft({
    int expectedRevision = 0,
    int publicationRevision = 0,
  });

  Future<ProfileShowcasePublicationEntity> withdraw({
    required int expectedRevision,
  });
}
