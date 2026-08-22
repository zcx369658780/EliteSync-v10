<?php

namespace Tests\Feature;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\PairKey;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunOutcome;
use App\Domain\Matching\RunState;
use App\Models\DatingMatch;
use App\Models\DatingRoundUserState;
use App\Models\MatchingOperationAudit;
use App\Models\User;
use App\Models\QuestionnaireQuestion;
use App\Services\MatchingRoundService;
use App\Services\MatchingRunService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class MatchingFoundationServiceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config()->set('matching.foundation.digest_key', 'unit-test-digest-key');
    }

    public function test_additive_schema_and_legacy_match_coexist(): void
    {
        foreach (['dating_round_channels','dating_rounds','matching_runs','matching_run_candidates','dating_round_user_states','matching_operation_audits'] as $table) $this->assertTrue(Schema::hasTable($table));
        $a = User::factory()->create(['phone' => 'test-a', 'role' => 'user']);
        $b = User::factory()->create(['phone' => 'test-b', 'role' => 'user']);
        $legacy = DatingMatch::query()->create(['week_tag' => 'legacy', 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true]);
        $this->assertNull($legacy->round_id);
        $this->assertNull($legacy->matching_run_id);
    }

    public function test_latest_additive_migrations_roll_back_without_deleting_legacy_matches(): void
    {
        $a = User::factory()->create(['phone' => 'upgrade-a']); $b = User::factory()->create(['phone' => 'upgrade-b']);
        $legacyId = DatingMatch::query()->create(['week_tag' => 'upgrade-legacy', 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true])->id;
        $this->artisan('migrate:rollback', [
            '--path' => [
                'database/migrations/2026_07_12_000100_create_match_round_foundation_tables.php',
                'database/migrations/2026_07_12_000200_add_round_run_linkage_to_dating_matches.php',
            ],
            '--force' => true,
        ])->assertSuccessful();
        $this->assertFalse(Schema::hasTable('matching_runs'));
        $this->assertTrue(Schema::hasTable('dating_matches'));
        $this->assertFalse(Schema::hasColumn('dating_matches', 'round_id'));
        $this->assertDatabaseHas('dating_matches', ['id' => $legacyId, 'week_tag' => 'upgrade-legacy']);
        $this->assertTrue(Schema::hasTable('user_profile_showcase_publications'));
        $this->artisan('migrate', ['--force' => true])->assertSuccessful();
        $this->assertDatabaseHas('dating_matches', ['id' => $legacyId, 'round_id' => null]);
    }

    public function test_prepare_request_claim_heartbeat_finalize_and_idempotent_replay(): void
    {
        $rounds = app(MatchingRoundService::class); $runs = app(MatchingRunService::class);
        $round = $rounds->prepare('default', '2026-W29', now(), now()->addHour(), 'test', null);
        $this->assertSame($round->id, $rounds->prepare('default', '2026-W29', now(), now()->addHour(), 'test', null)->id);
        $run = $runs->request($round, 'idem-1', 'test', null);
        $this->assertSame($run->id, $runs->request($round, 'idem-1', 'test', null)->id);
        $claimed = $runs->claimNext('worker-a', 120);
        $this->assertNotNull($claimed);
        $this->assertNull($runs->claimNext('worker-b', 120));
        $this->assertTrue($runs->heartbeat($claimed, 'worker-a', $claimed->fencing_token, 120));
        $this->assertFalse($runs->heartbeat($claimed, 'worker-b', $claimed->fencing_token, 120));
        $a = User::factory()->create(['phone' => 'candidate-a']); $b = User::factory()->create(['phone' => 'candidate-b']);
        $runs->freezeCandidates($claimed, collect([$a, $b]), 'worker-a', $claimed->fencing_token);
        $done = $runs->finalize($claimed->fresh(), 'worker-a', $claimed->fencing_token, [$a->id, $b->id], [['user_a' => $a->id, 'user_b' => $b->id, 'highlights' => 'bounded test']]);
        $this->assertSame(RunState::Succeeded, $done->state);
        $this->assertSame(RunOutcome::MatchesCreated, $done->outcome);
        $this->assertDatabaseHas('dating_matches', ['round_id' => $round->id, 'pair_key' => PairKey::forUsers($a->id, $b->id)]);
        $this->assertSame(2, DatingRoundUserState::query()->where('round_id', $round->id)->count());
    }

    public function test_stale_fence_is_rejected_and_retry_is_new_attempt(): void
    {
        $round = app(MatchingRoundService::class)->prepare('default', '2026-W30', null, null, 'test', null);
        $run = app(MatchingRunService::class)->request($round, 'idem-fail', 'test', null);
        $claimed = app(MatchingRunService::class)->claimNext('worker-a', 120);
        $this->expectException(\DomainException::class);
        app(MatchingRunService::class)->finalize($claimed, 'worker-a', $claimed->fencing_token + 1, [], []);
    }

    public function test_failure_is_not_no_candidate_and_retry_has_lineage(): void
    {
        $runs = app(MatchingRunService::class);
        $round = app(MatchingRoundService::class)->prepare('default', '2026-W31', null, null, 'test', null);
        $claimed = tap($runs->request($round, 'idem-failure', 'test', null), fn () => null);
        $claimed = $runs->claimNext('worker-a', 120);
        $failed = $runs->fail($claimed, 'worker-a', $claimed->fencing_token, 'technical_failure', 'bounded summary');
        $this->assertSame(RunState::Failed, $failed->state);
        $this->assertNull($failed->outcome);
        $retry = $runs->retry($failed, 'idem-retry', 'test', null);
        $this->assertSame($failed->id, $retry->supersedes_run_id);
        $this->assertSame(2, $retry->attempt_no);
    }

    public function test_atomic_pair_failure_leaves_no_matches_or_projections_then_records_failure(): void
    {
        $runs = app(MatchingRunService::class);
        $round = app(MatchingRoundService::class)->prepare('default', '2026-W34', null, null, 'test', null);
        $runs->request($round, 'idem-atomic', 'test', null);
        $claimed = $runs->claimNext('worker-a', 120);
        $a = User::factory()->create(['phone' => 'atomic-a']); $b = User::factory()->create(['phone' => 'atomic-b']);
        $runs->freezeCandidates($claimed, collect([$a, $b]), 'worker-a', $claimed->fencing_token);
        try {
            $runs->finalize($claimed, 'worker-a', $claimed->fencing_token, [$a->id, $b->id], [
                ['user_a' => $a->id, 'user_b' => $b->id],
                ['user_a' => $b->id, 'user_b' => $a->id],
            ]);
            $this->fail('duplicate symmetric pair should violate the round pair key');
        } catch (\DomainException|\Illuminate\Database\QueryException) {
            $this->assertDatabaseMissing('dating_matches', ['round_id' => $round->id]);
            $this->assertDatabaseMissing('dating_round_user_states', ['round_id' => $round->id]);
        }
        $failed = $runs->fail($claimed->fresh(), 'worker-a', $claimed->fencing_token, 'atomic_persistence_failed', 'bounded failure');
        $this->assertSame(RunState::Failed, $failed->state);
        $this->assertNull($failed->outcome);
    }

    public function test_append_only_audit_and_optimistic_round_transition(): void
    {
        $service = app(MatchingRoundService::class);
        $round = $service->prepare('default', '2026-W32', null, null, 'test', null);
        $round = $service->transition($round, RoundState::Failed, $round->state_version, 'test', null, OperationAction::Execute);
        $this->expectException(\DomainException::class);
        $service->transition($round, RoundState::Closed, $round->state_version - 1, 'test', null, OperationAction::Close);
    }

    public function test_expired_lease_is_fenced_failed_and_requires_new_retry(): void
    {
        $runs = app(MatchingRunService::class);
        $round = app(MatchingRoundService::class)->prepare('default', '2026-W36', null, null, 'test', null);
        $runs->request($round, 'idem-expire', 'test', null);
        $claimed = $runs->claimNext('worker-a', 1);
        $oldFence = $claimed->fencing_token;
        $this->travel(2)->seconds();
        $expired = $runs->expireLease($claimed->id);
        $this->assertSame(RunState::Failed, $expired->state);
        $this->assertGreaterThan($oldFence, $expired->fencing_token);
        $this->assertSame('lease_expired', $expired->error_code);
    }

    public function test_input_change_after_freeze_is_rejected(): void
    {
        $runs = app(MatchingRunService::class);
        $round = app(MatchingRoundService::class)->prepare('default', '2026-W37', null, null, 'test', null);
        $runs->request($round, 'idem-change', 'test', null);
        $claimed = $runs->claimNext('worker-a', 120);
        $a = User::factory()->create(['phone' => 'change-a']); $b = User::factory()->create(['phone' => 'change-b']);
        $question = QuestionnaireQuestion::query()->create(['question_key' => 'freeze_test', 'category' => 'test', 'content' => 'before', 'question_type' => 'single', 'options' => ['a','b'], 'sort_order' => 1, 'enabled' => true, 'version' => 1]);
        $runs->freezeCandidates($claimed, collect([$a, $b]), 'worker-a', $claimed->fencing_token);
        $this->travel(1)->seconds();
        $question->forceFill(['content' => 'after'])->save();
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('input_changed');
        $runs->finalize($claimed->fresh(), 'worker-a', $claimed->fencing_token, [$a->id, $b->id], []);
    }

    public function test_reveal_atomically_updates_match_and_user_projections(): void
    {
        $runs = app(MatchingRunService::class); $rounds = app(MatchingRoundService::class);
        $round = $rounds->prepare('default', '2026-W38', null, now()->subMinute(), 'test', null);
        $runs->request($round, 'idem-reveal', 'test', null); $claimed = $runs->claimNext('worker-a', 120);
        $a = User::factory()->create(['phone' => 'reveal-a']); $b = User::factory()->create(['phone' => 'reveal-b']);
        $runs->freezeCandidates($claimed, collect([$a, $b]), 'worker-a', $claimed->fencing_token);
        $runs->finalize($claimed->fresh(), 'worker-a', $claimed->fencing_token, [$a->id, $b->id], [['user_a' => $a->id, 'user_b' => $b->id]]);
        $waiting = $round->fresh();
        $revealed = $rounds->transition($waiting, RoundState::Revealed, $waiting->state_version, 'test', null, OperationAction::Reveal);
        $this->assertSame(RoundState::Revealed, $revealed->state);
        $this->assertDatabaseHas('dating_matches', ['round_id' => $round->id, 'drop_released' => true]);
        $this->assertSame(2, DatingRoundUserState::query()->where('round_id', $round->id)->where('conversation_eligible', true)->count());
    }

    public function test_all_unmatched_reveals_no_candidate_then_closes_projection(): void
    {
        $runs = app(MatchingRunService::class); $rounds = app(MatchingRoundService::class);
        $round = $rounds->prepare('default', '2026-W39', null, now()->subMinute(), 'test', null);
        $runs->request($round, 'idem-no-candidate', 'test', null); $claimed = $runs->claimNext('worker-a', 120);
        $user = User::factory()->create(['phone' => 'no-candidate-user']);
        $runs->freezeCandidates($claimed, collect([$user]), 'worker-a', $claimed->fencing_token);
        $done = $runs->finalize($claimed->fresh(), 'worker-a', $claimed->fencing_token, [$user->id], []);
        $this->assertSame(RunOutcome::NoCandidate, $done->outcome);
        $waiting = $round->fresh();
        $noCandidate = $rounds->transition($waiting, RoundState::NoCandidate, $waiting->state_version, 'test', null, OperationAction::Reveal);
        $this->assertDatabaseHas('dating_round_user_states', ['round_id' => $round->id, 'user_id' => $user->id, 'state' => 'no_candidate', 'conversation_eligible' => false]);
        $closed = $rounds->transition($noCandidate, RoundState::Closed, $noCandidate->state_version, 'test', null, OperationAction::Close);
        $this->assertSame(RoundState::Closed, $closed->state);
        $this->assertDatabaseHas('dating_round_user_states', ['round_id' => $round->id, 'user_id' => $user->id, 'state' => 'closed']);
    }
}
