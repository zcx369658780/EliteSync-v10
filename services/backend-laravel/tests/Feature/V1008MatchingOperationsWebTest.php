<?php

namespace Tests\Feature;

use App\Jobs\ExecuteMatchingRun;
use App\Models\DatingRound;
use App\Models\MatchingRun;
use App\Models\User;
use App\Services\MatchingRoundService;
use App\Services\MatchingRunService;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery as ValidateCsrfToken;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1008MatchingOperationsWebTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    private const CSRF = 'v1008-matching-csrf-fixture';

    protected function setUp(): void
    {
        parent::setUp();
        config(['matching.foundation.admin_operations_enabled' => true,
            'matching.c2.manual_consumer_configured' => true]);
        $this->admin = User::factory()->create(['phone' => '19900000891', 'role' => 'admin',
            'disabled' => false, 'is_synthetic' => false, 'verify_status' => 'approved']);
        config(['app.admin_phones' => [$this->admin->phone]]);
        $this->app->bind(ValidateCsrfToken::class,
            fn ($app) => new EnforcedV1008MatchingCsrf($app, $app['encrypter']));
        Queue::fake([ExecuteMatchingRun::class]);
    }

    public function test_web_requires_csrf_and_expected_version_before_any_business_audit_or_queue_write(): void
    {
        $round = $this->prepare();
        $before = $this->snapshot();
        $this->actingAs($this->admin, 'web')->withSession(['_token' => self::CSRF]);
        $this->post('/admin/matching', $this->webPayload($round, ['_token' => null]))->assertStatus(419);
        $this->assertSame($before, $this->snapshot());
        $this->post('/admin/matching', $this->webPayload($round, ['state_version' => 0]))->assertStatus(409);
        $this->assertSame($before, $this->snapshot());
        Queue::assertNothingPushed();
    }

    public function test_second_execution_with_new_key_and_current_version_cannot_supersede_pending_run(): void
    {
        $round = $this->prepare();
        Sanctum::actingAs($this->admin);
        $this->postJson($this->apiPath($round, 'execution-requests'), [
            'state_version' => $round->state_version, 'reason_code' => 'first',
        ], ['Idempotency-Key' => 'first-current-run'])->assertAccepted();
        $before = $this->snapshot();
        $round->refresh();
        $this->postJson($this->apiPath($round, 'execution-requests'), [
            'state_version' => $round->state_version, 'reason_code' => 'second',
        ], ['Idempotency-Key' => 'different-current-run'])->assertConflict()
            ->assertJsonPath('error.message', 'execution_already_requested_use_retry');
        $this->assertSame($before, $this->snapshot());
        Queue::assertPushed(ExecuteMatchingRun::class, 1);
    }

    public function test_web_prepare_and_execution_replay_show_pending_without_manufacturing_completion(): void
    {
        $this->actingAs($this->admin, 'web')->withSession(['_token' => self::CSRF]);
        $this->post('/admin/matching', [
            '_token' => self::CSRF, 'operation' => 'prepare', 'channel_key' => 'v1008',
            'cadence_key' => 'web-fixture', 'state_version' => 1, 'reveal_at' => now()->addHour()->toIso8601String(),
            'idempotency_key' => 'web-prepare-fixture', 'confirm' => true, 'reason_code' => 'fixture',
        ])->assertRedirect(route('admin.matching'));
        $round = DatingRound::sole();
        $payload = $this->webPayload($round);
        $this->post('/admin/matching', $payload)->assertRedirect(route('admin.matching'));
        $this->post('/admin/matching', $payload)->assertRedirect(route('admin.matching'));
        $this->assertDatabaseCount('matching_runs', 1);
        $run = MatchingRun::sole();
        $this->assertSame('pending', $run->state->value);
        $this->assertNull($run->finished_at);
        $this->assertDatabaseCount('dating_matches', 0);
        Queue::assertPushed(ExecuteMatchingRun::class, fn ($job) => $job->runId === $run->id);
        Queue::assertPushed(ExecuteMatchingRun::class, 1);
        $this->get('/admin/matching')->assertOk()->assertSee('pending')
            ->assertSee('只有run为succeeded才代表consumer已完成');
    }

    public function test_web_and_api_recheck_current_admin_after_the_authenticated_object_is_demoted(): void
    {
        $round = $this->prepare();
        $before = $this->snapshot();
        $this->actingAs($this->admin, 'web')->withSession(['_token' => self::CSRF]);
        Sanctum::actingAs($this->admin);
        // Preserve the authenticated object's old role; the database is authoritative.
        DB::table('users')->where('id', $this->admin->id)->update(['role' => 'user']);
        $this->assertSame('admin', $this->admin->role);
        $this->post('/admin/matching', $this->webPayload($round))->assertForbidden();
        $this->postJson($this->apiPath($round, 'execution-requests'), [
            'state_version' => $round->state_version, 'reason_code' => 'fixture',
        ], ['Idempotency-Key' => 'demoted-api-fixture'])->assertForbidden();
        $this->assertSame($before, $this->snapshot());
        Queue::assertNothingPushed();
    }

    public function test_api_requires_a_current_expected_version_and_idempotency_key_without_side_effects(): void
    {
        $round = $this->prepare();
        Sanctum::actingAs($this->admin);
        $before = $this->snapshot();
        $this->postJson($this->apiPath($round, 'execution-requests'), [
            'state_version' => $round->state_version, 'reason_code' => 'fixture',
        ])->assertUnprocessable()->assertJsonPath('error.message', 'valid Idempotency-Key header is required');
        $this->assertSame($before, $this->snapshot());
        $this->postJson($this->apiPath($round, 'execution-requests'), [
            'state_version' => 0, 'reason_code' => 'fixture',
        ], ['Idempotency-Key' => 'stale-version-fixture'])->assertStatus(409)
            ->assertJsonPath('error.message', 'stale state version');
        $this->assertSame($before, $this->snapshot());
        Queue::assertNothingPushed();
    }

    public function test_api_retry_fences_only_expired_running_attempt_and_replay_dispatches_once(): void
    {
        $old = $this->running(true);
        $round = $old->round()->firstOrFail();
        $oldFence = (int) $old->fencing_token;
        Sanctum::actingAs($this->admin);
        $payload = ['state_version' => $round->state_version, 'reason_code' => 'expired_fixture'];
        $headers = ['Idempotency-Key' => 'expired-retry-fixture'];
        $first = $this->postJson($this->apiPath($round, 'retry'), $payload, $headers)->assertCreated()
            ->assertJsonPath('data.state', 'pending')->assertJsonPath('data.attempt_no', 2)
            ->assertJsonPath('data.supersedes_run_id', $old->id);
        $newId = $first->json('data.id');
        $this->assertDatabaseHas('matching_runs', ['id' => $old->id, 'state' => 'failed',
            'error_code' => 'lease_expired', 'fencing_token' => $oldFence + 1]);
        $this->assertDatabaseHas('dating_rounds', ['id' => $round->id, 'active_run_id' => $newId, 'state' => 'preparing']);
        $this->assertDatabaseHas('matching_operation_audits', ['matching_run_id' => $newId,
            'action' => 'retry', 'idempotency_key' => 'expired-retry-fixture']);
        $this->postJson($this->apiPath($round, 'retry'), $payload, $headers)->assertCreated()
            ->assertJsonPath('data.id', $newId)->assertJsonPath('meta.idempotent_replay', true);
        $this->assertDatabaseCount('matching_runs', 2);
        $this->assertDatabaseCount('dating_matches', 0);
        Queue::assertPushed(ExecuteMatchingRun::class, fn ($job) => $job->runId === $newId);
        Queue::assertPushed(ExecuteMatchingRun::class, 1);
    }

    public function test_unexpired_running_retry_is_rejected_on_web_and_api_without_half_writes(): void
    {
        $run = $this->running(false);
        $round = $run->round()->firstOrFail();
        $before = $this->snapshot();
        $this->actingAs($this->admin, 'web')->withSession(['_token' => self::CSRF]);
        $this->post('/admin/matching', $this->webPayload($round, ['operation' => 'retry']))
            ->assertStatus(409);
        $this->assertSame($before, $this->snapshot());
        Sanctum::actingAs($this->admin);
        $this->postJson($this->apiPath($round, 'retry'), [
            'state_version' => $round->state_version, 'reason_code' => 'lease_still_active',
        ], ['Idempotency-Key' => 'unexpired-retry-fixture'])->assertStatus(409)
            ->assertJsonPath('error.message', 'run_lease_not_expired');
        $this->assertSame($before, $this->snapshot());
        Queue::assertNothingPushed();
    }

    public function test_rendered_retry_conflict_rolls_back_prior_expiry_fence_and_audit_changes(): void
    {
        $old = $this->running(true);
        $round = $old->round()->firstOrFail();
        $other = app(MatchingRoundService::class)->prepare('other-v1008', 'other-fixture', null, now()->addHour(), 'test', null);
        app(MatchingRunService::class)->request($other, 'cross-round-retry-fixture', 'test', null);
        $before = $this->snapshot();
        Sanctum::actingAs($this->admin);
        DB::enableQueryLog();
        $this->postJson($this->apiPath($round, 'retry'), [
            'state_version' => $round->state_version, 'reason_code' => 'rollback_fixture',
        ], ['Idempotency-Key' => 'cross-round-retry-fixture'])->assertStatus(409)
            ->assertJsonPath('error.code', 'matching_conflict')
            ->assertJsonPath('error.message', 'idempotency_key_conflict');
        $queries = DB::getQueryLog();
        DB::disableQueryLog();
        $expiryWasAttempted = false;
        foreach ($queries as $query) {
            if (str_starts_with(strtolower($query['query']), 'update "matching_runs"')
                && in_array('lease_expired', $query['bindings'], true)) {
                $expiryWasAttempted = true;
            }
        }
        $this->assertTrue($expiryWasAttempted, 'The regression must exercise a rendered failure after expiry writes, not an early rejection.');
        $this->assertSame($before, $this->snapshot());
        $this->assertDatabaseHas('matching_runs', ['id' => $old->id, 'state' => 'running',
            'fencing_token' => $old->fencing_token, 'error_code' => null]);
        $this->assertDatabaseHas('dating_rounds', ['id' => $round->id, 'state' => 'preparing',
            'active_run_id' => $old->id, 'state_version' => $round->state_version]);
        Queue::assertNothingPushed();
    }

    public function test_retry_without_an_active_run_returns_explicit_conflict_without_writes(): void
    {
        $round = $this->prepare();
        $before = $this->snapshot();
        Sanctum::actingAs($this->admin);
        $this->postJson($this->apiPath($round, 'retry'), [
            'state_version' => $round->state_version, 'reason_code' => 'missing_active_fixture',
        ], ['Idempotency-Key' => 'missing-active-fixture'])->assertStatus(409)
            ->assertJsonPath('error.message', 'active_run_required');
        $this->assertSame($before, $this->snapshot());
        Queue::assertNothingPushed();
    }

    public function test_retry_of_pending_active_run_is_a_domain_conflict_without_writes(): void
    {
        $runs = app(MatchingRunService::class);
        $runs->request($this->prepare(), 'pending-active-request', 'test', null);
        $round = DatingRound::sole();
        $before = $this->snapshot();
        Sanctum::actingAs($this->admin);
        $this->postJson($this->apiPath($round, 'retry'), [
            'state_version' => $round->state_version, 'reason_code' => 'pending_active_fixture',
        ], ['Idempotency-Key' => 'pending-retry-fixture'])->assertStatus(409)
            ->assertJsonPath('error.code', 'matching_conflict')
            ->assertJsonPath('error.message', 'only_current_failed_run_can_retry');
        $this->assertSame($before, $this->snapshot());
        Queue::assertNothingPushed();
    }

    private function prepare(): DatingRound
    {
        return app(MatchingRoundService::class)->prepare('v1008', 'route-fixture', null, now()->addHour(), 'test', null);
    }

    private function running(bool $expired): MatchingRun
    {
        $runs = app(MatchingRunService::class);
        $request = $runs->request($this->prepare(), 'initial-running-fixture', 'test', null);
        $run = $runs->claimNext('fixture-worker', 120, $request->id);
        $this->assertNotNull($run);
        if ($expired) {
            $run->forceFill(['lease_expires_at' => now()->subMinute()])->save();
        }

        return $run->fresh();
    }

    private function webPayload(DatingRound $round, array $overrides = []): array
    {
        return array_replace(['_token' => self::CSRF, 'operation' => 'executionRequest',
            'round_key' => $round->round_key, 'state_version' => $round->state_version,
            'idempotency_key' => 'web-execution-fixture', 'confirm' => true, 'reason_code' => 'fixture'], $overrides);
    }

    private function apiPath(DatingRound $round, string $operation): string
    {
        return '/api/v1/admin/matching/rounds/'.$round->round_key.'/'.$operation;
    }

    private function snapshot(): array
    {
        $snapshot = [];
        foreach (['matching_runs', 'dating_rounds', 'matching_operation_audits', 'admin_operation_audits', 'dating_matches'] as $table) {
            $snapshot[$table] = json_encode(DB::table($table)->orderBy('id')->get());
        }
        $snapshot['admin_versions'] = json_encode(DB::table('admin_versions')->orderBy('key')->get());

        return $snapshot;
    }
}

final class EnforcedV1008MatchingCsrf extends ValidateCsrfToken
{
    protected function runningUnitTests(): bool
    {
        return false;
    }
}
