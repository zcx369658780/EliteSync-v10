<?php
use Illuminate\Http\Request;use Illuminate\Support\Facades\DB;
define('LARAVEL_START',microtime(true));chdir(getenv('V1014_BACKEND_ROOT') ?: getcwd());require getcwd().'/vendor/autoload.php';$app=require getcwd().'/bootstrap/app.php';$r=Request::capture();$app->instance('request',$r);$kernel=$app->make(Illuminate\Contracts\Http\Kernel::class);$kernel->bootstrap();
$db=DB::connection();if(!$app->environment('local')||config('database.default')!=='mysql'||$db->getDatabaseName()!=='elitesync_v10_1_4_dev'||$db->getConfig('host')!=='127.0.0.1'||(int)$db->getConfig('port')!==43325||$db->getConfig('url')||$db->getConfig('unix_socket')){http_response_code(503);exit('OWNED_DB_GUARD_REJECT');}
$mode=$r->header('X-V1014-Race');if(in_array($mode,['event-revoke','safety-logout'],true)){
DB::listen(function($q)use($mode){$table=$mode==='event-revoke'?'platform_events':'safety_cases';$file=__DIR__.'/rr3-'.$mode.'.first-read';if(str_starts_with(strtolower($q->sql),'select')&&str_contains($q->sql,$table)&&!str_contains(strtolower($q->sql),'for update')&&!file_exists($file))file_put_contents($file,json_encode(['completed_at'=>microtime(true),'query'=>$q->sql,'transaction_level'=>DB::transactionLevel(),'connection_id'=>DB::selectOne('SELECT CONNECTION_ID() id')->id]));});}
$response=$kernel->handle($r);$response->send();$kernel->terminate($r,$response);
