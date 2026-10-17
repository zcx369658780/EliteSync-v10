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
        $solar = null;
        if ($settings['true_solar_time'] && $hasTime) {
            $solar = $western['solar_context'] ?? null;
            if (($solar['status'] ?? null) !== 'CALCULATED') {
                throw new RuntimeException('solar_context_unavailable');
            }
        }
        $bazi = app(NatalBaziCalculator::class)->compute($context, $solar);
        $ziwei = $this->run([(string) config('natal.node'), base_path('tools/natal/ziwei.mjs')], [
            'effective_civil_date' => $solar['effective_solar_date'] ?? $context['civil_date'],
            'effective_time' => $solar['effective_solar_time'] ?? $context['normalized_time'],
            'algorithm_sex' => $context['algorithm_sex'],
            'target_year' => $settings['target_year'],
            'requested_profile' => ['id' => 'iztro-2.5.8-modern-default-v1'],
        ]);
        return ['bazi' => $bazi, 'ziwei' => $ziwei, 'western' => $western];
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
