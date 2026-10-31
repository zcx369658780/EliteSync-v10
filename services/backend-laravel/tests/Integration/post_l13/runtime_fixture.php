<?php
declare(strict_types=1);
// CLI-only synthetic fixture. This is never a public HTTP endpoint.
if (PHP_SAPI !== 'cli' || getenv('TASK_ID') !== 'V1015_POST_L13_F1_F3_F4_E2E_20261031') { exit(20); }
require dirname(__DIR__, 3).'/vendor/autoload.php';
$app = require dirname(__DIR__, 3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
if (!app()->environment('local') || config('database.default') !== 'mysql'
    || config('database.connections.mysql.database') !== 'postl13_synthetic'
    || (int)config('database.connections.mysql.port') !== 55363) { throw new RuntimeException('Not the task synthetic DB'); }
$db = Illuminate\Support\Facades\DB::connection();
$identity = $db->selectOne('select database() as db, @@port as port');
if ($identity->db !== 'postl13_synthetic' || (int)$identity->port !== 55363) { throw new RuntimeException('Effective DB mismatch'); }
require __DIR__.'/qualify.php';
qualifyPostL13Task($app);
$action = $argv[1] ?? '';
$data = json_decode($argv[2] ?? '{}', true, 512, JSON_THROW_ON_ERROR);
$user = static function (int $id): App\Models\User {
    $u = App\Models\User::findOrFail($id);
    if (!str_starts_with((string)$u->phone, 'synthetic-p31-')) { throw new RuntimeException('Not a task fictional account'); }
    return $u;
};
$out = match ($action) {
    'friendship' => (function () use ($data, $user, $db) {
        $a=$user((int)$data['a']); $b=$user((int)$data['b']);
        $ids=[$a->id,$b->id]; sort($ids);
        $db->table('friendships')->updateOrInsert(['user_a'=>$ids[0],'user_b'=>$ids[1]], ['state'=>'ACTIVE','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
        return ['status'=>'SYNTHETIC_FRIENDSHIP_FIXTURE','actors'=>$ids];
    })(),
    'snapshot' => (function () use ($db) {
        $out=[];
        foreach ($db->select('SHOW TABLES') as $row) {
            $table=array_values((array)$row)[0];
            if (!preg_match('/^[a-z_0-9]+$/',$table)) throw new RuntimeException('Unexpected table');
            $rows=array_map(static fn($r)=>json_encode((array)$r,JSON_THROW_ON_ERROR),$db->table($table)->get()->all());sort($rows,SORT_STRING);
            $out[$table]=['rows'=>count($rows),'sha256'=>hash('sha256',implode("\n",$rows))];
        }
        ksort($out);$id=$db->selectOne('select database() as db, @@port as port, @@server_id as server_id, current_user() as actor');
        return ['tables'=>$out,'identity'=>$id,'all_tables_sha256'=>hash('sha256',json_encode($out,JSON_THROW_ON_ERROR))];
    })(),
    'totals' => (function () use ($db) {
        $out=[];
        foreach (['users','chat_messages','message_attachments','notifications','device_sessions','notification_preferences','notification_devices','notification_delivery_attempts'] as $table) { $out[$table]=$db->table($table)->count(); }
        $out['message_notifications']=$db->table('notifications')->where('kind','message')->count();
        $out['messages']=$db->table('chat_messages')->orderBy('id')->get(['id','sender_id','receiver_id','client_message_id']);
        $out['provider_raw_token_column_present']=$db->getSchemaBuilder()->hasColumn('notification_devices','token');
        $out['provider_token_hashes_valid']=$db->table('notification_devices')->get(['token_hash'])->every(static fn($r)=>preg_match('/^[a-f0-9]{64}$/',$r->token_hash)===1);
        return $out;
    })(),
    'attempt' => (function () use ($data, $user) {
        $u=$user((int)$data['user']);
        $notice=App\Models\AppNotificationItem::where('user_id',$u->id)->where('kind','message')->orderByDesc('id')->firstOrFail();
        return app(App\Services\NotificationDeliveryService::class)->attempt($notice,(string)$data['device']);
    })(),
    'disable' => (function () use ($data,$user) { $u=$user((int)$data['user']);$u->forceFill(['disabled'=>(bool)$data['disabled']])->save();return ['status'=>'SYNTHETIC_ACCOUNT_STATE','disabled'=>$u->disabled]; })(),
    'admin' => (function () use ($data,$user) { $u=$user((int)$data['user']);$u->forceFill(['role'=>'admin'])->save();return ['status'=>'SYNTHETIC_ADMIN_ROLE']; })(),
    'expire' => (function () use ($data,$user,$db) { $u=$user((int)$data['user']);$db->table('device_sessions')->where('user_id',$u->id)->update(['trusted_login_at'=>now('UTC')->subDays(16)]);return ['status'=>'TEST_INJECTION_EXPIRED_T0']; })(),
    'image' => (function () use ($data,$user) {
        $u=$user((int)$data['user']);
        $bytes=base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aZJkAAAAASUVORK5CYII=',true);
        $key='postl13-task/'.$u->id.'/synthetic.png';
        Illuminate\Support\Facades\Storage::disk('v1011_relationship')->put($key,$bytes);
        $asset=App\Models\MediaAsset::create(['owner_user_id'=>$u->id,'media_type'=>'image','storage_provider'=>'local','storage_disk'=>'v1011_relationship','storage_key'=>$key,'original_name'=>'synthetic.png','mime_type'=>'image/png','size_bytes'=>strlen($bytes),'status'=>'ready']);
        return ['id'=>$asset->id,'sha256'=>hash('sha256',$bytes),'fixture'=>'SYNTHETIC_IMAGE_ONLY_NOT_APP_PICKER_UPLOAD'];
    })(),
    default => throw new RuntimeException('Unknown bounded fixture action'),
};
echo json_encode($out, JSON_THROW_ON_ERROR|JSON_UNESCAPED_UNICODE).PHP_EOL;
