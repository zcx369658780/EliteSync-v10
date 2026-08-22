import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

class ProfileShowcasePublicationEntity {
  const ProfileShowcasePublicationEntity({
    this.id,
    this.sourceDraftId,
    this.publicationStatus = 'not_published',
    this.moderationStatus,
    this.publicDisplayEligible = false,
    this.matchingScoringEligible = false,
    this.publicFields = ProfileShowcaseDraftInput.empty,
    this.publishedAt,
    this.updatedAt,
  });

  final int? id;
  final int? sourceDraftId;
  final String publicationStatus;
  final String? moderationStatus;
  final bool publicDisplayEligible;
  final bool matchingScoringEligible;
  final ProfileShowcaseDraftInput publicFields;
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  bool get isPublished =>
      publicationStatus == 'published' &&
      publicDisplayEligible &&
      matchingScoringEligible == false;

  bool get isUnavailable => publicationStatus == 'unavailable';

  static const notPublished = ProfileShowcasePublicationEntity();
}
