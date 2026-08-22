<?php

namespace Tests\Feature;

use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunState;
use App\Domain\Matching\UserRoundState;
use App\Models\DatingRoundUserState;
use App\Models\DatingMatch;
use App\Models\User;
use App\Services\MatchingRoundService;
use App\Services\MatchingRunService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MatchRoundApiFoundationTest extends TestCase
{
    use RefreshDatabase;

    public function test_current_round_normal_absence_is_canonical_200_and_legacy_route_remains_registered(): void
    {
        $user = User::factory()->create(['phone' => 'reader']);
        Sanctum::actingAs($user);
        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'no_round')
            ->assertJsonPath('data.round_id', null)
            ->assertJsonPath('data.next_transition_at', null);
        $this->assertTrue(collect(app('router')->getRoutes())->contains(fn ($route) => $route->uri() === 'api/v1/matches/current'));
    }

    public function test_typed_no_round_and_persisted_states_have_server_owned_fields(): void
    {
        $user = User::factory()->create(['phone' => 'reader']);
        Sanctum::actingAs($user);
        $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.state', 'no_round')->assertJsonPath('data.state_version', null)->assertJsonPath('meta.contract_version', 'match_round_v2');
        app(MatchingRoundService::class)->prepare('default', '2026-W33', now()->addHour(), now()->addHours(2), 'test', null);
        $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.state', 'scheduled')->assertJsonPath('data.state_version', 1)->assertJsonStructure(['data' => ['server_now', 'scheduled_at', 'next_transition_at']]);
    }

    public function test_all_persisted_public_projection_states_are_typed_200(): void
    {
        $user = User::factory()->create(['phone' => 'state-reader']);
        Sanctum::actingAs($user);
        $round = app(MatchingRoundService::class)->prepare('default', '2026-W35', null, null, 'test', null);
        foreach ([UserRoundState::Preparing, UserRoundState::Waiting, UserRoundState::Revealed, UserRoundState::NoCandidate, UserRoundState::Failed, UserRoundState::Closed] as $state) {
            $round->forceFill([
                'scheduled_for' => $state === UserRoundState::Waiting
                    ? now()->addHour()
                    : now()->subHour(),
            ])->save();
            DatingRoundUserState::query()->updateOrCreate(['round_id' => $round->id, 'user_id' => $user->id], ['state' => $state, 'projection_version' => 1]);
            $expected = match ($state) {
                UserRoundState::Waiting => 'scheduled',
                UserRoundState::Revealed => 'no_candidate',
                default => $state->value,
            };
            $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.state', $expected);
        }
    }

    public function test_current_round_canonical_state_and_field_matrix_is_server_owned_and_read_only(): void
    {
        $user = User::factory()->create(['phone' => 'matrix-reader']);
        $peer = User::factory()->create(['phone' => 'matrix-peer']);
        Sanctum::actingAs($user);
        $scheduledAt = now()->addHour()->startOfSecond();
        $revealAt = now()->addHours(2)->startOfSecond();
        $round = app(MatchingRoundService::class)->prepare(
            'default',
            '2026-W36',
            $scheduledAt,
            $revealAt,
            'test',
            null,
        );

        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'scheduled')
            ->assertJsonPath('data.next_transition_at', $scheduledAt->toISOString());

        $round->forceFill(['scheduled_for' => now()->subMinute()])->save();
        $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.state', 'preparing');

        $run = app(MatchingRunService::class)->request($round->fresh(), 'projection-matrix', 'test', null);
        app(MatchingRunService::class)->claimNext('projection-test-worker');
        $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.state', 'running');

        $run->forceFill(['state' => RunState::Succeeded])->save();
        $round->forceFill(['state' => RoundState::Waiting])->save();
        DatingRoundUserState::query()->updateOrCreate(
            ['round_id' => $round->id, 'user_id' => $user->id],
            ['state' => UserRoundState::Waiting, 'projection_version' => 2],
        );
        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'scheduled')
            ->assertJsonPath('data.next_transition_at', $revealAt->toISOString());

        $match = DatingMatch::query()->create([
            'round_id' => $round->id,
            'matching_run_id' => $run->id,
            'pair_key' => "{$user->id}:{$peer->id}",
            'pair_key_version' => 1,
            'week_tag' => '2026-W36',
            'user_a' => $user->id,
            'user_b' => $peer->id,
            'highlights' => '本轮匹配已揭晓',
            'drop_released' => true,
        ]);
        $round->forceFill(['state' => RoundState::Revealed])->save();
        DatingRoundUserState::query()->updateOrCreate(
            ['round_id' => $round->id, 'user_id' => $user->id],
            ['state' => UserRoundState::Revealed, 'dating_match_id' => $match->id, 'projection_version' => 3],
        );
        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'revealed')
            ->assertJsonPath('data.result_id', $match->id);

        DatingRoundUserState::query()->where('round_id', $round->id)->where('user_id', $user->id)->update([
            'state' => UserRoundState::NoCandidate->value,
            'dating_match_id' => null,
            'reason_code' => 'no_eligible_candidate',
        ]);
        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'no_candidate')
            ->assertJsonPath('data.no_candidate_reason_code', 'no_eligible_candidate')
            ->assertJsonPath('data.failure_code', null);

        $round->forceFill(['state' => RoundState::Failed, 'failure_code' => 'run_failed'])->save();
        DatingRoundUserState::query()->where('round_id', $round->id)->where('user_id', $user->id)->update([
            'state' => UserRoundState::Failed->value,
            'reason_code' => 'safe_user_failure',
        ]);
        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'failed')
            ->assertJsonPath('data.failure_code', 'run_failed')
            ->assertJsonPath('data.no_candidate_reason_code', null)
            ->assertJsonPath('data.retry_eligible', true);

        $round->forceFill(['state' => RoundState::Closed])->save();
        DatingRoundUserState::query()->where('round_id', $round->id)->where('user_id', $user->id)->update(['state' => UserRoundState::Closed->value]);
        $before = [
            'rounds' => \App\Models\DatingRound::query()->count(),
            'states' => DatingRoundUserState::query()->count(),
            'matches' => DatingMatch::query()->count(),
        ];
        $response = $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'closed')
            ->assertJsonStructure(['data' => [
                'round_id', 'state', 'server_now', 'scheduled_at', 'next_transition_at',
                'result_id', 'no_candidate_reason_code', 'failure_code', 'retry_eligible',
                'user_action', 'projection_version', 'updated_at',
            ]]);
        $data = $response->json('data');
        $this->assertIsInt($data['round_id']);
        $this->assertIsString($data['server_now']);
        $this->assertIsBool($data['retry_eligible']);
        $this->assertIsString($data['user_action']);
        $this->assertIsInt($data['projection_version']);
        $this->assertArrayNotHasKey('score', $data);
        $this->assertArrayNotHasKey('weight', $data);
        $this->assertArrayNotHasKey('module_score', $data);
        $this->assertSame($before, [
            'rounds' => \App\Models\DatingRound::query()->count(),
            'states' => DatingRoundUserState::query()->count(),
            'matches' => DatingMatch::query()->count(),
        ]);
    }

    public function test_current_round_does_not_borrow_conversation_capability_from_an_older_match(): void
    {
        $user = User::factory()->create(['phone' => 'current-truth-reader']);
        $peer = User::factory()->create(['phone' => 'current-truth-peer']);
        Sanctum::actingAs($user);

        DatingMatch::query()->create([
            'week_tag' => 'historical-released',
            'user_a' => $user->id,
            'user_b' => $peer->id,
            'drop_released' => true,
            'released_at' => now()->subDay(),
        ]);

        $round = app(MatchingRoundService::class)->prepare(
            'default',
            'current-unreleased',
            now()->subHour(),
            now()->subMinute(),
            'test',
            null,
        );
        $currentMatch = DatingMatch::query()->create([
            'round_id' => $round->id,
            'pair_key' => "{$user->id}:{$peer->id}",
            'pair_key_version' => 1,
            'week_tag' => 'current-unreleased',
            'user_a' => $user->id,
            'user_b' => $peer->id,
            'drop_released' => false,
        ]);
        $round->forceFill(['state' => RoundState::Revealed])->save();
        DatingRoundUserState::query()->updateOrCreate(
            ['round_id' => $round->id, 'user_id' => $user->id],
            [
                'state' => UserRoundState::Revealed,
                'dating_match_id' => $currentMatch->id,
                'projection_version' => 2,
            ],
        );

        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'failed')
            ->assertJsonPath('data.result', null)
            ->assertJsonPath('data.conversation_capability', null)
            ->assertJsonPath('data.failure_code', 'current_match_not_released')
            ->assertJsonPath('data.retry_eligible', true);
    }

    public function test_admin_operation_guard_does_not_inherit_public_dev_bypass(): void
    {
        config()->set('app.allow_public_dev_matching', true);
        config()->set('matching.foundation.admin_operations_enabled', true);
        $normal = User::factory()->create(['phone' => 'normal', 'role' => 'user']);
        Sanctum::actingAs($normal);
        $this->getJson('/api/v1/admin/matching/rounds')->assertForbidden();
    }

    public function test_admin_and_cli_execution_are_default_off(): void
    {
        $phone = 'admin-test-only';
        config()->set('app.admin_phones', [$phone]);
        $admin = User::factory()->create(['phone' => $phone, 'role' => 'admin']);
        Sanctum::actingAs($admin);
        $this->getJson('/api/v1/admin/matching/rounds')->assertStatus(503);
        $this->artisan('app:matching:execute-pending', ['--once' => true])->assertFailed();
    }
}
