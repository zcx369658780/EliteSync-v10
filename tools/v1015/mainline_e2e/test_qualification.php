<?php
declare(strict_types=1);
/** Pure qualification tests: no PDO construction, Laravel bootstrap, HTTP or subprocess. */
require_once __DIR__.'/../../../services/backend-laravel/tests/E2E/MainlineEnvironment.php';
function config($key){return $key==='restoration.enabled';}
function app($key=null){if($key==='v1015.mainline-e2e.instance-qualified')return $GLOBALS['e2e_fake_qualifier'];return new class{function environment($env){return is_array($env)?in_array('testing',$env,true):$env==='testing';}function bound($key){return $key==='v1015.mainline-e2e.instance-qualified';}};}
$base=getenv('ELITESYNC_SELFTEST_ROOT');
if(!$base || !is_dir($base))throw new RuntimeException('Task-owned temp required');
$root=$base.'/v1015-mainline-live-pure-20261029';
if(file_exists($root))throw new RuntimeException('Existing fixture; reconcile first');
mkdir($root);mkdir($root.'/source');mkdir($root.'/data');
file_put_contents($root.'/source/inert.txt','INERT-SYNTHETIC');
$binding=['commit'=>str_repeat('1',40),'apps_tree'=>str_repeat('2',40),'services_tree'=>str_repeat('3',40)];
$c=['api'=>'http://127.0.0.1:43359/api/v1','database'=>MainlineEnvironment::DB,'db_port'=>43349,'task_root'=>$root,'source_root'=>$root.'/source','datadir'=>$root.'/data','server_id'=>101529,'db_username'=>'v1015_e2e','fixture_password'=>'INERT_SYNTHETIC_PASSWORD','source_files'=>['inert.txt'=>hash('sha256','INERT-SYNTHETIC')],'source_binding'=>$binding];
$g=['owner_authorized'=>true,'task_blob'=>str_repeat('4',40),'action'=>'mainline_api_db_e2e','new_instance_qualified'=>true,'not_before'=>gmdate('c',time()-60),'expires_at'=>gmdate('c',time()+60),'config_sha256'=>hash('sha256',MainlineEnvironment::canonical($c)),'source_binding'=>$binding];
$ctx=['config'=>$c,'grant'=>$g];$count=0;
$reject=function(array $x)use(&$count){$denied=false;try{MainlineEnvironment::assertContext($x);}catch(Throwable){$denied=true;}if(!$denied)throw new RuntimeException('Negative input was accepted');$count++;};
try{
    MainlineEnvironment::assertContext($ctx);$count++;
    $x=$ctx;$x['grant']['owner_authorized']=false;$reject($x);
    $x=$ctx;$x['grant']['task_blob']=MainlineEnvironment::CURRENT_TASK;$reject($x);
    $x=$ctx;$x['grant']['expires_at']=gmdate('c',time()-1);$reject($x);
    $x=$ctx;$x['config']['db_port']=43329;$reject($x);
    $x=$ctx;$x['config']['database']='existing_database';$reject($x);
    $x=$ctx;$x['grant']['source_binding']['commit']=str_repeat('5',40);$reject($x);
    $x=$ctx;$x['config']['source_files']=[];$x['grant']['config_sha256']=hash('sha256',MainlineEnvironment::canonical($x['config']));$reject($x);
    $x=$ctx;$x['config']['source_files']['inert.txt']=str_repeat('0',64);$x['grant']['config_sha256']=hash('sha256',MainlineEnvironment::canonical($x['config']));$reject($x);
    $x=$ctx;$x['config']['source_files']=['../outside'=>str_repeat('0',64)];$x['grant']['config_sha256']=hash('sha256',MainlineEnvironment::canonical($x['config']));$reject($x);
    require_once __DIR__.'/../../../services/backend-laravel/app/Services/LiveConsentService.php';
    $GLOBALS['e2e_fake_qualifier']=static fn()=>false;
    $gate=new App\Services\LiveConsentService();
    if($gate->enabled()!==false)throw new RuntimeException('False qualifier accepted');$count++;
    $GLOBALS['e2e_fake_qualifier']=static fn()=>1;
    if($gate->enabled()!==false)throw new RuntimeException('Truthy non-boolean accepted');$count++;
    $GLOBALS['e2e_fake_qualifier']=static fn()=>true;
    if($gate->enabled()!==true)throw new RuntimeException('Qualified test branch unavailable');$count++;
    $GLOBALS['e2e_fake_qualifier']=static function(){throw new RuntimeException('synthetic qualifier failure');};
    $denied=false;try{$gate->enabled();}catch(RuntimeException){$denied=true;}
    if(!$denied)throw new RuntimeException('Failed qualifier fell back');$count++;
    echo json_encode(['classification'=>'PURE_QUALIFICATION_ONLY','executed'=>$count,'passed'=>$count,'pdoConstructed'=>false,'laravelBootstrapped'=>false,'network'=>false]);
}finally{unlink($root.'/source/inert.txt');rmdir($root.'/source');rmdir($root.'/data');rmdir($root);}
