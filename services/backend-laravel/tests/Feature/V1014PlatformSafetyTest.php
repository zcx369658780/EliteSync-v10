<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

/** Synthetic Feature coverage only; real MariaDB/APP/Web evidence is collected separately. */
final class V1014PlatformSafetyTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = 'TEST_ONLY-platform-password';

    private User $adminUser;

    /** @return array{User,User,User,User} */
    private function people(): array
    {
        config(['restoration.enabled' => true, 'app.admin_phones' => ['19900001400']]);
        $this->adminUser = User::factory()->create([
            'phone' => '19900001400', 'role' => 'admin', 'is_synthetic' => true,
            'disabled' => false, 'account_status' => 'active', 'moderation_status' => 'normal',
            'password' => Hash::make(self::PASSWORD),
        ]);
        $users = [];
        foreach (['A', 'B', 'C', 'D'] as $i => $name) {
            $users[] = User::factory()->create([
                'phone' => '1990000140'.($i + 1), 'name' => 'TEST_ONLY '.$name,
                'role' => 'user', 'is_synthetic' => true, 'disabled' => false,
                'account_status' => 'active', 'moderation_status' => 'normal',
            ]);
        }

        return $users;
    }

    private function loginAdmin(): void
    {
        $this->post('/admin/login', ['phone' => $this->adminUser->phone, 'password' => self::PASSWORD])
            ->assertRedirect(route('admin.users'));
        $this->assertDatabaseHas('platform_admin_sessions', ['user_id' => $this->adminUser->id, 'revoked_at' => null]);
        // Feature requests do not retain a browser cookie jar automatically, and
        // JSON requests omit cookies unless explicitly made with credentials.
        $this->withCookie(config('session.cookie'), session()->getId())->withCredentials();
    }

    private function createDraft(int $capacity = 2, array $extra = []): string
    {
        $before = DB::table('platform_events')->count();
        $data = array_merge([
            'title' => 'TEST_ONLY shared study', 'city' => 'TEST_ONLY city', 'venue' => 'TEST_ONLY cafe',
            'capacity' => $capacity, 'start_at' => now()->addHour()->toIso8601String(),
            'end_at' => now()->addHours(2)->toIso8601String(),
            'idempotency_key' => (string) Str::uuid(), 'reason' => 'TEST_ONLY synthetic draft creation', 'confirm' => true,
        ], $extra);
        $this->postJson('/admin/platform-events', $data)->assertRedirect('/admin/platform-events');
        $this->assertSame($before + 1, DB::table('platform_events')->count());

        return (string) DB::table('platform_event_commands')->where('actor_id', $this->adminUser->id)
            ->where('idempotency_key', $data['idempotency_key'])->value('event_id');
    }

    private function event(string $id): object
    {
        $event = DB::table('platform_events')->where('id', $id)->first();
        $this->assertNotNull($event);

        return $event;
    }

    private function adminAction(string $id, string $action, array $extra = []): TestResponse
    {
        return $this->postJson('/admin/platform-events/'.$id.'/actions', array_merge([
            'action' => $action, 'revision' => (int) $this->event($id)->revision,
            'idempotency_key' => (string) Str::uuid(), 'reason' => 'TEST_ONLY explicit event operation', 'confirm' => true,
        ], $extra));
    }

    private function openEvent(int $capacity = 2): string
    {
        $id = $this->createDraft($capacity);
        foreach (['DRAFT', 'REVIEWED', 'APPROVED_FOR_DEV_SIMULATION'] as $state) {
            $budget = DB::table('platform_event_budgets')->where('event_id', $id)->first();
            $this->adminAction($id, 'budget', [
                'budget_revision' => (int) $budget->revision, 'budget_state' => $state,
                'venue_cost' => 1000, 'materials_cost' => 250, 'travel_cost' => 0,
            ])->assertRedirect('/admin/platform-events');
        }
        $this->adminAction($id, 'open')->assertRedirect('/admin/platform-events');
        $this->assertSame('OPEN', $this->event($id)->state);

        return $id;
    }

    private function invite(string $id, User ...$users): void
    {
        foreach ($users as $user) {
            $this->adminAction($id, 'invite', ['recipient_id' => $user->id])->assertRedirect('/admin/platform-events');
        }
    }

    private function userAction(User $user, string $id, string $action, array $extra = []): TestResponse
    {
        return $this->actingAs($user, 'sanctum')->postJson('/api/v1/platform-events/'.$id.'/actions', array_merge([
            'action' => $action, 'revision' => (int) $this->event($id)->revision,
            'idempotency_key' => (string) Str::uuid(),
        ], $extra));
    }

    private function registration(string $eventId, User $user): object
    {
        $row = DB::table('platform_event_registrations')->where('event_id', $eventId)->where('user_id', $user->id)->first();
        $this->assertNotNull($row);

        return $row;
    }

    private function makeReport(User $reporter, User $subject, string $eventId, string $category = 'CONDUCT'): array
    {
        return $this->actingAs($reporter, 'sanctum')->postJson('/api/v1/platform-events/'.$eventId.'/reports', [
            'target_registration_id' => $this->registration($eventId, $subject)->id,
            'category' => $category, 'statement' => 'TEST_ONLY synthetic claimant statement for manual investigation',
            'idempotency_key' => (string) Str::uuid(),
        ])->assertCreated()->json();
    }

    private function caseRow(string $id): object
    {
        $case = DB::table('safety_cases')->where('id', $id)->first();
        $this->assertNotNull($case);

        return $case;
    }

    private function evidence(string $id): TestResponse
    {
        return $this->getJson('/admin/safety-cases/'.$id.'/evidence?'.http_build_query([
            'reason' => 'TEST_ONLY necessary current source verification',
        ]));
    }

    private function decide(string $id, string $action, array $extra = []): TestResponse
    {
        return $this->postJson('/admin/safety-cases/'.$id.'/decisions', array_merge([
            'action' => $action, 'revision' => (int) $this->caseRow($id)->revision,
            'reason' => 'TEST_ONLY explicit human decision with recorded limits', 'confirm' => true,
        ], $extra));
    }

    private function substantiate(string $id, string $corroborating): void
    {
        $this->decide($id, 'triage')->assertRedirect('/admin/platform-events');
        $this->decide($id, 'investigate')->assertRedirect('/admin/platform-events');
        $this->evidence($id)->assertOk()->assertJsonCount(2, 'evidence');
        $this->evidence($corroborating)->assertOk()->assertJsonCount(2, 'evidence');
        $this->decide($id, 'substantiate', [
            'corroborating_case_id' => $corroborating, 'evidence_checked' => true,
            'manual_finding' => 'TEST_ONLY human reviewed two independent synthetic claims and current source identity; no actual physical incident is asserted.',
        ])->assertRedirect('/admin/platform-events');
        $this->assertSame('SUBSTANTIATED', $this->caseRow($id)->state);
        $this->assertDatabaseCount('admin_sanctions', 0);
    }

    private function review(string $id, int $appealId, string $outcome, array $extra = []): TestResponse
    {
        $case = $this->caseRow($id);
        $appeal = DB::table('sanction_appeals')->where('id', $appealId)->first();

        return $this->postJson('/admin/safety-cases/'.$id.'/reviews', array_merge([
            'revision' => (int) $case->revision, 'appeal_id' => $appealId,
            'appeal_revision' => (int) $appeal->revision, 'outcome' => $outcome,
            'user_revision' => (int) User::findOrFail($case->subject_id)->admin_revision,
            'reason' => 'TEST_ONLY bounded human review of the named sanction only', 'confirm' => true,
        ], $extra));
    }

    public function test_web_creation_requires_reviewed_simulation_budget_and_keeps_costs_internal(): void
    {
        [$a] = $this->people();
        $this->loginAdmin();
        $draft = $this->createDraft();
        $this->adminAction($draft, 'open')->assertStatus(409);
        $this->assertSame('DRAFT', $this->event($draft)->state);

        $id = $this->openEvent();
        $this->invite($id, $a);
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$id)->assertOk()
            ->assertJsonPath('marker', 'DEV_SYNTHETIC_EVENT')->assertJsonPath('booking', 'NOT_REAL_BOOKING')
            ->assertJsonMissingPath('budget')->assertJsonMissingPath('venue_cost')->assertJsonMissingPath('total');
        $this->assertDatabaseHas('platform_event_budgets', ['event_id' => $id, 'currency_code' => 'CNY', 'total' => 1250, 'state' => 'APPROVED_FOR_DEV_SIMULATION']);

        $audit = DB::table('admin_operation_audits')->where('action', 'platform_event.budget')->where('target_id', $id)->orderBy('id')->first();
        $this->assertNotNull($audit);
        $before = json_decode($audit->before_state, true, 512, JSON_THROW_ON_ERROR);
        $after = json_decode($audit->after_state, true, 512, JSON_THROW_ON_ERROR);
        $this->assertSame(0, $before['budget']['total']);
        $this->assertSame(1250, $after['budget']['total']);
        $this->assertSame(1000, $after['budget']['venue_cost']);
        $this->assertSame('DRAFT', $after['budget']['state']);
        $this->assertSame((int) $this->adminUser->id, (int) $audit->actor_user_id);
    }

    public function test_capacity_waitlist_fifo_and_idempotent_voluntary_cancel_do_not_create_other_consent(): void
    {
        [$a, $b, $c, $d] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a, $b, $c, $d);
        $this->userAction($a, $id, 'apply')->assertOk()->assertJsonPath('registration.state', 'APPLIED');
        $this->userAction($b, $id, 'apply')->assertOk()->assertJsonPath('registration.state', 'APPLIED');
        $this->userAction($c, $id, 'apply')->assertOk()->assertJsonPath('registration.state', 'WAITLISTED');
        $this->userAction($d, $id, 'apply')->assertOk()->assertJsonPath('registration.state', 'WAITLISTED');
        $this->assertLessThan($this->registration($id, $d)->wait_order, $this->registration($id, $c)->wait_order);
        foreach ([$a, $b] as $user) {
            $this->adminAction($id, 'confirm', ['registration_id' => $this->registration($id, $user)->id])->assertRedirect('/admin/platform-events');
        }
        $this->adminAction($id, 'promote', ['registration_id' => $this->registration($id, $c)->id])->assertStatus(409);

        $body = ['action' => 'cancel', 'revision' => (int) $this->event($id)->revision, 'idempotency_key' => 'same-cancel'];
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/platform-events/'.$id.'/actions', $body)->assertOk()->assertJsonPath('state', 'CANCELLED_BY_USER');
        $auditCount = DB::table('platform_event_audits')->count();
        $noticeCount = DB::table('notifications')->count();
        $this->postJson('/api/v1/platform-events/'.$id.'/actions', $body)->assertOk();
        $this->assertSame($auditCount, DB::table('platform_event_audits')->count());
        $this->assertSame($noticeCount, DB::table('notifications')->count());
        $this->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->adminAction($id, 'promote', ['registration_id' => $this->registration($id, $d)->id])->assertStatus(409);
        $this->adminAction($id, 'promote', ['registration_id' => $this->registration($id, $c)->id])->assertRedirect('/admin/platform-events');
        $this->assertSame(2, DB::table('platform_event_registrations')->where('event_id', $id)->where('state', 'CONFIRMED')->count());
        foreach (['friendships', 'product_connections', 'messaging_consents', 'formal_relationships', 'conversations', 'admin_sanctions'] as $table) {
            $this->assertDatabaseCount($table, 0);
        }
    }

    public function test_single_use_capability_revocation_expiry_and_bare_event_uuid_fail_closed(): void
    {
        [$a, $b, $c] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->adminAction($id, 'token')->assertRedirect('/admin/platform-events');
        $capability = session('issued_token');
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $capability);
        $this->assertDatabaseHas('platform_event_grants', ['event_id' => $id, 'token_hash' => hash('sha256', $capability)]);
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/platform-events/redeem', ['token' => $capability, 'idempotency_key' => 'redeem-once'])
            ->assertOk()->assertJsonPath('registration.state', 'INVITED');
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/platform-events/redeem', ['token' => $capability, 'idempotency_key' => 'steal-consumed'])->assertNotFound();
        $grant = DB::table('platform_event_grants')->where('token_hash', hash('sha256', $capability))->first();
        $this->adminAction($id, 'revoke', ['grant_id' => $grant->id])->assertRedirect('/admin/platform-events');
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->adminAction($id, 'token')->assertRedirect('/admin/platform-events');
        $expired = session('issued_token');
        DB::table('platform_event_grants')->where('token_hash', hash('sha256', $expired))->update(['expires_at' => now()->subSecond()]);
        $before = DB::table('platform_event_registrations')->count();
        $notices = DB::table('notifications')->count();
        $this->actingAs($c, 'sanctum')->postJson('/api/v1/platform-events/redeem', ['token' => $expired, 'idempotency_key' => 'expired'])->assertNotFound();
        $this->assertSame($before, DB::table('platform_event_registrations')->count());
        $this->assertSame($notices, DB::table('notifications')->count());
    }

    public function test_old_revision_forged_actor_and_non_synthetic_invitation_have_no_mutation(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a);
        $revision = (int) $this->event($id)->revision;
        $count = DB::table('platform_event_commands')->count();
        $this->userAction($a, $id, 'apply', ['actor_id' => $b->id])->assertUnprocessable();
        $this->userAction($a, $id, 'apply', ['revision' => $revision - 1])->assertStatus(409);
        $this->assertSame($count, DB::table('platform_event_commands')->count());
        $this->assertSame('INVITED', $this->registration($id, $a)->state);
        $b->forceFill(['is_synthetic' => false])->save();
        $this->adminAction($id, 'invite', ['recipient_id' => $b->id])->assertNotFound();
        $this->assertDatabaseMissing('platform_event_registrations', ['event_id' => $id, 'user_id' => $b->id]);
        $this->adminAction($id, 'cancel', ['confirm' => false])->assertUnprocessable();
        $this->assertSame('OPEN', $this->event($id)->state);
    }

    public function test_self_reported_attendance_is_not_verified_or_an_automatic_finding(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a, $b);
        $this->userAction($a, $id, 'apply')->assertOk();
        $this->adminAction($id, 'confirm', ['registration_id' => $this->registration($id, $a)->id])->assertRedirect('/admin/platform-events');
        $this->userAction($a, $id, 'attendance')->assertOk()->assertJsonPath('registration.attendance', 'SELF_REPORTED');
        $this->userAction($b, $id, 'attendance')->assertStatus(409);
        $this->assertSame('UNVERIFIED', $this->registration($id, $b)->attendance);
        $this->adminAction($id, 'close')->assertRedirect('/admin/platform-events');
        $this->adminAction($id, 'complete')->assertRedirect('/admin/platform-events');
        $this->assertSame('COMPLETED', $this->event($id)->state);
        foreach (['safety_cases', 'safety_case_decisions', 'admin_sanctions'] as $table) $this->assertDatabaseCount($table, 0);
    }

    public function test_report_submission_is_only_an_allegation_and_dismissal_changes_no_sanction(): void
    {
        [$a, $b, $c] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent(3);
        $this->invite($id, $a, $b);
        foreach ([$a, $b] as $u) $this->userAction($u, $id, 'apply')->assertOk();
        $case = $this->makeReport($a, $b, $id, 'ATTENDANCE');
        $this->assertSame('OPEN', $case['state']);
        $this->assertDatabaseCount('safety_case_decisions', 0);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseHas('safety_rule_advisories', ['case_id' => $case['id'], 'status' => 'ADVISORY_ONLY', 'classification' => 'UNVERIFIED_SELF_REPORT']);
        $this->assertDatabaseHas('moderation_reports', ['id' => $this->caseRow($case['id'])->report_id, 'status' => 'new']);
        $this->actingAs($c, 'sanctum')->getJson('/api/v1/safety/own/'.$case['id'])->assertNotFound();
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/safety/own/'.$case['id'])->assertOk()
            ->assertJsonMissingPath('reporter_id')->assertJsonMissingPath('claim')->assertJsonMissingPath('evidence');
        $this->decide($case['id'], 'dismiss')->assertRedirect('/admin/platform-events');
        $this->assertSame('DISMISSED', $this->caseRow($case['id'])->state);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertSame('normal', $b->fresh()->moderation_status);
        $this->assertDatabaseCount('safety_case_reviews', 0);
    }

    public function test_single_claim_or_attendance_rule_cannot_substantiate_or_punish(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a, $b);
        foreach ([$a, $b] as $u) $this->userAction($u, $id, 'apply')->assertOk();
        $case = $this->makeReport($a, $b, $id);
        $this->decide($case['id'], 'triage')->assertRedirect('/admin/platform-events');
        $this->decide($case['id'], 'investigate')->assertRedirect('/admin/platform-events');
        $this->evidence($case['id'])->assertOk()->assertJsonPath('advisory.status', 'ADVISORY_ONLY');
        $before = DB::table('safety_case_decisions')->count();
        $this->decide($case['id'], 'substantiate', ['evidence_checked' => true, 'manual_finding' => str_repeat('Synthetic claim alone is not proof. ', 2)])->assertUnprocessable();
        $this->decide($case['id'], 'restrict', ['user_revision' => 0])->assertStatus(409);
        $this->assertSame($before, DB::table('safety_case_decisions')->count());
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertSame('INVESTIGATING', $this->caseRow($case['id'])->state);
    }

    public function test_forged_evidence_and_cross_event_report_are_rejected_without_case_or_notice(): void
    {
        [$a, $b, $c] = $this->people();
        $this->loginAdmin();
        $one = $this->openEvent();
        $two = $this->openEvent();
        $this->invite($one, $a, $b);
        $this->invite($two, $c);
        $this->userAction($a, $one, 'apply')->assertOk();
        $this->userAction($b, $one, 'apply')->assertOk();
        $this->userAction($c, $two, 'apply')->assertOk();
        $notices = DB::table('notifications')->count();
        $base = ['target_registration_id' => $this->registration($one, $b)->id, 'category' => 'CONDUCT',
            'statement' => 'TEST_ONLY unverified claimant statement', 'idempotency_key' => 'forged'];
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/platform-events/'.$one.'/reports', $base + ['is_verified' => true])->assertUnprocessable();
        $this->postJson('/api/v1/platform-events/'.$one.'/reports', array_merge($base, ['target_registration_id' => $this->registration($two, $c)->id]))->assertNotFound();
        $this->actingAs($c, 'sanctum')->postJson('/api/v1/platform-events/'.$one.'/reports', $base)->assertNotFound();
        $this->assertDatabaseCount('safety_cases', 0);
        $this->assertDatabaseCount('safety_case_evidence', 0);
        $this->assertDatabaseCount('moderation_reports', 0);
        $this->assertSame($notices, DB::table('notifications')->count());
    }

    public function test_withdrawn_registration_removes_current_evidence_and_legacy_report_detail_access(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a, $b);
        foreach ([$a, $b] as $u) $this->userAction($u, $id, 'apply')->assertOk();
        $case = $this->makeReport($a, $b, $id);
        $this->evidence($case['id'])->assertOk()->assertJsonCount(2, 'evidence');
        $viewCount = DB::table('admin_operation_audits')->where('action', 'safety.evidence.view')->count();
        $this->userAction($a, $id, 'cancel')->assertOk();
        $this->evidence($case['id'])->assertNotFound();
        $this->assertSame($viewCount, DB::table('admin_operation_audits')->where('action', 'safety.evidence.view')->count());
        $this->getJson('/admin/reports/'.$this->caseRow($case['id'])->report_id)->assertNotFound();
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/safety/own/'.$case['id'])->assertNotFound();
        // The subject can retain only the private minimum needed for a possible appeal.
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/safety/own/'.$case['id'])->assertOk()
            ->assertJsonMissingPath('claim')->assertJsonMissingPath('evidence')->assertJsonMissingPath('reporter_id');
    }

    public function test_block_then_unblock_cannot_revive_event_or_report_grants(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a, $b);
        foreach ([$a, $b] as $u) $this->userAction($u, $id, 'apply')->assertOk();
        $case = $this->makeReport($a, $b, $id);
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $b->id, 'reason_code' => 'TEST_ONLY'])->assertOk();
        $this->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->getJson('/api/v1/safety/own/'.$case['id'])->assertNotFound();
        $this->deleteJson('/api/v1/moderation/blocks/'.$b->id)->assertOk();
        $this->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->assertDatabaseHas('platform_event_registrations', ['event_id' => $id, 'user_id' => $a->id, 'state' => 'CANCELLED_BY_ORGANIZER']);
        $this->assertDatabaseCount('admin_sanctions', 0);
    }

    public function test_current_admin_role_and_logged_out_session_are_rechecked_on_web_mutations(): void
    {
        $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $before = DB::table('platform_event_commands')->count();
        $this->adminUser->forceFill(['role' => 'user'])->save();
        $this->adminAction($id, 'close')->assertForbidden();
        $this->assertSame($before, DB::table('platform_event_commands')->count());
        $this->assertSame('OPEN', $this->event($id)->state);
        $this->adminUser->forceFill(['role' => 'admin'])->save();
        DB::table('platform_admin_sessions')->where('user_id', $this->adminUser->id)->update(['revoked_at' => now()]);
        $this->adminAction($id, 'close')->assertUnauthorized();
        $this->assertSame($before, DB::table('platform_event_commands')->count());
    }

    public function test_ordinary_account_cannot_log_in_as_admin_or_create_an_event(): void
    {
        [$a] = $this->people();
        $a->forceFill(['password' => Hash::make(self::PASSWORD)])->save();
        $this->post('/admin/login', ['phone' => $a->phone, 'password' => self::PASSWORD])->assertSessionHasErrors('phone');
        $this->get('/admin/platform-events')->assertStatus(302);
        $this->post('/admin/platform-events', [
            'title' => 'TEST_ONLY forbidden draft', 'city' => 'TEST_ONLY city', 'venue' => 'TEST_ONLY cafe',
            'capacity' => 2, 'start_at' => now()->addHour()->toIso8601String(), 'end_at' => now()->addHours(2)->toIso8601String(),
            'idempotency_key' => 'ordinary-role', 'reason' => 'TEST_ONLY unauthorized request', 'confirm' => true,
        ])->assertStatus(302);
        $this->assertDatabaseCount('platform_events', 0);
        $this->assertDatabaseCount('platform_event_budgets', 0);
        $this->assertDatabaseCount('platform_event_commands', 0);
    }

    public function test_revoked_api_session_has_no_old_event_read_or_apply_authority(): void
    {
        [$a] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->invite($id, $a);
        $issued = $a->createToken('TEST_ONLY-revoked-session');
        $credential = $issued->plainTextToken;
        $issued->accessToken->delete();
        Auth::guard('web')->logout();
        session()->flush();
        Auth::forgetGuards();
        // Exercise the revoked bearer alone, without the still-valid administrator cookie.
        $this->defaultCookies = [];
        $this->withHeader('Authorization', 'Bearer '.$credential)->getJson('/api/v1/platform-events/'.$id)->assertUnauthorized();
        $before = DB::table('platform_event_commands')->count();
        $this->postJson('/api/v1/platform-events/'.$id.'/actions', [
            'action' => 'apply', 'revision' => (int) $this->event($id)->revision, 'idempotency_key' => 'revoked-apply',
        ])->assertUnauthorized();
        $this->assertSame($before, DB::table('platform_event_commands')->count());
        $this->assertSame('INVITED', $this->registration($id, $a)->state);
    }

    public function test_human_finding_named_appeal_review_restores_only_selected_sanction_and_no_social_rights(): void
    {
        [$a, $b, $subject, $peer] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent(3);
        $this->invite($id, $a, $b, $subject);
        foreach ([$a, $b, $subject] as $u) $this->userAction($u, $id, 'apply')->assertOk();
        $case = $this->makeReport($a, $subject, $id);
        $second = $this->makeReport($b, $subject, $id);
        $this->substantiate($case['id'], $second['id']);
        $this->evidence($case['id'])->assertOk();
        $this->decide($case['id'], 'restrict', ['user_revision' => (int) $subject->fresh()->admin_revision])->assertRedirect('/admin/platform-events');
        $sanction = (int) $this->caseRow($case['id'])->sanction_id;
        $this->assertDatabaseHas('admin_sanctions', ['id' => $sanction, 'user_id' => $subject->id, 'active' => true]);
        $this->postJson('/admin/users/'.$subject->id.'/punishment', [
            'action' => 'restrict', 'reason' => 'TEST_ONLY separate independent restriction',
            'expected_revision' => (int) $subject->fresh()->admin_revision, 'confirm' => true,
        ])->assertRedirect();
        $independent = (int) DB::table('admin_sanctions')->where('user_id', $subject->id)->where('id', '!=', $sanction)->value('id');
        $this->assertGreaterThan(0, $independent);

        DB::table('friendships')->insert(['user_a' => min($subject->id, $peer->id), 'user_b' => max($subject->id, $peer->id), 'state' => 'REVOKED', 'revision' => 7, 'created_at' => now(), 'updated_at' => now()]);
        $connection = DB::table('product_connections')->insertGetId(['match_id' => null, 'user_a' => min($subject->id, $peer->id), 'user_b' => max($subject->id, $peer->id), 'requester_id' => $subject->id, 'state' => 'CN_CLOSED', 'revision' => 7, 'created_at' => now(), 'updated_at' => now()]);
        DB::table('messaging_consents')->insert(['connection_id' => $connection, 'purpose' => 'message', 'state' => 'MC_REVOKED', 'requester_id' => $subject->id, 'revision' => 9, 'connection_revision' => 7, 'generation' => 1, 'created_at' => now(), 'updated_at' => now()]);
        DB::table('user_blocks')->insert(['blocker_id' => $subject->id, 'blocked_user_id' => $peer->id, 'reason_code' => 'TEST_ONLY', 'created_at' => now(), 'updated_at' => now()]);
        $socialBefore = [];
        foreach (['friendships', 'product_connections', 'messaging_consents', 'user_blocks'] as $table) $socialBefore[$table] = DB::table($table)->orderBy('id')->get()->toJson();

        $appeal = $this->actingAs($subject, 'sanctum')->postJson('/api/v1/moderation/sanctions/'.$sanction.'/appeals', ['note' => 'TEST_ONLY I request a named human review'])->assertCreated()->json('appeal.id');
        $wrongAppeal = $this->postJson('/api/v1/moderation/sanctions/'.$independent.'/appeals', ['note' => 'TEST_ONLY independently scoped appeal'])->assertCreated()->json('appeal.id');
        $this->get('/admin/users/'.$subject->id)->assertOk()->assertDontSee('TEST_ONLY I request a named human review')->assertDontSee('处罚#'.$sanction.' ');
        $this->get('/admin/audits')->assertOk()->assertDontSee('TEST_ONLY explicit human decision with recorded limits');
        $beforeBypass=[];
        foreach(['safety_cases','sanction_appeals','safety_case_reviews','admin_sanctions','users','admin_operation_audits'] as $table)
            $beforeBypass[$table]=DB::table($table)->orderBy('id')->get()->toJson();
        $this->postJson('/admin/users/'.$subject->id.'/punishment',[
            'action'=>'restore','sanction_id'=>$sanction,'reason'=>'TEST_ONLY legacy bypass must be denied',
            'expected_revision'=>(int)$subject->fresh()->admin_revision,'confirm'=>true,
        ])->assertUnprocessable();
        foreach($beforeBypass as $table=>$snapshot)$this->assertSame($snapshot,DB::table($table)->orderBy('id')->get()->toJson(),$table.' legacy bypass must have no effects');
        $this->getJson('/api/v1/safety/own/'.$case['id'])->assertOk()->assertJsonPath('sanction_id', $sanction)
            ->assertJsonMissingPath('reporter_id')->assertJsonMissingPath('claim');
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/moderation/sanctions/'.$sanction.'/appeals', ['note' => 'TEST_ONLY not my sanction'])->assertNotFound();
        $this->review($case['id'], $wrongAppeal, 'OVERTURNED')->assertStatus(409);
        $this->assertDatabaseCount('safety_case_reviews', 0);

        $this->review($case['id'], $appeal, 'UPHELD')->assertRedirect('/admin/platform-events');
        $this->assertDatabaseHas('admin_sanctions', ['id' => $sanction, 'active' => true]);
        $this->assertDatabaseHas('sanction_appeals', ['id' => $appeal, 'review_outcome' => 'UPHELD', 'revision' => 2]);
        $oldCaseRevision = (int) $this->caseRow($case['id'])->revision;
        $this->review($case['id'], $appeal, 'OVERTURNED')->assertRedirect('/admin/platform-events');
        $this->assertDatabaseHas('admin_sanctions', ['id' => $sanction, 'active' => false]);
        $this->assertDatabaseHas('admin_sanctions', ['id' => $independent, 'active' => true]);
        $this->assertSame('restricted', $subject->fresh()->moderation_status);
        $this->assertDatabaseHas('sanction_appeals', ['id' => $appeal, 'review_outcome' => 'OVERTURNED', 'revision' => 3]);
        $this->assertSame('CORRECTED', $this->caseRow($case['id'])->state);
        $this->assertDatabaseCount('safety_case_reviews', 2);
        $this->review($case['id'], $appeal, 'CORRECTED', ['revision' => $oldCaseRevision])->assertStatus(409);
        $this->assertDatabaseCount('safety_case_reviews', 2);
        foreach ($socialBefore as $table => $snapshot) $this->assertSame($snapshot, DB::table($table)->orderBy('id')->get()->toJson(), $table.' must not revive');
        $this->assertDatabaseCount('formal_relationships', 0);
        $this->assertDatabaseCount('conversations', 0);
        $this->actingAs($subject, 'sanctum')->getJson('/api/v1/safety/own/'.$case['id'])->assertOk()->assertJsonPath('appeal.outcome', 'OVERTURNED');
        $this->getJson('/api/v1/moderation/sanctions')->assertOk()->assertJsonCount(1, 'items')->assertJsonPath('items.0.id', $independent);
    }

    public function test_expired_and_cancelled_events_do_not_imply_attendance_or_safety_penalty(): void
    {
        [$a] = $this->people();
        $this->loginAdmin();
        $cancelled = $this->openEvent();
        $this->invite($cancelled, $a);
        $this->userAction($a, $cancelled, 'apply')->assertOk();
        $this->adminAction($cancelled, 'cancel')->assertRedirect('/admin/platform-events');
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$cancelled)->assertNotFound();
        $this->assertSame('CANCELLED_BY_ORGANIZER', $this->registration($cancelled, $a)->state);

        $expired = $this->openEvent();
        $this->invite($expired, $a);
        $this->travel(3)->hours();
        $this->get('/admin/platform-events')->assertOk();
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$expired)->assertNotFound();
        $this->assertSame('EXPIRED', $this->event($expired)->state);
        $this->assertSame('EXPIRED', $this->registration($expired, $a)->state);
        $this->assertSame('UNVERIFIED', $this->registration($expired, $a)->attendance);
        $this->assertDatabaseCount('safety_cases', 0);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->travelBack();
    }

    public function test_user_first_expired_read_commits_terminal_state_without_admin_read(): void
    {
        [$a]=$this->people();$this->loginAdmin();$id=$this->openEvent();$this->invite($id,$a);
        $this->travel(3)->hours();
        $this->actingAs($a,'sanctum')->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->assertSame('EXPIRED',$this->event($id)->state);
        $this->assertSame('EXPIRED',$this->registration($id,$a)->state);
        $this->assertDatabaseHas('platform_event_grants',['id'=>$this->registration($id,$a)->grant_id,'state'=>'REVOKED']);
        $this->assertDatabaseCount('admin_sanctions',0);$this->travelBack();
    }

    public function test_restricted_owner_can_read_only_minimal_exit_ticket_and_cancel(): void
    {
        [$a]=$this->people();$this->loginAdmin();$id=$this->openEvent();$this->invite($id,$a);
        $this->userAction($a,$id,'apply')->assertOk();
        $a->forceFill(['moderation_status'=>'restricted'])->save();
        $r=$this->actingAs($a,'sanctum')->getJson('/api/v1/platform-events')->assertOk()->assertJsonCount(0,'items')->assertJsonCount(1,'exit_tickets')
            ->assertJsonMissingPath('exit_tickets.0.title')->assertJsonMissingPath('exit_tickets.0.venue')->assertJsonMissingPath('exit_tickets.0.participants');
        $ticket=$r->json('exit_tickets.0');$this->assertSame(['cancel'],$ticket['allowed_actions']);
        $this->postJson('/api/v1/platform-events/'.$id.'/actions',['action'=>'cancel','revision'=>$ticket['revision'],'idempotency_key'=>'restricted-exit'])->assertOk()->assertJsonPath('state','CANCELLED_BY_USER');
        $this->getJson('/api/v1/platform-events')->assertOk()->assertJsonCount(0,'exit_tickets');
        $this->assertSame('CANCELLED_BY_USER',$this->registration($id,$a)->state);
        $this->assertDatabaseCount('admin_sanctions',0);
    }
}
