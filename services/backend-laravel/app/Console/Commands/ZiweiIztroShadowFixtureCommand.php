<?php

namespace App\Console\Commands;

use App\Support\Ziwei\ZiweiIztroRunnerClient;
use App\Support\Ziwei\ZiweiIztroShadowAdapter;
use Illuminate\Console\Command;

class ZiweiIztroShadowFixtureCommand extends Command
{
    protected $signature = 'ziwei:iztro-shadow-fixture
        {--sample=A : Fixture sample A, B, or C}
        {--runner= : Explicit runner.mjs path}
        {--node=node : Node binary path}
        {--timeout=5 : Runner timeout seconds}';

    protected $description = 'Dev/admin diagnostic only: run iztro shadow fixture comparison without user-facing output or DB writes.';

    public function handle(): int
    {
        $sampleId = strtoupper((string) $this->option('sample'));
        $runnerPath = trim((string) ($this->option('runner') ?: base_path('tools/ziwei/iztro-runner/runner.mjs')));
        $timeout = max(1, (int) $this->option('timeout'));

        $client = new ZiweiIztroRunnerClient(
            runnerPath: $runnerPath,
            nodeBinary: (string) $this->option('node'),
            timeoutSeconds: $timeout,
            enabled: true,
        );
        $adapter = new ZiweiIztroShadowAdapter($client, enabled: true);

        $report = $adapter->buildFixtureShadowReport($sampleId, [
            'status' => 'current_user_facing_output_placeholder_not_modified_by_shadow_command',
        ]);

        $this->line(json_encode($report, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));

        return ($report['shadow_status'] ?? '') === 'candidate_generated'
            ? self::SUCCESS
            : self::FAILURE;
    }
}
