<?php
declare(strict_types=1);
/** Synthetic capability facts and receipt validation only. No introspection/loader/PDO. */
require_once __DIR__.'/../../../services/backend-laravel/tests/E2E/MainlineEnvironment.php';
require_once __DIR__.'/../../../services/backend-laravel/tests/E2E/PhpRuntimeQualification.php';
$policy=json_decode(file_get_contents(__DIR__.'/php_requirements.json'),true,512,JSON_THROW_ON_ERROR);
$modules=$policy['required_shared_modules'];$manifest=['builtin_modules'=>array_values(array_diff($policy['required_modules'],$modules)),'shared_modules'=>array_fill_keys($modules,'inert'),'windows_system_modules'=>[]];
$facts=['version'=>$policy['php_version'],'int_size'=>8,'zts'=>false,'sapi'=>'cli','ini_loaded'=>false,'ini_scanned'=>false,'auto_prepend'=>'','auto_append'=>'','enable_dl'=>'0','modules'=>$policy['required_modules'],'functions'=>array_fill_keys($policy['functions'],true),'classes'=>array_fill_keys($policy['classes'],true),'pdo_drivers'=>['mysql']];
$count=0;
$ok=static function()use(&$count,$facts,$manifest,$policy){PhpRuntimeQualification::capabilities($facts,$manifest,$policy);$count++;};
$reject=static function(array $bad)use(&$count,$manifest,$policy){$denied=false;try{PhpRuntimeQualification::capabilities($bad,$manifest,$policy);}catch(Throwable){$denied=true;}if(!$denied)throw new RuntimeException('Bad capability facts accepted');$count++;};
$ok();
$x=$facts;$x['modules']=array_values(array_diff($x['modules'],['mbstring']));$reject($x);
$x=$facts;$x['modules'][]='undeclared_extension';$reject($x);
$x=$facts;$x['functions']['mb_substr']=false;$reject($x);
$x=$facts;$x['classes']['DOMDocument']=false;$reject($x);
$x=$facts;$x['pdo_drivers']=[];$reject($x);
$x=$facts;$x['version']='8.4.0';$reject($x);
$x=$facts;$x['zts']=true;$reject($x);
$x=$facts;$x['sapi']='fpm-fcgi';$reject($x);
$x=$facts;$x['ini_loaded']='GLOBAL_INI_NOT_ALLOWED';$reject($x);
$x=$facts;$x['ini_scanned']='GLOBAL_SCAN_NOT_ALLOWED';$reject($x);
$x=$facts;$x['auto_prepend']='GLOBAL_PREPEND_NOT_ALLOWED';$reject($x);
$x=$facts;$x['enable_dl']='1';$reject($x);
$h=str_repeat('1',64);$pid=123;$nonce=str_repeat('a',32);$exe='/INERT/bin/php.exe';$ext='/INERT/bin/ext/php_mbstring.dll';
$nativeManifest=['_absolute_executable'=>$exe,'_absolute_extensions'=>[$ext],'windows_system_modules'=>[]];
$expected=[strtolower($exe)=>$h,strtolower($ext)=>$h];$receipt=['pid'=>$pid,'nonce'=>$nonce,'manifest_sha256'=>$h,'system_directory'=>'/INERT/System32','images'=>[['path'=>$exe,'sha256'=>$h,'source_class'=>'TASK_PRIVATE_BINARY'],['path'=>$ext,'sha256'=>$h,'source_class'=>'TASK_PRIVATE_BINARY']]];
PhpRuntimeQualification::nativeReceipt($receipt,$nativeManifest,$expected,$pid,$nonce,$h);$count++;
foreach(['pid','nonce','manifest_sha256'] as $key){
    $bad=$receipt;$bad[$key]=$key==='pid'?124:'wrong';
    $denied=false;try{PhpRuntimeQualification::nativeReceipt($bad,$nativeManifest,$expected,$pid,$nonce,$h);}catch(Throwable){$denied=true;}
    if(!$denied)throw new RuntimeException('Bad native receipt accepted');$count++;
}
$bad=$receipt;$bad['images'][]=['path'=>'/GLOBAL/php_mbstring.dll','sha256'=>$h];
$denied=false;try{PhpRuntimeQualification::nativeReceipt($bad,$nativeManifest,$expected,$pid,$nonce,$h);}catch(Throwable){$denied=true;}
if(!$denied)throw new RuntimeException('Global image accepted');$count++;
foreach($policy['closed_runtime_task_blobs'] as $task) {
    $denied=false;try{PhpRuntimeQualification::assertTask($task,$policy);}catch(Throwable){$denied=true;}
    if(!$denied)throw new RuntimeException('Old task permitted');$count++;
}
PhpRuntimeQualification::assertTask(str_repeat('4',40),$policy);$count++;
echo json_encode(['classification'=>'SYNTHETIC_CAPABILITY_AND_RECEIPT_INPUTS_ONLY','executed'=>$count,'passed'=>$count,'actual_extension_load'=>false,'native_observer_executed'=>false,'pdo_connection'=>false,'laravel_bootstrap'=>false]);
