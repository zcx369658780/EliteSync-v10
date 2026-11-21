<?php

namespace App\Console\Commands;

use App\Services\SyntheticConnectionScope;
use Illuminate\Console\Command;

final class SyntheticConnectionScopeCommand extends Command
{
    protected $signature = 'qa:connection-pair {action : grant or revoke} {actor} {peer}';

    protected $description = 'Grant or revoke a pair of fictional local integration accounts';

    public function handle(SyntheticConnectionScope $scope): int
    {
        $actor = filter_var($this->argument('actor'), FILTER_VALIDATE_INT);
        $peer = filter_var($this->argument('peer'), FILTER_VALIDATE_INT);

        if ($actor === false || $peer === false || ! $scope->change($this->argument('action'), $actor, $peer)) {
            $this->error('Fixture instance or pair unavailable.');

            return self::FAILURE;
        }

        $this->info('Fixture pair updated.');

        return self::SUCCESS;
    }
}
