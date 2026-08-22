<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\DatingRound;
use App\Models\DatingRoundChannel;
use App\Models\DatingRoundUserState;
use App\Models\MatchingRun;
use App\Models\MatchingOperationAudit;
use App\Models\User;
use App\Services\C2LocalMatchScenarioService;
use App\Services\MatchingRoundService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class C2LocalRuntimeIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config()->set('matching.c2.local_integration_enabled', true);
        config()->set('matching.c2.local_password', 'local-test-password');
        config()->set('matching.foundation.read_contract_enabled', true);
        config()->set('matching.foundation.admin_operations_enabled', true);
        config()->set('matching.foundation.digest_key', 'c2-test-digest');
    }

    public function test_harness_refuses_when_flag_is_off(): void
    {
        config()->set('matching.c2.local_integration_enabled', false);
        $this->expectException(\RuntimeException::class);
        app(C2LocalMatchScenarioService::class)->build('no_round');
    }

    public function test_real_api_returns_every_guarded_synthetic_scenario(): void
    {
        $service = app(C2LocalMatchScenarioService::class);
        foreach (['no_round', 'preparing', 'waiting', 'revealed', 'no_candidate', 'failed', 'closed'] as $scenario) {
            $summary = $service->build($scenario);
            $this->assertTrue($summary['synthetic_only']);
            $user = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
            Sanctum::actingAs($user);
            $expectedPublicState = $scenario === 'waiting' ? 'scheduled' : $scenario;
            $response = $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.state', $expectedPublicState);
            if ($scenario === 'waiting') {
                $response->assertJsonPath('data.reveal_at', fn ($value) => is_string($value) && $value !== '');
            }
            if ($scenario === 'revealed') {
                $response->assertJsonPath('data.conversation_capability.can_create', true)
                    ->assertJsonPath('data.result.partner_id', fn ($value) => is_int($value) && $value > 0)
                    ->assertJsonMissingPath('data.result.score');
            }
            if ($scenario === 'failed') {
                $response->assertJsonPath('data.reason_code', 'temporary_failure');
            }
        }

        $service->build('revealed');
        $user = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
        $admin = User::query()->where('phone', C2LocalMatchScenarioService::ADMIN_PHONE)->firstOrFail();
        DatingMatch::query()->latest('id')->firstOrFail()->forceFill(['user_a' => $admin->id])->save();
        Sanctum::actingAs($user);
        $this->getJson('/api/v1/match-rounds/current')->assertOk()
            ->assertJsonPath('data.state', 'no_candidate')
            ->assertJsonPath('data.result', null)
            ->assertJsonPath('data.conversation_capability', null);

        $service->build('revealed');
        $user = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
        DatingRoundUserState::query()->where('user_id', $user->id)->latest('id')->firstOrFail()->forceFill(['dating_match_id' => null])->save();
        Sanctum::actingAs($user);
        $this->getJson('/api/v1/match-rounds/current')->assertOk()
            ->assertJsonPath('data.state', 'no_candidate')
            ->assertJsonPath('data.result', null)
            ->assertJsonPath('data.conversation_capability', null);
    }

    public function test_scenario_reset_preserves_unrelated_channel_and_actor_identity(): void
    {
        $service = app(C2LocalMatchScenarioService::class);
        $service->build('no_round');
        $actorId = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->value('id');
        $sentinel = app(MatchingRoundService::class)->prepare('unrelated-local', 'sentinel', null, null, 'system', null, 'unrelated');

        $service->build('waiting');

        $this->assertSame($actorId, User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->value('id'));
        $this->assertSame($sentinel->id, DatingRoundChannel::query()->whereKey('unrelated-local')->value('active_round_id'));
    }

    public function test_admin_request_replay_stale_retry_reveal_and_close_contract(): void
    {
        $service = app(C2LocalMatchScenarioService::class);
        config()->set('app.admin_phones', [C2LocalMatchScenarioService::ADMIN_PHONE]);
        config()->set('matching.c2.manual_consumer_configured', true);

        $service->build('preparing');
        $admin = User::query()->where('phone', C2LocalMatchScenarioService::ADMIN_PHONE)->firstOrFail();
        Sanctum::actingAs($admin);
        $round = DatingRound::query()->latest('id')->firstOrFail();
        $this->getJson('/api/v1/admin/matching/rounds')->assertOk()
            ->assertJsonPath('data.0.operation_capabilities.execute', true)
            ->assertJsonPath('data.0.operation_capabilities.compensation', false)
            ->assertJsonPath('meta.consumer_configured', true);
        $headers = ['Idempotency-Key' => 'c2-execute-replay'];
        $payload = ['state_version' => $round->state_version, 'reason_code' => 'c2_test'];
        $first = $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', $payload, $headers)->assertStatus(202);
        $second = $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', $payload, $headers)->assertStatus(202)->assertJsonPath('meta.idempotent_replay', true);
        $this->assertSame($first->json('data.id'), $second->json('data.id'));
        $this->assertSame(1, MatchingRun::query()->where('round_id', $round->id)->count());
        $this->getJson('/api/v1/admin/matching/rounds')->assertOk()
            ->assertJsonPath('data.0.operation_capabilities.execute', false);
        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', ['state_version' => 1, 'reason_code' => 'stale'], ['Idempotency-Key' => 'c2-stale'])->assertConflict();

        $service->build('failed');
        $failed = DatingRound::query()->latest('id')->firstOrFail();
        $this->postJson('/api/v1/admin/matching/rounds/'.$failed->round_key.'/retry', ['state_version' => $failed->state_version, 'reason_code' => 'retry_local'], ['Idempotency-Key' => 'c2-retry'])->assertCreated();
        $this->postJson('/api/v1/admin/matching/rounds/'.$failed->round_key.'/execution-requests', ['state_version' => $failed->state_version, 'reason_code' => 'wrong_action'], ['Idempotency-Key' => 'c2-retry'])
            ->assertConflict()->assertJsonPath('message', 'idempotency key already used for another operation');

        $service->build('waiting');
        $waiting = DatingRound::query()->latest('id')->firstOrFail();
        $this->travel(31)->minutes();
        $revealPayload = ['state_version' => $waiting->state_version, 'reason_code' => 'reveal_local'];
        $revealHeaders = ['Idempotency-Key' => 'c2-reveal', 'X-Matching-Confirmation' => 'confirm:'.$waiting->round_key.':reveal'];
        $this->postJson('/api/v1/admin/matching/rounds/'.$waiting->round_key.'/reveal', $revealPayload, $revealHeaders)->assertOk()->assertJsonPath('data.state', 'revealed');
        $this->postJson('/api/v1/admin/matching/rounds/'.$waiting->round_key.'/reveal', $revealPayload, $revealHeaders)->assertOk()->assertJsonPath('meta.idempotent_replay', true)->assertJsonPath('data.state', 'revealed');
        $revealed = $waiting->fresh();
        $closePayload = ['state_version' => $revealed->state_version, 'reason_code' => 'close_local'];
        $closeHeaders = ['Idempotency-Key' => 'c2-close', 'X-Matching-Confirmation' => 'confirm:'.$revealed->round_key.':close'];
        $this->postJson('/api/v1/admin/matching/rounds/'.$revealed->round_key.'/close', $closePayload, $closeHeaders)->assertOk()->assertJsonPath('data.state', 'closed');
        $this->postJson('/api/v1/admin/matching/rounds/'.$revealed->round_key.'/close', $closePayload, $closeHeaders)->assertOk()->assertJsonPath('meta.idempotent_replay', true)->assertJsonPath('data.state', 'closed');

        $detail = $this->getJson('/api/v1/admin/matching/rounds/'.$revealed->round_key)->assertOk()
            ->assertJsonMissingPath('audits.0.idempotency_key')
            ->assertJsonMissingPath('audits.0.correlation_id')
            ->assertJsonMissingPath('audits.0.role_snapshot')
            ->assertJsonMissingPath('audits.0.aggregate_summary');
        $this->assertNotEmpty($detail->json('audits'));
    }

    public function test_no_consumer_is_truthful_unavailable(): void
    {
        app(C2LocalMatchScenarioService::class)->build('preparing');
        config()->set('app.admin_phones', [C2LocalMatchScenarioService::ADMIN_PHONE]);
        config()->set('matching.c2.manual_consumer_configured', false);
        $admin = User::query()->where('phone', C2LocalMatchScenarioService::ADMIN_PHONE)->firstOrFail();
        Sanctum::actingAs($admin);
        $round = DatingRound::query()->latest('id')->firstOrFail();
        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/execution-requests', ['state_version' => $round->state_version, 'reason_code' => 'local'], ['Idempotency-Key' => 'c2-disabled'])
            ->assertStatus(503)->assertJsonPath('error_code', 'manual_consumer_not_configured')->assertJsonPath('retry_safe', true);
        $this->assertSame(0, MatchingOperationAudit::query()->where('round_id', $round->id)->where('action', 'execute')->count());
    }

    public function test_non_admin_is_denied_and_compensation_stays_unavailable(): void
    {
        app(C2LocalMatchScenarioService::class)->build('preparing');
        config()->set('app.admin_phones', [C2LocalMatchScenarioService::ADMIN_PHONE]);
        $round = DatingRound::query()->latest('id')->firstOrFail();
        $ordinary = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
        Sanctum::actingAs($ordinary);
        $this->getJson('/api/v1/admin/matching/rounds')->assertForbidden();
        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/compensation')->assertForbidden();

        $admin = User::query()->where('phone', C2LocalMatchScenarioService::ADMIN_PHONE)->firstOrFail();
        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/admin/matching/rounds/'.$round->round_key.'/compensation')
            ->assertForbidden()->assertJsonPath('message', 'compensation is not authorized');
    }
}
