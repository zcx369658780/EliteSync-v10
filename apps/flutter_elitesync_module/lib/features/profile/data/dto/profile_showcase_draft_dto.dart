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
    );
  }
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
