<?php

namespace Tests\Unit;

use App\Support\Ziwei\ZiweiIztroAdapterContract;
use App\Support\Ziwei\ZiweiIztroFixtureComparison;
use App\Support\Ziwei\ZiweiIztroPalaceNormalizer;
use Tests\TestCase;

class ZiweiIztroAdapterContractTest extends TestCase
{
    public function test_adapter_contract_declares_test_only_input_and_output_shape(): void
    {
        $input = ZiweiIztroAdapterContract::inputShape();
        $output = ZiweiIztroAdapterContract::outputShape();

        foreach ([
            'gregorian_date',
            'civil_birth_time',
            'normalized_chart_time',
            'normalized_time_branch',
            'timeIndex',
            'gender_for_iztro',
            'calendar_type',
            'lunar_date',
            'is_leap_month',
            'fixLeap',
            'algorithm',
            'yearDivide',
            'dayDivide',
            'horoscopeDivide',
            'language',
            'source_policy_version',
        ] as $field) {
            $this->assertArrayHasKey($field, $input);
        }

        $this->assertSame('third_party_candidate_iztro_test_only', $output['algorithm_route']);
        $this->assertSame('iztro@2.5.8', $output['algorithm_version']);
        $this->assertSame('6.2e_iztro_adapter_policy_v1', $output['source_policy']);
        $this->assertTrue((bool) $output['display_only']);
        $this->assertSame('excluded_from_core_matching', $output['scoring_status']);
        $this->assertSame('not_validated', $output['external_oracle_status']);
        $this->assertFalse((bool) $output['production_runtime_enabled']);
        $this->assertFalse((bool) $output['dependency_adopted']);
        $this->assertContains('true_solar_time_must_be_precomputed_outside_iztro', $output['warnings']);
        $this->assertContains('No production runtime integration.', $output['limitations']);
    }

    public function test_normalization_rules_map_gender_palace_alias_and_strict_main_star_subset(): void
    {
        $this->assertSame('男', ZiweiIztroAdapterContract::genderForIztro('male'));
        $this->assertSame('女', ZiweiIztroAdapterContract::genderForIztro('female'));
        $this->assertSame('交友', ZiweiIztroPalaceNormalizer::normalizePalaceName('仆役'));

        $stars = ZiweiIztroPalaceNormalizer::filterStrictMainStars([
            '紫微',
            '左辅',
            ['name' => '天机', 'brightness' => '旺'],
            ['name' => '文昌'],
            '破军',
        ]);

        $this->assertSame(['紫微', '天机', '破军'], $stars);
    }

    public function test_empty_strict_main_star_palace_uses_explicit_status(): void
    {
        $palace = ZiweiIztroPalaceNormalizer::normalizePalace([
            'name' => '仆役',
            'earthlyBranch' => '卯',
            'majorStars' => [['name' => '文昌'], ['name' => '左辅']],
            'minorStars' => [['name' => '文昌']],
        ]);

        $this->assertSame('交友', $palace['palace_name']);
        $this->assertSame('卯', $palace['branch']);
        $this->assertSame([], $palace['main_stars']);
        $this->assertSame('no_14_main_star_in_strict_subset', $palace['empty_main_star_status']);
        $this->assertNotEmpty($palace['diagnostic_auxiliary_stars']);
    }

    public function test_a_b_c_fixture_comparison_keeps_strict_subset_matches_after_alias_normalization(): void
    {
        $comparisons = ZiweiIztroFixtureComparison::comparisons();

        foreach (['A', 'B', 'C'] as $sampleId) {
            $comparison = $comparisons[$sampleId];

            $this->assertSame(12, $comparison['branch_matches']);
            $this->assertSame(12, $comparison['main_star_matches']);
            $this->assertSame('12_of_12_branch_and_14_main_star_match_after_alias_normalization', $comparison['match_status']);
            $this->assertCount(12, $comparison['rows']);
            $this->assertContains('仆役', array_column($comparison['rows'], 'source_palace_name'));

            foreach ($comparison['policy_variants'] as $variant) {
                $this->assertSame('stable_match', $variant['strict_subset_status']);
            }
        }
    }

    public function test_a_b_c_sample_metadata_and_empty_palaces_match_accepted_subset(): void
    {
        $outputs = [
            'A' => ZiweiIztroFixtureComparison::adapterOutput('A'),
            'B' => ZiweiIztroFixtureComparison::adapterOutput('B'),
            'C' => ZiweiIztroFixtureComparison::adapterOutput('C'),
        ];

        $this->assertSame('寅', data_get($outputs, 'A.life_palace.branch'));
        $this->assertSame('辰', data_get($outputs, 'A.body_palace.branch'));
        $this->assertSame('火六局', data_get($outputs, 'A.five_element_bureau'));
        $this->assertSame('禄存', data_get($outputs, 'A.life_master'));
        $this->assertSame('天机', data_get($outputs, 'A.body_master'));

        $this->assertSame('戌', data_get($outputs, 'B.life_palace.branch'));
        $this->assertSame('申', data_get($outputs, 'B.body_palace.branch'));
        $this->assertSame('火六局', data_get($outputs, 'B.five_element_bureau'));
        $this->assertSame('禄存', data_get($outputs, 'B.life_master'));
        $this->assertSame('文昌', data_get($outputs, 'B.body_master'));
        $this->assertSame([['交友', '卯'], ['田宅', '丑']], $this->emptyPalaces($outputs['B']['palaces']));

        $this->assertSame('子', data_get($outputs, 'C.life_palace.branch'));
        $this->assertSame('戌', data_get($outputs, 'C.body_palace.branch'));
        $this->assertSame('土五局', data_get($outputs, 'C.five_element_bureau'));
        $this->assertSame('贪狼', data_get($outputs, 'C.life_master'));
        $this->assertSame('天机', data_get($outputs, 'C.body_master'));
        $this->assertSame([], $this->emptyPalaces($outputs['C']['palaces']));
    }

    public function test_adapter_outputs_preserve_diagnostic_only_and_containment_metadata(): void
    {
        foreach (['A', 'B', 'C'] as $sampleId) {
            $output = ZiweiIztroFixtureComparison::adapterOutput($sampleId);

            $this->assertSame('diagnostic_only', data_get($output, 'diagnostic_auxiliary_stars.status'));
            $this->assertSame('diagnostic_only', data_get($output, 'diagnostic_four_transformations.status'));
            $this->assertSame('diagnostic_only_not_accepted', data_get($output, 'diagnostic_flying_star_capabilities.status'));
            $this->assertTrue((bool) data_get($output, 'display_only'));
            $this->assertSame('excluded_from_core_matching', data_get($output, 'scoring_status'));
            $this->assertSame('not_validated', data_get($output, 'external_oracle_status'));
            $this->assertFalse((bool) data_get($output, 'production_runtime_enabled'));
            $this->assertFalse((bool) data_get($output, 'dependency_adopted'));
            $this->assertContains('dst_must_be_resolved_outside_iztro', $output['warnings']);
            $this->assertContains('timezone_must_be_resolved_outside_iztro', $output['warnings']);
            $this->assertContains('birthplace_geocode_must_be_resolved_outside_iztro', $output['warnings']);
        }
    }

    /**
     * @param array<int,array<string,mixed>> $palaces
     * @return array<int,array{0:string,1:string}>
     */
    private function emptyPalaces(array $palaces): array
    {
        $empty = [];

        foreach ($palaces as $palace) {
            if ($palace['empty_main_star_status'] === 'no_14_main_star_in_strict_subset') {
                $empty[] = [$palace['palace_name'], $palace['branch']];
            }
        }

        return $empty;
    }
}
