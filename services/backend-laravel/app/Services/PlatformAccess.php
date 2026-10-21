<?php

namespace App\Services;

use App\Models\User;
use App\Services\Accounts\AdminAccess;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

final class PlatformAccess
{
    public function gate(): void
    {
        $db=DB::connection();
        $testing=app()->environment('testing') && $db->getDriverName()==='sqlite' && $db->getDatabaseName()===':memory:';
        $local=app()->environment('local') && in_array($db->getDriverName(),['mysql','mariadb'],true)
            && $db->getDatabaseName()==='elitesync_v10_1_4_dev' && $db->getConfig('host')==='127.0.0.1'
            && (int)$db->getConfig('port')===43325 && !$db->getConfig('url') && !$db->getConfig('unix_socket');
        abort_unless($testing || $local,404,'unavailable');
    }

    public function users(array $ids): void
    {
        $this->gate();
        app(JourneyStore::class)->users($ids,true);
    }

    public function available(int $id,bool $restricted=false): bool
    {
        return User::whereKey($id)->where('is_synthetic',true)->where('disabled',false)
            ->where('account_status','active')->whereIn('moderation_status',$restricted?['normal','restricted']:['normal'])
            ->lockForUpdate()->exists();
    }

    public function admin(int $id): User
    {
        $user=User::whereKey($id)->lockForUpdate()->first();
        abort_unless($this->available($id) && app(AdminAccess::class)->allows($user),403);
        if (request()->hasSession()) {
            $hash=hash('sha256',request()->session()->getId());
            abort_unless(DB::table('platform_admin_sessions')->where('session_hash',$hash)->where('user_id',$id)
                ->whereNull('revoked_at')->lockForUpdate()->exists(),401,'admin session revoked; login again');
        }
        return $user;
    }

    /** The event source needs current organizer authority, not the viewer's Web session. */
    public function organizer(int $id): bool
    {
        $user=User::whereKey($id)->lockForUpdate()->first();
        return $this->available($id) && app(AdminAccess::class)->allows($user);
    }

    public function recordAdminSession(int $id,string $session): void
    {
        if (!Schema::hasTable('platform_admin_sessions')) return;
        DB::transaction(function()use($id,$session){
            User::whereKey($id)->lockForUpdate()->firstOrFail();
            DB::table('platform_admin_sessions')->insert(['session_hash'=>hash('sha256',$session),'user_id'=>$id,'created_at'=>now(),'updated_at'=>now()]);
        });
    }

    public function revokeAdminSession(int $id,string $session): void
    {
        if (!Schema::hasTable('platform_admin_sessions')) return;
        DB::transaction(function()use($id,$session){
            User::whereKey($id)->lockForUpdate()->firstOrFail();
            DB::table('platform_admin_sessions')->where('session_hash',hash('sha256',$session))->where('user_id',$id)
                ->update(['revoked_at'=>now(),'updated_at'=>now()]);
        });
    }
}
