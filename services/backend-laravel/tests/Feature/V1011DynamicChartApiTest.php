<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserDynamicChart;
use App\Services\DynamicChartService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class V1011DynamicChartApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['dynamic_charts.enabled' => true]);
    }

    private function owner(): User
    {
        static $number = 1;
        return User::create(['phone' => '1991011'.str_pad((string) $number++, 4, '0', STR_PAD_LEFT),
            'password' => 'synthetic-test-only', 'birthday' => '2000-01-01']);
    }

    private function payload(int $revision = 0): array
    {
        $source = ['source' => 'manual', 'input' => ['civil_date' => '2000-01-01',
            'civil_time' => '12:00', 'time_precision' => 'minute', 'timezone' => 'Europe/London',
            'latitude' => 51.5, 'longitude' => 0.0]];
        return ['chart_type' => 'synastry', 'first' => $source, 'second' => $source,
            'settings' => [], 'expected_revision' => $revision];
    }

    private function calculator(?callable $callback = null): void
    {
        // API contract double only, never algorithm or real-chain evidence.
        $this->partialMock(DynamicChartService::class, function ($mock) use ($callback) {
            $call = $mock->shouldReceive('compute');
            if ($callback) {
                $call->andReturnUsing($callback);
            } else {
                $call->andReturn(['status' => 'CALCULATED', 'oracle_status' => 'UNVERIFIED']);
            }
        });
    }

    public function test_records_are_owner_filtered_and_multiple_records_are_allowed(): void
    {
        $this->getJson('/api/v1/profile/dynamic')->assertUnauthorized();
        Sanctum::actingAs($this->owner());
        $this->calculator();
        $id = $this->postJson('/api/v1/profile/dynamic', $this->payload())->assertOk()
            ->assertJsonPath('chart.result_revision', 1)->json('chart.id');
        $this->postJson('/api/v1/profile/dynamic', $this->payload())->assertOk();
        $this->getJson('/api/v1/profile/dynamic')->assertJsonCount(2, 'charts')
            ->assertHeader('Cache-Control', 'no-store, private');
        Sanctum::actingAs($this->owner());
        $this->getJson('/api/v1/profile/dynamic/'.$id)->assertNotFound()
            ->assertHeader('Cache-Control', 'no-store, private');
        $this->postJson('/api/v1/profile/dynamic/'.$id, $this->payload(1))->assertNotFound();
        $this->getJson('/api/v1/profile/dynamic')->assertJsonCount(0, 'charts');
    }

    public function test_unknown_identity_fields_and_unowned_natal_source_are_rejected(): void
    {
        Sanctum::actingAs($this->owner());
        $this->postJson('/api/v1/profile/dynamic', [...$this->payload(), 'peer_id' => 2])
            ->assertUnprocessable()->assertHeader('Cache-Control', 'no-store, private');
        $body = $this->payload();
        $body['second'] = ['source' => 'own_natal', 'revision' => 1];
        $this->postJson('/api/v1/profile/dynamic', $body)->assertUnprocessable();
        $body = $this->payload();
        $body['settings'] = ['target_year' => null];
        $this->postJson('/api/v1/profile/dynamic', $body)->assertUnprocessable();
        $this->assertDatabaseCount('user_dynamic_charts', 0);
    }

    public function test_cas_cache_and_input_change_have_separate_generations(): void
    {
        Sanctum::actingAs($this->owner());
        $this->calculator();
        $first = $this->postJson('/api/v1/profile/dynamic', $this->payload())->assertOk();
        $id = $first->json('chart.id');
        $this->postJson('/api/v1/profile/dynamic/'.$id, $this->payload())->assertStatus(409);
        $this->postJson('/api/v1/profile/dynamic/'.$id, $this->payload(1))->assertOk()
            ->assertJsonPath('chart.input_revision', 1);
        $changed = $this->payload(1);
        $changed['second']['input']['civil_time'] = '12:01';
        $this->postJson('/api/v1/profile/dynamic/'.$id, $changed)->assertOk()
            ->assertJsonPath('chart.input_revision', 2)->assertJsonPath('chart.result_revision', 2);
    }

    public function test_failure_and_superseded_result_never_become_cached_success(): void
    {
        Sanctum::actingAs($this->owner());
        $this->calculator(function () { throw new \RuntimeException('private stderr'); });
        $this->postJson('/api/v1/profile/dynamic', $this->payload())->assertStatus(503)
            ->assertJsonPath('code', 'dynamic_calculation_unavailable');
        $this->assertDatabaseHas('user_dynamic_charts', ['status' => 'FAILED', 'results' => null]);
    }

    public function test_runtime_change_and_disabled_owner_during_compute_reject_old_results(): void
    {
        $owner = $this->owner();
        Sanctum::actingAs($owner);
        $this->calculator(function () use ($owner) {
            User::whereKey($owner->id)->update(['disabled' => true]);
            return ['status' => 'CALCULATED'];
        });
        $this->postJson('/api/v1/profile/dynamic', $this->payload())->assertForbidden();
        $this->assertDatabaseHas('user_dynamic_charts', ['results' => null, 'result_revision' => null]);
    }

    public function test_late_result_cannot_replace_new_generation(): void
    {
        Sanctum::actingAs($this->owner());
        $this->calculator(function () {
            UserDynamicChart::query()->update(['input_revision' => 2, 'status' => 'COMPUTING']);
            return ['status' => 'CALCULATED'];
        });
        $this->postJson('/api/v1/profile/dynamic', $this->payload())->assertStatus(409);
        $this->assertDatabaseHas('user_dynamic_charts', ['input_revision' => 2, 'results' => null]);
    }

    public function test_event_edit_reuses_trusted_first_chart_and_selection_does_not_recompute(): void
    {
        Sanctum::actingAs($this->owner());
        $calls = 0;
        $this->calculator(function ($prepared) use (&$calls) {
            $calls++;
            if ($calls === 2) {
                $this->assertSame(['cache_marker' => 'trusted'], $prepared['payload']['first_calculated']);
            }
            return ['status' => 'CALCULATED', 'first' => ['cache_marker' => 'trusted'],
                'events' => [['utc' => '2025-01-01T00:00:00Z'], ['utc' => '2025-02-01T00:00:00Z']]];
        });
        $body = $this->payload();
        unset($body['second']);
        $body['chart_type'] = 'solar_return';
        $body['event'] = ['year' => 2025, 'timezone' => 'Europe/London', 'latitude' => 51.5, 'longitude' => 0.0];
        $id = $this->postJson('/api/v1/profile/dynamic', $body)->assertOk()->json('chart.id');
        $body['expected_revision'] = 1;
        $body['selected_event_index'] = 1;
        $this->postJson('/api/v1/profile/dynamic/'.$id, $body)->assertOk()
            ->assertJsonPath('chart.selected_event_index', 1)->assertJsonPath('chart.input_revision', 2);
        $this->assertSame(1, $calls);
        $this->postJson('/api/v1/profile/dynamic/'.$id, $body)->assertStatus(409);
        $body['expected_revision'] = 2;
        $body['event']['year'] = 2026;
        $this->postJson('/api/v1/profile/dynamic/'.$id, $body)->assertOk()
            ->assertJsonPath('chart.input_revision', 3);
        $this->assertSame(2, $calls);
        $body['expected_revision'] = 3;
        $body['selected_event_index'] = 9;
        $this->postJson('/api/v1/profile/dynamic/'.$id, $body)->assertUnprocessable();
        $this->assertSame(2, $calls);
    }

    public function test_civil_gap_and_forged_cache_are_rejected_before_persistence(): void
    {
        Sanctum::actingAs($this->owner());
        $body = $this->payload();
        $body['first']['input'] = array_replace($body['first']['input'], [
            'civil_date' => '2024-03-10', 'civil_time' => '02:30', 'timezone' => 'America/New_York']);
        $this->postJson('/api/v1/profile/dynamic', $body)->assertUnprocessable();
        $this->postJson('/api/v1/profile/dynamic', [...$this->payload(), 'first_calculated' => ['fake' => true]])
            ->assertUnprocessable();
        $this->assertDatabaseCount('user_dynamic_charts', 0);
    }

    public function test_history_is_bounded_and_never_probes_or_returns_private_results(): void
    {
        $owner = $this->owner();
        Sanctum::actingAs($owner);
        $this->mock(DynamicChartService::class, function ($mock) {
            $mock->shouldNotReceive('prepare');
            $mock->shouldNotReceive('view');
        });
        for ($i = 0; $i < 23; $i++) {
            UserDynamicChart::create(['user_id' => $owner->id, 'chart_type' => 'transit',
                'request' => ['private_input' => 'not_in_list'], 'settings' => [], 'prepared' => [],
                'input_signature' => str_repeat('a', 64), 'input_revision' => 1,
                'status' => 'COMPUTED_UNVERIFIED', 'results' => ['private' => 'not_in_list']]);
        }
        $first = $this->getJson('/api/v1/profile/dynamic')->assertOk()->assertJsonCount(20, 'charts');
        $this->assertArrayNotHasKey('results', $first->json('charts.0'));
        $this->assertArrayNotHasKey('request', $first->json('charts.0'));
        $this->assertSame('DETAIL_REVALIDATION_REQUIRED', $first->json('charts.0.status'));
        $cursor = $first->json('next_before_id');
        $this->getJson('/api/v1/profile/dynamic?before_id='.$cursor)->assertOk()
            ->assertJsonCount(3, 'charts')->assertJsonPath('next_before_id', null);
        $this->getJson('/api/v1/profile/dynamic?before_id=bad')->assertUnprocessable();
    }
}
