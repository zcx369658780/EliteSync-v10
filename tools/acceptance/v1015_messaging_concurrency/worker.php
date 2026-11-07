<?php
/** Real HTTP-kernel worker for a separately authorized, qualified fixture DB. */
declare(strict_types=1);

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\User;

[$script, $mode, $label, $case, $configPath] = $argv;
if (!in_array($mode, ['hold', 'request', 'snapshot'], true)
    || !preg_match('/\A[a-z0-9-]+\z/', $label) || !in_array($case, ['duplicate', 'revocation'], true)) {
    throw new RuntimeException('Unsupported probe operation');
}
$cfg = json_decode(file_get_contents($configPath), true, 32, JSON_THROW_ON_ERROR);
if (!preg_match('/\AV1015_MSG_CONCURRENCY_[0-9]{8}_[0-9]{2}\z/', $cfg['task_id'] ?? '')
    || getenv('TASK_ID') !== $cfg['task_id']) throw new RuntimeException('Task binding required');
require '/app/vendor/autoload.php';
$app = require '/app/bootstrap/app.php';
$app->useEnvironmentPath('/task');
$app->loadEnvironmentFrom('empty.env');
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->bootstrap();
require '/task/qualify.php';
$identity = qualifyV1015MessagingConcurrency($app);
if ($identity['db'] !== $cfg['database']) throw new RuntimeException('Actual fixture DB mismatch');
$dir = $cfg['container_output_dir'].'/'.$case;
if (!is_dir($dir) || is_link($dir)) throw new RuntimeException('New task evidence directory required');
$pdo = DB::connection()->getPdo();
$cid = (int) $pdo->query('SELECT CONNECTION_ID()')->fetchColumn();
$isolation = (string) $pdo->query('SELECT @@session.tx_isolation')->fetchColumn();
if (strtoupper(str_replace('_', '-', $isolation)) !== 'REPEATABLE-READ') throw new RuntimeException('REPEATABLE-READ required; never changed by probe');
function dbUtc(): string { global $pdo; return (string) $pdo->query('SELECT UTC_TIMESTAMP(6)')->fetchColumn(); }
function mark(string $event, array $data = []): void {
    global $dir, $label, $cid;
    $path = $dir.'/'.$label.'.'.$event.'.json';
    if (file_exists($path)) throw new RuntimeException('Preserve prior worker evidence');
    $temporary = $path.'.tmp-'.getmypid();
    $stream = fopen($temporary, 'x');
    if (!$stream) throw new RuntimeException('Preserve prior worker evidence');
    fwrite($stream, json_encode(['connection_id'=>$cid, 'php_monotonic_ns'=>hrtime(true),
        'db_utc'=>dbUtc()] + $data, JSON_THROW_ON_ERROR|JSON_UNESCAPED_SLASHES)."\n");
    fclose($stream);
    if (!rename($temporary,$path)) throw new RuntimeException('Could not publish complete worker evidence');
}
function barrier(): void {
    global $dir;
    $deadline = microtime(true)+40;
    while (!is_file($dir.'/allow-release')) {
        if (is_file($dir.'/cancel') || microtime(true)>$deadline) throw new RuntimeException('Barrier cancelled or expired');
        usleep(20000);
    }
}
function snapshot(): array {
    global $cfg;
    [$a,$b] = $cfg['participants'];
    $rows = DB::table('chat_messages')->where(function ($q) use ($a,$b) {
        $q->where(function ($q) use ($a,$b) {$q->where('sender_id',$a)->where('receiver_id',$b);})
            ->orWhere(function ($q) use ($a,$b) {$q->where('sender_id',$b)->where('receiver_id',$a);});
    })->orderBy('id')->get(['id','content','client_message_id']);
    $ids=[];$hashes=[];$keys=[];
    foreach ($rows as $row) {$ids[]=(int)$row->id;$hashes[(string)$row->id]=hash('sha256',(string)$row->content);$keys[(string)$row->id]=$row->client_message_id;}
    $cn=DB::table('product_connections')->where('user_a',min($a,$b))->where('user_b',max($a,$b))->first();
    return [
        'message_ids'=>$ids,'message_hashes'=>(object)$hashes,'client_message_ids'=>(object)$keys,
        'notification_ids'=>DB::table('notifications')->where('user_id',$b)->where('kind','message')->orderBy('id')->pluck('id')->map(fn($x)=>(int)$x)->all(),
        'message_event_ids'=>DB::table('app_events')->where('event_name','message_sent')->where('actor_user_id',$a)->where('target_user_id',$b)->orderBy('id')->pluck('id')->map(fn($x)=>(int)$x)->all(),
        'attachment_ids'=>DB::table('message_attachments')->whereIn('message_id',$ids)->orderBy('id')->pluck('id')->map(fn($x)=>(int)$x)->all(),
        'cn_state'=>$cn?->state,'mc_states'=>$cn ? DB::table('messaging_consents')->where('connection_id',$cn->id)->orderBy('purpose')->pluck('state')->all() : [],
    ];
}
$requestActive=false;$lockAttempt=false;$lockAcquired=false;
DB::connection()->beforeExecuting(function ($sql) use (&$requestActive,&$lockAttempt) {
    $sql=strtolower($sql);
    if ($requestActive && !$lockAttempt && str_contains($sql,'`users`') && str_contains($sql,'for update')) {
        $lockAttempt=true;mark('lock-attempt',['transaction_level'=>DB::transactionLevel()]);
    }
});
DB::listen(function ($query) use (&$requestActive,&$lockAcquired) {
    $sql=strtolower($query->sql);
    if ($requestActive && !$lockAcquired && str_contains($sql,'`users`') && str_contains($sql,'for update')) {
        $lockAcquired=true;mark('lock-acquired',['transaction_level'=>DB::transactionLevel()]);
    }
});
function http(string $method,string $uri,string $actor,array $body=[]): array {
    global $app,$kernel,$cfg,$requestActive,$lockAcquired,$cid,$isolation;
    if (!in_array($method,['GET','POST'],true) || !preg_match('~\A/api/v1/(messages(?:\?peer_id=[0-9]+)?|connections/[0-9]+/consent)\z~',$uri)) {
        throw new RuntimeException('Only probe message/consent routes allowed');
    }
    $app['auth']->forgetGuards();
    $request=Request::create($uri,$method,[],[],[],['HTTP_ACCEPT'=>'application/json',
        'CONTENT_TYPE'=>'application/json','HTTP_AUTHORIZATION'=>'Bearer '.$cfg['tokens'][$actor]],
        $method==='POST' ? json_encode($body,JSON_THROW_ON_ERROR) : null);
    $requestActive=true;
    $response=$kernel->handle($request);
    $requestActive=false;
    $bytes=$response->getContent();
    $data=json_decode($bytes,true,64,JSON_THROW_ON_ERROR);
    $kernel->terminate($request,$response);
    return ['status'=>$response->getStatusCode(),'id'=>$data['id']??null,
        'client_message_id'=>$data['client_message_id']??null,'idempotent_replay'=>$data['idempotent_replay']??null,
        'private_marker_present'=>str_contains($bytes,$cfg['private_marker']),
        'body_sha256'=>hash('sha256',$bytes),'body_bytes'=>strlen($bytes),
        'kernel_executed'=>true,'transaction_level'=>DB::transactionLevel(),'session_isolation'=>$isolation,
        'connection_id'=>$cid,'user_lock_acquired'=>$lockAcquired];
}
try {
    mark('started',['database'=>$identity['db'],'session_isolation'=>$isolation,'transaction_level'=>DB::transactionLevel()]);
    if ($mode==='snapshot') { $result=snapshot();mark('done',$result);echo json_encode($result,JSON_THROW_ON_ERROR)."\n";exit(0); }
    if ($mode==='hold') {
        DB::beginTransaction();
        User::whereIn('id',$cfg['participants'])->orderBy('id')->lockForUpdate()->get();
        mark('held',['transaction_level'=>DB::transactionLevel()]);barrier();
        if ($case==='revocation') {
            $result=http('POST','/api/v1/connections/'.$cfg['participants'][0].'/consent','b',
                ['action'=>'revoke','expected_revision'=>2]);
            mark('revocation-written',['status'=>$result['status']]);
            if ($result['status']!==200 || DB::transactionLevel()!==1) throw new RuntimeException('Real MC revoke failed');
        } else {$result=['status'=>200,'connection_id'=>$cid,'session_isolation'=>$isolation];}
        DB::commit();$result['committed']=true;$result['transaction_level']=DB::transactionLevel();
        mark('committed',$result);mark('done',$result);echo json_encode($result,JSON_THROW_ON_ERROR)."\n";exit(0);
    }
    $operation=$cfg['operations'][$case][$label];
    $result=http($operation['method'],$operation['uri'],$operation['actor'],$operation['body']??[]);
    if (DB::transactionLevel()!==0) throw new RuntimeException('HTTP request left an open transaction');
    mark('done',$result);echo json_encode($result,JSON_THROW_ON_ERROR)."\n";
} catch (Throwable $error) {
    while (DB::transactionLevel()>0) DB::rollBack();
    mark('exception',['class'=>get_class($error),'message'=>$error->getMessage()]);
    fwrite(STDERR,get_class($error).': '.$error->getMessage()."\n");exit(2);
}
