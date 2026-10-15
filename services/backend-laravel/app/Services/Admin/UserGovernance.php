<?php
namespace App\Services\Admin;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Accounts\DisableUser;
use Illuminate\Support\Facades\DB;
final class UserGovernance {
 public function target(User $actor,int $id):User {
  $trusted=User::whereKey($actor->id)->lockForUpdate()->first();abort_unless(app(AdminAccess::class)->allows($trusted),403);
  $u=User::whereKey($id)->lockForUpdate()->firstOrFail();abort_unless($u->role==='user'&&$u->id!==$actor->id,403);return $u;
 }
 private function version(User $u,int $expected):void {abort_unless((int)$u->admin_revision===$expected,409,'stale user revision');}
 private function reason(string $reason):void {abort_unless(trim($reason)!==''&&mb_strlen($reason)<=1000,422,'reason required');}
 public function review(User $actor,int $id,string $status,string $reason,int $expected):void {
  $this->reason($reason);abort_unless(in_array($status,['pending','approved','rejected'],true),422);
  DB::transaction(function()use($actor,$id,$status,$reason,$expected){$u=$this->target($actor,$id);abort_unless((int)$u->verify_revision===$expected,409,'stale verification revision');$before=['status'=>$u->verify_status,'revision'=>(int)$u->verify_revision];$u->forceFill(['verify_status'=>$status,'verify_reason'=>$reason,'verify_revision'=>$expected+1])->save();OperationAudit::record($actor->id,'user.review','user',$id,$reason,$expected,$before,['status'=>$status,'revision'=>$expected+1]);});
 }
 public function punish(User $actor,int $id,string $kind,string $reason,int $expected,?int $report=null):int {
  $this->reason($reason);abort_unless(in_array($kind,['restrict','banned'],true),422);
  return DB::transaction(function()use($actor,$id,$kind,$reason,$expected,$report){$u=$this->target($actor,$id);$this->version($u,$expected);$before=$this->summary($u);
   if($u->disabled&&!DB::table('admin_sanctions')->where('user_id',$id)->where('active',true)->whereIn('kind',['banned','external_ban'])->exists())DB::table('admin_sanctions')->insert(['user_id'=>$id,'report_id'=>null,'kind'=>'external_ban','active'=>true,'actor_user_id'=>$actor->id,'reason'=>'Pre-existing independent disable; not restorable through this action','created_at'=>now(),'updated_at'=>now()]);
   $sid=DB::table('admin_sanctions')->insertGetId(['user_id'=>$id,'report_id'=>$report,'kind'=>$kind,'active'=>true,'actor_user_id'=>$actor->id,'reason'=>$reason,'created_at'=>now(),'updated_at'=>now()]);
   if($kind==='banned'){app(DisableUser::class)->execute($id);$u->refresh();$this->revokeConsent($id,$actor->id);}
   else { if(!$u->disabled)$u->moderation_status='restricted';$u->is_match_eligible=false; }
   $u->admin_revision=$expected+1;$u->save();OperationAudit::record($actor->id,'user.'.$kind,'user',$id,$reason,$expected,$before,$this->summary($u)+['sanction_id'=>$sid]);return $sid;
  });
 }
 public function restore(User $actor,int $id,int $sanction,string $reason,int $expected,?int $report=null):void {
  $this->reason($reason);
  DB::transaction(function()use($actor,$id,$sanction,$reason,$expected,$report){$u=$this->target($actor,$id);$this->version($u,$expected);$s=DB::table('admin_sanctions')->where('id',$sanction)->lockForUpdate()->first();abort_unless($s&&(int)$s->user_id===$id&&$s->active&&in_array($s->kind,['restrict','banned'],true)&&($report===null||(int)$s->report_id===$report),409,'active sanction ownership required');$before=$this->summary($u);
   DB::table('admin_sanctions')->where('id',$sanction)->update(['active'=>false,'restored_by'=>$actor->id,'restored_at'=>now(),'updated_at'=>now()]);
   $remaining=DB::table('admin_sanctions')->where('user_id',$id)->where('active',true)->pluck('kind');
   // A disabled account without a matching tracked ban is not ours to restore.
   $unknownBan=$u->disabled&&$s->kind!=='banned'&&!($remaining->contains('banned')||$remaining->contains('external_ban'));
   $u->disabled=($remaining->contains('banned')||$remaining->contains('external_ban'))||$unknownBan;$u->moderation_status=$u->disabled?'banned':($remaining->contains('restrict')?'restricted':'normal');
   $u->account_status=$u->disabled?'disabled':'active';$u->visibility_scope=$u->disabled?'hidden':'square';$u->is_match_eligible=!$u->disabled&&!$remaining->contains('restrict');$u->is_square_visible=!$u->disabled;$u->exclude_from_metrics=$u->disabled;$u->admin_revision=$expected+1;$u->save();
   $this->revokeConsent($id,$actor->id);OperationAudit::record($actor->id,'user.restore','user',$id,$reason,$expected,$before,$this->summary($u)+['sanction_id'=>$sanction]);
  });
 }
 private function summary(User $u):array{return ['disabled'=>(bool)$u->disabled,'moderation_status'=>$u->moderation_status,'revision'=>(int)$u->admin_revision];}
 private function revokeConsent(int $id,int $actor):void {
  $connections=DB::table('product_connections')->where('user_a',$id)->orWhere('user_b',$id)->orderBy('id')->lockForUpdate()->get();
  foreach($connections as $c){$rows=DB::table('messaging_consents')->where('connection_id',$c->id)->orderBy('id')->lockForUpdate()->get();$gen=(int)($rows->max('generation')??1);$current=$rows->where('generation',$gen);if($current->isEmpty())continue;$revision=(int)$current->max('revision')+1;
   DB::table('messaging_consents')->where('connection_id',$c->id)->where('generation',$gen)->whereNotIn('state',['MC_REVOKED','MC_DECLINED','MC_WITHDRAWN'])->update(['state'=>'MC_REVOKED','revision'=>$revision,'updated_at'=>now()]);
   DB::table('live_consent_events')->insert(['connection_id'=>$c->id,'kind'=>'sanction','actor_id'=>$actor,'from_state'=>'CURRENT','to_state'=>'MC_REVOKED','revision'=>$revision,'created_at'=>now()]);
  }
 }
}
