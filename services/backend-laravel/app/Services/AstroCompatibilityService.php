<?php

namespace App\Services;

class AstroCompatibilityService
{
    /**
     * @param  array{zodiac_animal:string,public_zodiac_sign:string,private_bazi:string,private_natal_chart:mixed,private_ziwei:mixed,birthday:?string,gender:string}  $a
     * @param  array{zodiac_animal:string,public_zodiac_sign:string,private_bazi:string,private_natal_chart:mixed,private_ziwei:mixed,birthday:?string,gender:string}  $b
     * @return array{
     *  bazi:int,zodiac:int,constellation:int,natal_chart:int,ziwei:int,pair_chart:int,total:int,verdict:string,
     *  reasons_match:array<int,string>,reasons_mismatch:array<int,string>,confidence:float,
     *  module_details:array<string,array<string,mixed>>
     * }
     */
    public function score(array $a, array $b): array
    {
        $zodiac = $this->scoreZodiac((string) ($a['zodiac_animal'] ?? ''), (string) ($b['zodiac_animal'] ?? ''));
        $constellation = $this->scoreConstellation((string) ($a['public_zodiac_sign'] ?? ''), (string) ($b['public_zodiac_sign'] ?? ''));
        $bazi = $this->scoreBazi((string) ($a['private_bazi'] ?? ''), (string) ($b['private_bazi'] ?? ''), $a['private_natal_chart'] ?? null, $b['private_natal_chart'] ?? null);
        $chart = $this->scoreNatalChart($a['private_natal_chart'] ?? null, $b['private_natal_chart'] ?? null, (string) ($a['public_zodiac_sign'] ?? ''), (string) ($b['public_zodiac_sign'] ?? ''));
        $ziwei = $this->scoreZiwei($a['private_ziwei'] ?? null, $b['private_ziwei'] ?? null, (string) ($a['gender'] ?? ''), (string) ($b['gender'] ?? ''));
        $pairChart = $this->scorePairChart(
            $a['private_natal_chart'] ?? null,
            $b['private_natal_chart'] ?? null,
            (string) ($a['public_zodiac_sign'] ?? ''),
            (string) ($b['public_zodiac_sign'] ?? ''),
            (string) ($a['private_bazi'] ?? ''),
            (string) ($b['private_bazi'] ?? ''),
            (string) ($a['gender'] ?? ''),
            (string) ($b['gender'] ?? '')
        );

        $w = (array) config('match_rules.weights', []);
        $weightBazi = (float) ($w['bazi'] ?? 0.5);
        $weightZodiac = (float) ($w['zodiac'] ?? 0.25);
        $weightConstellation = (float) ($w['constellation'] ?? 0.15);
        $weightChart = (float) ($w['natal_chart'] ?? 0.10);
        $weightZiwei = $this->ziweiMainStarAffinityWeight();
        $weightPairChart = (float) ($w['pair_chart'] ?? 0.0);
        $total = (int) round(
            ($bazi['score'] * $weightBazi)
            + ($zodiac['score'] * $weightZodiac)
            + ($constellation['score'] * $weightConstellation)
            + ($chart['score'] * $weightChart)
            + ($ziwei['score'] * $weightZiwei)
            + ($pairChart['score'] * $weightPairChart)
        );

        $threshold = (array) config('match_rules.verdict_thresholds', ['high' => 80, 'medium' => 60]);
        $verdict = $total >= (int) ($threshold['high'] ?? 80)
            ? 'high'
            : ($total >= (int) ($threshold['medium'] ?? 60) ? 'medium' : 'low');

        $modules = [
            [
                'key' => 'bazi',
                'name' => '八字',
                'score' => (int) $bazi['score'],
                'weight' => $weightBazi,
                'match' => (string) $bazi['match'],
                'mismatch' => (string) $bazi['mismatch'],
            ],
            [
                'key' => 'zodiac',
                'name' => '属相',
                'score' => (int) $zodiac['score'],
                'weight' => $weightZodiac,
                'match' => (string) $zodiac['match'],
                'mismatch' => (string) $zodiac['mismatch'],
            ],
            [
                'key' => 'constellation',
                'name' => '星座',
                'score' => (int) $constellation['score'],
                'weight' => $weightConstellation,
                'match' => (string) $constellation['match'],
                'mismatch' => (string) $constellation['mismatch'],
            ],
            [
                'key' => 'natal_chart',
                'name' => '星盘',
                'score' => (int) $chart['score'],
                'weight' => $weightChart,
                'match' => (string) $chart['match'],
                'mismatch' => (string) $chart['mismatch'],
            ],
            [
                'key' => 'ziwei',
                'name' => '紫微主星关系参考',
                'score' => (int) $ziwei['score'],
                'weight' => $weightZiwei,
                'match' => (string) $ziwei['match'],
                'mismatch' => (string) $ziwei['mismatch'],
            ],
        ];
        if ($weightPairChart > 0.0) {
            $modules[] = [
                'key' => 'pair_chart',
                'name' => '男女合盘',
                'score' => (int) $pairChart['score'],
                'weight' => $weightPairChart,
                'match' => (string) $pairChart['match'],
                'mismatch' => (string) $pairChart['mismatch'],
            ];
        }
        usort($modules, function (array $x, array $y): int {
            $wx = ((float) ($x['weight'] ?? 0.0)) * ((int) ($x['score'] ?? 0));
            $wy = ((float) ($y['weight'] ?? 0.0)) * ((int) ($y['score'] ?? 0));

            return $wy <=> $wx;
        });

        $reasonsMatch = [];
        $reasonsMismatch = [];
        foreach ($modules as $m) {
            $name = (string) ($m['name'] ?? '');
            $score = (int) ($m['score'] ?? 0);
            $matchText = trim((string) ($m['match'] ?? ''));
            $mismatchText = trim((string) ($m['mismatch'] ?? ''));
            if ($matchText !== '') {
                $reasonsMatch[] = sprintf('%s(%d分)：%s', $name, $score, $matchText);
            }
            if ($mismatchText !== '') {
                $reasonsMismatch[] = sprintf('%s(%d分)：%s', $name, $score, $mismatchText);
            }
        }
        $reasonsMatch = array_slice($reasonsMatch, 0, 3);
        $reasonsMismatch = array_slice($reasonsMismatch, 0, 2);

        $summary = sprintf(
            '综合匹配度%d分（八字%d%%、属相%d%%、星座%d%%、星盘%d%%、紫微主星参考%d%%、合盘%d%%）',
            max(0, min(100, $total)),
            $this->toPercent($weightBazi),
            $this->toPercent($weightZodiac),
            $this->toPercent($weightConstellation),
            $this->toPercent($weightChart),
            $this->toPercent($weightZiwei),
            $this->toPercent($weightPairChart)
        );

        return [
            'bazi' => $bazi['score'],
            'zodiac' => $zodiac['score'],
            'constellation' => $constellation['score'],
            'natal_chart' => $chart['score'],
            'ziwei' => $ziwei['score'],
            'pair_chart' => $pairChart['score'],
            'total' => max(0, min(100, $total)),
            'verdict' => $verdict,
            'summary' => $summary,
            'ziwei_main_star_affinity' => $ziwei,
            'reasons_match' => $reasonsMatch,
            'reasons_mismatch' => $reasonsMismatch,
            'confidence' => round(($bazi['confidence'] + $chart['confidence'] + $ziwei['confidence'] + $pairChart['confidence'] + 1.0 + 1.0) / 6, 2),
            'module_details' => [
                'bazi' => $bazi,
                'zodiac' => $zodiac,
                'constellation' => $constellation,
                'natal_chart' => $chart,
                'ziwei' => $ziwei,
                'pair_chart' => $pairChart,
            ],
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreBazi(string $baziA, string $baziB, mixed $chartA, mixed $chartB): array
    {
        $tpl = (array) (((array) config('match_rules.bazi.templates', []))['full'] ?? []);
        $tplSimilarity = (array) (((array) config('match_rules.bazi.templates', []))['similarity'] ?? []);
        $tplDegraded = (array) (((array) config('match_rules.bazi.templates', []))['degraded'] ?? []);
        /** @var BaziFeatureExtractor $extractor */
        $extractor = app(BaziFeatureExtractor::class);
        $features = $extractor->extractPairFeatures($baziA, $baziB, $chartA, $chartB);
        if ((bool) ($features['available'] ?? false)) {
            $weights = (array) config('match_rules.bazi.feature_weights', []);
            $ws = (float) ($weights['structure'] ?? 0.50);
            $wr = (float) ($weights['relationship'] ?? 0.30);
            $wt = (float) ($weights['timing'] ?? 0.20);
            $norm = max(0.0001, $ws + $wr + $wt);
            $ws /= $norm;
            $wr /= $norm;
            $wt /= $norm;

            $structure = (float) ($features['structure_score'] ?? 60.0);
            $relationship = (float) ($features['relationship_score'] ?? 60.0);
            $timing = (float) ($features['timing_score'] ?? 60.0);
            $score = (int) round(($structure * $ws) + ($relationship * $wr) + ($timing * $wt));

            return [
                'score' => max(0, min(100, $score)),
                'match' => (string) ($tpl['match'] ?? '八字五行互补度较好，节奏更容易协调'),
                'mismatch' => $score < 60 ? (string) ($tpl['mismatch'] ?? '八字五行分布偏差较大，可能需要更长磨合') : '',
                'confidence' => (float) ($features['confidence'] ?? 0.85),
                'reason_short' => sprintf(
                    '结构分%.0f，关系分%.0f，时间分%.0f（权重 %.0f/%.0f/%.0f）。',
                    $structure,
                    $relationship,
                    $timing,
                    $ws * 100,
                    $wr * 100,
                    $wt * 100
                ),
                'reason_detail' => (string) ($tpl['detail'] ?? '从五行分布看，你们更偏向“互补调节”而非同侧堆叠，长期生活节律更容易形成稳定配合。'),
                'risk_detail' => $score < 60 ? (string) ($tpl['risk'] ?? '五行分布差异偏大，婚后在作息、决策与压力处理上可能出现节律不一致。') : '',
                'evidence_tags' => (array) ($features['evidence_tags'] ?? ['wu_xing_complement', 'long_term_harmony_oriented']),
                'evidence' => (array) ($features['evidence'] ?? []),
                'degraded' => (bool) ($features['degraded'] ?? false),
                'degrade_reason' => (string) ($features['degrade_reason'] ?? ''),
            ];
        }

        if ($baziA !== '' && $baziB !== '') {
            similar_text($baziA, $baziB, $percent);
            $score = (int) round(40 + ($percent * 0.45));

            return [
                'score' => max(0, min(100, $score)),
                'match' => (string) ($tplSimilarity['match'] ?? '八字信息完整，基础结构相容度中等偏上'),
                'mismatch' => $score < 60 ? (string) ($tplSimilarity['mismatch'] ?? '八字组合冲突项偏多，建议谨慎观察') : '',
                'confidence' => 0.75,
                'reason_short' => (string) ($tplSimilarity['short'] ?? '八字结构相容度中等偏上。'),
                'reason_detail' => (string) ($tplSimilarity['detail'] ?? '当前按八字文本结构相似度估算，倾向于“可磨合但需观察现实互动”的组合。'),
                'risk_detail' => $score < 60 ? (string) ($tplSimilarity['risk'] ?? '八字结构冲突项偏多，长期磨合成本可能偏高。') : '',
                'evidence_tags' => ['bazi_similarity_estimation', 'confidence_medium'],
                'evidence' => [
                    'bazi_a' => $baziA,
                    'bazi_b' => $baziB,
                    'similarity_percent' => round($percent, 2),
                ],
                'degraded' => true,
                'degrade_reason' => 'missing_wu_xing',
            ];
        }

        return [
            'score' => 55,
            'match' => (string) ($tplDegraded['match'] ?? '八字信息不完整，已使用保守估计'),
            'mismatch' => (string) ($tplDegraded['mismatch'] ?? '缺少完整八字或五行明细，结论置信度较低'),
            'confidence' => 0.4,
            'reason_short' => (string) ($tplDegraded['short'] ?? '八字数据不完整，当前仅作保守参考。'),
            'reason_detail' => (string) ($tplDegraded['detail'] ?? '缺少完整八字或五行明细，系统只能按简化规则估算，不建议把该项作为强结论。'),
            'risk_detail' => (string) ($tplDegraded['risk'] ?? '建议补全出生时刻与地点，提高长期结果判断的稳定性。'),
            'evidence_tags' => ['bazi_degraded_estimation', 'missing_bazi'],
            'evidence' => [],
            'degraded' => true,
            'degrade_reason' => 'missing_bazi',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreZodiac(string $a, string $b): array
    {
        $scores = (array) config('match_rules.zodiac.scores', []);
        $tplMatch = (array) config('match_rules.zodiac.templates.match', []);
        $tplDetail = (array) config('match_rules.zodiac.templates.detail', []);
        $tplRisk = (string) config('match_rules.zodiac.templates.risk', '该关系类型并非“不能在一起”，而是提示磨合与沟通成本相对更高。');
        if ($a === '' || $b === '') {
            return [
                'score' => 55,
                'match' => '属相信息缺失，使用中性评分',
                'mismatch' => '',
                'confidence' => 0.5,
                'reason_short' => '属相信息缺失，暂按中性倾向处理。',
                'reason_detail' => '当前缺少属相信息，无法判断六合/三合/冲刑害等关系，只能给出中性估计。',
                'risk_detail' => '',
                'evidence_tags' => ['missing_zodiac'],
                'evidence' => ['animal_a' => $a, 'animal_b' => $b],
                'degraded' => true,
                'degrade_reason' => 'missing_zodiac',
            ];
        }

        $relation = $this->zodiacRelation($a, $b);
        $score = (int) ($scores[$relation] ?? ($scores['normal'] ?? 55));
        $match = (string) ($tplMatch[$relation] ?? $tplMatch['normal'] ?? '属相关系一般，仍可通过沟通建立默契');
        $detail = (string) ($tplDetail[$relation] ?? $tplDetail['normal'] ?? "当前组合（{$a}-{$b}）不属于传统六合/三合，也不在冲刑害高风险组，建议以现实互动质量为主判断。");
        $mismatch = in_array($relation, ['chong', 'xing', 'hai'], true)
            ? (string) ($tplMatch[$relation] ?? '属相关系存在冲/刑/害，冲突概率相对更高')
            : '';
        $tags = match ($relation) {
            'liuhe' => ['zodiac_liuhe'],
            'sanhe' => ['zodiac_sanhe'],
            'same' => ['zodiac_same'],
            'chong' => ['zodiac_chong'],
            'xing' => ['zodiac_xing'],
            'hai' => ['zodiac_hai'],
            default => ['zodiac_normal'],
        };

        return [
            'score' => $score,
            'match' => $match,
            'mismatch' => $mismatch,
            'confidence' => 1.0,
            'reason_short' => $match,
            'reason_detail' => sprintf(
                '%s 当前组合：%s-%s（关系类型：%s）。',
                $detail,
                $a,
                $b,
                $relation
            ),
            'risk_detail' => in_array($relation, ['chong', 'xing', 'hai'], true)
                ? $tplRisk
                : '',
            'evidence_tags' => $tags,
            'evidence' => ['animal_a' => $a, 'animal_b' => $b, 'relation_type' => $relation],
            'degraded' => false,
            'degrade_reason' => '',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreConstellation(string $a, string $b): array
    {
        $elements = (array) config('match_rules.constellation.elements', []);
        $tpl = (array) config('match_rules.constellation.templates', []);
        $tplDegraded = (array) ($tpl['degraded'] ?? []);
        if ($a === '' || $b === '' || ! isset($elements[$a]) || ! isset($elements[$b])) {
            return [
                'score' => 60,
                'match' => (string) ($tplDegraded['match'] ?? '星座信息不完整，采用基础评分'),
                'mismatch' => '',
                'confidence' => 0.6,
                'reason_short' => (string) ($tplDegraded['short'] ?? '星座信息不完整，当前仅作基础参考。'),
                'reason_detail' => (string) ($tplDegraded['detail'] ?? '因星座要素缺失，系统无法给出完整过程层判断，仅提供中性估计。'),
                'risk_detail' => '',
                'evidence_tags' => ['missing_constellation'],
                'evidence' => ['sign_a' => $a, 'sign_b' => $b],
                'degraded' => true,
                'degrade_reason' => 'missing_constellation',
            ];
        }
        $ea = $elements[$a];
        $eb = $elements[$b];
        $same = $ea === $eb;
        $complement = in_array([$ea, $eb], [
            ['fire', 'air'], ['air', 'fire'], ['earth', 'water'], ['water', 'earth'],
        ], true);

        $score = $same
            ? (int) config('match_rules.constellation.score_same_element', 85)
            : ($complement
                ? (int) config('match_rules.constellation.score_complement', 75)
                : (int) config('match_rules.constellation.score_normal', 60));
        if ($a === $b) {
            $score += (int) config('match_rules.constellation.same_sign_bonus', 5);
        }

        $mode = $same ? 'same' : ($complement ? 'complement' : 'tension');
        $tplMode = (array) ($tpl[$mode] ?? []);
        $tplRisk = (array) ($tpl['tension'] ?? []);

        return [
            'score' => max(0, min(100, $score)),
            'match' => (string) ($tplMode['match'] ?? ($same ? '同元素星座，沟通风格更易同频' : ($complement ? '星座元素互补，互动张力较好' : '星座元素差异较大，需要主动沟通'))),
            'mismatch' => $score < 65 ? '星座特质差异较明显，磨合成本可能偏高' : '',
            'confidence' => 1.0,
            'reason_short' => (string) ($tplMode['short'] ?? ($same ? '互动风格偏同频，推进更顺滑。' : ($complement ? '元素互补，互动张力与推进节奏较好。' : '互动节奏差异较大，需主动对齐。'))),
            'reason_detail' => (string) ($tplMode['detail'] ?? ($same
                ? '同元素组合通常在表达方式和节奏上更容易同步，过程层阻力相对更低。'
                : ($complement
                    ? '元素互补组合通常体现为一方推进、另一方承接更自然，初期互动更容易形成节奏。'
                    : '元素差异较大时，常见情况是表达逻辑与情绪节奏不同步，推进关系需要额外沟通。'))),
            'risk_detail' => $score < 65 ? (string) ($tplRisk['risk'] ?? '该项主要反映相处过程是否顺滑，不代表长期结果层结论。') : '',
            'evidence_tags' => $same ? ['same_element', 'process_layer_signal'] : ($complement ? ['element_complement', 'process_layer_signal'] : ['element_tension', 'process_layer_signal']),
            'evidence' => [
                'sign_a' => $a,
                'sign_b' => $b,
                'element_a' => $ea,
                'element_b' => $eb,
                'same_element' => $same,
                'complementary' => $complement,
            ],
            'degraded' => false,
            'degrade_reason' => '',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreNatalChart(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array
    {
        $engine = $this->westernEngine();
        $m = $engine->natalMetrics($chartA, $chartB, $sunA, $sunB);
        $sunA = (string) ($m['sun_a'] ?? $sunA);
        $sunB = (string) ($m['sun_b'] ?? $sunB);
        $moonA = (string) ($m['moon_a'] ?? '');
        $moonB = (string) ($m['moon_b'] ?? '');
        $ascA = (string) ($m['asc_a'] ?? '');
        $ascB = (string) ($m['asc_b'] ?? '');
        $directionSync = (float) ($m['direction_sync'] ?? 60.0);
        $emotionSync = (float) ($m['emotion_sync'] ?? 60.0);
        $expressionSync = (float) ($m['expression_sync'] ?? 60.0);
        $completenessLevel = (int) ($m['completeness_level'] ?? 0);
        $hasMoon = (bool) ($m['has_moon'] ?? false);
        $hasAsc = (bool) ($m['has_asc'] ?? false);
        $completenessBonus = ($hasMoon && $hasAsc) ? 6 : (($hasMoon || $hasAsc) ? 3 : 0);

        $raw = (0.35 * $emotionSync) + (0.30 * $expressionSync) + (0.30 * $directionSync) + (0.05 * (60 + $completenessBonus));
        $score = (int) round(max(0.0, min(100.0, $raw)));
        $conf = $completenessLevel === 2 ? 0.9 : ($completenessLevel === 1 ? 0.72 : 0.55);
        $lowKeys = [];
        if ($emotionSync < 60) {
            $lowKeys[] = '情绪同步';
        }
        if ($expressionSync < 60) {
            $lowKeys[] = '表达风格';
        }
        if ($directionSync < 60) {
            $lowKeys[] = '关系方向';
        }
        $riskPoint = empty($lowKeys) ? '' : ('主要张力点：'.implode('、', $lowKeys).'。');

        return [
            'score' => max(0, min(100, $score)),
            'match' => $score >= 70 ? '星盘关键项相位较和谐，情绪与节奏更易同步' : '星盘结构一般，可通过互动逐步建立默契',
            'mismatch' => $score < 60 ? '星盘相位张力偏大，容易出现沟通温差' : '',
            'confidence' => $conf,
            'reason_short' => sprintf(
                '情绪同步%d / 表达风格%d / 关系方向%d。',
                (int) round($emotionSync),
                (int) round($expressionSync),
                (int) round($directionSync)
            ),
            'reason_detail' => sprintf(
                '该项主要衡量过程层顺滑度：情绪同步（%d）、表达风格（%d）、关系方向（%d）。%s',
                (int) round($emotionSync),
                (int) round($expressionSync),
                (int) round($directionSync),
                $completenessLevel === 2 ? '关键出生信息较完整，结论稳定性较高。' : '当前存在部分出生信息缺失，建议补全后复核。'
            ),
            'risk_detail' => $score < 60 ? ('该项反映过程层温差风险，建议在互动中增加反馈确认与节奏对齐。'.$riskPoint) : '',
            'evidence_tags' => $conf < 0.8
                ? ['natal_chart_partial_data']
                : ($score >= 70 ? ['moon_sync_high', 'asc_style_match', 'sun_direction_sync'] : ['moon_sync_low', 'asc_style_gap', 'sun_direction_gap']),
            'evidence' => [
                'sun_sign_a' => $sunA,
                'sun_sign_b' => $sunB,
                'moon_sign_a' => $moonA,
                'moon_sign_b' => $moonB,
                'asc_sign_a' => $ascA,
                'asc_sign_b' => $ascB,
                'emotion_sync_score' => (int) round($emotionSync),
                'expression_sync_score' => (int) round($expressionSync),
                'direction_sync_score' => (int) round($directionSync),
                'data_completeness_level' => $completenessLevel,
                'engine_source' => (string) ($m['source'] ?? ''),
            ],
            'degraded' => $conf < 0.8,
            'degrade_reason' => $conf < 0.8 ? 'partial_natal_chart' : '',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreZiwei(mixed $ziweiA, mixed $ziweiB, string $genderA, string $genderB): array
    {
        $a = is_array($ziweiA) ? $ziweiA : [];
        $b = is_array($ziweiB) ? $ziweiB : [];
        $weight = $this->ziweiMainStarAffinityWeight();
        $cfg = (array) config('match_rules.ziwei_main_star_affinity', []);
        $key = (string) ($cfg['key'] ?? 'ziwei_main_star_affinity_v1');
        $label = (string) ($cfg['label'] ?? '紫微主星关系参考');
        $policy = (string) ($cfg['weight_policy'] ?? 'low_weight_auxiliary');

        if ($weight <= 0.0) {
            return $this->ziweiUnavailableResult(
                'disabled',
                '紫微主星关系参考已关闭，不影响当前匹配结果。',
                $key,
                $label,
                $policy,
                $weight,
                $a,
                $b
            );
        }

        $profileA = $this->mainStarProfile($a);
        $profileB = $this->mainStarProfile($b);
        if (($profileA['available'] ?? false) !== true || ($profileB['available'] ?? false) !== true) {
            return $this->ziweiUnavailableResult(
                'unavailable',
                '双方紫微主星排盘资料暂不完整，本项不扣分。',
                $key,
                $label,
                $policy,
                $weight,
                $a,
                $b
            );
        }

        $sharedMainStars = array_values(array_intersect(
            (array) ($profileA['all_main_stars'] ?? []),
            (array) ($profileB['all_main_stars'] ?? [])
        ));
        $sharedLifeStars = array_values(array_intersect(
            (array) ($profileA['life_main_stars'] ?? []),
            (array) ($profileB['life_main_stars'] ?? [])
        ));
        $sameLifePalace = (string) ($profileA['life_palace'] ?? '') !== ''
            && (string) ($profileA['life_palace'] ?? '') === (string) ($profileB['life_palace'] ?? '');
        $sameBodyPalace = (string) ($profileA['body_palace'] ?? '') !== ''
            && (string) ($profileA['body_palace'] ?? '') === (string) ($profileB['body_palace'] ?? '');
        $advancedA = $this->advancedFieldProfile($a);
        $advancedB = $this->advancedFieldProfile($b);
        $hasAcceptedAdvanced = (bool) ($advancedA['accepted'] ?? false) || (bool) ($advancedB['accepted'] ?? false);

        $score = 62;
        if ($sameLifePalace) {
            $score += 8;
        }
        if ($sameBodyPalace) {
            $score += 5;
        }
        if (! empty($sharedLifeStars)) {
            $score += 8;
        }
        if (! empty($sharedMainStars)) {
            $score += min(7, count($sharedMainStars) * 2);
        }
        $score = max(58, min(82, $score));
        $scoreDelta = round($score * $weight, 2);

        $conversationHint = ! empty($sharedLifeStars)
            ? '可以从彼此都重视的表达方式聊起，先交换真实感受，再慢慢延伸到关系节奏。'
            : '可以把主星差异当作开场线索，先问对方更习惯怎样被理解和回应。';
        $rhythmHint = $sameLifePalace || $sameBodyPalace
            ? '你们在主星排盘的角色感上有接近处，适合用轻问题确认共同节奏。'
            : '你们的主星落点更像互补提醒，适合提前说明边界与回应速度。';
        $advancedHint = $hasAcceptedAdvanced
            ? '已验收的四化、辅星与星曜状态只作为补充解释，适合用来补充提问，不单独决定匹配。'
            : '四化、辅星、亮度、飞星和命宫飞星未进入已验收匹配解释，本轮保持跳过。';

        return [
            'score' => $score,
            'match' => $label.'：'.$rhythmHint,
            'mismatch' => '',
            'confidence' => 0.72,
            'status' => 'available',
            'key' => $key,
            'label' => $label,
            'weight' => $weight,
            'weight_policy' => $policy,
            'contribution_level' => 'low_weight_auxiliary',
            'score_delta' => $scoreDelta,
            'summary' => $rhythmHint,
            'conversation_hint' => $conversationHint,
            'advanced_field_hint' => $advancedHint,
            'boundary_note' => $hasAcceptedAdvanced
                ? '当前可使用已验收的紫微高级字段做低权重解释；available_unverified 与 pending_oracle 字段不会进入匹配分。'
                : '当前仅使用 12 宫、地支、14 主星、命宫、身宫等第一阶段字段；四化、辅星、亮度、飞星和命宫飞星仍待后续版本扩展。',
            'reason_short' => '紫微主星关系参考已作为低权重辅助维度纳入慢约会理解。',
            'reason_detail' => sprintf(
                '本项只按双方主星排盘第一阶段字段生成关系提示，权重上限 %.0f%%，不会作为硬过滤器，也不会覆盖现有 Date Drop 主链。',
                $weight * 100
            ),
            'risk_detail' => '紫微主星只用于辅助理解开场和节奏，不代表完整紫微斗数结论，也不写入资料或星盘真值。',
            'evidence_tags' => array_values(array_filter([
                'ziwei_main_star_affinity_v1',
                'low_weight_auxiliary',
                $hasAcceptedAdvanced ? 'ziwei_advanced_affinity_v1' : '',
                $sameLifePalace ? 'life_palace_aligned' : '',
                $sameBodyPalace ? 'body_palace_aligned' : '',
                ! empty($sharedMainStars) ? 'main_star_overlap' : '',
            ])),
            'evidence' => [
                'has_a' => ! empty($a),
                'has_b' => ! empty($b),
                'engine_a' => (string) data_get($a, 'engine', ''),
                'engine_b' => (string) data_get($b, 'engine', ''),
                'external_oracle_status_a' => (string) data_get($a, 'external_oracle_status', 'not_validated'),
                'external_oracle_status_b' => (string) data_get($b, 'external_oracle_status', 'not_validated'),
                'display_only_a' => (bool) data_get($a, 'display_only', true),
                'display_only_b' => (bool) data_get($b, 'display_only', true),
                'scoring_status' => 'low_weight_auxiliary',
                'life_palace_a' => (string) ($profileA['life_palace'] ?? ''),
                'life_palace_b' => (string) ($profileB['life_palace'] ?? ''),
                'body_palace_a' => (string) ($profileA['body_palace'] ?? ''),
                'body_palace_b' => (string) ($profileB['body_palace'] ?? ''),
                'shared_main_stars' => $sharedMainStars,
                'shared_life_main_stars' => $sharedLifeStars,
                'advanced_field_status_a' => $advancedA,
                'advanced_field_status_b' => $advancedB,
                'gender_pair' => [$genderA, $genderB],
            ],
            'degraded' => false,
            'degrade_reason' => '',
        ];
    }

    private function ziweiMainStarAffinityWeight(): float
    {
        $cfg = (array) config('match_rules.ziwei_main_star_affinity', []);
        if ((bool) ($cfg['enabled'] ?? true) !== true) {
            return 0.0;
        }
        $configured = (float) config('match_rules.weights.ziwei', 0.0);
        $max = (float) ($cfg['max_weight'] ?? 0.05);

        return max(0.0, min($configured, $max, 0.08));
    }

    /**
     * @param  array<string,mixed>  $a
     * @param  array<string,mixed>  $b
     * @return array<string,mixed>
     */
    private function ziweiUnavailableResult(
        string $status,
        string $summary,
        string $key,
        string $label,
        string $policy,
        float $weight,
        array $a,
        array $b
    ): array {
        return [
            'score' => 0,
            'match' => '',
            'mismatch' => '',
            'confidence' => 0.0,
            'status' => $status,
            'key' => $key,
            'label' => $label,
            'weight' => $weight,
            'weight_policy' => $policy,
            'contribution_level' => 'low_weight_auxiliary',
            'score_delta' => 0.0,
            'summary' => $summary,
            'conversation_hint' => '',
            'boundary_note' => '紫微主星辅助维度缺失或关闭时不扣分，不改变现有匹配结果。',
            'reason_short' => $summary,
            'reason_detail' => '本项采用 fail-open 策略：缺少双方主星排盘或配置关闭时，保持原有匹配结果。',
            'risk_detail' => '不要把缺失的紫微信息解读为不合适；当前只是未展示辅助维度。',
            'evidence_tags' => $status === 'disabled'
                ? ['ziwei_main_star_affinity_disabled', 'low_weight_auxiliary']
                : ['missing_ziwei', 'low_weight_auxiliary'],
            'evidence' => [
                'has_a' => ! empty($a),
                'has_b' => ! empty($b),
                'engine_a' => (string) data_get($a, 'engine', ''),
                'engine_b' => (string) data_get($b, 'engine', ''),
                'scoring_status' => $status,
            ],
            'degraded' => true,
            'degrade_reason' => $status === 'disabled' ? 'ziwei_affinity_disabled' : 'missing_ziwei_main_star_data',
        ];
    }

    /**
     * @param  array<string,mixed>  $ziwei
     * @return array<string,mixed>
     */
    private function mainStarProfile(array $ziwei): array
    {
        $palaces = (array) data_get($ziwei, 'palaces', []);
        $lifePalace = (string) data_get($ziwei, 'life_palace', '');
        $bodyPalace = (string) data_get($ziwei, 'body_palace', '');
        $lifeMainStars = [];
        $allMainStars = [];

        foreach ($palaces as $palace) {
            if (! is_array($palace)) {
                continue;
            }
            $name = (string) ($palace['palace_name'] ?? $palace['name'] ?? '');
            $stars = (array) ($palace['main_stars'] ?? []);
            if (empty($stars) && trim((string) ($palace['main_star'] ?? '')) !== '') {
                $stars = [(string) $palace['main_star']];
            }
            $stars = array_values(array_filter(array_map(
                static fn (mixed $star): string => trim((string) $star),
                $stars
            )));
            $allMainStars = array_merge($allMainStars, $stars);
            if ($name !== '' && $lifePalace !== '' && $name === $lifePalace) {
                $lifeMainStars = $stars;
            }
        }

        $lifeDetailStars = (array) data_get($ziwei, 'life_palace_detail.main_stars', []);
        if (empty($lifeMainStars) && ! empty($lifeDetailStars)) {
            $lifeMainStars = array_values(array_filter(array_map(
                static fn (mixed $star): string => trim((string) $star),
                $lifeDetailStars
            )));
            $allMainStars = array_merge($allMainStars, $lifeMainStars);
        }

        $allMainStars = array_values(array_unique(array_filter($allMainStars)));

        return [
            'available' => $lifePalace !== '' && $bodyPalace !== '' && count($palaces) >= 1 && ! empty($allMainStars),
            'life_palace' => $lifePalace,
            'body_palace' => $bodyPalace,
            'life_main_stars' => array_values(array_unique($lifeMainStars)),
            'all_main_stars' => $allMainStars,
        ];
    }

    /**
     * @param  array<string,mixed>  $ziwei
     * @return array<string,mixed>
     */
    private function advancedFieldProfile(array $ziwei): array
    {
        $advanced = (array) data_get($ziwei, 'ziwei_advanced_fields', []);
        $fieldStatus = (array) data_get($advanced, 'field_status', []);
        $sihua = (array) data_get($advanced, 'sihua.items', []);
        $accepted = false;
        foreach (['sihua', 'auxiliary_stars', 'brightness'] as $field) {
            if (str_contains((string) ($fieldStatus[$field] ?? ''), 'accepted')) {
                $accepted = true;
                break;
            }
        }

        return [
            'status' => (string) ($advanced['status'] ?? 'missing'),
            'sihua_status' => (string) ($fieldStatus['sihua'] ?? 'missing'),
            'auxiliary_status' => (string) ($fieldStatus['auxiliary_stars'] ?? 'missing'),
            'brightness_status' => (string) ($fieldStatus['brightness'] ?? 'missing'),
            'flying_star_status' => (string) ($fieldStatus['flying_stars'] ?? 'missing'),
            'ming_gong_flying_star_status' => (string) ($fieldStatus['ming_gong_flying_star'] ?? 'missing'),
            'accepted' => $accepted,
            'sihua_count' => count($sihua),
            'matching_policy' => (string) ($advanced['matching_policy'] ?? 'skip_unverified_or_missing_fields'),
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scorePairChart(
        mixed $chartA,
        mixed $chartB,
        string $sunA,
        string $sunB,
        string $baziA,
        string $baziB,
        string $genderA,
        string $genderB
    ): array {
        $engine = $this->westernEngine();
        $m = $engine->pairMetrics($chartA, $chartB, $sunA, $sunB);
        $sunA = (string) ($m['sun_a'] ?? $sunA);
        $sunB = (string) ($m['sun_b'] ?? $sunB);
        $moonA = (string) ($m['moon_a'] ?? '');
        $moonB = (string) ($m['moon_b'] ?? '');
        $ascA = (string) ($m['asc_a'] ?? '');
        $ascB = (string) ($m['asc_b'] ?? '');

        $pairCfg = (array) config('match_rules.pair_chart.weights', []);
        $sunMoonAB = (float) ($m['sun_moon_ab'] ?? 60.0);
        $sunMoonBA = (float) ($m['sun_moon_ba'] ?? 60.0);
        $sunMoon = (int) round((float) ($m['sun_moon_avg'] ?? (($sunMoonAB + $sunMoonBA) / 2.0)));
        $ascScore = (float) ($m['asc_score'] ?? 60.0);
        $emotionScore = (float) ($m['emotion_score'] ?? 60.0);
        $baziBridge = ($baziA !== '' && $baziB !== '') ? 72 : 60;
        $full = (bool) ($m['full_data'] ?? false) && $baziA !== '' && $baziB !== '';
        $componentCount = (int) ($m['component_count'] ?? 0);
        if ($baziA !== '' && $baziB !== '') {
            $componentCount += 1;
        }
        /** @var PairChartFeatureExtractor $extractor */
        $extractor = app(PairChartFeatureExtractor::class);
        $pair = $extractor->build(
            [
                'sun_moon_harmony' => $sunMoon,
                'asc_interaction' => $ascScore,
                'emotion_rhythm' => $emotionScore,
                'long_term_stability' => $baziBridge,
                'sun_moon_ab' => $sunMoonAB,
                'sun_moon_ba' => $sunMoonBA,
                'full_data' => $full,
                'component_count' => $componentCount,
            ],
            [
                'sun_moon_harmony' => (float) ($pairCfg['sun_moon_harmony'] ?? 0.35),
                'asc_interaction' => (float) ($pairCfg['asc_interaction'] ?? 0.20),
                'emotion_rhythm' => (float) ($pairCfg['emotion_rhythm'] ?? 0.25),
                'long_term_stability' => (float) ($pairCfg['long_term_stability'] ?? 0.20),
            ]
        );
        $score = (int) ($pair['score'] ?? 60);
        $confidence = (float) ($pair['confidence'] ?? 0.7);
        $degraded = (bool) ($pair['degraded'] ?? true);
        $degradeReason = (string) ($pair['degrade_reason'] ?? 'partial_pair_chart');
        $lowPair = (array) ($pair['top_risks'] ?? []);
        $pairRiskPoint = empty($lowPair) ? '' : ('重点磨合点：'.implode('、', $lowPair).'。');

        $match = $score >= 78
            ? '男女合盘协同性较高，关系推进路径更清晰'
            : ($score >= 60 ? '男女合盘存在互补空间，可通过沟通对齐节奏' : '男女合盘节奏差异较大，建议先建立边界与沟通规则');
        $mismatch = $score < 60 ? '合盘提示互动节奏存在温差，磨合期成本偏高' : '';
        $reasonShort = $score >= 78
            ? '情感节奏与互动推进较协调，关系升温路径清晰。'
            : ($score >= 60 ? '存在互补空间，建议通过沟通对齐节奏。' : '互动节奏差异较明显，建议先建立边界与沟通规则。');
        $topFeatures = (array) ($pair['top_highlights'] ?? []);
        $featureHint = empty($topFeatures) ? '' : (' 关键特征：'.implode('、', $topFeatures).'。');
        $reasonDetail = sprintf(
            '合盘过程层分项：日月互动%d、上升互动%d、情绪节奏%d、长期稳定%d。%s',
            $sunMoon,
            $ascScore,
            $emotionScore,
            $baziBridge,
            $full ? '核心信息完整，推进路径判断更稳定。' : '当前存在信息缺失，建议补全后复核。'
        ).$featureHint;
        $riskDetail = $score < 60
            ? ('情绪回应速度与表达方式存在时差，易出现“误解并非恶意”；建议建立固定复盘与确认机制。'.$pairRiskPoint)
            : ($degraded ? '当前为简化估算，缺失信息会降低结论稳定性。' : '');

        $featureRows = (array) ($pair['features'] ?? []);
        $featureTags = [];
        foreach ($featureRows as $fr) {
            if (! is_array($fr)) {
                continue;
            }
            $featureTags = array_merge($featureTags, (array) ($fr['evidence_tags'] ?? []));
        }
        $evidenceTags = array_values(array_unique(array_merge(['pair_chart_v2', 'sun_moon_harmony', 'emotion_rhythm'], $featureTags)));
        if ($score < 60) {
            $evidenceTags[] = 'pair_chart_tension';
        } else {
            $evidenceTags[] = 'pair_chart_harmony';
        }
        if ($degraded) {
            $evidenceTags[] = 'pair_chart_degraded';
        }

        return [
            'score' => $score,
            'match' => $match,
            'mismatch' => $mismatch,
            'confidence' => $confidence,
            'reason_short' => $reasonShort,
            'reason_detail' => $reasonDetail,
            'risk_detail' => $riskDetail,
            'evidence_tags' => $evidenceTags,
            'evidence' => [
                'sun_moon_ab' => $sunMoonAB,
                'sun_moon_ba' => $sunMoonBA,
                'asc_score' => $ascScore,
                'emotion_rhythm_score' => $emotionScore,
                'bazi_bridge' => $baziBridge,
                'gender_pair' => [$genderA, $genderB],
                'component_count' => $componentCount,
                'engine_source' => (string) ($m['source'] ?? ''),
                'features' => $featureRows,
            ],
            'degraded' => $degraded,
            'degrade_reason' => $degradeReason,
        ];
    }

    /**
     * @return array<string,int>
     */
    private function extractWuXing(mixed $chart): array
    {
        if (! is_array($chart)) {
            return [];
        }
        $raw = $chart['wu_xing'] ?? null;
        if (! is_array($raw)) {
            return [];
        }
        $normalized = [];
        foreach (['木', '火', '土', '金', '水'] as $k) {
            $normalized[$k] = (int) ($raw[$k] ?? 0);
        }

        return $normalized;
    }

    private function zodiacRelation(string $a, string $b): string
    {
        if ($a === $b) {
            return 'same';
        }

        $pairs = [
            'chong' => (array) config('match_rules.zodiac.chong', []),
            'xing' => (array) config('match_rules.zodiac.xing', []),
            'hai' => (array) config('match_rules.zodiac.hai', []),
            'liuhe' => (array) config('match_rules.zodiac.liuhe', []),
            'sanhe' => (array) config('match_rules.zodiac.sanhe', []),
        ];

        foreach (['chong', 'xing', 'hai', 'liuhe', 'sanhe'] as $type) {
            foreach ($pairs[$type] as $pair) {
                if (! is_array($pair) || count($pair) < 2) {
                    continue;
                }
                [$x, $y] = $pair;
                if (($a === $x && $b === $y) || ($a === $y && $b === $x)) {
                    return $type;
                }
            }
        }

        return 'normal';
    }

    private function toPercent(float $weight): int
    {
        return (int) round(max(0.0, min(1.0, $weight)) * 100);
    }

    private function astroAdapter(): AstroEngineAdapter
    {
        $name = strtolower(trim((string) config('matching.astro_engine_adapter', 'default')));
        /** @var AstrologyDependencyGateService $gate */
        $gate = app(AstrologyDependencyGateService::class);
        $licenseMap = [
            'swisseph' => 'swisseph',
            'pyswisseph' => 'pyswisseph',
            'kerykeion' => 'kerykeion',
        ];
        if (isset($licenseMap[$name])) {
            $allow = $gate->allow($licenseMap[$name]);
            if (! (bool) ($allow['allowed'] ?? false)) {
                $name = 'default';
            }
        }
        if ($name === 'standard') {
            /** @var AstroEngineAdapter $svc */
            $svc = app(StandardAstroEngineAdapter::class);

            return $svc;
        }
        /** @var AstroEngineAdapter $svc */
        $svc = app(DefaultAstroEngineAdapter::class);

        return $svc;
    }

    private function westernEngine(): WesternCompatibilityEngine
    {
        $name = strtolower(trim((string) config('matching.western_engine', 'default')));
        /** @var AstrologyDependencyGateService $gate */
        $gate = app(AstrologyDependencyGateService::class);
        $licenseMap = [
            'swisseph' => 'swisseph',
            'pyswisseph' => 'pyswisseph',
            'kerykeion' => 'kerykeion',
        ];
        if (isset($licenseMap[$name])) {
            $allow = $gate->allow($licenseMap[$name]);
            if (! (bool) ($allow['allowed'] ?? false)) {
                $name = 'default';
            }
        }
        if ($name === 'standard') {
            /** @var WesternCompatibilityEngine $svc */
            $svc = app(StandardWesternCompatibilityEngine::class);

            return $svc;
        }
        /** @var WesternCompatibilityEngine $svc */
        $svc = app(DefaultWesternCompatibilityEngine::class);

        return $svc;
    }
}
