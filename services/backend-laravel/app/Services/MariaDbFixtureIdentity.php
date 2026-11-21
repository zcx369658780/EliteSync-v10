<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Database\Query\Builder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/** Only the explicitly provisioned local function fixture may use these assertions. */
final class MariaDbFixtureIdentity
{
    public const DATASET = 'v2-function-match-qa';
    public const ISSUER = 'V2_FUNCTION_MARIADB_TEST_ONLY';
    private const KEY_FILE = '/run/secrets/v2_function_identity_key';

    private function key(): ?string
    {
        if (! config('journey.mariadb_fixture_enabled')
            || config('journey.mariadb_fixture_runtime') !== 'local-v2-function'
            || ! app(SyntheticConnectionScope::class)->matchesDatabase()
            || ! is_readable(self::KEY_FILE)) {
            return null;
        }
        $key = trim((string) @file_get_contents(self::KEY_FILE, length: 66));

        return preg_match('/\A[0-9a-f]{64}\z/D', $key) ? hex2bin($key) : null;
    }

    public function enabled(): bool
    {
        return $this->key() !== null;
    }

    public function matchingDigestKey(): string
    {
        $key = $this->key();

        return $key === null ? '' : hash_hmac('sha256', 'v2-function-matching-candidate-digest', $key);
    }

    private function cohort(int $id, bool $active = true): bool
    {
        return User::whereKey($id)->where('is_synthetic', true)->where('account_type', 'test')
            ->where('synthetic_batch', self::DATASET)
            ->when($active, fn ($q) => $q->where('disabled', false)->where('account_status', 'active')->where('moderation_status', 'normal'))
            ->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())->first(['id']) !== null;
    }

    private function assertions(int $id): Builder
    {
        return DB::table('identity_assertions')->where('user_id', $id)
            ->where('issuer', self::ISSUER)->where('dataset', self::DATASET);
    }

    private function signature(object $row, string $key): string
    {
        return hash_hmac('sha256', json_encode([
            self::ISSUER, self::DATASET, SyntheticConnectionScope::DATABASE, SyntheticConnectionScope::SERVER_ID,
            $row->id, (int) $row->user_id, $row->nonce, (int) $row->revision, $row->valid_from, $row->expires_at,
        ], JSON_THROW_ON_ERROR), $key);
    }

    public function credential(int $id, ?string $expected = null): ?string
    {
        $key = $this->key();
        if ($key === null || ! $this->cohort($id)) {
            return null;
        }
        $now = now('UTC');
        $rows = $this->assertions($id)->whereNull('revoked_at')->where('valid_from', '<=', $now)->where('expires_at', '>', $now)
            ->when($expected !== null, fn ($q) => $q->where('id', $expected))
            ->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())
            ->orderByDesc('valid_from')->orderByDesc('id')->get();

        return $rows->first(fn ($row) => hash_equals($this->signature($row, $key), $row->signature))?->id;
    }

    public function allowsPair(int $actor, int $peer): bool
    {
        return $actor !== $peer && $this->credential(min($actor, $peer)) !== null
            && $this->credential(max($actor, $peer)) !== null;
    }

    public function issue(int $id, string $nonce, int $minutes): string
    {
        abort_unless(app()->runningInConsole() && ($key = $this->key()) !== null, 403, 'fixture issuer unavailable');
        abort_unless(Str::isUuid($nonce) && $minutes >= 1 && $minutes <= 60, 422, 'invalid fixture credential bounds');

        return DB::transaction(function () use ($id, $nonce, $minutes, $key) {
            app(JourneyStore::class)->users([$id]);
            abort_unless($this->cohort($id), 403, 'fixture subject unavailable');
            abort_if(DB::table('identity_assertions')->where('nonce', $nonce)->exists(), 409, 'assertion replay');
            $now = now('UTC');
            $row = (object) ['id' => (string) Str::uuid(), 'user_id' => $id, 'issuer' => self::ISSUER,
                'dataset' => self::DATASET, 'nonce' => $nonce, 'revision' => 1,
                'valid_from' => $now->toDateTimeString(), 'expires_at' => $now->copy()->addMinutes($minutes)->toDateTimeString()];
            DB::table('identity_assertions')->insert((array) $row + [
                'signature' => $this->signature($row, $key), 'created_at' => $now, 'updated_at' => $now,
            ]);
            app(JourneyStore::class)->audit($id, $row->id, 'MARIADB_TEST_ONLY_ISSUED',
                ['issuer' => self::ISSUER, 'dataset' => self::DATASET, 'expires_at' => $row->expires_at, 'revision' => 1]);

            return $row->id;
        }, 3);
    }

    public function revoke(int $id, string $credential): void
    {
        abort_unless(app()->runningInConsole() && $this->enabled(), 403, 'fixture issuer unavailable');
        DB::transaction(function () use ($id, $credential) {
            app(JourneyStore::class)->users([$id], true);
            abort_unless($this->cohort($id, active: false), 403, 'fixture subject unavailable');
            $row = $this->assertions($id)->where('id', $credential)->lockForUpdate()->first();
            abort_unless($row, 404, 'fixture credential unavailable');
            if ($row->revoked_at !== null) {
                return;
            }
            $now = now('UTC');
            $revision = (int) $row->revision + 1;
            $this->assertions($id)->where('id', $credential)->update([
                'revoked_at' => $now, 'updated_at' => $now, 'revision' => $revision,
            ]);
            app(FormalRelationshipService::class)->suspendCredential($id, $credential);
            app(JourneyStore::class)->audit($id, $credential, 'MARIADB_TEST_ONLY_REVOKED',
                ['issuer' => self::ISSUER, 'dataset' => self::DATASET, 'revision' => $revision]);
        }, 3);
    }
}
