<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'||getenv('TASK_ID')!=='V1015_POST_0017_DEVICE_E2E_FINAL_CLOSURE_20261031')exit(20);
require dirname(__DIR__,3).'/vendor/autoload.php';$app=require dirname(__DIR__,3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();require __DIR__.'/qualify.php';
try {
    qualifyPost0017Task($app);$ids=[(int)($argv[1]??0),(int)($argv[2]??0)];sort($ids);$nonce=$argv[3]??'';
    if($ids[0]<1||$ids[0]===$ids[1]||!preg_match('/^[a-f0-9]{32}$/',$nonce))throw new RuntimeException('Invalid task lock input');
    foreach(App\Models\User::whereIn('id',$ids)->get() as $u)if(!str_starts_with($u->phone,'synthetic-c31-'))throw new RuntimeException('Non task actor');
    $db=Illuminate\Support\Facades\DB::connection();$db->beginTransaction();
    if($db->table('users')->whereIn('id',$ids)->orderBy('id')->lockForUpdate()->get()->count()!==2)throw new RuntimeException('Missing task actors');
    $base=storage_path('app/post0017-control/'.$nonce);$f=fopen($base.'.ready','x');fwrite($f,json_encode(['locked'=>true,'rows'=>2,'isolation'=>$db->selectOne('select @@tx_isolation as level')->level,'connection_id'=>(int)$db->selectOne('select connection_id() as id')->id]));fflush($f);fsync($f);fclose($f);
    $deadline=hrtime(true)+40_000_000_000;
    while(!is_file($base.'.release')){if(hrtime(true)>$deadline)throw new RuntimeException('Bounded lock hold timeout');usleep(100000);clearstatcache(true,$base.'.release');}
    $db->commit();echo json_encode(['released'=>true,'rows_modified'=>0]).PHP_EOL;
}catch(Throwable $e){if(isset($db)&&$db->transactionLevel()>0)$db->rollBack();fwrite(STDERR,get_class($e).': '.$e->getMessage().PHP_EOL);exit(1);}
