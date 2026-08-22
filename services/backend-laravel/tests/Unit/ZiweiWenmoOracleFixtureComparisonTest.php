<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use App\Services\ZiweiCanonicalService;
use Tests\TestCase;

class ZiweiWenmoOracleFixtureComparisonTest extends TestCase
{
    private const WENMO_SOURCE_LABEL = 'GPT advisor preliminary visual transcription from user-provided Wenmo Tianji screenshots; requires later human/vision confirmation.';

    public function test_cece_legacy_fixture_evidence_is_one_palace_offset_from_wenmo_candidate(): void
    {
        $this->assertSame(
            self::WENMO_SOURCE_LABEL,
            'GPT advisor preliminary visual transcription from user-provided Wenmo Tianji screenshots; requires later human/vision confirmation.'
        );

        $legacyByBranch = [];
        foreach ($this->legacyCeceP0PalaceFixture() as $palaceName => $expectation) {
            $legacyByBranch[$expectation['branch']] = [
                'palace' => $palaceName,
                'main_stars' => $expectation['main_stars'],
            ];
        }

        $mismatches = [];
        foreach ($this->wenmoCandidateFixture() as $palaceName => $expectation) {
            $legacy = $legacyByBranch[$expectation['branch']] ?? null;
            $this->assertNotNull($legacy, "Missing legacy branch {$expectation['branch']}");
            $this->assertSame($expectation['main_stars'], $legacy['main_stars'], $palaceName);

            if ($legacy['palace'] !== $palaceName) {
                $mismatches[$expectation['branch']] = [
                    'wenmo' => $palaceName,
                    'legacy' => $legacy['palace'],
                ];
            }
        }

        $this->assertCount(12, $mismatches);
        $this->assertSame(['wenmo' => '父母宫', 'legacy' => '命宫'], $mismatches['卯']);
        $this->assertSame(['wenmo' => '命宫', 'legacy' => '兄弟宫'], $mismatches['寅']);
    }

    public function test_current_jingtai_fixture_palace_branch_and_main_star_mapping_matches_wenmo_candidate(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $result = $service->canonicalize($this->jingtaiFixturePayload());
        $ziwei = (array) ($result['ziwei'] ?? []);

        foreach ($this->wenmoCandidateFixture() as $palaceName => $expectation) {
            $palace = $this->palaceByName($ziwei, $palaceName);
            $this->assertSame($expectation['branch'], $palace['branch'] ?? null, $palaceName);
            $this->assertSame($expectation['main_stars'], $palace['main_stars'] ?? null, $palaceName);
        }

        $this->assertSame('命宫', (string) ($ziwei['life_palace'] ?? ''));
        $this->assertSame('寅', (string) data_get($ziwei, 'life_palace_detail.branch'));
        $this->assertSame(['紫微', '天府'], data_get($ziwei, 'life_palace_detail.main_stars'));
        $this->assertSame('not_validated', (string) ($ziwei['external_oracle_status'] ?? ''));
        $this->assertTrue((bool) ($ziwei['display_only'] ?? false));
        $this->assertSame('excluded_from_core_matching', (string) ($ziwei['scoring_status'] ?? ''));
        $this->assertSame(0.58, (float) ($ziwei['confidence'] ?? 0));
        $this->assertSame('insufficient_oracle', data_get($ziwei, 'flying_star_status.status'));
        $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'));
    }

