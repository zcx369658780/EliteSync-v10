import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_publication_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_publication_repository.dart';

class ProfileShowcasePublicationRepositoryImpl
    implements ProfileShowcasePublicationRepository {
  const ProfileShowcasePublicationRepositoryImpl({required this.remote});

  final ProfileShowcasePublicationRemoteDataSource remote;

  @override
  Future<ProfileShowcasePublicationEntity> getPublication() async {
    return (await remote.getPublication()).toEntity();
  }

  @override
  Future<ProfileShowcasePublicationEntity> publishApprovedDraft({
    int expectedRevision = 0,
    int publicationRevision = 0,
  }) async {
    return (await remote.publishApprovedDraft(
      expectedRevision: expectedRevision,
      publicationRevision: publicationRevision,
    )).toEntity();
  }

  @override
  Future<ProfileShowcasePublicationEntity> withdraw({
    required int expectedRevision,
  }) async =>
      (await remote.withdraw(expectedRevision: expectedRevision)).toEntity();
}
