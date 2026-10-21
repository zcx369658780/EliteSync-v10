<?php
require __DIR__.'/runtime_bootstrap.php';
use Illuminate\Support\Facades\DB;
$f=json_decode(file_get_contents(__DIR__.'/fixture-chain01.private.json'),true);
$eid='e9de1a1a-8c90-4fa2-a512-b2483562e237';
$event=DB::table('platform_events')->where('id',$eid)->first();
$reg=DB::table('platform_event_registrations')->where('event_id',$eid)->where('user_id',$f['users']['C']['id'])->first();
if($event->state!=='COMPLETED'||$reg->state!=='CANCELLED_BY_USER')throw new Exception('APP completed withdrawal not durable');
$grant=DB::table('platform_event_grants')->where('id',$reg->grant_id)->first();
if($grant->state!=='REVOKED')throw new Exception('grant not revoked');
$before=json_decode(file_get_contents(__DIR__.'/durability-after.json'),true);
$out=['event_state'=>$event->state,'C_registration_state'=>$reg->state,'C_grant_state'=>$grant->state,'no_new_decision_or_sanction'=>true];
foreach(['safety_case_decisions','safety_case_reviews','admin_sanctions'] as $t){
 $values=DB::table($t)->get()->map(fn($x)=>(array)$x)->all();foreach($values as &$v)ksort($v);unset($v);usort($values,fn($a,$b)=>strcmp(json_encode($a),json_encode($b)));$bytes=json_encode($values,JSON_THROW_ON_ERROR|JSON_UNESCAPED_UNICODE);
 $actual=['rows'=>count($values),'full_value_SHA256'=>hash('sha256',$bytes)];
 if($before[$t]!==$actual)throw new Exception('unexpected sanction/decision mutation '.$t);
 $out['unchanged_tables'][$t]=$actual;
}
$sanctions=DB::table('admin_sanctions')->where('user_id',$f['users']['B']['id'])->orderBy('id')->get(['id','active']);
$out['B_sanction_facts']=$sanctions;
file_put_contents(__DIR__.'/completed-exit-db-verification.json',json_encode($out,JSON_PRETTY_PRINT));echo 'APP withdrawal persisted; COMPLETED retained; decision/review/sanction full values unchanged';
