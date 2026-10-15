<?php

namespace Tests\Feature;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireAttempt;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Database\Seeders\QuestionnaireQuestionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007QuestionnairePersistenceTest extends TestCase
{
    use RefreshDatabase;

    private User $account;

    private QuestionnaireQuestion $question;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(QuestionnaireQuestionSeeder::class);
        $this->account = User::factory()->create(['phone' => '19900000741', 'disabled' => false]);
        $this->question = QuestionnaireQuestion::where('enabled', true)->orderBy('id')->firstOrFail();
        Sanctum::actingAs($this->account);
    }

    private function answer(array $overrides = []): array
    {
        return array_replace([
            'question_id' => $this->question->id,
            'option_id' => $this->question->options[0]['option_id'],
            'importance' => 2,
            'version' => $this->question->version,
        ], $overrides);
    }

    public function test_canonical_answer_and_attempt_are_persisted_with_current_identity(): void
    {
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [$this->answer()]])->assertOk();
        $answer = QuestionnaireAnswer::where('user_id', $this->account->id)->firstOrFail();
        $this->assertSame($this->question->options[0]['option_id'], $answer->answer_payload['value']);
        $this->assertSame($this->question->version, $answer->version);
        $this->assertSame($this->question->version, $answer->answer_payload['question_version']);
        $this->assertSame($this->question->question_key, $answer->answer_payload['question_key']);
        $attempt = QuestionnaireAttempt::where('user_id', $this->account->id)->firstOrFail();
        $this->assertSame($answer->answer_payload['attempt_version'], $attempt->attempt_version);
        $this->assertSame($answer->answer_payload['bank_version'], $attempt->bank_version);
        $this->assertSame(1, $attempt->answers_count);
    }

    public function test_invalid_option_rejects_entire_batch_without_answer_or_attempt_writes(): void
    {
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            $this->answer(), $this->answer(['option_id' => 'NOT_A_BANK_OPTION']),
        ]])->assertUnprocessable();
        $this->assertDatabaseCount('questionnaire_answers', 0);
        $this->assertDatabaseCount('questionnaire_attempts', 0);
    }

    public function test_stale_question_version_rejects_without_writes(): void
    {
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            $this->answer(['version' => $this->question->version + 1]),
        ]])->assertUnprocessable();
        $this->assertDatabaseCount('questionnaire_answers', 0);
        $this->assertDatabaseCount('questionnaire_attempts', 0);
    }

    public function test_disabled_research_question_cannot_be_answered(): void
    {
        $research = QuestionnaireQuestion::where('recommended_bank', 'research')->firstOrFail();
        $this->assertFalse($research->enabled);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            $this->answer([
                'question_id' => $research->id,
                'option_id' => $research->options[0]['option_id'],
                'version' => $research->version,
            ]),
        ]])->assertUnprocessable();
        $this->assertDatabaseCount('questionnaire_answers', 0);
        $this->assertDatabaseCount('questionnaire_attempts', 0);
    }

    public function test_draft_persists_and_readback_is_isolated_by_current_account(): void
    {
        $payload = [
            'answers' => [(string) $this->question->id => 0],
            'current_index' => 1,
            'version' => config('questionnaire.version', 'q_v2'),
            'bank_version' => config('questionnaire.bank_version', 'qb_v1'),
        ];
        $this->postJson('/api/v1/questionnaire/draft', $payload)->assertOk();
        $row = DB::table('questionnaire_drafts')->where('user_id', $this->account->id)->first();
        $this->assertNotNull($row);
        $this->assertEquals($payload, json_decode($row->payload, true));
        $this->getJson('/api/v1/questionnaire/draft')->assertOk()->assertExactJson($payload);
        $other = User::factory()->create(['phone' => '19900000742', 'disabled' => false]);
        Sanctum::actingAs($other);
        $this->getJson('/api/v1/questionnaire/draft')->assertOk()->assertExactJson([]);
        $this->assertDatabaseCount('questionnaire_drafts', 1);
        Sanctum::actingAs($this->account);
        $this->getJson('/api/v1/questionnaire/draft')->assertOk()->assertExactJson($payload);
    }

    public function test_invalid_draft_index_does_not_replace_saved_snapshot(): void
    {
        $payload = [
            'answers' => [(string) $this->question->id => 0], 'current_index' => 1,
            'version' => config('questionnaire.version', 'q_v2'),
            'bank_version' => config('questionnaire.bank_version', 'qb_v1'),
        ];
        $this->postJson('/api/v1/questionnaire/draft', $payload)->assertOk();
        $invalid = $payload;
        $invalid['answers'][(string) $this->question->id] = count($this->question->options);
        $this->postJson('/api/v1/questionnaire/draft', $invalid)->assertUnprocessable();
        $this->getJson('/api/v1/questionnaire/draft')->assertOk()->assertExactJson($payload);
    }

    public function test_seeder_retains_unrelated_history_and_disables_research(): void
    {
        $historical = $this->question->replicate();
        $historical->question_key = 'V1007_UNRELATED_HISTORICAL_FIXTURE';
        $historical->save();
        $this->seed(QuestionnaireQuestionSeeder::class);
        $this->assertDatabaseHas('questionnaire_questions', ['id' => $historical->id, 'question_key' => $historical->question_key]);
        $this->assertGreaterThan(0, QuestionnaireQuestion::where('recommended_bank', 'research')->count());
        $this->assertSame(0, QuestionnaireQuestion::where('recommended_bank', 'research')->where('enabled', true)->count());
    }

    public function test_question_session_order_survives_partial_draft_and_ignores_client_snapshot(): void
    {
        $first = $this->getJson('/api/v1/questionnaire/questions')->assertOk()->json();
        $ids = array_column($first['questions'] ?? $first['items'], 'id');
        $this->assertNotEmpty($ids);
        $payload = [
            'answers' => [(string) $ids[0] => 0], 'current_index' => 1,
            'version' => config('questionnaire.version', 'q_v2'),
            'bank_version' => config('questionnaire.bank_version', 'qb_v1'),
            'question_ids' => [999999],
        ];
        $this->postJson('/api/v1/questionnaire/draft', $payload)->assertOk();
        $draft = $this->getJson('/api/v1/questionnaire/draft')->assertOk();
        $draft->assertJsonPath('current_index', 1)
            ->assertJsonPath('answers.'.(string) $ids[0], 0)
            ->assertJsonPath('question_ids', $ids);
        $second = $this->getJson('/api/v1/questionnaire/questions')->assertOk()->json();
        $this->assertSame($ids, array_column($second['questions'] ?? $second['items'], 'id'));
        $other = User::factory()->create(['phone' => '19900000743', 'disabled' => false]);
        Sanctum::actingAs($other);
        $this->getJson('/api/v1/questionnaire/draft')->assertOk()->assertExactJson([]);
    }

    public function test_stale_draft_version_or_bank_does_not_override_current_snapshot(): void
    {
        $payload = [
            'answers' => [(string) $this->question->id => 0], 'current_index' => 1,
            'version' => config('questionnaire.version', 'q_v2'),
            'bank_version' => config('questionnaire.bank_version', 'qb_v1'),
        ];
        $this->postJson('/api/v1/questionnaire/draft', $payload)->assertOk();
        foreach (['version', 'bank_version'] as $field) {
            $invalid = $payload;
            $invalid[$field] = 'stale_'.$payload[$field];
            $invalid['current_index'] = 2;
            $this->postJson('/api/v1/questionnaire/draft', $invalid)->assertUnprocessable();
            $this->getJson('/api/v1/questionnaire/draft')->assertOk()->assertExactJson($payload);
        }
    }

    public function test_questions_replace_stale_nonempty_snapshot_and_clear_incompatible_draft(): void
    {
        foreach (['version', 'bank_version'] as $field) {
            $oldIds = [999991, 999992];
            $payload = [
                'answers' => ['999991' => 1], 'current_index' => 9,
                'version' => config('questionnaire.version', 'q_v2'),
                'bank_version' => config('questionnaire.bank_version', 'qb_v1'),
                'question_ids' => $oldIds,
            ];
            $payload[$field] = 'old_'.$payload[$field];
            DB::table('questionnaire_drafts')->updateOrInsert(
                ['user_id' => $this->account->id],
                ['payload' => json_encode($payload), 'created_at' => now(), 'updated_at' => now()],
            );
            $questions = $this->getJson('/api/v1/questionnaire/questions')->assertOk()->json();
            $ids = array_column($questions['questions'] ?? $questions['items'], 'id');
            $this->assertNotEmpty($ids);
            $this->assertNotSame($oldIds, $ids);
            $draft = $this->getJson('/api/v1/questionnaire/draft')->assertOk()->json();
            $this->assertSame($ids, $draft['question_ids']);
            $this->assertSame([], $draft['answers']);
            $this->assertSame(0, $draft['current_index']);
            $this->assertSame(config('questionnaire.version', 'q_v2'), $draft['version']);
            $this->assertSame(config('questionnaire.bank_version', 'qb_v1'), $draft['bank_version']);
        }
    }

    public function test_local_legacy_formats_cannot_bypass_question_bank_guards(): void
    {
        config(['restoration.enabled' => true]);
        $research = QuestionnaireQuestion::where('recommended_bank', 'research')->firstOrFail();
        foreach (['selected_answer', 'answer'] as $field) {
            $canonical = $this->question->options[0]['option_id'];
            $legacy = ['question_id' => $this->question->id, 'version' => $this->question->version,
                $field => $field === 'selected_answer' ? [$canonical] : $canonical];
            $invalid = [
                array_replace($legacy, ['question_id' => $research->id, 'version' => $research->version,
                    $field => $field === 'selected_answer' ? [$research->options[0]['option_id']] : $research->options[0]['option_id']]),
                array_replace($legacy, [$field => $field === 'selected_answer' ? ['NOT_IN_BANK'] : 'NOT_IN_BANK']),
                array_replace($legacy, ['version' => $this->question->version + 1]),
                array_diff_key($legacy, ['version' => true]),
                array_replace($legacy, ['acceptable_answers' => ['NOT_IN_BANK']]),
            ];
            foreach ($invalid as $bad) {
                $this->postJson('/api/v1/questionnaire/answers', ['answers' => [$this->answer(), $bad]])->assertUnprocessable();
                $this->assertDatabaseCount('questionnaire_answers', 0);
                $this->assertDatabaseCount('questionnaire_attempts', 0);
            }
        }
    }

    public function test_local_legal_legacy_selected_answer_persists_canonical_bank_identity(): void
    {
        config(['restoration.enabled' => true]);
        $option = $this->question->options[0]['option_id'];
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [[
            'question_id' => $this->question->id, 'selected_answer' => [$option],
            'acceptable_answers' => [$option], 'importance' => 2, 'version' => $this->question->version,
        ]]])->assertOk();
        $saved = QuestionnaireAnswer::where('user_id', $this->account->id)->firstOrFail();
        $this->assertSame($option, $saved->answer_payload['value']);
        $this->assertSame([$option], $saved->selected_answer_json);
        $this->assertSame([$option], $saved->acceptable_answers_json);
        $this->assertSame($this->question->version, $saved->version);
        $this->assertDatabaseCount('questionnaire_attempts', 1);
    }
}
