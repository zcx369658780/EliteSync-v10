<?php

namespace Tests\Unit;

use App\Services\NatalCalculationService;
use PHPUnit\Framework\TestCase;
use RuntimeException;

class V1010NatalChironResultIdentityTest extends TestCase
{
    public function test_full_result_must_use_the_request_data_and_manifest(): void
    {
        $artifact = str_repeat('a', 64);
        $manifest = str_repeat('b', 64);
        $profile = ['source_hashes' => [
            'resources/natal/data/chiron-lowell-hermite8d-v1.npz' => $artifact,
            'resources/natal/chiron-data-manifest.json' => $manifest,
        ]];
        $point = ['name' => 'chiron', 'data_sha256' => $artifact, 'data_manifest_sha256' => $manifest];
        $result = ['planets' => [$point], 'effective_profile' => ['point_set' => 'full'], 'unavailable_points' => []];
        $service = new NatalCalculationService;
        $service->validateChironIdentity($result, $profile);
        $mutations = [
            [...$result, 'planets' => [[...$point, 'data_sha256' => str_repeat('c', 64)]]],
            [...$result, 'planets' => [[...$point, 'data_manifest_sha256' => str_repeat('c', 64)]]],
            [...$result, 'planets' => []],
            [...$result, 'planets' => [$point, $point]],
            [...$result, 'effective_profile' => ['point_set' => 'PARTIAL_FULL']],
            [...$result, 'unavailable_points' => [['name' => 'chiron']]],
        ];
        foreach ($mutations as $mutation) {
            try {
                $service->validateChironIdentity($mutation, $profile);
                $this->fail('Changed or incomplete full result was accepted.');
            } catch (RuntimeException $error) {
                $this->assertSame('natal_chiron_result_identity_mismatch', $error->getMessage());
            }
        }
    }
}
