<?php
require getcwd().'/vendor/autoload.php';$app=require getcwd().'/bootstrap/app.php';$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$db=Illuminate\Support\Facades\DB::connection();
if(!$app->environment('local')||config('database.default')!=='mysql'||$db->getDatabaseName()!=='elitesync_v10_1_2_dev'||$db->getConfig('host')!=='127.0.0.1'||(int)$db->getConfig('port')!==43323||$db->getConfig('url')||$db->getConfig('unix_socket')){fwrite(STDERR,'OWNED_DB_GUARD_REJECT');exit(31);}
