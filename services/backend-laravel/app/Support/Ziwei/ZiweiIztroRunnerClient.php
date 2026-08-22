<?php

namespace App\Support\Ziwei;

class ZiweiIztroRunnerClient
{
    public function __construct(
        private readonly string $runnerPath,
        private readonly string $nodeBinary = 'node',
        private readonly int $timeoutSeconds = 5,
        private readonly bool $enabled = false,
    ) {
    }

    /**
     * @param array<string,mixed> $input
     * @return array<string,mixed>
     */
    public function run(array $input): array
    {
        if (! $this->enabled) {
            return $this->fallback('shadow_runner_disabled');
        }

        if (! is_file($this->runnerPath)) {
            return $this->fallback('shadow_runner_missing');
        }

        $payload = json_encode($input, JSON_UNESCAPED_UNICODE);
        if ($payload === false) {
            return $this->fallback('shadow_runner_input_json_encode_failed');
        }

        $descriptorSpec = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];

        $process = @proc_open([$this->nodeBinary, $this->runnerPath], $descriptorSpec, $pipes);

        if (! is_resource($process)) {
            return $this->fallback('node_binary_missing_or_process_open_failed');
        }

        fwrite($pipes[0], $payload);
        fclose($pipes[0]);

        $startedAt = microtime(true);
        $stdout = '';
        $stderr = '';
        $timedOut = false;

        foreach ([1, 2] as $pipe) {
            stream_set_blocking($pipes[$pipe], false);
        }

        while (true) {
            $status = proc_get_status($process);

            $stdout .= stream_get_contents($pipes[1]);
            $stderr .= stream_get_contents($pipes[2]);

            if (! ($status['running'] ?? false)) {
                break;
            }

            if ((microtime(true) - $startedAt) > $this->timeoutSeconds) {
                $timedOut = true;
                proc_terminate($process);
                break;
            }

            usleep(10000);
        }

        $stdout .= stream_get_contents($pipes[1]);
        $stderr .= stream_get_contents($pipes[2]);

        fclose($pipes[1]);
        fclose($pipes[2]);

        $exitCode = proc_close($process);

        if ($timedOut) {
            return $this->fallback('shadow_runner_timeout');
        }

        $decoded = json_decode(trim($stdout), true);

        if (! is_array($decoded)) {
            return $this->fallback('shadow_runner_malformed_json', [
                'exit_code' => $exitCode,
                'stderr_present' => trim($stderr) !== '',
            ]);
        }

        if ($exitCode !== 0 || ($decoded['success'] ?? null) !== true) {
            return array_merge($this->fallback('shadow_runner_nonzero_exit', [
                'exit_code' => $exitCode,
            ]), [
                'runner_payload' => $decoded,
            ]);
        }

        return $decoded;
    }

    /**
     * @param array<string,mixed> $extra
     * @return array<string,mixed>
     */
    public function fallback(string $reason, array $extra = []): array
    {
        return array_merge([
            'success' => false,
            'shadow_status' => 'candidate_unavailable',
            'failure_reason' => $reason,
            'algorithm_version' => ZiweiIztroAdapterContract::ALGORITHM_VERSION,
            'warnings' => ZiweiIztroAdapterContract::unsupportedPolicyWarnings(),
            'display_only' => true,
            'external_oracle_status' => 'not_validated',
            'scoring_status' => 'excluded_from_core_matching',
            'production_runtime_enabled' => false,
            'user_facing_enabled' => false,
            'dependency_adopted' => 'shadow_tool_only',
        ], $extra);
    }
}
