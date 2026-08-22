class ProfileShowcaseDraftEntity {
  const ProfileShowcaseDraftEntity({
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

  bool get hasContent =>
      (selfIntro ?? '').trim().isNotEmpty ||
      interestTags.isNotEmpty ||
      lifestyleTags.isNotEmpty ||
      (openerNote ?? '').trim().isNotEmpty;

  ProfileShowcaseDraftInput toInput() {
    return ProfileShowcaseDraftInput(
      selfIntro: selfIntro ?? '',
      interestTags: interestTags,
      lifestyleTags: lifestyleTags,
      openerNote: openerNote ?? '',
    );
  }
}

class ProfileShowcaseDraftInput {
  const ProfileShowcaseDraftInput({
    this.selfIntro = '',
    this.interestTags = const [],
    this.lifestyleTags = const [],
    this.openerNote = '',
  });

  final String selfIntro;
  final List<String> interestTags;
  final List<String> lifestyleTags;
  final String openerNote;

  static const empty = ProfileShowcaseDraftInput();

  bool get hasContent =>
      selfIntro.trim().isNotEmpty ||
      interestTags.isNotEmpty ||
      lifestyleTags.isNotEmpty ||
      openerNote.trim().isNotEmpty;

  ProfileShowcaseDraftInput copyWith({
    String? selfIntro,
    List<String>? interestTags,
    List<String>? lifestyleTags,
    String? openerNote,
  }) {
    return ProfileShowcaseDraftInput(
      selfIntro: selfIntro ?? this.selfIntro,
      interestTags: interestTags ?? this.interestTags,
      lifestyleTags: lifestyleTags ?? this.lifestyleTags,
      openerNote: openerNote ?? this.openerNote,
    );
  }
}
