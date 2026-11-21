<?php

namespace App\Services\Accounts;

use DomainException;
use Illuminate\Database\MariaDbConnection;
use Illuminate\Support\Facades\DB;
use PDO;

final class LegacyAdminTarget
{
    public function assert(string $identity, ?string $approval = null): void
    {
        $origin = config('legacy_admin.url');
        if ($identity === '' || $identity !== config('legacy_admin.target')
            || ! is_string($origin) || ! str_starts_with($origin, 'https://')
            || $origin !== config('app.url') || config('app.debug') || ! config('session.secure')
            || ($approval !== null && $approval !== config('legacy_admin.approval'))) {
            throw new DomainException('Wrong recovery target or missing target approval.');
        }

        if (app()->runningUnitTests() && config('database.default') === 'sqlite'
            && DB::connection()->getDatabaseName() === ':memory:') {
            return;
        }

        $expected = self::binding();
        if (! app()->environment('staging') || $expected['connection'] !== 'mariadb'
            || config('database.default') !== 'mariadb' || DB::getDefaultConnection() !== 'mariadb'
            || config('session.driver') !== 'database' || config('session.connection') !== 'mariadb'
            || config('session.table') !== 'sessions'
            || ! is_string($expected['database']) || ! str_starts_with($expected['database'], 'elitesync_v2_')
            || ! is_string($expected['host']) || $expected['host'] === ''
            || ! is_string($expected['username']) || ! preg_match('/^[a-z][a-z0-9_]{1,63}$/D', $expected['username'])
            || ! is_string($expected['current_user']) || ! str_starts_with($expected['current_user'], $expected['username'].'@')
            || $expected['current_user'] === $expected['username'].'@'
            || $expected['port'] < 1 || $expected['port'] > 65535 || $expected['server_id'] < 1
            || ! is_string($expected['version']) || ! preg_match('/^10\.11\.\d+-MariaDB(?:[-+].+)?$/D', $expected['version'])) {
            throw new DomainException('Recovery target and database session must use the approved dedicated staging connection.');
        }

        $synthetic = $expected['database'] === 'elitesync_v2_function' && $expected['server_id'] === 2621121
            && $expected['host'] === 'r0-db' && $expected['username'] === 'elitesync_function_app'
            && $expected['port'] === 3306 && preg_match('#^https://127\.0\.0\.1(?::[0-9]+)?/?$#D', $origin);
        if (($identity === 'local-v2-function' && ! $synthetic)
            || ($identity !== 'local-v2-function' && (! str_starts_with($expected['database'], 'elitesync_v2_beta_')
                || ! str_starts_with($expected['username'], 'elitesync_v2_beta_')
                || in_array($expected['server_id'], [1, 2621111, 2621121], true)))) {
            throw new DomainException('Recovery target is outside its approved database class.');
        }

        $declared = config('database.connections.mariadb', []);
        $this->assertConnectionConfig($declared, $expected);
        $db = DB::connection('mariadb');
        if (! $db instanceof MariaDbConnection || $db->getName() !== 'mariadb'
            || $db->getNameWithReadWriteType() !== 'mariadb' || $db->getDriverName() !== 'mariadb'
            || $db->getDatabaseName() !== $expected['database']) {
            throw new DomainException('Recovery database was rebound.');
        }
        $this->assertConnectionConfig($db->getConfig(), $expected);
        if ($db->getPdo()->getAttribute(PDO::ATTR_DRIVER_NAME) !== 'mysql' || $db->getReadPdo() !== $db->getPdo()) {
            throw new DomainException('Recovery database cannot use an alternate or split PDO.');
        }

        $actual = $db->selectOne('SELECT DATABASE() AS schema_name, @@server_id AS server_id, @@port AS port, '
            .'VERSION() AS version, CURRENT_USER() AS grant_account, USER() AS login_account', [], false);
        if (! $actual || $actual->schema_name !== $expected['database'] || (int) $actual->server_id !== $expected['server_id']
            || (int) $actual->port !== $expected['port'] || $actual->version !== $expected['version']
            || $actual->grant_account !== $expected['current_user']
            || explode('@', (string) $actual->login_account, 2)[0] !== $expected['username']) {
            throw new DomainException('Actual staging database identity does not match.');
        }
    }

    private function assertConnectionConfig(array $config, array $expected): void
    {
        if (($config['driver'] ?? null) !== 'mariadb' || ! empty($config['url'])
            || ! empty($config['unix_socket']) || array_key_exists('read', $config) || array_key_exists('write', $config)
            || ($config['host'] ?? null) !== $expected['host'] || ($config['database'] ?? null) !== $expected['database']
            || ($config['username'] ?? null) !== $expected['username']
            || (string) ($config['port'] ?? '') !== (string) $expected['port']) {
            throw new DomainException('Laravel staging connection does not match the approved database.');
        }
    }

    public static function binding(): array
    {
        return [
            'target' => config('legacy_admin.target'),
            'origin' => config('legacy_admin.url'),
            'connection' => config('legacy_admin.connection'),
            'database' => config('legacy_admin.database'),
            'host' => config('legacy_admin.host'),
            'username' => config('legacy_admin.username'),
            'port' => config('legacy_admin.port'),
            'current_user' => config('legacy_admin.current_user'),
            'server_id' => config('legacy_admin.server_id'),
            'version' => config('legacy_admin.version'),
        ];
    }
}
