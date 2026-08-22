<?php

namespace Tests\Unit;

use App\Support\Ziwei\ZiweiAlgorithmContract;
use App\Support\Ziwei\ZiweiFixtureMatrix;
use App\Support\Ziwei\ZiweiInputPolicy;
use Tests\TestCase;

class ZiweiGenericAlgorithmContractTest extends TestCase
{
    public function test_contract_preserves_containment_defaults_without_runtime_enablement(): void
    {
        $contract = ZiweiAlgorithmContract::schema();

        $this->assertSame('6.2d_contract_scaffold_v1', $contract['contract_version']);
        $this->assertTrue((bool) data_get($contract, 'containment.display_only'));
        $this->assertSame('not_validated', data_get($contract, 'containment.external_oracle_status'));
        $this->assertSame('excluded_from_core_matching', data_get($contract, 'containment.scoring_status'));
        $this->assertSame('remains_zero_until_separate_gate', data_get($contract, 'containment.ziwei_score_status'));
        $this->assertSame('contract_only', data_get($contract, 'containment.runtime_algorithm_status'));

        $this->assertSame('hybrid_staged_contract_first', data_get($contract, 'output_metadata.algorithm_route'));
        $this->assertSame('contract_only', data_get($contract, 'output_metadata.precision'));
        $this->assertTrue((bool) data_get($contract, 'output_metadata.display_only'));
        $this->assertContains('runtime_algorithm_not_replaced', data_get($contract, 'output_metadata.warnings'));
        $this->assertContains('No generic Ziwei algorithm validation.', data_get($contract, 'output_metadata.limitations'));
    }

    public function test_input_policy_declares_required_fields_with_status_source_and_warning(): void
    {
        $fields = ZiweiInputPolicy::fields();

        $expected = [
            'gregorian_date',
            'civil_birth_time',
            'gender',
            'birth_place_label',
            'latitude',
            'longitude',
            'timezone',
            'dst_policy',
            'true_solar_time_policy',
            'hour_branch_policy',
            'lunar_conversion_policy',
            'leap_month_policy',
            'solar_term_boundary_policy',
            'zi_hour_cross_day_policy',
            'hour_boundary_policy',
        ];

        $this->assertSame($expected, array_keys($fields));

        foreach ($fields as $field) {
            $this->assertContains($field['status'], ['undecided', 'selected', 'out_of_scope']);
            $this->assertContains($field['source'], ['none', 'lunar_php', 'wenmo_candidate', 'cece_candidate', 'gpt_advisor_decision', 'future_gate']);
            $this->assertNotSame('', $field['warning']);
            $this->assertNotSame('', $field['limitation']);
        }
    }

    public function test_chart_contract_defines_core_fields_and_twelve_palace_slots(): void
    {
        $chart = ZiweiAlgorithmContract::chartContract();

        foreach ([
            'yin_yang_gender',
            'five_element_bureau',
            'life_master',
            'body_master',
            'zi_dou',
            'life_palace',
            'body_palace',
            'palaces',
            'palace_name',
            'branch',
            'palace_stem',
            'main_stars',
            'empty_main_star_status',
            'algorithm_version',
            'result_status',
            'confidence',
        ] as $field) {
            $this->assertArrayHasKey($field, $chart);
        }

        $this->assertCount(12, $chart['palaces']);
        $this->assertSame('命宫', $chart['palaces'][0]['palace_name']);
        $this->assertSame('父母宫', $chart['palaces'][11]['palace_name']);
        $this->assertSame('14_main_stars_only', data_get($chart, 'main_stars.scope'));
        $this->assertSame('contract_only_not_runtime', $chart['result_status']);
        $this->assertSame(0.0, $chart['confidence']);
    }

    public function test_placeholder_policies_keep_four_auxiliary_and_flying_star_out_of_first_gate(): void
    {
        $four = ZiweiAlgorithmContract::fourTransformationsPolicy();
        $auxiliary = ZiweiAlgorithmContract::auxiliaryStarPolicy();
        $flying = ZiweiAlgorithmContract::flyingStarPolicy();

        $this->assertSame('out_of_scope_for_first_runtime_gate', $four['status']);
        $this->assertSame('excluded_from_first_runtime_gate', $auxiliary['auxiliary_star_scope_status']);
        $this->assertSame('out_of_scope_for_first_runtime_gate', $auxiliary['status']);
        $this->assertSame('not part of current strict main-star fixture', $auxiliary['warning']);
        $this->assertSame('not_implemented', $flying['flying_star_status']);
        $this->assertSame('pending_oracle', $flying['flying_star_oracle_status']);
        $this->assertSame('not_implemented', $flying['ming_gong_flying_star_status']);
        $this->assertSame('pending_oracle', $flying['ming_gong_flying_star_oracle_status']);
        $this->assertStringContainsString('cannot be inferred', $flying['warning']);
    }

    public function test_fixture_matrix_represents_a_b_c_statuses_without_enabling_b_c_runtime_match(): void
    {
        $statuses = ZiweiFixtureMatrix::statuses();
        $fixtures = ZiweiFixtureMatrix::fixtures();

        $this->assertArrayHasKey('accepted_fixture', $statuses);
        $this->assertArrayHasKey('confirmed_oracle_gap', $statuses);
        $this->assertArrayHasKey('pending_confirmation', $statuses);
        $this->assertArrayHasKey('out_of_scope', $statuses);
        $this->assertArrayHasKey('research_candidate', $statuses);

        $this->assertSame('accepted_fixture', $fixtures['sample_a_jingtai']['status']);
        $this->assertTrue((bool) $fixtures['sample_a_jingtai']['strict_runtime_assertion_enabled']);
        $this->assertContains('not_full_ziwei_correctness', array_keys($fixtures['sample_a_jingtai']));

        foreach (['sample_b_hangzhou', 'sample_c_chengdu'] as $fixtureId) {
            $fixture = $fixtures[$fixtureId];

            $this->assertSame('confirmed_oracle_gap', $fixture['status']);
            $this->assertFalse((bool) $fixture['strict_runtime_assertion_enabled']);
            $this->assertFalse((bool) $fixture['runtime_match_assertion_enabled']);
            $this->assertSame('generic_algorithm_gap', $fixture['runtime_mismatch_classification']);
            $this->assertContains('14_main_stars', $fixture['strict_oracle_subset']);
            $this->assertContains('auxiliary_stars', $fixture['out_of_scope_fields']);
            $this->assertContains('four_transformations', $fixture['out_of_scope_fields']);
            $this->assertContains('flying_star', $fixture['out_of_scope_fields']);
            $this->assertContains('ming_gong_flying_star', $fixture['out_of_scope_fields']);
            $this->assertTrue((bool) $fixture['not_runtime_fixture']);
            $this->assertTrue((bool) $fixture['not_generic_algorithm_validation']);
        }
    }
}
