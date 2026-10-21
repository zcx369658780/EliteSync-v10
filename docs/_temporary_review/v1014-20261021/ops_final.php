<?php
require __DIR__.'/runtime_bootstrap.php';
use Illuminate\Support\Facades\DB;use Illuminate\Support\Str;use App\Models\User;use App\Services\PlatformEventService as Events;use App\Services\Accounts\DeviceSessions;use Laravel\Sanctum\PersonalAccessToken;
function save($p,$d){if(file_exists(__DIR__.'/'.$p))throw new Exception('evidence exists');file_put_contents(__DIR__.'/'.$p,json_encode($d,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE));}
function actor($u){$t=PersonalAccessToken::findToken($u['session']['access_token']);$user=User::findOrFail($u['id'])->withAccessToken($t);request()->setUserResolver(fn()=>$user);return $user;}
$chain=json_decode(file_get_contents(__DIR__.'/fixture-chain01.private.json'),true);$admin=(int)$chain['users']['Admin']['id'];$events=app(Events::class);
function eventAction($id,$action,$d=[]){global $events,$admin;request()->setUserResolver(fn()=>null);return $events->adminAction($admin,$id,['action'=>$action,'revision'=>(int)DB::table('platform_events')->where('id',$id)->value('revision'),'idempotency_key'=>(string)Str::uuid(),'reason'=>'TEST_ONLY explicitly scoped service operation','confirm'=>true]+$d);}
function newEvent($title){global $events,$admin;request()->setUserResolver(fn()=>null);$e=$events->create($admin,['title'=>'TEST_ONLY '.$title,'city'=>'TEST_ONLY city','venue'=>'TEST_ONLY cafe','capacity'=>2,'start_at'=>now()->addDay()->format('Y-m-d H:i:s'),'end_at'=>now()->addDays(2)->format('Y-m-d H:i:s'),'reason'=>'TEST_ONLY independent runtime service fixture','confirm'=>true,'idempotency_key'=>(string)Str::uuid()]);$id=$e['id'];foreach(['REVIEWED','APPROVED_FOR_DEV_SIMULATION'] as $state)eventAction($id,'budget',['budget_revision'=>(int)DB::table('platform_event_budgets')->where('event_id',$id)->value('revision'),'budget_state'=>$state,'venue_cost'=>0,'materials_cost'=>0,'travel_cost'=>0]);eventAction($id,'open');return $id;}
function applyUser($u,$id,$rev=null,$key=null){global $events;actor($u);return $events->action($u['id'],$id,['action'=>'apply','revision'=>$rev??(int)DB::table('platform_events')->where('id',$id)->value('revision'),'idempotency_key'=>$key??(string)Str::uuid()]);}
$mode=$argv[1];
if($mode==='prepare'){
 $out=['users'=>[]];foreach(['eventReader','safetyReader','safetySubject','capA','capB','capC'] as $name){$u=User::create(['name'=>'TEST_ONLY '.$name,'phone'=>'199'.str_pad((string)random_int(10000000,99999999),8,'0',STR_PAD_LEFT),'password'=>bin2hex(random_bytes(16)),'is_synthetic'=>true,'role'=>'user','disabled'=>false,'account_status'=>'active','moderation_status'=>'normal']);$out['users'][$name]=['id'=>$u->id,'session'=>app(DeviceSessions::class)->issue($u,'v1014-concurrency')];}
 $out['event']=newEvent('revoke race');eventAction($out['event'],'invite',['recipient_id'=>$out['users']['eventReader']['id']]);
 $out['safety_event']=newEvent('session race');foreach(['safetyReader','safetySubject'] as $who)eventAction($out['safety_event'],'invite',['recipient_id'=>$out['users'][$who]['id']]);
 foreach(['safetyReader','safetySubject'] as $who)applyUser($out['users'][$who],$out['safety_event']);
 actor($out['users']['safetyReader']);$out['case']=app(App\Services\SafetyCaseService::class)->submit($out['users']['safetyReader']['id'],$out['safety_event'],['target_registration_id'=>DB::table('platform_event_registrations')->where('event_id',$out['safety_event'])->where('user_id',$out['users']['safetySubject']['id'])->value('id'),'category'=>'ATTENDANCE','statement'=>'TEST_ONLY an unverified synthetic statement; no actual physical event','idempotency_key'=>(string)Str::uuid()])['id'];
 $out['cap']=newEvent('capacity race');foreach(['capA','capB','capC'] as $who)eventAction($out['cap'],'invite',['recipient_id'=>$out['users'][$who]['id']]);applyUser($out['users']['capA'],$out['cap']);$out['cap_revision']=(int)DB::table('platform_events')->where('id',$out['cap'])->value('revision');
 save('concurrency-final-fixture.private.json',$out);echo 'new synthetic RR and capacity fixtures prepared through real services';
}
if($mode==='writer'){
 $f=json_decode(file_get_contents(__DIR__.'/concurrency-final-fixture.private.json'),true);$kind=$argv[2];$prefix=$argv[3]??'rr';$who=$kind==='event-revoke'?'eventReader':'safetyReader';$u=$f['users'][$who];request()->setUserResolver(fn()=>null);DB::beginTransaction();
 if($kind==='event-revoke')app(App\Services\CurrentQuestionnaire::class)->lock();
 app(App\Services\JourneyStore::class)->users($kind==='event-revoke'?[$admin,$u['id']]:[$u['id']],true);
 save($prefix.'-'.$kind.'.writer-locked.json',['connection_id'=>DB::selectOne('SELECT CONNECTION_ID() id')->id,'isolation'=>DB::selectOne('SELECT @@tx_isolation v')->v,'locked_at'=>microtime(true),'user_id'=>$u['id']]);
 $limit=microtime(true)+45;while(!file_exists(__DIR__.'/'.$prefix.'-'.$kind.'.commit-go')){if(microtime(true)>$limit)throw new Exception('barrier timeout');usleep(20000);}
 if($kind==='event-revoke')eventAction($f['event'],'revoke',['grant_id'=>DB::table('platform_event_registrations')->where('event_id',$f['event'])->where('user_id',$u['id'])->value('grant_id')]);
 else app(DeviceSessions::class)->revoke(User::findOrFail($u['id']),$u['session']['session_id']);
 DB::commit();save($prefix.'-'.$kind.'.writer-commit.json',['committed_at'=>microtime(true)]);echo 'committed';
}
if($mode==='observe'){
 $env=[];foreach(file(__DIR__.'/db.private.env',FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES) as $line){[$k,$v]=explode('=',$line,2);$env[$k]=$v;}
 $pdo=new PDO('mysql:host=127.0.0.1;port=43325;dbname=elitesync_v10_1_4_dev','root',$env['MARIADB_ROOT_PASSWORD'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
 $rows=$pdo->query("SELECT w.requesting_trx_id,w.blocking_trx_id,r.trx_mysql_thread_id reader_connection,b.trx_mysql_thread_id writer_connection,r.trx_query reader_query,l.lock_table,l.lock_index,l.lock_data,l.lock_mode FROM information_schema.INNODB_LOCK_WAITS w JOIN information_schema.INNODB_TRX r ON r.trx_id=w.requesting_trx_id JOIN information_schema.INNODB_TRX b ON b.trx_id=w.blocking_trx_id JOIN information_schema.INNODB_LOCKS l ON l.lock_id=w.requested_lock_id")->fetchAll(PDO::FETCH_ASSOC);
 echo json_encode(['observed_at'=>microtime(true),'waits'=>$rows]);
}
if($mode==='capacity'){
 $f=json_decode(file_get_contents(__DIR__.'/concurrency-final-fixture.private.json'),true);$who=$argv[2];$u=$f['users'][$who];actor($u);save('capacity-'.$who.'.ready',['connection_id'=>DB::selectOne('SELECT CONNECTION_ID() id')->id,'isolation'=>DB::selectOne('SELECT @@tx_isolation v')->v]);$limit=microtime(true)+40;while(!file_exists(__DIR__.'/capacity-go')){if(microtime(true)>$limit)throw new Exception('barrier timeout');usleep(10000);}
 try{$r=applyUser($u,$f['cap'],$f['cap_revision'],'capacity-'.$who);$code=200;}catch(Symfony\Component\HttpKernel\Exception\HttpException $e){$code=$e->getStatusCode();$r=['error'=>$e->getMessage()];}
 save('capacity-'.$who.'.result.json',['code'=>$code,'result'=>$r,'finished_at'=>microtime(true)]);echo $code;
}
if($mode==='capacity-retry'){$f=json_decode(file_get_contents(__DIR__.'/concurrency-final-fixture.private.json'),true);$who=$argv[2];$r=applyUser($f['users'][$who],$f['cap']);save('capacity-retry.json',$r);echo 'current revision retry '. $r['registration']['state'];}
if($mode==='snapshot'){
 $tables=DB::select('SHOW TABLES');$out=[];$private=[];foreach($tables as $row){$t=array_values((array)$row)[0];if(in_array($t,['sessions','cache','cache_locks'],true))continue;$values=DB::table($t)->get()->map(fn($x)=>(array)$x)->all();foreach($values as &$v)ksort($v);unset($v);usort($values,fn($a,$b)=>strcmp(json_encode($a),json_encode($b)));$bytes=json_encode($values,JSON_THROW_ON_ERROR|JSON_UNESCAPED_UNICODE);$out[$t]=['rows'=>count($values),'full_value_SHA256'=>hash('sha256',$bytes)];$private[$t]=$values;}
 save($argv[2].'.json',$out);save($argv[2].'.private.json',$private);echo json_encode($out);
}
if($mode==='chain-readback'){
 $id='e9de1a1a-8c90-4fa2-a512-b2483562e237';$out=['event'=>DB::table('platform_events')->where('id',$id)->first(),'budget'=>DB::table('platform_event_budgets')->where('event_id',$id)->first(),'registrations'=>DB::table('platform_event_registrations')->where('event_id',$id)->get(),'cases'=>DB::table('safety_cases')->where('event_id',$id)->get()];save($argv[2].'.private.json',$out);echo 'chain readback saved';
}
