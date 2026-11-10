<?php
require __DIR__.'/../../../services/backend-laravel/vendor/autoload.php';
$app=require __DIR__.'/../../../services/backend-laravel/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
set_exception_handler(function (Throwable $e) { fwrite(STDERR,get_class($e).PHP_EOL);exit(1); });
$db=Illuminate\Support\Facades\DB::connection();
if (!app()->environment('local') || $db->getDatabaseName()!=='elitesync_v1009_dev' || (int)$db->getConfig('port')!==43319 || $db->getConfig('host')!=='127.0.0.1') throw new RuntimeException('Exact V1009 database required');
$tables=['users'=>['id','disabled','moderation_status','verify_status'], 'rtc_sessions'=>['id','call_key','room_key','initiator_user_id','peer_user_id','mode','status','accepted_at','ended_at','failure_code'],
 'rtc_session_events'=>['id','rtc_session_id','event_name','payload','created_at'], 'product_connections'=>['id','match_id','user_a','user_b','state','revision'],
 'messaging_consents'=>['id','connection_id','purpose','generation','state','revision','connection_revision'],
 'media_assets'=>['id','owner_user_id','media_type','storage_disk','status','sha256','duration_ms','metadata'],
 'message_attachments'=>['id','message_id','media_asset_id'],
 'admin_sanctions'=>['id','user_id','kind','active','created_at','restored_at'],
 'sanction_appeals'=>['id','user_id','sanction_id','status','created_at'],
 'admin_operation_audits'=>['id','actor_user_id','action','target_type','target_id','created_at']];
$out=['database'=>'elitesync_v1009_dev','port'=>43319,'time'=>now()->toISOString()];
foreach($tables as $table=>$columns) {
 if (!Illuminate\Support\Facades\Schema::hasTable($table)) continue;
 $columns=array_values(array_filter($columns,fn($c)=>Illuminate\Support\Facades\Schema::hasColumn($table,$c)));
 $out[$table]=$db->table($table)->orderBy('id')->get($columns);
}
$out['credential_counts']=['tokens'=>$db->table('personal_access_tokens')->count(),'sessions'=>$db->table('sessions')->count()];
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE).PHP_EOL;
