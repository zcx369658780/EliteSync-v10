<?php

namespace App\Console\Commands;

use App\Services\C2LocalMatchScenarioService;
use Illuminate\Console\Command;

class C2LocalMatchScenarioCommand extends Command
{
    protected $signature = 'app:c2:match-scenario {scenario : no_round|preparing|waiting|revealed|no_candidate|failed|closed}';
    protected $description = 'Build one guarded synthetic C2 match scenario in an ephemeral local SQLite database.';

    public function handle(C2LocalMatchScenarioService $service): int
    {
        try {
            $summary = $service->build((string) $this->argument('scenario'));
            $this->line(json_encode($summary, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
            return self::SUCCESS;
        } catch (\Throwable $error) {
            $this->error('C2 scenario refused: '.$error->getMessage());
            return self::FAILURE;
        }
    }
}
