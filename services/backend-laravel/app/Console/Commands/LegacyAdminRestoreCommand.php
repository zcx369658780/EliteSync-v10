<?php

namespace App\Console\Commands;

use App\Services\Accounts\LegacyAdminManifest;
use App\Services\Accounts\LegacyAdminRestore;
use DomainException;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use JsonException;
use Throwable;

final class LegacyAdminRestoreCommand extends Command
{
    protected $signature = 'admin:legacy-restore {manifest : Approved private JSON file}
        {--action=dry-run : dry-run, apply, issue or rollback}
        {--candidate= : Approved candidate reference for issue}
        {--out= : New private activation file for issue}';

    protected $description = 'Stage, issue and roll back explicitly approved legacy administrators';

    public function handle(LegacyAdminRestore $restore): int
    {
        try {
            $manifest = LegacyAdminManifest::read((string) $this->argument('manifest'));
            $action = $this->option('action');
            if ($action !== 'issue' && ($this->option('candidate') !== null || $this->option('out') !== null)) {
                throw new DomainException('Candidate and output options only apply to issue.');
            }
            if ($action === 'issue') {
                $restore->issue($manifest, (string) $this->option('candidate'), $this->privateDelivery((string) $this->option('out')));
                $this->info('Activation issued. Deliver the private file to the approved holder.');

                return self::SUCCESS;
            }

            $result = match ($action) {
                'dry-run' => $restore->preview($manifest),
                'apply' => $restore->apply($manifest),
                'rollback' => $restore->rollback($manifest),
                default => throw new DomainException('Unknown restoration action.'),
            };
            $this->table(['Candidate reference', 'Status'], collect($result)->map(fn ($state, $ref) => [$ref, $state])->values());
            if ($action === 'rollback') {
                $this->info('Remove these candidates from the private ADMIN_PHONES configuration.');
            }

            return self::SUCCESS;
        } catch (DomainException $exception) {
            $this->error($exception->getMessage());
        } catch (JsonException) {
            $this->error('Invalid manifest JSON.');
        } catch (Throwable) {
            // Database errors may carry private bindings. Surface a safe status only.
            $this->error('Restoration stopped. Check target identity, migration state, and conflicts.');
        }

        return self::FAILURE;
    }

    private function privateDelivery(string $path): \Closure
    {
        $directory = dirname($path);
        if (! str_starts_with($path, '/') || ! preg_match('/^[a-z0-9][a-z0-9._-]{0,63}\.json$/D', basename($path))
            || ! function_exists('posix_geteuid') || realpath($directory) !== $directory
            || fileowner($directory) !== posix_geteuid() || (fileperms($directory) & 0077) !== 0) {
            throw new DomainException('Issue requires a new JSON file in a private absolute Linux directory owned by the operator.');
        }

        return static function (#[\SensitiveParameter] string $secret, Carbon $expires) use ($path): void {
            $previous = umask(0077);
            try {
                $handle = @fopen($path, 'xb');
                if ($handle === false) {
                    throw new DomainException('Private delivery file could not be created exclusively.');
                }
                try {
                    $payload = json_encode(['activation_code' => $secret, 'expires_at' => $expires->toIso8601String()], JSON_THROW_ON_ERROR);
                    if (fwrite($handle, $payload) !== strlen($payload) || ! fflush($handle)) {
                        throw new DomainException('Private delivery file could not be written.');
                    }
                } finally {
                    fclose($handle);
                }
            } finally {
                umask($previous);
            }
        };
    }
}
