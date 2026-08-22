<?php

namespace App\Support\Ziwei;

use InvalidArgumentException;
use RuntimeException;

class ZiweiIztroComparisonReport
{
    /**
     * @return array<string,mixed>
     */
    public static function fromFixtureFile(string $path): array
    {
        if (! is_file($path)) {
            throw new InvalidArgumentException("Ziwei iztro comparison fixture not found: {$path}");
        }

        $contents = file_get_contents($path);

        if ($contents === false) {
            throw new RuntimeException("Unable to read Ziwei iztro comparison fixture: {$path}");
        }

        $fixture = json_decode($contents, true);

        if (! is_array($fixture)) {
            throw new RuntimeException("Invalid Ziwei iztro comparison fixture JSON: {$path}");
        }

        return self::fromFixture($fixture);
    }

    /**
     * @param array<string,mixed> $fixture
     * @return array<string,mixed>
     */
    public static function fromFixture(array $fixture): array
    {
        $sampleReports = [];

        foreach ((array) ($fixture['samples'] ?? []) as $sample) {
            if (! is_array($sample)) {
                continue;
            }

            $sampleReports[] = self::sampleReport($fixture, $sample);
        }

        return [
            'generator' => 'ZiweiIztroComparisonReport',
            'mode' => 'non_runtime_report_only_generated_fixture',
            'oracle_source' => (string) ($fixture['oracle_source'] ?? ''),
            'iztro_source_version' => (string) ($fixture['iztro_source_version'] ?? ZiweiIztroAdapterContract::ALGORITHM_VERSION),
            'input_policy' => (array) ($fixture['input_policy'] ?? []),
            'palace_alias_normalization' => (array) ($fixture['palace_alias_normalization'] ?? ZiweiIztroPalaceNormalizer::palaceAliases()),
            'strict_subset_fields' => (array) ($fixture['strict_subset_fields'] ?? ['palace_name', 'branch', 'main_stars']),
            'unsupported_fields' => (array) ($fixture['unsupported_fields'] ?? []),
            'diagnostic_only_fields' => (array) ($fixture['diagnostic_only_fields'] ?? []),
            'warnings' => (array) ($fixture['warnings'] ?? ZiweiIztroAdapterContract::unsupportedPolicyWarnings()),
            'non_claims' => (array) ($fixture['non_claims'] ?? ZiweiIztroAdapterContract::limitations()),
            'sample_reports' => $sampleReports,
            'summary' => self::summary($sampleReports),
        ];
    }

    /**
     * @param array<string,mixed> $report
     */
    public static function toMarkdown(array $report): string
    {
        $lines = [
            '# 6.2f Non-Runtime iztro Comparison Report',
            '',
            '- Generator: `'.($report['generator'] ?? 'ZiweiIztroComparisonReport').'`',
            '- Mode: `'.($report['mode'] ?? 'non_runtime_report_only_generated_fixture').'`',
            '- iztro source version: `'.($report['iztro_source_version'] ?? '').'`',
            '- Oracle source: `'.($report['oracle_source'] ?? '').'`',
            '- Overall match status: `'.data_get($report, 'summary.overall_match_status').'`',
            '',
            '## Samples',
        ];

        foreach ((array) ($report['sample_reports'] ?? []) as $sampleReport) {
            $lines[] = '';
            $lines[] = '### Sample '.($sampleReport['sample_id'] ?? '');
            $lines[] = '';
            $lines[] = '- Match status: `'.($sampleReport['match_status'] ?? '').'`';
            $lines[] = '- Branch matches: `'.data_get($sampleReport, 'match_counts.branch_matches').'/12`';
            $lines[] = '- Main-star matches: `'.data_get($sampleReport, 'match_counts.main_star_matches').'/12`';
            $lines[] = '- Empty strict palaces: `'.implode(', ', array_map(
                static fn (array $palace): string => $palace['palace_name'].'/'.$palace['branch'],
                (array) ($sampleReport['empty_strict_main_star_palaces'] ?? [])
            )).'`';
        }

        $lines[] = '';
        $lines[] = '## Non-Claims';

        foreach ((array) ($report['non_claims'] ?? []) as $claim) {
            $lines[] = '- '.$claim;
        }

        return implode(PHP_EOL, $lines).PHP_EOL;
    }

