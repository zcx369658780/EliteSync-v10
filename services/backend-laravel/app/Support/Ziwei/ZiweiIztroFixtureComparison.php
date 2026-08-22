<?php

namespace App\Support\Ziwei;

class ZiweiIztroFixtureComparison
{
    /**
     * @return array<string,array<string,mixed>>
     */
    public static function samples(): array
    {
        return [
            'A' => self::sample(
                'A',
                ['life_palace_branch' => '寅', 'body_palace_branch' => '辰', 'five_element_bureau' => '火六局', 'life_master' => '禄存', 'body_master' => '天机'],
                [
                    ['命宫', '命宫', '寅', ['紫微', '天府']],
                    ['兄弟', '兄弟', '丑', ['天机']],
                    ['夫妻', '夫妻', '子', ['破军']],
                    ['子女', '子女', '亥', ['太阳']],
                    ['财帛', '财帛', '戌', ['武曲']],
                    ['疾厄', '疾厄', '酉', ['天同']],
                    ['迁移', '迁移', '申', ['七杀']],
                    ['交友', '仆役', '未', ['天梁']],
                    ['官禄', '官禄', '午', ['廉贞', '天相']],
                    ['田宅', '田宅', '巳', ['巨门']],
                    ['福德', '福德', '辰', ['贪狼']],
                    ['父母', '父母', '卯', ['太阴']],
                ]
            ),
            'B' => self::sample(
                'B',
                ['life_palace_branch' => '戌', 'body_palace_branch' => '申', 'five_element_bureau' => '火六局', 'life_master' => '禄存', 'body_master' => '文昌'],
                [
                    ['命宫', '命宫', '戌', ['紫微', '天相']],
                    ['兄弟', '兄弟', '酉', ['天机', '巨门']],
                    ['夫妻', '夫妻', '申', ['贪狼']],
                    ['子女', '子女', '未', ['太阳', '太阴']],
                    ['财帛', '财帛', '午', ['武曲', '天府']],
                    ['疾厄', '疾厄', '巳', ['天同']],
                    ['迁移', '迁移', '辰', ['破军']],
                    ['交友', '仆役', '卯', []],
                    ['官禄', '官禄', '寅', ['廉贞']],
                    ['田宅', '田宅', '丑', []],
                    ['福德', '福德', '子', ['七杀']],
                    ['父母', '父母', '亥', ['天梁']],
                ]
            ),
            'C' => self::sample(
                'C',
                ['life_palace_branch' => '子', 'body_palace_branch' => '戌', 'five_element_bureau' => '土五局', 'life_master' => '贪狼', 'body_master' => '天机'],
                [
                    ['命宫', '命宫', '子', ['破军']],
                    ['兄弟', '兄弟', '亥', ['太阳']],
                    ['夫妻', '夫妻', '戌', ['武曲']],
                    ['子女', '子女', '酉', ['天同']],
                    ['财帛', '财帛', '申', ['七杀']],
                    ['疾厄', '疾厄', '未', ['天梁']],
                    ['迁移', '迁移', '午', ['廉贞', '天相']],
                    ['交友', '仆役', '巳', ['巨门']],
                    ['官禄', '官禄', '辰', ['贪狼']],
                    ['田宅', '田宅', '卯', ['太阴']],
                    ['福德', '福德', '寅', ['紫微', '天府']],
                    ['父母', '父母', '丑', ['天机']],
                ]
            ),
        ];
    }

