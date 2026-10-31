<?php
require '/workspace/services/backend-laravel/vendor/autoload.php';
$app=require '/workspace/services/backend-laravel/bootstrap/app.php';
$kernel=$app->make(Illuminate\Contracts\Console\Kernel::class);$kernel->bootstrap();
require '/workspace/services/backend-laravel/tests/Integration/final_rtc/qualify.php';
$identity=qualifyFinalRtcTask($app);$db=Illuminate\Support\Facades\DB::connection();
if(PHP_SAPI !== 'cli') throw new RuntimeException('CLI only');
$mode=$argv[1]??'';
if($mode==='empty') { if(count($db->select('SHOW TABLES'))!==0) throw new RuntimeException('Not new empty DB'); echo json_encode(['identity'=>$identity,'tables'=>0,'effective'=>config('database.default'),'APP_DB_CONNECTION'=>getenv('APP_DB_CONNECTION'),'DB_CONNECTION'=>getenv('DB_CONNECTION')]); }
elseif($mode==='migrate') { if(count($db->select('SHOW TABLES'))!==0) throw new RuntimeException('Not new empty DB');$rc=$kernel->call('migrate',['--force'=>true]);echo $kernel->output();if($rc!==0)throw new RuntimeException('Migration failed'); }
elseif($mode==='seed-web') {
 if($db->table('users')->count()!==0)throw new RuntimeException('Seed requires empty actors');
 $c=json_decode(file_get_contents('/runtime-secrets/seed-actors.json'),true,512,JSON_THROW_ON_ERROR);
 $ids=$db->transaction(function()use($c){$ids=[];foreach([['admin_phone','admin'],['user_phone','user']] as [$field,$role]){$u=App\Models\User::factory()->create(['phone'=>$c[$field],'password'=>Illuminate\Support\Facades\Hash::make($c['password']),'role'=>$role,'disabled'=>false,'is_synthetic'=>false]);$ids[]=$u->id;}return $ids;});
 echo json_encode(['identity'=>$identity,'fictional_actor_ids'=>$ids,'users'=>$db->table('users')->count(),'synthetic_seed_transaction'=>1]);
} elseif($mode==='inspect') {echo json_encode(['identity'=>$identity,'tables'=>count($db->select('SHOW TABLES')),'users'=>$db->table('users')->count(),'admins'=>$db->table('users')->where('role','admin')->count()]);} else throw new RuntimeException('Unknown bounded action');
