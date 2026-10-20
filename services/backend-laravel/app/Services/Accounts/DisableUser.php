<?php

namespace App\Services\Accounts;

use App\Models\User;
use App\Services\SocialPolicy;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

final class DisableUser
{
    public function execute(int $id): void
    {
        DB::transaction(function () use ($id) {
            $user = User::query()->lockForUpdate()->findOrFail($id);
            $user->disabled = true;
            $user->moderation_status = 'banned';
            foreach (['account_status' => 'disabled', 'visibility_scope' => 'hidden',
                'is_match_eligible' => false, 'is_square_visible' => false,
                'exclude_from_metrics' => true] as $column => $value) {
                if (Schema::hasColumn('users', $column)) {
                    $user->{$column} = $value;
                }
            }
            $user->remember_token = Str::random(60);
            $user->save();
            if (Schema::hasTable('device_sessions')) {
                app(DeviceSessions::class)->revokeAll($user);
            } else {
                $user->tokens()->delete();
                if (Schema::hasTable('sessions')) {
                    DB::table('sessions')->where('user_id', $id)->delete();
                }
            }
            app(SocialPolicy::class)->revokeUser($id);
        });
    }
}