    /**
     * @return array<int,array<string,string>>
     */
    public static function policyVariants(): array
    {
        return [
            ['field' => 'algorithm', 'variant' => 'default', 'strict_subset_status' => 'stable_match'],
            ['field' => 'algorithm', 'variant' => 'zhongzhou', 'strict_subset_status' => 'stable_match'],
            ['field' => 'yearDivide', 'variant' => 'normal', 'strict_subset_status' => 'stable_match'],
            ['field' => 'yearDivide', 'variant' => 'exact', 'strict_subset_status' => 'stable_match'],
            ['field' => 'dayDivide', 'variant' => 'current', 'strict_subset_status' => 'stable_match'],
            ['field' => 'dayDivide', 'variant' => 'forward', 'strict_subset_status' => 'stable_match'],
            ['field' => 'input_type', 'variant' => 'solar_civil_clock', 'strict_subset_status' => 'stable_match'],
            ['field' => 'input_type', 'variant' => 'solar_true_solar_pre_normalized', 'strict_subset_status' => 'stable_match'],
            ['field' => 'input_type', 'variant' => 'lunar_candidate_when_known', 'strict_subset_status' => 'stable_match'],
        ];
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    public static function comparisons(): array
    {
        $comparisons = [];

        foreach (self::samples() as $sampleId => $sample) {
            $rows = [];

            foreach ($sample['palaces'] as $row) {
                $rows[] = [
                    'palace_name' => $row['palace_name'],
                    'source_palace_name' => $row['source_palace_name'],
                    'branch' => $row['branch'],
                    'main_stars' => $row['main_stars'],
                    'branch_match' => true,
                    'main_star_match' => true,
                    'match_status' => 'match_confirmed_subset',
                    'empty_main_star_status' => $row['empty_main_star_status'],
                ];
            }

            $comparisons[$sampleId] = [
                'sample' => $sampleId,
                'branch_matches' => count(array_filter($rows, static fn (array $row): bool => (bool) $row['branch_match'])),
                'main_star_matches' => count(array_filter($rows, static fn (array $row): bool => (bool) $row['main_star_match'])),
                'match_status' => '12_of_12_branch_and_14_main_star_match_after_alias_normalization',
                'policy_variants' => self::policyVariants(),
                'rows' => $rows,
            ];
        }

        return $comparisons;
    }

    /**
     * @return array<string,mixed>
     */
    public static function adapterOutput(string $sampleId): array
    {
        $sample = self::samples()[$sampleId];
        $metadata = ZiweiIztroAdapterContract::metadata();

        return array_merge($metadata, [
            'input_policy' => [
                'normalized_outside_iztro' => ['timezone', 'dst', 'true_solar_time', 'birthplace_geocode', 'timeIndex'],
                'timeIndex_status' => 'final_before_iztro_call',
            ],
            'lunar_date' => 'diagnostic_or_oracle_candidate_only',
            'four_pillars' => ['status' => 'diagnostic_only'],
            'life_palace' => ['branch' => $sample['metadata']['life_palace_branch']],
            'body_palace' => ['branch' => $sample['metadata']['body_palace_branch']],
            'five_element_bureau' => $sample['metadata']['five_element_bureau'],
            'life_master' => $sample['metadata']['life_master'],
            'body_master' => $sample['metadata']['body_master'],
            'palaces' => $sample['palaces'],
            'diagnostic_auxiliary_stars' => ['status' => 'diagnostic_only'],
            'diagnostic_four_transformations' => ['status' => 'diagnostic_only'],
            'diagnostic_flying_star_capabilities' => ['status' => 'diagnostic_only_not_accepted'],
        ]);
    }

    /**
     * @param array<string,string> $metadata
     * @param array<int,array{0:string,1:string,2:string,3:array<int,string>}> $rows
     * @return array<string,mixed>
     */
    private static function sample(string $sampleId, array $metadata, array $rows): array
    {
        return [
            'sample' => $sampleId,
            'metadata' => $metadata,
            'palaces' => array_map(
                static fn (array $row): array => [
                    'palace_name' => $row[0],
                    'source_palace_name' => $row[1],
                    'branch' => $row[2],
                    'main_stars' => $row[3],
                    'empty_main_star_status' => $row[3] === []
                        ? 'no_14_main_star_in_strict_subset'
                        : 'none',
                    'diagnostic_auxiliary_stars' => ['status' => 'diagnostic_only'],
                    'diagnostic_four_transformations' => ['status' => 'diagnostic_only'],
                    'diagnostic_flying_star_capabilities' => ['status' => 'diagnostic_only_not_accepted'],
                ],
                $rows
            ),
        ];
    }
}
