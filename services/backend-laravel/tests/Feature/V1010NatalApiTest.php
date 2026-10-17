<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\NatalCalculationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class V1010NatalApiTest extends TestCase
{
    use RefreshDatabase;

    private function payload(int $revision = 0): array
    {
        return ['input' => ['civil_date' => '2000-01-01', 'civil_time' => '12:00',
            'time_precision' => 'minute', 'timezone' => 'Europe/London',
            'latitude' => 51.5, 'longitude' => 0.0, 'algorithm_sex' => 'unknown'],
            'settings' => [], 'expected_revision' => $revision];
    }

    private function stubCalculator(): void
    {
        // Contract-only double: this is not algorithm/oracle or real-chain evidence.
        $this->mock(NatalCalculationService::class, function ($mock) {
            $mock->shouldReceive('compute')->andReturn(['bazi' => ['status' => 'UNKNOWN'],
                'ziwei' => ['status' => 'UNKNOWN'], 'western' => ['oracle_status' => 'UNVERIFIED']]);
        });
    }

    private function owner(): User
    {
        static $number = 1;
        return User::create(['phone' => '1991010'.str_pad((string) $number++, 4, '0', STR_PAD_LEFT),
            'password' => 'synthetic-test-only', 'birthday' => '2000-01-01']);
    }

    public function test_natal_requires_identity_and_is_private_to_current_user(): void
    {
        $this->getJson('/api/v1/profile/natal')->assertUnauthorized();
        Sanctum::actingAs($this->owner());
        $this->stubCalculator();
        $this->postJson('/api/v1/profile/natal', $this->payload())->assertOk()
            ->assertJsonPath('profile.input_revision', 1)->assertJsonPath('profile.result_revision', 1);
        foreach (['summary', 'chart'] as $view) {
            $this->getJson('/api/v1/profile/astro/'.$view)->assertOk()
                ->assertJsonPath('profile.source', 'private_calculation_mirror')
                ->assertJsonPath('profile.natal.input_revision', 1)
                ->assertHeader('Cache-Control', 'no-store, private');
        }
        Sanctum::actingAs($this->owner());
        $this->getJson('/api/v1/profile/natal')->assertOk()->assertJsonPath('exists', false);
    }

    public function test_stale_edit_cannot_overwrite_and_repeated_input_reuses_result(): void
    {
        Sanctum::actingAs($this->owner());
        $this->stubCalculator();
        $first = $this->postJson('/api/v1/profile/natal', $this->payload())->assertOk();
        $signature = $first->json('profile.input_signature');
        $this->postJson('/api/v1/profile/natal', $this->payload(0))->assertStatus(409);
        $this->postJson('/api/v1/profile/natal', $this->payload(1))->assertOk()
            ->assertJsonPath('profile.input_revision', 1)->assertJsonPath('profile.input_signature', $signature);
        $changed = $this->payload(1);
        $changed['input']['civil_time'] = '12:01';
        $response = $this->postJson('/api/v1/profile/natal', $changed)->assertOk()
            ->assertJsonPath('profile.input_revision', 2)->assertJsonPath('profile.result_revision', 2);
        $this->assertNotSame($signature, $response->json('profile.input_signature'));
        $this->getJson('/api/v1/profile/natal')->assertJsonPath('profile.context.civil_time', '12:01');
    }

    public function test_gap_and_unadmitted_options_do_not_write_a_result(): void
    {
        Sanctum::actingAs($this->owner());
        $payload = $this->payload();
        $payload['input'] = array_replace($payload['input'], ['civil_date' => '2024-03-10',
            'civil_time' => '02:30', 'timezone' => 'America/New_York']);
        $this->postJson('/api/v1/profile/natal', $payload)->assertUnprocessable();
        $payload = $this->payload();
        $payload['settings']['house_system'] = 'koch';
        $this->postJson('/api/v1/profile/natal', $payload)->assertUnprocessable();
        $this->assertDatabaseCount('user_natal_profiles', 0);
    }

    public function test_calculator_failure_is_not_a_cached_success(): void
    {
        Sanctum::actingAs($this->owner());
        $this->mock(NatalCalculationService::class, function ($mock) {
            $mock->shouldReceive('compute')->andThrow(new \RuntimeException('internal paths must not be exposed'));
        });
        $this->postJson('/api/v1/profile/natal', $this->payload())->assertStatus(503)
            ->assertJsonPath('code', 'natal_calculation_unavailable');
        $this->getJson('/api/v1/profile/natal')->assertOk()->assertJsonPath('profile.status', 'FAILED')
            ->assertJsonPath('profile.results', null)->assertJsonPath('profile.result_revision', null);
    }

    public function test_superseded_inflight_result_is_not_stored(): void
    {
        Sanctum::actingAs($this->owner());
        $this->mock(NatalCalculationService::class, function ($mock) {
            $mock->shouldReceive('compute')->andReturnUsing(function () {
                \App\Models\UserNatalProfile::query()->update(['input_revision' => 2,
                    'status' => 'COMPUTING', 'results' => null, 'result_revision' => null]);
                return ['old_result' => true];
            });
        });
        $this->postJson('/api/v1/profile/natal', $this->payload())->assertStatus(409);
        $this->assertDatabaseHas('user_natal_profiles', ['input_revision' => 2, 'results' => null,
            'result_revision' => null]);
    }

    public function test_disabled_owner_cannot_read_or_recompute_private_chart(): void
    {
        $owner = $this->owner();
        $owner->forceFill(['disabled' => true])->save();
        Sanctum::actingAs($owner);
        $this->getJson('/api/v1/profile/natal')->assertForbidden();
        $this->postJson('/api/v1/profile/natal', $this->payload())->assertForbidden();
        $this->assertDatabaseCount('user_natal_profiles', 0);
    }
}
