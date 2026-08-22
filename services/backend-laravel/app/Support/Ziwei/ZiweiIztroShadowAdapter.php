<?php

namespace App\Support\Ziwei;

class ZiweiIztroShadowAdapter
{
    public const SOURCE_POLICY = '6.2g_iztro_shadow_adapter_policy_v1';

    public function __construct(
        private readonly ZiweiIztroRunnerClient $runner,
        private readonly bool $enabled = false,
    ) {
    }

    /**
     * @param array<string,mixed> $normalizedInput
     * @param array<string,mixed> $currentUserFacingOutput
     * @return array<string,mixed>
     */
    public function buildShadowReport(array $normalizedInput, array $currentUserFacingOutput): array
    {
        $runnerInput = $this->withDefaultPolicy($normalizedInput);
        $candidate = $this->enabled
            ? $this->normalizeCandidate($this->runner->run($runnerInput))
            : $this->runner->fallback('shadow_adapter_disabled');

        return [
            'mode' => 'shadow_only_no_user_facing_change',
            'source_policy' => self::SOURCE_POLICY,
            'enabled' => $this->enabled,
            'shadow_status' => ($candidate['success'] ?? false) === true
                ? 'candidate_generated'
                : 'candidate_unavailable',
            'current_user_facing_output' => $currentUserFacingOutput,
            'user_facing_output' => $currentUserFacingOutput,
            'iztro_candidate' => $candidate,
            'display_only' => true,
            'external_oracle_status' => 'not_validated',
            'scoring_status' => 'excluded_from_core_matching',
            'production_runtime_enabled' => false,
            'user_facing_enabled' => false,
            'dependency_adopted' => 'shadow_tool_only',
            'db_write_enabled' => false,
            'warnings' => ZiweiIztroAdapterContract::unsupportedPolicyWarnings(),
            'limitations' => [
                'shadow_candidate_is_not_returned_to_user',
                'current_runtime_payload_is_not_modified',
                'no_user_astro_profiles_write',
                'no_users_private_ziwei_write',
                'no_matching_or_scoring_use',
            ],
        ];
    }

    /**
     * @param array<string,mixed> $currentUserFacingOutput
     * @return array<string,mixed>
     */
    public function buildFixtureShadowReport(string $sampleId, array $currentUserFacingOutput = []): array
    {
        $sampleId = strtoupper($sampleId);
        $input = self::fixtureInput($sampleId);
        $report = $this->buildShadowReport($input, $currentUserFacingOutput);
        $report['sample_id'] = $sampleId;
        $report['fixture_validation_status'] = $this->compareCandidateToAcceptedSubset(
            (array) ($report['iztro_candidate'] ?? []),
            $sampleId
        );
        $report['current_runtime_comparison_status'] = $sampleId === 'A'
            ? 'current_user_facing_output_remains_accepted_fixture_or_contained_output'
            : 'current_runtime_mismatch_remains_generic_algorithm_gap_if_compared';

        return $report;
    }

    /**
     * @return array<string,mixed>
     */
    public static function fixtureInput(string $sampleId): array
    {
        return match (strtoupper($sampleId)) {
            'A' => [
                'gregorian_date' => '1989-09-05',
                'civil_birth_time' => '14:30',
                'normalized_chart_time' => '14:30',
                'normalized_time_branch' => '未时',
                'timeIndex' => 7,
                'gender' => 'male',
                'gender_for_iztro' => '男',
                'calendar_type' => 'solar',
            ],
            'B' => [
                'gregorian_date' => '1994-03-18',
                'civil_birth_time' => '09:20',
                'normalized_chart_time' => '09:12',
                'normalized_time_branch' => '巳时',
                'timeIndex' => 5,
                'gender' => 'female',
                'gender_for_iztro' => '女',
                'calendar_type' => 'solar',
            ],
            'C' => [
                'gregorian_date' => '2001-11-23',
                'civil_birth_time' => '22:10',
                'normalized_chart_time' => '21:19',
                'normalized_time_branch' => '亥时',
                'timeIndex' => 11,
                'gender' => 'male',
                'gender_for_iztro' => '男',
                'calendar_type' => 'solar',
            ],
            default => throw new \InvalidArgumentException("Unsupported Ziwei iztro shadow fixture sample: {$sampleId}"),
        };
    }

