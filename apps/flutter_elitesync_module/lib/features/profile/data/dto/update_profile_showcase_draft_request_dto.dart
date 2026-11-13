import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

class UpdateProfileShowcaseDraftRequestDto {
  const UpdateProfileShowcaseDraftRequestDto({
    required this.selfIntro,
    required this.interestTags,
    required this.lifestyleTags,
    required this.openerNote,
    this.displayName = '',
    this.city = '',
    this.relationshipGoal = '',
    this.photoIds = const [],
    this.audiences = const [],
    this.expectedRevision = 0,
  });

  factory UpdateProfileShowcaseDraftRequestDto.fromInput(
    ProfileShowcaseDraftInput input, {
    int expectedRevision = 0,
  }) {
    return UpdateProfileShowcaseDraftRequestDto(
      selfIntro: input.selfIntro.trim(),
      interestTags: _normalizeTags(input.interestTags),
      lifestyleTags: _normalizeTags(input.lifestyleTags),
      openerNote: input.openerNote.trim(),
      displayName: input.displayName.trim(),
      city: input.city.trim(),
      relationshipGoal: input.relationshipGoal.trim(),
      photoIds: input.photoIds,
      audiences: input.audiences,
      expectedRevision: expectedRevision,
    );
  }

  final String selfIntro;
  final List<String> interestTags;
  final List<String> lifestyleTags;
  final String openerNote;
  final String displayName;
  final String city;
  final String relationshipGoal;
  final List<int> photoIds;
  final List<String> audiences;
  final int expectedRevision;

  Map<String, dynamic> toJson() {
    return {
      'expected_revision': expectedRevision,
      'display_name': displayName.isEmpty ? null : displayName,
      'city': city.isEmpty ? null : city,
      'relationship_goal': relationshipGoal.isEmpty ? null : relationshipGoal,
      'photo_ids': photoIds,
      'audiences': audiences,
      'self_intro': selfIntro.isEmpty ? null : selfIntro,
      'interest_tags': interestTags,
      'lifestyle_tags': lifestyleTags,
      'opener_note': openerNote.isEmpty ? null : openerNote,
    };
  }
}

List<String> _normalizeTags(List<String> tags) {
  final seen = <String>{};
  final normalized = <String>[];
  for (final raw in tags) {
    final tag = raw.trim();
    if (tag.isEmpty || seen.contains(tag)) continue;
    seen.add(tag);
    normalized.add(tag);
  }
  return normalized;
}
