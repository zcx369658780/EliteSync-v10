<?php

namespace App\Services;

use RuntimeException;
use Symfony\Component\Process\Process;
use Throwable;

final class NatalRuntimeIdentity
{
    public function make(): array
    {
        $python = (string) config('natal.python', '');
        $kernel = (string) config('natal.kernel', '');
        $expected = (string) config('natal.kernel_sha256', '');
        // Paths affect configuration identity but are never returned in plaintext.
        $base = ['schema' => 'natal-runtime-identity-v1',
            'configuration_sha256' => hash('sha256', json_encode([$python, $kernel, $expected], JSON_THROW_ON_ERROR))];
        if ($python === '' || $kernel === '' || ! preg_match('/^[a-f0-9]{64}$/', $expected)) {
            return [...$base, 'status' => 'IDENTITY_UNAVAILABLE', 'reason' => 'runtime_not_configured'];
        }
        try {
            $process = new Process([$python, base_path('tools/natal/runtime_identity.py'), $kernel, $expected],
                base_path(), null, null, (float) config('natal.identity_timeout_seconds', 10));
            $bytes = 0;
            $process->run(function (string $type, string $buffer) use (&$bytes): void {
                $bytes += strlen($buffer);
                if ($bytes > 131072) {
                    throw new RuntimeException('runtime_identity_output_limit');
                }
            });
            if (! $process->isSuccessful()) {
                throw new RuntimeException('runtime_identity_process_failed');
            }
            $result = json_decode($process->getOutput(), true, 32, JSON_THROW_ON_ERROR);
            if (! is_array($result) || ($result['schema'] ?? null) !== $base['schema']
                || ! in_array($result['status'] ?? '', ['AVAILABLE', 'IDENTITY_UNAVAILABLE'], true)) {
                throw new RuntimeException('runtime_identity_invalid');
            }
            return [...$result, ...$base];
        } catch (Throwable) {
            return [...$base, 'status' => 'IDENTITY_UNAVAILABLE', 'reason' => 'offline_runtime_probe_failed'];
        }
    }
}
