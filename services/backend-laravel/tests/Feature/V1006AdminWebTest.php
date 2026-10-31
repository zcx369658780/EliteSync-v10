<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Accounts\DisableUser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery as ValidateCsrfToken;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class V1006AdminWebTest extends TestCase
{
    use RefreshDatabase;

    private function account(string $role = 'user', string $phone = '19900000602'): User
    {
        return User::create(['name' => 'Fictional test', 'phone' => $phone,
            'password' => 'fixture-password', 'role' => $role, 'disabled' => false,
            'city' => 'Before', 'gender' => 'male', 'relationship_goal' => 'friendship']);
    }

    private function administrator(): User
    {
        $admin = $this->account('admin', '19900000601');
        config(['app.admin_phones' => [$admin->phone]]);
        return $admin;
    }

    public function test_web_login_search_and_disable_share_the_api_action(): void
    {
        $admin = $this->administrator();
        $target = $this->account();
        $target->createToken('old');
        DB::table('sessions')->insert(['id' => 'old-session', 'user_id' => $target->id,
            'payload' => '', 'last_activity' => time()]);
        $this->post('/admin/login', ['phone' => $admin->phone, 'password' => 'fixture-password'])
            ->assertRedirect('/admin');
        $this->get('/admin?q='.$target->id)->assertOk()->assertSee($target->phone);
        $this->post('/admin/users/'.$target->id.'/disable', ['confirm_disable' => '1', 'expected_revision' => 0, 'reason' => 'Fixture account disable'])
            ->assertRedirect('/admin');
        $this->assertDatabaseHas('users', ['id' => $target->id, 'disabled' => true, 'moderation_status' => 'banned']);
        $this->assertDatabaseMissing('personal_access_tokens', ['tokenable_id' => $target->id]);
        $this->assertDatabaseMissing('sessions', ['user_id' => $target->id]);
        $this->assertDatabaseHas('users', ['id' => $target->id, 'admin_revision' => 1,
            'account_status' => 'disabled', 'visibility_scope' => 'hidden', 'is_match_eligible' => false]);
        $this->assertDatabaseHas('admin_sanctions', ['user_id' => $target->id,
            'kind' => 'banned', 'active' => true, 'actor_user_id' => $admin->id]);
        $this->assertDatabaseHas('admin_operation_audits', ['actor_user_id' => $admin->id,
            'action' => 'user.banned', 'target_type' => 'user', 'target_id' => (string) $target->id,
            'reason' => 'Fixture account disable', 'expected_version' => 0]);
        $this->assertDatabaseCount('admin_operation_audits', 1);
    }

    public function test_empty_admin_list_rejects_web_and_api_even_in_local(): void
    {
        $admin = $this->administrator();
        $this->app->detectEnvironment(fn () => 'local');
        config(['app.admin_phones' => []]);
        $this->actingAs($admin, 'web')->get('/admin')->assertForbidden();
        $this->getJson('/api/v1/admin/users')->assertForbidden();
    }

    public function test_valid_csrf_does_not_grant_a_whitelisted_ordinary_user_management(): void
    {
        $user = $this->account();
        $target = $this->account('user', '19900000603');
        config(['app.admin_phones' => [$user->phone]]);
        $this->app->bind(ValidateCsrfToken::class, fn ($app) => new EnforcedV1006Csrf($app, $app['encrypter']));
        $this->actingAs($user, 'web')->withSession(['_token' => 'valid-csrf-fixture'])
            ->post('/admin/users/'.$target->id.'/disable', ['_token' => 'valid-csrf-fixture', 'confirm_disable' => '1', 'expected_revision' => 0, 'reason' => 'Unauthorized fixture disable'])
            ->assertForbidden();
        $this->getJson('/api/v1/admin/users')->assertForbidden();
        $this->assertDatabaseHas('users', ['id' => $target->id, 'disabled' => false]);
    }

    public function test_missing_csrf_is_rejected_and_web_logout_invalidates_authentication(): void
    {
        $admin = $this->administrator();
        $this->app->bind(ValidateCsrfToken::class, fn ($app) => new EnforcedV1006Csrf($app, $app['encrypter']));
        $this->actingAs($admin, 'web')->withSession(['_token' => 'valid-csrf-fixture'])
            ->post('/admin/logout')->assertStatus(419);
        $this->post('/admin/logout', ['_token' => 'valid-csrf-fixture'])->assertRedirect('/admin/login');
        $this->assertGuest('web');
        $this->get('/admin')->assertRedirect('/admin/login');
    }

    public function test_disabled_user_cannot_login_refresh_or_use_profile_with_old_token(): void
    {
        $target = $this->account();
        $control = $this->account('user', '19900000603');
        $token = $target->createToken('old')->plainTextToken;
        app(DisableUser::class)->execute($target->id);
        $this->postJson('/api/v1/auth/login', ['phone' => $target->phone, 'password' => 'fixture-password'])->assertForbidden();
        $this->withToken($token)->postJson('/api/v1/auth/refresh')->assertUnauthorized();
        $this->withToken($token)->getJson('/api/v1/profile/basic')->assertUnauthorized();
        $this->withToken($token)->postJson('/api/v1/profile/city', ['city' => 'Forbidden'])->assertUnauthorized();
        $this->assertDatabaseHas('users', ['id' => $target->id, 'city' => 'Before']);
        $this->assertDatabaseHas('users', ['id' => $control->id, 'disabled' => false]);
    }

    public function test_active_refresh_retains_response_contract(): void
    {
        $user = $this->account();
        $token = $user->createToken('old')->plainTextToken;
        $this->withToken($token)->postJson('/api/v1/auth/refresh')->assertOk()
            ->assertJsonPath('user.id', $user->id)->assertJsonStructure(['access_token', 'token_type', 'user']);
    }

    public function test_city_is_persisted_without_creating_algorithm_records_and_invalid_input_is_rejected(): void
    {
        $user = $this->account();
        $this->actingAs($user)->postJson('/api/v1/profile/city', ['city' => 'Development City'])->assertOk();
        $this->assertDatabaseHas('users', ['id' => $user->id, 'city' => 'Development City']);
        $this->assertDatabaseCount('user_astro_profiles', 0);
        $this->postJson('/api/v1/profile/city', ['city' => ''])->assertUnprocessable();
        $this->getJson('/api/v1/profile/basic')->assertOk()->assertJsonPath('city', 'Development City');
    }

    public function test_disabled_existing_web_identity_and_direct_admin_target_post_are_rejected(): void
    {
        $admin = $this->administrator();
        $this->actingAs($admin, 'web')->post('/admin/users/'.$admin->id.'/disable', ['confirm_disable' => '1', 'expected_revision' => 0, 'reason' => 'Fixture account disable'])->assertForbidden();
        $this->assertDatabaseHas('users', ['id' => $admin->id, 'disabled' => false, 'admin_revision' => 0]);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertDatabaseCount('admin_operation_audits', 0);
        $admin->disabled = true;
        $admin->save();
        $this->get('/admin')->assertForbidden();
    }
}

final class EnforcedV1006Csrf extends ValidateCsrfToken
{
    protected function runningUnitTests(): bool { return false; }
}

