<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class ZiweiIztroLocalReplacementTest extends TestCase
{
    public function test_default_off_mode_keeps_non_fixture_seed_output_unchanged(): void
    {
        Config::set('ziwei.iztro.mode', 'off');

        $result = $this->service()->canonicalize($this->sampleBPayload());
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('ziwei_seed_estimate', $ziwei['engine']);
        $this->assertSame('approximate_not_validated', $ziwei['precision']);
        $this->assertSame('ziwei_placeholder_not_validated', $result['accuracy']);
        $this->assertArrayNotHasKey('algorithm_route', $ziwei);
        $this->assertSame('not_validated', $ziwei['external_oracle_status']);
        $this->assertTrue((bool) $ziwei['display_only']);
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
    }

    public function test_local_replacement_mode_outputs_b_iztro_14_main_star_subset(): void
    {
        $this->enableLocalReplacement();

        $result = $this->service()->canonicalize($this->sampleBPayload());

        $this->assertLocalReplacementContainment($result);
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

    public function test_local_replacement_mode_outputs_c_iztro_14_main_star_subset(): void
    {
        $this->enableLocalReplacement();

        $result = $this->service()->canonicalize($this->sampleCPayload());

        $this->assertLocalReplacementContainment($result);
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

    public function test_sample_a_fixture_remains_stable_in_local_replacement_mode(): void
    {
        $this->enableLocalReplacement();

        $result = $this->service()->canonicalize($this->sampleAPayload());
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('ziwei_cece_p0_oracle_minimum', $ziwei['engine']);
        $this->assertSame('p0_selected_fields_only', $ziwei['precision']);
        $this->assertSame('命宫', $ziwei['life_palace']);
        $this->assertSame(['紫微', '天府'], data_get($this->palaceByName($result, '命宫'), 'main_stars'));
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
    }

    public function test_missing_runner_path_falls_back_to_current_seed_output(): void
    {
        $this->enableLocalReplacement();
        Config::set('ziwei.iztro.runner_path', base_path('tools/ziwei/iztro-runner/missing-runner.mjs'));

        $result = $this->service()->canonicalize($this->sampleBPayload());

        $this->assertSeedFallback($result, 'shadow_runner_missing');
    }

    public function test_invalid_node_binary_falls_back_to_current_seed_output(): void
    {
        $this->enableLocalReplacement();
        Config::set('ziwei.iztro.node_bin', 'missing-node-binary-for-iztro-local-replacement');

        $result = $this->service()->canonicalize($this->sampleBPayload());

        $this->assertSeedFallback($result, 'node_binary_missing_or_process_open_failed');
    }

    public function test_timeout_falls_back_to_current_seed_output(): void
    {
        $script = sys_get_temp_dir().DIRECTORY_SEPARATOR.'iztro-timeout-'.bin2hex(random_bytes(6)).'.mjs';
        file_put_contents($script, "setTimeout(() => process.stdout.write(JSON.stringify({success:true})), 2000);\n");

        try {
            $this->enableLocalReplacement();
            Config::set('ziwei.iztro.runner_path', $script);
            Config::set('ziwei.iztro.timeout_ms', 1);

            $result = $this->service()->canonicalize($this->sampleBPayload());

            $this->assertSeedFallback($result, 'shadow_runner_timeout');
        } finally {
            @unlink($script);
        }
    }

    public function test_malformed_json_falls_back_to_current_seed_output(): void
    {
        $script = sys_get_temp_dir().DIRECTORY_SEPARATOR.'iztro-bad-json-local-'.bin2hex(random_bytes(6)).'.mjs';
        file_put_contents($script, "process.stdout.write('not json');\n");

        try {
            $this->enableLocalReplacement();
            Config::set('ziwei.iztro.runner_path', $script);

            $result = $this->service()->canonicalize($this->sampleBPayload());

            $this->assertSeedFallback($result, 'shadow_runner_malformed_json');
        } finally {
            @unlink($script);
        }
    }

    public function test_nonzero_exit_falls_back_to_current_seed_output(): void
    {
        $script = sys_get_temp_dir().DIRECTORY_SEPARATOR.'iztro-nonzero-local-'.bin2hex(random_bytes(6)).'.mjs';
        file_put_contents($script, "process.stdout.write(JSON.stringify({success:false,error_code:'forced'})); process.exit(7);\n");

        try {
            $this->enableLocalReplacement();
            Config::set('ziwei.iztro.runner_path', $script);

            $result = $this->service()->canonicalize($this->sampleBPayload());

            $this->assertSeedFallback($result, 'shadow_runner_nonzero_exit');
        } finally {
            @unlink($script);
        }
    }

    public function test_unsupported_input_falls_back_to_current_seed_output(): void
    {
        $this->enableLocalReplacement();

        $payload = $this->sampleBPayload();
        $payload['gender'] = 'unknown';
        $result = $this->service()->canonicalize($payload);

        $this->assertSeedFallback($result, 'unsupported_input');
    }

    private function service(): ZiweiCanonicalService
    {
        return new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));
    }

    private function enableLocalReplacement(): void
    {
        Config::set('ziwei.iztro.mode', 'local_replacement');
        Config::set('ziwei.iztro.runner_path', base_path('tools/ziwei/iztro-runner/runner.mjs'));
        Config::set('ziwei.iztro.node_bin', 'node');
        Config::set('ziwei.iztro.timeout_ms', 5000);
        Config::set('ziwei.iztro.fail_open_to_current_runtime', true);
        Config::set('ziwei.iztro.allowed_local_replacement_environments', [app()->environment()]);
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
            'birth_place' => '上海',
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
            'birth_place' => '北京',
            'gender' => 'male',
            'user_id' => 6203,
            'platform' => 'android',
        ];
    }

    /**
     * @param array<string,mixed> $result
     */
    private function assertLocalReplacementContainment(array $result): void
    {
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('third_party_candidate_iztro_local_replacement', $ziwei['algorithm_route']);
        $this->assertSame('iztro@2.5.8', $ziwei['algorithm_version']);
        $this->assertSame('not_validated', $ziwei['external_oracle_status']);
        $this->assertTrue((bool) $ziwei['display_only']);
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
        $this->assertSame(0, $ziwei['score']);
        $this->assertLessThanOrEqual(0.50, (float) $ziwei['confidence']);
        $this->assertSame('ziwei_iztro_local_replacement_not_validated', $result['accuracy']);
        $this->assertCount(12, $ziwei['palaces']);
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
     */
    private function assertSeedFallback(array $result, string $reason): void
    {
        $ziwei = (array) $result['ziwei'];

        $this->assertSame('ziwei_seed_estimate', $ziwei['engine']);
        $this->assertSame('approximate_not_validated', $ziwei['precision']);
        $this->assertSame('ziwei_placeholder_not_validated', $result['accuracy']);
        $this->assertSame('not_validated', $ziwei['external_oracle_status']);
        $this->assertTrue((bool) $ziwei['display_only']);
        $this->assertSame('excluded_from_core_matching', $ziwei['scoring_status']);
        $this->assertContains('iztro_local_replacement_fallback:'.$reason, $result['notes']);
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
