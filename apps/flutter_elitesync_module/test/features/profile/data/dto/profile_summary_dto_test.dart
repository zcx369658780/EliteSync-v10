import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_detail_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_summary_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';

void main() {
  test('profile summary dto maps birth place coordinates', () {
    const json = <String, dynamic>{
      'nickname': 'Mia',
      'birthday': '1998-04-20',
      'birth_time': '09:30',
      'birth_place': '武汉',
      'birth_lat': 30.5928,
      'birth_lng': 114.3055,
      'city': '武汉',
      'target': 'dating',
      'verified': true,
      'moderation_status': 'normal',
      'completion': 0.9,
      'tags': ['生日已确认'],
    };

    final dto = ProfileSummaryDto.fromJson(json);
    final summary = const ProfileMapper().toSummary(dto);

    expect(dto.birthLat, 30.5928);
    expect(dto.birthLng, 114.3055);
    expect(summary.birthLat, 30.5928);
    expect(summary.birthLng, 114.3055);
    expect(summary.birthPlace, '武汉');
  });

  test('basic profile supports DECIMAL strings in summary and edit detail', () {
    const json = <String, dynamic>{
      'name': 'Fixture',
      'birthday': '2001-02-03',
      'gender': 'female',
      'city': '当前城市',
      'relationship_goal': 'friendship',
      'birth_time': '08:12',
      'birth_place': '出生地点',
      'birth_lat': '-12.3456789',
      'birth_lng': '0.0000000',
    };

    final summary = ProfileSummaryDto.fromJson(json);
    final detail = ProfileDetailDto.fromJson(json);
    expect(summary.birthLat, -12.3456789);
    expect(summary.birthLng, 0);
    expect(detail.birthLat, -12.3456789);
    expect(detail.birthLng, 0);
    expect(detail.birthday, '2001-02-03');
    expect(detail.birthTime, '08:12');
    expect(detail.gender, 'female');
    expect(detail.city, '当前城市');
    expect(detail.birthPlace, '出生地点');
    expect(detail.target, 'friendship');
  });

  test(
    'profile coordinates prefer canonical values and reject invalid ones',
    () {
      final summary = ProfileSummaryDto.fromJson({
        'birth_lat': 0,
        'private_birth_lat': '32.0000000',
        'birth_lng': null,
        'private_birth_lng': '-180.0000000',
      });
      expect(summary.birthLat, 0);
      expect(summary.birthLng, -180);
      final detail = ProfileDetailDto.fromJson({
        'birth_lat': '90.0000001',
        'birth_lng': 'Infinity',
      });
      expect(detail.birthLat, isNull);
      expect(detail.birthLng, isNull);
    },
  );

  test(
    'profile summary dto parses canonical readiness and publication truth',
    () {
      final dto = ProfileSummaryDto.fromJson({
        'profile_readiness': {
          'contract_version': 'profile_readiness_v1',
          'matching_eligibility': {
            'eligible': false,
            'reason_code': 'questionnaire_incomplete',
            'required_answer_count': 10,
            'answered_answer_count': 8,
            'missing_answer_count': 2,
            'next_action_code': 'complete_questionnaire',
          },
          'showcase': {
            'draft_state': 'private_draft',
            'review_status': 'approved',
            'publication_status': 'published',
            'published_version_current': false,
            'affects_matching_eligibility': false,
          },
        },
      });

      expect(dto.readiness.hasServerTruth, isTrue);
      expect(dto.readiness.matchingEligibility.eligible, isFalse);
      expect(dto.readiness.matchingEligibility.missingAnswerCount, 2);
      expect(dto.readiness.showcase.publicationStatus, 'published');
      expect(dto.readiness.showcase.publishedVersionCurrent, isFalse);
      expect(dto.readiness.showcase.affectsMatchingEligibility, isFalse);
    },
  );

  test(
    'profile summary dto never infers eligibility from a missing contract',
    () {
      final dto = ProfileSummaryDto.fromJson(const {});

      expect(dto.readiness.hasServerTruth, isFalse);
      expect(dto.readiness.matchingEligibility.eligible, isFalse);
      expect(dto.readiness.matchingEligibility.reasonCode, 'unavailable');
      expect(dto.completion, 0);
    },
  );
}
