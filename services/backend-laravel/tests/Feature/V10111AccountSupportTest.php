<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Tests\TestCase;

final class V10111AccountSupportTest extends TestCase
{
    use RefreshDatabase;

    private function user(): User
    {
        return User::create(['phone' => '19900111101', 'password' => Hash::make('FictionalOld123'), 'role' => 'user']);
    }

    public function test_password_change_revokes_all_old_credentials_and_new_password_logs_in(): void
    {
        $user = $this->user();
        $sessions = app(DeviceSessions::class);
        $first = $sessions->issue($user, 'fictional first', true);
        $second = $sessions->issue($user, 'fictional second', true);
        $this->withToken($first['access_token'])->postJson('/api/v1/auth/password', [
            'current_password' => 'FictionalOld123', 'new_password' => 'FictionalNew123',
            'new_password_confirmation' => 'FictionalNew123',
        ])->assertOk()->assertJsonPath('status', 'PASSWORD_CHANGED_LOGIN_REQUIRED');
        $this->assertSame(0, DB::table('personal_access_tokens')->where('tokenable_id', $user->id)->count());
        $this->assertSame(0, DB::table('device_sessions')->where('user_id', $user->id)->whereNull('revoked_at')->count());
        $this->withToken($second['access_token'])->getJson('/api/v1/account/sessions')->assertUnauthorized();
        $this->withToken($second['refresh_token'])->postJson('/api/v1/auth/refresh')->assertUnauthorized();
        $this->postJson('/api/v1/auth/login', ['phone' => $user->phone, 'password' => 'FictionalOld123'])->assertUnprocessable();
        $this->postJson('/api/v1/auth/login', ['phone' => $user->phone, 'password' => 'FictionalNew123'])->assertOk()
            ->assertJsonPath('user.id', $user->id);
    }

    public function test_wrong_password_preserves_the_existing_session(): void
    {
        $user = $this->user();
        $tokens = app(DeviceSessions::class)->issue($user, 'fictional', true);
        $this->withToken($tokens['access_token'])->postJson('/api/v1/auth/password', [
            'current_password' => 'Wrong123', 'new_password' => 'FictionalNew123',
            'new_password_confirmation' => 'FictionalNew123',
        ])->assertUnprocessable();
        $this->withToken($tokens['access_token'])->getJson('/api/v1/account/sessions')->assertOk();
        $this->assertTrue(Hash::check('FictionalOld123', $user->fresh()->password));
    }

    public function test_password_characters_are_preserved_including_surrounding_spaces(): void
    {
        $user = $this->user();
        $tokens = app(DeviceSessions::class)->issue($user, 'fictional', true);
        $password = ' FictionalNew123 ';
        $this->withToken($tokens['access_token'])->postJson('/api/v1/auth/password', [
            'current_password' => 'FictionalOld123', 'new_password' => $password,
            'new_password_confirmation' => $password,
        ])->assertOk();
        $this->postJson('/api/v1/auth/login', ['phone' => $user->phone, 'password' => $password])->assertOk();
        $this->postJson('/api/v1/auth/login', ['phone' => $user->phone, 'password' => trim($password)])->assertUnprocessable();
    }

    public function test_revoked_bearer_snapshot_is_rejected_after_account_lock(): void
    {
        $user = $this->user();
        $tokens = app(DeviceSessions::class)->issue($user, 'fictional', true);
        $presented = \Laravel\Sanctum\PersonalAccessToken::findToken($tokens['access_token']);
        $user->withAccessToken($presented);
        app(DeviceSessions::class)->revokeAll($user);
        try {
            DB::transaction(function () use ($user) {
                User::whereKey($user->id)->lockForUpdate()->firstOrFail();
                app(DeviceSessions::class)->assertCurrentCredential($user);
            });
            $this->fail('A previously authenticated revoked bearer must be rejected.');
        } catch (HttpExceptionInterface $error) {
            $this->assertSame(401, $error->getStatusCode());
        }
    }

    public function test_recovery_capabilities_are_public_and_describe_actual_verification_boundary(): void
    {
        $this->getJson('/api/v1/auth/support-capabilities')->assertOk()
            ->assertJsonPath('password_recovery.available', false)
            ->assertJsonPath('password_recovery.status', 'VERIFICATION_PROVIDER_NOT_CONFIGURED')
            ->assertJsonPath('password_change.available', true)
            ->assertJsonPath('closure_receipt_recovery.requires.2', 'current_password')
            ->assertJsonMissingPath('user')->assertHeader('Cache-Control', 'no-store, private');
    }

    public function test_privacy_exact_retry_is_idempotent_and_different_stale_write_is_rejected(): void
    {
        $tokens = app(DeviceSessions::class)->issue($this->user(), 'fictional', true);
        $body = ['expected_revision' => 0, 'fields' => ['birthday' => 'SELF', 'interests' => 'SELF',
            'resume' => 'RELATIONSHIP_SHARED', 'zodiac' => 'SELF']];
        $this->withToken($tokens['access_token'])->putJson('/api/v1/privacy', $body)->assertOk()->assertJsonPath('revision', 1);
        $this->putJson('/api/v1/privacy', $body)->assertOk()->assertJsonPath('revision', 1);
        $body['fields']['resume'] = 'SELF';
        $this->putJson('/api/v1/privacy', $body)->assertConflict();
        $body['expected_revision'] = 1;
        $this->putJson('/api/v1/privacy', $body)->assertOk()->assertJsonPath('revision', 2);
        $this->putJson('/api/v1/privacy', $body)->assertOk()->assertJsonPath('revision', 2);
    }
}
