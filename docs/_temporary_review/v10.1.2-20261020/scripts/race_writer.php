<?php
require __DIR__.'/runtime_bootstrap.php';
use Illuminate\Support\Facades\DB;
use App\Models\User;
$scenario=$argv[1];$f=json_decode(file_get_contents(__DIR__.'/race-'.$scenario.'.private.json'),true);
$a=$f['owner']['id'];$b=$f['viewer']['id'];
DB::transaction(function()use($scenario,$f,$a,$b){
 User::whereIn('id',[$a,$b,$f['third']['id']])->orderBy('id')->lockForUpdate()->get();
 file_put_contents(__DIR__.'/race-'.$scenario.'.writer-locked',json_encode(['connection_id'=>DB::selectOne('SELECT CONNECTION_ID() id')->id,'isolation'=>DB::selectOne('SELECT @@tx_isolation level')->level]));
 $deadline=microtime(true)+45;
 while(!file_exists(__DIR__.'/race-'.$scenario.'.release')){if(microtime(true)>$deadline)throw new RuntimeException('barrier timeout');usleep(20000);}
 if($scenario==='audience'){
  $r=Illuminate\Http\Request::create('/api/v1/privacy','PUT',['expected_revision'=>1,'fields'=>array_fill_keys(['birthday','interests','resume','zodiac'],'SELF')]);$r->setUserResolver(fn()=>User::findOrFail($a));app(App\Http\Controllers\Api\V1\PrivacyController::class)->save($r);
 }elseif($scenario==='pause'){
  app(App\Services\FormalRelationshipService::class)->action($a,$f['relationship']['id'],'pause',$f['relationship']['revision'],'race-pause-write');
 }elseif($scenario==='credential'){
  app(App\Services\TrustedIdentityService::class)->revoke($a,$f['owner']['credential']);
  app(App\Services\TrustedIdentityService::class)->issue($a,'race-credential-reissued',120);
 }elseif(str_starts_with($scenario,'block')){
  $r=Illuminate\Http\Request::create('/api/v1/moderation/blocks','POST',['blocked_user_id'=>$b]);$r->setUserResolver(fn()=>User::findOrFail($a));app(App\Http\Controllers\Api\V1\ModerationController::class)->block($r,app(App\Services\EventLogger::class));
 }elseif($scenario==='disabled'){
  app(App\Services\Accounts\DisableUser::class)->execute($a);
 }elseif($scenario==='session'){
  app(App\Services\Accounts\DeviceSessions::class)->revoke(User::findOrFail($b),$f['viewer']['session']['session_id']);
 }
});
file_put_contents(__DIR__.'/race-'.$scenario.'.committed',json_encode(['committed'=>true,'at'=>microtime(true)]));
echo json_encode(['scenario'=>$scenario,'committed'=>true]);
