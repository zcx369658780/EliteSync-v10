<?php

namespace App\Support\Ziwei;

class ZiweiInputPolicy
{
    public const VERSION = '6.2d_contract_scaffold_v1';

    /**
     * @return array<string,array<string,string>>
     */
    public static function fields(): array
    {
        return [
            'gregorian_date' => self::field('selected', 'future_gate', 'Civil Gregorian birth date remains required input.'),
            'civil_birth_time' => self::field('selected', 'future_gate', 'Civil birth time remains required input; boundary behavior is not yet validated.'),
            'gender' => self::field('selected', 'future_gate', 'Gender is required because Ziwei yin-yang gender and bureau rules depend on it.'),
            'birth_place_label' => self::field('selected', 'future_gate', 'Human-readable place label is retained for audit and oracle comparison.'),
            'latitude' => self::field('selected', 'future_gate', 'Coordinates are required for true solar time policy, but source precedence is not final.'),
            'longitude' => self::field('selected', 'future_gate', 'Coordinates are required for true solar time policy, but source precedence is not final.'),
            'timezone' => self::field('selected', 'future_gate', 'Timezone must be explicit before generic runtime replacement.'),
            'dst_policy' => self::field('undecided', 'future_gate', 'DST handling outside accepted fixtures remains undecided.'),
            'true_solar_time_policy' => self::field('undecided', 'future_gate', 'Whether and how true solar time determines chart hour remains a separate decision.'),
            'hour_branch_policy' => self::field('undecided', 'future_gate', 'Civil-time versus true-solar-time hour branch selection is not accepted yet.'),
            'lunar_conversion_policy' => self::field('undecided', 'lunar_php', 'Existing lunar-php support can be reused, but Ziwei-specific boundaries still require validation.'),
            'leap_month_policy' => self::field('undecided', 'lunar_php', 'Leap month treatment must be fixture-tested before runtime replacement.'),
            'solar_term_boundary_policy' => self::field('undecided', 'future_gate', 'Solar-term boundary behavior is required for a validated generic calculator.'),
            'zi_hour_cross_day_policy' => self::field('undecided', 'future_gate', 'Zi-hour cross-day behavior must be selected and tested explicitly.'),
            'hour_boundary_policy' => self::field('undecided', 'future_gate', 'Boundary inclusivity at each double-hour needs oracle-backed acceptance.'),
        ];
    }

    /**
     * @return array<string,mixed>
     */
    public static function contract(): array
    {
        return [
            'policy_version' => self::VERSION,
            'fields' => self::fields(),
            'warnings' => [
                'input_policy_is_contract_only',
                'runtime_seed_rotate_branch_is_not_replaced',
                'true_solar_hour_branch_policy_not_accepted',
            ],
            'limitations' => [
                'No generic Ziwei runtime correctness is claimed.',
                'No B/C runtime fixture match is enabled.',
            ],
        ];
    }

    /**
     * @return array<string,string>
     */
    private static function field(string $status, string $source, string $warning): array
    {
        return [
            'status' => $status,
            'source' => $source,
            'warning' => $warning,
            'limitation' => $warning,
        ];
    }
}
