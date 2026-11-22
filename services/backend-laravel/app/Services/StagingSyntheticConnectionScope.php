<?php

namespace App\Services;

use App\Models\User;
use DateTimeImmutable;
use DateTimeZone;
use Illuminate\Database\Query\Builder;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

/** Local restricted-staging rehearsal. A grant supplies no Connection or consent. */
final class StagingSyntheticConnectionScope
{
    private const TARGET = 'elitesync-restricted-scope-local';
    private const ORIGIN = 'https://scope-stage.elitesync.invalid';
    private const SCHEMA = 'elitesync_v2_scope_local';
    private const SERVER_ID = 2621135;
    private const DB_USER = 'elitesync_scope_app';
    private const BATCH = 'restricted-remote-qa';

    public function targetsRuntime(): bool
    {
        return app()->environment('staging') && config('staging_connection.instance') === self::TARGET;
    }

    public function allowsActor(int $actor): bool
    {
        if (! $this->enabled()) {
            return false;
        }

        $pairs = $this->activeGrants()->where(fn ($query) => $query->where('user_a', $actor)->orWhere('user_b', $actor))
            ->get(['user_a', 'user_b']);

        return $pairs->contains(fn ($row) => $this->eligible((int) $row->user_a, (int) $row->user_b));
    }

    public function allowsPair(int $a, int $b): bool
    {
        if ($a === $b || ! $this->enabled() || ! $this->eligible($a, $b, DB::transactionLevel() > 0)) {
            return false;
        }

        return $this->activeGrants()->where('user_a', min($a, $b))->where('user_b', max($a, $b))
            ->when(DB::transactionLevel() > 0, fn ($query) => $query->lockForUpdate())->first(['id']) !== null;
    }

    public function change(string $action, array $manifest): bool
    {
        if (! app()->runningInConsole() || ! in_array($action, ['grant', 'revoke'], true)
            || ! $this->manifestMatches($manifest, $action) || ! $this->enabled()) {
            return false;
        }

        $now = now('UTC');
        $expires = null;
        if ($action === 'grant') {
            $raw = $manifest['expires_at'];
            $expires = is_string($raw) && strlen($raw) === 20
                ? DateTimeImmutable::createFromFormat('!Y-m-d\TH:i:s\Z', $raw, new DateTimeZone('UTC')) : false;
            if (! $expires || $expires->format('Y-m-d\TH:i:s\Z') !== $raw
                || $expires <= $now || $expires > $now->copy()->addHours(24)) {
                return false;
            }
        }

        return DB::transaction(function () use ($action, $manifest, $now, $expires) {
            $a = min($manifest['a'], $manifest['b']);
            $b = max($manifest['a'], $manifest['b']);
            User::query()->whereKey([$a, $b])->orderBy('id')->lockForUpdate()->get(['id']);
            $pair = DB::table('staging_connection_grants')->where('user_a', $a)->where('user_b', $b);
            if ($action === 'revoke') {
                return $pair->whereNull('revoked_at')->update([
                    'revoked_at' => $now,
                    'revocation' => $manifest['ticket'],
                ]) === 1;
            }
            if (! $this->eligible($a, $b, true) || $pair->first(['id']) !== null) {
                return false;
            }

            return DB::table('staging_connection_grants')->insert([
                'user_a' => $a,
                'user_b' => $b,
                'approval' => $manifest['ticket'],
                'granted_at' => $now,
                'expires_at' => $expires,
            ]);
        });
    }

    private function enabled(): bool
    {
        $hash = config('staging_connection.marker_sha256');
        if (! $this->targetsRuntime() || config('staging_connection.enabled') !== true
            || config('app.url') !== self::ORIGIN || ! is_string($hash) || ! preg_match('/\A[a-f0-9]{64}\z/', $hash)) {
            return false;
        }

        try {
            $db = DB::connection();
            if ($db->getDriverName() !== 'mariadb' || $db->getDatabaseName() !== self::SCHEMA
                || $db->getConfig('username') !== self::DB_USER || $db->getConfig('host') !== 'scope-db'
                || (int) $db->getConfig('port') !== 3306 || $db->getConfig('url') || $db->getConfig('unix_socket')
                || $db->getConfig('read') || $db->getConfig('write')) {
                return false;
            }
            $identity = $db->selectOne(
                "SELECT DATABASE() AS db_name, @@server_id AS server_id, VERSION() AS db_version, SUBSTRING_INDEX(CURRENT_USER(), '@', 1) AS db_user",
                [], false
            );
            if (! $identity || $identity->db_name !== self::SCHEMA || $identity->db_user !== self::DB_USER
                || (int) $identity->server_id !== self::SERVER_ID || ! preg_match('/\A10\.11\..*MariaDB/i', $identity->db_version)) {
                return false;
            }
            $marker = $db->table('staging_connection_instance')->where('id', 1)->useWritePdo()->value('marker');

            return is_string($marker) && preg_match('/\A[a-f0-9]{64}\z/', $marker)
                && hash_equals($hash, hash('sha256', $marker));
        } catch (QueryException) {
            return false;
        }
    }

    private function eligible(int $a, int $b, bool $lock = false): bool
    {
        return User::query()->whereKey([$a, $b])->where('is_synthetic', true)->where('account_type', 'test')
            ->where('synthetic_batch', self::BATCH)->where('role', 'user')->where('disabled', false)
            ->where('account_status', 'active')->orderBy('id')
            ->when($lock, fn ($query) => $query->lockForUpdate())->get(['id'])->count() === 2;
    }

    private function activeGrants(): Builder
    {
        return DB::table('staging_connection_grants')->whereNull('revoked_at')->where('expires_at', '>', now('UTC'));
    }

    private function manifestMatches(array $data, string $action): bool
    {
        $identity = ['target' => self::TARGET, 'schema' => self::SCHEMA, 'server_id' => self::SERVER_ID,
            'origin' => self::ORIGIN, 'batch' => self::BATCH];
        $expectedKeys = [...array_keys($identity), 'a', 'b', 'ticket'];
        if ($action === 'grant') {
            $expectedKeys[] = 'expires_at';
        }
        if (count($data) !== count($expectedKeys) || array_diff($expectedKeys, array_keys($data))) {
            return false;
        }
        foreach ($identity as $key => $value) {
            if ($data[$key] !== $value) {
                return false;
            }
        }

        return is_int($data['a']) && is_int($data['b']) && $data['a'] > 0 && $data['b'] > 0 && $data['a'] !== $data['b']
            && is_string($data['ticket']) && preg_match('/\A[A-Z][A-Z0-9-]{2,63}\z/', $data['ticket']) === 1;
    }
}
