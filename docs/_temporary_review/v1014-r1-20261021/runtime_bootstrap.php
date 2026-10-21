<?php
require getcwd().'/vendor/autoload.php';$app=require getcwd().'/bootstrap/app.php';$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
set_exception_handler(function(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);});
$db=Illuminate\Support\Facades\DB::connection();if(!$app->environment('local')||config('database.default')!=='mysql'||$db->getDatabaseName()!=='elitesync_v10_1_4_dev'||$db->getConfig('host')!=='127.0.0.1'||(int)$db->getConfig('port')!==43325||$db->getConfig('url')||$db->getConfig('unix_socket')){fwrite(STDERR,'OWNED_V1014_DB_GUARD_REJECT');exit(31);}if($db->selectOne('SELECT @@tx_isolation AS level')->level!=='REPEATABLE-READ')exit(32);
