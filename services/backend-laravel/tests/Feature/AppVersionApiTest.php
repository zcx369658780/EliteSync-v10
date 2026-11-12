<?php

namespace Tests\Feature;

use App\Models\AppReleaseVersion;
use Illuminate\Database\DatabaseManager;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Mockery;
use RuntimeException;
use Tests\TestCase;

class AppVersionApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_app_health_returns_database_status(): void
    {
        $this->getJson('/api/v1/app/health')
            ->assertOk()
            ->assertJsonPath('status', 'ok')
            ->assertJsonPath('checks.database.ok', true)
            ->assertJsonPath('checks.database.message', 'ok')
            ->assertJsonPath('checks.config.ok', true)
            ->assertJsonPath('checks.config.message', 'ok')
            ->assertJsonPath('app_version', (string) config('app_update.android.latest_version_name'))
            ->assertJsonPath('app_version_code', (int) config('app_update.android.latest_version_code'))
            ->assertJsonMissingPath('environment')
            ->assertJsonMissingPath('checks.database.driver');
    }

    public function test_app_health_degrades_without_exposing_database_failure_details(): void
    {
        $database = DB::getFacadeRoot();
        $injectedDetail = 'SQLSTATE[HY000] connection refused at db.internal:3306 database=private_db';
        $failingDatabase = Mockery::mock(DatabaseManager::class);
        $failingDatabase->shouldReceive('connection')
            ->once()
            ->andThrow(new RuntimeException($injectedDetail));
        DB::swap($failingDatabase);

        try {
            $response = $this->getJson('/api/v1/app/health');
        } finally {
            DB::swap($database);
        }

        $response
            ->assertOk()
            ->assertJsonPath('status', 'degraded')
            ->assertJsonPath('checks.database.ok', false)
            ->assertJsonPath('checks.database.message', 'unavailable')
            ->assertJsonPath('checks.config.ok', true)
            ->assertJsonPath('app_version', (string) config('app_update.android.latest_version_name'))
            ->assertJsonPath('app_version_code', (int) config('app_update.android.latest_version_code'))
            ->assertJsonMissingPath('environment')
            ->assertJsonMissingPath('checks.database.driver');

        $encodedResponse = $response->getContent();
        $this->assertIsString($encodedResponse);
        $this->assertStringNotContainsString($injectedDetail, $encodedResponse);
        $this->assertStringNotContainsString('SQLSTATE', $encodedResponse);
        $this->assertStringNotContainsString('connection refused', $encodedResponse);
        $this->assertStringNotContainsString('db.internal', $encodedResponse);
        $this->assertStringNotContainsString('private_db', $encodedResponse);
    }

    public function test_version_check_returns_soft_update(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.01.02',
            'version_code' => 102,
            'min_supported_version_name' => '0.01.01',
            'download_url' => 'https://slowdate.top/downloads/elitesync-0.01.02.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=0.01.01&version_code=101')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('force_update', false)
            ->assertJsonPath('latest_version_name', '0.01.02');
    }

    public function test_version_check_returns_force_update_when_below_min_supported(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.01.10',
            'version_code' => 110,
            'min_supported_version_name' => '0.01.05',
            'download_url' => 'https://slowdate.top/downloads/elitesync-0.01.10.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=0.01.01&version_code=101')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('force_update', true);
    }

    public function test_version_check_supports_alpha_suffix_ordering(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.03.02a',
            'version_code' => 30201,
            'min_supported_version_name' => '0.03.01',
            'download_url' => 'https://slowdate.top/downloads/elitesync-0.03.02a.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=0.03.02&version_code=302')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('latest_version_name', '0.03.02a');
    }

    public function test_development_version_is_not_forced_to_an_older_release(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.07.04',
            'version_code' => 704,
            'min_supported_version_name' => '0.07.04',
            'download_url' => 'https://example.invalid/old-release.apk',
            'force_update' => true,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=10.1.5-dev')
            ->assertOk()
            ->assertJsonPath('has_update', false)
            ->assertJsonPath('force_update', false);
    }

    public function test_stable_release_can_replace_its_prerelease(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '10.1.5',
            'version_code' => 1010501,
            'min_supported_version_name' => '10.1.4',
            'download_url' => 'https://example.invalid/stable-release.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=10.1.5-dev')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('force_update', false);
    }

    public function test_build_metadata_does_not_change_version_precedence(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '10.1.5',
            'version_code' => 1010501,
            'min_supported_version_name' => '10.1.5',
            'download_url' => 'https://example.invalid/stable-release.apk',
            'force_update' => true,
            'is_active' => true,
        ]);

        $query = http_build_query([
            'platform' => 'android',
            'version_name' => '10.1.5+build.42',
        ]);
        $this->getJson('/api/v1/app/version/check?'.$query)
            ->assertOk()
            ->assertJsonPath('has_update', false)
            ->assertJsonPath('force_update', false);
    }

    public function test_prerelease_identifiers_compare_numerically_and_lexically(): void
    {
        $cases = [
            ['latest' => '10.1.5-beta.10', 'client' => '10.1.5-beta.2'],
            ['latest' => '10.1.5-rc.1', 'client' => '10.1.5-beta.99'],
            ['latest' => '10.1.5-dev.alpha', 'client' => '10.1.5-dev.1'],
        ];
        foreach ($cases as $index => $case) {
            $channel = 'preview-'.$index;
            AppReleaseVersion::query()->create([
                'platform' => 'android',
                'channel' => $channel,
                'version_name' => $case['latest'],
                'version_code' => 1010501,
                'min_supported_version_name' => '10.1.4',
                'download_url' => 'https://example.invalid/preview-release.apk',
                'force_update' => false,
                'is_active' => true,
            ]);

            $query = http_build_query([
                'platform' => 'android',
                'channel' => $channel,
                'version_name' => $case['client'],
            ]);
            $this->getJson('/api/v1/app/version/check?'.$query)
                ->assertOk()
                ->assertJsonPath('has_update', true)
                ->assertJsonPath('force_update', false);
        }
    }
}
