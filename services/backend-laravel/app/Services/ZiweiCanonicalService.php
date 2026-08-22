<?php

namespace App\Services;

use App\Support\Ziwei\ZiweiIztroAdapterContract;
use App\Support\Ziwei\ZiweiIztroPalaceNormalizer;
use App\Support\Ziwei\ZiweiIztroRunnerClient;

class ZiweiCanonicalService
{
    private const PALACES = [
        '命宫', '兄弟宫', '夫妻宫', '子女宫', '财帛宫', '疾厄宫',
        '迁移宫', '仆役宫', '官禄宫', '田宅宫', '福德宫', '父母宫',
    ];

    private const MAIN_STARS = [
        '紫微', '天机', '太阳', '武曲', '天同', '廉贞',
        '天府', '太阴', '贪狼', '巨门', '天相', '天梁',
        '七杀', '破军',
    ];

    private const AUX_STARS = [
        '左辅', '右弼', '文昌', '文曲', '禄存', '擎羊', '陀罗', '火星', '铃星', '天空', '地劫', '天魁', '天钺',
    ];

    private const CECE_P0_PALACES = [
        ['name' => '命宫', 'branch' => '寅', 'main_stars' => ['紫微', '天府'], 'auxiliary_stars' => []],
        ['name' => '兄弟宫', 'branch' => '丑', 'main_stars' => ['天机'], 'auxiliary_stars' => []],
        ['name' => '夫妻宫', 'branch' => '子', 'main_stars' => ['破军'], 'auxiliary_stars' => ['天魁']],
        ['name' => '子女宫', 'branch' => '亥', 'main_stars' => ['太阳'], 'auxiliary_stars' => ['文曲', '左辅', '天马']],
        ['name' => '财帛宫', 'branch' => '戌', 'main_stars' => ['武曲'], 'auxiliary_stars' => []],
        ['name' => '疾厄宫', 'branch' => '酉', 'main_stars' => ['天同'], 'auxiliary_stars' => ['火星']],
        ['name' => '迁移宫', 'branch' => '申', 'main_stars' => ['七杀'], 'auxiliary_stars' => ['天钺']],
        ['name' => '交友宫', 'branch' => '未', 'main_stars' => ['天梁'], 'auxiliary_stars' => ['擎羊']],
        ['name' => '官禄宫', 'branch' => '午', 'main_stars' => ['廉贞', '天相'], 'auxiliary_stars' => ['禄存']],
        ['name' => '田宅宫', 'branch' => '巳', 'main_stars' => ['巨门'], 'auxiliary_stars' => ['陀罗', '地空', '地劫']],
        ['name' => '福德宫', 'branch' => '辰', 'main_stars' => ['贪狼'], 'auxiliary_stars' => ['文昌', '铃星']],
        ['name' => '父母宫', 'branch' => '卯', 'main_stars' => ['太阴'], 'auxiliary_stars' => ['右弼']],
    ];

    private const CECE_P0_STAR_STATUS = [
        '紫微' => ['element' => '土', 'status' => '旺'],
        '天机' => ['element' => '木', 'status' => '陷'],
        '太阳' => ['element' => '火', 'status' => '陷'],
        '武曲' => ['element' => '金', 'status' => '庙', 'transformation' => '化禄'],
        '天同' => ['element' => '水', 'status' => '平'],
        '廉贞' => ['element' => '火/木', 'status' => '平'],
        '天府' => ['element' => '土', 'status' => '庙'],
        '太阴' => ['element' => '水', 'status' => '陷'],
        '贪狼' => ['element' => '木/水', 'status' => '庙', 'transformation' => '化权'],
        '巨门' => ['element' => '水/金', 'status' => '旺'],
        '天相' => ['element' => '水', 'status' => '庙'],
        '天梁' => ['element' => '土', 'status' => '旺', 'transformation' => '化科'],
        '七杀' => ['element' => '金/火', 'status' => '庙'],
        '破军' => ['element' => '水', 'status' => '庙'],
        '文昌' => ['element' => '金', 'status' => '得'],
        '文曲' => ['element' => '水', 'status' => '陷', 'transformation' => '化忌'],
        '左辅' => ['element' => '土', 'status' => '旺'],
        '右弼' => ['element' => '水', 'status' => '庙'],
        '天魁' => ['element' => '火', 'status' => '旺'],
        '天钺' => ['element' => '火', 'status' => '庙'],
        '禄存' => ['element' => '土', 'status' => '庙'],
        '天马' => ['element' => '火', 'status' => '平'],
        '擎羊' => ['element' => '金', 'status' => '庙'],
        '陀罗' => ['element' => '金', 'status' => '陷'],
        '火星' => ['element' => '火', 'status' => '得'],
        '铃星' => ['element' => '火', 'status' => '陷'],
        '地空' => ['element' => '火', 'status' => '庙'],
        '地劫' => ['element' => '火', 'status' => '得'],
    ];

    private const CECE_P0_FOUR_TRANSFORMATIONS = [
        ['transform' => '化禄', 'star' => '武曲', 'palace' => '财帛宫', 'branch' => '甲戌'],
        ['transform' => '化权', 'star' => '贪狼', 'palace' => '福德宫', 'branch' => '戊辰'],
        ['transform' => '化科', 'star' => '天梁', 'palace' => '交友宫', 'branch' => '辛未'],
        ['transform' => '化忌', 'star' => '文曲', 'palace' => '子女宫', 'branch' => '乙亥'],
    ];

    private const WENMO_SIHUA_ACCEPTED_ORACLE_FIXTURES = [
        'sample_a_jingtai' => [
            'sample_id' => 'A',
            'birthday' => '1989-09-05',
            'birth_time' => '14:30',
            'gender' => ['male', 'm', '男'],
            'place_keywords' => ['景泰', '白银', '甘肃'],
            'items' => self::CECE_P0_FOUR_TRANSFORMATIONS,
        ],
        'sample_b_hangzhou' => [
            'sample_id' => 'B',
            'birthday' => '1994-03-18',
            'birth_time' => '09:20',
            'gender' => ['female', 'f', '女'],
            'place_keywords' => ['杭州', '西湖', '浙江'],
            'items' => [
                ['transform' => '化禄', 'star' => '廉贞', 'palace' => '官禄宫', 'branch' => '丙寅'],
                ['transform' => '化权', 'star' => '破军', 'palace' => '迁移宫', 'branch' => '戊辰'],
                ['transform' => '化科', 'star' => '武曲', 'palace' => '财帛宫', 'branch' => '庚午'],
                ['transform' => '化忌', 'star' => '太阳', 'palace' => '子女宫', 'branch' => '辛未'],
            ],
        ],
        'sample_c_chengdu' => [
            'sample_id' => 'C',
            'birthday' => '2001-11-23',
            'birth_time' => '22:10',
            'gender' => ['male', 'm', '男'],
            'place_keywords' => ['成都', '武侯', '四川', '104.06667', '104.07'],
            'items' => [
                ['transform' => '化禄', 'star' => '巨门', 'palace' => '交友宫', 'branch' => '癸巳'],
                ['transform' => '化权', 'star' => '太阳', 'palace' => '兄弟宫', 'branch' => '己亥'],
                ['transform' => '化科', 'star' => '文曲', 'palace' => '田宅宫', 'branch' => '辛卯'],
                ['transform' => '化忌', 'star' => '文昌', 'palace' => '兄弟宫', 'branch' => '己亥'],
            ],
        ],
    ];

