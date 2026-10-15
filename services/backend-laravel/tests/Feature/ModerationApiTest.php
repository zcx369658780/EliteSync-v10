<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\ModerationReport;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ModerationApiTest extends TestCase
{
    use RefreshDatabase;

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function test_report_block_and_appeal_flow(): void
    {
        $reporter = User::create([
            'phone' => '13800003001',
            'name' => 'Reporter',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $target = User::create([
            'phone' => '13800003002',
            'name' => 'Target',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        Sanctum::actingAs($reporter);

        $report = $this->postJson('/api/v1/moderation/reports', [
            'target_user_id' => $target->id,
            'category' => 'user',
            'reason_code' => 'harassment',
            'detail' => 'test report',
        ])
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('report.status', 'new')
            ->json('report');

        $this->postJson('/api/v1/moderation/blocks', [
            'blocked_user_id' => $target->id,
            'reason_code' => 'chat_menu',
        ])
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/moderation/blocks')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.blocked_user_id', $target->id);

        $reportId = (int) $report['id'];
        $this->postJson("/api/v1/moderation/reports/{$reportId}/appeal", [
            'appeal_note' => 'please review',
        ])
            ->assertOk()
            ->assertJsonPath('report.appeal_status', 'submitted');

        $this->assertDatabaseHas('moderation_reports', [
            'id' => $reportId,
            'appeal_status' => 'submitted',
        ]);
    }

    public function test_block_prevents_chat_send(): void
    {
        $userA = User::create([
            'phone' => '13800003003',
            'name' => 'A',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $userB = User::create([
            'phone' => '13800003004',
            'name' => 'B',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/moderation/blocks', [
            'blocked_user_id' => $userB->id,
            'reason_code' => 'chat_menu',
        ])->assertOk();

        $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'hello',
        ])->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);
        $this->assertDatabaseCount('chat_messages', 0);
        // The route guard denies before the legacy internal block gate executes.
    }

    public function test_admin_report_action_updates_user_status(): void
    {
        config(['app.admin_phones' => ['18000000000']]);

        $admin = User::create([
            'phone' => '18000000000',
            'name' => 'Admin',
            'password' => 'secret123',
            'role' => 'admin',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $reporter = User::create([
            'phone' => '13800003005',
            'name' => 'Reporter2',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $target = User::create([
            'phone' => '13800003006',
            'name' => 'Target2',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        $report = ModerationReport::create([
            'reporter_id' => $reporter->id,
            'target_user_id' => $target->id,
            'category' => 'user',
            'reason_code' => 'spam',
            'status' => 'new',
        ]);

        $oldTokenId = $target->createToken('pre-ban')->accessToken->id;
        DB::table('sessions')->insert(['id' => 'moderation-target-session', 'user_id' => $target->id,
            'payload' => '', 'last_activity' => time()]);
        $oldRememberToken = $target->remember_token;
        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/admin/reports/'.$report->id.'/action', [
            'action' => 'banned',
            'note' => 'confirmed spam',
            'expected_revision' => 0,
            'expected_user_revision' => 0,
            'reason' => 'confirmed spam',
            'confirm' => true,
        ])->assertOk()->assertJsonPath('ok', true);
        // Mutation now acknowledges success; report detail still proves the resulting status.
        $this->getJson('/api/v1/admin/reports/'.$report->id)->assertOk()
            ->assertJsonPath('status', 'action_taken');
        $this->assertDatabaseHas('moderation_reports', ['id' => $report->id,
            'status' => 'action_taken', 'admin_revision' => 1, 'resolved_by_user_id' => $admin->id]);
        $this->assertDatabaseHas('users', [
            'id' => $target->id,
            'disabled' => true,
            'moderation_status' => 'banned',
        ]);
        $this->assertDatabaseHas('users', ['id' => $target->id, 'admin_revision' => 1,
            'account_status' => 'disabled', 'visibility_scope' => 'hidden', 'is_match_eligible' => false]);
        $this->assertDatabaseMissing('personal_access_tokens', ['id' => $oldTokenId]);
        $this->assertDatabaseMissing('sessions', ['user_id' => $target->id]);
        $this->assertNotSame($oldRememberToken, $target->fresh()->remember_token);
        $sanction = DB::table('admin_sanctions')->where('user_id', $target->id)
            ->where('report_id', $report->id)->where('kind', 'banned')->where('active', true)->sole();
        $this->assertSame($admin->id, (int) $sanction->actor_user_id);
        foreach (['user.banned' => 'user', 'report.banned' => 'report'] as $action => $type) {
            $this->assertDatabaseHas('admin_operation_audits', ['actor_user_id' => $admin->id,
                'action' => $action, 'target_type' => $type,
                'target_id' => (string) ($type === 'user' ? $target->id : $report->id),
                'expected_version' => 0, 'reason' => 'confirmed spam']);
        }
        $this->assertDatabaseCount('admin_operation_audits', 2);

        // Restore must identify this exact active sanction and retain revoked credentials.
        $this->postJson('/api/v1/admin/reports/'.$report->id.'/action', [
            'action' => 'restore', 'sanction_id' => $sanction->id,
            'expected_revision' => 1, 'expected_user_revision' => 1,
            'reason' => 'Reviewed this fixture sanction', 'confirm' => true,
        ])->assertOk()->assertJsonPath('ok', true);
        $this->assertDatabaseHas('admin_sanctions', ['id' => $sanction->id, 'active' => false,
            'restored_by' => $admin->id]);
        $this->assertDatabaseHas('users', ['id' => $target->id, 'disabled' => false,
            'moderation_status' => 'normal', 'account_status' => 'active', 'admin_revision' => 2]);
        $this->assertDatabaseHas('moderation_reports', ['id' => $report->id,
            'status' => 'closed', 'admin_revision' => 2]);
        $this->assertDatabaseMissing('personal_access_tokens', ['id' => $oldTokenId]);
        $this->assertDatabaseMissing('sessions', ['user_id' => $target->id]);
        $this->assertDatabaseCount('admin_operation_audits', 4);
        foreach (['user.restore' => 'user', 'report.restore' => 'report'] as $action => $type) {
            $this->assertDatabaseHas('admin_operation_audits', ['actor_user_id' => $admin->id,
                'action' => $action, 'target_type' => $type,
                'target_id' => (string) ($type === 'user' ? $target->id : $report->id),
                'expected_version' => 1, 'reason' => 'Reviewed this fixture sanction']);
        }
    }
}
