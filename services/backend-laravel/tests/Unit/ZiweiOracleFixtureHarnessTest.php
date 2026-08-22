<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use App\Services\ZiweiCanonicalService;
use App\Support\Ziwei\ZiweiFixtureMatrix;
use Tests\TestCase;

class ZiweiOracleFixtureHarnessTest extends TestCase
{
    private const WENMO_SOURCE_LABEL = 'GPT advisor preliminary visual transcription from user-provided Wenmo Tianji screenshots; requires later human/vision confirmation.';
    private const BC_CONFIRMATION_SOURCE_LABEL = 'GPT advisor based on user-provided Wenmo Tianji screenshots confirms B/C limited oracle fixtures for input profile, true solar time, lunar date/time branch, and palace-name / branch / 14-main-star mapping only.';

    public function test_harness_declares_one_strict_fixture_and_two_confirmed_oracle_gap_fixtures(): void
    {
        $fixtures = $this->oracleFixtures();

        $this->assertCount(3, $fixtures);
        $this->assertSame('accepted_fixture', $fixtures['sample_a_jingtai']['oracle_status']);
        $this->assertSame('confirmed_oracle_gap', $fixtures['sample_b_hangzhou']['oracle_status']);
        $this->assertSame('confirmed_oracle_gap', $fixtures['sample_c_chengdu']['oracle_status']);

        $this->assertTrue((bool) $fixtures['sample_a_jingtai']['strict_assertions_enabled']);
        $this->assertFalse((bool) $fixtures['sample_b_hangzhou']['strict_assertions_enabled']);
        $this->assertFalse((bool) $fixtures['sample_c_chengdu']['strict_assertions_enabled']);
        $this->assertFalse((bool) $fixtures['sample_a_jingtai']['strict_runtime_match_assertions_disabled']);
        $this->assertTrue((bool) $fixtures['sample_b_hangzhou']['strict_oracle_table_enabled']);
        $this->assertTrue((bool) $fixtures['sample_c_chengdu']['strict_oracle_table_enabled']);
        $this->assertTrue((bool) $fixtures['sample_b_hangzhou']['strict_runtime_match_assertions_disabled']);
        $this->assertTrue((bool) $fixtures['sample_c_chengdu']['strict_runtime_match_assertions_disabled']);

        foreach ($fixtures as $fixture) {
            $this->assertArrayHasKey('fixture_id', $fixture);
            $this->assertArrayHasKey('sample_label', $fixture);
            $this->assertArrayHasKey('source_label', $fixture);
            $this->assertArrayHasKey('confirmation_source', $fixture);
            $this->assertArrayHasKey('oracle_status', $fixture);
            $this->assertArrayHasKey('input_policy', $fixture);
            $this->assertArrayHasKey('expected_lunar_date', $fixture);
            $this->assertArrayHasKey('expected_true_solar_time', $fixture);
            $this->assertArrayHasKey('life_palace', $fixture);
            $this->assertArrayHasKey('body_palace', $fixture);
            $this->assertArrayHasKey('palaces', $fixture);
            $this->assertArrayHasKey('auxiliary_stars', $fixture);
            $this->assertArrayHasKey('four_transformations', $fixture);
            $this->assertArrayHasKey('flying_star_status', $fixture);
            $this->assertArrayHasKey('star_strength', $fixture);
            $this->assertArrayHasKey('runtime_comparison', $fixture);
            $this->assertArrayHasKey('acceptance_scope', $fixture);
            $this->assertArrayHasKey('matching_scope', $fixture);
            $this->assertArrayHasKey('non_claims', $fixture);
        }
    }

    public function test_fixture_status_taxonomy_keeps_pending_and_out_of_scope_available(): void
    {
        $statuses = $this->fixtureStatusTaxonomy();

        $this->assertSame('strict runtime comparison enabled for the accepted 6.2b surface', $statuses['accepted_fixture']);
        $this->assertSame('oracle table accepted but runtime mismatch remains a generic algorithm gap', $statuses['confirmed_oracle_gap']);
        $this->assertSame('record-only oracle lead that still requires confirmation', $statuses['pending_confirmation']);
        $this->assertSame('field not included in this strict fixture subset', $statuses['out_of_scope']);
    }

