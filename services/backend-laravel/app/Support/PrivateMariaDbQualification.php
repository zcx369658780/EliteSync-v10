<?php

namespace App\Support;

use Illuminate\Foundation\Application;
use RuntimeException;

/** Opt-in guard for this Owner-frozen, private synthetic MariaDB task only. */
final class PrivateMariaDbQualification
{
    public static function assertConfiguration(array $config, bool $testing): void
    {
        if (! $testing || ($config['driver'] ?? null) !== 'mariadb'
            || ($config['host'] ?? null) !== '127.0.0.1'
            || ! in_array($config['port'] ?? null, [43329, '43329'], true)
            || ($config['database'] ?? null) !== 'elitesync_v1015_verify_20261029'
            || ($config['username'] ?? null) !== 'v1015_task'
            || ! empty($config['url']) || ! empty($config['unix_socket'])
            || ! empty($config['read']) || ! empty($config['write'])) {
            throw new RuntimeException('Private MariaDB task config mismatch; no migrations permitted.');
        }
    }

    public static function assertApplication(Application $app): void
    {
        $default = $app['config']->get('database.default');
        if ($default !== 'mariadb') {
            throw new RuntimeException('Private task requires exactly one MariaDB default connection.');
        }
        self::assertConfiguration($app['config']->get('database.connections.mariadb', []), $app->environment('testing'));
        $file = getenv('ELITESYNC_TASK_DB_QUALIFICATION');
        $expectedHash = getenv('ELITESYNC_TASK_DB_QUALIFICATION_SHA256');
        if (! $file || ! $expectedHash || ! is_file($file)) {
            throw new RuntimeException('Private task qualification is missing or changed.');
        }
        // Consistency with the trusted task runner, not a security boundary
        // against an attacker controlling both the process environment and file.
        $bytes = file_get_contents($file);
        if ($bytes === false || ! hash_equals($expectedHash, hash('sha256', $bytes))) {
            throw new RuntimeException('Private task qualification is missing or changed.');
        }
        $proof = json_decode($bytes, true, 512, JSON_THROW_ON_ERROR);
        $root = realpath(dirname($file));
        $data = realpath($proof['datadir'] ?? '');
        if (($proof['taskBlob'] ?? null) !== '48d3670ac26b1959c1b59ffb4871109cef09a4c8'
            || ($proof['taskId'] ?? null) !== 'V1015_PORTABLE_TOOLCHAIN_RECOVERY_20261029'
            || ! $root || $root !== realpath($proof['taskRoot'] ?? '')
            || ! $data || dirname($data) !== $root || basename($data) !== 'mariadb_data'
            || ($proof['host'] ?? null) !== '127.0.0.1' || ($proof['port'] ?? null) !== 43329
            || ($proof['database'] ?? null) !== 'elitesync_v1015_verify_20261029'
            || ($proof['username'] ?? null) !== 'v1015_task') {
            throw new RuntimeException('Private task source/datadir proof mismatch.');
        }
        $connection = $app['db']->connection('mariadb');
        $live = $connection->selectOne('SELECT @@version AS version, @@port AS port, @@datadir AS datadir, @@server_id AS server_id, DATABASE() AS db, CURRENT_USER() AS actor');
        if (! str_starts_with($live->version, '10.11.19-MariaDB') || (int) $live->port !== 43329
            || realpath($live->datadir) !== $data || (int) $live->server_id !== ($proof['serverId'] ?? null)
            || $live->db !== 'elitesync_v1015_verify_20261029' || $live->actor !== 'v1015_task@127.0.0.1') {
            throw new RuntimeException('Live private task instance mismatch; no migrations permitted.');
        }
        self::assertGrants(array_map(fn ($row) => (string) array_values((array) $row)[0], $connection->select('SHOW GRANTS')));
    }

    public static function assertGrants(array $grants): void
    {
        if ($grants === []) {
            throw new RuntimeException('Task grants could not be established.');
        }
        foreach ($grants as $grant) {
            // Schema DDL, including DROP, is required by RefreshDatabase, but
            // the test actor has no privileges outside this new synthetic DB.
            if (! str_contains($grant, 'GRANT USAGE ON *.*')
                && ! str_contains($grant, ' ON `elitesync_v1015_verify_20261029`.* ')) {
                throw new RuntimeException('Test actor has privileges outside the private schema.');
            }
            if (str_contains($grant, 'WITH GRANT OPTION')) {
                throw new RuntimeException('Test actor may not delegate privileges.');
            }
        }
    }
}
