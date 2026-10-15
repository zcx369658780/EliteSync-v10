<?php
namespace Tests\Feature;
use App\Models\User;
use App\Services\Admin\UserGovernance;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;
class V1008PolicyTest extends TestCase {
 use RefreshDatabase;
 private function users():array { $a=User::create(['phone'=>'19900000801','password'=>'fixture-password','role'=>'admin']); config(['app.admin_phones'=>[$a->phone]]); return [$a,User::create(['phone'=>'19900000802','password'=>'fixture-password','role'=>'user'])]; }
 public function test_review_is_versioned_audited_and_stale_request_is_atomic():void {
  [$a,$u]=$this->users(); $s=app(UserGovernance::class);
  $s->review($a,$u->id,'approved','operating eligibility approved',0);
  $this->assertSame('approved',$u->fresh()->verify_status);$this->assertDatabaseCount('admin_operation_audits',1);
  try{$s->review($a,$u->id,'rejected','stale',0);$this->fail('stale accepted');}catch(\Symfony\Component\HttpKernel\Exception\HttpException $e){$this->assertSame(409,$e->getStatusCode());}
  $this->assertSame('approved',$u->fresh()->verify_status);$this->assertDatabaseCount('admin_operation_audits',1);
 }
 public function test_restrict_does_not_clear_ban_and_restore_requires_exact_owned_sanction():void {
  [$a,$u]=$this->users();$s=app(UserGovernance::class);$u->createToken('old');DB::table('sessions')->insert(['id'=>'old-session','user_id'=>$u->id,'payload'=>'','last_activity'=>time()]);
  $ban=$s->punish($a,$u->id,'banned','ban fixture',0);
  $restriction=$s->punish($a,$u->id,'restrict','independent restriction',1);
  $this->assertTrue($u->fresh()->disabled);$this->assertDatabaseMissing('sessions',['user_id'=>$u->id]);$this->assertSame(0,$u->tokens()->count());
  $s->restore($a,$u->id,$ban,'undo own ban',2);
  $this->assertFalse($u->fresh()->disabled);$this->assertSame('restricted',$u->fresh()->moderation_status);
  $s->restore($a,$u->id,$restriction,'undo restriction',3);$this->assertSame('normal',$u->fresh()->moderation_status);$this->assertSame(0,$u->tokens()->count());
 }
 public function test_role_only_actor_and_admin_targets_are_refused():void {
  [$a,$u]=$this->users();config(['app.admin_phones'=>[]]);
  try{app(UserGovernance::class)->review($a,$u->id,'approved','denied',0);$this->fail('unauthorized');}catch(\Symfony\Component\HttpKernel\Exception\HttpException $e){$this->assertSame(403,$e->getStatusCode());}
  $this->assertSame('pending',$u->fresh()->verify_status);
 }
}
