<?php

namespace App\Console\Commands;

use App\Services\MariaDbFixtureIdentity;
use Illuminate\Console\Command;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

final class MariaDbFixtureIdentityCommand extends Command
{
    protected $signature = 'qa:mariadb-identity {action : issue or revoke} {user} {--nonce=} {--ttl=30} {--credential=}';

    protected $description = 'Manage signed TEST_ONLY assertions on the local function MariaDB fixture';

    public function handle(MariaDbFixtureIdentity $issuer): int
    {
        $id = filter_var($this->argument('user'), FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        $ttl = filter_var($this->option('ttl'), FILTER_VALIDATE_INT);
        $credential = (string) $this->option('credential');
        if ($id === false) {
            return self::INVALID;
        }

        try {
            if ($this->argument('action') === 'issue' && $ttl !== false) {
                $this->line($issuer->issue($id, (string) ($this->option('nonce') ?? Str::uuid()), $ttl));

                return self::SUCCESS;
            }
            if ($this->argument('action') === 'revoke' && Str::isUuid($credential)) {
                $issuer->revoke($id, $credential);

                return self::SUCCESS;
            }
        } catch (HttpExceptionInterface|UniqueConstraintViolationException) {
            $this->error('Fixture instance, assertion or subject refused.');

            return self::FAILURE;
        }

        return self::INVALID;
    }
}
