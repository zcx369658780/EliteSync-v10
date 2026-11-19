<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

/** Legacy writer retired: all matching must use the audited round lifecycle. */
class DevRunMatchingCommand extends Command
{
    protected $signature = 'app:dev:run-matching
        {--include-synthetic= : Retired option}
        {--release-drop : Retired option}
        {--reset-week : Retired option}';

    protected $description = 'Retired matching writer; use the guarded round lifecycle.';

    public function handle(): int
    {
        $this->error('LEGACY_MATCHING_DISABLED: use the guarded matching round lifecycle.');

        return self::FAILURE;
    }
}
