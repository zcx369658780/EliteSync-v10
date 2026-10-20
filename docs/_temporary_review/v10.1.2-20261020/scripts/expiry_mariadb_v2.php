<?php
require __DIR__.'/runtime_bootstrap.php';
use App\Models\User;use App\Models\QuestionnaireAnswer;use App\Models\QuestionnaireQuestion;use App\Models\DatingMatch;
use App\Services\SlowDatingService;use App\Services\MatchingRoundService;use App\Services\MatchingRunService;use App\Services\TrustedIdentityService;use App\Services\FormalRelationshipService;
use App\Domain\Matching\RoundState;use App\Domain\Matching\OperationAction;use Illuminate\Support\Facades\DB;
set_exception_handler(function(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);});
$batch='expiry05';$results=[];$j=app(SlowDatingService::class);$rs=app(MatchingRoundService::class);$runs=app(MatchingRunService::class);
function check($value,$label){if(!$value)throw new RuntimeException($label);}
function deny(callable $fn,string $label):void{try{$fn();throw new RuntimeException('expected denial:'.$label);}catch(Symfony\Component\HttpKernel\Exception\HttpException $e){check($e->getStatusCode()===409,$label);}}
function pair(string $label):array{
 $ids=[];foreach(['a','b'] as $x){$u=User::create(['name'=>'V1012 synthetic edge '.$label.$x,'phone'=>'syn-'.bin2hex(random_bytes(7)),'password'=>bin2hex(random_bytes(16)),'is_synthetic'=>true,'verify_status'=>'approved','account_status'=>'active','moderation_status'=>'normal','is_match_eligible'=>true]);app(TrustedIdentityService::class)->register($u->id);
 foreach(QuestionnaireQuestion::where('enabled',true)->get() as $q)QuestionnaireAnswer::create(['user_id'=>$u->id,'questionnaire_question_id'=>$q->id,'answer_payload'=>['value'=>'A','selected_answer'=>['A']],'version'=>1]);
 app(SlowDatingService::class)->participate($u->id,'opt_in',0,'explicit synthetic participation');$ids[]=$u->id;}return $ids;
}
function waiting(array $ids,string $key):object{
 $key=$key.'-expiry05';$rs=app(MatchingRoundService::class);$runs=app(MatchingRunService::class);$r=$rs->prepare('edge-'.$key,'synthetic-'.$key,null,now()->subMinute(),'test',null);
 $run=$runs->request($r,'edge-'.$key,'test',null);$run=$runs->claimNext('edge-worker',120,$run->id);$runs->freezeCandidates($run,User::whereIn('id',$ids)->get(),'edge-worker',$run->fencing_token);
 $runs->finalize($run,'edge-worker',$run->fencing_token,$ids,[['user_a'=>$ids[0],'user_b'=>$ids[1]]]);return $r->fresh();
}
function reveal(object $r):void{app(MatchingRoundService::class)->transition($r,RoundState::Revealed,$r->state_version,'test',null,OperationAction::Reveal);}

$c=app(App\Services\LiveConsentService::class);
function mutual(array $ids,string $key):array { $r=waiting($ids,$key);reveal($r);$j=app(SlowDatingService::class);$p=$j->proposal($ids[0]);$j->decision($ids[0],$p['id'],'accept',$p['revision'],$key.'-a');$p=$j->proposal($ids[1]);return $j->decision($ids[1],$p['id'],'accept',$p['revision'],$key.'-b'); }
function denied404(callable $fn,string $label):void { try{$fn();throw new RuntimeException('expected 404:'.$label);}catch(Symfony\Component\HttpKernel\Exception\HttpException $e){check($e->getStatusCode()===404,$label.':'.$e->getStatusCode());} }
$without=pair('expiry-without');$p=mutual($without,'expiry-without');
$existing=pair('expiry-existing');$p2=mutual($existing,'expiry-existing');
$cn=$c->transition($existing[0],$existing[1],'connection','request',0);$cn=$c->transition($existing[1],$existing[0],'connection','accept',$cn['connection']['revision']);
$cn=$c->transition($existing[0],$existing[1],'consent','request',0);$cn=$c->transition($existing[1],$existing[0],'consent','accept',$cn['consent']['revision']);check($cn['gates']['live_send_allowed'],'active explicit CN MC');
$level=DB::selectOne('SELECT @@tx_isolation AS isolation_level')->isolation_level;
Illuminate\Support\Carbon::setTestNow(now()->utc()->addHours(169));
check($c->match(...$without)===null,'expired no match');
denied404(fn()=>$c->transition($without[0],$without[1],'connection','request',0),'expired no-CN create');
check(DB::table('product_connections')->where('user_a',min($without))->where('user_b',max($without))->count()===0,'no unauthorized CN');
$expired=$j->proposal($without[0]);check(!$expired['showcase']&&!$expired['connection_eligible'],'expired projection hidden');
check($c->gates(...$existing)['live_send_allowed'],'existing MC continues after expiry');
$closed=$c->transition($existing[0],$existing[1],'connection','close',$cn['connection']['revision'],$cn['connection']['id']);
denied404(fn()=>$c->transition($existing[0],$existing[1],'connection','request',$closed['connection']['revision'],$closed['connection']['id']),'expired terminal CN new generation');
check(DB::table('product_connections')->where('user_a',min($existing))->where('user_b',max($existing))->count()===1,'no unauthorized lifecycle');
check(DB::table('social_requests')->whereIn('pair_key',[min($without).':'.max($without),min($existing).':'.max($existing)])->count()===0,'no social context');
Illuminate\Support\Carbon::setTestNow();
$out=['isolation'=>$level,'clock'=>'process-local explicit synthetic +169h','entry'=>'actual SlowDatingService/MatchingRoundService/LiveConsentService','without_CN'=>'404; no insert; no private showcase','existing_CN_MC'=>'live_send_allowed true after Match expiry','closed_CN'=>'404 new lifecycle; same single CN','result'=>'PASS'];
file_put_contents(__DIR__.'/expiry-mariadb-result.json',json_encode($out,JSON_PRETTY_PRINT));echo json_encode($out,JSON_PRETTY_PRINT);
