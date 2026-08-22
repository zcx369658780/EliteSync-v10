<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use App\Services\ZiweiCanonicalService;
use Tests\TestCase;

class ZiweiCanonicalServiceTest extends TestCase
{
    public function test_canonicalize_returns_structured_ziwei_profile(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));
        $result = $service->canonicalize([
            'birthday' => '1996-08-18',
            'birth_time' => '10:30',
            'birth_place' => '河南南阳',
            'gender' => 'male',
            'user_id' => 1001,
            'platform' => 'android',
        ]);

        $this->assertArrayHasKey('ziwei', $result);
        $ziwei = (array) ($result['ziwei'] ?? []);
        $this->assertSame('ziwei_seed_estimate', (string) ($ziwei['engine'] ?? ''));
        $this->assertSame('approximate_not_validated', (string) ($ziwei['precision'] ?? ''));
        $this->assertSame('not_validated', (string) ($ziwei['external_oracle_status'] ?? ''));
        $this->assertTrue((bool) ($ziwei['display_only'] ?? false));
        $this->assertSame('excluded_from_core_matching', (string) ($ziwei['scoring_status'] ?? ''));
        $this->assertLessThanOrEqual(0.32, (float) ($ziwei['confidence'] ?? 1));
        $this->assertSame('ziwei_placeholder_not_validated', (string) ($result['accuracy'] ?? ''));
        $this->assertStringContainsString('不作为真实紫微排盘结论', (string) ($ziwei['disclaimer'] ?? ''));
        $this->assertNotSame('ziwei_canonical_server', (string) ($ziwei['engine'] ?? ''));
        $this->assertNotSame('full_birth_data', (string) ($ziwei['precision'] ?? ''));
        $this->assertNotEmpty($ziwei['life_palace'] ?? null);
        $this->assertNotEmpty($ziwei['body_palace'] ?? null);
        $this->assertIsArray($ziwei['palaces'] ?? null);
        $this->assertNotEmpty($ziwei['palaces'] ?? []);
        $this->assertArrayHasKey('summary', $ziwei);
        $this->assertArrayHasKey('major_themes', $ziwei);
    }

    public function test_cece_p0_fixture_returns_oracle_palaces_transformations_and_statuses(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $result = $service->canonicalize($this->ceceFixturePayload());
        $ziwei = (array) ($result['ziwei'] ?? []);

        $this->assertSame('命宫', (string) ($ziwei['life_palace'] ?? ''));
        $this->assertSame('寅', (string) data_get($ziwei, 'life_palace_detail.branch'));
        $this->assertSame(['紫微', '天府'], data_get($ziwei, 'life_palace_detail.main_stars'));
        $this->assertSame('福德宫', (string) ($ziwei['body_palace'] ?? ''));
        $this->assertSame('medium', (string) data_get($ziwei, 'body_palace_detail.confidence'));

        $expected = [
            '命宫' => ['branch' => '寅', 'main_stars' => ['紫微', '天府']],
            '兄弟宫' => ['branch' => '丑', 'main_stars' => ['天机']],
            '夫妻宫' => ['branch' => '子', 'main_stars' => ['破军']],
            '子女宫' => ['branch' => '亥', 'main_stars' => ['太阳']],
            '财帛宫' => ['branch' => '戌', 'main_stars' => ['武曲']],
            '疾厄宫' => ['branch' => '酉', 'main_stars' => ['天同']],
            '迁移宫' => ['branch' => '申', 'main_stars' => ['七杀']],
            '交友宫' => ['branch' => '未', 'main_stars' => ['天梁']],
            '官禄宫' => ['branch' => '午', 'main_stars' => ['廉贞', '天相']],
            '田宅宫' => ['branch' => '巳', 'main_stars' => ['巨门']],
            '福德宫' => ['branch' => '辰', 'main_stars' => ['贪狼']],
            '父母宫' => ['branch' => '卯', 'main_stars' => ['太阴']],
        ];

        foreach ($expected as $palaceName => $expectation) {
            $palace = $this->palaceByName($ziwei, $palaceName);
            $this->assertSame($expectation['branch'], $palace['branch'] ?? null, $palaceName);
            $this->assertSame($expectation['main_stars'], $palace['main_stars'] ?? null, $palaceName);
            $this->assertSame($expectation['main_stars'][0], $palace['main_star'] ?? null, $palaceName);
        }

        $this->assertSame([
            $this->acceptedSihuaRow('化禄', '武曲', '财帛宫', '甲戌'),
            $this->acceptedSihuaRow('化权', '贪狼', '福德宫', '戊辰'),
            $this->acceptedSihuaRow('化科', '天梁', '交友宫', '辛未'),
            $this->acceptedSihuaRow('化忌', '文曲', '子女宫', '乙亥'),
        ], $ziwei['four_transformations'] ?? []);

        $this->assertSame('庙', data_get($this->palaceByName($ziwei, '财帛宫'), 'star_status_map.武曲'));
        $this->assertSame('陷', data_get($this->palaceByName($ziwei, '子女宫'), 'star_status_map.文曲'));
        $this->assertSame('庙', data_get($this->palaceByName($ziwei, '官禄宫'), 'star_status_map.天相'));
        $this->assertSame('旺', data_get($this->palaceByName($ziwei, '命宫'), 'star_status_map.紫微'));
        $this->assertSame('平', data_get($this->palaceByName($ziwei, '疾厄宫'), 'star_status_map.天同'));
        $this->assertSame('得', data_get($this->palaceByName($ziwei, '福德宫'), 'star_status_map.文昌'));
        $this->assertSame(
            'oracle_display_only',
            data_get($ziwei, 'ziwei_advanced_fields.field_status.sihua')
        );
        $this->assertSame('accepted_oracle', data_get($ziwei, 'ziwei_advanced_fields.sihua.status'));
        $this->assertSame('display_only_no_matching_scoring', data_get($ziwei, 'ziwei_advanced_fields.sihua.matching_policy'));
        $this->assertSame(
            'accepted_selected_fields_only',
            data_get($ziwei, 'ziwei_advanced_fields.field_status.auxiliary_stars')
        );
        $this->assertSame(
            'accepted_selected_fields_only',
            data_get($ziwei, 'ziwei_advanced_fields.field_status.brightness')
        );
        $this->assertSame(
            'pending_oracle',
            data_get($ziwei, 'ziwei_advanced_fields.field_status.ming_gong_flying_star')
        );
        $this->assertCount(4, (array) data_get($ziwei, 'ziwei_advanced_fields.sihua.items', []));
        $this->assertNotEmpty((array) data_get($ziwei, 'ziwei_advanced_fields.auxiliary_stars.palaces', []));
        $this->assertNotEmpty((array) data_get($ziwei, 'ziwei_advanced_fields.brightness.items', []));
    }

    public function test_wenmo_sihua_display_only_oracle_subset_covers_samples_b_and_c_without_scoring(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $cases = [
            'B' => [
                'payload' => [
                    'birthday' => '1994-03-18',
                    'birth_time' => '09:20',
                    'birth_place' => '浙江杭州西湖',
                    'gender' => 'female',
                    'user_id' => 3003,
                ],
                'expected' => [
                    $this->acceptedSihuaRow('化禄', '廉贞', '官禄宫', '丙寅'),
                    $this->acceptedSihuaRow('化权', '破军', '迁移宫', '戊辰'),
                    $this->acceptedSihuaRow('化科', '武曲', '财帛宫', '庚午'),
                    $this->acceptedSihuaRow('化忌', '太阳', '子女宫', '辛未'),
                ],
            ],
            'C' => [
                'payload' => [
                    'birthday' => '2001-11-23',
                    'birth_time' => '22:10',
                    'birth_place' => '四川成都武侯',
                    'gender' => 'male',
                    'user_id' => 4004,
                ],
                'expected' => [
                    $this->acceptedSihuaRow('化禄', '巨门', '交友宫', '癸巳'),
                    $this->acceptedSihuaRow('化权', '太阳', '兄弟宫', '己亥'),
                    $this->acceptedSihuaRow('化科', '文曲', '田宅宫', '辛卯'),
                    $this->acceptedSihuaRow('化忌', '文昌', '兄弟宫', '己亥'),
                ],
            ],
        ];

        foreach ($cases as $sampleId => $case) {
            $ziwei = (array) data_get($service->canonicalize($case['payload']), 'ziwei', []);

            $this->assertSame($case['expected'], $ziwei['four_transformations'] ?? [], $sampleId);
            $this->assertSame('accepted_oracle', data_get($ziwei, 'ziwei_advanced_fields.sihua.status'), $sampleId);
            $this->assertSame('oracle_display_only', data_get($ziwei, 'ziwei_advanced_fields.field_status.sihua'), $sampleId);
            $this->assertSame('display_only_no_matching_scoring', data_get($ziwei, 'ziwei_advanced_fields.matching_policy'), $sampleId);
            $this->assertSame('excluded_from_core_matching', data_get($ziwei, 'scoring_status'), $sampleId);
            $this->assertFalse((bool) data_get($ziwei, 'matching_score_enabled'), $sampleId);
            $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.flying_stars'), $sampleId);
            $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.ming_gong_flying_star'), $sampleId);
            $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'), $sampleId);
            $this->assertSame('candidate_visualization', data_get($ziwei, 'ziwei_advanced_fields.flying_star_candidate.status'), $sampleId);
            $this->assertSame('human_review_required', data_get($ziwei, 'ziwei_advanced_fields.flying_star_candidate.review_status'), $sampleId);
            $this->assertSame('display_only_no_matching_scoring', data_get($ziwei, 'ziwei_advanced_fields.flying_star_candidate.matching_policy'), $sampleId);
            $this->assertSame('candidate_visualization', data_get($ziwei, 'ziwei_advanced_fields.ming_gong_flying_star_candidate.status'), $sampleId);
            $this->assertSame('human_review_required', data_get($ziwei, 'ziwei_advanced_fields.ming_gong_flying_star_candidate.review_status'), $sampleId);
        }
    }

    public function test_wenmo_flying_star_candidate_visualization_requires_human_review_without_scoring(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $ziwei = (array) data_get($service->canonicalize([
            'birthday' => '2001-11-23',
            'birth_time' => '22:10',
            'birth_place' => '四川成都武侯',
            'gender' => 'male',
            'user_id' => 4004,
        ]), 'ziwei', []);

        $candidate = (array) data_get($ziwei, 'ziwei_advanced_fields.flying_star_candidate', []);
        $mingCandidate = (array) data_get($ziwei, 'ziwei_advanced_fields.ming_gong_flying_star_candidate', []);
        $firstLine = (array) data_get($candidate, 'lines.0', []);

        $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.flying_stars'));
        $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.ming_gong_flying_star'));
        $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'));
        $this->assertSame('candidate_visualization', $candidate['status'] ?? null);
        $this->assertSame('human_review_required', $candidate['review_status'] ?? null);
        $this->assertSame('arrow_start_end_uncertain', $candidate['line_semantics_status'] ?? null);
        $this->assertSame('display_only_no_matching_scoring', $candidate['matching_policy'] ?? null);
        $this->assertNotEmpty((array) ($candidate['lines'] ?? []));
        $this->assertNull($firstLine['from_palace'] ?? null);
        $this->assertSame('交友宫', $firstLine['to_palace'] ?? null);
        $this->assertSame('化禄', $firstLine['transform_type'] ?? null);
        $this->assertSame('candidate', $firstLine['source_status'] ?? null);
        $this->assertSame('human_review_required', $firstLine['review_status'] ?? null);
        $this->assertSame('low', $firstLine['confidence'] ?? null);
        $this->assertSame('candidate_visualization', $mingCandidate['status'] ?? null);
        $this->assertSame('human_review_required', $mingCandidate['review_status'] ?? null);
        $this->assertSame('命宫', $mingCandidate['life_palace'] ?? null);
        $this->assertSame('子', $mingCandidate['life_branch'] ?? null);
        $this->assertFalse((bool) data_get($ziwei, 'matching_score_enabled'));
        $this->assertSame('excluded_from_core_matching', data_get($ziwei, 'scoring_status'));

        $this->assertStringNotContainsString('accepted_oracle', json_encode($candidate, JSON_UNESCAPED_UNICODE) ?: '');
        $this->assertStringNotContainsString('accepted_oracle', json_encode($mingCandidate, JSON_UNESCAPED_UNICODE) ?: '');
    }

    public function test_wenmo_sihua_oracle_does_not_match_by_user_id_or_phone(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $ziwei = (array) data_get($service->canonicalize([
            'birthday' => '1994-03-18',
            'birth_time' => '09:20',
            'birth_place' => '北京',
            'gender' => 'female',
            'phone' => '13906229031',
            'user_id' => 3003,
        ]), 'ziwei', []);

        $this->assertSame([], $ziwei['four_transformations'] ?? []);
        $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.sihua.status'));
        $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.sihua'));
    }

    public function test_cece_p0_payload_shape_preserves_compatibility_and_containment(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $result = $service->canonicalize($this->ceceFixturePayload());
        $ziwei = (array) ($result['ziwei'] ?? []);
        $lifePalace = $this->palaceByName($ziwei, '命宫');

        $this->assertSame('ziwei_cece_p0_oracle_minimum', (string) ($ziwei['engine'] ?? ''));
        $this->assertSame('p0_selected_fields_only', (string) ($ziwei['precision'] ?? ''));
        $this->assertSame('not_validated', (string) ($ziwei['external_oracle_status'] ?? ''));
        $this->assertSame('cece', (string) ($ziwei['oracle_source'] ?? ''));
        $this->assertSame('cece_p0', (string) ($ziwei['rule_mouthpiece'] ?? ''));
        $this->assertSame('p0_fixture_supported', (string) ($ziwei['validation_status'] ?? ''));
        $this->assertTrue((bool) ($ziwei['display_only'] ?? false));
        $this->assertSame('excluded_from_core_matching', (string) ($ziwei['scoring_status'] ?? ''));

        $this->assertIsArray($ziwei['input_policy'] ?? null);
        $this->assertSame('1989-09-05 13:30', data_get($ziwei, 'input_policy.chart_beijing_time'));
        $this->assertSame('未', data_get($ziwei, 'input_policy.time_branch'));
        $this->assertFalse((bool) data_get($ziwei, 'input_policy.true_solar_time_used_for_p0'));

        $this->assertSame('insufficient_oracle', data_get($ziwei, 'flying_star_status.status'));
        $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'));
        $this->assertIsArray($ziwei['four_transformations'] ?? null);

        $this->assertSame('命宫', (string) ($ziwei['life_palace'] ?? ''));
        $this->assertSame('福德宫', (string) ($ziwei['body_palace'] ?? ''));
        $this->assertSame('紫微', (string) ($lifePalace['main_star'] ?? ''));
        $this->assertSame(['紫微', '天府'], $lifePalace['main_stars'] ?? null);
        $this->assertArrayHasKey('summary', $lifePalace);
        $this->assertArrayHasKey('major_themes', $ziwei);
    }

    public function test_cece_p0_payload_does_not_claim_full_correctness_or_flying_star(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $result = $service->canonicalize($this->ceceFixturePayload());
        $ziwei = (array) ($result['ziwei'] ?? []);

        $this->assertNotSame('validated', (string) ($ziwei['external_oracle_status'] ?? ''));
        $this->assertNotSame('full_birth_data', (string) ($ziwei['precision'] ?? ''));
        $this->assertStringContainsString('不代表完整紫微', (string) ($ziwei['disclaimer'] ?? ''));
        $this->assertStringContainsString('不参与核心匹配评分', (string) ($ziwei['disclaimer'] ?? ''));
        $this->assertSame('insufficient_oracle', data_get($ziwei, 'flying_star_status.status'));
        $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'));
        $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.flying_stars'));
        $this->assertSame('pending_oracle', data_get($ziwei, 'ziwei_advanced_fields.field_status.ming_gong_flying_star'));
    }

    /**
     * @return array<string,mixed>
     */
    private function ceceFixturePayload(): array
    {
        return [
            'birthday' => '1989-09-05',
            'birth_time' => '14:30',
            'daylight_saving' => true,
            'chart_beijing_time' => '13:30',
            'lunar_date' => '己巳年八月初六',
            'time_branch' => '未',
            'birth_place' => '白银市景泰县',
            'true_solar_time' => '12:27',
            'gender' => 'male',
            'user_id' => 22,
            'platform' => 'android',
        ];
    }

    /**
     * @param  array<string,mixed>  $ziwei
     * @return array<string,mixed>
     */
    private function palaceByName(array $ziwei, string $name): array
    {
        foreach ((array) ($ziwei['palaces'] ?? []) as $palace) {
            $palace = (array) $palace;
            if (($palace['name'] ?? null) === $name || ($palace['palace_name'] ?? null) === $name) {
                return $palace;
            }
        }

        $this->fail("Missing palace {$name}");
    }

    /**
     * @return array<string,mixed>
     */
    private function acceptedSihuaRow(string $transform, string $star, string $palace, string $branch): array
    {
        return [
            'transform' => $transform,
            'star' => $star,
            'palace' => $palace,
            'branch' => $branch,
            'status' => 'accepted_oracle',
            'source_app' => 'wenmo_tianji_pro',
            'evidence_source' => '6.3d_wenmo_screenshots',
            'adjudication_source' => '6.3e_gpt_advisor_visual_adjudication',
            'display_only' => true,
            'matching_policy' => 'display_only_no_matching_scoring',
        ];
    }
}
