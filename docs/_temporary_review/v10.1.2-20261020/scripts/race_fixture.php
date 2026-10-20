<?php
require __DIR__.'/runtime_bootstrap.php';
use App\Models\User;
use App\Services\TrustedIdentityService;
use App\Services\FormalRelationshipService;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Support\Facades\DB;
$scenario=$argv[1];
if(!preg_match('/^[a-z_]+$/',$scenario)){exit(39);}
$out=['scenario'=>$scenario];
foreach(['owner','viewer','third'] as $role){
 $u=User::create(['name'=>'V1012 Synthetic Race '.$scenario.' '.$role,'phone'=>'syn-'.bin2hex(random_bytes(7)),'password'=>bin2hex(random_bytes(20)),'is_synthetic'=>true,'verify_status'=>'approved','account_status'=>'active','moderation_status'=>'normal','disabled'=>false,'birthday'=>'1994-02-03','public_personality'=>['SYNTHETIC_INTEREST'],'public_zodiac_sign'=>'SYNTHETIC_ZODIAC']);
 $u->forceFill(['relationship_resume'=>'SYNTHETIC_PRIVATE_RESUME'])->save();
 app(TrustedIdentityService::class)->register($u->id);
 $out[$role]=['id'=>$u->id,'credential'=>app(TrustedIdentityService::class)->issue($u->id,'race-'.$scenario.'-'.$role,120),'session'=>app(DeviceSessions::class)->issue($u,'v1012-race-'.$scenario)];
}
$a=$out['owner']['id'];$b=$out['viewer']['id'];$s=app(FormalRelationshipService::class);
$r=$s->request($a,$b,'race-'.$scenario.'-request');$r=$s->action($a,$r['id'],'confirm',$r['revision'],'race-'.$scenario.'-confirm-a');
if($scenario!=='exclusive'){$r=$s->action($b,$r['id'],'confirm',$r['revision'],'race-'.$scenario.'-confirm-b');}
$out['relationship']=$r;
DB::table('privacy_preferences')->insert(['user_id'=>$a,'fields'=>json_encode(array_fill_keys(['birthday','interests','resume','zodiac'],'RELATIONSHIP_SHARED')),'revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
if($scenario==='exclusive'){$c=$out['third']['id'];$r2=$s->request($a,$c,'race-exclusive-request-2');$out['relationship2']=$s->action($a,$r2['id'],'confirm',$r2['revision'],'race-exclusive-confirm-a-2');}
file_put_contents(__DIR__.'/race-'.$scenario.'.private.json',json_encode($out));
echo json_encode(['scenario'=>$scenario,'state'=>$r['state'],'registered_synthetic_subjects'=>3]);
