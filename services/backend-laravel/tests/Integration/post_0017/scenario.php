<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli' || getenv('TASK_ID')!=='V1015_POST_0017_DEVICE_E2E_FINAL_CLOSURE_20261031') exit(20);
require dirname(__DIR__,3).'/vendor/autoload.php';
$app=require dirname(__DIR__,3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
require __DIR__.'/qualify.php';
$identity=qualifyPost0017Task($app);
$db=Illuminate\Support\Facades\DB::connection();
$data=json_decode($argv[2]??'{}',true,512,JSON_THROW_ON_ERROR);
$user=static function(int $id):App\Models\User {
    $u=App\Models\User::findOrFail($id);
    if (!str_starts_with((string)$u->phone,'synthetic-c31-')) throw new RuntimeException('Not this task fictional actor');
    return $u;
};
$out=match($argv[1]??'') {
    'identity'=>$identity+['APP_DB_CONNECTION'=>getenv('APP_DB_CONNECTION'),'DB_CONNECTION'=>getenv('DB_CONNECTION'),'effective'=>config('database.default'),'tables'=>count($db->select('SHOW TABLES'))],
    'friendship'=>(function()use($data,$user,$db){$a=$user((int)$data['a']);$b=$user((int)$data['b']);$db->table('friendships')->insert(['user_a'=>min($a->id,$b->id),'user_b'=>max($a->id,$b->id),'state'=>'ACTIVE','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);return ['fixture'=>'SYNTHETIC_FRIENDSHIP_ONLY'];})(),
    'admin'=>(function()use($data,$user){$u=$user((int)$data['user']);$u->forceFill(['role'=>'admin'])->save();return ['fixture'=>'SYNTHETIC_ADMIN_ROLE_ONLY'];})(),
    'disable'=>(function()use($data,$user){$u=$user((int)$data['user']);$u->forceFill(['disabled'=>true])->save();return ['fixture'=>'SYNTHETIC_DISABLED_ACCOUNT'];})(),
    'expire'=>(function()use($data,$user,$db){$u=$user((int)$data['user']);$db->table('device_sessions')->where('user_id',$u->id)->update(['trusted_login_at'=>now('UTC')->subDays(16)]);return ['fixture'=>'TEST_INJECTION_16_DAYS_OWN_ACTOR_ONLY'];})(),
    'delivery'=>(function()use($data,$user){$u=$user((int)$data['user']);$n=App\Models\AppNotificationItem::where('user_id',$u->id)->where('kind','message')->latest('id')->firstOrFail();return app(App\Services\NotificationDeliveryService::class)->attempt($n,(string)$data['device']);})(),
    'observe'=>(function()use($db){$out=[];foreach(['users','chat_messages','message_attachments','notifications','notification_devices','notification_delivery_attempts','media_assets'] as $t)$out[$t]=$db->table($t)->count();$out['message_notices']=$db->table('notifications')->where('kind','message')->count();$out['raw_token_column']=$db->getSchemaBuilder()->hasColumn('notification_devices','token');$out['token_hashes_valid']=$db->table('notification_devices')->get(['token_hash'])->every(static fn($r)=>preg_match('/^[a-f0-9]{64}$/',$r->token_hash)===1);return $out;})(),
    'snapshot'=>(function()use($db,$identity){$out=[];foreach($db->select('SHOW TABLES') as $row){$t=array_values((array)$row)[0];if(!preg_match('/^[a-z_0-9]+$/',$t))throw new RuntimeException('Unexpected table');$rows=array_map(static fn($r)=>json_encode((array)$r,JSON_THROW_ON_ERROR),$db->table($t)->get()->all());sort($rows,SORT_STRING);$out[$t]=['rows'=>count($rows),'sha256'=>hash('sha256',implode("\n",$rows))];}ksort($out);return ['identity'=>$identity,'tables'=>$out,'aggregate'=>hash('sha256',json_encode($out,JSON_THROW_ON_ERROR))];})(),
    default=>throw new RuntimeException('Unknown bounded action'),
};
echo json_encode($out,JSON_THROW_ON_ERROR|JSON_UNESCAPED_UNICODE).PHP_EOL;
