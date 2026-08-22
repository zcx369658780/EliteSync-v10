<?php

namespace Tests\Unit;

use App\Support\Ziwei\ZiweiIztroComparisonReport;
use Tests\TestCase;

class ZiweiIztroComparisonReportTest extends TestCase
{
    private string $fixturePath;

    protected function setUp(): void
    {
        parent::setUp();

        $this->fixturePath = base_path('tests/Fixtures/Ziwei/iztro_abc_comparison_fixture.json');
    }

    public function test_report_generator_loads_generated_fixture_without_runtime_dependency(): void
    {
        $report = ZiweiIztroComparisonReport::fromFixtureFile($this->fixturePath);

        $this->assertSame('ZiweiIztroComparisonReport', $report['generator']);
        $this->assertSame('non_runtime_report_only_generated_fixture', $report['mode']);
        $this->assertSame('iztro@2.5.8', $report['iztro_source_version']);
        $this->assertSame(['palace_name', 'branch', 'main_stars'], $report['strict_subset_fields']);
        $this->assertTrue((bool) data_get($report, 'summary.display_only'));
        $this->assertSame('not_validated', data_get($report, 'summary.external_oracle_status'));
        $this->assertSame('excluded_from_core_matching', data_get($report, 'summary.scoring_status'));
        $this->assertFalse((bool) data_get($report, 'summary.production_runtime_enabled'));
        $this->assertFalse((bool) data_get($report, 'summary.dependency_adopted'));
    }

    public function test_a_b_c_strict_subset_rows_match_after_palace_alias_normalization(): void
    {
        $report = ZiweiIztroComparisonReport::fromFixtureFile($this->fixturePath);

        $this->assertSame('all_samples_match_strict_subset_after_alias_normalization', data_get($report, 'summary.overall_match_status'));
        $this->assertCount(3, $report['sample_reports']);

        foreach ($report['sample_reports'] as $sampleReport) {
            $this->assertSame('12_of_12_branch_and_14_main_star_match_after_alias_normalization', $sampleReport['match_status']);
            $this->assertSame(12, data_get($sampleReport, 'match_counts.palace_name_matches'));
            $this->assertSame(12, data_get($sampleReport, 'match_counts.branch_matches'));
            $this->assertSame(12, data_get($sampleReport, 'match_counts.main_star_matches'));
            $this->assertCount(12, $sampleReport['comparison_rows']);
            $this->assertContains('仆役', array_column(array_column($sampleReport['comparison_rows'], 'iztro'), 'source_palace_name'));
        }
    }

    public function test_b_empty_palaces_and_c_no_empty_palaces_are_preserved(): void
    {
        $samples = $this->samplesById(ZiweiIztroComparisonReport::fromFixtureFile($this->fixturePath));

        $this->assertSame([], data_get($samples, 'A.empty_strict_main_star_palaces'));
        $this->assertSame(
            [
                ['palace_name' => '交友', 'branch' => '卯'],
                ['palace_name' => '田宅', 'branch' => '丑'],
            ],
            data_get($samples, 'B.empty_strict_main_star_palaces')
        );
        $this->assertSame([], data_get($samples, 'C.empty_strict_main_star_palaces'));
    }

    public function test_report_marks_unsupported_and_diagnostic_fields_without_correctness_claims(): void
    {
        $report = ZiweiIztroComparisonReport::fromFixtureFile($this->fixturePath);

        foreach (['birthplace_geocode', 'timezone', 'dst', 'true_solar_time', 'final_timeIndex'] as $field) {
            $this->assertContains($field, $report['unsupported_fields']);
        }

        foreach (['auxiliary_stars', 'four_transformations', 'brightness', 'flying_star', 'ming_gong_flying_star'] as $field) {
            $this->assertContains($field, $report['diagnostic_only_fields']);
        }

        $this->assertContains('true_solar_time_must_be_precomputed_outside_iztro', $report['warnings']);
        $this->assertContains('No production iztro acceptance.', $report['non_claims']);
        $this->assertContains('No full Ziwei correctness validation.', $report['non_claims']);
        $this->assertContains('No matching/scoring readiness.', $report['non_claims']);
    }

    public function test_report_can_render_markdown_summary_for_artifact_generation(): void
    {
        $report = ZiweiIztroComparisonReport::fromFixtureFile($this->fixturePath);
        $markdown = ZiweiIztroComparisonReport::toMarkdown($report);

        $this->assertStringContainsString('# 6.2f Non-Runtime iztro Comparison Report', $markdown);
        $this->assertStringContainsString('all_samples_match_strict_subset_after_alias_normalization', $markdown);
        $this->assertStringContainsString('Sample A', $markdown);
        $this->assertStringContainsString('Sample B', $markdown);
        $this->assertStringContainsString('Sample C', $markdown);
        $this->assertStringContainsString('No production iztro acceptance.', $markdown);
    }

    /**
     * @param array<string,mixed> $report
     * @return array<string,array<string,mixed>>
     */
    private function samplesById(array $report): array
    {
        $samples = [];

        foreach ($report['sample_reports'] as $sampleReport) {
            $samples[$sampleReport['sample_id']] = $sampleReport;
        }

        return $samples;
    }
}
