import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

class ProfileShowcaseDraftDto {
  const ProfileShowcaseDraftDto({
    this.id,
    this.selfIntro,
    this.interestTags = const [],
    this.lifestyleTags = const [],
    this.openerNote,
    this.visibilityIntent = 'private_draft',
    this.draftStatus = 'draft',
    this.moderationStatus = 'not_submitted',
    this.sourceType = 'user_confirmed',
    this.publicDisplayEligible = false,
    this.matchingScoringEligible = false,
    this.updatedAt,
    this.revision = 0,
    this.displayName = '',
    this.city = '',
    this.relationshipGoal = '',
    this.photos = const [],
    this.photoIds = const [],
    this.audiences = const [],
    this.submission,
  });

  final int? id;
  final String? selfIntro;
  final List<String> interestTags;
  final List<String> lifestyleTags;
  final String? openerNote;
  final String visibilityIntent;
  final String draftStatus;
  final String moderationStatus;
  final String sourceType;
  final bool publicDisplayEligible;
  final bool matchingScoringEligible;
  final DateTime? updatedAt;
  final int revision;
  final String displayName;
  final String city;
  final String relationshipGoal;
  final List<ShowcasePhoto> photos;
  final List<int> photoIds;
  final List<String> audiences;
  final ShowcaseSubmission? submission;

  factory ProfileShowcaseDraftDto.fromJson(Map<String, dynamic> json) {
    return ProfileShowcaseDraftDto(
      id:
          (json['id'] as num?)?.toInt() ??
          int.tryParse((json['id'] ?? '').toString()),
      selfIntro: _nullableString(json['self_intro']),
      interestTags: _stringList(json['interest_tags']),
      lifestyleTags: _stringList(json['lifestyle_tags']),
      openerNote: _nullableString(json['opener_note']),
      visibilityIntent: (json['visibility_intent'] ?? 'private_draft')
          .toString(),
      draftStatus: (json['draft_status'] ?? 'draft').toString(),
      moderationStatus: (json['moderation_status'] ?? 'not_submitted')
          .toString(),
      sourceType: (json['source_type'] ?? 'user_confirmed').toString(),
      publicDisplayEligible:
          (json['public_display_eligible'] as bool?) ?? false,
      matchingScoringEligible:
          (json['matching_scoring_eligible'] as bool?) ?? false,
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      displayName: (json['display_name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      relationshipGoal: (json['relationship_goal'] ?? '').toString(),
      photos: parseShowcasePhotos(json['photos']),
      photoIds: parseShowcasePhotoIds(json['photo_ids']),
      audiences: _stringList(json['audiences']),
      submission: parseShowcaseSubmission(json['submission']),
    );
  }

  ProfileShowcaseDraftEntity toEntity() {
    return ProfileShowcaseDraftEntity(
      id: id,
      selfIntro: selfIntro,
      interestTags: interestTags,
      lifestyleTags: lifestyleTags,
      openerNote: openerNote,
      visibilityIntent: visibilityIntent,
      draftStatus: draftStatus,
      moderationStatus: moderationStatus,
      sourceType: sourceType,
      publicDisplayEligible: publicDisplayEligible,
      matchingScoringEligible: matchingScoringEligible,
      updatedAt: updatedAt,
      revision: revision,
      displayName: displayName,
      city: city,
      relationshipGoal: relationshipGoal,
      photos: photos,
      photoIds: photoIds,
      audiences: audiences,
      submission: submission,
    );
  }
}

List<int> parseShowcasePhotoIds(Object? value) => value is List
    ? value.whereType<num>().map((id) => id.toInt()).toList(growable: false)
    : const [];

List<ShowcasePhoto> parseShowcasePhotos(Object? value) {
  if (value is! List) return const [];
  return [
    for (final photo in value.whereType<Map>())
      if (photo['id'] is num && photo['content_path'] is String)
        ShowcasePhoto(
          id: (photo['id'] as num).toInt(),
          contentPath: photo['content_path'] as String,
        ),
  ];
}

ProfileShowcaseDraftInput parseShowcaseInput(Map<String, dynamic> json) =>
    ProfileShowcaseDraftInput(
      displayName: (json['display_name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      relationshipGoal: (json['relationship_goal'] ?? '').toString(),
      selfIntro: (json['self_intro'] ?? '').toString(),
      interestTags: _stringList(json['interest_tags']),
      lifestyleTags: _stringList(json['lifestyle_tags']),
      openerNote: (json['opener_note'] ?? '').toString(),
      photoIds: parseShowcasePhotoIds(json['photo_ids']),
      audiences: _stringList(json['audiences']),
    );

ShowcaseSubmission? parseShowcaseSubmission(Object? value) {
  if (value is! Map<String, dynamic> ||
      value['id'] is! num ||
      value['revision'] is! num) {
    return null;
  }
  final snapshot = value['snapshot'];
  return ShowcaseSubmission(
    id: (value['id'] as num).toInt(),
    revision: (value['revision'] as num).toInt(),
    state: (value['state'] ?? '').toString(),
    feedback: _nullableString(value['feedback']),
    snapshot: snapshot is Map<String, dynamic>
        ? parseShowcaseInput(snapshot)
        : ProfileShowcaseDraftInput.empty,
    reviewedAt: DateTime.tryParse((value['reviewed_at'] ?? '').toString()),
  );
}

String? _nullableString(Object? value) {
  final text = (value ?? '').toString().trim();
  return text.isEmpty ? null : text;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
