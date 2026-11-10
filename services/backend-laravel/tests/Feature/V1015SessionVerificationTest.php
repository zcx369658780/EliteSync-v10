<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

class V1015SessionVerificationTest extends TestCase
{
    use RefreshDatabase;

    private function member(): User
    {
        static $number = 1000;

        return User::factory()->create(['disabled' => false, 'phone' => '1990000'.(++$number)]);
    }

    private function issueSession(User $user, string $device = 'verification-device-a'): array
    {
        return app(DeviceSessions::class)->issue($user, 'Mobile', true, $device);
    }

    private function verifySession(array $session, ?string $refresh = null)
    {
        $this->app['auth']->forgetGuards();

        return $this->withToken($session['access_token'])->postJson('/api/v1/auth/session/verify', [
            'refresh_token' => $refresh ?? $session['refresh_token'],
        ]);
    }

    public function test_online_verification_preserves_both_credentials_and_original_deadlines(): void
    {
        $this->travelTo(now()->startOfSecond());
        $user = $this->member();
        $session = $this->issueSession($user);
        $ids = $user->tokens()->orderBy('id')->pluck('id')->all();
        $this->travel(2)->days();
        $reply = $this->verifySession($session)->assertOk()->assertJsonPath('verified', true);
        $reply->assertJsonPath('user.id', $user->id);
        $reply->assertJsonPath('session_id', $session['session_id']);
        foreach (['login_at', 'online_expires_at', 'purge_at', 'user_id', 'device_id', 'session_id'] as $field) {
            $this->assertSame($session['session_retention'][$field], $reply->json('session_retention.'.$field));
        }
        $this->assertNotSame($session['session_retention']['server_now'], $reply->json('session_retention.server_now'));
        $this->assertSame($ids, $user->tokens()->orderBy('id')->pluck('id')->all());
        $this->assertNotNull(PersonalAccessToken::findToken($session['access_token']));
        $this->assertNotNull(PersonalAccessToken::findToken($session['refresh_token']));
        $reply->assertJsonMissingPath('access_token')->assertJsonMissingPath('refresh_token');
    }

    public function test_another_account_or_device_family_cannot_be_paired_with_access(): void
    {
        $user = $this->member();
        $other = $this->member();
        $session = $this->issueSession($user);
        $otherFamily = $this->issueSession($user, 'verification-device-b');
        $otherUser = $this->issueSession($other);
        $this->verifySession($session, $otherFamily['refresh_token'])->assertUnauthorized();
        $this->verifySession($session, $otherUser['refresh_token'])->assertUnauthorized();
        $this->verifySession($session, $session['access_token'])->assertUnauthorized();
        $this->assertSame(6, PersonalAccessToken::query()->count());
    }

    public function test_revoked_disabled_and_untrusted_login_families_stay_closed(): void
    {
        $user = $this->member();
        $session = $this->issueSession($user);
        DB::table('device_sessions')->where('id', $session['session_id'])->update(['revoked_at' => now()]);
        $this->verifySession($session)->assertUnauthorized();
        $session = $this->issueSession($user);
        $user->update(['disabled' => true]);
        $this->verifySession($session)->assertForbidden();
        $user->update(['disabled' => false]);
        $session = app(DeviceSessions::class)->issue($user);
        $this->verifySession($session)->assertUnauthorized();
    }

    public function test_fifteen_day_boundary_is_not_renewed_by_verification(): void
    {
        $this->travelTo(now()->startOfSecond());
        $user = $this->member();
        $session = $this->issueSession($user);
        $this->travel(15)->days();
        $this->verifySession($session)->assertUnauthorized();
        $this->assertSame(1, DB::table('device_sessions')->count());
        $this->assertSame(\Carbon\CarbonImmutable::parse($session['session_retention']['login_at'])->format('Y-m-d H:i:s'),
            DB::table('device_sessions')->where('id', $session['session_id'])->value('trusted_login_at'));
    }
}
