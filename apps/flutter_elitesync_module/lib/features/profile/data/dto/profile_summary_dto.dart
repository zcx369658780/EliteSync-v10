import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';

class ProfileSummaryDto {
  const ProfileSummaryDto({
    required this.nickname,
    required this.birthday,
    required this.birthTime,
    required this.birthPlace,
    this.birthLat,
    this.birthLng,
    required this.city,
    required this.target,
    required this.verified,
    required this.moderationStatus,
    required this.moderationNote,
    required this.completion,
    required this.tags,
    required this.readiness,
  });
  final String nickname;
  final String birthday;
  final String birthTime;
  final String? birthPlace;
  final double? birthLat;
  final double? birthLng;
  final String city;
  final String target;
  final bool verified;
  final String moderationStatus;
  final String? moderationNote;
  final double completion;
  final List<String> tags;
  final ProfileReadinessEntity readiness;

  factory ProfileSummaryDto.fromJson(Map<String, dynamic> json) =>
      ProfileSummaryDto(
        nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
        birthday: (json['birthday'] ?? '').toString(),
        birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
        birthPlace:
            (json['birth_place'] ?? json['private_birth_place'] ?? '')
                .toString()
                .isEmpty
            ? null
            : (json['birth_place'] ?? json['private_birth_place'] ?? '')
                  .toString(),
        birthLat:
            (json['birth_lat'] as num?)?.toDouble() ??
            (json['private_birth_lat'] as num?)?.toDouble(),
        birthLng:
            (json['birth_lng'] as num?)?.toDouble() ??
            (json['private_birth_lng'] as num?)?.toDouble(),
        city: (json['city'] ?? '').toString(),
        target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
        verified:
            (json['verified'] as bool?) ??
            (json['realname_verified'] as bool?) ??
            false,
        moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
        moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
            ? null
            : (json['moderation_note'] ?? '').toString(),
        completion: (json['completion'] as num?)?.toDouble() ?? 0,
        tags: (json['tags'] as List<dynamic>? ?? const ['本地草稿待确认'])
            .map((e) => e.toString())
            .toList(),
        readiness: _readiness(json['profile_readiness']),
      );
}

ProfileReadinessEntity _readiness(dynamic value) {
  if (value is! Map) return const ProfileReadinessEntity();
  final json = value.map((key, value) => MapEntry(key.toString(), value));
  final matchingRaw = json['matching_eligibility'];
  final showcaseRaw = json['showcase'];
  final matching = matchingRaw is Map
      ? matchingRaw.map((key, value) => MapEntry(key.toString(), value))
      : const <String, dynamic>{};
  final showcase = showcaseRaw is Map
      ? showcaseRaw.map((key, value) => MapEntry(key.toString(), value))
      : const <String, dynamic>{};
  return ProfileReadinessEntity(
    contractVersion: (json['contract_version'] ?? '').toString(),
    matchingEligibility: MatchingEligibilityEntity(
      eligible: matching['eligible'] == true,
      reasonCode: (matching['reason_code'] ?? 'unavailable').toString(),
      requiredAnswerCount:
          (matching['required_answer_count'] as num?)?.toInt() ?? 0,
      answeredAnswerCount:
          (matching['answered_answer_count'] as num?)?.toInt() ?? 0,
      missingAnswerCount:
          (matching['missing_answer_count'] as num?)?.toInt() ?? 0,
      nextActionCode: (matching['next_action_code'] ?? 'refresh').toString(),
    ),
    showcase: ShowcaseReadinessEntity(
      draftState: (showcase['draft_state'] ?? 'none').toString(),
      reviewStatus: (showcase['review_status'] ?? 'not_submitted').toString(),
      publicationStatus: (showcase['publication_status'] ?? 'not_published')
          .toString(),
      publishedVersionCurrent: showcase['published_version_current'] == true,
      affectsMatchingEligibility:
          showcase['affects_matching_eligibility'] == true,
    ),
  );
}
