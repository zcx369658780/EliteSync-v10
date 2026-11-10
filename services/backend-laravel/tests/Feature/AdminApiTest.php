<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminApiTest extends TestCase
{
    use RefreshDatabase;

    private function fullAnswersPayload(): array
    {
        $ids = QuestionnaireQuestion::query()->where('enabled', true)->orderBy('sort_order')->pluck('id');

        return $ids->map(fn ($id) => ['question_id' => (int) $id, 'answer' => 'A'])->values()->all();
    }

    public function test_verify_queue_and_update_flow(): void
    {
        $admin = User::create([
            'phone' => '13800000101',
            'name' => 'admin',
            'password' => 'secret123',
            'role' => 'admin',
            'verify_status' => 'approved',
        ]);

        $pendingUser = User::create([
            'phone' => '13800000102',
            'name' => 'pending',
            'password' => 'secret123',
            'verify_status' => 'pending',
            'is_match_eligible' => true,
            'is_square_visible' => true,
            'exclude_from_metrics' => false,
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/admin/verify-queue')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $pendingUser->id);

        $this->postJson('/api/v1/admin/verify/'.$pendingUser->id, [
            'status' => 'approved','reason'=>'approved operating fixture','expected_revision'=>0,'confirm'=>'1',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/admin/users/'.$pendingUser->id.'/disable',['reason'=>'disable fixture','expected_revision'=>0,'confirm'=>'1'])
            ->assertOk()
            ->assertJsonPath('ok', true);

        $pendingUser->refresh();
        $this->assertTrue((bool) $pendingUser->disabled);
        $this->assertSame('banned', $pendingUser->moderation_status);
        $this->assertSame('disabled', $pendingUser->account_status);
        $this->assertSame('hidden', $pendingUser->visibility_scope);
        $this->assertFalse((bool) $pendingUser->is_match_eligible);
        $this->assertFalse((bool) $pendingUser->is_square_visible);
        $this->assertTrue((bool) $pendingUser->exclude_from_metrics);

        $this->getJson('/api/v1/admin/users')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $pendingUser->id,
                'role' => 'user',
                'account_type' => 'normal',
                'verify_status' => 'approved',
                'disabled' => true,
            ]);
    }

    public function test_admin_users_exposes_batch_audit_fields_and_filters_by_batch_id(): void
    {
        $admin = User::create([
            'phone' => '13800000103',
            'name' => 'admin-batch',
            'password' => 'secret123',
            'role' => 'admin',
            'verify_status' => 'approved',
        ]);

        $batchUser = User::create([
            'phone' => '13800000104',
            'name' => 'syn-batch-user',
            'password' => 'secret123',
            'account_type' => 'test',
            'verify_status' => 'approved',
            'is_synthetic' => true,
            'synthetic_batch' => 'batch-a',
            'synthetic_batch_id' => 'batch-a-id',
            'synthetic_seed' => 20260410,
            'generation_version' => 'v32',
            'account_status' => 'active',
            'visibility_scope' => 'square',
            'cleanup_token' => 'token-batch-a',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/admin/users?synthetic_batch=batch-a-id')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonFragment([
                'id' => $batchUser->id,
                'account_type' => 'test',
                'synthetic_batch' => 'batch-a',
                'synthetic_batch_id' => 'batch-a-id',
                'synthetic_seed' => 20260410,
                'generation_version' => 'v32',
                'account_status' => 'active',
                'visibility_scope' => 'square',
                'cleanup_token' => 'token-batch-a',
                'is_match_eligible' => true,
                'is_square_visible' => true,
                'exclude_from_metrics' => false,
            ]);
    }

    public function test_dev_matching_and_release_drop_flow(): void
    {
        $admin=User::create(['phone'=>'19900999901','role'=>'admin','password'=>'fixture-password']);
        config(['app.admin_phones'=>[$admin->phone]]);Sanctum::actingAs($admin);
        $before=DatingMatch::count();
        foreach(['/api/v1/admin/dev/run-matching','/api/v1/admin/dev/release-drop','/api/v1/admin/dev/matching-debug'] as $path)$this->postJson($path)->assertForbidden();
        $this->assertSame($before,DatingMatch::count());
        $this->assertDatabaseCount('matching_runs',0);$this->assertDatabaseCount('matching_operation_audits',0);
    }

    public function test_dev_matching_handles_multiple_chunks_without_key_error(): void
    {
        $admin=User::create(['phone'=>'19900999901','role'=>'admin','password'=>'fixture-password']);
        config(['app.admin_phones'=>[$admin->phone]]);Sanctum::actingAs($admin);
        $before=DatingMatch::count();
        foreach(['/api/v1/admin/dev/run-matching','/api/v1/admin/dev/release-drop','/api/v1/admin/dev/matching-debug'] as $path)$this->postJson($path)->assertForbidden();
        $this->assertSame($before,DatingMatch::count());
        $this->assertDatabaseCount('matching_runs',0);$this->assertDatabaseCount('matching_operation_audits',0);
    }

    public function test_dev_matching_can_toggle_synthetic_user_inclusion(): void
    {
        $admin=User::create(['phone'=>'19900999901','role'=>'admin','password'=>'fixture-password']);
        config(['app.admin_phones'=>[$admin->phone]]);Sanctum::actingAs($admin);
        $before=DatingMatch::count();
        foreach(['/api/v1/admin/dev/run-matching','/api/v1/admin/dev/release-drop','/api/v1/admin/dev/matching-debug'] as $path)$this->postJson($path)->assertForbidden();
        $this->assertSame($before,DatingMatch::count());
        $this->assertDatabaseCount('matching_runs',0);$this->assertDatabaseCount('matching_operation_audits',0);
    }

    public function test_admin_endpoints_forbid_non_admin_user(): void
    {
        $admin = User::create([
            'phone' => '13800000131',
            'name' => 'admin3',
            'password' => 'secret123',
            'role' => 'admin',
            'verify_status' => 'approved',
        ]);
        $normal = User::create([
            'phone' => '13800000132',
            'name' => 'normal',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($normal);

        $this->getJson('/api/v1/admin/users')
            ->assertStatus(403)
            ->assertJsonPath('message', 'admin access required');
    }

    public function test_admin_endpoints_forbid_whitelisted_phone_without_admin_role(): void
    {
        $normal = User::create([
            'phone' => '13800000133',
            'name' => 'whitelisted-normal',
            'password' => 'secret123',
            'role' => 'user',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$normal->phone]);
        Sanctum::actingAs($normal);

        $this->getJson('/api/v1/admin/users')
            ->assertStatus(403)
            ->assertJsonPath('message', 'admin access required');
    }

    public function test_question_quality_stats_endpoint_returns_reason_breakdown(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000141',
            'name' => 'admin4',
            'password' => 'secret123',
            'role' => 'admin',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $resp = $this->getJson('/api/v1/admin/questionnaire/quality-stats')
            ->assertOk()
            ->assertJsonStructure([
                'total',
                'by_tier',
                'by_tag',
                'reasons' => [['quality_tier', 'quality_tag', 'quality_reason', 'count']],
                'low_drop_reasons',
            ])
            ->json();

        $this->assertGreaterThan(0, (int) ($resp['total'] ?? 0));
        $this->assertNotEmpty($resp['by_tier'] ?? []);
        $this->assertNotEmpty($resp['by_tag'] ?? []);
        $this->assertNotEmpty($resp['reasons'] ?? []);
    }

    public function test_prune_low_drop_questions_supports_dry_run_and_apply(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000151',
            'name' => 'admin5',
            'password' => 'secret123',
            'role' => 'admin',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $initial = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->where('quality_tag', 'low_drop')
            ->count();
        if ($initial === 0) {
            QuestionnaireQuestion::query()->create([
                'question_key' => 'TEST_LOW_DROP_001',
                'category' => 'values',
                'subtopic' => 'test',
                'recommended_bank' => 'core',
                'quality_tier' => 'normal',
                'quality_tag' => 'low_drop',
                'quality_reason' => 'test_seed',
                'content' => 'test low drop question',
                'question_text_zh' => 'test low drop question',
                'question_text_en' => 'test low drop question',
                'question_type' => 'single_choice',
                'acceptable_answer_logic' => 'single_select',
                'options' => [
                    ['option_id' => 'A', 'label' => ['zh' => 'A', 'en' => 'A'], 'dimension_weights' => [], 'evaluation_standard' => ['code' => 'T', 'zh' => 'T', 'en' => 'T'], 'score' => 1],
                ],
                'sort_order' => 999999,
                'enabled' => true,
                'version' => 1,
            ]);
            $initial = 1;
        }
        $this->assertGreaterThan(0, $initial);

        $dryRun = $this->postJson('/api/v1/admin/questionnaire/prune-low-drop', [
            'dry_run' => true,
        ])->assertOk()->json();

        $this->assertTrue((bool) ($dryRun['ok'] ?? false));
        $this->assertTrue((bool) ($dryRun['dry_run'] ?? false));
        $this->assertSame($initial, (int) ($dryRun['candidates'] ?? -1));
        $this->assertSame(0, (int) ($dryRun['updated'] ?? -1));

        $apply = $this->postJson('/api/v1/admin/questionnaire/prune-low-drop', [
            'dry_run' => false,'expected_revision'=>$dryRun['expected_revision'],'preview_signature'=>$dryRun['preview_signature'],'reason'=>'retire low drop fixture','confirm'=>'1',
        ])->assertOk()->json();

        $this->assertTrue((bool) ($apply['ok'] ?? false));
        $this->assertFalse((bool) ($apply['dry_run'] ?? true));
        $this->assertSame($initial, (int) ($apply['updated'] ?? -1));

        $after = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->where('quality_tag', 'low_drop')
            ->count();
        $this->assertSame(0, $after);
    }
}
