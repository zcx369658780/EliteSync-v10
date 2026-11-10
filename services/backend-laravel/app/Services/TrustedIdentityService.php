<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/** No real provider is configured. This issuer has no HTTP/admin entry point. */
final class TrustedIdentityService
{
    public function sandbox(): bool
    {
        if (! config('journey.test_issuer_enabled') || strlen((string) config('journey.test_issuer_key')) < 32) {
            return false;
        }
        $db = DB::connection();
        return (app()->environment('testing') && $db->getDriverName() === 'sqlite' && $db->getDatabaseName() === ':memory:')
            || (app()->environment('local') && in_array($db->getDriverName(), ['mysql', 'mariadb'], true)
                && $db->getDatabaseName() === 'elitesync_v10_1_2_dev' && $db->getConfig('host') === '127.0.0.1'
                && (int) $db->getConfig('port') === 43323 && ! $db->getConfig('unix_socket') && ! $db->getConfig('url'));
    }

    public function registered(int $id): bool
    {
        return $this->sandbox() && User::whereKey($id)->where('is_synthetic', true)->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())->exists()
            && DB::table('development_identity_subjects')->where('user_id', $id)->where('dataset', config('journey.dataset'))->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())->exists();
    }

    public function register(int $id): void
    {
        abort_unless($this->sandbox() && app()->runningInConsole(), 403, 'test issuer unavailable');
        DB::transaction(function () use ($id) {
            app(JourneyStore::class)->users([$id]);
            abort_unless(User::whereKey($id)->where('is_synthetic', true)->when(DB::transactionLevel() > 0, fn ($q) => $q->lockForUpdate())->exists(), 403, 'synthetic subject required');
            DB::table('development_identity_subjects')->updateOrInsert(['user_id' => $id], ['dataset' => config('journey.dataset'), 'created_at' => now(), 'updated_at' => now()]);
        });
    }

    private function signature(object $r): string
    {
        return hash_hmac('sha256', implode('|', [$r->id, $r->user_id, $r->issuer, $r->dataset, $r->nonce, $r->revision, $r->valid_from, $r->expires_at]), (string) config('journey.test_issuer_key'));
    }

    public function issue(int $id, string $nonce, int $minutes = 60): string
    {
        abort_unless(app()->runningInConsole(), 403, 'test issuer unavailable');
        return DB::transaction(function () use ($id, $nonce, $minutes) {
            app(JourneyStore::class)->users([$id]);
            abort_unless($this->registered($id) && $minutes > 0 && $minutes <= 1440, 403, 'test subject unavailable');
            abort_if(DB::table('identity_assertions')->where('nonce', $nonce)->exists(), 409, 'assertion replay');
            $row = (object) ['id' => (string) Str::uuid(), 'user_id' => $id, 'issuer' => 'V1012_LOCAL_TEST_ONLY', 'dataset' => config('journey.dataset'), 'nonce' => $nonce, 'revision' => 1, 'valid_from' => now()->utc()->format('Y-m-d H:i:s'), 'expires_at' => now()->utc()->addMinutes($minutes)->format('Y-m-d H:i:s')];
            DB::table('identity_assertions')->insert((array) $row + ['signature' => $this->signature($row), 'created_at' => now(), 'updated_at' => now()]);
            app(JourneyStore::class)->audit($id, $row->id, 'TEST_ONLY_ISSUED', ['issuer' => $row->issuer, 'expires_at' => $row->expires_at]);
            return $row->id;
        });
    }

    public function valid(int $id, ?string $credential = null): bool
    {
        if (! $this->registered($id)) { return false; }
        // Locking reads stay current even in an outer RR transaction with an older snapshot.
        $rows = DB::table('identity_assertions')->where('user_id', $id)->when($credential !== null, fn($q) => $q->where('id', $credential))->whereNull('revoked_at')->where('valid_from', '<=', now()->utc())->where('expires_at', '>', now()->utc())->lockForUpdate()->get();
        return $rows->contains(fn ($r) => $r->issuer === 'V1012_LOCAL_TEST_ONLY' && $r->dataset === config('journey.dataset') && hash_equals($this->signature($r), $r->signature));
    }

    public function credential(int $id): ?string
    {
        if (! $this->registered($id)) { return null; }
        foreach (DB::table('identity_assertions')->where('user_id', $id)->orderByDesc('created_at')->orderByDesc('id')->lockForUpdate()->get() as $r) {
            if ($this->valid($id, $r->id)) { return $r->id; }
        }
        return null;
    }

    public function status(int $id): array
    {
        $valid = $this->valid($id);
        return ['status' => $valid ? 'DEV_SYNTHETIC_VERIFIED' : 'PROVIDER_NOT_CONFIGURED', 'test_only' => $valid, 'real_provider' => 'PENDING', 'activation_available' => $valid];
    }

    public function revoke(int $id, string $credential): void
    {
        abort_unless(app()->runningInConsole() && $this->sandbox(), 403);
        DB::transaction(function () use ($id, $credential) {
            app(JourneyStore::class)->users([$id], true);
            DB::table('identity_assertions')->where('id', $credential)->where('user_id', $id)->update(['revoked_at' => now(), 'updated_at' => now()]);
            app(FormalRelationshipService::class)->suspendCredential($id, $credential);
            app(JourneyStore::class)->audit($id, $credential, 'TEST_ONLY_REVOKED', []);
        });
    }
}
