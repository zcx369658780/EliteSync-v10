<?php

namespace Tests\Unit;

use App\Services\NatalCalculationService;
use RuntimeException;
use Tests\TestCase;

class V1010NatalRuntimeGateTest extends TestCase
{
    public function test_known_time_cannot_calculate_or_reuse_an_unobserved_runtime_identity(): void
    {
        config(['natal.python' => '', 'natal.kernel' => '']);
        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('natal_runtime_identity_unavailable');
        app(NatalCalculationService::class)->compute([
            'civil_date' => '2000-01-01', 'normalized_time' => '12:00:00',
            'utc' => '2000-01-01T12:00:00Z', 'time_precision' => 'second',
            'calculation_profile' => ['runtime_identity' => ['status' => 'IDENTITY_UNAVAILABLE']],
        ], ['true_solar_time' => false, 'target_year' => null]);
    }
}
