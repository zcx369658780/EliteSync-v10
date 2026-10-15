<?php

namespace Tests\Feature;

use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\Admin\OperationAudit;
use App\Services\Admin\QuestionOperations;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\Sanctum;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

final class V1008QuestionOperationsTest extends TestCase
{
    use RefreshDatabase;

    private QuestionnaireQuestion $question;

    private User $actor;

    protected function setUp(): void
    {
        parent::setUp();
        config(['app.key' => 'base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=']);
        DB::table('admin_versions')->updateOrInsert(['key' => 'questionnaire'], ['revision' => 1]);
        $this->actor = User::factory()->create(['phone' => '19900000851', 'role' => 'admin', 'disabled' => false]);
        config(['app.admin_phones' => [$this->actor->phone]]);
        $this->question = QuestionnaireQuestion::create([
            'question_key' => 'V1008_LOW_DROP', 'content' => '虚构题目', 'quality_tag' => 'low_drop',
            'enabled' => true, 'version' => 1, 'category' => 'v1008_fixture', 'sort_order' => 0,
            'question_type' => 'single_choice', 'recommended_bank' => 'core', 'quality_tier' => 'normal',
        ]);
    }

    public function test_preview_is_read_only_and_counts_history_without_returning_private_payloads(): void
    {
        $this->history();
        $before = $this->snapshots();
        $preview = app(QuestionOperations::class)->preview([$this->question->id], false);
        $this->assertTrue($preview['dry_run']);
        $this->assertSame(1, $preview['impact']['answers']);
        $this->assertSame(1, $preview['impact']['attempts']);
        $this->assertSame(1, $preview['impact']['drafts']);
        $this->assertSame($before, $this->snapshots());
        $this->assertStringNotContainsString('PRIVATE_FIXTURE_VALUE', json_encode($preview));
        $this->assertDatabaseCount('admin_operation_audits', 0);
        $this->assertTrue($this->question->fresh()->enabled);
    }

    public function test_disable_and_restore_increment_versions_and_preserve_history(): void
    {
        $this->history();
        $before = $this->snapshots();
        $service = app(QuestionOperations::class);
        foreach ([false, true] as $enabled) {
            $preview = $service->preview([$this->question->id], $enabled);
            $service->apply([$this->question->id], $enabled, $preview['expected_revision'],
                $preview['preview_signature'], '具名虚构数据纠错', $this->actor->id);
            $this->assertSame($enabled, $this->question->fresh()->enabled);
        }
        $this->assertSame(3, $this->question->fresh()->version);
        $this->assertDatabaseHas('admin_versions', ['key' => 'questionnaire', 'revision' => 3]);
        $this->assertDatabaseCount('admin_operation_audits', 2);
        $this->assertSame($before, $this->snapshots());
    }

