<?php
require getcwd().'/vendor/autoload.php';
putenv('DB_CONNECTION=sqlite');putenv('APP_DB_CONNECTION=mysql');putenv('APP_ENV=local');
$test=new class('probe') extends Tests\TestCase { public function probe():void{} };
try{$test->createApplication();fwrite(STDERR,'GUARD_DID_NOT_REJECT');exit(1);}
catch(RuntimeException $e){if(!str_contains($e->getMessage(),'Tests require effective testing / sqlite / :memory:')){fwrite(STDERR,get_class($e));exit(2);}echo 'APP_DB_CONNECTION mysql over DB_CONNECTION sqlite: rejected before RefreshDatabase / migrations';}
