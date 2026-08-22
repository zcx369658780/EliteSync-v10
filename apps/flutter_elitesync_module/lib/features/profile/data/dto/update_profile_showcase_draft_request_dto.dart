import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

class UpdateProfileShowcaseDraftRequestDto {
  const UpdateProfileShowcaseDraftRequestDto({
    required this.selfIntro,
    required this.interestTags,
    required this.lifestyleTags,
    required this.openerNote,
  });

  factory UpdateProfileShowcaseDraftRequestDto.fromInput(
    ProfileShowcaseDraftInput input,
  ) {
    return UpdateProfileShowcaseDraftRequestDto(
      selfIntro: input.selfIntro.trim(),
      interestTags: _normalizeTags(input.interestTags),
      lifestyleTags: _normalizeTags(input.lifestyleTags),
      openerNote: input.openerNote.trim(),
    );
  }

  final String selfIntro;
  final List<String> interestTags;
  final List<String> lifestyleTags;
  final String openerNote;

  Map<String, dynamic> toJson() {
    return {
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
