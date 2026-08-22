<?php

namespace Tests\Unit;

use App\Support\Ziwei\ZiweiIztroRunnerClient;
use App\Support\Ziwei\ZiweiIztroShadowAdapter;
use Tests\TestCase;

class ZiweiIztroRunnerClientTest extends TestCase
{
    public function test_runner_client_is_disabled_by_default_boundary(): void
    {
        $client = new ZiweiIztroRunnerClient(
            runnerPath: base_path('tools/ziwei/iztro-runner/runner.mjs'),
        );

        $result = $client->run(ZiweiIztroShadowAdapter::fixtureInput('A'));

        $this->assertFalse((bool) $result['success']);
        $this->assertSame('shadow_runner_disabled', $result['failure_reason']);
        $this->assertTrue((bool) $result['display_only']);
        $this->assertSame('not_validated', $result['external_oracle_status']);
        $this->assertSame('excluded_from_core_matching', $result['scoring_status']);
        $this->assertFalse((bool) $result['production_runtime_enabled']);
        $this->assertFalse((bool) $result['user_facing_enabled']);
    }

    public function test_runner_client_returns_fallback_for_missing_runner_path(): void
    {
        $client = new ZiweiIztroRunnerClient(
            runnerPath: base_path('tools/ziwei/iztro-runner/missing-runner.mjs'),
            enabled: true,
        );

        $result = $client->run(ZiweiIztroShadowAdapter::fixtureInput('A'));

        $this->assertFalse((bool) $result['success']);
        $this->assertSame('shadow_runner_missing', $result['failure_reason']);
        $this->assertSame('shadow_tool_only', $result['dependency_adopted']);
    }

    public function test_runner_client_executes_iztro_runner_for_sample_a(): void
    {
        $client = new ZiweiIztroRunnerClient(
            runnerPath: base_path('tools/ziwei/iztro-runner/runner.mjs'),
            enabled: true,
        );

        $result = $client->run(ZiweiIztroShadowAdapter::fixtureInput('A'));

        $this->assertTrue((bool) $result['success']);
        $this->assertSame('iztro@2.5.8', $result['algorithm_version']);
        $this->assertSame('寅', data_get($result, 'life_palace.branch'));
        $this->assertSame('辰', data_get($result, 'body_palace.branch'));
        $this->assertSame('火六局', $result['five_element_bureau']);
        $this->assertCount(12, $result['palaces']);
        $this->assertContains('交友', array_column($result['palaces'], 'palace_name'));
        $this->assertTrue((bool) $result['display_only']);
        $this->assertSame('excluded_from_core_matching', $result['scoring_status']);
        $this->assertFalse((bool) $result['production_runtime_enabled']);
        $this->assertFalse((bool) $result['user_facing_enabled']);
    }

    public function test_runner_client_handles_malformed_json_without_throwing(): void
    {
        $script = sys_get_temp_dir().DIRECTORY_SEPARATOR.'iztro-bad-json-'.bin2hex(random_bytes(6)).'.mjs';
        file_put_contents($script, "process.stdout.write('not json');\n");

        try {
            $client = new ZiweiIztroRunnerClient(
                runnerPath: $script,
                enabled: true,
            );

            $result = $client->run(ZiweiIztroShadowAdapter::fixtureInput('A'));

            $this->assertFalse((bool) $result['success']);
            $this->assertSame('shadow_runner_malformed_json', $result['failure_reason']);
        } finally {
            @unlink($script);
        }
    }

    public function test_runner_client_handles_nonzero_exit_without_throwing(): void
    {
        $script = sys_get_temp_dir().DIRECTORY_SEPARATOR.'iztro-nonzero-'.bin2hex(random_bytes(6)).'.mjs';
        file_put_contents($script, "process.stdout.write(JSON.stringify({success:false,error_code:'forced'})); process.exit(7);\n");

        try {
            $client = new ZiweiIztroRunnerClient(
                runnerPath: $script,
                enabled: true,
            );

            $result = $client->run(ZiweiIztroShadowAdapter::fixtureInput('A'));

            $this->assertFalse((bool) $result['success']);
            $this->assertSame('shadow_runner_nonzero_exit', $result['failure_reason']);
            $this->assertSame('forced', data_get($result, 'runner_payload.error_code'));
        } finally {
            @unlink($script);
        }
    }
}