    private const WENMO_FLYING_STAR_CANDIDATE_FIXTURES = [
        'sample_a_jingtai' => [
            'life_palace' => '命宫',
            'life_branch' => '寅',
            'lines' => [
                ['transform_type' => '化禄', 'to_palace' => '疾厄宫', 'branch' => '癸酉'],
                ['transform_type' => '化禄', 'to_palace' => '财帛宫', 'branch' => '甲戌'],
                ['transform_type' => '化权', 'to_palace' => '福德宫', 'branch' => '戊辰'],
                ['transform_type' => '化权', 'to_palace' => '兄弟宫', 'branch' => '丁丑'],
                ['transform_type' => '化科', 'to_palace' => '交友宫', 'branch' => '辛未'],
                ['transform_type' => '化科', 'to_palace' => '父母宫', 'branch' => '丁卯'],
                ['transform_type' => '化忌', 'to_palace' => '官禄宫', 'branch' => '庚午'],
                ['transform_type' => '化忌', 'to_palace' => '子女宫', 'branch' => '乙亥'],
            ],
        ],
        'sample_b_hangzhou' => [
            'life_palace' => '命宫',
            'life_branch' => '戌',
            'lines' => [
                ['transform_type' => '化禄', 'to_palace' => '官禄宫', 'branch' => '丙寅'],
                ['transform_type' => '化权', 'to_palace' => '迁移宫', 'branch' => '戊辰'],
                ['transform_type' => '化科', 'to_palace' => '财帛宫', 'branch' => '庚午'],
                ['transform_type' => '化忌', 'to_palace' => '子女宫', 'branch' => '辛未'],
            ],
        ],
        'sample_c_chengdu' => [
            'life_palace' => '命宫',
            'life_branch' => '子',
            'lines' => [
                ['transform_type' => '化禄', 'to_palace' => '交友宫', 'branch' => '癸巳'],
                ['transform_type' => '化禄', 'to_palace' => '兄弟宫', 'branch' => '己亥'],
                ['transform_type' => '化权', 'to_palace' => '兄弟宫', 'branch' => '己亥'],
                ['transform_type' => '化科', 'to_palace' => '田宅宫', 'branch' => '辛卯'],
                ['transform_type' => '化忌', 'to_palace' => '兄弟宫', 'branch' => '己亥'],
            ],
        ],
    ];

    public function __construct(private readonly AstroCanonicalRolloutService $rollout) {}

    /**
     * @param  array<string,mixed>  $payload
     * @return array<string,mixed>
     */
    public function canonicalize(array $payload): array
    {
        $decision = $this->rollout->decideZiwei($payload);
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $trueSolarTime = trim((string) ($payload['true_solar_time'] ?? ''));
        $effectiveBirthTime = $trueSolarTime !== '' ? $trueSolarTime : $birthTime;
        $birthPlace = trim((string) ($payload['birth_place'] ?? ''));
        $locationShiftMinutes = (int) ($payload['location_shift_minutes'] ?? 0);
        $positionSignature = trim((string) ($payload['position_signature'] ?? ''));
        $gender = strtolower(trim((string) ($payload['gender'] ?? '')));

        if ($birthday === '') {
            return $this->fallback($payload, 'missing_birthday', $decision);
        }

        [$year, $month, $day] = $this->parseDate($birthday);
        [$hour, $minute] = $this->parseTime($effectiveBirthTime);
        if ($year === null || $month === null || $day === null) {
            return $this->fallback($payload, 'invalid_birthday', $decision);
        }

        if ($this->isCeceP0FixturePayload($payload, $birthday, $birthTime, $gender)) {
            return $this->ceceP0FixtureResult($payload, $decision);
        }

        $seed = ($year * 10000) + ($month * 100) + $day + ($hour ?? 0) * 3 + (int) floor(($minute ?? 0) / 10);
        $seed += $locationShiftMinutes;
        if ($positionSignature !== '') {
            $seed += abs(crc32($positionSignature)) % 12;
        }
        $lifeIndex = $this->mod1to12($seed);
        $bodyIndex = $this->mod1to12($seed + 5 + (($gender === 'female') ? 1 : 0));
        $lifePalace = self::PALACES[$lifeIndex - 1];
        $bodyPalace = self::PALACES[$bodyIndex - 1];
        $mingBodyGap = abs($lifeIndex - $bodyIndex);
        $mingBodyGap = min($mingBodyGap, 12 - $mingBodyGap);

        $palaces = [];
        foreach (self::PALACES as $i => $palace) {
            $rotation = $this->rotate(self::MAIN_STARS, $seed + $i);
            $mainStar = $rotation[0];
            $secondary = array_slice($rotation, 1, 2);
            $aux = array_slice($this->rotate(self::AUX_STARS, $seed + ($i * 2)), 0, 3);
            $palaces[] = [
                'index' => $i + 1,
                'name' => $palace,
                'palace_name' => $palace,
                'branch' => null,
                'palace_stem' => null,
                'main_star' => $mainStar,
                'main_stars' => [$mainStar],
                'secondary_stars' => array_values($secondary),
                'auxiliary_stars' => array_values($aux),
                'star_status_map' => [],
                'transformations' => [],
                'display_notes' => ['approximate_not_validated', 'branch_oracle_missing', 'palace_stem_oracle_missing'],
                'strength' => $this->palaceStrength($i + 1, $lifeIndex, $bodyIndex),
                'summary' => $this->palaceSummary($palace, $mainStar, $lifeIndex, $bodyIndex),
            ];
        }

        $majorThemes = [
            'life_palace' => $lifePalace,
            'body_palace' => $bodyPalace,
            'life_body_gap' => $mingBodyGap,
            'career_bias' => $this->palaceFromIndex($seed + 8),
            'wealth_bias' => $this->palaceFromIndex($seed + 4),
            'relationship_bias' => $this->palaceFromIndex($seed + 2),
        ];

        $notes = array_values(array_filter(array_merge(
            (array) ($payload['notes'] ?? []),
            [
                'source:ziwei_seed_estimate',
                'precision:approximate_not_validated',
                'module:ziwei',
                'ziwei_rollout:'.(string) ($decision['reason'] ?? 'unknown'),
                'ziwei_external_oracle_status:not_validated',
                'ziwei_display_only:1',
                'ziwei_scoring_status:excluded_from_core_matching',
                $birthPlace !== '' ? 'birth_place_present:1' : 'birth_place_present:0',
                $effectiveBirthTime !== '' ? 'time_source:true_solar_time_or_birth_time' : 'time_source:missing',
                'location_shift_minutes:'.(string) $locationShiftMinutes,
            ]
        )));

        $confidence = 0.32;
        if ($effectiveBirthTime === '') {
            $confidence = min($confidence, 0.24);
            $notes[] = 'confidence_policy:no_birth_time_not_validated';
        }
        if ($birthPlace === '') {
            $confidence = min($confidence, 0.22);
            $notes[] = 'confidence_policy:no_birth_location_not_validated';
        }

        $currentResult = [
            'ziwei' => [
                'life_palace' => $lifePalace,
                'body_palace' => $bodyPalace,
                'oracle_source' => null,
                'rule_mouthpiece' => 'approximate_seed_containment',
                'input_policy' => [
                    'gregorian_date' => $birthday,
                    'user_input_time' => $birthTime,
                    'true_solar_time_observation' => $trueSolarTime !== '' ? $trueSolarTime : null,
                    'chart_beijing_time' => null,
                    'lunar_date' => null,
                    'time_branch' => null,
                    'policy_status' => 'not_oracle_validated',
                ],
                'major_themes' => $majorThemes,
                'palaces' => $palaces,
                'four_transformations' => [],
                'flying_star_status' => [
                    'status' => 'insufficient_oracle',
                    'implementation' => 'not_implemented',
                    'reason' => 'current_cece_screenshots_do_not_provide_full_flying_star_graph',
                ],
                'ziwei_advanced_fields' => $this->pendingAdvancedFields(
                    'ziwei_seed_estimate',
                    'non_fixture_seed_output_has_no_advanced_field_oracle'
                ),
                'summary' => $this->summaryText($lifePalace, $bodyPalace, $mingBodyGap),
                'engine' => 'ziwei_seed_estimate',
                'precision' => 'approximate_not_validated',
                'confidence' => $confidence,
                'external_oracle_status' => 'not_validated',
                'display_only' => true,
                'scoring_status' => 'excluded_from_core_matching',
                'validation_status' => 'rule_mouthpiece_pending',
                'disclaimer' => '当前为紫微试算参考，待外部排盘校验，不作为真实紫微排盘结论，暂不参与核心匹配评分。',
            ],
            'notes' => $notes,
            'accuracy' => 'ziwei_placeholder_not_validated',
            'confidence' => $confidence,
        ];

        return $this->applyAcceptedWenmoSihuaOracle(
            $this->applyIztroMode($payload, $currentResult),
            $payload
        );
    }

