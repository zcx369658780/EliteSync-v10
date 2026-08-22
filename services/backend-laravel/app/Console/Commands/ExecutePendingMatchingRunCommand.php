<?php

namespace App\Console\Commands;

use App\Models\QuestionnaireQuestion;
use App\Services\MatchingEngineService;
use App\Services\MatchingRunService;
use App\Services\PersonalityProfileService;
use App\Services\ProfileReadinessService;
use Illuminate\Console\Command;

class ExecutePendingMatchingRunCommand extends Command
{
    protected $signature = 'app:matching:execute-pending {--once : Claim at most one pending run}';
    protected $description = 'Execute one durable matching run when the protected foundation consumer is enabled.';

    public function handle(MatchingRunService $runs, PersonalityProfileService $profiles, MatchingEngineService $engine, ProfileReadinessService $readiness): int
    {
        if (!(bool) config('matching.foundation.execution_enabled', false)) {
            $this->error('Matching foundation execution is disabled.');
            return self::FAILURE;
        }
        if (!$this->option('once')) {
            $this->error('The protected consumer requires --once.');
            return self::INVALID;
        }

        $owner = gethostname().':'.getmypid();
        $run = $runs->claimNext($owner, (int) config('matching.foundation.lease_seconds', 60));
        if (!$run) {
            $this->line('No pending matching run.');
            return self::SUCCESS;
        }
        $fence = (int) $run->fencing_token;

        try {
            if (QuestionnaireQuestion::query()->where('enabled', true)->count() === 0) throw new \RuntimeException('no_enabled_questions');
            $users = $readiness->eligibleUsersQuery()->orderBy('id')->get(['id','created_at','updated_at']);
            $runs->freezeCandidates($run, $users, $owner, $fence);
            $profileMap = []; $userMeta = [];
            foreach ($users as $index => $user) {
                if ($index % 10 === 0 && !$runs->heartbeat($run, $owner, $fence, (int) config('matching.foundation.lease_seconds', 60))) throw new \RuntimeException('lease_lost');
                $profileMap[(int) $user->id] = $profiles->buildForUser((int) $user->id);
                $userMeta[(int) $user->id] = ['created_at' => $user->created_at, 'updated_at' => $user->updated_at];
            }
            if (!$runs->heartbeat($run, $owner, $fence, (int) config('matching.foundation.lease_seconds', 60))) throw new \RuntimeException('lease_lost');
            $plannedPairs = $engine->buildPairs($profileMap, $userMeta);
            $runs->finalize($run, $owner, $fence, $users->pluck('id')->map(fn ($id) => (int) $id)->all(), $plannedPairs);
            $this->line('Matching run completed: '.$run->run_key);
            return self::SUCCESS;
        } catch (\Throwable $error) {
            try { $runs->fail($run, $owner, $fence, 'execution_failed', 'Protected matching execution failed.'); } catch (\Throwable) {
                try { $runs->expireLease((int) $run->id); } catch (\Throwable) {}
            }
            $this->error('Matching run failed: '.$run->run_key);
            return self::FAILURE;
        }
    }
}