    /**
     * @param array<string,mixed> $input
     * @return array<string,mixed>
     */
    private function withDefaultPolicy(array $input): array
    {
        $gender = (string) ($input['gender_for_iztro'] ?? ZiweiIztroAdapterContract::genderForIztro((string) ($input['gender'] ?? '')) ?? '');

        return array_merge([
            'calendar_type' => 'solar',
            'fixLeap' => true,
            'algorithm' => 'default',
            'yearDivide' => 'normal',
            'dayDivide' => 'current',
            'horoscopeDivide' => 'normal',
            'language' => 'zh-CN',
            'source_policy_version' => self::SOURCE_POLICY,
        ], $input, [
            'gender_for_iztro' => $gender,
        ]);
    }

    /**
     * @param array<string,mixed> $candidate
     * @return array<string,mixed>
     */
    private function normalizeCandidate(array $candidate): array
    {
        if (($candidate['success'] ?? false) !== true) {
            return $candidate;
        }

        $palaces = [];
        foreach ((array) ($candidate['palaces'] ?? []) as $palace) {
            if (is_array($palace)) {
                $palaces[] = ZiweiIztroPalaceNormalizer::normalizePalace($palace);
            }
        }

        return array_merge($candidate, [
            'palaces' => $palaces,
            'display_only' => true,
            'external_oracle_status' => 'not_validated',
            'scoring_status' => 'excluded_from_core_matching',
            'production_runtime_enabled' => false,
            'user_facing_enabled' => false,
            'dependency_adopted' => 'shadow_tool_only',
        ]);
    }

    /**
     * @param array<string,mixed> $candidate
     * @return array<string,mixed>
     */
    private function compareCandidateToAcceptedSubset(array $candidate, string $sampleId): array
    {
        if (($candidate['success'] ?? false) !== true) {
            return [
                'status' => 'candidate_unavailable',
                'branch_matches' => 0,
                'main_star_matches' => 0,
                'palace_name_matches' => 0,
            ];
        }

        $expected = ZiweiIztroFixtureComparison::adapterOutput($sampleId);
        $expectedByName = [];
        foreach ((array) $expected['palaces'] as $palace) {
            $expectedByName[(string) $palace['palace_name']] = $palace;
        }

        $branchMatches = 0;
        $mainStarMatches = 0;
        $palaceNameMatches = 0;
        $rows = [];

        foreach ((array) ($candidate['palaces'] ?? []) as $candidatePalace) {
            if (! is_array($candidatePalace)) {
                continue;
            }

            $name = (string) ($candidatePalace['palace_name'] ?? '');
            $expectedPalace = (array) ($expectedByName[$name] ?? []);
            $branchMatch = (string) ($expectedPalace['branch'] ?? '') === (string) ($candidatePalace['branch'] ?? '');
            $mainStarMatch = array_values((array) ($expectedPalace['main_stars'] ?? [])) === array_values((array) ($candidatePalace['main_stars'] ?? []));
            $palaceNameMatch = $expectedPalace !== [];

            $branchMatches += $branchMatch ? 1 : 0;
            $mainStarMatches += $mainStarMatch ? 1 : 0;
            $palaceNameMatches += $palaceNameMatch ? 1 : 0;
            $rows[] = [
                'palace_name' => $name,
                'branch_match' => $branchMatch,
                'main_star_match' => $mainStarMatch,
                'palace_name_match' => $palaceNameMatch,
                'empty_main_star_status' => (string) ($candidatePalace['empty_main_star_status'] ?? ''),
            ];
        }

        $matched = count($rows) === 12
            && $branchMatches === 12
            && $mainStarMatches === 12
            && $palaceNameMatches === 12;

        return [
            'status' => $matched
                ? '12_of_12_branch_and_14_main_star_match_after_alias_normalization'
                : 'strict_subset_mismatch',
            'branch_matches' => $branchMatches,
            'main_star_matches' => $mainStarMatches,
            'palace_name_matches' => $palaceNameMatches,
            'rows' => $rows,
        ];
    }
}