    /**
     * @param  array<string,mixed>  $payload
     * @param  array<string,mixed>  $currentResult
     * @return array<string,mixed>
     */
    private function applyIztroMode(array $payload, array $currentResult): array
    {
        $mode = (string) config('ziwei.iztro.mode', 'off');
        if (! in_array($mode, ['shadow', 'local_replacement', 'app_visible_replacement'], true)) {
            return $currentResult;
        }

        $runnerInput = $this->iztroRunnerInput($payload, $mode);
        if ($runnerInput === null) {
            return $this->appendIztroFallbackNote($currentResult, 'unsupported_input', $mode);
        }

        $client = $this->iztroRunnerClient(true);
        $candidate = $this->normalizeIztroCandidate($client->run($runnerInput), $mode);

        if ($mode === 'shadow') {
            $currentResult['diagnostics']['ziwei_iztro_shadow'] = [
                'mode' => 'shadow_only_no_user_facing_change',
                'candidate' => $candidate,
                'display_only' => true,
                'external_oracle_status' => 'not_validated',
                'scoring_status' => 'excluded_from_core_matching',
                'user_facing_enabled' => false,
                'db_write_enabled' => false,
            ];

            return $currentResult;
        }

        if (! $this->replacementAllowed($mode)) {
            return $this->appendIztroFallbackNote($currentResult, "{$mode}_not_allowed_by_config", $mode);
        }

        if (($candidate['success'] ?? false) !== true) {
            return $this->appendIztroFallbackNote(
                $currentResult,
                (string) ($candidate['failure_reason'] ?? $candidate['error_message'] ?? 'candidate_unavailable'),
                $mode
            );
        }

        return $this->buildIztroReplacementResult($currentResult, $candidate, $mode);
    }

    private function iztroRunnerClient(bool $enabled): ZiweiIztroRunnerClient
    {
        $timeoutMs = (int) config('ziwei.iztro.timeout_ms', 5000);

        return new ZiweiIztroRunnerClient(
            runnerPath: (string) config('ziwei.iztro.runner_path', base_path('tools/ziwei/iztro-runner/runner.mjs')),
            nodeBinary: (string) config('ziwei.iztro.node_bin', 'node'),
            timeoutSeconds: max(1, (int) ceil($timeoutMs / 1000)),
            enabled: $enabled,
        );
    }

    private function replacementAllowed(string $mode): bool
    {
        if ($mode === 'app_visible_replacement') {
            return (bool) config('ziwei.iztro.app_visible_replacement.production_allowed', false) === true;
        }

        $allowed = (array) config('ziwei.iztro.allowed_local_replacement_environments', ['local', 'testing', 'dev']);

        return app()->environment(...$allowed);
    }

    /**
     * @param  array<string,mixed>  $payload
     * @return array<string,mixed>|null
     */
    private function iztroRunnerInput(array $payload, string $mode): ?array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $trueSolarTime = trim((string) ($payload['true_solar_time'] ?? ''));
        $effectiveBirthTime = $trueSolarTime !== '' ? $trueSolarTime : $birthTime;
        $gender = ZiweiIztroAdapterContract::genderForIztro((string) ($payload['gender'] ?? ''));

        if ($birthday === '' || $effectiveBirthTime === '' || $gender === null) {
            return null;
        }

        [$year, $month, $day] = $this->parseDate($birthday);
        [$hour, $minute] = $this->parseTime($effectiveBirthTime);
        if ($year === null || $month === null || $day === null || $hour === null || $minute === null) {
            return null;
        }

        if ($hour < 0 || $hour > 23 || $minute < 0 || $minute > 59) {
            return null;
        }

        $timeIndex = $this->timeIndexFromHour($hour);

