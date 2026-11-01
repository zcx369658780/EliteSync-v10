<?php

namespace App\Services\Accounts;

use App\Models\User;
use App\Services\RtcAuthorityService;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Laravel\Sanctum\PersonalAccessToken;

final class DeviceSessions
{
    public function issue(User $user, string $label = 'Mobile', bool $successfulLogin = false, ?string $deviceId = null): array
    {
        return DB::transaction(function () use ($user, $label, $successfulLogin, $deviceId) {
            $user = User::query()->lockForUpdate()->findOrFail($user->id);
            abort_if($user->disabled || $this->hasClosure($user), 403, 'ACCOUNT_UNAVAILABLE');
            $id = (string) Str::uuid();
            $issuedAt = now('UTC')->startOfSecond();
            DB::table('device_sessions')->insert(['id' => $id, 'user_id' => $user->id,
                'label' => mb_substr($label, 0, 80), 'last_used_at' => $issuedAt, 'created_at' => $issuedAt, 'updated_at' => $issuedAt,
                'trusted_login_at' => $successfulLogin ? $issuedAt : null,
                'device_id' => $deviceId ?? (string) Str::uuid()]);

            return $this->tokens($user, $id);
        });
    }

    private function tokens(User $user, string $id): array
    {
        $family = DB::table('device_sessions')->where('id', $id)->where('user_id', $user->id)->first();
        abort_unless($family && ! $family->revoked_at, 401, 'SESSION_REVOKED');
        $deadline = $this->onlineDeadline($family);
        abort_if($deadline->lessThanOrEqualTo(now('UTC')), 401, 'ONLINE_LOGIN_EXPIRED');
        $access = $user->createToken('mobile-access', ['*'], $deadline);
        $refresh = $user->createToken('mobile-refresh', ['session:refresh'], $deadline);
        DB::table('personal_access_tokens')->whereIn('id', [$access->accessToken->id, $refresh->accessToken->id])
            ->update(['device_session_id' => $id]);

        return ['access_token' => $access->plainTextToken, 'refresh_token' => $refresh->plainTextToken,
            'session_id' => $id, 'token_type' => 'Bearer', 'session_retention' => $this->retentionReceipt($family)];
    }

    /** Server-owned anchor; registration/legacy families never acquire a login T0 through refresh. */
    public function onlineDeadline(object $family): CarbonImmutable
    {
        $anchor = $family->trusted_login_at ?? $family->created_at ?? null;
        try {
            $deadline = \App\Domain\TrustedLoginTimeContract::deadline(
                is_string($anchor) ? $anchor : '', CarbonImmutable::now('UTC')->toDateTimeImmutable());
            return CarbonImmutable::instance($deadline);
        } catch (\InvalidArgumentException) {
            abort(401, 'SESSION_TIME_UNTRUSTED');
        }
    }

    private function retentionReceipt(object $family): ?array
    {
        if (! $family->trusted_login_at || ! $family->device_id) {
            return null;
        }
        $loginAt = $this->onlineDeadline($family)->subDays(15);

        return ['login_at' => $loginAt->toISOString(), 'server_now' => now('UTC')->toISOString(),
            'online_expires_at' => $loginAt->addDays(15)->toISOString(), 'purge_at' => $loginAt->addDays(30)->toISOString(),
            'device_id' => $family->device_id, 'session_id' => $family->id, 'user_id' => (int) $family->user_id];
    }

    public function refresh(User $actor, PersonalAccessToken $presented): array
    {
        return DB::transaction(function () use ($actor, $presented) {
            $user = User::query()->lockForUpdate()->findOrFail($actor->id);
            abort_if($user->disabled || $this->hasClosure($user), 403, 'ACCOUNT_UNAVAILABLE');
            // Authentication may have happened before a concurrent logout/refresh committed.
            $token = PersonalAccessToken::query()->whereKey($presented->id)->lockForUpdate()->first();
            abort_unless($token && (int) $token->tokenable_id === (int) $user->id
                && $token->tokenable_type === $user->getMorphClass(), 401, 'SESSION_REVOKED');
            $id = $token->device_session_id;
            // An old credential cannot manufacture a new successful-login event.
            abort_unless($id, 401, 'PASSWORD_LOGIN_REQUIRED');
            $family = DB::table('device_sessions')->where('id', $id)->where('user_id', $user->id)->lockForUpdate()->first();
            abort_unless($family && ! $family->revoked_at, 401, 'SESSION_REVOKED');
            abort_if($this->onlineDeadline($family)->lessThanOrEqualTo(now('UTC'))
                || ($token->expires_at && $token->expires_at->lessThanOrEqualTo(now('UTC'))), 401, 'ONLINE_LOGIN_EXPIRED');
            $user->tokens()->where('device_session_id', $id)->delete();
            DB::table('device_sessions')->where('id', $id)->update(['last_used_at' => now(), 'updated_at' => now()]);

            return $this->tokens($user, $id);
        });
    }

    public function revoke(User $actor, string $id): void
    {
        DB::transaction(function () use ($actor, $id) {
            User::query()->lockForUpdate()->findOrFail($actor->id);
            $family = DB::table('device_sessions')->where('id', $id)->where('user_id', $actor->id)->lockForUpdate()->first();
            abort_unless($family, 404);
            DB::table('device_sessions')->where('id', $id)->update(['revoked_at' => now(), 'updated_at' => now()]);
            $actor->tokens()->where('device_session_id', $id)->delete();
            if (Schema::hasTable('notification_devices')) {
                DB::table('notification_devices')->where('user_id',$actor->id)->where('device_session_id',$id)
                    ->whereNull('revoked_at')->update(['revoked_at'=>now(),'updated_at'=>now()]);
            }
            app(RtcAuthorityService::class)->revokeDevice((int) $actor->id, $id);
        });
    }

    public function revokeAll(User $actor): void
    {
        DB::transaction(function () use ($actor) {
            User::query()->lockForUpdate()->findOrFail($actor->id);
            DB::table('device_sessions')->where('user_id', $actor->id)->whereNull('revoked_at')
                ->update(['revoked_at' => now(), 'updated_at' => now()]);
            $actor->tokens()->delete();
            if (Schema::hasTable('notification_devices')) {
                DB::table('notification_devices')->where('user_id',$actor->id)->whereNull('revoked_at')
                    ->update(['revoked_at'=>now(),'updated_at'=>now()]);
            }
            DB::table('sessions')->where('user_id', $actor->id)->delete();
            app(RtcAuthorityService::class)->revokeDevice((int) $actor->id, null);
        });
    }

    private function hasClosure(User $user): bool
    {
        return Schema::hasTable('account_closures') && DB::table('account_closures')->where('user_id', $user->id)->exists();
    }
}
