<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserDynamicChart;
use App\Models\UserNatalProfile;
use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;
use RuntimeException;
use Symfony\Component\Process\Process;
use Throwable;

class DynamicChartService
{
    private const INPUT_KEYS = ['civil_date', 'civil_time', 'time_precision', 'timezone',
        'latitude', 'longitude', 'fold', 'utc_offset_seconds', 'algorithm_sex', 'time_source', 'location_label'];

    public function prepare(User $user, array $body): array
    {
        $this->keys($body, ['chart_type', 'first', 'second', 'event', 'settings', 'expected_revision', 'selected_event_index']);
        $selected = $body['selected_event_index'] ?? null;
        if ($selected !== null && (! is_int($selected) || $selected < 0)) {
            throw new InvalidArgumentException('invalid_selected_event_index');
        }
        $type = $body['chart_type'] ?? null;
        if (! in_array($type, ['synastry', 'comparison', 'transit', 'solar_return', 'lunar_return'], true)
            || ! is_int($body['expected_revision'] ?? null) || $body['expected_revision'] < 0
            || ! is_array($body['settings'] ?? null)) {
            throw new InvalidArgumentException('invalid_dynamic_request');
        }
        if (array_key_exists('target_year', $body['settings']) || ($body['settings']['true_solar_time'] ?? false) !== false) {
            throw new InvalidArgumentException('unsupported_dynamic_setting');
        }
        $profiles = app(NatalCalculationProfile::class);
        $settings = array_intersect_key($profiles->settings($body['settings']), array_flip([
            'zodiac_mode', 'house_system', 'aspect_mode', 'orb_preset', 'point_set',
        ]));
        $profile = $profiles->make($settings);
        foreach (['app/Services/DynamicChartService.php', 'tools/natal/dynamic.py',
            'resources/natal/dynamic-profile-registry.json', 'config/dynamic_charts.php'] as $path) {
            $profile['source_hashes'][$path] = is_file(base_path($path)) ? hash_file('sha256', base_path($path)) : null;
        }
        $first = $this->source($user, $body['first'] ?? null, $profile);
        $pair = in_array($type, ['synastry', 'comparison'], true);
        $second = $pair ? $this->source($user, $body['second'] ?? null, $profile) : null;
        if ((! $pair && ($body['second'] ?? null) !== null) || ($pair && ($body['event'] ?? null) !== null)) {
            throw new InvalidArgumentException('unexpected_dynamic_input');
        }
        $event = null;
        if (! $pair) {
            if (! is_array($body['event'] ?? null)) {
                throw new InvalidArgumentException('event_required');
            }
            $input = $body['event'];
            if ($type === 'solar_return') {
                $this->keys($input, ['year', 'timezone', 'latitude', 'longitude', 'location_label']);
                if (! is_int($input['year'] ?? null) || $input['year'] < 1900 || $input['year'] > 2100) {
                    throw new InvalidArgumentException('invalid_return_year');
                }
                $year = $input['year'];
                // Gregorian civil-year boundaries in the explicitly selected IANA zone.
                $event = $this->context(['civil_date' => sprintf('%04d-01-01', $year), 'civil_time' => '00:00:00',
                    'time_precision' => 'second', 'timezone' => $input['timezone'] ?? null,
                    'latitude' => $input['latitude'] ?? null, 'longitude' => $input['longitude'] ?? null,
                    'location_label' => $input['location_label'] ?? null], $profile);
                $zone = new DateTimeZone($event['timezone']);
                $event['year'] = $year;
                $event['window_start'] = (new DateTimeImmutable(sprintf('%04d-01-01 00:00:00', $year), $zone))
                    ->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z');
                $event['window_end'] = (new DateTimeImmutable(sprintf('%04d-01-01 00:00:00', $year + 1), $zone))
                    ->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z');
            } else {
                $event = $this->context($input, $profile);
            }
        }
        $payload = ['chart_type' => $type, 'first' => $first, 'second' => $second,
            'event' => $event, 'profile' => $settings];
        $request = array_intersect_key($body, array_flip(['chart_type', 'first', 'second', 'event']));
        $signature = hash('sha256', json_encode($this->canonical(['payload' => $payload,
            'profile' => $profile]), JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
        $firstSignature = hash('sha256', json_encode($this->canonical(['first' => $first,
            'profile' => $profile]), JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));

        return ['payload' => $payload, 'request' => $request, 'settings' => $settings,
            'input_signature' => $signature, 'first_context_signature' => $firstSignature];
    }

    private function source(User $user, mixed $source, array $profile): array
    {
        if (! is_array($source)) {
            throw new InvalidArgumentException('dynamic_source_required');
        }
        if (($source['source'] ?? null) === 'manual') {
            $this->keys($source, ['source', 'input']);
            if (! is_array($source['input'] ?? null)) {
                throw new InvalidArgumentException('manual_input_required');
            }
            return [...$this->context($source['input'], $profile), 'source' => 'manual'];
        }
        $this->keys($source, ['source', 'revision']);
        if (($source['source'] ?? null) !== 'own_natal' || ! is_int($source['revision'] ?? null) || $source['revision'] < 1) {
            throw new InvalidArgumentException('invalid_private_natal_source');
        }
        $row = UserNatalProfile::where('user_id', $user->id)->first();
        if (! $row || $row->input_revision !== $source['revision']
            || $row->result_revision !== $row->input_revision || $row->status !== 'COMPUTED_UNVERIFIED') {
            throw new InvalidArgumentException('own_natal_revision_unavailable');
        }
        $view = app(NatalProfileView::class)->profile($row);
        if ($view['status'] !== 'COMPUTED_UNVERIFIED' || $view['results'] === null) {
            throw new InvalidArgumentException('own_natal_revision_stale');
        }
        return [...$this->context($row->input, $profile), 'source' => 'own_natal',
            'natal_revision' => $row->input_revision, 'natal_signature' => $row->input_signature];
    }

    private function context(array $input, array $profile): array
    {
        $this->keys($input, self::INPUT_KEYS);
        $context = app(NatalInputContext::class)->normalize($input, $profile);
        $year = (int) substr($context['civil_date'], 0, 4);
        if ($year < 1900 || $year > 2100 || $context['normalized_time'] === null
            || $context['latitude'] === null || $context['longitude'] === null) {
            throw new InvalidArgumentException('dynamic_known_time_and_coordinates_required_in_domain');
        }
        if (strlen((string) $context['location_label']) > 255 || strlen($context['time_source']) > 64) {
            throw new InvalidArgumentException('dynamic_provenance_too_long');
        }
        return $context;
    }

    public function compute(array $prepared): array
    {
        if (! app()->environment(['local', 'testing']) || ! config('dynamic_charts.enabled', false)) {
            throw new RuntimeException('dynamic_runtime_not_admitted');
        }
        if (! app()->environment('testing')
            && (config('database.connections.'.config('database.default').'.database') !== config('dynamic_charts.database', 'elitesync_v1011_dev')
                || config('database.connections.'.config('database.default').'.host') !== '127.0.0.1')) {
            throw new RuntimeException('dynamic_database_not_admitted');
        }
        if (($prepared['payload']['first']['calculation_profile']['runtime_identity']['status'] ?? null) !== 'AVAILABLE') {
            throw new RuntimeException('dynamic_runtime_unavailable');
        }
        $python = (string) config('natal.python');
        if ($python === '') {
            throw new RuntimeException('dynamic_runtime_unavailable');
        }
        $process = new Process([$python, base_path('tools/natal/dynamic.py'),
            (string) config('natal.kernel'), (string) config('natal.kernel_sha256')], base_path(), null,
            json_encode($prepared['payload'], JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE), 300);
        $bytes = 0;
        $process->run(function (string $type, string $buffer) use (&$bytes): void {
            $bytes += strlen($buffer);
            if ($bytes > 2097152) {
                throw new RuntimeException('dynamic_output_limit');
            }
        });
        if (! $process->isSuccessful()) {
            throw new RuntimeException('dynamic_calculation_failed');
        }
        $result = json_decode($process->getOutput(), true, 128, JSON_THROW_ON_ERROR);
        if (! is_array($result) || ! is_string($result['status'] ?? null)
            || in_array($result['status'], ['ERROR', 'FAILED'], true)) {
            throw new RuntimeException('dynamic_result_invalid');
        }
        $charts = [$result['first'] ?? null, $result['second'] ?? null];
        foreach ($result['events'] ?? [] as $event) {
            $charts[] = $event['chart'] ?? null;
        }
        foreach (array_filter($charts, fn ($chart) => $chart !== null) as $chart) {
            if (! is_array($chart) || ! hash_equals((string) config('natal.kernel_sha256'),
                (string) ($chart['data_sha256'] ?? ''))) {
                throw new RuntimeException('dynamic_result_data_identity_mismatch');
            }
            if ($prepared['settings']['point_set'] === 'full') {
                app(NatalCalculationService::class)->validateChironIdentity($chart,
                    $prepared['payload']['first']['calculation_profile']);
            }
        }
        return $result;
    }

    public function view(User $user, UserDynamicChart $row): array
    {
        $stale = true;
        try {
            $current = $this->prepare($user, [...$row->request, 'settings' => $row->settings,
                'expected_revision' => $row->input_revision]);
            $stale = ! hash_equals($row->input_signature, $current['input_signature']);
        } catch (Throwable) {
            // Missing/changed source or runtime fails closed; never expose old private results.
        }
        return ['id' => $row->id, 'chart_type' => $row->chart_type, 'request' => $row->request,
            'settings' => $row->settings, 'input_revision' => $row->input_revision,
            'result_revision' => $stale ? null : $row->result_revision,
            'input_signature' => $row->input_signature,
            'selected_event_index' => $stale ? null : $row->selected_event_index,
            'status' => $stale ? 'STALE_RECALCULATION_REQUIRED' : $row->status,
            'results' => $stale ? null : $row->results];
    }

    public function selectEvent(array $results, mixed $index): ?int
    {
        if ($index === null) {
            return null;
        }
        if (! is_int($index) || $index < 0 || ! is_array($results['events'] ?? null)
            || ! array_key_exists($index, $results['events'])) {
            throw new InvalidArgumentException('selected_event_not_available');
        }
        return $index;
    }

    private function keys(array $value, array $allowed): void
    {
        if (array_diff(array_keys($value), $allowed)) {
            throw new InvalidArgumentException('unsupported_dynamic_field');
        }
    }

    private function canonical(mixed $value): mixed
    {
        if (is_array($value)) {
            if (! array_is_list($value)) {
                ksort($value, SORT_STRING);
            }
            return array_map(fn ($item) => $this->canonical($item), $value);
        }
        return $value;
    }
}
