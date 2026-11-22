<?php

namespace App\Console\Commands;

use App\Services\StagingSyntheticConnectionScope;
use Illuminate\Console\Command;
use Illuminate\Database\QueryException;
use JsonException;

final class StagingSyntheticConnectionScopeCommand extends Command
{
    protected $signature = 'qa:staging-connection-pair {action : grant or revoke} {manifest : Private JSON approval file}';

    protected $description = 'Change one synthetic pair grant in the isolated local Staging rehearsal';

    public function handle(StagingSyntheticConnectionScope $scope): int
    {
        $path = (string) $this->argument('manifest');
        $contents = is_file($path) && is_readable($path) ? file_get_contents($path, false, null, 0, 4097) : false;
        try {
            $manifest = is_string($contents) && strlen($contents) <= 4096
                ? json_decode($contents, true, 8, JSON_THROW_ON_ERROR) : null;
            if (is_array($manifest) && $scope->change((string) $this->argument('action'), $manifest)) {
                $this->info('Synthetic staging pair grant updated.');

                return self::SUCCESS;
            }
        } catch (JsonException|QueryException) {
            // The command never echoes manifest content or database values.
        }
        $this->error('Synthetic staging target or approval unavailable.');

        return self::FAILURE;
    }
}
