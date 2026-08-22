<?php

namespace App\Support\Ziwei;

class ZiweiIztroAdapterContract
{
    public const ALGORITHM_ROUTE = 'third_party_candidate_iztro_test_only';
    public const ALGORITHM_VERSION = 'iztro@2.5.8';
    public const SOURCE_POLICY = '6.2e_iztro_adapter_policy_v1';
    public const FIXTURE_VALIDATION_STATUS = 'strict_subset_comparison_only_not_runtime_validated';

    /**
     * @return array<string,mixed>
     */
    public static function inputShape(): array
    {
        return [
            'gregorian_date' => ['required' => true, 'source' => 'EliteSync_normalized_input'],
            'civil_birth_time' => ['required' => true, 'source' => 'EliteSync_profile_input'],
            'normalized_chart_time' => ['required' => true, 'source' => 'precomputed_outside_iztro'],
            'normalized_time_branch' => ['required' => true, 'source' => 'precomputed_outside_iztro'],
            'timeIndex' => ['required' => true, 'source' => 'precomputed_outside_iztro'],
            'gender_for_iztro' => ['required' => true, 'allowed' => ['男', '女']],
            'calendar_type' => ['required' => true, 'allowed' => ['solar', 'lunar']],
            'lunar_date' => ['required' => false, 'source' => 'EliteSync_or_oracle_candidate_when_used'],
            'is_leap_month' => ['required' => false, 'source' => 'EliteSync_or_oracle_candidate_when_used'],
            'fixLeap' => ['required' => true, 'source' => 'fixed_adapter_policy'],
            'algorithm' => ['required' => true, 'allowed' => ['default', 'zhongzhou']],
            'yearDivide' => ['required' => true, 'allowed' => ['normal', 'exact']],
            'dayDivide' => ['required' => true, 'allowed' => ['current', 'forward']],
            'horoscopeDivide' => ['required' => true, 'allowed' => ['normal', 'exact']],
            'language' => ['required' => true, 'allowed' => ['zh-CN']],
            'source_policy_version' => ['required' => true, 'value' => self::SOURCE_POLICY],
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function outputShape(): array
    {
        return [
            'algorithm_route' => self::ALGORITHM_ROUTE,
            'algorithm_version' => self::ALGORITHM_VERSION,
            'source_policy' => self::SOURCE_POLICY,
            'input_policy' => 'pre_normalized_outside_iztro',
            'lunar_date' => ['type' => 'string', 'required' => false],
            'four_pillars' => ['status' => 'diagnostic_only'],
            'life_palace' => ['branch' => 'earthly_branch'],
            'body_palace' => ['branch' => 'earthly_branch'],
            'five_element_bureau' => ['type' => 'string'],
            'life_master' => ['type' => 'string'],
            'body_master' => ['type' => 'string'],
            'palaces' => [
                'count' => 12,
                'fields' => ['palace_name', 'branch', 'main_stars', 'empty_main_star_status'],
            ],
            'palace_name' => ['normalization' => '仆役=>交友'],
            'branch' => ['type' => 'earthly_branch'],
            'main_stars' => ['scope' => '14_main_stars_only'],
            'empty_main_star_status' => ['allowed' => ['none', 'no_14_main_star_in_strict_subset']],
            'diagnostic_auxiliary_stars' => ['status' => 'diagnostic_only'],
            'diagnostic_four_transformations' => ['status' => 'diagnostic_only'],
            'diagnostic_flying_star_capabilities' => ['status' => 'diagnostic_only_not_accepted'],
            'fixture_validation_status' => self::FIXTURE_VALIDATION_STATUS,
            'warnings' => self::unsupportedPolicyWarnings(),
            'limitations' => self::limitations(),
            'display_only' => true,
            'scoring_status' => 'excluded_from_core_matching',
            'external_oracle_status' => 'not_validated',
            'production_runtime_enabled' => false,
            'dependency_adopted' => false,
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function normalizationRequirements(): array
    {
        return [
            'gender_mapping' => ['male' => '男', 'female' => '女'],
            'palace_aliases' => ZiweiIztroPalaceNormalizer::palaceAliases(),
            'strict_main_stars' => ZiweiIztroPalaceNormalizer::strictMainStars(),
            'empty_main_star_status' => 'no_14_main_star_in_strict_subset',
            'unsupported_upstream_policies' => [
                'true_solar_time_precomputed_outside_iztro',
                'dst_resolved_outside_iztro',
                'timezone_resolved_outside_iztro',
                'birthplace_geocode_resolved_outside_iztro',
            ],
            'diagnostic_only_fields' => [
                'auxiliary_stars',
                'minor_stars',
                'brightness',
                'four_transformations',
                'flying_star',
                'ming_gong_flying_star',
            ],
        ];
    }

    public static function genderForIztro(string $gender): ?string
    {
        return match (strtolower(trim($gender))) {
            'male', 'm', '男' => '男',
            'female', 'f', '女' => '女',
            default => null,
        };
    }

    /**
     * @return array<int,string>
     */
    public static function unsupportedPolicyWarnings(): array
    {
        return [
            'true_solar_time_must_be_precomputed_outside_iztro',
            'dst_must_be_resolved_outside_iztro',
            'timezone_must_be_resolved_outside_iztro',
            'birthplace_geocode_must_be_resolved_outside_iztro',
            'timeIndex_is_policy_decisive_and_must_be_final_before_iztro_call',
            'zi_hour_cross_day_policy_not_validated_by_a_b_c_samples',
        ];
    }

    /**
     * @return array<int,string>
     */
    public static function limitations(): array
    {
        return [
            'No production iztro dependency adoption.',
            'No production runtime integration.',
            'No full Ziwei correctness validation.',
            'No generic algorithm validation.',
            'No auxiliary-star correctness.',
            'No four-transformation correctness.',
            'No flying-star or Ming-gong flying-star correctness.',
            'A/B/C fixture comparison remains strict-subset test evidence only.',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function metadata(): array
    {
        return [
            'algorithm_route' => self::ALGORITHM_ROUTE,
            'algorithm_version' => self::ALGORITHM_VERSION,
            'source_policy' => self::SOURCE_POLICY,
            'fixture_validation_status' => self::FIXTURE_VALIDATION_STATUS,
            'display_only' => true,
            'scoring_status' => 'excluded_from_core_matching',
            'external_oracle_status' => 'not_validated',
            'production_runtime_enabled' => false,
            'dependency_adopted' => false,
            'warnings' => self::unsupportedPolicyWarnings(),
            'limitations' => self::limitations(),
        ];
    }
}
