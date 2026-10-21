<?php
require __DIR__.'/runtime_bootstrap.php';use Illuminate\Support\Facades\DB;
$f=json_decode(file_get_contents(__DIR__.'/after-fixture.private.json'),true);$admin=(int)$f['admin']['id'];DB::beginTransaction();app(App\Services\JourneyStore::class)->users([$admin],true);
file_put_contents(__DIR__.'/rrfinal.writer-locked.json',json_encode(['connection_id'=>DB::selectOne('SELECT CONNECTION_ID() id')->id,'isolation'=>DB::selectOne('SELECT @@tx_isolation v')->v,'at'=>microtime(true)]));
$limit=microtime(true)+40;while(!file_exists(__DIR__.'/rrfinal.commit-go')){if(microtime(true)>$limit)throw new Exception('barrier timeout');usleep(20000);}
$reader=json_decode(file_get_contents(__DIR__.'/rrfinal.first-read.private.json'),true);app(App\Services\PlatformAccess::class)->revokeAdminSession($admin,$reader['session_id']);DB::commit();file_put_contents(__DIR__.'/rrfinal.writer-commit.json',json_encode(['at'=>microtime(true),'real_service'=>'PlatformAccess::revokeAdminSession']));echo 'named Web session revoked and committed';
