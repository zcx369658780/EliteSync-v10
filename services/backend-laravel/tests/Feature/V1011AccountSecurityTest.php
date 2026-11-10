<?php

namespace Tests\Feature;

use App\Http\Middleware\EnsureAccountActive;
use App\Models\User;
use App\Services\Accounts\AccountClosure;
use App\Services\Accounts\DeviceSessions;
use App\Services\Accounts\DisableUser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class V1011AccountSecurityTest extends TestCase
{
    use RefreshDatabase;

    private function member(array $extra = []): User
    {
        return User::factory()->create(array_merge(['phone' => '138'.random_int(10000000, 99999999),
            'role' => 'user', 'password' => Hash::make('Password123')], $extra));
    }

    public function test_private_profile_writer_rechecks_captured_user_after_closure_and_never_calls_next(): void
    {
        $user = $this->member(['disabled' => false]);
        $captured = clone $user;
        $request = Request::create('/api/v1/profile/basic', 'POST');
        $request->setUserResolver(fn () => $captured);
        $pending = app(AccountClosure::class)->request($user, 'Password123', 'private-writer-closure-key');
        $this->assertFalse($captured->disabled);
        $this->assertDatabaseHas('users', ['id' => $user->id, 'disabled' => true]);
        $this->assertDatabaseHas('account_closures', ['id' => $pending['request_id'], 'status' => 'DELETION_PENDING']);
        $called = false;

        $response = app(EnsureAccountActive::class)->handle($request, function () use (&$called) {
            $called = true;

            return response()->json(['unexpected' => true]);
        });

        $this->assertSame(403, $response->getStatusCode());
        $this->assertSame('account_disabled', $response->getData(true)['error']['code']);
        $this->assertFalse($called);
    }

    public function test_active_private_profile_writer_receives_fresh_user_inside_transaction(): void
    {
        $captured = $this->member(['name' => 'Captured old name', 'disabled' => false]);
        $request = Request::create('/api/v1/profile/basic', 'POST');
        $request->setUserResolver(fn () => $captured);
        DB::table('users')->where('id', $captured->id)->update(['name' => 'Fresh database name']);
        $this->assertSame('Captured old name', $captured->name);
        $baselineLevel = DB::transactionLevel();
        $called = false;

        $response = app(EnsureAccountActive::class)->handle($request, function (Request $current) use (&$called, $baselineLevel) {
            $called = true;
            $this->assertGreaterThan($baselineLevel, DB::transactionLevel());
            $this->assertSame('Fresh database name', $current->user()->name);
            $this->assertFalse($current->user()->disabled);

            return response()->json(['ok' => true]);
        });

        $this->assertTrue($called);
        $this->assertSame(200, $response->getStatusCode());
        $this->assertSame($baselineLevel, DB::transactionLevel());
    }

    public function test_revoking_one_server_family_preserves_other_device_and_denies_cross_user(): void
    {
        $user = $this->member();
        $service = app(DeviceSessions::class);
        $one = $service->issue($user);
        $two = $service->issue($user);
        try {
            $service->revoke($this->member(), $one['session_id']);
            $this->fail('Another user must not revoke this session');
        } catch (HttpException $error) {
            $this->assertSame(404, $error->getStatusCode());
        }
        $service->revoke($user, $one['session_id']);
        $this->assertNull(PersonalAccessToken::findToken($one['access_token']));
        $this->assertNull(PersonalAccessToken::findToken($one['refresh_token']));
        $this->assertNotNull(PersonalAccessToken::findToken($two['access_token']));
    }

    public function test_refresh_rechecks_pre_authenticated_token_after_logout_commit(): void
    {
        $user = $this->member();
        $service = app(DeviceSessions::class);
        $issued = $service->issue($user);
        $authenticatedBeforeLogout = PersonalAccessToken::findToken($issued['refresh_token']);
        $service->revoke($user, $issued['session_id']);
        $this->expectException(HttpException::class);
        $this->expectExceptionCode(0);
        try {
            $service->refresh($user, $authenticatedBeforeLogout);
        } finally {
            $this->assertSame(0, $user->tokens()->count());
        }
    }

    public function test_refresh_replay_cannot_rotate_again_or_create_a_new_family(): void
    {
        $user = $this->member();
        $service = app(DeviceSessions::class);
        $issued = $service->issue($user);
        $captured = PersonalAccessToken::findToken($issued['refresh_token']);
        $rotated = $service->refresh($user, $captured);
        $this->assertSame($issued['session_id'], $rotated['session_id']);
        $this->assertNull(PersonalAccessToken::findToken($issued['access_token']));
        try {
            $service->refresh($user, $captured);
            $this->fail('Consumed refresh must not work');
        } catch (HttpException $error) {
            $this->assertSame(401, $error->getStatusCode());
        }
        $this->assertSame(1, DB::table('device_sessions')->where('user_id', $user->id)->count());
        $this->assertNotNull(PersonalAccessToken::findToken($rotated['access_token']));
    }

    public function test_all_sessions_and_disable_cover_old_access_and_refresh(): void
    {
        $user = $this->member();
        $service = app(DeviceSessions::class);
        $service->issue($user);
        $service->issue($user);
        $service->revokeAll($user);
        $this->assertSame(0, $user->tokens()->count());
        $this->assertSame(0, DB::table('device_sessions')->where('user_id', $user->id)->whereNull('revoked_at')->count());
        app(DisableUser::class)->execute($user->id);
        $this->expectException(HttpException::class);
        $service->issue($user);
    }

    public function test_refresh_credential_cannot_read_private_business_profile(): void
    {
        $issued = app(DeviceSessions::class)->issue($this->member());
        $this->withToken($issued['refresh_token'])->getJson('/api/v1/profile/basic')
            ->assertForbidden()->assertJsonPath('error.message', 'TOKEN_PURPOSE_RESTRICTED');
    }

    public function test_refresh_credential_can_only_revoke_its_current_family(): void
    {
        $user = $this->member();
        $service = app(DeviceSessions::class);
        $one = $service->issue($user);
        $two = $service->issue($user);
        $this->withToken($one['refresh_token'])->postJson('/api/v1/auth/logout')->assertOk();
        $this->assertNull(PersonalAccessToken::findToken($one['refresh_token']));
        $this->assertNotNull(PersonalAccessToken::findToken($two['refresh_token']));
    }

    public function test_clearing_disabled_does_not_allow_reopening_a_closure(): void
    {
        $user = $this->member();
        $pending = app(AccountClosure::class)->request($user, 'Password123', 'closed-account-stays-closed');
        DB::table('users')->where('id', $user->id)->update(['disabled' => false]);
        $this->withToken($pending['receipt_token'])->getJson('/api/v1/profile/basic')->assertUnauthorized();
        $this->expectException(HttpException::class);
        app(DeviceSessions::class)->issue($user->fresh());
    }

    public function test_ordinary_prefix_account_closure_is_durable_idempotent_and_receipt_is_not_business_token(): void
    {
        $user = $this->member(['name' => '普通演练成员']);
        app(DeviceSessions::class)->issue($user);
        $service = app(AccountClosure::class);
        $pending = $service->request($user, 'Password123', 'closure-idempotency-one');
        $replayed = $service->request($user, 'Password123', 'closure-idempotency-one');
        $this->assertSame($pending, $replayed);
        $this->assertTrue($user->fresh()->disabled);
        $this->assertSame(0, $user->tokens()->count());
        $this->assertNull(PersonalAccessToken::findToken($pending['receipt_token']));
        $this->assertSame('DELETION_PENDING', $service->receipt($pending['request_id'], $pending['receipt_token'])['status']);
        $service->processPending();
        $receipt = $service->receipt($pending['request_id'], $pending['receipt_token']);
        $this->assertSame('PRODUCTION_RETENTION_POLICY_PENDING', $receipt['status']);
        $this->assertSame('普通演练成员', $user->fresh()->name);
        $this->assertContains('shared_messages_and_counterpart_records', $receipt['result']['retained']);
    }

    public function test_client_synthetic_flags_prefixes_and_registration_cannot_authorize_erasure_on_unknown_database(): void
    {
        config(['account_security.erasure_enabled' => true]);
        $user = $this->member(['phone' => '90123456789', 'name' => 'Smoke demo', 'is_synthetic' => true]);
        DB::table('v1011_erasure_members')->insert(['user_id' => $user->id,
            'dataset' => config('account_security.dataset'), 'provenance' => 'test fixture', 'registered_at' => now()]);
        $this->assertFalse(app(AccountClosure::class)->erasurePermitted($user->id));
    }

    public function test_processing_failure_persists_and_can_be_retried_after_restart_without_reactivating_account(): void
    {
        $user = $this->member();
        $service = app(AccountClosure::class);
        $pending = $service->request($user, 'Password123', 'retryable-closure-key');
        // A concurrent protected-role change must stop the processor rather than erase staff.
        DB::table('users')->where('id', $user->id)->update(['role' => 'admin']);
        $service->process($pending['request_id']);
        $failed = $service->receipt($pending['request_id'], $pending['receipt_token']);
        $this->assertSame('FAILED_RETRYABLE', $failed['status']);
        $this->assertSame(1, $failed['attempts']);
        DB::table('users')->where('id', $user->id)->update(['role' => 'user']);
        (new AccountClosure)->processPending();
        $retried = $service->receipt($pending['request_id'], $pending['receipt_token']);
        $this->assertSame('PRODUCTION_RETENTION_POLICY_PENDING', $retried['status']);
        $this->assertSame(2, $retried['attempts']);
        $this->assertTrue($user->fresh()->disabled);
    }

    public function test_admin_and_wrong_password_cannot_request_closure_and_receipt_requires_exact_secret(): void
    {
        $service = app(AccountClosure::class);
        foreach ([[$this->member(['role' => 'admin']), 'Password123', 403], [$this->member(), 'wrong', 422]] as [$user, $password, $status]) {
            try {
                $service->request($user, $password, 'negative-closure-key');
                $this->fail('Invalid closure request accepted');
            } catch (HttpException $error) {
                $this->assertSame($status, $error->getStatusCode());
            }
            $this->assertFalse($user->fresh()->disabled);
        }
        $pending = $service->request($this->member(), 'Password123', 'valid-closure-key');
        $this->expectException(HttpException::class);
        $service->receipt($pending['request_id'], str_repeat('0', 64));
    }

    public function test_lost_closure_receipt_can_be_recovered_without_issuing_business_tokens(): void
    {
        $user = $this->member();
        $closures = app(AccountClosure::class);
        $pending = $closures->request($user, 'Password123', 'lost-receipt-recovery-key');
        $recovered = $closures->recover($user->phone, 'Password123', 'lost-receipt-recovery-key');
        $this->assertSame($pending, $recovered);
        $this->assertSame(0, $user->tokens()->count());
        foreach ([['13800000000', 'wrong', 'lost-receipt-recovery-key'], [$user->phone, 'wrong', 'lost-receipt-recovery-key'],
            [$user->phone, 'Password123', 'incorrect-key-value']] as [$phone, $password, $key]) {
            try {
                $closures->recover($phone, $password, $key);
                $this->fail('Unverified recovery accepted');
            } catch (HttpException $error) {
                $this->assertSame(422, $error->getStatusCode());
                $this->assertSame('CLOSURE_RECOVERY_UNAVAILABLE', $error->getMessage());
            }
        }
    }

    public function test_self_reported_identity_is_not_a_verified_identity(): void
    {
        $this->withoutMiddleware();
        $response = $this->postJson('/api/v1/auth/register', ['phone' => '13712345678',
            'password' => 'Password123', 'name' => 'Normal member', 'realname_verified' => true]);
        $response->assertCreated()->assertJsonPath('user.realname_verified', false);
        $this->assertFalse(User::where('phone', '13712345678')->firstOrFail()->realname_verified);
    }

    public function test_web_account_audit_denies_ordinary_role_and_never_projects_receipt_or_idempotency_secrets(): void
    {
        $ordinary = $this->member();
        config(['app.admin_phones' => [$ordinary->phone]]);
        $this->actingAs($ordinary, 'web')->get('/admin/account-security')->assertForbidden();
        $admin = $this->member(['role' => 'admin']);
        config(['app.admin_phones' => [$admin->phone]]);
        $pending = app(AccountClosure::class)->request($ordinary, 'Password123', 'audit-must-not-leak-key');
        $hash = DB::table('account_closures')->where('id', $pending['request_id'])->value('receipt_hash');
        $this->actingAs($admin, 'web')->get('/admin/account-security')->assertOk()
            ->assertSee('DELETION_PENDING')->assertSee($pending['request_id'])
            ->assertDontSee($pending['receipt_token'])->assertDontSee($hash)
            ->assertDontSee('audit-must-not-leak-key')->assertDontSee($ordinary->phone)
            ->assertHeader('Cache-Control', 'no-store, private');
    }

    public function test_historical_self_reported_flag_cannot_become_provider_verified_on_login(): void
    {
        $user = $this->member(['realname_verified' => true]);
        $this->postJson('/api/v1/auth/login', ['phone' => $user->phone, 'password' => 'Password123'])
            ->assertOk()->assertJsonPath('user.realname_verified', false)
            ->assertJsonPath('user.identity_provider', 'NOT_CONFIGURED')->assertJsonPath('user.identity_status', 'NOT_VERIFIED');
    }
}
