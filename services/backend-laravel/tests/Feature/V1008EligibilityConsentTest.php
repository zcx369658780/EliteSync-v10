<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireAttempt;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\Admin\QuestionOperations;
use App\Services\Admin\UserGovernance;
use App\Services\LiveConsentService;
use App\Services\ProfileReadinessService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

final class V1008EligibilityConsentTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    private User $a;

    private User $b;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'questionnaire.required_answer_count' => 20,
            'app.key' => 'v1008-eligibility-fixture-signing-key']);
        $this->admin = $this->account('19900000861', ['role' => 'admin']);
        $this->a = $this->account('19900000862');
        $this->b = $this->account('19900000863');
        config(['app.admin_phones' => [$this->admin->phone]]);
        DatingMatch::create(['week_tag' => 'v1008-fixture', 'user_a' => $this->a->id,
            'user_b' => $this->b->id, 'drop_released' => true]);
    }

    public function test_pending_and_rejected_are_excluded_despite_twenty_valid_answers(): void
    {
        $questions = $this->questions();
        foreach ($questions as $question) {
            $this->answer($question);
        }
        $readiness = app(ProfileReadinessService::class);
        foreach (['pending', 'rejected'] as $status) {
            $this->a->forceFill(['verify_status' => $status, 'verify_reason' => '具名运营审核原因'])->save();
            $result = $readiness->forUser($this->a->fresh());
            $this->assertFalse($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
            $this->assertFalse($result['matching_eligibility']['eligible']);
            $this->assertSame('operational_review_'.$status, $result['matching_eligibility']['reason_code']);
            $this->assertSame('wait_for_review', $result['matching_eligibility']['next_action_code']);
            $this->assertSame('具名运营审核原因', $result['operational_review']['reason']);
        }
        $this->a->update(['verify_status' => 'approved']);
        $this->assertTrue($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $this->assertTrue($readiness->forUser($this->a->fresh())['matching_eligibility']['eligible']);
    }

    public function test_independent_match_exclusion_remains_effective_after_restrict_restore(): void
    {
        foreach ($this->questions() as $question) {
            $this->answer($question);
        }
        $this->a->update(['is_match_eligible' => false]);
        $governance = app(UserGovernance::class);
        $sanction = $governance->punish($this->admin, $this->a->id, 'restrict', 'controlled restriction', 0);
        $governance->restore($this->admin, $this->a->id, $sanction, 'restore only this restriction', 1);
        $readiness = app(ProfileReadinessService::class);
        $this->assertFalse((bool) $this->a->fresh()->is_match_eligible);
        $this->assertFalse($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $this->assertSame('matching_participation_excluded', $readiness->forUser($this->a->fresh())['matching_eligibility']['reason_code']);
        $this->a->update(['is_match_eligible' => true, 'account_status' => 'disabled']);
        $this->assertFalse($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $this->assertFalse($readiness->forUser($this->a->fresh())['matching_eligibility']['eligible']);
    }

    public function test_approved_requires_twenty_current_enabled_answers_with_valid_option_identity(): void
    {
        $questions = $this->questions();
        foreach (array_slice($questions, 0, 19) as $question) {
            $this->answer($question);
        }
        $readiness = app(ProfileReadinessService::class);
        $this->assertIncomplete($readiness, 19);
        $this->answer($questions[19], 'INVALID_OPTION_ID');
        $this->assertIncomplete($readiness, 19);
        $this->answer($questions[19]);
        $this->assertTrue($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $this->assertSame(20, $readiness->forUser($this->a->fresh())['matching_eligibility']['answered_answer_count']);
    }

    public function test_question_disable_preserves_history_and_requires_supplement_for_future_matching(): void
    {
        $questions = $this->questions(21);
        foreach (array_slice($questions, 0, 20) as $question) {
            $this->answer($question);
        }
        QuestionnaireAttempt::create(['user_id' => $this->a->id, 'questionnaire_version' => 'q_v2',
            'bank_version' => 'qb_v1', 'attempt_version' => 'qa_v1', 'answers_count' => 20, 'total_count' => 21,
            'answers_json' => array_map(fn ($q) => ['question_id' => $q->id, 'option_id' => 'fixture_yes'], array_slice($questions, 0, 20)),
            'completed_at' => now()]);
        $before = $this->historySnapshot();
        DB::table('admin_versions')->updateOrInsert(['key' => 'questionnaire'], ['revision' => 0]);
        $readiness = app(ProfileReadinessService::class);
        $this->assertTrue($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $operations = app(QuestionOperations::class);
        $preview = $operations->preview([$questions[0]->id], false);
        $operations->apply([$questions[0]->id], false, $preview['expected_revision'],
            $preview['preview_signature'], '虚构低质量题停用', $this->admin->id);
        $this->assertSame($before, $this->historySnapshot());
        $this->assertIncomplete($readiness, 19);
        $this->answer($questions[20]);
        $this->assertTrue($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $this->assertTrue($readiness->forUser($this->a->fresh())['matching_eligibility']['eligible']);
        $this->assertDatabaseCount('questionnaire_attempts', 1);
        $this->assertDatabaseCount('dating_matches', 1);
    }

    public function test_restrict_retains_history_read_but_restore_requires_new_bilateral_consent_generation(): void
    {
        $live = app(LiveConsentService::class);
        $this->assertSame('CN_PENDING', $live->transition($this->a->id, $this->b->id, 'connection', 'request', 0)['connection']['state']);
        $this->assertSame('CN_ACTIVE', $live->transition($this->b->id, $this->a->id, 'connection', 'accept', 1)['connection']['state']);
        $this->assertSame('MC_PENDING', $live->transition($this->a->id, $this->b->id, 'consent', 'request', 0)['consent']['state']);
        $this->assertSame('MC_ACTIVE', $live->transition($this->b->id, $this->a->id, 'consent', 'accept', 1)['consent']['state']);
        $this->assertGates($live, true, true);
        $activeSnapshot = json_encode(DB::table('messaging_consents')->where('generation', 1)->orderBy('id')->get());
        $governance = app(UserGovernance::class);
        $sanction = $governance->punish($this->admin, $this->a->id, 'restrict', '虚构处罚', 0);
        $this->assertGreaterThan(0, $sanction);
        $this->assertSame('restricted', $this->a->fresh()->moderation_status);
        $this->assertGates($live, true, false);
        $this->assertSame($activeSnapshot, json_encode(DB::table('messaging_consents')->where('generation', 1)->orderBy('id')->get()));
        $this->assertConflict(fn () => $live->transition($this->a->id, $this->b->id, 'consent', 'request', 2), 403);
        $governance->restore($this->admin, $this->a->id, $sanction, '具名解除本项处罚', 1);
        $this->assertSame('normal', $this->a->fresh()->moderation_status);
        $this->assertDatabaseHas('admin_sanctions', ['id' => $sanction, 'active' => false]);
        $this->assertGates($live, false, false);
        $revoked = DB::table('messaging_consents')->where('generation', 1)->orderBy('id')->get();
        $this->assertCount(2, $revoked);
        foreach ($revoked as $row) {
            $this->assertSame('MC_REVOKED', $row->state);
        }
        $oldSnapshot = json_encode($revoked);
        $current = $live->current($this->a->id, $this->b->id);
        $this->assertSame('MC_REVOKED', $current['consent']['state']);
        $this->assertConflict(fn () => $live->transition($this->a->id, $this->b->id, 'consent', 'request', 0));
        $eventBoundary = (int) DB::table('live_consent_events')->max('id');
        $pending = $live->transition($this->a->id, $this->b->id, 'consent', 'request', $current['consent']['revision'], $current['connection']['id'], $current['consent']['id']);
        $this->assertSame('MC_PENDING', $pending['consent']['state']);
        $this->assertSame(1, $pending['consent']['revision']);
        $newRows = DB::table('messaging_consents')->where('generation', 2)->get();
        $this->assertCount(2, $newRows);
        foreach ($newRows as $row) {
            $this->assertSame('MC_PENDING', $row->state);
        }
        $this->assertTrue(DB::table('live_consent_events')->where('id', '>', $eventBoundary)->where([
            'kind' => 'consent', 'actor_id' => $this->a->id, 'from_state' => 'MC_NONE',
            'to_state' => 'MC_PENDING', 'revision' => 1])->exists());
        $this->assertGates($live, false, false);
        $this->assertConflict(fn () => $live->transition($this->a->id, $this->b->id, 'consent', 'accept', 1));
        $current = $live->current($this->b->id, $this->a->id);
        $accepted = $live->transition($this->b->id, $this->a->id, 'consent', 'accept', 1, $current['connection']['id'], $current['consent']['id']);
        $this->assertSame('MC_ACTIVE', $accepted['consent']['state']);
        $this->assertGates($live, true, true);
        $this->assertConflict(fn () => $live->transition($this->b->id, $this->a->id, 'consent', 'accept', 2));
        $this->assertSame($oldSnapshot, json_encode(DB::table('messaging_consents')->where('generation', 1)->orderBy('id')->get()));
        $this->assertDatabaseCount('messaging_consents', 4);
        $this->assertDatabaseHas('product_connections', ['state' => 'CN_ACTIVE', 'revision' => 2]);
    }

    private function account(string $phone, array $overrides = []): User
    {
        return User::factory()->create(array_replace(['phone' => $phone, 'role' => 'user', 'disabled' => false,
            'is_synthetic' => false, 'verify_status' => 'approved', 'moderation_status' => 'normal'], $overrides));
    }

    private function questions(int $count = 20): array
    {
        $questions = [];
        for ($i = 0; $i < $count; $i++) {
            $questions[] = QuestionnaireQuestion::create(['question_key' => 'V1008_ELIGIBILITY_'.$i,
                'content' => '虚构资格题 '.$i, 'category' => 'fixture', 'sort_order' => $i, 'enabled' => true,
                'version' => 1, 'quality_tag' => 'low_drop', 'options' => [['option_id' => 'fixture_yes']]]);
        }

        return $questions;
    }

    private function answer(QuestionnaireQuestion $question, string $option = 'fixture_yes'): void
    {
        QuestionnaireAnswer::updateOrCreate(['user_id' => $this->a->id, 'questionnaire_question_id' => $question->id],
            ['answer_payload' => ['value' => $option, 'selected_answer' => [$option], 'question_version' => $question->version],
                'selected_answer_json' => [$option], 'acceptable_answers_json' => [$option], 'version' => $question->version]);
    }

    private function assertIncomplete(ProfileReadinessService $readiness, int $answered): void
    {
        $result = $readiness->forUser($this->a->fresh())['matching_eligibility'];
        $this->assertFalse($readiness->eligibleUsersQuery()->whereKey($this->a->id)->exists());
        $this->assertFalse($result['eligible']);
        $this->assertSame('questionnaire_incomplete', $result['reason_code']);
        $this->assertSame('complete_questionnaire', $result['next_action_code']);
        $this->assertSame(20, $result['required_answer_count']);
        $this->assertSame($answered, $result['answered_answer_count']);
        $this->assertSame(20 - $answered, $result['missing_answer_count']);
    }

    private function assertGates(LiveConsentService $live, bool $read, bool $send): void
    {
        foreach ([[$this->a->id, $this->b->id], [$this->b->id, $this->a->id]] as [$actor, $peer]) {
            $gates = $live->gates($actor, $peer);
            $this->assertSame($read, $gates['live_read_allowed']);
            $this->assertSame($send, $gates['live_send_allowed']);
        }
    }

    private function assertConflict(callable $operation, int $status = 409): void
    {
        try {
            $operation();
            $this->fail('Expected transition rejection');
        } catch (HttpException $error) {
            $this->assertSame($status, $error->getStatusCode());
        }
    }

    private function historySnapshot(): array
    {
        $snapshot = [];
        foreach (['questionnaire_answers', 'questionnaire_attempts', 'dating_matches'] as $table) {
            $snapshot[$table] = json_encode(DB::table($table)->orderBy('id')->get());
        }

        return $snapshot;
    }
}
