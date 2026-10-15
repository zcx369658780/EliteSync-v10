<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\BirthLocationSolarTimeService;
use App\Services\LunarPhpBaziEngine;
use com\nlf\calendar\Solar;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007BaziProvenanceTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        config([
            'restoration.enabled' => true, 'astro_rollout.bazi.enabled' => true,
            'astro_rollout.bazi.platform_overrides' => [], 'astro_rollout.bazi.min_profile_version' => 0,
            'python_astro.api_base' => '', 'python_astro.render_url' => '',
        ]);
        Http::preventStrayRequests();
        $this->user = User::factory()->create(['phone' => '19900000771', 'disabled' => false, 'birthday' => '1989-09-05', 'gender' => 'male']);
        Sanctum::actingAs($this->user);
    }

    private function basic(array $overrides = []): array
    {
        return array_replace(['birthday' => '1989-09-05', 'gender' => 'male', 'city' => '上海', 'relationship_goal' => 'dating'], $overrides);
    }

    public function test_real_local_lunar_engine_produces_known_four_pillars_without_coordinates(): void
    {
        $this->postJson('/api/v1/profile/astro', ['birth_time' => '14:30', 'tz_str' => 'Asia/Shanghai'])
            ->assertOk()->assertJsonPath('profile.bazi', '己巳 壬申 戊辰 己未');
        $profile = UserAstroProfile::where('user_id', $this->user->id)->firstOrFail();
        $this->assertSame('己巳 壬申 戊辰 己未', $profile->bazi);
        $this->assertContains('canonical_source:lunar_php', $profile->notes);
        $this->assertContains('civil_timezone:Asia/Shanghai', $profile->notes);
        $this->assertContains('birth_time_input_source:user_input', $profile->notes);
    }

    public function test_missing_birth_time_is_explicit_default_noon_with_low_confidence(): void
    {
        $this->postJson('/api/v1/profile/basic', $this->basic())->assertOk();
        $profile = UserAstroProfile::where('user_id', $this->user->id)->firstOrFail();
        $this->assertSame('12:00', $profile->birth_time);
        $this->assertContains('civil_timezone:Asia/Shanghai', $profile->notes);
        $this->assertContains('birth_time_input_source:default_noon_unknown', $profile->notes);
        $confidence = array_values(array_filter($profile->notes, fn ($note) => str_starts_with($note, 'canonical_confidence:')));
        $this->assertCount(1, $confidence);
        $this->assertLessThanOrEqual(0.35, (float) substr($confidence[0], strlen('canonical_confidence:')));
    }

    public function test_invalid_time_or_unsupported_timezone_rejects_before_user_or_profile_write(): void
    {
        $before = $this->user->fresh()->getRawOriginal();
        foreach ([['birth_time' => '25:99'], ['birth_time' => '14:30', 'tz_str' => 'UTC']] as $invalid) {
            $this->postJson('/api/v1/profile/basic', $this->basic($invalid + ['name' => 'must not persist']))->assertUnprocessable();
            $this->assertSame($before, $this->user->fresh()->getRawOriginal());
            $this->assertDatabaseCount('user_astro_profiles', 0);
            $this->postJson('/api/v1/profile/astro', $invalid)->assertUnprocessable();
            $this->assertSame($before, $this->user->fresh()->getRawOriginal());
            $this->assertDatabaseCount('user_astro_profiles', 0);
        }
    }

    public function test_client_cannot_supply_derived_bazi_or_provenance_notes(): void
    {
        foreach (['bazi' => '伪造四柱', 'notes' => ['canonical_source:client']] as $key => $value) {
            $this->postJson('/api/v1/profile/astro', ['birth_time' => '14:30', $key => $value])->assertUnprocessable();
            $this->assertDatabaseCount('user_astro_profiles', 0);
        }
    }

    public function test_solar_longitude_shift_crosses_civil_date_and_uses_real_lunar_date(): void
    {
        $context = app(BirthLocationSolarTimeService::class)->resolve([
            'birthday' => '1989-09-05', 'birth_time' => '00:10', 'birth_lng' => 75,
        ]);
        $this->assertSame('1989-09-04', $context['effective_birthday']);
        $this->assertTrue(checkdate(9, 4, 1989));
        $this->assertSame('longitude_based', $context['location_source']);
        $result = app(LunarPhpBaziEngine::class)->canonicalize([
            'birthday' => $context['effective_birthday'], 'birth_time' => $context['effective_birth_time'], 'gender' => 'male',
        ]);
        $expected = Solar::fromYmdHms(1989, 9, 4,
            (int) substr($context['effective_birth_time'], 0, 2), (int) substr($context['effective_birth_time'], 3, 2), 0)
            ->getLunar()->getEightChar()->toString();
        $this->assertSame($expected, $result['bazi']);
        $this->assertContains('canonical_source:lunar_php', $result['notes']);
    }

    public function test_repeated_unknown_time_stays_low_confidence_until_explicit_time_replaces_provenance(): void
    {
        $tag = static fn (array $notes, string $prefix): array => array_values(array_filter(
            $notes, fn ($note) => str_starts_with($note, $prefix),
        ));
        for ($save = 0; $save < 2; $save++) {
            $this->postJson('/api/v1/profile/basic', $this->basic())->assertOk();
            $profile = UserAstroProfile::where('user_id', $this->user->id)->firstOrFail();
            $this->assertSame('12:00', $profile->birth_time);
            $this->assertSame(['birth_time_input_source:default_noon_unknown'], $tag($profile->notes, 'birth_time_input_source:'));
            $confidence = $tag($profile->notes, 'canonical_confidence:');
            $this->assertCount(1, $confidence);
            $this->assertLessThanOrEqual(0.35, (float) substr($confidence[0], strlen('canonical_confidence:')));
        }
        $this->postJson('/api/v1/profile/basic', $this->basic(['birth_time' => '14:30']))->assertOk();
        $profile = UserAstroProfile::where('user_id', $this->user->id)->firstOrFail();
        $this->assertSame('14:30', $profile->birth_time);
        $this->assertSame(['birth_time_input_source:user_input'], $tag($profile->notes, 'birth_time_input_source:'));
        $confidence = $tag($profile->notes, 'canonical_confidence:');
        $this->assertCount(1, $confidence);
        $this->assertGreaterThan(0.35, (float) substr($confidence[0], strlen('canonical_confidence:')));
        $this->assertNotContains('birth_time_input_source:default_noon_unknown', $profile->notes);
        $this->assertSame('己巳 壬申 戊辰 己未', $profile->bazi);
    }
}
