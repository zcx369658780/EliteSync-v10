<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class ZiweiIztroAppVisibleReplacementTest extends TestCase
{
    public function test_app_visible_replacement_requires_explicit_production_gate(): void
    {
        Config::set('ziwei.iztro.mode', 'app_visible_replacement');
        Config::set('ziwei.iztro.app_visible_replacement.production_allowed', false);
        Config::set('ziwei.iztro.fail_open_to_current_runtime', true);

        $result = $this->service()->canonicalize($this->sampleBPayload());
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('ziwei_seed_estimate', $ziwei['engine']);
        $this->assertSame('approximate_not_validated', $ziwei['precision']);
        $this->assertSame('ziwei_placeholder_not_validated', $result['accuracy']);
        $this->assertContains(
            'iztro_app_visible_replacement_fallback:app_visible_replacement_not_allowed_by_config',
            $result['notes']
        );
        $this->assertSame('not_validated', $ziwei['external_oracle_status']);
        $this->assertTrue((bool) $ziwei['display_only']);
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
    }

    public function test_app_visible_replacement_outputs_b_iztro_14_main_star_subset(): void
    {
        $this->enableAppVisibleReplacement();

        $result = $this->service()->canonicalize($this->sampleBPayload());

        $this->assertAppVisibleContainment($result);
        $this->assertPalaces($result, [
            '命' => ['戌', ['紫微', '天相']],
            '兄弟' => ['酉', ['天机', '巨门']],
            '夫妻' => ['申', ['贪狼']],
            '子女' => ['未', ['太阳', '太阴']],
            '财帛' => ['午', ['武曲', '天府']],
            '疾厄' => ['巳', ['天同']],
            '迁移' => ['辰', ['破军']],
            '交友' => ['卯', []],
            '官禄' => ['寅', ['廉贞']],
            '田宅' => ['丑', []],
            '福德' => ['子', ['七杀']],
            '父母' => ['亥', ['天梁']],
        ]);
    }

    public function test_app_visible_replacement_outputs_c_iztro_14_main_star_subset(): void
    {
        $this->enableAppVisibleReplacement();

        $result = $this->service()->canonicalize($this->sampleCPayload());

        $this->assertAppVisibleContainment($result);
        $this->assertPalaces($result, [
            '命' => ['子', ['破军']],
            '兄弟' => ['亥', ['太阳']],
            '夫妻' => ['戌', ['武曲']],
            '子女' => ['酉', ['天同']],
            '财帛' => ['申', ['七杀']],
            '疾厄' => ['未', ['天梁']],
            '迁移' => ['午', ['廉贞', '天相']],
            '交友' => ['巳', ['巨门']],
            '官禄' => ['辰', ['贪狼']],
            '田宅' => ['卯', ['太阴']],
            '福德' => ['寅', ['紫微', '天府']],
            '父母' => ['丑', ['天机']],
        ]);
    }

    public function test_sample_a_fixture_remains_stable_in_app_visible_replacement_mode(): void
    {
        $this->enableAppVisibleReplacement();

        $result = $this->service()->canonicalize($this->sampleAPayload());
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('ziwei_cece_p0_oracle_minimum', $ziwei['engine']);
        $this->assertSame('p0_selected_fields_only', $ziwei['precision']);
        $this->assertSame('命宫', $ziwei['life_palace']);
        $this->assertSame(['紫微', '天府'], data_get($this->palaceByName($result, '命宫'), 'main_stars'));
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
    }

    private function enableAppVisibleReplacement(): void
    {
        Config::set('ziwei.iztro.mode', 'app_visible_replacement');
        Config::set('ziwei.iztro.app_visible_replacement.production_allowed', true);
        Config::set('ziwei.iztro.runner_path', base_path('tools/ziwei/iztro-runner/runner.mjs'));
        Config::set('ziwei.iztro.node_bin', 'node');
        Config::set('ziwei.iztro.timeout_ms', 5000);
        Config::set('ziwei.iztro.fail_open_to_current_runtime', true);
    }

    private function service(): ZiweiCanonicalService
    {
        return new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));
    }

    /**
     * @return array<string,mixed>
     */
    private function sampleAPayload(): array
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
     * @return array<string,mixed>
     */
    private function sampleBPayload(): array
    {
        return [
            'birthday' => '1994-03-18',
            'birth_time' => '09:20',
            'true_solar_time' => '09:12',
            'birth_place' => '浙江省杭州市西湖区',
            'gender' => 'female',
            'user_id' => 6202,
            'platform' => 'android',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private function sampleCPayload(): array
    {
        return [
            'birthday' => '2001-11-23',
            'birth_time' => '22:10',
            'true_solar_time' => '21:19',
            'birth_place' => '四川省成都市武侯区',
            'gender' => 'male',
            'user_id' => 6203,
            'platform' => 'android',
        ];
    }

    /**
     * @param array<string,mixed> $result
     */
    private function assertAppVisibleContainment(array $result): void
    {
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('third_party_candidate_iztro_app_visible_replacement', $ziwei['algorithm_route']);
        $this->assertSame('iztro@2.5.8', $ziwei['algorithm_version']);
        $this->assertSame('6.2i_iztro_app_visible_replacement_policy_v1', $ziwei['source_policy']);
        $this->assertSame('app_visible_replacement', $ziwei['replacement_mode']);
        $this->assertSame('not_validated', $ziwei['external_oracle_status']);
        $this->assertTrue((bool) $ziwei['display_only']);
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
        $this->assertSame(0, $ziwei['score']);
        $this->assertFalse((bool) $ziwei['matching_score_enabled']);
        $this->assertLessThanOrEqual(0.50, (float) $ziwei['confidence']);
        $this->assertSame('ziwei_iztro_app_visible_replacement_not_validated', $result['accuracy']);
        $this->assertCount(12, $ziwei['palaces']);
        $this->assertSame('pending_oracle', data_get($ziwei, 'flying_star_status.status'));
        $this->assertSame('not_implemented', data_get($ziwei, 'flying_star_status.implementation'));
        $this->assertContains('true_solar_time_must_be_precomputed_outside_iztro', $ziwei['warnings']);
        $this->assertStringContainsString('full Ziwei correctness', implode(' ', $ziwei['limitations']));
    }

    /**
     * @param array<string,mixed> $result
     * @param array<string,array{0:string,1:list<string>}> $expected
     */
    private function assertPalaces(array $result, array $expected): void
    {
        foreach ($expected as $palaceName => [$branch, $mainStars]) {
            $palace = $this->palaceByName($result, $palaceName);
            $this->assertSame($branch, $palace['branch'] ?? null, $palaceName);
            $this->assertSame($mainStars, $palace['main_stars'] ?? null, $palaceName);
            $this->assertSame(
                $mainStars === [] ? 'no_14_main_star_in_strict_subset' : 'none',
                $palace['empty_main_star_status'] ?? null,
                $palaceName
            );
        }
    }

    /**
     * @param array<string,mixed> $result
     * @return array<string,mixed>
     */
    private function palaceByName(array $result, string $name): array
    {
        foreach ((array) data_get($result, 'ziwei.palaces', []) as $palace) {
            $palace = (array) $palace;
            $displayName = str_ends_with($name, '宫') ? $name : $name.'宫';

            if (
                ($palace['palace_name'] ?? null) === $name
                || ($palace['palace_name'] ?? null) === $displayName
                || ($palace['name'] ?? null) === $name
                || ($palace['name'] ?? null) === $displayName
            ) {
                return $palace;
            }
        }

        $this->fail("Missing palace {$name}");
    }
}
