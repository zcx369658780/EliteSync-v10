<?php

namespace App\Services;

use RuntimeException;
use Symfony\Component\Process\Process;

class NatalCalculationService
{
    public function compute(array $context, array $settings): array
    {
        $year = (int) substr($context['civil_date'], 0, 4);
        if ($year < 1900 || $year > 2100) {
            // Preserve the historical input contract without fabricating an
            // independently supported chart outside the admitted reference domain.
            $unverified = ['status' => 'UNVERIFIED', 'oracle_status' => 'UNVERIFIED',
                'reason' => 'outside_current_independent_reference_domain'];

            return ['bazi' => [...$unverified, 'pillars' => null, 'da_yun' => null],
                'ziwei' => [...$unverified, 'palaces' => null],
                'western' => [...$unverified, 'calculation_status' => 'UNVERIFIED',
                    'planets' => null, 'houses' => null, 'aspects' => null]];
        }
        $hasTime = ($context['normalized_time'] ?? null) !== null;
        if ($hasTime && ($context['calculation_profile']['runtime_identity']['status'] ?? null) !== 'AVAILABLE') {
            // Identity observation is separate from accuracy approval. Refuse a
            // known-time calculation if its actual dependency/data identity is unavailable.
            throw new RuntimeException('natal_runtime_identity_unavailable');
        }
        $western = $hasTime ? $this->run([
            (string) config('natal.python'), base_path('tools/natal/western.py'),
            (string) config('natal.kernel'), (string) config('natal.kernel_sha256'),
        ], ['context' => $context, 'profile' => $settings]) : [
            'calculation_status' => 'UNKNOWN', 'reason' => 'birth_time_unknown', 'oracle_status' => 'UNVERIFIED',
            'requested_profile' => $settings, 'planets' => [], 'houses' => [], 'aspects' => [],
        ];
        if ($hasTime && ($settings['point_set'] ?? null) === 'full') {
            $this->validateChironIdentity($western, $context['calculation_profile']);
        }
        $solar = null;
        if ($settings['true_solar_time'] && $hasTime) {
            $solar = $western['solar_context'] ?? null;
            if (($solar['status'] ?? null) !== 'CALCULATED') {
                throw new RuntimeException('solar_context_unavailable');
            }
        }
        if ($hasTime && ! is_array($western['time_context'] ?? null)) {
            throw new RuntimeException('natal_time_context_unavailable');
        }
        $bazi = (new NatalBaziCalculator(new NatalBaziTimeScale((string) config('natal.python'))))
            ->compute($context, $solar, $western['time_context'] ?? null);
        $ziwei = $this->run([(string) config('natal.node'), base_path('tools/natal/ziwei.mjs')], [
            'source_civil_date' => $context['civil_date'],
            'effective_civil_date' => $solar['effective_solar_date'] ?? $context['civil_date'],
            'effective_time' => $solar['effective_solar_time'] ?? $context['normalized_time'],
            'algorithm_sex' => $context['algorithm_sex'],
            'target_year' => $settings['target_year'],
            'requested_profile' => ['id' => 'iztro-2.5.8-modern-default-v1'],
        ]);

        return ['bazi' => $bazi, 'ziwei' => $ziwei, 'western' => $western];
    }

    public function validateChironIdentity(array $western, array $profile): void
    {
        $points = array_values(array_filter($western['planets'] ?? [],
            fn ($point) => is_array($point) && ($point['name'] ?? null) === 'chiron'));
        $artifact = $profile['source_hashes']['resources/natal/data/chiron-lowell-hermite8d-v1.npz'] ?? null;
        $manifest = $profile['source_hashes']['resources/natal/chiron-data-manifest.json'] ?? null;
        // Bind the bytes actually used by the subprocess to the request's
        // fingerprint. A concurrent data change must fail, never persist a
        // new orbit under the old input signature or overwrite newer results.
        if (count($points) !== 1 || ! is_string($artifact) || ! is_string($manifest)
            || ! hash_equals($artifact, (string) ($points[0]['data_sha256'] ?? ''))
            || ! hash_equals($manifest, (string) ($points[0]['data_manifest_sha256'] ?? ''))
            || ($western['effective_profile']['point_set'] ?? null) !== 'full'
            || ($western['unavailable_points'] ?? null) !== []) {
            throw new RuntimeException('natal_chiron_result_identity_mismatch');
        }
    }

    private function run(array $command, array $payload): array
    {
        if ($command[0] === '') {
            throw new RuntimeException('local_natal_executable_not_configured');
        }
        // An argument vector and stdin prevent shell interpolation and birth data in argv.
        $process = new Process($command, base_path(), null,
            json_encode($payload, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE),
            (float) config('natal.timeout_seconds', 45));
        $process->run();
        if (! $process->isSuccessful() || strlen($process->getOutput()) > 2097152) {
            throw new RuntimeException('local_natal_process_failed');
        }
        $result = json_decode($process->getOutput(), true, 128, JSON_THROW_ON_ERROR);
        if (! is_array($result) || in_array($result['status'] ?? $result['calculation_status'] ?? 'ERROR', ['ERROR'], true)) {
            throw new RuntimeException('local_natal_result_invalid');
        }

        return $result;
    }
}