    /**
     * @param array<string,mixed> $fixture
     * @param array<string,mixed> $sample
     * @return array<string,mixed>
     */
    private static function sampleReport(array $fixture, array $sample): array
    {
        $rows = [];

        foreach ((array) ($sample['comparison_rows'] ?? []) as $row) {
            if (is_array($row)) {
                $rows[] = self::comparisonRow($row);
            }
        }

        $branchMatches = count(array_filter($rows, static fn (array $row): bool => (bool) $row['branch_match']));
        $mainStarMatches = count(array_filter($rows, static fn (array $row): bool => (bool) $row['main_star_match']));
        $palaceNameMatches = count(array_filter($rows, static fn (array $row): bool => (bool) $row['palace_name_match']));
        $allRowsMatch = count($rows) === 12
            && $branchMatches === 12
            && $mainStarMatches === 12
            && $palaceNameMatches === 12;

        return [
            'sample_id' => (string) ($sample['sample_id'] ?? ''),
            'oracle_source' => (string) ($fixture['oracle_source'] ?? ''),
            'iztro_source_version' => (string) ($fixture['iztro_source_version'] ?? ZiweiIztroAdapterContract::ALGORITHM_VERSION),
            'input_policy' => (array) ($sample['input_policy'] ?? $fixture['input_policy'] ?? []),
            'palace_alias_normalization' => (array) ($fixture['palace_alias_normalization'] ?? ZiweiIztroPalaceNormalizer::palaceAliases()),
            'strict_subset_fields' => (array) ($fixture['strict_subset_fields'] ?? ['palace_name', 'branch', 'main_stars']),
            'comparison_rows' => $rows,
            'match_counts' => [
                'palace_name_matches' => $palaceNameMatches,
                'branch_matches' => $branchMatches,
                'main_star_matches' => $mainStarMatches,
            ],
            'match_status' => $allRowsMatch
                ? '12_of_12_branch_and_14_main_star_match_after_alias_normalization'
                : 'strict_subset_mismatch',
            'empty_strict_main_star_palaces' => self::emptyStrictMainStarPalaces($rows),
            'unsupported_fields' => (array) ($fixture['unsupported_fields'] ?? []),
            'diagnostic_only_fields' => (array) ($fixture['diagnostic_only_fields'] ?? []),
            'warnings' => (array) ($fixture['warnings'] ?? ZiweiIztroAdapterContract::unsupportedPolicyWarnings()),
            'non_claims' => (array) ($fixture['non_claims'] ?? ZiweiIztroAdapterContract::limitations()),
        ];
    }

    /**
     * @param array<string,mixed> $row
     * @return array<string,mixed>
     */
    private static function comparisonRow(array $row): array
    {
        $oracle = (array) ($row['oracle'] ?? []);
        $iztro = (array) ($row['iztro'] ?? []);
        $normalizedIztroPalace = ZiweiIztroPalaceNormalizer::normalizePalace([
            'name' => (string) ($iztro['palace_name'] ?? ''),
            'earthlyBranch' => (string) ($iztro['branch'] ?? ''),
            'majorStars' => (array) ($iztro['main_stars'] ?? []),
        ]);
        $oracleMainStars = array_values((array) ($oracle['main_stars'] ?? []));
        $iztroMainStars = array_values((array) ($normalizedIztroPalace['main_stars'] ?? []));

        return [
            'palace_name' => (string) ($oracle['palace_name'] ?? ''),
            'oracle' => [
                'palace_name' => (string) ($oracle['palace_name'] ?? ''),
                'branch' => (string) ($oracle['branch'] ?? ''),
                'main_stars' => $oracleMainStars,
            ],
            'iztro' => [
                'source_palace_name' => (string) ($iztro['palace_name'] ?? ''),
                'palace_name' => (string) $normalizedIztroPalace['palace_name'],
                'branch' => (string) $normalizedIztroPalace['branch'],
                'main_stars' => $iztroMainStars,
                'empty_main_star_status' => (string) $normalizedIztroPalace['empty_main_star_status'],
            ],
            'palace_name_match' => (string) ($oracle['palace_name'] ?? '') === (string) $normalizedIztroPalace['palace_name'],
            'branch_match' => (string) ($oracle['branch'] ?? '') === (string) $normalizedIztroPalace['branch'],
            'main_star_match' => $oracleMainStars === $iztroMainStars,
            'match_status' => (string) ($oracle['palace_name'] ?? '') === (string) $normalizedIztroPalace['palace_name']
                && (string) ($oracle['branch'] ?? '') === (string) $normalizedIztroPalace['branch']
                && $oracleMainStars === $iztroMainStars
                    ? 'match_confirmed_subset'
                    : 'strict_subset_mismatch',
        ];
    }

    /**
     * @param array<int,array<string,mixed>> $rows
     * @return array<int,array{palace_name:string,branch:string}>
     */
    private static function emptyStrictMainStarPalaces(array $rows): array
    {
        $empty = [];

        foreach ($rows as $row) {
            if (data_get($row, 'iztro.empty_main_star_status') === 'no_14_main_star_in_strict_subset') {
                $empty[] = [
                    'palace_name' => (string) data_get($row, 'iztro.palace_name'),
                    'branch' => (string) data_get($row, 'iztro.branch'),
                ];
            }
        }

        return $empty;
    }

    /**
     * @param array<int,array<string,mixed>> $sampleReports
     * @return array<string,mixed>
     */
    private static function summary(array $sampleReports): array
    {
        $sampleStatuses = [];

        foreach ($sampleReports as $sampleReport) {
            $sampleStatuses[(string) $sampleReport['sample_id']] = (string) $sampleReport['match_status'];
        }

        $allMatch = $sampleStatuses !== []
            && count(array_filter(
                $sampleStatuses,
                static fn (string $status): bool => $status === '12_of_12_branch_and_14_main_star_match_after_alias_normalization'
            )) === count($sampleStatuses);

        return [
            'sample_count' => count($sampleReports),
            'sample_statuses' => $sampleStatuses,
            'overall_match_status' => $allMatch
                ? 'all_samples_match_strict_subset_after_alias_normalization'
                : 'one_or_more_samples_mismatch',
            'display_only' => true,
            'external_oracle_status' => 'not_validated',
            'scoring_status' => 'excluded_from_core_matching',
            'production_runtime_enabled' => false,
            'dependency_adopted' => false,
        ];
    }
}