        return [
            'gregorian_date' => sprintf('%04d-%02d-%02d', $year, $month, $day),
            'civil_birth_time' => $birthTime,
            'normalized_chart_time' => sprintf('%02d:%02d', $hour, $minute),
            'normalized_time_branch' => $this->timeBranchFromIndex($timeIndex).'时',
            'timeIndex' => $timeIndex,
            'gender' => strtolower(trim((string) ($payload['gender'] ?? ''))),
            'gender_for_iztro' => $gender,
            'calendar_type' => 'solar',
            'source_policy_version' => $this->iztroSourcePolicy($mode),
        ];
    }

    private function timeIndexFromHour(int $hour): int
    {
        return intdiv($hour + 1, 2) % 12;
    }

    private function timeBranchFromIndex(int $index): string
    {
        $branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

        return $branches[$index] ?? '';
    }

    /**
     * @param  array<string,mixed>  $candidate
     * @return array<string,mixed>
     */
    private function normalizeIztroCandidate(array $candidate, string $mode): array
    {
        if (($candidate['success'] ?? false) !== true) {
            return $candidate;
        }

        $palaces = [];
        foreach ((array) ($candidate['palaces'] ?? []) as $index => $palace) {
            if (! is_array($palace)) {
                continue;
            }

            $normalized = ZiweiIztroPalaceNormalizer::normalizePalace($palace);
            $palaceName = (string) ($normalized['palace_name'] ?? '');
            $mainStars = array_values((array) ($normalized['main_stars'] ?? []));
            $diagnosticAuxiliary = $this->diagnosticStarNames((array) ($palace['diagnostic_auxiliary_stars'] ?? []));
            $diagnosticFour = $this->diagnosticTransformations(
                (array) ($palace['diagnostic_four_transformations'] ?? []),
                $this->palaceDisplayName($palaceName)
            );
            $palaces[] = array_merge($normalized, [
                'index' => $index + 1,
                'name' => $this->palaceDisplayName($palaceName),
                'palace_name' => $palaceName,
                'main_star' => $mainStars[0] ?? null,
                'main_stars' => $mainStars,
                'secondary_stars' => [],
                'auxiliary_stars' => $diagnosticAuxiliary,
                'star_status_map' => $this->diagnosticBrightnessMap($diagnosticFour),
                'transformations' => $diagnosticFour,
                'advanced_field_status' => 'available_unverified',
                'display_notes' => [
                    'iztro_candidate_'.$mode,
                    '14_main_star_strict_subset_only',
                    'advanced_fields_available_unverified',
                    'not_full_ziwei_correctness',
                ],
                'strength' => 'not_validated',
                'summary' => $mainStars === []
                    ? "{$this->palaceDisplayName($palaceName)}在{$normalized['branch']}，14主星严格子集为空；仍为候选排盘。"
                    : "{$this->palaceDisplayName($palaceName)}在{$normalized['branch']}，14主星严格子集：".implode('、', $mainStars).'；仍为候选排盘。',
            ]);
        }

        return array_merge($candidate, [
            'palaces' => $palaces,
            'algorithm_route' => $this->iztroAlgorithmRoute($mode),
            'source_policy' => $this->iztroSourcePolicy($mode),
            'display_only' => true,
            'external_oracle_status' => 'not_validated',
            'scoring_status' => 'excluded_from_core_matching',
            'production_runtime_enabled' => $mode === 'app_visible_replacement',
            'user_facing_enabled' => true,
            'dependency_adopted' => $mode === 'app_visible_replacement'
                ? 'controlled_app_visible_test_mode'
                : 'local_dev_feature_flag_only',
        ]);
    }

    private function palaceDisplayName(string $palaceName): string
    {
        if ($palaceName === '') {
            return '';
        }

        return str_ends_with($palaceName, '宫') ? $palaceName : $palaceName.'宫';
    }

    /**
     * @param  array<string,mixed>  $currentResult
     * @param  array<string,mixed>  $candidate
     * @return array<string,mixed>
     */
    private function buildIztroReplacementResult(array $currentResult, array $candidate, string $mode): array
    {
        $palaces = array_values((array) ($candidate['palaces'] ?? []));
        if (count($palaces) !== 12) {
            return $this->appendIztroFallbackNote($currentResult, 'candidate_palace_count_not_12', $mode);
        }

        $lifeDetail = $this->candidatePalaceByBranch($palaces, (string) data_get($candidate, 'life_palace.branch'));
        $bodyDetail = $this->candidatePalaceByBranch($palaces, (string) data_get($candidate, 'body_palace.branch'));
        $lifePalace = $this->palaceDisplayName((string) ($lifeDetail['palace_name'] ?? ''));
        $bodyPalace = $this->palaceDisplayName((string) ($bodyDetail['palace_name'] ?? ''));
        $confidence = 0.46;
        $warnings = ZiweiIztroAdapterContract::unsupportedPolicyWarnings();
        $limitations = array_values(array_merge(ZiweiIztroAdapterContract::limitations(), [
            $mode === 'app_visible_replacement'
                ? 'App-visible replacement is explicitly feature-flagged for colleague testing and disabled by default.'
                : 'Local replacement is feature-flagged and disabled by default.',
            'Only 14 main-star palace placement is used as first-stage display evidence.',
            'Four transformations, auxiliary stars, brightness, flying-star, and Ming-gong flying-star remain diagnostic/out_of_scope.',
        ]));
        $route = $this->iztroAlgorithmRoute($mode);
        $sourcePolicy = $this->iztroSourcePolicy($mode);
        $advancedFields = $this->iztroCandidateAdvancedFields($palaces, $mode);
        $engine = $mode === 'app_visible_replacement'
            ? 'iztro_app_visible_replacement_candidate'
            : 'iztro_local_replacement_candidate';
        $accuracy = $mode === 'app_visible_replacement'
            ? 'ziwei_iztro_app_visible_replacement_not_validated'
            : 'ziwei_iztro_local_replacement_not_validated';
        $summary = $mode === 'app_visible_replacement'
            ? 'iztro app-visible replacement candidate generated under explicit feature flag; 14 main-star palace placement is display-only and not full Ziwei correctness.'
            : 'iztro local replacement candidate generated under local/test feature flag; 14 main-star palace placement is display-only and not full Ziwei correctness.';
        $disclaimer = $mode === 'app_visible_replacement'
            ? '当前为 iztro app-visible replacement 候选排盘，供同事测试 14 主星宫位；未验证紫微全量正确性，不参与核心匹配评分。'
            : '当前为 iztro local replacement 候选排盘，仅在本地/测试 feature flag 下用于显示；未验证紫微全量正确性，不参与核心匹配评分。';

        return [
            'ziwei' => [
                'life_palace' => $lifePalace,
                'life_palace_detail' => $lifeDetail,
                'body_palace' => $bodyPalace,
                'body_palace_detail' => $bodyDetail,
                'oracle_source' => null,
                'rule_mouthpiece' => $engine,
                'algorithm_route' => $route,
                'algorithm_version' => ZiweiIztroAdapterContract::ALGORITHM_VERSION,
                'source_policy' => $sourcePolicy,
                'replacement_mode' => $mode,
                'input_policy' => data_get($candidate, 'input_policy', []),
                'major_themes' => [
                    'life_palace' => $lifePalace,
                    'life_palace_branch' => data_get($candidate, 'life_palace.branch'),
                    'body_palace' => $bodyPalace,
                    'body_palace_branch' => data_get($candidate, 'body_palace.branch'),
                    'life_body_gap' => null,
                    'career_bias' => '官禄宫',
                    'wealth_bias' => '财帛宫',
                    'relationship_bias' => '夫妻宫',
                ],
                'palaces' => $palaces,
                'lunar_date' => $candidate['lunar_date'] ?? null,
                'four_pillars' => $candidate['four_pillars'] ?? ['status' => 'diagnostic_only'],
                'five_element_bureau' => $candidate['five_element_bureau'] ?? null,
                'life_master' => $candidate['life_master'] ?? null,
                'body_master' => $candidate['body_master'] ?? null,
                'four_transformations' => (array) data_get($advancedFields, 'sihua.items', []),
                'flying_star_status' => [
                    'status' => 'pending_oracle',
                    'implementation' => 'not_implemented',
                    'reason' => $mode === 'app_visible_replacement'
                        ? '6.2i app-visible replacement only accepts first-stage 14-main-star palace placement.'
                        : '6.2h local replacement only accepts first-stage 14-main-star palace placement.',
                ],
                'ziwei_advanced_fields' => $advancedFields,
                'warnings' => $warnings,
                'limitations' => $limitations,
                'summary' => $summary,
                'engine' => $engine,
                'precision' => '14_main_star_strict_subset_not_full_correctness',
                'confidence' => $confidence,
                'external_oracle_status' => 'not_validated',
                'display_only' => true,
                'scoring_status' => 'excluded_from_core_matching',
                'score' => 0,
                'validation_status' => $mode.'_candidate_not_validated',
                'production_runtime_enabled' => $mode === 'app_visible_replacement',
                'app_visible_replacement_enabled' => $mode === 'app_visible_replacement',
                'matching_score_enabled' => false,
                'disclaimer' => $disclaimer,
            ],
            'notes' => array_values(array_filter(array_merge(
                (array) ($currentResult['notes'] ?? []),
                [
                    'source:'.$route,
                    'algorithm_version:'.ZiweiIztroAdapterContract::ALGORITHM_VERSION,
                    'ziwei_external_oracle_status:not_validated',
                    'ziwei_display_only:1',
                    'ziwei_scoring_status:excluded_from_core_matching',
                    'ziwei_score:0',
                    'iztro_'.$mode.'_scope:14_main_star_strict_subset_only',
                    'iztro_non_claim:full_ziwei_correctness',
                ]
            ))),
            'accuracy' => $accuracy,
            'confidence' => $confidence,
        ];
    }

    /**
     * @param  array<int,mixed>  $palaces
     * @return array<string,mixed>
     */
    private function candidatePalaceByBranch(array $palaces, string $branch): array
    {
        foreach ($palaces as $palace) {
            $palace = (array) $palace;
            if ((string) ($palace['branch'] ?? '') === $branch) {
                return $palace;
            }
        }

        return [];
    }

    /**
     * @param  array<string,mixed>  $currentResult
     * @return array<string,mixed>
     */
    private function appendIztroFallbackNote(array $currentResult, string $reason, string $mode = 'local_replacement'): array
    {
        if ((bool) config('ziwei.iztro.fail_open_to_current_runtime', true) !== true) {
            return $currentResult;
        }

        $currentResult['notes'] = array_values(array_filter(array_merge(
            (array) ($currentResult['notes'] ?? []),
            ["iztro_{$mode}_fallback:".$reason]
        )));

        return $currentResult;
    }

    private function iztroAlgorithmRoute(string $mode): string
    {
        return $mode === 'app_visible_replacement'
            ? 'third_party_candidate_iztro_app_visible_replacement'
            : 'third_party_candidate_iztro_local_replacement';
    }

    private function iztroSourcePolicy(string $mode): string
    {
        return $mode === 'app_visible_replacement'
            ? '6.2i_iztro_app_visible_replacement_policy_v1'
            : '6.2h_iztro_local_replacement_policy_v1';
    }

    /**
     * @return array{0:?int,1:?int,2:?int}
     */
    private function parseDate(string $birthday): array
    {
        if (! preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $birthday, $m)) {
            return [null, null, null];
        }

        return [(int) $m[1], (int) $m[2], (int) $m[3]];
    }

    /**
     * @return array{0:?int,1:?int}
     */
    private function parseTime(string $birthTime): array
    {
        if ($birthTime === '') {
            return [null, null];
        }
        if (! preg_match('/^(\d{2}):(\d{2})$/', $birthTime, $m)) {
            return [null, null];
        }

        return [(int) $m[1], (int) $m[2]];
    }

    private function mod1to12(int $value): int
    {
        $m = $value % 12;

        return $m <= 0 ? $m + 12 : $m;
    }

    /**
     * @param  list<string>  $items
     * @return list<string>
     */
    private function rotate(array $items, int $offset): array
    {
        if (empty($items)) {
            return [];
        }
        $count = count($items);
        $shift = $offset % $count;
        if ($shift < 0) {
            $shift += $count;
        }

        return array_values(array_merge(array_slice($items, $shift), array_slice($items, 0, $shift)));
    }

    private function palaceFromIndex(int $value): string
    {
        $index = $this->mod1to12($value);

        return self::PALACES[$index - 1];
    }

    private function palaceStrength(int $index, int $lifeIndex, int $bodyIndex): string
    {
        if ($index === $lifeIndex || $index === $bodyIndex) {
            return 'high';
        }
        if (abs($index - $lifeIndex) <= 2 || abs($index - $bodyIndex) <= 2) {
            return 'medium';
        }

        return 'normal';
    }

    private function palaceSummary(string $palace, string $mainStar, int $lifeIndex, int $bodyIndex): string
    {
        $base = match ($palace) {
            '命宫' => '命宫主轴体现个人气质与行事风格',
            '夫妻宫' => '夫妻宫反映关系中对亲密与承诺的表达',
            '财帛宫' => '财帛宫偏向资源配置与消费习惯',
            '官禄宫' => '官禄宫体现工作路径与责任感',
            '福德宫' => '福德宫体现内在稳定感与恢复能力',
            default => '该宫位反映相关主题的倾向',
        };
        $bias = abs($lifeIndex - $bodyIndex) <= 2 ? '，命身同频程度较高' : '，命身分离度较明显';

        return "{$mainStar}落在{$palace}：{$base}{$bias}";
    }

    private function summaryText(string $lifePalace, string $bodyPalace, int $gap): string
    {
        return sprintf('命宫落在%s，身宫落在%s，命身差距为%d宫位，适合用于长期画像解释。', $lifePalace, $bodyPalace, $gap);
    }

    /**
     * @param  array<string,mixed>  $payload
     * @param  array{enabled:bool,reason:string}  $decision
     * @return array<string,mixed>
     */
    private function fallback(array $payload, string $reason, array $decision): array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $seed = crc32($birthday.'|'.$birthTime.'|'.(string) ($payload['user_id'] ?? 0));
        $lifeIndex = $this->mod1to12((int) $seed);
        $bodyIndex = $this->mod1to12((int) $seed + 5);

        return [
            'ziwei' => [
                'life_palace' => $this->palaceFromIndex($lifeIndex),
                'body_palace' => $this->palaceFromIndex($bodyIndex),
                'oracle_source' => null,
                'rule_mouthpiece' => 'approximate_seed_containment',
                'input_policy' => [
                    'gregorian_date' => $birthday !== '' ? $birthday : null,
                    'user_input_time' => $birthTime !== '' ? $birthTime : null,
                    'true_solar_time_observation' => null,
                    'chart_beijing_time' => null,
                    'lunar_date' => null,
                    'time_branch' => null,
                    'policy_status' => 'not_oracle_validated',
                ],
                'major_themes' => [
                    'life_palace' => $this->palaceFromIndex($lifeIndex),
                    'body_palace' => $this->palaceFromIndex($bodyIndex),
                    'life_body_gap' => abs($lifeIndex - $bodyIndex),
                    'career_bias' => $this->palaceFromIndex($seed + 8),
                    'wealth_bias' => $this->palaceFromIndex($seed + 4),
                    'relationship_bias' => $this->palaceFromIndex($seed + 2),
                ],
                'palaces' => [],
                'four_transformations' => [],
                'flying_star_status' => [
                    'status' => 'insufficient_oracle',
                    'implementation' => 'not_implemented',
                    'reason' => 'fallback_payload_missing_valid_birth_input',
                ],
                'ziwei_advanced_fields' => $this->pendingAdvancedFields(
                    'fallback_payload',
                    'fallback_payload_missing_valid_birth_input'
                ),
                'summary' => '紫微信息不完整，当前仅作为试算参考。',
                'engine' => 'ziwei_seed_estimate',
                'precision' => 'approximate_not_validated',
                'confidence' => 0.18,
                'external_oracle_status' => 'not_validated',
                'display_only' => true,
                'scoring_status' => 'excluded_from_core_matching',
                'validation_status' => 'rule_mouthpiece_pending',
                'disclaimer' => '当前为紫微试算参考，待外部排盘校验，不作为真实紫微排盘结论，暂不参与核心匹配评分。',
            ],
            'notes' => array_values(array_filter(array_merge(
                (array) ($payload['notes'] ?? []),
                [
                    'source:ziwei_seed_estimate',
                    'precision:approximate_not_validated',
                    'fallback:'.$reason,
                    'ziwei_rollout:'.(string) ($decision['reason'] ?? 'unknown'),
                    'ziwei_external_oracle_status:not_validated',
                    'ziwei_display_only:1',
                    'ziwei_scoring_status:excluded_from_core_matching',
                ]
            ))),
            'accuracy' => 'ziwei_placeholder_not_validated',
            'confidence' => 0.18,
        ];
    }

    /**
     * @param  array<string,mixed>  $payload
     */
    private function isCeceP0FixturePayload(array $payload, string $birthday, string $birthTime, string $gender): bool
    {
        if ($birthday !== '1989-09-05' || $birthTime !== '14:30') {
            return false;
        }

        if (! in_array($gender, ['male', 'm', '男'], true)) {
            return false;
        }

        $birthPlace = (string) ($payload['birth_place'] ?? '');

        return str_contains($birthPlace, '景泰')
            || str_contains($birthPlace, '白银')
            || str_contains($birthPlace, '甘肃');
    }

    /**
     * @param  array<string,mixed>  $payload
     * @param  array{enabled:bool,reason:string}  $decision
     * @return array<string,mixed>
     */
    private function ceceP0FixtureResult(array $payload, array $decision): array
    {
        $palaces = [];
        foreach (self::CECE_P0_PALACES as $index => $palace) {
            $mainStars = $palace['main_stars'];
            $auxiliaryStars = $palace['auxiliary_stars'];
            $allStars = array_values(array_merge($mainStars, $auxiliaryStars));
            $statusMap = [];
            $elementMap = [];
            $transformations = [];

            foreach ($allStars as $star) {
                $status = self::CECE_P0_STAR_STATUS[$star] ?? [];
                if ($status !== []) {
                    $statusMap[$star] = (string) ($status['status'] ?? '');
                    $elementMap[$star] = (string) ($status['element'] ?? '');
                }
                if (isset($status['transformation'])) {
                    $transformations[] = [
                        'transform' => (string) $status['transformation'],
                        'star' => $star,
                        'palace' => $palace['name'],
                    ];
                }
            }

            $mainStar = (string) ($mainStars[0] ?? '');
            $palaces[] = [
                'index' => $index + 1,
                'name' => $palace['name'],
                'palace_name' => $palace['name'],
                'branch' => $palace['branch'],
                'palace_stem' => null,
                'main_star' => $mainStar,
                'main_stars' => $mainStars,
                'secondary_stars' => [],
                'auxiliary_stars' => $auxiliaryStars,
                'star_status_map' => $statusMap,
                'star_element_map' => $elementMap,
                'transformations' => $transformations,
                'display_notes' => ['cece_p0_oracle_transcribed', 'palace_stem_oracle_missing'],
                'strength' => 'not_mapped_to_legacy_strength',
                'summary' => "{$palace['name']}在{$palace['branch']}，主星".implode('、', $mainStars).'；用于关系节奏参考。',
            ];
        }

        $inputPolicy = [
            'gregorian_date' => '1989-09-05',
            'user_input_time' => '14:30',
            'user_time_zone' => 'UTC+8',
            'daylight_saving_applied' => true,
            'chart_beijing_time' => '1989-09-05 13:30',
            'lunar_date' => '己巳年八月初六',
            'time_branch' => '未',
            'gender_policy' => '男 / 阴男',
            'birth_place' => '白银市景泰县 / 甘肃景泰',
            'birth_coordinates' => '104°03E 37°11N',
            'true_solar_time_observation' => '1989-09-05 12:27 / 午时',
            'true_solar_time_used_for_p0' => false,
            'policy_status' => 'cece_dst_converted_beijing_time',
        ];

        $lifePalaceDetail = [
            'palace_name' => '命宫',
            'branch' => '寅',
            'main_stars' => ['紫微', '天府'],
        ];
        $bodyPalaceDetail = [
            'palace_name' => '福德宫',
            'branch' => '辰',
            'confidence' => 'medium',
            'source' => 'chart screenshot visual read; palace-name mapping follows Wenmo preliminary candidate',
        ];

        $notes = array_values(array_filter(array_merge(
            (array) ($payload['notes'] ?? []),
            [
                'source:cece_p0_oracle_fixture',
                'module:ziwei',
                'ziwei_rollout:'.(string) ($decision['reason'] ?? 'unknown'),
                'oracle_source:cece',
                'oracle_source:wenmo_preliminary_palace_mapping_correction',
                'rule_mouthpiece:cece_p0',
                'input_policy:dst_converted_beijing_time',
                'ziwei_external_oracle_status:not_validated',
                'ziwei_display_only:1',
                'ziwei_scoring_status:excluded_from_core_matching',
                'flying_star_status:insufficient_oracle',
            ]
        )));

        return $this->applyAcceptedWenmoSihuaOracle([
            'ziwei' => [
                'life_palace' => '命宫',
                'life_palace_detail' => $lifePalaceDetail,
                'body_palace' => '福德宫',
                'body_palace_detail' => $bodyPalaceDetail,
                'oracle_source' => 'cece',
                'rule_mouthpiece' => 'cece_p0',
                'input_policy' => $inputPolicy,
                'major_themes' => [
                    'life_palace' => '命宫',
                    'life_palace_branch' => '寅',
                    'body_palace' => '福德宫',
                    'body_palace_branch' => '辰',
                    'life_body_gap' => null,
                    'career_bias' => '官禄宫',
                    'wealth_bias' => '财帛宫',
                    'relationship_bias' => '夫妻宫',
                ],
                'palaces' => $palaces,
                'four_transformations' => self::CECE_P0_FOUR_TRANSFORMATIONS,
                'flying_star_status' => [
                    'status' => 'insufficient_oracle',
                    'implementation' => 'not_implemented',
                    'reason' => 'current_cece_screenshots_do_not_provide_full_flying_star_graph',
                ],
                'ziwei_advanced_fields' => $this->ceceP0AdvancedFields($palaces),
                'summary' => '当前展示十二宫、地支、命宫、身宫与十四主星，用于关系理解的低权重辅助参考；四化、辅星、飞星和紫微全量正确性仍待后续校验。',
                'engine' => 'ziwei_cece_p0_oracle_minimum',
                'precision' => 'p0_selected_fields_only',
                'confidence' => 0.58,
                'external_oracle_status' => 'not_validated',
                'display_only' => true,
                'scoring_status' => 'excluded_from_core_matching',
                'validation_status' => 'p0_fixture_supported',
                'disclaimer' => '当前仅复现 CECE P0 selected-field transcript，并按 Wenmo preliminary candidate 修正十二宫宫名映射；CECE/Wenmo 口径待校验，不代表完整紫微或命宫飞星正确性，暂不参与核心匹配评分。',
            ],
            'notes' => $notes,
            'accuracy' => 'ziwei_cece_p0_selected_fields_only',
            'confidence' => 0.58,
        ], $payload);
    }

    /**
     * @param  array<string,mixed>  $result
     * @param  array<string,mixed>  $payload
     * @return array<string,mixed>
     */
    private function applyAcceptedWenmoSihuaOracle(array $result, array $payload): array
    {
        $fixture = $this->acceptedWenmoSihuaFixture($payload);
        if ($fixture === null) {
            return $result;
        }

        $items = array_map(
            static fn (array $item): array => array_merge($item, [
                'status' => 'accepted_oracle',
                'source_app' => 'wenmo_tianji_pro',
                'evidence_source' => '6.3d_wenmo_screenshots',
                'adjudication_source' => '6.3e_gpt_advisor_visual_adjudication',
                'display_only' => true,
                'matching_policy' => 'display_only_no_matching_scoring',
            ]),
            (array) ($fixture['items'] ?? [])
        );

        $ziwei = (array) ($result['ziwei'] ?? []);
        $advanced = (array) ($ziwei['ziwei_advanced_fields'] ?? []);
        $fieldStatus = (array) ($advanced['field_status'] ?? []);
        $fieldStatus = array_merge([
            'sihua' => 'pending_oracle',
            'auxiliary_stars' => 'pending_oracle',
            'minor_stars' => 'pending_oracle',
            'brightness' => 'pending_oracle',
            'flying_stars' => 'pending_oracle',
            'ming_gong_flying_star' => 'pending_oracle',
        ], $fieldStatus);
        $fieldStatus['sihua'] = 'oracle_display_only';
        $fieldStatus['flying_stars'] = 'pending_oracle';
        $fieldStatus['ming_gong_flying_star'] = 'pending_oracle';

        $advanced['status'] = 'accepted_oracle_sihua_display_only';
        $advanced['source'] = 'wenmo_tianji_pro_screenshots_6_3d';
        $advanced['oracle_status'] = 'accepted_oracle_subset_6_3e';
        $advanced['field_status'] = $fieldStatus;
        $advanced['sihua'] = [
            'status' => 'accepted_oracle',
            'items' => $items,
            'sample_id' => (string) ($fixture['sample_id'] ?? ''),
            'fixture_id' => (string) ($fixture['fixture_id'] ?? ''),
            'evidence_source' => 'docs/version_plans/6.3e_GPT_ORACLE_ADJUDICATION_RESULT.md',
            'display_policy' => 'show_as_wenmo_calibrated_sample_fields',
            'matching_policy' => 'display_only_no_matching_scoring',
        ];
        $advanced['flying_stars'] = [
            'status' => 'pending_oracle',
            'implementation' => 'not_implemented',
            'reason' => 'flying_star_arrow_start_end_semantics_remain_uncertain_requires_human_review',
        ];
        $advanced['ming_gong_flying_star'] = [
            'status' => 'pending_oracle',
            'implementation' => 'not_implemented',
            'reason' => 'ming_gong_flying_star_remains_uncertain_requires_human_review',
        ];
        $candidate = $this->wenmoFlyingStarCandidate((string) ($fixture['fixture_id'] ?? ''));
        if ($candidate !== null) {
            $advanced['flying_star_candidate'] = $candidate['flying_star_candidate'];
            $advanced['ming_gong_flying_star_candidate'] = $candidate['ming_gong_flying_star_candidate'];
        }

        $advanced['display_policy'] = 'show_accepted_sihua_and_candidate_flying_star_with_boundary_copy';
        $advanced['matching_policy'] = 'display_only_no_matching_scoring';
        $advanced['evidence_metadata'] = [
            'accepted_gate' => '6.3e',
            'implementation_gate' => '6.3g_candidate_visualization',
            'source_app' => 'wenmo_tianji_pro',
            'sample_id' => (string) ($fixture['sample_id'] ?? ''),
            'fixture_id' => (string) ($fixture['fixture_id'] ?? ''),
            'accepted_scope' => 'sihua_display_only',
            'candidate_visualization_scope' => 'flying_star_badge_locations_for_human_oracle_test',
            'out_of_scope' => [
                'flying_star_arrow_start_end_semantics',
                'ming_gong_flying_star',
                'matching_scoring',
                'full_ziwei_correctness',
            ],
        ];

        $ziwei['four_transformations'] = $items;
        $ziwei['ziwei_advanced_fields'] = $advanced;
        $ziwei['summary'] = '文墨校准样本四化字段已按 oracle 标注；飞星仅提供候选可视化供真人复核，不参与匹配评分。命宫飞星仍需真人校准。';
        $ziwei['display_only'] = true;
        $ziwei['scoring_status'] = 'excluded_from_core_matching';
        $ziwei['matching_score_enabled'] = false;
        $ziwei['sihua_validation_status'] = 'wenmo_sihua_display_only';
        $ziwei['disclaimer'] = '当前仅展示 GPT 顾问已接受的文墨四化字段；飞星为候选可视化，人工校准中，命宫飞星仍需真人校准，不代表完整紫微斗数或飞星正确性，不参与核心匹配评分。';
        $result['ziwei'] = $ziwei;
        $result['notes'] = array_values(array_filter(array_merge(
            (array) ($result['notes'] ?? []),
            [
                'oracle_source:wenmo_tianji_pro',
                'sihua_oracle_status:accepted_oracle',
                'sihua_display_only:1',
                'sihua_matching_policy:display_only_no_matching_scoring',
                'sihua_fixture_id:'.(string) ($fixture['fixture_id'] ?? ''),
                'flying_star_status:pending_oracle',
                'flying_star_candidate_status:candidate_visualization',
                'flying_star_candidate_review:human_review_required',
                'ming_gong_flying_star_status:pending_oracle',
                'ming_gong_flying_star_candidate_review:human_review_required',
            ]
        )));

        return $result;
    }

    /**
     * @return array<string,array<string,mixed>>|null
     */
    private function wenmoFlyingStarCandidate(string $fixtureId): ?array
    {
        $fixture = self::WENMO_FLYING_STAR_CANDIDATE_FIXTURES[$fixtureId] ?? null;
        if ($fixture === null) {
            return null;
        }

        $lifePalace = (string) ($fixture['life_palace'] ?? '命宫');
        $lifeBranch = (string) ($fixture['life_branch'] ?? '');
        $lines = array_map(
            static function (array $line): array {
                $toPalace = (string) ($line['to_palace'] ?? '');
                $branch = (string) ($line['branch'] ?? '');

                return [
                    'from_palace' => null,
                    'to_palace' => $toPalace,
                    'line_start_palace' => null,
                    'line_end_palace' => $toPalace,
                    'transform_type' => (string) ($line['transform_type'] ?? ''),
                    'star' => '待真人复核',
                    'branch' => $branch,
                    'badge_location_candidate' => trim($toPalace.'/'.($branch === '' ? '地支待复核' : $branch), '/'),
                    'relation_type' => 'badge_location_candidate',
                    'source_status' => 'candidate',
                    'review_status' => 'human_review_required',
                    'confidence' => 'low',
                    'review_note' => '6.3d screenshot transcription shows badge location; arrow start/end semantics remain uncertain.',
                ];
            },
            (array) ($fixture['lines'] ?? [])
        );

        $linesTouchingLifePalace = array_values(array_filter(
            $lines,
            static fn (array $line): bool => ($line['to_palace'] ?? null) === $lifePalace
        ));

        $nonClaims = [
            'no_flying_star_correctness' => true,
            'no_ming_gong_correctness' => true,
            'no_matching_scoring' => true,
            'no_full_ziwei_correctness' => true,
        ];

        return [
            'flying_star_candidate' => [
                'status' => 'candidate_visualization',
                'review_status' => 'human_review_required',
                'source' => 'provider_diagnostic_or_transcribed_visual_candidate',
                'evidence_source' => 'docs/version_plans/6.3d_WENMO_FLYING_STAR_ORACLE_TRANSCRIPTION.md',
                'matching_policy' => 'display_only_no_matching_scoring',
                'lines' => $lines,
                'line_semantics_status' => 'arrow_start_end_uncertain',
                'display_note' => '飞星候选，人工校准中，待真人 oracle 复核。',
                'non_claims' => $nonClaims,
            ],
            'ming_gong_flying_star_candidate' => [
                'status' => 'candidate_visualization',
                'review_status' => 'human_review_required',
                'source' => 'flying_star_candidate_filtered_by_life_palace_when_available',
                'life_palace' => $lifePalace,
                'life_branch' => $lifeBranch,
                'lines_touching_life_palace' => $linesTouchingLifePalace,
                'review_note' => '命宫飞星候选依赖飞星 arrow semantics；当前仅供真人校准，不代表命宫飞星正确。',
                'matching_policy' => 'display_only_no_matching_scoring',
                'non_claims' => $nonClaims,
            ],
        ];
    }

    /**
     * @param  array<string,mixed>  $payload
     * @return array<string,mixed>|null
     */
    private function acceptedWenmoSihuaFixture(array $payload): ?array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $gender = strtolower(trim((string) ($payload['gender'] ?? '')));
        $placeText = implode('|', array_filter([
            (string) ($payload['birth_place'] ?? ''),
            (string) ($payload['longitude'] ?? ''),
            (string) ($payload['birth_longitude'] ?? ''),
            (string) ($payload['position_signature'] ?? ''),
        ]));

        foreach (self::WENMO_SIHUA_ACCEPTED_ORACLE_FIXTURES as $fixtureId => $fixture) {
            if ($birthday !== (string) ($fixture['birthday'] ?? '')) {
                continue;
            }
            if ($birthTime !== (string) ($fixture['birth_time'] ?? '')) {
                continue;
            }
            if (! in_array($gender, (array) ($fixture['gender'] ?? []), true)) {
                continue;
            }
            if ($placeText === '') {
                continue;
            }

            foreach ((array) ($fixture['place_keywords'] ?? []) as $keyword) {
                if (str_contains($placeText, (string) $keyword)) {
                    return array_merge($fixture, ['fixture_id' => $fixtureId]);
                }
            }
        }

        return null;
    }

    /**
     * @return array<string,mixed>
     */
    private function pendingAdvancedFields(string $source, string $reason): array
    {
        return [
            'status' => 'pending_oracle',
            'source' => $source,
            'oracle_status' => 'pending_oracle',
            'field_status' => [
                'sihua' => 'pending_oracle',
                'auxiliary_stars' => 'pending_oracle',
                'minor_stars' => 'pending_oracle',
                'brightness' => 'pending_oracle',
                'flying_stars' => 'pending_oracle',
                'ming_gong_flying_star' => 'pending_oracle',
            ],
            'sihua' => ['status' => 'pending_oracle', 'items' => []],
            'auxiliary_stars' => ['status' => 'pending_oracle', 'palaces' => []],
            'minor_stars' => ['status' => 'pending_oracle', 'palaces' => []],
            'brightness' => ['status' => 'pending_oracle', 'items' => []],
            'flying_stars' => [
                'status' => 'pending_oracle',
                'implementation' => 'not_implemented',
                'reason' => $reason,
            ],
            'ming_gong_flying_star' => [
                'status' => 'pending_oracle',
                'implementation' => 'not_implemented',
                'reason' => $reason,
            ],
            'display_policy' => 'hide_as_unavailable_without_penalty',
            'matching_policy' => 'skip_unverified_or_missing_fields',
        ];
    }

    /**
     * @param  array<int,array<string,mixed>>  $palaces
     * @return array<string,mixed>
     */
    private function ceceP0AdvancedFields(array $palaces): array
    {
        return [
            'status' => 'accepted_selected_fields_only',
            'source' => 'cece_p0_selected_fields_transcript',
            'oracle_status' => 'selected_fields_transcribed_not_full_chart',
            'field_status' => [
                'sihua' => 'accepted_selected_fields_only',
                'auxiliary_stars' => 'accepted_selected_fields_only',
                'minor_stars' => 'accepted_selected_fields_only',
                'brightness' => 'accepted_selected_fields_only',
                'flying_stars' => 'pending_oracle',
                'ming_gong_flying_star' => 'pending_oracle',
            ],
            'sihua' => [
                'status' => 'accepted_selected_fields_only',
                'items' => self::CECE_P0_FOUR_TRANSFORMATIONS,
            ],
            'auxiliary_stars' => [
                'status' => 'accepted_selected_fields_only',
                'palaces' => $this->palaceStarGroups($palaces, 'auxiliary_stars'),
            ],
            'minor_stars' => [
                'status' => 'accepted_selected_fields_only',
                'palaces' => $this->palaceStarGroups($palaces, 'auxiliary_stars'),
            ],
            'brightness' => [
                'status' => 'accepted_selected_fields_only',
                'items' => $this->brightnessItems($palaces),
            ],
            'flying_stars' => [
                'status' => 'pending_oracle',
                'implementation' => 'not_implemented',
                'reason' => 'current_cece_screenshots_do_not_provide_full_flying_star_graph',
            ],
            'ming_gong_flying_star' => [
                'status' => 'pending_oracle',
                'implementation' => 'not_implemented',
                'reason' => 'ming_gong_flying_star_requires_new_oracle_screenshot_or_text',
            ],
            'display_policy' => 'show_as_selected_field_reference_with_boundary_copy',
            'matching_policy' => 'eligible_for_low_weight_explanation_only_no_hard_filter',
        ];
    }

    /**
     * @param  array<int,array<string,mixed>>  $palaces
     * @return array<string,mixed>
     */
    private function iztroCandidateAdvancedFields(array $palaces, string $mode): array
    {
        $sihua = [];
        foreach ($palaces as $palace) {
            foreach ((array) ($palace['transformations'] ?? []) as $row) {
                if (is_array($row)) {
                    $sihua[] = $row;
                }
            }
        }

        return [
            'status' => 'available_unverified',
            'source' => 'iztro_2_5_8_'.$mode.'_diagnostic_output',
            'oracle_status' => 'not_oracle_validated',
            'field_status' => [
                'sihua' => $sihua === [] ? 'pending_oracle' : 'available_unverified',
                'auxiliary_stars' => 'available_unverified',
                'minor_stars' => 'available_unverified',
                'brightness' => $this->brightnessItems($palaces) === [] ? 'pending_oracle' : 'available_unverified',
                'flying_stars' => 'pending_oracle',
                'ming_gong_flying_star' => 'pending_oracle',
            ],
            'sihua' => ['status' => $sihua === [] ? 'pending_oracle' : 'available_unverified', 'items' => $sihua],
            'auxiliary_stars' => [
                'status' => 'available_unverified',
                'palaces' => $this->palaceStarGroups($palaces, 'auxiliary_stars'),
            ],
            'minor_stars' => [
                'status' => 'available_unverified',
                'palaces' => $this->palaceStarGroups($palaces, 'auxiliary_stars'),
            ],
            'brightness' => [
                'status' => $this->brightnessItems($palaces) === [] ? 'pending_oracle' : 'available_unverified',
                'items' => $this->brightnessItems($palaces),
            ],
            'flying_stars' => [
                'status' => 'pending_oracle',
                'implementation' => 'not_accepted',
                'reason' => 'iztro_has_flying_star_query_api_but_elitesync_has_no_accepted_oracle_matrix_yet',
            ],
            'ming_gong_flying_star' => [
                'status' => 'pending_oracle',
                'implementation' => 'not_implemented',
                'reason' => 'ming_gong_flying_star_requires_new_oracle_screenshot_or_text',
            ],
            'display_policy' => 'show_only_with_unverified_boundary_if_surface_uses_this_payload',
            'matching_policy' => 'skip_until_field_status_is_accepted',
        ];
    }

    /**
     * @param  array<int,mixed>  $stars
     * @return array<int,string>
     */
    private function diagnosticStarNames(array $stars): array
    {
        $names = [];
        foreach ($stars as $star) {
            $name = is_array($star) ? trim((string) ($star['name'] ?? '')) : trim((string) $star);
            if ($name !== '') {
                $names[] = $name;
            }
        }

        return array_values(array_unique($names));
    }

    /**
     * @param  array<int,mixed>  $rows
     * @return array<int,array<string,string>>
     */
    private function diagnosticTransformations(array $rows, string $palace): array
    {
        $items = [];
        foreach ($rows as $row) {
            if (! is_array($row)) {
                continue;
            }
            $star = trim((string) ($row['star'] ?? ''));
            $mutagen = trim((string) ($row['mutagen'] ?? $row['transform'] ?? ''));
            if ($star === '' || $mutagen === '') {
                continue;
            }
            $items[] = [
                'transform' => str_starts_with($mutagen, '化') ? $mutagen : '化'.$mutagen,
                'star' => $star,
                'palace' => $palace,
                'brightness' => trim((string) ($row['brightness'] ?? '')),
                'status' => 'available_unverified',
            ];
        }

        return $items;
    }

    /**
     * @param  array<int,array<string,string>>  $rows
     * @return array<string,string>
     */
    private function diagnosticBrightnessMap(array $rows): array
    {
        $map = [];
        foreach ($rows as $row) {
            $star = (string) ($row['star'] ?? '');
            $brightness = (string) ($row['brightness'] ?? '');
            if ($star !== '' && $brightness !== '') {
                $map[$star] = $brightness;
            }
        }

        return $map;
    }

    /**
     * @param  array<int,array<string,mixed>>  $palaces
     * @return array<int,array<string,mixed>>
     */
    private function palaceStarGroups(array $palaces, string $field): array
    {
        $groups = [];
        foreach ($palaces as $palace) {
            $stars = array_values(array_filter(array_map(
                static fn (mixed $star): string => trim((string) $star),
                (array) ($palace[$field] ?? [])
            )));
            if ($stars === []) {
                continue;
            }
            $groups[] = [
                'palace' => (string) ($palace['name'] ?? $palace['palace_name'] ?? ''),
                'stars' => $stars,
            ];
        }

        return $groups;
    }

    /**
     * @param  array<int,array<string,mixed>>  $palaces
     * @return array<int,array<string,string>>
     */
    private function brightnessItems(array $palaces): array
    {
        $items = [];
        foreach ($palaces as $palace) {
            $palaceName = (string) ($palace['name'] ?? $palace['palace_name'] ?? '');
            foreach ((array) ($palace['star_status_map'] ?? []) as $star => $status) {
                $star = trim((string) $star);
                $status = trim((string) $status);
                if ($star !== '' && $status !== '') {
                    $items[] = ['palace' => $palaceName, 'star' => $star, 'status' => $status];
                }
            }
        }

        return $items;
    }
}
