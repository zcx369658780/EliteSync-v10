<?php

namespace Tests\Unit;

use App\Support\Ziwei\ZiweiIztroRunnerClient;
use App\Support\Ziwei\ZiweiIztroShadowAdapter;
use Tests\TestCase;

class ZiweiIztroShadowAdapterTest extends TestCase
{
    public function test_shadow_adapter_default_disabled_keeps_user_facing_output_unchanged(): void
    {
        $current = ['ziwei' => ['algorithm_route' => 'current_contained_seed_or_fixture']];
        $adapter = new ZiweiIztroShadowAdapter(
            new ZiweiIztroRunnerClient(base_path('tools/ziwei/iztro-runner/runner.mjs')),
        );

        $report = $adapter->buildShadowReport(ZiweiIztroShadowAdapter::fixtureInput('A'), $current);

        $this->assertSame('shadow_only_no_user_facing_change', $report['mode']);
        $this->assertSame($current, $report['current_user_facing_output']);
        $this->assertSame($current, $report['user_facing_output']);
        $this->assertSame('candidate_unavailable', $report['shadow_status']);
        $this->assertFalse((bool) $report['enabled']);
        $this->assertFalse((bool) $report['production_runtime_enabled']);
        $this->assertFalse((bool) $report['user_facing_enabled']);
        $this->assertFalse((bool) $report['db_write_enabled']);
        $this->assertSame('excluded_from_core_matching', $report['scoring_status']);
    }

    public function test_shadow_adapter_generates_a_b_c_candidates_that_match_accepted_strict_subset(): void
    {
        $adapter = new ZiweiIztroShadowAdapter(
            new ZiweiIztroRunnerClient(
                runnerPath: base_path('tools/ziwei/iztro-runner/runner.mjs'),
                enabled: true,
            ),
            enabled: true,
        );

        foreach (['A', 'B', 'C'] as $sampleId) {
            $report = $adapter->buildFixtureShadowReport($sampleId, [
                'status' => 'current_output_not_modified',
            ]);

            $this->assertSame('candidate_generated', $report['shadow_status']);
            $this->assertSame(
                '12_of_12_branch_and_14_main_star_match_after_alias_normalization',
                data_get($report, 'fixture_validation_status.status')
            );
            $this->assertSame(12, data_get($report, 'fixture_validation_status.branch_matches'));
            $this->assertSame(12, data_get($report, 'fixture_validation_status.main_star_matches'));
            $this->assertSame(12, data_get($report, 'fixture_validation_status.palace_name_matches'));
            $this->assertTrue((bool) data_get($report, 'iztro_candidate.display_only'));
            $this->assertSame('not_validated', data_get($report, 'iztro_candidate.external_oracle_status'));
            $this->assertSame('excluded_from_core_matching', data_get($report, 'iztro_candidate.scoring_status'));
            $this->assertFalse((bool) data_get($report, 'iztro_candidate.production_runtime_enabled'));
            $this->assertFalse((bool) data_get($report, 'iztro_candidate.user_facing_enabled'));
        }
    }

    public function test_shadow_adapter_preserves_b_empty_strict_main_star_palaces(): void
    {
        $adapter = new ZiweiIztroShadowAdapter(
            new ZiweiIztroRunnerClient(
                runnerPath: base_path('tools/ziwei/iztro-runner/runner.mjs'),
                enabled: true,
            ),
            enabled: true,
        );

        $report = $adapter->buildFixtureShadowReport('B');
        $empty = [];

        foreach ((array) data_get($report, 'iztro_candidate.palaces', []) as $palace) {
            if (($palace['empty_main_star_status'] ?? '') === 'no_14_main_star_in_strict_subset') {
                $empty[] = [$palace['palace_name'], $palace['branch']];
            }
        }

        $this->assertSame([['交友', '卯'], ['田宅', '丑']], $empty);
    }

    public function test_shadow_adapter_records_unsupported_upstream_policy_warnings(): void
    {
        $adapter = new ZiweiIztroShadowAdapter(
            new ZiweiIztroRunnerClient(base_path('tools/ziwei/iztro-runner/runner.mjs')),
        );

        $report = $adapter->buildShadowReport(ZiweiIztroShadowAdapter::fixtureInput('A'), []);

        foreach ([
            'true_solar_time_must_be_precomputed_outside_iztro',
            'dst_must_be_resolved_outside_iztro',
            'timezone_must_be_resolved_outside_iztro',
            'birthplace_geocode_must_be_resolved_outside_iztro',
            'timeIndex_is_policy_decisive_and_must_be_final_before_iztro_call',
        ] as $warning) {
            $this->assertContains($warning, $report['warnings']);
        }
    }

    public function test_shadow_adapter_keeps_b_c_current_runtime_gap_classification_non_user_facing(): void
    {
        $adapter = new ZiweiIztroShadowAdapter(
            new ZiweiIztroRunnerClient(
                runnerPath: base_path('tools/ziwei/iztro-runner/runner.mjs'),
                enabled: true,
            ),
            enabled: true,
        );

        foreach (['B', 'C'] as $sampleId) {
            $report = $adapter->buildFixtureShadowReport($sampleId);

            $this->assertSame(
                'current_runtime_mismatch_remains_generic_algorithm_gap_if_compared',
                $report['current_runtime_comparison_status']
            );
            $this->assertSame([], $report['user_facing_output']);
            $this->assertFalse((bool) $report['user_facing_enabled']);
        }
    }
}
