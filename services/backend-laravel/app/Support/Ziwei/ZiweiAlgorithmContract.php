<?php

namespace App\Support\Ziwei;

class ZiweiAlgorithmContract
{
    public const CONTRACT_VERSION = '6.2d_contract_scaffold_v1';
    public const ALGORITHM_ROUTE = 'hybrid_staged_contract_first';

    /**
     * @return array<string,mixed>
     */
    public static function defaultContainment(): array
    {
        return [
            'display_only' => true,
            'external_oracle_status' => 'not_validated',
            'scoring_status' => 'excluded_from_core_matching',
            'ziwei_score_status' => 'remains_zero_until_separate_gate',
            'runtime_algorithm_status' => 'contract_only',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function chartContract(): array
    {
        return [
            'yin_yang_gender' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'five_element_bureau' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'life_master' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'body_master' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'zi_dou' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'life_palace' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'body_palace' => ['status' => 'required_future_rule', 'confidence' => 'unverified'],
            'palaces' => self::palaceSlots(),
            'palace_name' => ['type' => 'string', 'required' => true],
            'branch' => ['type' => 'earthly_branch', 'required' => true],
            'palace_stem' => ['type' => 'heavenly_stem', 'required' => false, 'status' => 'optional_contract_field'],
            'main_stars' => ['type' => 'list<string>', 'required' => true, 'scope' => '14_main_stars_only'],
            'empty_main_star_status' => ['type' => 'string', 'allowed' => ['none', 'empty_main_star_palace', 'unknown']],
            'algorithm_version' => self::CONTRACT_VERSION,
            'result_status' => 'contract_only_not_runtime',
            'confidence' => 0.0,
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function fourTransformationsPolicy(): array
    {
        return [
            'rule_source_status' => 'not_selected',
            'heavenly_stem_source' => 'undecided',
            'transformation_star' => null,
            'transformation_type' => null,
            'palace' => null,
            'status' => 'out_of_scope_for_first_runtime_gate',
            'comparison_strategy' => 'compare_wenmo_or_cece_only_after_oracle_source_is_selected',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function auxiliaryStarPolicy(): array
    {
        return [
            'auxiliary_star_scope_status' => 'excluded_from_first_runtime_gate',
            'allowed_future_subset' => [],
            'status' => 'out_of_scope_for_first_runtime_gate',
            'warning' => 'not part of current strict main-star fixture',
            'separate_acceptance_required' => true,
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function flyingStarPolicy(): array
    {
        return [
            'flying_star_status' => 'not_implemented',
            'flying_star_oracle_status' => 'pending_oracle',
            'ming_gong_flying_star_status' => 'not_implemented',
            'ming_gong_flying_star_oracle_status' => 'pending_oracle',
            'first_generic_algorithm_gate_scope' => 'excluded',
            'warning' => 'cannot be inferred from star placement or four transformations alone',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function outputMetadata(): array
    {
        return [
            'algorithm_version' => self::CONTRACT_VERSION,
            'algorithm_route' => self::ALGORITHM_ROUTE,
            'oracle_status' => 'not_validated',
            'external_oracle_status' => 'not_validated',
            'precision' => 'contract_only',
            'confidence' => 0.0,
            'display_only' => true,
            'scoring_status' => 'excluded_from_core_matching',
            'source_policy' => ZiweiInputPolicy::VERSION,
            'fixture_validation_status' => 'not_runtime_validated',
            'warnings' => [
                'runtime_algorithm_not_replaced',
                'b_c_runtime_match_not_enabled',
                'flying_star_not_implemented',
            ],
            'limitations' => [
                'No full Ziwei correctness.',
                'No generic Ziwei algorithm validation.',
                'No Ming-gong flying-star correctness.',
            ],
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function schema(): array
    {
        return [
            'contract_version' => self::CONTRACT_VERSION,
            'containment' => self::defaultContainment(),
            'input_policy' => ZiweiInputPolicy::contract(),
            'chart_contract' => self::chartContract(),
            'four_transformations' => self::fourTransformationsPolicy(),
            'auxiliary_stars' => self::auxiliaryStarPolicy(),
            'flying_star' => self::flyingStarPolicy(),
            'output_metadata' => self::outputMetadata(),
            'fixture_strategy' => ZiweiFixtureMatrix::strategy(),
        ];
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    private static function palaceSlots(): array
    {
        $names = ['命宫', '兄弟宫', '夫妻宫', '子女宫', '财帛宫', '疾厄宫', '迁移宫', '交友宫', '官禄宫', '田宅宫', '福德宫', '父母宫'];

        return array_map(
            static fn (string $name): array => [
                'palace_name' => $name,
                'branch' => null,
                'palace_stem' => null,
                'main_stars' => [],
                'empty_main_star_status' => 'unknown',
            ],
            $names
        );
    }
}
