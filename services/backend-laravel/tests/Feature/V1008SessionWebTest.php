<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Http\Middleware\ValidateCsrfToken;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

final class V1008SessionWebTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->app->bind(ValidateCsrfToken::class,
            fn ($app) => new EnforcedV1008SessionCsrf($app, $app['encrypter']));
    }

    private function account(string $phone, string $role = 'user', bool $disabled = false): User
    {
        return User::create(['name' => 'Fictional session fixture', 'phone' => $phone,
            'password' => 'fixture-password', 'role' => $role, 'disabled' => $disabled]);
    }

    private function admin(): User
    {
        $admin = $this->account('19900000881', 'admin');
        config(['app.admin_phones' => [$admin->phone]]);
        return $admin;
    }

    private function disablePayload(string $csrf): array
    {
        return ['_token' => $csrf, 'confirm_disable' => '1', 'expected_revision' => 0,
            'reason' => 'Fictional session permission check'];
    }

    private function login(User $admin): void
    {
        $this->withSession(['_token' => 'pre-login-fixture-csrf']);
        $this->from('/admin/login')->post('/admin/login', ['_token' => 'pre-login-fixture-csrf',
            'phone' => $admin->phone, 'password' => 'fixture-password'])->assertRedirect('/admin');
        $this->assertAuthenticatedAs($admin, 'web');
    }

    public static function deniedIdentities(): array
    {
        return [
            'role-only' => ['admin', false, 'other'],
            'list-only' => ['user', false, 'self'],
            'empty-list' => ['admin', false, 'empty'],
            'disabled-admin' => ['admin', true, 'self'],
            'ordinary' => ['user', false, 'empty'],
        ];
    }

    #[DataProvider('deniedIdentities')]
    public function test_incomplete_identity_cannot_login_or_manage_even_with_valid_csrf(
        string $role, bool $disabled, string $listMode
    ): void {
        $actor = $this->account('19900000882', $role, $disabled);
        $target = $this->account('19900000883');
        config(['app.admin_phones' => match ($listMode) {
            'self' => [$actor->phone], 'other' => ['19900000999'], default => [],
        }]);
        $this->withSession(['_token' => 'identity-fixture-csrf'])->from('/admin/login')
            ->post('/admin/login', ['_token' => 'identity-fixture-csrf', 'phone' => $actor->phone,
                'password' => 'fixture-password'])->assertRedirect('/admin/login')->assertSessionHasErrors('phone');
        $this->assertGuest('web');
        $this->actingAs($actor, 'web')->get('/admin')->assertForbidden();
        $this->post('/admin/users/'.$target->id.'/disable', $this->disablePayload('identity-fixture-csrf'))
            ->assertForbidden();
        $this->assertDatabaseHas('users', ['id' => $target->id, 'disabled' => false, 'admin_revision' => 0]);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_valid_session_and_csrf_do_not_allow_self_target(): void
    {
        $admin = $this->admin();
        $this->login($admin);
        $csrf = session()->token();
        $this->post('/admin/users/'.$admin->id.'/disable', $this->disablePayload($csrf))->assertForbidden();
        $this->assertDatabaseHas('users', ['id' => $admin->id, 'disabled' => false, 'admin_revision' => 0]);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_login_and_logout_rotate_session_and_csrf_and_old_csrf_is_rejected(): void
    {
        $admin = $this->admin();
        $target = $this->account('19900000884');
        $this->withSession(['_token' => 'pre-login-fixture-csrf']);
        $beforeLogin = session()->getId();
        $this->login($admin);
        $afterLogin = session()->getId();
        $csrf = session()->token();
        $this->assertNotSame($beforeLogin, $afterLogin);
        $this->assertNotSame('pre-login-fixture-csrf', $csrf);
        Auth::forgetGuards();
        $this->get('/admin')->assertOk();
        $this->post('/admin/users/'.$target->id.'/disable',
            $this->disablePayload('pre-login-fixture-csrf'))->assertStatus(419);
        $this->post('/admin/users/'.$target->id.'/disable',
            array_diff_key($this->disablePayload($csrf), ['_token' => true]))->assertStatus(419);
        $this->assertDatabaseHas('users', ['id' => $target->id, 'disabled' => false]);
        $this->post('/admin/logout', ['_token' => $csrf])->assertRedirect('/admin/login');
        $this->assertNotSame($afterLogin, session()->getId());
        $this->assertNotSame($csrf, session()->token());
        $this->assertGuest('web');
        Auth::forgetGuards();
        $this->get('/admin')->assertRedirect('/admin/login');
        $this->post('/admin/users/'.$target->id.'/disable', $this->disablePayload($csrf))->assertStatus(419);
        $this->post('/admin/users/'.$target->id.'/disable', $this->disablePayload(session()->token()))
            ->assertRedirect('/admin/login');
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_demoted_existing_web_session_loses_read_and_write_access(): void
    {
        $admin = $this->admin();
        $target = $this->account('19900000885');
        $this->login($admin);
        $csrf = session()->token();
        $this->get('/admin')->assertOk();
        DB::table('users')->where('id', $admin->id)->update(['role' => 'user']);
        // Emulate the next HTTP request's guard resolution from the existing session.
        Auth::forgetGuards();
        $this->get('/admin')->assertForbidden();
        $this->post('/admin/users/'.$target->id.'/disable', $this->disablePayload($csrf))->assertForbidden();
        $this->assertDatabaseHas('users', ['id' => $target->id, 'disabled' => false, 'admin_revision' => 0]);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_disabled_existing_web_session_loses_access(): void
    {
        $admin = $this->admin();
        $this->login($admin);
        DB::table('users')->where('id', $admin->id)->update(['disabled' => true]);
        Auth::forgetGuards();
        $this->get('/admin')->assertForbidden();
        $this->post('/admin/logout', ['_token' => session()->token()])->assertForbidden();
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_removed_allowlist_entry_revokes_an_existing_session(): void
    {
        $admin = $this->admin();
        $this->login($admin);
        config(['app.admin_phones' => []]);
        Auth::forgetGuards();
        $this->get('/admin')->assertForbidden();
        $this->post('/admin/users/'.$admin->id.'/disable', $this->disablePayload(session()->token()))
            ->assertForbidden();
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }
}

final class EnforcedV1008SessionCsrf extends ValidateCsrfToken
{
    protected function runningUnitTests(): bool
    {
        return false;
    }
}

