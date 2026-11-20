<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserDynamicChart;
use Illuminate\Support\Facades\DB;

final class DataPurposeService
{
    public const CITY_IN_SHOWCASE = 'showcase_city';
    public const NATAL_IN_DYNAMIC = 'dynamic_own_natal';

    private const BASIS = 'ISOLATED_TEST_ONLY';

    /** The only configured basis is a signed synthetic identity in isolated memory. */
    public function testOnly(int $owner): bool
    {
        return app(TrustedIdentityService::class)->participationAllowed($owner);
    }

    private function grant(int $owner, string $purpose = self::CITY_IN_SHOWCASE): ?object
    {
        return DB::table('data_purpose_grants')->where('user_id', $owner)
            ->where('purpose', $purpose)->lockForUpdate()->first();
    }

    private function isCurrent(?object $grant): bool
    {
        return $grant && $grant->basis === self::BASIS && $grant->state === 'GRANTED'
            && $grant->expires_at && now()->lt($grant->expires_at);
    }

    /** The controller and the showcase workflow hold the owner lock. */
    public function status(int $owner, string $purpose = self::CITY_IN_SHOWCASE): array
    {
        $mode = $this->testOnly($owner);
        $grant = $mode ? $this->grant($owner, $purpose) : null;
        $city = $purpose === self::CITY_IN_SHOWCASE;

        return [
            'purpose' => $purpose, 'source' => $city ? 'profile.current_city' : 'private_natal.input_revision',
            'fields' => $city ? ['current_city'] : ['civil_date', 'civil_time', 'time_precision',
                'timezone', 'location', 'algorithm_parameters'],
            'audience' => $city ? 'SELF_PREVIEW_UNTIL_SEPARATE_PUBLICATION' : 'SELF_ONLY',
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

    public function decide(int $owner, string $state, int $expected, string $purpose = self::CITY_IN_SHOWCASE): array
    {
        abort_unless($this->testOnly($owner), 409, 'LEGAL_BASIS_UNVERIFIED');
        $grant = $this->grant($owner, $purpose);
        abort_unless((int) ($grant->revision ?? 0) === $expected, 409, 'PURPOSE_CHANGED_REFRESH_REQUIRED');
        DB::table('data_purpose_grants')->updateOrInsert(['user_id' => $owner, 'purpose' => $purpose], [
            'state' => $state, 'basis' => self::BASIS, 'revision' => $expected + 1,
            'expires_at' => $state === 'GRANTED' ? now()->addHour() : null,
            'created_at' => $grant->created_at ?? now(), 'updated_at' => now(),
        ]);

        return $this->status($owner, $purpose);
    }

    public function dynamicUsesNatal(array $request): bool
    {
        return data_get($request, 'first.source') === 'own_natal'
            || data_get($request, 'second.source') === 'own_natal';
    }

    public function dynamicRevision(int $owner): ?int
    {
        $grant = $this->testOnly($owner) ? $this->grant($owner, self::NATAL_IN_DYNAMIC) : null;

        return $this->isCurrent($grant) ? (int) $grant->revision : null;
    }

    public function dynamicView(User $owner, UserDynamicChart $row, DynamicChartService $service): array
    {
        if (! $this->dynamicUsesNatal($row->request)) {
            return $service->view($owner, $row);
        }
        $revision = $this->dynamicRevision((int) $owner->id);
        if ($revision === null || ($row->prepared['_purpose_grant_revision'] ?? null) !== $revision) {
            return ['id' => $row->id, 'chart_type' => $row->chart_type, 'input_revision' => $row->input_revision,
                'result_revision' => null, 'results' => null, 'status' => 'PURPOSE_UNAVAILABLE'];
        }

        return $service->view($owner, $row) + ['purpose_revision' => $revision];
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