    public function test_fixture_statuses_align_with_generic_algorithm_contract_scaffold(): void
    {
        $fixtures = $this->oracleFixtures();
        $matrix = ZiweiFixtureMatrix::fixtures();

        $this->assertSame($fixtures['sample_a_jingtai']['oracle_status'], $matrix['sample_a_jingtai']['status']);
        $this->assertTrue((bool) $matrix['sample_a_jingtai']['strict_runtime_assertion_enabled']);

        foreach (['sample_b_hangzhou', 'sample_c_chengdu'] as $fixtureId) {
            $this->assertSame($fixtures[$fixtureId]['oracle_status'], $matrix[$fixtureId]['status']);
            $this->assertFalse((bool) $matrix[$fixtureId]['runtime_match_assertion_enabled']);
            $this->assertSame(
                $fixtures[$fixtureId]['runtime_comparison']['classification'],
                $matrix[$fixtureId]['runtime_mismatch_classification']
            );
            $this->assertContains('14_main_stars', $matrix[$fixtureId]['strict_oracle_subset']);
            $this->assertContains('four_transformations', $matrix[$fixtureId]['out_of_scope_fields']);
            $this->assertContains('flying_star', $matrix[$fixtureId]['out_of_scope_fields']);
            $this->assertContains('ming_gong_flying_star', $matrix[$fixtureId]['out_of_scope_fields']);
        }
    }

    public function test_sample_a_strict_fixture_matches_runtime_selected_scope_and_containment(): void
    {
        $fixture = $this->oracleFixtures()['sample_a_jingtai'];
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $result = $service->canonicalize($fixture['input_policy']);
        $ziwei = (array) ($result['ziwei'] ?? []);

        $this->assertSame('命宫', (string) ($ziwei['life_palace'] ?? ''));
        $this->assertSame('寅', (string) data_get($ziwei, 'life_palace_detail.branch'));
        $this->assertSame(['紫微', '天府'], data_get($ziwei, 'life_palace_detail.main_stars'));

        foreach ($fixture['palaces'] as $expected) {
            $palace = $this->palaceByName($ziwei, (string) $expected['palace_name']);
            $this->assertSame($expected['branch'], $palace['branch'] ?? null, (string) $expected['palace_name']);
            $this->assertSame($expected['main_stars'], $palace['main_stars'] ?? null, (string) $expected['palace_name']);
        }

        $this->assertTrue((bool) ($ziwei['display_only'] ?? false));
        $this->assertSame('not_validated', (string) ($ziwei['external_oracle_status'] ?? ''));
        $this->assertSame('excluded_from_core_matching', (string) ($ziwei['scoring_status'] ?? ''));
        $this->assertSame(0.58, (float) ($ziwei['confidence'] ?? 0));
        $this->assertSame('insufficient_oracle', data_get($ziwei, 'flying_star_status.status'));
        $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'));
    }

    public function test_confirmed_b_c_oracle_gap_fixtures_are_test_only_and_cannot_be_runtime_fixtures(): void
    {
        foreach (['sample_b_hangzhou', 'sample_c_chengdu'] as $fixtureId) {
            $fixture = $this->oracleFixtures()[$fixtureId];

            $this->assertSame('confirmed_oracle_gap', $fixture['oracle_status']);
            $this->assertFalse((bool) $fixture['strict_assertions_enabled']);
            $this->assertTrue((bool) $fixture['strict_oracle_table_enabled']);
            $this->assertTrue((bool) $fixture['strict_runtime_match_assertions_disabled']);
            $this->assertFalse((bool) $fixture['product_fixture_allowed']);
            $this->assertSame(self::BC_CONFIRMATION_SOURCE_LABEL, $fixture['confirmation_source']);
            $this->assertContains('confirmed_oracle_14_main_star_table', $fixture['acceptance_scope']);
            $this->assertContains('runtime_mismatch_expected', $fixture['acceptance_scope']);
            $this->assertSame('mismatch', $fixture['runtime_comparison']['expected_status']);
            $this->assertSame('generic_algorithm_gap', $fixture['runtime_comparison']['classification']);
            $this->assertSame('strict_runtime_match_assertions_disabled', $fixture['runtime_comparison']['assertion_policy']);
            $this->assertContains('not_6_2b_regression', $fixture['non_claims']);
            $this->assertContains('not_generic_algorithm_validation', $fixture['non_claims']);
            $this->assertContains('not_runtime_fixture', $fixture['non_claims']);
            $this->assertContains('not_product_fixture', $fixture['non_claims']);
            $this->assertSame('excluded_from_core_matching', $fixture['matching_scope']['scoring_status']);
            $this->assertSame('not_implemented', $fixture['flying_star_status']['implementation']);
        }
    }

