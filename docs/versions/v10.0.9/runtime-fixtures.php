<?php
/** Explicit fictional released-Match fixtures for RTC, not matching-consumer evidence. */
require __DIR__.'/../../../services/backend-laravel/vendor/autoload.php';
$app=require __DIR__.'/../../../services/backend-laravel/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
set_exception_handler(function (Throwable $e) { fwrite(STDERR, get_class($e).': '.$e->getMessage().PHP_EOL); exit(1); });
$db=Illuminate\Support\Facades\DB::connection();
if (!app()->environment('local') || $db->getDatabaseName()!=='elitesync_v1009_dev' || (int)$db->getConfig('port')!==43319 || $db->getConfig('host')!=='127.0.0.1') throw new RuntimeException('Exact V1009 database required');
$data=json_decode(file_get_contents(env('V1009_CREDENTIALS_FILE')),true,flags:JSON_THROW_ON_ERROR);
$users=[];foreach($data['accounts'] as $name=>$account) $users[$name]=App\Models\User::where('phone',$account['phone'])->firstOrFail();
$rows=[];
foreach(['bob','pending'] as $peer) {
 $m=App\Models\DatingMatch::firstOrCreate(['week_tag'=>'v1009-rtc','user_a'=>$users['alice']->id,'user_b'=>$users[$peer]->id],['drop_released'=>true]);
 $rows[]=['match_id'=>$m->id,'a'=>$users['alice']->id,'b'=>$users[$peer]->id,'source'=>'explicit_rtc_fixture_not_consumer'];
}
echo json_encode(['users'=>array_map(fn($u)=>$u->id,$users),'matches'=>$rows],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES).PHP_EOL;
