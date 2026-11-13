import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_showcase_draft_dto.dart';

class ProfileShowcasePublicationDto {
  const ProfileShowcasePublicationDto({
    this.id,
    this.sourceDraftId,
    this.publicationStatus = 'not_published',
    this.moderationStatus,
    this.publicDisplayEligible = false,
    this.matchingScoringEligible = false,
    this.publicFields = ProfileShowcaseDraftInput.empty,
    this.publishedAt,
    this.updatedAt,
    this.revision = 0,
    this.sourceRevision = 0,
    this.photos = const [],
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
  final int revision;
  final int sourceRevision;
  final List<ShowcasePhoto> photos;

  factory ProfileShowcasePublicationDto.fromJson(Map<String, dynamic> json) {
    final publication = json['publication'];
    final copyState = json['copy_state'];
    final fallbackStatus = copyState is Map<String, dynamic>
        ? (copyState['publication_status'] ?? 'not_published').toString()
        : 'not_published';

    if (publication is! Map<String, dynamic>) {
      return ProfileShowcasePublicationDto(
        publicationStatus: _safeEmptyStatus(fallbackStatus),
      );
    }

    final publicDisplayEligible =
        publication['public_display_eligible'] as bool? ?? false;
    final matchingScoringEligible =
        publication['matching_scoring_eligible'] as bool? ?? false;
    final rawStatus = (publication['publication_status'] ?? fallbackStatus)
        .toString();
    final safeStatus =
        rawStatus == 'published' &&
            publicDisplayEligible &&
            matchingScoringEligible == false
        ? 'published'
        : _safeEmptyStatus(rawStatus);
    final publicFields = publication['public_fields'];

    return ProfileShowcasePublicationDto(
      id: _intValue(publication['id']),
      sourceDraftId: _intValue(publication['source_draft_id']),
      publicationStatus: safeStatus,
      moderationStatus: _nullableString(publication['moderation_status']),
      publicDisplayEligible: safeStatus == 'published',
      matchingScoringEligible: false,
      publicFields: publicFields is Map<String, dynamic>
          ? parseShowcaseInput(publicFields)
          : ProfileShowcaseDraftInput.empty,
      revision: _intValue(publication['revision']) ?? 0,
      sourceRevision: _intValue(publication['source_revision']) ?? 0,
      photos: publicFields is Map
          ? parseShowcasePhotos(publicFields['photos'])
          : const [],
      publishedAt: DateTime.tryParse(
        (publication['published_at'] ?? '').toString(),
      ),
      updatedAt: DateTime.tryParse(
        (publication['updated_at'] ?? '').toString(),
      ),
    );
  }

  ProfileShowcasePublicationEntity toEntity() {
    return ProfileShowcasePublicationEntity(
      id: id,
      sourceDraftId: sourceDraftId,
      publicationStatus: publicationStatus,
      moderationStatus: moderationStatus,
      publicDisplayEligible: publicDisplayEligible,
      matchingScoringEligible: matchingScoringEligible,
      publicFields: publicFields,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
      revision: revision,
      sourceRevision: sourceRevision,
      photos: photos,
    );
  }
}

String _safeEmptyStatus(String value) {
  return switch (value) {
    'not_published' || 'unavailable' || 'withdrawn' => value,
    _ => 'unavailable',
  };
}

int? _intValue(Object? value) {
  return (value as num?)?.toInt() ?? int.tryParse((value ?? '').toString());
}

String _stringValue(Object? value) => (value ?? '').toString().trim();

String? _nullableString(Object? value) {
  final text = _stringValue(value);
  return text.isEmpty ? null : text;
}