    public function test_confirmed_b_c_oracle_gap_fixtures_record_exact_14_main_star_tables(): void
    {
        $fixtures = $this->oracleFixtures();

        $this->assertSame([
            ['palace_name' => '命宫', 'branch' => '戌', 'main_stars' => ['紫微', '天相']],
            ['palace_name' => '兄弟宫', 'branch' => '酉', 'main_stars' => ['天机', '巨门']],
            ['palace_name' => '夫妻宫', 'branch' => '申', 'main_stars' => ['贪狼']],
            ['palace_name' => '子女宫', 'branch' => '未', 'main_stars' => ['太阳', '太阴']],
            ['palace_name' => '财帛宫', 'branch' => '午', 'main_stars' => ['武曲', '天府']],
            ['palace_name' => '疾厄宫', 'branch' => '巳', 'main_stars' => ['天同']],
            ['palace_name' => '迁移宫', 'branch' => '辰', 'main_stars' => ['破军']],
            ['palace_name' => '交友宫', 'branch' => '卯', 'main_stars' => []],
            ['palace_name' => '官禄宫', 'branch' => '寅', 'main_stars' => ['廉贞']],
            ['palace_name' => '田宅宫', 'branch' => '丑', 'main_stars' => []],
            ['palace_name' => '福德宫', 'branch' => '子', 'main_stars' => ['七杀']],
            ['palace_name' => '父母宫', 'branch' => '亥', 'main_stars' => ['天梁']],
        ], $this->palaceOracleTable($fixtures['sample_b_hangzhou']));

        $this->assertSame([
            ['palace_name' => '命宫', 'branch' => '子', 'main_stars' => ['破军']],
            ['palace_name' => '兄弟宫', 'branch' => '亥', 'main_stars' => ['太阳']],
            ['palace_name' => '夫妻宫', 'branch' => '戌', 'main_stars' => ['武曲']],
            ['palace_name' => '子女宫', 'branch' => '酉', 'main_stars' => ['天同']],
            ['palace_name' => '财帛宫', 'branch' => '申', 'main_stars' => ['七杀']],
            ['palace_name' => '疾厄宫', 'branch' => '未', 'main_stars' => ['天梁']],
            ['palace_name' => '迁移宫', 'branch' => '午', 'main_stars' => ['廉贞', '天相']],
            ['palace_name' => '交友宫', 'branch' => '巳', 'main_stars' => ['巨门']],
            ['palace_name' => '官禄宫', 'branch' => '辰', 'main_stars' => ['贪狼']],
            ['palace_name' => '田宅宫', 'branch' => '卯', 'main_stars' => ['太阴']],
            ['palace_name' => '福德宫', 'branch' => '寅', 'main_stars' => ['紫微', '天府']],
            ['palace_name' => '父母宫', 'branch' => '丑', 'main_stars' => ['天机']],
        ], $this->palaceOracleTable($fixtures['sample_c_chengdu']));
    }

