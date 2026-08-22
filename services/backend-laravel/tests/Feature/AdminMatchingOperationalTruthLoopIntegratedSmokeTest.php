<?php

namespace Tests\Feature;

use App\Models\DatingRound;
use App\Models\MatchingRun;
use App\Models\User;
use App\Services\C2LocalMatchScenarioService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminMatchingOperationalTruthLoopIntegratedSmokeTest extends TestCase
{
    use RefreshDatabase;

    public function test_disposable_admin_operation_truth_recovery_and_audit_loop(): void
    {
        config()->set('matching.c2.local_integration_enabled', true);
        config()->set('matching.c2.local_password', 'r4-disposable-only');
        config()->set('matching.foundation.admin_operations_enabled', true);
        config()->set('matching.c2.manual_consumer_configured', true);
        config()->set('app.admin_phones', [C2LocalMatchScenarioService::ADMIN_PHONE]);

        app(C2LocalMatchScenarioService::class)->build('preparing');
        $round = DatingRound::query()->latest('id')->firstOrFail();
        $ordinary = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
        $admin = User::query()->where('phone', C2LocalMatchScenarioService::ADMIN_PHONE)->firstOrFail();

        Sanctum::actingAs($ordinary);
        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', [
            'state_version' => $round->state_version,
            'reason_code' => 'r4_disposable_smoke',
        ], ['Idempotency-Key' => 'r4-smoke-execute'])->assertForbidden();

        Sanctum::actingAs($admin);
        $before = $this->getJson('/api/v1/admin/matching/rounds')->assertOk()
            ->assertJsonPath('data.0.operation_capabilities.execute', true)
            ->assertJsonPath('data.0.operation_capabilities.compensation', false);
        $version = $before->json('data.0.state_version');
        $payload = ['state_version' => $version, 'reason_code' => 'r4_disposable_smoke'];
        $headers = ['Idempotency-Key' => 'r4-smoke-execute'];

        $accepted = $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', $payload, $headers)
            ->assertStatus(202)->assertJsonPath('meta.background_started', false);
        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', $payload, $headers)
            ->assertStatus(202)->assertJsonPath('meta.idempotent_replay', true)
            ->assertJsonPath('data.id', $accepted->json('data.id'));
        $this->assertSame(1, MatchingRun::query()->where('round_id', $round->id)->count());

        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', $payload, [
            'Idempotency-Key' => 'r4-smoke-stale',
        ])->assertConflict()->assertJsonPath('current_state_version', $version + 1);

        $this->getJson('/api/v1/admin/matching/rounds')->assertOk()
            ->assertJsonPath('data.0.state_version', $version + 1)
            ->assertJsonPath('data.0.active_run.state', 'pending')
            ->assertJsonPath('data.0.operation_capabilities.execute', false);
        $detail = $this->getJson('/api/v1/admin/matching/rounds/'.$round->round_key)->assertOk()
            ->assertJsonPath('audits.1.action', 'execute')
            ->assertJsonPath('audits.1.actor_id', $admin->id)
            ->assertJsonPath('audits.1.reason_code', 'r4_disposable_smoke')
            ->assertJsonMissingPath('audits.1.idempotency_key')
            ->assertJsonMissingPath('audits.1.correlation_id')
            ->assertJsonMissingPath('audits.1.aggregate_summary');
        $this->assertSame(['action', 'actor_type', 'actor_id', 'reason_code', 'before_state', 'after_state', 'created_at'], array_keys($detail->json('audits.1')));

        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/compensation')
            ->assertForbidden()->assertJsonPath('message', 'compensation is not authorized');
    }
}
