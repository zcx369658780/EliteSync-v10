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
  Future<ProfileShowcasePublicationEntity> publishApprovedDraft() async {
    return (await remote.publishApprovedDraft()).toEntity();
  }
}
