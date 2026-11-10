<?php

namespace Tests\Unit;

use App\Models\User;
use App\Services\DynamicChartService;
use InvalidArgumentException;
use Tests\TestCase;

class V1011DynamicInputTest extends TestCase
{
    private function body(string $type, array $event): array
    {
        return ['chart_type' => $type, 'first' => ['source' => 'manual', 'input' => [
            'civil_date' => '1996-02-29', 'civil_time' => '03:12:09', 'time_precision' => 'second',
            'timezone' => 'Etc/UTC', 'latitude' => 51.0, 'longitude' => 1.0,
        ]], 'event' => $event, 'settings' => [], 'expected_revision' => 0];
    }

    public function test_solar_year_is_the_selected_timezone_half_open_civil_year(): void
    {
        $p = app(DynamicChartService::class)->prepare(new User(), $this->body('solar_return', [
            'year' => 2024, 'timezone' => 'America/New_York', 'latitude' => 40.7, 'longitude' => -74.0,
        ]));
        $this->assertSame('2024-01-01T05:00:00Z', $p['payload']['event']['window_start']);
        $this->assertSame('2025-01-01T05:00:00Z', $p['payload']['event']['window_end']);
        $this->assertSame('1996-02-29', $p['payload']['first']['civil_date']);
    }

    public function test_event_fold_is_explicit_and_does_not_change_birth_or_first_cache_signature(): void
    {
        $body = $this->body('transit', ['civil_date' => '2024-11-03', 'civil_time' => '01:30:00',
            'time_precision' => 'second', 'timezone' => 'America/New_York', 'latitude' => 40.7,
            'longitude' => -74.0, 'fold' => 0]);
        $service = app(DynamicChartService::class);
        $a = $service->prepare(new User(), $body);
        $body['event']['fold'] = 1;
        $b = $service->prepare(new User(), $body);
        $this->assertSame('2024-11-03T05:30:00Z', $a['payload']['event']['utc']);
        $this->assertSame('2024-11-03T06:30:00Z', $b['payload']['event']['utc']);
        $this->assertSame($a['first_context_signature'], $b['first_context_signature']);
        $this->assertNotSame($a['input_signature'], $b['input_signature']);
    }

    public function test_unknown_time_and_missing_coordinates_are_refused_without_synthetic_values(): void
    {
        $body = $this->body('lunar_return', ['civil_date' => '2025-01-01', 'civil_time' => null,
            'time_precision' => 'unknown', 'timezone' => 'Etc/UTC']);
        $this->expectException(InvalidArgumentException::class);
        app(DynamicChartService::class)->prepare(new User(), $body);
    }

    public function test_runtime_gate_remains_closed_by_default(): void
    {
        config(['dynamic_charts.enabled' => false]);
        $this->getJson('/api/v1/profile/dynamic')->assertForbidden()
            ->assertHeader('Cache-Control', 'no-store, private');
    }
}
