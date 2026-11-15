<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Console\Scheduling\Schedule;

/** Local launcher for the single B2 scheduler event. */
final class WorkUserAutomation extends Command
{
    protected $signature = 'app:automation:work {--once}';
    protected $description = 'Run the named user-automation scheduler event';

    public function handle(Schedule $schedule): int
    {
        do {
            foreach ($schedule->events() as $event) {
                if ($event->description === 'user-automation' && $event->isDue($this->laravel)) {
                    $event->run($this->laravel);
                    if ($event->exitCode !== 0) {
                        $this->error(now()->utc()->toISOString().' user-automation scheduler event failed');
                        if ($this->option('once')) { return self::FAILURE; }
                        continue;
                    }
                    $this->line(now()->utc()->toISOString().' user-automation scheduler event finished');
                }
            }
            if ($this->option('once')) { return self::SUCCESS; }
            sleep(max(1, 60 - (int) now()->format('s')));
        } while (true);
    }
}
