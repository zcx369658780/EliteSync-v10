const showcaseAudienceLabels = <String, String>{
  'friends': '好友',
  'contacts': '有效匹配或获准联系的对象',
  'relationship': '已授权分享的正式关系对象',
};

class ShowcasePhoto {
  const ShowcasePhoto({required this.id, required this.contentPath});

  final int id;
  final String contentPath;
}

class ShowcaseSubmission {
  const ShowcaseSubmission({
    required this.id,
    required this.revision,
    required this.state,
    required this.snapshot,
    this.feedback,
    this.reviewedAt,
  });

  final int id;
  final int revision;
  final String state;
  final String? feedback;
  final ProfileShowcaseDraftInput snapshot;
  final DateTime? reviewedAt;
}

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

  bool get hasContent =>
      (selfIntro ?? '').trim().isNotEmpty ||
      interestTags.isNotEmpty ||
      lifestyleTags.isNotEmpty ||
      (openerNote ?? '').trim().isNotEmpty ||
      displayName.trim().isNotEmpty ||
      city.trim().isNotEmpty ||
      relationshipGoal.trim().isNotEmpty ||
      photoIds.isNotEmpty;

  ProfileShowcaseDraftInput toInput() {
    return ProfileShowcaseDraftInput(
      selfIntro: selfIntro ?? '',
      interestTags: interestTags,
      lifestyleTags: lifestyleTags,
      openerNote: openerNote ?? '',
      displayName: displayName,
      city: city,
      relationshipGoal: relationshipGoal,
      photoIds: photoIds,
      audiences: audiences,
    );
  }
}

class ProfileShowcaseDraftInput {
  const ProfileShowcaseDraftInput({
    this.selfIntro = '',
    this.interestTags = const [],
    this.lifestyleTags = const [],
    this.openerNote = '',
    this.displayName = '',
    this.city = '',
    this.relationshipGoal = '',
    this.photoIds = const [],
    this.audiences = const [],
  });

  final String selfIntro;
  final List<String> interestTags;
  final List<String> lifestyleTags;
  final String openerNote;
  final String displayName;
  final String city;
  final String relationshipGoal;
  final List<int> photoIds;
  final List<String> audiences;

  static const empty = ProfileShowcaseDraftInput();

  bool get hasContent =>
      selfIntro.trim().isNotEmpty ||
      interestTags.isNotEmpty ||
      lifestyleTags.isNotEmpty ||
      openerNote.trim().isNotEmpty ||
      displayName.trim().isNotEmpty ||
      city.trim().isNotEmpty ||
      relationshipGoal.trim().isNotEmpty ||
      photoIds.isNotEmpty;

  ProfileShowcaseDraftInput copyWith({
    String? selfIntro,
    List<String>? interestTags,
    List<String>? lifestyleTags,
    String? openerNote,
    String? displayName,
    String? city,
    String? relationshipGoal,
    List<int>? photoIds,
    List<String>? audiences,
  }) {
    return ProfileShowcaseDraftInput(
      selfIntro: selfIntro ?? this.selfIntro,
      interestTags: interestTags ?? this.interestTags,
      lifestyleTags: lifestyleTags ?? this.lifestyleTags,
      openerNote: openerNote ?? this.openerNote,
      displayName: displayName ?? this.displayName,
      city: city ?? this.city,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      photoIds: photoIds ?? this.photoIds,
      audiences: audiences ?? this.audiences,
    );
  }
}
