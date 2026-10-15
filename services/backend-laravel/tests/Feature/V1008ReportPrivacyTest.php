<?php

namespace Tests\Feature;

use App\Models\ChatMessage;
use App\Models\ModerationReport;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1008ReportPrivacyTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    private User $reporter;

    private User $target;

    protected function setUp(): void
    {
        parent::setUp();
        $this->admin = $this->account('19900000871', 'admin');
        $this->reporter = $this->account('19900000872');
        $this->target = $this->account('19900000873');
        config(['app.admin_phones' => [$this->admin->phone]]);
        Sanctum::actingAs($this->admin);
    }

    public function test_report_list_is_bounded_and_omits_sensitive_explanations_and_contact_identity(): void
    {
        for ($i = 0; $i < 23; $i++) {
            $this->report();
        }
        DB::enableQueryLog();
        $first = $this->getJson('/api/v1/admin/reports')->assertOk()
            ->assertJsonCount(20, 'items')->assertJsonPath('total', 23)
            ->assertJsonPath('per_page', 20)->assertJsonPath('current_page', 1)
            ->assertJsonPath('last_page', 2);
        $second = $this->getJson('/api/v1/admin/reports?page=2')->assertOk()
            ->assertJsonCount(3, 'items')->assertJsonPath('total', 23);
        $queries = DB::getQueryLog();
        DB::disableQueryLog();
        $firstIds = array_column($first->json('items'), 'id');
        $secondIds = array_column($second->json('items'), 'id');
        $this->assertSame([], array_intersect($firstIds, $secondIds));
        $this->assertGreaterThan(max($secondIds), min($firstIds));
        foreach ($first->json('items') as $item) {
            foreach (['detail', 'appeal_note', 'admin_note', 'phone'] as $field) {
                $this->assertArrayNotHasKey($field, $item);
            }
            $this->assertSame(['id'], array_keys($item['reporter']));
            $this->assertSame(['id'], array_keys($item['resolver']));
            $this->assertSame(['id', 'disabled', 'moderation_status'], array_keys($item['target_user']));
        }
        $this->assertStringNotContainsString('PRIVATE_', $first->getContent());
        foreach ([$this->admin, $this->reporter, $this->target] as $user) {
            $this->assertStringNotContainsString($user->phone, $first->getContent());
        }
        $this->assertNoMessageReads($queries);
        foreach ($queries as $query) {
            if (str_contains($query['query'], 'moderation_reports')) {
                $this->assertStringNotContainsString('"detail"', $query['query']);
                $this->assertStringNotContainsString('"appeal_note"', $query['query']);
            }
        }
        $this->assertDatabaseCount('admin_operation_audits', 0);
        $this->getJson('/api/v1/admin/reports?per_page=101')->assertUnprocessable();
    }

    public function test_legal_detail_returns_report_explanation_with_minimal_audit_and_never_reads_private_message(): void
    {
        $message = ChatMessage::create(['room_id' => 'v1008-privacy', 'sender_id' => $this->reporter->id,
            'receiver_id' => $this->target->id, 'content' => 'PRIVATE_CONVERSATION_CONTENT']);
        $report = $this->report(['category' => 'message', 'target_message_id' => $message->id]);
        $storedMessage = DB::table('chat_messages')->where('id', $message->id)->first();
        DB::enableQueryLog();
        $response = $this->getJson('/api/v1/admin/reports/'.$report->id)->assertOk()
            ->assertJsonPath('detail', 'PRIVATE_REPORT_EXPLANATION')
            ->assertJsonPath('appeal_note', 'PRIVATE_APPEAL_EXPLANATION')
            ->assertJsonPath('admin_revision', 0)
            ->assertJsonPath('target_message_id', $message->id)
            ->assertJsonPath('target_user.id', $this->target->id);
        $queries = DB::getQueryLog();
        DB::disableQueryLog();
        $this->assertNoMessageReads($queries);
        $this->assertStringNotContainsString('PRIVATE_CONVERSATION_CONTENT', $response->getContent());
        $this->assertStringNotContainsString('PRIVATE_USER_NAME', $response->getContent());
        foreach ([$this->admin, $this->reporter, $this->target] as $user) {
            $this->assertStringNotContainsString($user->phone, $response->getContent());
        }
        $this->assertSame(['id', 'disabled', 'moderation_status'], array_keys($response->json('target_user')));
        $audit = DB::table('admin_operation_audits')->sole();
        $this->assertSame($this->admin->id, (int) $audit->actor_user_id);
        $this->assertSame('report.view', $audit->action);
        $this->assertSame('report', $audit->target_type);
        $this->assertSame((string) $report->id, $audit->target_id);
        $this->assertSame('case detail view', $audit->reason);
        $this->assertSame([], json_decode($audit->before_state, true));
        $this->assertSame(['category' => 'message'], json_decode($audit->after_state, true));
        $this->assertNull($audit->expected_version);
        $this->assertEquals($storedMessage, DB::table('chat_messages')->where('id', $message->id)->first());
    }

    public function test_ordinary_role_only_list_only_and_disabled_admin_cannot_open_report_explanations(): void
    {
        $report = $this->report();
        foreach ([['user', true, false], ['admin', false, false], ['admin', true, true]] as [$role, $listed, $disabled]) {
            $this->admin->forceFill(['role' => $role, 'disabled' => $disabled])->save();
            config(['app.admin_phones' => $listed ? [$this->admin->phone] : []]);
            Sanctum::actingAs($this->admin->fresh());
            foreach (['/api/v1/admin/reports', '/api/v1/admin/reports/'.$report->id] as $url) {
                $response = $this->getJson($url)->assertForbidden();
                $this->assertStringNotContainsString('PRIVATE_REPORT_EXPLANATION', $response->getContent());
            }
        }
        Sanctum::actingAs($this->reporter);
        $this->getJson('/api/v1/admin/reports/'.$report->id)->assertForbidden();
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_missing_report_does_not_create_a_successful_access_audit(): void
    {
        $this->getJson('/api/v1/admin/reports/999999')->assertNotFound();
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_audit_failure_prevents_sensitive_detail_delivery(): void
    {
        $report = $this->report();
        DB::unprepared("CREATE TRIGGER reject_fixture_report_audit BEFORE INSERT ON admin_operation_audits BEGIN SELECT RAISE(ABORT, 'fixture audit unavailable'); END");
        $response = $this->getJson('/api/v1/admin/reports/'.$report->id)->assertStatus(500);
        $this->assertStringNotContainsString('PRIVATE_REPORT_EXPLANATION', $response->getContent());
        $this->assertStringNotContainsString('PRIVATE_APPEAL_EXPLANATION', $response->getContent());
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    private function account(string $phone, string $role = 'user'): User
    {
        return User::factory()->create(['phone' => $phone, 'name' => 'PRIVATE_USER_NAME',
            'role' => $role, 'disabled' => false, 'is_synthetic' => false, 'verify_status' => 'approved']);
    }

    private function report(array $overrides = []): ModerationReport
    {
        return ModerationReport::create(array_replace(['reporter_id' => $this->reporter->id,
            'target_user_id' => $this->target->id, 'category' => 'user', 'reason_code' => 'fixture',
            'detail' => 'PRIVATE_REPORT_EXPLANATION', 'appeal_note' => 'PRIVATE_APPEAL_EXPLANATION',
            'admin_note' => 'PRIVATE_ADMIN_NOTE'], $overrides));
    }

    private function assertNoMessageReads(array $queries): void
    {
        foreach ($queries as $query) {
            $this->assertStringNotContainsString('chat_messages', $query['query']);
        }
    }
}
