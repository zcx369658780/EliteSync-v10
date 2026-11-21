<?php

namespace App\Services\Accounts;

use DomainException;
use Illuminate\Support\Facades\DB;

final class LegacyAdminTarget
{
    public function assert(string $identity, ?string $approval = null): void
    {
        $db = DB::connection();
        $origin = config('legacy_admin.url');
        $validConfig = $identity !== '' && $identity === config('legacy_admin.target')
            && is_string($origin) && str_starts_with($origin, 'https://')
            && $origin === config('app.url') && ! config('app.debug') && config('session.secure');

        if (! $validConfig || ($approval !== null && $approval !== config('legacy_admin.approval'))) {
            throw new DomainException('Wrong recovery target or missing target approval.');
        }
        if (app()->runningUnitTests() && $db->getDriverName() === 'sqlite' && $db->getDatabaseName() === ':memory:') {
            return;
        }

        $schema = config('legacy_admin.database');
        $serverId = config('legacy_admin.server_id');
        if (! app()->environment('staging') || $db->getDriverName() !== 'mariadb'
            || ! is_string($schema) || $schema === '' || $schema !== $db->getDatabaseName()
            || $db->getConfig('host') !== config('legacy_admin.host') || $db->getConfig('url')
            || config('database.connections.'.$db->getName().'.url') || $db->getConfig('unix_socket') || $serverId < 1
            || config('session.driver') !== 'database'
            || ! in_array(config('session.connection'), [null, $db->getName()], true)
            || config('session.table') !== 'sessions'
            || ! str_starts_with($schema, 'elitesync_v2_')) {
            throw new DomainException('Recovery requires a dedicated V2 staging database and database sessions.');
        }

        $actual = $db->selectOne('select database() as schema_name, @@server_id as server_id, version() as version');
        if ($schema !== $actual->schema_name || $serverId !== (int) $actual->server_id
            || ! str_starts_with($actual->version, '10.11.') || ! str_contains($actual->version, 'MariaDB')) {
            throw new DomainException('Actual staging database identity does not match.');
        }

        $synthetic = $schema === 'elitesync_v2_function' && $serverId === 2621121
            && $db->getConfig('host') === 'r0-db'
            && preg_match('#^https://127\.0\.0\.1(?::[0-9]+)?/?$#D', $origin);
        if (($identity === 'local-v2-function' && ! $synthetic)
            || ($identity !== 'local-v2-function' && ($schema === 'elitesync_v2_function' || $schema === 'elitesync_v2_r0'
                || $serverId === 2621121 || $serverId === 2621111 || ! str_starts_with($schema, 'elitesync_v2_beta_')))) {
            throw new DomainException('Recovery target is outside its approved database class.');
        }
    }
};
