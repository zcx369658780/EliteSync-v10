<?php

namespace App\Support\Ziwei;

class ZiweiFixtureMatrix
{
    /**
     * @return array<string,string>
     */
    public static function statuses(): array
    {
        return [
            'accepted_fixture' => 'strict runtime comparison enabled for an accepted oracle surface',
            'confirmed_oracle_gap' => 'oracle subset accepted while current runtime mismatch remains expected',
            'pending_confirmation' => 'oracle lead retained without enough confirmation for strict assertions',
            'out_of_scope' => 'field deliberately excluded from this fixture gate',
            'research_candidate' => 'future candidate requiring separate evidence and acceptance',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function strategy(): array
    {
        return [
            'fixture_statuses' => self::statuses(),
            'strict_fields' => ['input_profile', 'true_solar_time', 'lunar_date_time_branch', 'palace_name', 'branch', '14_main_stars'],
            'diagnostic_fields' => ['runtime_mismatch_classification', 'oracle_comparison_notes'],
            'out_of_scope_fields' => ['auxiliary_stars', 'minor_stars', 'four_transformations', 'flying_star', 'ming_gong_flying_star', 'star_strength'],
            'runtime_match_assertion_enabled' => false,
        ];
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    public static function fixtures(): array
    {
        return [
            'sample_a_jingtai' => [
                'status' => 'accepted_fixture',
                'strict_runtime_assertion_enabled' => true,
                'scope' => ['palace_name', 'branch', 'main_star_mapping', 'containment'],
                'strict_fields' => ['palace_name', 'branch', 'main_stars', 'display_only_containment'],
                'diagnostic_fields' => [],
                'out_of_scope_fields' => ['full_ziwei_correctness', 'full_auxiliary_star_alignment', 'ming_gong_flying_star'],
                'runtime_mismatch_classification' => null,
                'not_full_ziwei_correctness' => true,
            ],
            'sample_b_hangzhou' => self::confirmedOracleGapFixture('sample_b_hangzhou'),
            'sample_c_chengdu' => self::confirmedOracleGapFixture('sample_c_chengdu'),
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private static function confirmedOracleGapFixture(string $fixtureId): array
    {
        return [
            'status' => 'confirmed_oracle_gap',
            'strict_runtime_assertion_enabled' => false,
            'runtime_match_assertion_enabled' => false,
            'strict_oracle_subset' => [
                'input_profile',
                'true_solar_time',
                'lunar_date_time_branch',
                'palace_name',
                'branch',
                '14_main_stars',
            ],
            'strict_fields' => ['input_profile', 'true_solar_time', 'lunar_date_time_branch', 'palace_name', 'branch', '14_main_stars'],
            'diagnostic_fields' => ['runtime_mismatch_classification'],
            'out_of_scope_fields' => ['auxiliary_stars', 'minor_stars', 'four_transformations', 'flying_star', 'ming_gong_flying_star', 'star_strength'],
            'runtime_mismatch_classification' => 'generic_algorithm_gap',
            'not_runtime_fixture' => true,
            'not_generic_algorithm_validation' => true,
            'fixture_id' => $fixtureId,
        ];
    }
}
