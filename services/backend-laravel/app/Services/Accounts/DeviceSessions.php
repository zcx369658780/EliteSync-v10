<?php

namespace App\Services\Accounts;

use App\Models\User;
use App\Services\RtcAuthorityService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Laravel\Sanctum\PersonalAccessToken;

final class DeviceSessions
{
    public function issue(User $user, string $label = 'Mobile'): array
    {
        return DB::transaction(function () use ($user, $label) {
            $user = User::query()->lockForUpdate()->findOrFail($user->id);
            abort_if($user->disabled || $this->hasClosure($user), 403, 'ACCOUNT_UNAVAILABLE');
            $id = (string) Str::uuid();
            DB::table('device_sessions')->insert(['id' => $id, 'user_id' => $user->id,
                'label' => mb_substr($label, 0, 80), 'last_used_at' => now(), 'created_at' => now(), 'updated_at' => now()]);

            return $this->tokens($user, $id);
        });
    }

    private function tokens(User $user, string $id): array
    {
        $access = $user->createToken('mobile-access', ['*']);
        $refresh = $user->createToken('mobile-refresh', ['session:refresh']);
        DB::table('personal_access_tokens')->whereIn('id', [$access->accessToken->id, $refresh->accessToken->id])
            ->update(['device_session_id' => $id]);

        return ['access_token' => $access->plainTextToken, 'refresh_token' => $refresh->plainTextToken,
            'session_id' => $id, 'token_type' => 'Bearer'];
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
            if (! $id) {
                // Upgrade a pre-version token exactly once, under the same account lock.
                $token->delete();

                return $this->issue($user);
            }
            $family = DB::table('device_sessions')->where('id', $id)->where('user_id', $user->id)->lockForUpdate()->first();
            abort_unless($family && ! $family->revoked_at, 401, 'SESSION_REVOKED');
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
            DB::table('sessions')->where('user_id', $actor->id)->delete();
            app(RtcAuthorityService::class)->revokeDevice((int) $actor->id, null);
        });
    }

    private function hasClosure(User $user): bool
    {
        return Schema::hasTable('account_closures') && DB::table('account_closures')->where('user_id', $user->id)->exists();
    }
}