    public function test_current_jingtai_fixture_four_transformations_keep_stars_but_use_corrected_palaces(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));

        $result = $service->canonicalize($this->jingtaiFixturePayload());
        $ziwei = (array) ($result['ziwei'] ?? []);

        $this->assertSame([
            $this->acceptedSihuaRow('化禄', '武曲', '财帛宫', '甲戌'),
            $this->acceptedSihuaRow('化权', '贪狼', '福德宫', '戊辰'),
            $this->acceptedSihuaRow('化科', '天梁', '交友宫', '辛未'),
            $this->acceptedSihuaRow('化忌', '文曲', '子女宫', '乙亥'),
        ], $ziwei['four_transformations'] ?? []);
    }

    /**
     * @return array<string,array{branch:string,main_stars:array<int,string>}>
     */
    private function wenmoCandidateFixture(): array
    {
        // 6.2b scope: palace-name / branch / main-star mapping only.
        // Expanded Wenmo auxiliary-star alignment remains a separate oracle-confirmation gate.
        return [
            '命宫' => ['branch' => '寅', 'main_stars' => ['紫微', '天府']],
            '兄弟宫' => ['branch' => '丑', 'main_stars' => ['天机']],
            '夫妻宫' => ['branch' => '子', 'main_stars' => ['破军']],
            '子女宫' => ['branch' => '亥', 'main_stars' => ['太阳']],
            '财帛宫' => ['branch' => '戌', 'main_stars' => ['武曲']],
            '疾厄宫' => ['branch' => '酉', 'main_stars' => ['天同']],
            '迁移宫' => ['branch' => '申', 'main_stars' => ['七杀']],
            '交友宫' => ['branch' => '未', 'main_stars' => ['天梁']],
            '官禄宫' => ['branch' => '午', 'main_stars' => ['廉贞', '天相']],
            '田宅宫' => ['branch' => '巳', 'main_stars' => ['巨门']],
            '福德宫' => ['branch' => '辰', 'main_stars' => ['贪狼']],
            '父母宫' => ['branch' => '卯', 'main_stars' => ['太阴']],
        ];
    }

    /**
     * @return array<string,array{branch:string,main_stars:array<int,string>}>
     */
    private function legacyCeceP0PalaceFixture(): array
    {
        return [
            '命宫' => ['branch' => '卯', 'main_stars' => ['太阴']],
            '兄弟宫' => ['branch' => '寅', 'main_stars' => ['紫微', '天府']],
            '夫妻宫' => ['branch' => '丑', 'main_stars' => ['天机']],
            '子女宫' => ['branch' => '子', 'main_stars' => ['破军']],
            '财帛宫' => ['branch' => '亥', 'main_stars' => ['太阳']],
            '疾厄宫' => ['branch' => '戌', 'main_stars' => ['武曲']],
            '迁移宫' => ['branch' => '酉', 'main_stars' => ['天同']],
            '交友宫' => ['branch' => '申', 'main_stars' => ['七杀']],
            '官禄宫' => ['branch' => '未', 'main_stars' => ['天梁']],
            '田宅宫' => ['branch' => '午', 'main_stars' => ['廉贞', '天相']],
            '福德宫' => ['branch' => '巳', 'main_stars' => ['巨门']],
            '父母宫' => ['branch' => '辰', 'main_stars' => ['贪狼']],
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private function jingtaiFixturePayload(): array
    {
        return [
            'birthday' => '1989-09-05',
            'birth_time' => '14:30',
            'daylight_saving' => true,
            'chart_beijing_time' => '13:30',
            'lunar_date' => '己巳年八月初六',
            'time_branch' => '未',
            'birth_place' => '白银市景泰县',
            'true_solar_time' => '12:27',
            'gender' => 'male',
            'user_id' => 22,
            'platform' => 'android',
        ];
    }

    /**
     * @param array<string,mixed> $ziwei
     * @return array<string,mixed>
     */
    private function palaceByName(array $ziwei, string $name): array
    {
        foreach ((array) ($ziwei['palaces'] ?? []) as $palace) {
            $palace = (array) $palace;
            if (($palace['name'] ?? null) === $name || ($palace['palace_name'] ?? null) === $name) {
                return $palace;
            }
        }

        $this->fail("Missing palace {$name}");
    }

    /**
     * @return array<string,mixed>
     */
    private function acceptedSihuaRow(string $transform, string $star, string $palace, string $branch): array
    {
        return [
            'transform' => $transform,
            'star' => $star,
            'palace' => $palace,
            'branch' => $branch,
            'status' => 'accepted_oracle',
            'source_app' => 'wenmo_tianji_pro',
            'evidence_source' => '6.3d_wenmo_screenshots',
            'adjudication_source' => '6.3e_gpt_advisor_visual_adjudication',
            'display_only' => true,
            'matching_policy' => 'display_only_no_matching_scoring',
        ];
    }
}
