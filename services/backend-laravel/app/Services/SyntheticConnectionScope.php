<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

/** Local integration fixtures only. Grants never confer formal identity or matching authority. */
final class SyntheticConnectionScope
{
    public const DATABASE = 'elitesync_v2_function';
    public const SERVER_ID = 2621121;
    public const ORIGIN = 'https://127.0.0.1:18444';
    public const DATASET = 'v2-function-qa';

    public function targetsFixtureRuntime(): bool
    {
        return $this->targetsOriginalFixtureRuntime() || app(StagingSyntheticConnectionScope::class)->targetsRuntime();
    }

    private function targetsOriginalFixtureRuntime(): bool
    {
        if (! app()->environment('staging') || config('app.url') !== self::ORIGIN) {
            return false;
        }

        $db = DB::connection();

        return $db->getDriverName() === 'mariadb' && $db->getDatabaseName() === self::DATABASE
            && $db->getConfig('username') === 'elitesync_function_app'
            && $db->getConfig('host') === 'r0-db' && (int) $db->getConfig('port') === 3306
            && ! $db->getConfig('url') && ! $db->getConfig('unix_socket');
    }

    public function enabled(): bool
    {
        return (bool) config('restoration.synthetic_connection_enabled') && $this->matchesDatabase();
    }

    public function matchesDatabase(): bool
    {
        if (! $this->targetsOriginalFixtureRuntime()) {
            return false;
        }

        try {
            $identity = DB::selectOne("SELECT DATABASE() AS db_name, @@server_id AS server_id, VERSION() AS db_version, SUBSTRING_INDEX(CURRENT_USER(), '@', 1) AS db_user", [], false);
        } catch (QueryException) {
            return false;
        }

        return $identity->db_name === self::DATABASE && $identity->db_user === 'elitesync_function_app'
            && (int) $identity->server_id === self::SERVER_ID
            && preg_match('/^10\.11\..*MariaDB/i', $identity->db_version) === 1;
    }

    public function allowsActor(int $actor): bool
    {
        return ($this->enabled() && $this->eligibleUsers([$actor]))
            || app(StagingSyntheticConnectionScope::class)->allowsActor($actor);
    }

    public function allowsPair(int $actor, int $peer): bool
    {
        return ($actor !== $peer && $this->enabled() && $this->eligibleUsers([$actor, $peer])
            && $this->pair($actor, $peer)->whereNull('revoked_at')->where('expires_at', '>', now('UTC'))->first() !== null)
            || app(StagingSyntheticConnectionScope::class)->allowsPair($actor, $peer);
    }

    /** Only the fixture console can write grants. A retired pair must use fresh accounts. */
    public function change(string $action, int $actor, int $peer): bool
    {
        if (! app()->runningInConsole() || ! $this->enabled() || $actor <= 0 || $peer <= 0 || $actor === $peer) {
            return false;
        }

        return DB::transaction(function () use ($action, $actor, $peer) {
            User::whereIn('id', [$actor, $peer])->orderBy('id')->lockForUpdate()->get(['id']);
            $pair = $this->pair($actor, $peer);

            if ($action === 'revoke') {
                return $pair->whereNull('revoked_at')->update(['revoked_at' => now('UTC')]) === 1;
            }

            if ($action !== 'grant' || ! $this->eligibleUsers([$actor, $peer]) || $pair->first()) {
                return false;
            }

            $now = now('UTC');

            return DB::table('synthetic_connection_pairs')->insert([
                'user_a' => min($actor, $peer), 'user_b' => max($actor, $peer),
                'granted_at' => $now, 'expires_at' => $now->copy()->addHours(4),
            ]);
        });
    }

    private function eligibleUsers(array $ids): bool
    {
        return User::whereIn('id', $ids)->where('is_synthetic', true)->where('account_type', 'test')
            ->where('synthetic_batch', self::DATASET)->where('disabled', false)->where('account_status', 'active')
            ->orderBy('id')->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())
            ->get(['id'])->count() === count($ids);
    }

    private function pair(int $actor, int $peer): \Illuminate\Database\Query\Builder
    {
        return DB::table('synthetic_connection_pairs')->where('user_a', min($actor, $peer))
            ->where('user_b', max($actor, $peer))
            ->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate());
    }
}
