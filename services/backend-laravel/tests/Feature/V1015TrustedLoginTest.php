<?php

namespace Tests\Feature;

use App\Http\Middleware\EnsureAccountActive;
use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class V1015TrustedLoginTest extends TestCase
{
    use RefreshDatabase;

    private function member(): User
    {
        return User::factory()->create(['phone' => '13811111501', 'password' => Hash::make('Password123'),
            'role' => 'user', 'disabled' => false]);
    }

    public function test_password_login_returns_server_owned_account_device_and_fixed_deadlines(): void
    {
        $this->travelTo(now()->setDate(2026, 10, 21)->startOfSecond());
        $user = $this->member();
        $reply = $this->postJson('/api/v1/auth/login', ['phone' => $user->phone,
            'password' => 'Password123', 'device_id' => 'v1015-synthetic-device-a'])->assertOk();
        $receipt = $reply->json('session_retention');
        $this->assertSame((int) $user->id, $receipt['user_id']);
        $this->assertSame('v1015-synthetic-device-a', $receipt['device_id']);
        $this->assertSame(now()->toISOString(), $receipt['login_at']);
        $this->assertSame(now()->toISOString(), $receipt['server_now']);
        $this->assertSame(now()->addDays(15)->toISOString(), $receipt['online_expires_at']);
        $this->assertSame(now()->addDays(30)->toISOString(), $receipt['purge_at']);
        $this->assertSame($reply->json('session_id'), $receipt['session_id']);
        $this->assertDatabaseHas('device_sessions', ['id' => $receipt['session_id'], 'user_id' => $user->id,
            'device_id' => 'v1015-synthetic-device-a', 'trusted_login_at' => now()->format('Y-m-d H:i:s')]);
        foreach (['access_token', 'refresh_token'] as $key) {
            $token = PersonalAccessToken::findToken($reply->json($key));
            $this->assertSame(now()->addDays(15)->format('Y-m-d H:i:s'), $token->expires_at->format('Y-m-d H:i:s'));
        }
    }

    public function test_registration_does_not_create_a_successful_login_or_offline_receipt(): void
    {
        $reply = $this->postJson('/api/v1/auth/register', ['phone' => '13811111502',
            'password' => 'Password123'])->assertCreated();
        $reply->assertJsonPath('session_retention', null);
        $family = DB::table('device_sessions')->where('id', $reply->json('session_id'))->first();
        $this->assertNull($family->trusted_login_at);
        $this->assertNotNull(PersonalAccessToken::findToken($reply->json('access_token'))->expires_at);
    }

    public function test_refresh_before_deadline_keeps_login_identity_and_expiration(): void
    {
        $this->travelTo(now()->setDate(2026, 10, 21)->startOfSecond());
        $user = $this->member();
        $issued = app(DeviceSessions::class)->issue($user, 'Mobile', true, 'v1015-device-a');
        $initial = $issued['session_retention'];
        $this->travel(14)->days();
        $refresh = app(DeviceSessions::class)->refresh($user, PersonalAccessToken::findToken($issued['refresh_token']));
        foreach (['login_at', 'online_expires_at', 'purge_at', 'user_id', 'device_id', 'session_id'] as $field) {
            $this->assertSame($initial[$field], $refresh['session_retention'][$field]);
        }
        $this->assertNotSame($initial['server_now'], $refresh['session_retention']['server_now']);
        $this->assertNull(PersonalAccessToken::findToken($issued['access_token']));
        $this->assertSame($initial['online_expires_at'], PersonalAccessToken::findToken($refresh['access_token'])->expires_at->toISOString());
    }

    public function test_exact_fifteen_day_deadline_rejects_refresh_and_private_read_without_new_family(): void
    {
        $this->travelTo(now()->setDate(2026, 10, 21)->startOfSecond());
        $user = $this->member();
        $issued = app(DeviceSessions::class)->issue($user, 'Mobile', true);
        $access = PersonalAccessToken::findToken($issued['access_token']);
        $refresh = PersonalAccessToken::findToken($issued['refresh_token']);
        $this->travel(15)->days();
        $this->assertDenied(fn () => app(DeviceSessions::class)->refresh($user, $refresh));
        $request = Request::create('/api/v1/profile/basic', 'GET');
        $request->setUserResolver(fn () => $user->withAccessToken($access));
        $this->assertDenied(fn () => app(EnsureAccountActive::class)->handle($request,
            fn () => response()->json(['unexpected' => true])));
        $this->assertSame(1, DB::table('device_sessions')->where('user_id', $user->id)->count());
    }

    public function test_future_login_anchor_is_rejected_and_legacy_refresh_does_not_become_login(): void
    {
        $user = $this->member();
        $issued = app(DeviceSessions::class)->issue($user, 'Mobile', true);
        DB::table('device_sessions')->where('id', $issued['session_id'])->update(['trusted_login_at' => now()->addDay()]);
        $this->assertDenied(fn () => app(DeviceSessions::class)->refresh($user, PersonalAccessToken::findToken($issued['refresh_token'])));
        $legacy = $user->createToken('pre-device-version', ['session:refresh']);
        $this->assertDenied(fn () => app(DeviceSessions::class)->refresh($user, $legacy->accessToken));
        $this->assertSame(1, DB::table('device_sessions')->where('user_id', $user->id)->count());
    }

    public function test_registration_refresh_retains_null_login_receipt_and_issued_deadline(): void
    {
        $user = $this->member();
        $issued = app(DeviceSessions::class)->issue($user);
        $deadline = PersonalAccessToken::findToken($issued['refresh_token'])->expires_at->toISOString();
        $this->travel(3)->days();
        $reply = app(DeviceSessions::class)->refresh($user, PersonalAccessToken::findToken($issued['refresh_token']));
        $this->assertNull($reply['session_retention']);
        $this->assertSame($deadline, PersonalAccessToken::findToken($reply['access_token'])->expires_at->toISOString());
        $this->assertNull(DB::table('device_sessions')->where('id', $issued['session_id'])->value('trusted_login_at'));
    }

    public function test_one_second_before_deadline_can_refresh_but_one_second_after_cannot(): void
    {
        $this->travelTo(now()->setDate(2026, 10, 21)->startOfSecond());
        $user = $this->member();
        $issued = app(DeviceSessions::class)->issue($user, 'Mobile', true);
        $this->travelTo(now()->addDays(15)->subSecond());
        $rotated = app(DeviceSessions::class)->refresh($user, PersonalAccessToken::findToken($issued['refresh_token']));
        $this->assertSame($issued['session_retention']['login_at'], $rotated['session_retention']['login_at']);
        $this->travel(2)->seconds();
        $this->assertDenied(fn () => app(DeviceSessions::class)->refresh($user, PersonalAccessToken::findToken($rotated['refresh_token'])));
    }

    public function test_expired_credentials_are_rejected_by_actual_refresh_and_private_api_routes(): void
    {
        $this->travelTo(now()->setDate(2026, 10, 21)->startOfSecond());
        $user = $this->member();
        $issued = $this->postJson('/api/v1/auth/login', ['phone' => $user->phone,
            'password' => 'Password123'])->assertOk()->json();
        $this->travel(15)->days();
        $this->app['auth']->forgetGuards();
        $this->withToken($issued['refresh_token'])->postJson('/api/v1/auth/refresh')->assertUnauthorized();
        $this->app['auth']->forgetGuards();
        $this->withToken($issued['access_token'])->getJson('/api/v1/profile/basic')->assertUnauthorized();
        $this->assertSame(1, DB::table('device_sessions')->where('user_id', $user->id)->count());
    }

    public function test_failed_password_login_cannot_create_time_anchor_or_device_family(): void
    {
        $user = $this->member();
        $this->postJson('/api/v1/auth/login', ['phone' => $user->phone,
            'password' => 'WrongPassword123', 'device_id' => 'v1015-device-failed'])->assertUnprocessable();
        $this->assertSame(0, DB::table('device_sessions')->where('user_id', $user->id)->count());
        $this->assertSame(0, $user->tokens()->count());
    }

    private function assertDenied(callable $operation): void
    {
        try {
            $operation();
            $this->fail('Expired, untrusted or legacy refresh must not succeed.');
        } catch (HttpException $error) {
            $this->assertSame(401, $error->getStatusCode());
        }
    }
}
