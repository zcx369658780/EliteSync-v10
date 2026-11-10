<?php

namespace Tests\Unit;

use App\Services\NatalCalculationProfile;
use App\Services\NatalCalculationService;
use App\Services\NatalInputContext;
use Tests\TestCase;

/** Real local process integration; not a new astronomical accuracy oracle. */
class V1010NatalDerivedDateBoundaryTest extends TestCase
{
    public function test_solar_date_padding_keeps_supported_civil_input_and_unverified_reference_state(): void
    {
        $python = getenv('NATAL_IDENTITY_TEST_PYTHON');
        $kernel = getenv('NATAL_IDENTITY_TEST_KERNEL');
        if (! $python || ! $kernel) {
            $this->markTestSkipped('Explicit owned runtime/kernel paths not supplied.');
        }
        config(['natal.python' => $python, 'natal.kernel' => $kernel]);
        foreach ([
            ['1900-01-01', '00:00:00', 'Pacific/Kiritimati', -179.9, '1899'],
            ['2100-12-31', '23:59:59', 'Pacific/Pago_Pago', 179.9, '2101'],
        ] as [$date, $time, $zone, $longitude, $effectiveYear]) {
            $settings = app(NatalCalculationProfile::class)->settings(['point_set' => 'full', 'true_solar_time' => true]);
            $context = app(NatalInputContext::class)->normalize([
                'civil_date' => $date, 'civil_time' => $time, 'time_precision' => 'second',
                'timezone' => $zone, 'latitude' => 0.0, 'longitude' => $longitude, 'algorithm_sex' => 'male',
            ], app(NatalCalculationProfile::class)->make($settings));
            $result = app(NatalCalculationService::class)->compute($context, $settings);
            $this->assertSame($date, $result['ziwei']['effective_input']['source_civil_date']);
            $this->assertStringStartsWith($effectiveYear.'-', $result['ziwei']['effective_input']['effective_civil_date']);
            $this->assertSame('DERIVED_EDGE_DATE_UNVERIFIED', $result['ziwei']['effective_input']['calendar_reference_status']);
            $this->assertSame('UNVERIFIED', $result['ziwei']['oracle_status']);
            $this->assertCount(12, $result['ziwei']['palaces']);
            $this->assertCount(14, $result['western']['planets']);
            $this->assertNotNull($result['bazi']['pillars']);
        }
    }
}
