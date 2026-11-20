<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;

final class DataPurposeService
{
    public const CITY_IN_SHOWCASE = 'showcase_city';
    private const BASIS = 'ISOLATED_TEST_ONLY';

    /** The only configured basis is a signed synthetic identity in isolated memory. */
    public function testOnly(int $owner): bool
    {
        return app(TrustedIdentityService::class)->participationAllowed($owner);
    }

    private function grant(int $owner): ?object
    {
        return DB::table('data_purpose_grants')->where('user_id', $owner)
            ->where('purpose', self::CITY_IN_SHOWCASE)->lockForUpdate()->first();
    }

    private function isCurrent(?object $grant): bool
    {
        return $grant && $grant->basis === self::BASIS && $grant->state === 'GRANTED'
            && $grant->expires_at && now()->lt($grant->expires_at);
    }

    /** The controller and the showcase workflow hold the owner lock. */
    public function status(int $owner): array
    {
        $mode = $this->testOnly($owner);
        $grant = $mode ? $this->grant($owner) : null;

        return [
            'purpose' => self::CITY_IN_SHOWCASE, 'source' => 'profile.current_city',
            'fields' => ['current_city'], 'audience' => 'SELF_PREVIEW_UNTIL_SEPARATE_PUBLICATION',
            'available' => $mode, 'test_only' => $mode,
            'state' => match (true) {
                ! $mode => 'LEGAL_BASIS_UNVERIFIED',
                $grant === null => 'NO_DECISION',
                $grant->state === 'GRANTED' && ! $this->isCurrent($grant) => 'EXPIRED',
                default => $grant->state,
            },
            'revision' => (int) ($grant->revision ?? 0),
            'expires_at' => $grant?->expires_at,
        ];
    }

    public function decide(int $owner, string $state, int $expected): array
    {
        abort_unless($this->testOnly($owner), 409, 'LEGAL_BASIS_UNVERIFIED');
        $grant = $this->grant($owner);
        abort_unless((int) ($grant->revision ?? 0) === $expected, 409, 'PURPOSE_CHANGED_REFRESH_REQUIRED');
        DB::table('data_purpose_grants')->updateOrInsert(['user_id' => $owner, 'purpose' => self::CITY_IN_SHOWCASE], [
            'state' => $state, 'basis' => self::BASIS, 'revision' => $expected + 1,
            'expires_at' => $state === 'GRANTED' ? now()->addHour() : null,
            'created_at' => $grant->created_at ?? now(), 'updated_at' => now(),
        ]);

        return $this->status($owner);
    }

    private function currentCity(int $owner): string
    {
        return trim((string) User::whereKey($owner)->lockForUpdate()->value('city'));
    }

    private function digest(string $city): string
    {
        return hash_hmac('sha256', $city, (string) config('app.key'));
    }

    public function reuseCity(int $owner): array
    {
        $grant = $this->testOnly($owner) ? $this->grant($owner) : null;
        abort_unless($this->isCurrent($grant), 409, 'PURPOSE_PERMISSION_REQUIRED');
        $city = $this->currentCity($owner);
        abort_if($city === '', 422, 'SOURCE_FIELD_UNAVAILABLE');

        return [$city, ['grant_revision' => (int) $grant->revision, 'source_digest' => $this->digest($city)]];
    }

    public function dependency(int $owner, int $revision): ?object
    {
        return DB::table('showcase_city_sources')->where('user_id', $owner)
            ->where('draft_revision', $revision)->lockForUpdate()->first();
    }

    public function recordDependency(int $owner, int $revision, array $source): void
    {
        DB::table('showcase_city_sources')->insert(['user_id' => $owner, 'draft_revision' => $revision] + $source);
    }

    public function permitsSnapshot(int $owner, object $source): bool
    {
        $grant = $this->testOnly($owner) ? $this->grant($owner) : null;

        return $this->isCurrent($grant) && (int) $grant->revision === (int) $source->grant_revision;
    }

    public function derivationState(int $owner, object $source): string
    {
        if (! $this->permitsSnapshot($owner, $source)) {
            return 'PURPOSE_UNAVAILABLE';
        }

        return hash_equals($source->source_digest, $this->digest($this->currentCity($owner))) ? 'CURRENT' : 'NEEDS_REVIEW';
    }
}
