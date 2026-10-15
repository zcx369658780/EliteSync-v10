<?php

namespace Tests\Feature;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\RoundState;
use App\Models\MatchingRun;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\Admin\QuestionOperations;
use App\Services\Admin\UserGovernance;
use App\Services\MatchingRoundService;
use App\Services\MatchingRunService;
use Illuminate\Database\Query\Builder;
use Illuminate\Database\Query\Grammars\SQLiteGrammar;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/** Records requested row locks without pretending SQLite implements FOR UPDATE. */
final class V1008RecordingLockGrammar extends SQLiteGrammar
{
    public array $requestedLocks = [];

    protected function compileLock(Builder $query, $value)
    {
        if ($value) {
            $this->requestedLocks[] = ['table' => $query->from, 'orders' => $query->orders ?? []];
        }

        return parent::compileLock($query, $value);
    }
}

final class V1008MatchingConcurrencyTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    private User $a;

    private User $b;

    private QuestionnaireQuestion $question;

    protected function setUp(): void
    {
        parent::setUp();
        config(['matching.foundation.digest_key' => 'v1008-lock-fixture-key',
            'questionnaire.required_answer_count' => 1,
            'app.key' => 'base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=']);
        $this->admin = $this->account('19900000881', 'admin');
        $this->a = $this->account('19900000882');
        $this->b = $this->account('19900000883');
        config(['app.admin_phones' => [$this->admin->phone]]);
        $this->question = QuestionnaireQuestion::create(['question_key' => 'V1008_LOCK_QUESTION',
            'content' => '虚构锁验证题', 'enabled' => true, 'version' => 1, 'quality_tag' => 'low_drop',
            'options' => [['option_id' => 'A']]]);
        foreach ([$this->a, $this->b] as $user) {
            QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $this->question->id,
                'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        }
    }

    public function test_finalize_requests_global_then_sorted_users_then_round_and_run_locks(): void
    {
        $run = $this->freeze();
        $locks = $this->recordLocks(fn () => $this->finalize($run));
        $this->assertSame(['admin_versions', 'users', 'dating_rounds', 'matching_runs'],
            array_column(array_slice($locks, 0, 4), 'table'));
        $this->assertSame([['column' => 'id', 'direction' => 'asc']], $locks[1]['orders']);
        $this->assertDatabaseHas('matching_runs', ['id' => $run->id, 'state' => 'succeeded']);
        $this->assertDatabaseHas('dating_matches', ['matching_run_id' => $run->id, 'drop_released' => false]);
    }

    public function test_finalize_rejects_a_running_run_that_is_no_longer_the_current_attempt(): void
    {
        $run = $this->freeze();
        DB::table('dating_rounds')->where('id', $run->round_id)->update(['active_run_id' => null]);
        try {
            $this->finalize($run);
            $this->fail('Detached run must not finalize');
        } catch (\DomainException $error) {
            $this->assertSame('run_not_current', $error->getMessage());
        }
        $this->assertDatabaseCount('dating_matches', 0);
        $this->assertDatabaseHas('matching_runs', ['id' => $run->id, 'state' => 'running', 'pair_count' => 0]);
        $before = $this->publicationSnapshot();
        $runs = app(MatchingRunService::class);
        // The consumer's finalize catch must not let either fallback overwrite the current round.
        $this->assertRejected(fn () => $runs->fail($run, 'fixture-worker', $run->fencing_token, 'execution_failed', 'failure'), 'run_not_current');
        $this->travel(121)->seconds();
        $this->assertRejected(fn () => $runs->expireLease($run->id), 'run_not_current');
        $this->assertFalse($runs->heartbeat($run, 'fixture-worker', $run->fencing_token));
        $this->assertSame($before, $this->publicationSnapshot());
    }

    public function test_reveal_requests_the_same_input_locks_before_publishing(): void
    {
        $run = $this->freeze();
        $this->finalize($run);
        $locks = $this->recordLocks(fn () => $this->reveal($run));
        $this->assertSame(['admin_versions', 'users', 'dating_rounds', 'matching_runs'],
            array_column(array_slice($locks, 0, 4), 'table'));
        $this->assertSame([['column' => 'id', 'direction' => 'asc']], $locks[1]['orders']);
        $notifications = \App\Models\AppNotificationItem::where('kind', 'matching_round')->get();
        $this->assertCount(2, $notifications);
        foreach ($notifications as $notification) {
            $this->assertSame($run->round->round_key, $notification->payload['round_key']);
            $this->assertSame($run->run_key, $notification->payload['run_key']);
            $this->assertSame('match_result', $notification->payload['route_name']);
            $this->assertArrayNotHasKey('partner_user_id', $notification->payload);
            $this->assertStringContainsString('不授予连接或消息同意', $notification->body);
        }
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
        $this->assertDatabaseHas('dating_matches', ['matching_run_id' => $run->id, 'drop_released' => true]);
    }

    public function test_review_committed_after_freeze_prevents_finalize_without_partial_matches(): void
    {
        $run = $this->freeze();
        app(UserGovernance::class)->review($this->admin, $this->a->id, 'rejected', '虚构审核变化', 0);
        $before = $this->publicationSnapshot();
        $this->assertRejected(fn () => $this->finalize($run), 'eligibility_changed');
        $this->assertSame($before, $this->publicationSnapshot());
        $this->assertDatabaseHas('matching_runs', ['id' => $run->id, 'state' => 'running']);
        $this->assertDatabaseCount('dating_matches', 0);
    }

    public function test_question_change_committed_after_freeze_prevents_finalize_and_retains_answers(): void
    {
        $run = $this->freeze();
        $operations = app(QuestionOperations::class);
        $preview = $operations->preview([$this->question->id], false);
        $operations->apply([$this->question->id], false, $preview['expected_revision'],
            $preview['preview_signature'], '虚构题库变更', $this->admin->id);
        $before = $this->publicationSnapshot();
        $this->assertRejected(fn () => $this->finalize($run), 'input_changed');
        $this->assertSame($before, $this->publicationSnapshot());
        $this->assertDatabaseCount('questionnaire_answers', 2);
        $this->assertDatabaseCount('dating_matches', 0);
    }

    public function test_restrict_committed_after_finalize_prevents_reveal_without_rewriting_frozen_run(): void
    {
        $run = $this->freeze();
        $this->finalize($run);
        app(UserGovernance::class)->punish($this->admin, $this->b->id, 'restrict', '虚构处罚变化', 0);
        $before = $this->publicationSnapshot();
        $this->assertRejected(fn () => $this->reveal($run), 'eligibility_changed_before_reveal');
        $this->assertSame($before, $this->publicationSnapshot());
        $this->assertDatabaseHas('dating_matches', ['matching_run_id' => $run->id, 'drop_released' => false]);
        $this->assertDatabaseHas('matching_runs', ['id' => $run->id, 'state' => 'succeeded']);
    }

    public function test_question_change_after_finalize_prevents_reveal_when_current_coverage_is_insufficient(): void
    {
        $run = $this->freeze();
        $this->finalize($run);
        $operations = app(QuestionOperations::class);
        $preview = $operations->preview([$this->question->id], false);
        $operations->apply([$this->question->id], false, $preview['expected_revision'],
            $preview['preview_signature'], '虚构发布前停题', $this->admin->id);
        $before = $this->publicationSnapshot();
        $this->assertRejected(fn () => $this->reveal($run), 'eligibility_changed_before_reveal');
        $this->assertSame($before, $this->publicationSnapshot());
        $this->assertDatabaseCount('questionnaire_answers', 2);
    }

    public function test_unmatched_candidate_review_change_blocks_no_candidate_publication_without_half_writes(): void
    {
        $run = $this->freeze();
        app(MatchingRunService::class)->finalize($run, 'fixture-worker', $run->fencing_token,
            [$this->b->id, $this->a->id], []);
        $this->assertDatabaseCount('dating_matches', 0);
        $this->assertDatabaseCount('dating_round_user_states', 2);
        foreach (['pending', 'rejected'] as $revision => $status) {
            app(UserGovernance::class)->review($this->admin, $this->a->id, $status,
                '虚构未配对候选审核变化', $revision);
            $before = $this->publicationSnapshot();
            $round = $run->round()->firstOrFail();
            $this->assertRejected(fn () => app(MatchingRoundService::class)->transition(
                $round, RoundState::NoCandidate, $round->state_version, 'test', null, OperationAction::Reveal
            ), 'eligibility_changed_before_reveal');
            $this->assertSame($before, $this->publicationSnapshot());
            $this->assertDatabaseHas('dating_rounds', ['id' => $round->id, 'state' => 'waiting', 'revealed_at' => null]);
            $this->assertDatabaseHas('dating_round_user_states', ['round_id' => $round->id,
                'user_id' => $this->a->id, 'state' => 'waiting', 'dating_match_id' => null,
                'reason_code' => 'no_candidate_pending_reveal', 'projection_version' => 1]);
        }
    }

    private function account(string $phone, string $role = 'user'): User
    {
        return User::factory()->create(['phone' => $phone, 'role' => $role, 'verify_status' => 'approved',
            'disabled' => false, 'is_synthetic' => false, 'moderation_status' => 'normal']);
    }

    private function freeze(): MatchingRun
    {
        $round = app(MatchingRoundService::class)->prepare('v1008-locks', 'lock-fixture', null, now()->subMinute(), 'test', null);
        $runs = app(MatchingRunService::class);
        $requested = $runs->request($round, 'v1008-lock-request', 'test', null);
        $run = $runs->claimNext('fixture-worker', 120, $requested->id);
        $this->assertNotNull($run);
        // Deliberately supply reverse ID order; locking must still be deterministic.
        $runs->freezeCandidates($run, [$this->b, $this->a], 'fixture-worker', $run->fencing_token);

        return $run->fresh();
    }

    private function finalize(MatchingRun $run): void
    {
        app(MatchingRunService::class)->finalize($run, 'fixture-worker', $run->fencing_token,
            [$this->b->id, $this->a->id], [['user_a' => $this->a->id, 'user_b' => $this->b->id]]);
    }

    private function reveal(MatchingRun $run): void
    {
        $round = $run->round()->firstOrFail();
        app(MatchingRoundService::class)->transition($round, RoundState::Revealed, $round->state_version,
            'test', null, OperationAction::Reveal);
    }

    private function recordLocks(callable $operation): array
    {
        $connection = DB::connection();
        $original = $connection->getQueryGrammar();
        $grammar = new V1008RecordingLockGrammar;
        $grammar->setConnection($connection);
        $grammar->setTablePrefix($original->getTablePrefix());
        $connection->setQueryGrammar($grammar);
        try {
            $operation();
        } finally {
            $connection->setQueryGrammar($original);
        }

        return $grammar->requestedLocks;
    }

    private function assertRejected(callable $operation, string $reason): void
    {
        try {
            $operation();
            $this->fail('Expected frozen run/publication conflict');
        } catch (\DomainException $error) {
            $this->assertSame($reason, $error->getMessage());
        }
    }

    private function publicationSnapshot(): array
    {
        $snapshot = [];
        foreach (['matching_runs', 'matching_run_candidates', 'dating_rounds', 'dating_matches',
            'dating_round_user_states', 'matching_operation_audits', 'questionnaire_answers'] as $table) {
            $snapshot[$table] = json_encode(DB::table($table)->orderBy('id')->get());
        }

        return $snapshot;
    }
}