    public function test_stale_revision_or_tampered_signature_does_not_write(): void
    {
        $service = app(QuestionOperations::class);
        $preview = $service->preview([$this->question->id], false);
        foreach ([[$preview['expected_revision'] + 1, $preview['preview_signature']], [$preview['expected_revision'], str_repeat('0', 64)]] as [$revision, $signature]) {
            try {
                $service->apply([$this->question->id], false, $revision, $signature, '原因', $this->actor->id);
                $this->fail('Expected conflict');
            } catch (HttpException $error) {
                $this->assertSame(409, $error->getStatusCode());
            }
        }
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_question_version_change_invalidates_preview_even_without_revision_change(): void
    {
        $service = app(QuestionOperations::class);
        $preview = $service->preview([$this->question->id], false);
        $this->question->update(['version' => 2]);
        try {
            $service->apply([$this->question->id], false, 1, $preview['preview_signature'], '原因', $this->actor->id);
            $this->fail('Expected conflict');
        } catch (HttpException $error) {
            $this->assertSame(409, $error->getStatusCode());
        }
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_non_low_drop_disable_and_unaudited_restore_are_rejected(): void
    {
        $service = app(QuestionOperations::class);
        foreach ([['quality_tag' => 'pass', 'enabled' => true, 'target' => false], ['quality_tag' => 'low_drop', 'enabled' => false, 'target' => true]] as $state) {
            $target = $state['target'];
            unset($state['target']);
            $this->question->update($state);
            try {
                $service->preview([$this->question->id], $target);
                $this->fail('Expected invalid operation');
            } catch (ValidationException $error) {
                $this->assertArrayHasKey('ids', $error->errors());
            }
        }
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_missing_confirmation_cannot_apply_from_web(): void
    {
        $preview = app(QuestionOperations::class)->preview([$this->question->id], false);
        $this->actingAs($this->actor, 'web')->postJson('/admin/questions/apply', [
            'ids' => [$this->question->id], 'enabled' => false,
            'expected_revision' => $preview['expected_revision'], 'preview_signature' => $preview['preview_signature'], 'reason' => '原因',
        ])->assertUnprocessable();
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_prune_api_defaults_to_read_only_preview_without_confirmation(): void
    {
        Sanctum::actingAs($this->actor);
        foreach ([[], ['dry_run' => true]] as $payload) {
            $this->postJson('/api/v1/admin/questionnaire/prune-low-drop', $payload)
                ->assertOk()->assertJsonPath('dry_run', true)
                ->assertJsonPath('candidates', 1)->assertJsonPath('updated', 0)
                ->assertJsonPath('expected_revision', 1);
        }
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertSame(1, $this->question->fresh()->version);
        $this->assertDatabaseHas('admin_versions', ['key' => 'questionnaire', 'revision' => 1]);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_prune_api_apply_without_confirmation_is_rejected_even_with_valid_preview(): void
    {
        Sanctum::actingAs($this->actor);
        $preview = app(QuestionOperations::class)->preview([$this->question->id], false);
        $response = $this->postJson('/api/v1/admin/questionnaire/prune-low-drop', [
            'dry_run' => false, 'expected_revision' => $preview['expected_revision'],
            'preview_signature' => $preview['preview_signature'], 'reason' => '具名停用原因',
        ])->assertUnprocessable()->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'validation_error');
        // This API wraps validation fields under error.details, not Laravel's errors key.
        $this->assertSame(['confirm'], array_keys($response->json('error.details')));
        $this->assertNotEmpty($response->json('error.details.confirm'));
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertSame(1, $this->question->fresh()->version);
        $this->assertDatabaseHas('admin_versions', ['key' => 'questionnaire', 'revision' => 1]);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_service_rechecks_current_admin_authority_before_applying(): void
    {
        $service = app(QuestionOperations::class);
        $preview = $service->preview([$this->question->id], false);
        $this->actor->update(['disabled' => true]);
        try {
            $service->apply([$this->question->id], false, 1, $preview['preview_signature'], '原因', $this->actor->id);
            $this->fail('Expected forbidden');
        } catch (HttpException $error) {
            $this->assertSame(403, $error->getStatusCode());
        }
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertDatabaseHas('admin_versions', ['key' => 'questionnaire', 'revision' => 1]);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_audit_failure_rolls_back_question_and_global_revision(): void
    {
        $service = app(QuestionOperations::class);
        $preview = $service->preview([$this->question->id], false);
        $this->app->instance(OperationAudit::class, new class
        {
            public function record(...$arguments): void
            {
                throw new \RuntimeException('fixture audit failure');
            }
        });
        try {
            $service->apply([$this->question->id], false, 1, $preview['preview_signature'], '原因', $this->actor->id);
            $this->fail('Expected audit failure');
        } catch (\RuntimeException $error) {
            $this->assertSame('fixture audit failure', $error->getMessage());
        }
        $this->assertTrue($this->question->fresh()->enabled);
        $this->assertSame(1, $this->question->fresh()->version);
        $this->assertDatabaseHas('admin_versions', ['key' => 'questionnaire', 'revision' => 1]);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    private function history(): void
    {
        $now = now();
        DB::table('questionnaire_answers')->insert([
            'user_id' => $this->actor->id, 'questionnaire_question_id' => $this->question->id,
            'answer_payload' => json_encode(['value' => 'PRIVATE_FIXTURE_VALUE']), 'version' => 1,
            'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('questionnaire_attempts')->insert([
            'user_id' => $this->actor->id, 'questionnaire_version' => 'q_v2', 'bank_version' => 'qb_v1',
            'attempt_version' => 'qa_v1', 'answers_count' => 1, 'total_count' => 1,
            'answers_json' => json_encode([['question_id' => $this->question->id, 'answer' => 'PRIVATE_FIXTURE_VALUE']]),
            'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('questionnaire_drafts')->insert([
            'user_id' => $this->actor->id, 'payload' => json_encode(['question_ids' => [$this->question->id], 'answers' => []]),
            'created_at' => $now, 'updated_at' => $now,
        ]);
    }

    private function snapshots(): array
    {
        $result = [];
        foreach (['questionnaire_answers', 'questionnaire_attempts', 'questionnaire_drafts', 'dating_matches'] as $table) {
            $result[$table] = json_encode(DB::table($table)->orderBy('id')->get());
        }

        return $result;
    }
}