    public function test_confirmed_b_c_oracle_gap_fixtures_keep_auxiliary_four_transformations_and_flying_star_out_of_scope(): void
    {
        $fixtures = $this->oracleFixtures();

        $this->assertSame(
            ['文曲', '右弼', '铃星', '天马', '天钺', '火星', '地空', '文昌', '左辅', '红鸾', '地劫', '擎羊', '禄存', '天魁', '陀罗'],
            $fixtures['sample_b_hangzhou']['auxiliary_stars']['excluded_stars']
        );
        $this->assertSame(
            ['文曲', '左辅', '天马', '擎羊', '地劫', '红鸾', '禄存', '铃星', '陀罗', '天钺', '天喜', '天魁', '火星', '右弼'],
            $fixtures['sample_c_chengdu']['auxiliary_stars']['excluded_stars']
        );

        foreach (['sample_b_hangzhou', 'sample_c_chengdu'] as $fixtureId) {
            $fixture = $fixtures[$fixtureId];

            $this->assertSame('out_of_scope', $fixture['auxiliary_stars']['status']);
            $this->assertSame('out_of_scope', $fixture['four_transformations']['status']);
            $this->assertSame('out_of_scope', $fixture['star_strength']['status']);
            $this->assertSame('insufficient_oracle', $fixture['flying_star_status']['status']);
            $this->assertSame('not_implemented', $fixture['flying_star_status']['implementation']);
            $this->assertSame('out_of_scope', $fixture['flying_star_status']['acceptance_status']);
            $this->assertContains('not_auxiliary_star_alignment', $fixture['non_claims']);
            $this->assertContains('not_four_transformations_correctness', $fixture['non_claims']);
            $this->assertContains('not_flying_star_correctness', $fixture['non_claims']);
            $this->assertContains('not_ming_gong_flying_star', $fixture['non_claims']);
        }
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    private function oracleFixtures(): array
    {
        return [
            'sample_a_jingtai' => [
                'fixture_id' => 'sample_a_jingtai_19890905_1430_male',
                'sample_label' => 'A: 1989-09-05 14:30 男 甘肃景泰',
                'source_label' => self::WENMO_SOURCE_LABEL,
                'confirmation_source' => self::WENMO_SOURCE_LABEL,
                'oracle_status' => 'accepted_fixture',
                'strict_assertions_enabled' => true,
                'strict_oracle_table_enabled' => true,
                'strict_runtime_match_assertions_disabled' => false,
                'product_fixture_allowed' => false,
                'input_policy' => [
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
                ],
                'expected_lunar_date' => '己巳年八月初六',
                'expected_true_solar_time' => '12:27',
                'life_palace' => ['palace_name' => '命宫', 'branch' => '寅', 'main_stars' => ['紫微', '天府']],
                'body_palace' => ['palace_name' => '福德宫', 'branch' => '辰', 'status' => 'medium_confidence'],
                'palaces' => [
                    ['palace_name' => '命宫', 'branch' => '寅', 'main_stars' => ['紫微', '天府'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '兄弟宫', 'branch' => '丑', 'main_stars' => ['天机'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '夫妻宫', 'branch' => '子', 'main_stars' => ['破军'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '子女宫', 'branch' => '亥', 'main_stars' => ['太阳'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '财帛宫', 'branch' => '戌', 'main_stars' => ['武曲'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '疾厄宫', 'branch' => '酉', 'main_stars' => ['天同'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '迁移宫', 'branch' => '申', 'main_stars' => ['七杀'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '交友宫', 'branch' => '未', 'main_stars' => ['天梁'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '官禄宫', 'branch' => '午', 'main_stars' => ['廉贞', '天相'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '田宅宫', 'branch' => '巳', 'main_stars' => ['巨门'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '福德宫', 'branch' => '辰', 'main_stars' => ['贪狼'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                    ['palace_name' => '父母宫', 'branch' => '卯', 'main_stars' => ['太阴'], 'auxiliary_stars_subset' => [], 'status' => 'strict_main_star_only'],
                ],
                'four_transformations' => [
                    ['transform' => '化禄', 'star' => '武曲', 'palace' => '财帛宫'],
                    ['transform' => '化权', 'star' => '贪狼', 'palace' => '福德宫'],
                    ['transform' => '化科', 'star' => '天梁', 'palace' => '交友宫'],
                    ['transform' => '化忌', 'star' => '文曲', 'palace' => '财帛宫'],
                ],
                'flying_star_status' => ['status' => 'insufficient_oracle', 'implementation' => 'not_implemented'],
                'auxiliary_stars' => ['status' => 'out_of_scope', 'excluded_stars' => []],
                'star_strength' => ['status' => 'out_of_scope'],
                'runtime_comparison' => [
                    'expected_status' => 'match',
                    'classification' => 'accepted_fixture',
                    'assertion_policy' => 'strict_runtime_match_assertions_enabled',
                ],
                'acceptance_scope' => ['palace_name', 'branch', 'main_stars', 'display_only_containment'],
                'matching_scope' => ['scoring_status' => 'excluded_from_core_matching'],
                'non_claims' => ['not_full_ziwei_correctness', 'not_full_auxiliary_alignment', 'not_ming_gong_flying_star'],
            ],
            'sample_b_hangzhou' => $this->confirmedOracleGapFixture(
                'sample_b_hangzhou_19940318_0920_female',
                'B: 1994-03-18 09:20 女 浙江杭州西湖',
                [
                    'birthday' => '1994-03-18',
                    'birth_time' => '09:20',
                    'birth_place' => '浙江省杭州市西湖区',
                    'true_solar_time' => '09:12',
                    'gender' => 'female',
                    'platform' => 'android',
                    'bureau_polarity' => '阳女 火六局',
                    'ming_zhu' => '禄存',
                    'shen_zhu' => '文昌',
                    'zi_dou' => '辰',
                ],
                '甲戌年二月初七日 巳时',
                '09:12',
                ['palace_name' => '命宫', 'branch' => '戌', 'main_stars' => ['紫微', '天相']],
                ['status' => 'confirmed_limited', 'shen_zhu' => '文昌'],
                [
                    ['palace_name' => '命宫', 'branch' => '戌', 'main_stars' => ['紫微', '天相'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '兄弟宫', 'branch' => '酉', 'main_stars' => ['天机', '巨门'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '夫妻宫', 'branch' => '申', 'main_stars' => ['贪狼'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '子女宫', 'branch' => '未', 'main_stars' => ['太阳', '太阴'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '财帛宫', 'branch' => '午', 'main_stars' => ['武曲', '天府'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '疾厄宫', 'branch' => '巳', 'main_stars' => ['天同'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '迁移宫', 'branch' => '辰', 'main_stars' => ['破军'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '交友宫', 'branch' => '卯', 'main_stars' => [], 'status' => 'no_14_main_star_confirmed'],
                    ['palace_name' => '官禄宫', 'branch' => '寅', 'main_stars' => ['廉贞'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '田宅宫', 'branch' => '丑', 'main_stars' => [], 'status' => 'no_14_main_star_confirmed'],
                    ['palace_name' => '福德宫', 'branch' => '子', 'main_stars' => ['七杀'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '父母宫', 'branch' => '亥', 'main_stars' => ['天梁'], 'status' => 'confirmed_14_main_star_only'],
                ],
                ['文曲', '右弼', '铃星', '天马', '天钺', '火星', '地空', '文昌', '左辅', '红鸾', '地劫', '擎羊', '禄存', '天魁', '陀罗']
            ),
            'sample_c_chengdu' => $this->confirmedOracleGapFixture(
                'sample_c_chengdu_20011123_2210_male',
                'C: 2001-11-23 22:10 男 四川成都武侯',
                [
                    'birthday' => '2001-11-23',
                    'birth_time' => '22:10',
                    'birth_place' => '四川省成都市武侯区',
                    'true_solar_time' => '21:19',
                    'gender' => 'male',
                    'platform' => 'android',
                    'bureau_polarity' => '阴男 土五局',
                    'ming_zhu' => '贪狼',
                    'shen_zhu' => '天机',
                    'zi_dou' => '寅',
                ],
                '辛巳年十月初九日 亥时',
                '21:19',
                ['palace_name' => '命宫', 'branch' => '子', 'main_stars' => ['破军']],
                ['status' => 'confirmed_limited', 'shen_zhu' => '天机'],
                [
                    ['palace_name' => '命宫', 'branch' => '子', 'main_stars' => ['破军'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '兄弟宫', 'branch' => '亥', 'main_stars' => ['太阳'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '夫妻宫', 'branch' => '戌', 'main_stars' => ['武曲'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '子女宫', 'branch' => '酉', 'main_stars' => ['天同'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '财帛宫', 'branch' => '申', 'main_stars' => ['七杀'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '疾厄宫', 'branch' => '未', 'main_stars' => ['天梁'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '迁移宫', 'branch' => '午', 'main_stars' => ['廉贞', '天相'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '交友宫', 'branch' => '巳', 'main_stars' => ['巨门'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '官禄宫', 'branch' => '辰', 'main_stars' => ['贪狼'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '田宅宫', 'branch' => '卯', 'main_stars' => ['太阴'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '福德宫', 'branch' => '寅', 'main_stars' => ['紫微', '天府'], 'status' => 'confirmed_14_main_star_only'],
                    ['palace_name' => '父母宫', 'branch' => '丑', 'main_stars' => ['天机'], 'status' => 'confirmed_14_main_star_only'],
                ],
                ['文曲', '左辅', '天马', '擎羊', '地劫', '红鸾', '禄存', '铃星', '陀罗', '天钺', '天喜', '天魁', '火星', '右弼']
            ),
        ];
    }

    /**
     * @return array<string,string>
     */
    private function fixtureStatusTaxonomy(): array
    {
        return [
            'accepted_fixture' => 'strict runtime comparison enabled for the accepted 6.2b surface',
            'confirmed_oracle_gap' => 'oracle table accepted but runtime mismatch remains a generic algorithm gap',
            'pending_confirmation' => 'record-only oracle lead that still requires confirmation',
            'out_of_scope' => 'field not included in this strict fixture subset',
        ];
    }

    /**
     * @param array<string,mixed> $inputPolicy
     * @param array<string,mixed> $lifePalace
     * @param array<string,mixed> $bodyPalace
     * @param array<int,array<string,mixed>> $palaces
     * @param array<int,string> $excludedAuxiliaryStars
     * @return array<string,mixed>
     */
    private function confirmedOracleGapFixture(
        string $fixtureId,
        string $sampleLabel,
        array $inputPolicy,
        string $lunarDate,
        string $trueSolarTime,
        array $lifePalace,
        array $bodyPalace,
        array $palaces,
        array $excludedAuxiliaryStars
    ): array {
        return [
            'fixture_id' => $fixtureId,
            'sample_label' => $sampleLabel,
            'source_label' => self::WENMO_SOURCE_LABEL,
            'confirmation_source' => self::BC_CONFIRMATION_SOURCE_LABEL,
            'oracle_status' => 'confirmed_oracle_gap',
            'strict_assertions_enabled' => false,
            'strict_oracle_table_enabled' => true,
            'strict_runtime_match_assertions_disabled' => true,
            'product_fixture_allowed' => false,
            'input_policy' => $inputPolicy,
            'expected_lunar_date' => $lunarDate,
            'expected_true_solar_time' => $trueSolarTime,
            'life_palace' => $lifePalace,
            'body_palace' => $bodyPalace,
            'palaces' => $palaces,
            'auxiliary_stars' => ['status' => 'out_of_scope', 'excluded_stars' => $excludedAuxiliaryStars],
            'four_transformations' => ['status' => 'out_of_scope'],
            'flying_star_status' => [
                'status' => 'insufficient_oracle',
                'implementation' => 'not_implemented',
                'acceptance_status' => 'out_of_scope',
            ],
            'star_strength' => ['status' => 'out_of_scope'],
            'runtime_comparison' => [
                'expected_status' => 'mismatch',
                'classification' => 'generic_algorithm_gap',
                'assertion_policy' => 'strict_runtime_match_assertions_disabled',
            ],
            'acceptance_scope' => [
                'confirmed_oracle_14_main_star_table',
                'runtime_mismatch_expected',
                'test_only_oracle_gap_fixture',
            ],
            'matching_scope' => ['scoring_status' => 'excluded_from_core_matching'],
            'non_claims' => [
                'not_6_2b_regression',
                'not_generic_algorithm_validation',
                'not_runtime_fixture',
                'not_product_fixture',
                'not_auxiliary_star_alignment',
                'not_four_transformations_correctness',
                'not_flying_star_correctness',
                'not_ming_gong_flying_star',
            ],
        ];
    }

    /**
     * @param array<string,mixed> $fixture
     * @return array<int,array{palace_name:string,branch:string,main_stars:array<int,string>}>
     */
    private function palaceOracleTable(array $fixture): array
    {
        return array_map(
            static fn (array $palace): array => [
                'palace_name' => (string) $palace['palace_name'],
                'branch' => (string) $palace['branch'],
                'main_stars' => (array) $palace['main_stars'],
            ],
            $fixture['palaces']
        );
    }

    /**
     * @param array<string,mixed> $ziwei
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
}
