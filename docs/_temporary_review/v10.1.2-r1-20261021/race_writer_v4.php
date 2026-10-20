<?php
require __DIR__.'/runtime_bootstrap.php';use Illuminate\Support\Facades\DB;use App\Models\User;
set_exception_handler(function(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);});
$mode=$argv[1];$f=json_decode(file_get_contents(__DIR__.'/fixture-race04.private.json'),true);$a=$f['users']['A']['id'];$peer=$f['users'][$mode==='contact'?'C':'B']['id'];
DB::transaction(function()use($mode,$a,$peer){
 if($mode==='exit')app(App\Services\CurrentQuestionnaire::class)->lock();
 User::whereIn('id',[$peer])->orderBy('id')->lockForUpdate()->get();
 $id=DB::selectOne('SELECT CONNECTION_ID() id')->id;$iso=DB::selectOne('SELECT @@tx_isolation level')->level;
 file_put_contents(__DIR__.'/race4-'.$mode.'.held',json_encode(['writer_connection_id'=>$id,'isolation'=>$iso,'held_at'=>microtime(true)]));
 $deadline=microtime(true)+45;while(!file_exists(__DIR__.'/race4-'.$mode.'.release')){if(microtime(true)>$deadline)throw new RuntimeException('release timeout');usleep(20000);}
 if($mode==='contact'){$r=Illuminate\Http\Request::create('/api/v1/social/preferences','POST',['requests_enabled'=>false]);$r->setUserResolver(fn()=>User::findOrFail($peer));app(App\Http\Controllers\Api\V1\SocialController::class)->preferences($r);}
 else{app(App\Services\SlowDatingService::class)->participate($peer,'exit',1,'explicit R1 lock-wait exit');}
});file_put_contents(__DIR__.'/race4-'.$mode.'.committed',json_encode(['committed'=>true,'after_commit_at'=>microtime(true)]));echo 'product revocation committed';
