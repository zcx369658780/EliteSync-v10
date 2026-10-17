<?php

namespace Tests\Unit;

use App\Services\NatalCalculationProfile;
use App\Services\NatalRuntimeIdentity;
use App\Services\NatalInputContext;
use App\Services\NatalProfileView;
use App\Models\UserNatalProfile;
use Tests\TestCase;

class V1010NatalRuntimeIdentityTest extends TestCase
{
    public function test_unconfigured_identity_is_explicit_stable_and_does_not_leak_paths(): void
    {
        config(['natal.python' => '', 'natal.kernel' => 'private-local-path']);
        $identity = app(NatalRuntimeIdentity::class)->make();
        $this->assertSame('IDENTITY_UNAVAILABLE', $identity['status']);
        $this->assertSame($identity, app(NatalRuntimeIdentity::class)->make());
        $this->assertStringNotContainsString('private-local-path', json_encode($identity));
        config(['natal.kernel' => 'different-private-path']);
        $this->assertNotSame($identity['configuration_sha256'], app(NatalRuntimeIdentity::class)->make()['configuration_sha256']);
    }

    public function test_probe_failure_is_not_an_exception_or_success(): void
    {
        config(['natal.python' => 'nonexistent-private-interpreter', 'natal.kernel' => 'private-kernel']);
        $result = app(NatalRuntimeIdentity::class)->make();
        $this->assertSame('IDENTITY_UNAVAILABLE', $result['status']);
        $this->assertSame('offline_runtime_probe_failed', $result['reason']);
        $this->assertStringNotContainsString('private-', json_encode($result));
    }

    public function test_profile_binds_runtime_and_implementation_hashes_without_requiring_configuration(): void
    {
        config(['natal.python' => '', 'natal.kernel' => '']);
        $profile = app(NatalCalculationProfile::class)->make([]);
        $this->assertSame('IDENTITY_UNAVAILABLE', $profile['runtime_identity']['status']);
        $this->assertSame(hash_file('sha256', base_path('tools/natal/runtime_identity.py')),
            $profile['source_hashes']['tools/natal/runtime_identity.py']);
        $this->assertArrayHasKey('tools/natal/requirements.lock', $profile['source_hashes']);
    }

    public function test_real_configured_offline_runtime_when_explicitly_supplied(): void
    {
        $python = getenv('NATAL_IDENTITY_TEST_PYTHON');
        $kernel = getenv('NATAL_IDENTITY_TEST_KERNEL');
        if (! $python || ! $kernel) {
            $this->markTestSkipped('Explicit owned runtime/kernel paths not supplied.');
        }
        config(['natal.python' => $python, 'natal.kernel' => $kernel]);
        $started = microtime(true);
        $identity = app(NatalRuntimeIdentity::class)->make();
        $elapsed = microtime(true) - $started;
        $this->assertSame('AVAILABLE', $identity['status']);
        $this->assertSame('1.55', $identity['packages']['skyfield']['version']);
        $this->assertSame($identity['kernel']['admitted_sha256'], $identity['kernel']['actual_sha256']);
        $this->assertStringNotContainsString($kernel, json_encode($identity));
        fwrite(STDOUT, json_encode(['real_identity_probe_seconds' => round($elapsed, 4)]).PHP_EOL);
    }

    public function test_actual_kernel_mutation_invalidates_in_memory_persisted_view_without_database(): void
    {
        $python = getenv('NATAL_IDENTITY_TEST_PYTHON');
        $kernel = getenv('NATAL_IDENTITY_TEST_KERNEL');
        if (! $python || ! $kernel) {
            $this->markTestSkipped('Explicit owned runtime/kernel paths not supplied.');
        }
        config(['natal.python' => $python, 'natal.kernel' => $kernel]);
        $input = ['civil_date' => '2000-01-01', 'civil_time' => '12:00:00',
            'time_precision' => 'second', 'timezone' => 'Europe/London',
            'latitude' => 51.5, 'longitude' => 0.0, 'algorithm_sex' => 'male'];
        $settings = app(NatalCalculationProfile::class)->settings([]);
        $profile = app(NatalCalculationProfile::class)->make($settings);
        $this->assertSame('AVAILABLE', $profile['runtime_identity']['status']);
        $context = app(NatalInputContext::class)->normalize($input, $profile);
        $row = new UserNatalProfile(['input' => $input, 'settings' => $settings,
            'context' => $context, 'input_signature' => $context['input_signature'],
            'input_revision' => 1, 'result_revision' => 1, 'status' => 'UNVERIFIED',
            'results' => ['test_marker' => 'cached-result-for-identity-check-only']]);
        $view = app(NatalProfileView::class);
        $this->assertSame($row->results, $view->profile($row)['results']);
        $ownedCopy = tempnam(sys_get_temp_dir(), 'v1010-identity-');
        $this->assertNotFalse($ownedCopy);
        try {
            $this->assertTrue(copy($kernel, $ownedCopy));
            $stream = fopen($ownedCopy, 'r+b');
            fseek($stream, -1, SEEK_END);
            $last = fread($stream, 1);
            fseek($stream, -1, SEEK_END);
            fwrite($stream, chr(ord($last) ^ 1));
            fclose($stream);
            config(['natal.kernel' => $ownedCopy]);
            $changed = app(NatalCalculationProfile::class)->make($settings);
            $this->assertSame('IDENTITY_UNAVAILABLE', $changed['runtime_identity']['status']);
            $this->assertNotSame($profile['runtime_identity']['kernel']['actual_sha256'],
                $changed['runtime_identity']['kernel']['actual_sha256']);
            $stale = $view->profile($row);
            $this->assertSame('STALE_RECALCULATION_REQUIRED', $stale['status']);
            $this->assertNull($stale['results']);
            $this->assertNull($stale['result_revision']);
        } finally {
            config(['natal.kernel' => $kernel]);
            unlink($ownedCopy);
        }
        $this->assertSame($row->results, $view->profile($row)['results']);
        $this->assertSame($profile['runtime_identity']['kernel']['actual_sha256'], hash_file('sha256', $kernel));
        $this->assertFalse($row->exists);
    }
}
