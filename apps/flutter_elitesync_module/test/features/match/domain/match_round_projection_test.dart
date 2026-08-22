import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/match/data/datasource/match_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.result) : super(dio: Dio());
  final NetworkResult<Map<String, dynamic>> result;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async => result;
}

Map<String, dynamic> _envelope(String state) => {
  'data': {
    'round_id': state == 'no_round' ? null : 1,
    'round_key': state == 'no_round' ? null : 'round-1',
    'state': state,
    'state_version': state == 'no_round' ? null : 2,
    'server_now': '2026-07-12T10:00:00Z',
    'scheduled_at': null,
    'next_transition_at': '2026-07-12T12:00:00Z',
    'result_id': null,
    'no_candidate_reason_code': state == 'no_candidate' ? 'none_found' : null,
    'failure_code': state == 'failed' ? 'run_failed' : null,
    'retry_eligible': state == 'failed',
    'user_action': state == 'failed' ? 'retry' : 'wait',
    'projection_version': 2,
    'updated_at': '2026-07-12T10:00:00Z',
    'scheduled_for': null,
    'reveal_at': '2026-07-12T12:00:00Z',
    'reason_code': null,
    'next_action_code': null,
    'result': state == 'revealed'
        ? {'match_id': 7, 'partner_id': 9, 'headline': '本轮匹配已揭晓'}
        : null,
    'conversation_capability': state == 'revealed'
        ? {'can_create': true, 'can_send': true, 'can_ws': false}
        : null,
  },
  'meta': {'contract_version': 'match_round_v1'},
};

void main() {
  test('parses every business state and rejects unknown state', () {
    for (final state in MatchRoundBusinessState.values) {
      expect(MatchRoundProjection.fromJson(_envelope(state.key)).state, state);
    }
    expect(
      () => MatchRoundProjection.fromJson(_envelope('invented_waiting')),
      throwsFormatException,
    );
  });

  test('countdown uses server time and receive elapsed time', () {
    final projection = MatchRoundProjection.fromJson(
      _envelope('scheduled'),
      receivedAt: DateTime.parse('2026-07-12T08:00:00Z'),
    );
    expect(
      projection.remainingAt(DateTime.parse('2026-07-12T08:30:00Z')),
      const Duration(hours: 1, minutes: 30),
    );
  });

  test('revealed state requires a stable positive match identity', () {
    final invalid = _envelope('revealed');
    (invalid['data'] as Map<String, dynamic>)['result'] = {
      'match_id': 0,
      'partner_id': 9,
      'headline': 'invalid',
    };

    expect(() => MatchRoundProjection.fromJson(invalid), throwsFormatException);
  });

  test(
    'typed endpoint failure is not converted to local waiting state',
    () async {
      final remote = MatchRemoteDataSource(
        apiClient: _FakeApiClient(
          const NetworkFailure<Map<String, dynamic>>(
            message: 'Not found',
            statusCode: 404,
          ),
        ),
        useMock: false,
      );
      await expectLater(
        remote.getRoundProjection(),
        throwsA(
          isA<MatchRemoteException>().having(
            (error) => error.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    },
  );

  test('legacy countdown 404 is not converted to local 21:00', () async {
    final remote = MatchRemoteDataSource(
      apiClient: _FakeApiClient(
        const NetworkFailure<Map<String, dynamic>>(
          message: 'Not found',
          statusCode: 404,
        ),
      ),
      useMock: false,
    );
    await expectLater(
      remote.getCountdown(),
      throwsA(isA<MatchRemoteException>()),
    );
  });

  test(
    'legacy result uses display_score without numeric highlight fallback',
    () async {
      final remote = MatchRemoteDataSource(
        apiClient: _FakeApiClient(
          NetworkSuccess<Map<String, dynamic>>({
            'match_id': 7,
            'partner_id': 9,
            'display_score': 77,
            'final_score': 99,
            'core_scores': {'personality': 91},
            'astro_scores': {'zodiac': 88},
            'match_reasons': {
              'match': [
                {'module': 'zodiac', 'score': 88, 'reason': '节奏较一致'},
              ],
            },
          }),
        ),
        useMock: false,
      );

      final result = await remote.getResult();

      expect(result.score, 77);
      expect(result.highlights.single.containsKey('value'), isFalse);
    },
  );

  test('legacy detail keeps text without module scores or weights', () async {
    final remote = MatchRemoteDataSource(
      apiClient: _FakeApiClient(
        NetworkSuccess<Map<String, dynamic>>({
          'match_id': 7,
          'partner_id': 9,
          'match_verdict': 'compatible',
          'match_reasons': {
            'match': [
              {'module': 'zodiac', 'score': 88, 'reason': '节奏较一致'},
            ],
            'modules': [
              {'label': '属相', 'score': 88, 'weight': 0.3},
            ],
            'module_explanations': [
              {'label': '属相', 'reason': '节奏较一致', 'risk': ''},
            ],
          },
        }),
      ),
      useMock: false,
    );

    final detail = await remote.getDetail();

    expect(detail.weights, isEmpty);
    expect(detail.moduleScores, isEmpty);
    expect(detail.reasons.single, '匹配亮点｜属相：节奏较一致');
    expect(detail.moduleExplanations.single.containsKey('score'), isFalse);
    expect(detail.moduleExplanations.single.containsKey('weight'), isFalse);
  });
}
