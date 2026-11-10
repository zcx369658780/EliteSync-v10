<?php

namespace Tests\Unit;

use App\Services\NatalInputContext;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class V1010NatalInputContextTest extends TestCase
{
    private function input(array $changes = []): array
    {
        return array_replace([
            'civil_date' => '2000-01-01',
            'civil_time' => '00:30',
            'time_precision' => 'minute',
            'timezone' => 'Asia/Shanghai',
            'latitude' => 31.2,
            'longitude' => 121.5,
        ], $changes);
    }

    private function normalize(array $changes = [], ?array $profile = null): array
    {
        return (new NatalInputContext)->normalize($this->input($changes), $profile ?? [
            'id' => 'synthetic-test', 'version' => '1',
        ]);
    }

    public function test_civil_input_is_preserved_and_utc_can_cross_the_date_boundary(): void
    {
        $context = $this->normalize();
        $this->assertSame('2000-01-01', $context['civil_date']);
        $this->assertSame('00:30', $context['civil_time']);
        $this->assertSame('00:30:00', $context['normalized_time']);
        $this->assertSame('1999-12-31T16:30:00Z', $context['utc']);
        $this->assertSame(28800, $context['utc_offset_seconds']);
        $this->assertSame('unknown', $context['algorithm_sex']);
        $this->assertNotEmpty($context['tzdb_version']);
    }

    public function test_unknown_time_stays_unknown_without_inventing_noon_or_gender(): void
    {
        $context = $this->normalize([
            'civil_time' => null, 'time_precision' => 'unknown',
            'gender' => 'male', 'latitude' => null, 'longitude' => null,
        ]);
        $this->assertNull($context['civil_time']);
        $this->assertNull($context['normalized_time']);
        $this->assertNull($context['utc']);
        $this->assertNull($context['utc_offset_seconds']);
        $this->assertNull($context['fold']);
        $this->assertSame('unknown', $context['algorithm_sex']);
    }

    public function test_second_precision_and_explicit_algorithm_parameter_are_preserved(): void
    {
        $context = $this->normalize([
            'civil_time' => '23:59:59', 'time_precision' => 'second',
            'algorithm_sex' => 'female',
        ]);
        $this->assertSame('2000-01-01T15:59:59Z', $context['utc']);
        $this->assertSame('female', $context['algorithm_sex']);
    }

    public function test_dst_gap_is_rejected_instead_of_silently_shifted(): void
    {
        $this->expectExceptionMessage('civil_time_in_dst_gap');
        $this->normalize(['civil_date' => '2024-03-10', 'civil_time' => '02:30', 'timezone' => 'America/New_York']);
    }

    public function test_dst_fold_requires_explicit_disambiguation(): void
    {
        $this->expectExceptionMessage('ambiguous_civil_time_requires_fold_or_offset');
        $this->normalize(['civil_date' => '2024-11-03', 'civil_time' => '01:30', 'timezone' => 'America/New_York']);
    }

    public function test_both_fold_occurrences_resolve_and_offset_selection_is_equivalent(): void
    {
        $input = ['civil_date' => '2024-11-03', 'civil_time' => '01:30', 'timezone' => 'America/New_York'];
        $early = $this->normalize($input + ['fold' => 0]);
        $late = $this->normalize($input + ['fold' => 1]);
        $offset = $this->normalize($input + ['utc_offset_seconds' => -18000]);
        $this->assertSame('2024-11-03T05:30:00Z', $early['utc']);
        $this->assertSame('2024-11-03T06:30:00Z', $late['utc']);
        $this->assertSame(1, $offset['fold']);
        $this->assertSame($late['input_signature'], $offset['input_signature']);
    }

    public function test_non_hour_dst_transition_and_skipped_civil_day_are_handled(): void
    {
        $early = $this->normalize(['civil_date' => '2024-04-07', 'civil_time' => '01:45', 'timezone' => 'Australia/Lord_Howe', 'fold' => 0]);
        $late = $this->normalize(['civil_date' => '2024-04-07', 'civil_time' => '01:45', 'timezone' => 'Australia/Lord_Howe', 'fold' => 1]);
        $this->assertSame(1800, strtotime($late['utc']) - strtotime($early['utc']));
        $this->expectExceptionMessage('civil_time_in_dst_gap');
        $this->normalize(['civil_date' => '2011-12-30', 'civil_time' => '10:00', 'timezone' => 'Pacific/Apia']);
    }

    public function test_signature_is_stable_under_key_order_and_changes_with_actual_context(): void
    {
        $profile = ['id' => 'synthetic', 'version' => '1', 'data' => ['hash' => 'abc', 'version' => '2']];
        $first = $this->normalize([], $profile);
        $reordered = ['data' => ['version' => '2', 'hash' => 'abc'], 'version' => '1', 'id' => 'synthetic'];
        $this->assertSame($first['input_signature'], $this->normalize([], $reordered)['input_signature']);
        $this->assertMatchesRegularExpression('/^[0-9a-f]{64}$/', $first['input_signature']);
        foreach ([['longitude' => 122], ['civil_time' => '00:31'], ['algorithm_sex' => 'male'], ['timezone' => 'Asia/Tokyo']] as $change) {
            $this->assertNotSame($first['input_signature'], $this->normalize($change, $profile)['input_signature']);
        }
        $this->assertNotSame($first['input_signature'], $this->normalize([], array_replace($profile, ['version' => '2']))['input_signature']);
    }

    public function test_invalid_input_is_rejected_without_php_date_or_numeric_coercion(): void
    {
        $invalid = [
            ['civil_date' => '2023-02-29'], ['civil_date' => '2000-1-1'],
            ['civil_time' => '24:00'], ['civil_time' => '12:00:30'],
            ['civil_time' => null], ['time_precision' => 'unknown'],
            ['timezone' => '+08:00'], ['timezone' => 'CST'],
            ['latitude' => INF], ['longitude' => NAN], ['latitude' => 91],
            ['longitude' => -181], ['latitude' => '31.2'], ['longitude' => null],
            ['fold' => 2], ['utc_offset_seconds' => 0], ['algorithm_sex' => true],
            ['civil_time' => null, 'time_precision' => 'unknown', 'fold' => 0],
        ];
        foreach ($invalid as $change) {
            try {
                $this->normalize($change);
                $this->fail('Expected invalid input: '.json_encode($change, JSON_PARTIAL_OUTPUT_ON_ERROR));
            } catch (InvalidArgumentException $exception) {
                $this->assertNotEmpty($exception->getMessage());
            }
        }
    }

    public function test_explicit_fold_and_offset_must_agree(): void
    {
        $this->expectExceptionMessage('fold_offset_conflict');
        $this->normalize(['civil_date' => '2024-11-03', 'civil_time' => '01:30', 'timezone' => 'America/New_York', 'fold' => 0, 'utc_offset_seconds' => -18000]);
    }

    public function test_missing_profile_identity_is_rejected(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->normalize([], ['id' => 'no-version']);
    }

    public function test_historical_dates_can_be_saved_without_claiming_algorithm_coverage(): void
    {
        $context = $this->normalize(['civil_date' => '1900-01-01', 'civil_time' => null, 'time_precision' => 'unknown']);
        $this->assertSame('1900-01-01', $context['civil_date']);
        $this->assertNull($context['utc']);
        $this->assertArrayNotHasKey('verified', $context);
        $this->assertArrayNotHasKey('gender', $context);
    }

    public function test_coordinate_limits_are_inclusive_and_do_not_reject_zero(): void
    {
        foreach ([[90, 180], [-90, -180], [0, 0]] as [$latitude, $longitude]) {
            $context = $this->normalize(['latitude' => $latitude, 'longitude' => $longitude]);
            $this->assertSame((float) $latitude, $context['latitude']);
            $this->assertSame((float) $longitude, $context['longitude']);
        }
    }

    public function test_engine_and_data_versions_participate_in_the_signature(): void
    {
        $profile = ['id' => 'synthetic', 'version' => '1', 'engine' => ['version' => '1'], 'data' => ['sha256' => 'abc']];
        $signature = $this->normalize([], $profile)['input_signature'];
        $profile['engine']['version'] = '2';
        $this->assertNotSame($signature, $this->normalize([], $profile)['input_signature']);
        $profile['engine']['version'] = '1';
        $profile['data']['sha256'] = 'def';
        $this->assertNotSame($signature, $this->normalize([], $profile)['input_signature']);
    }

    public function test_unsupported_profile_values_are_rejected_instead_of_omitted_from_signature(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->normalize([], ['id' => 'synthetic', 'version' => '1', 'rules' => new \stdClass]);
    }
}
