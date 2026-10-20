<?php
require __DIR__.'/runtime_bootstrap.php';
use App\Models\User;use App\Models\QuestionnaireAnswer;use App\Models\QuestionnaireQuestion;use App\Models\DatingMatch;
use App\Services\SlowDatingService;use App\Services\MatchingRoundService;use App\Services\MatchingRunService;use App\Services\TrustedIdentityService;use App\Services\FormalRelationshipService;
use App\Domain\Matching\RoundState;use App\Domain\Matching\OperationAction;use Illuminate\Support\Facades\DB;
set_exception_handler(function(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);});
$batch='attempt03';$results=[];$j=app(SlowDatingService::class);$rs=app(MatchingRoundService::class);$runs=app(MatchingRunService::class);
function check($value,$label){if(!$value)throw new RuntimeException($label);}
function deny(callable $fn,string $label):void{try{$fn();throw new RuntimeException('expected denial:'.$label);}catch(Symfony\Component\HttpKernel\Exception\HttpException $e){check($e->getStatusCode()===409,$label);}}
function pair(string $label):array{
 $ids=[];foreach(['a','b'] as $x){$u=User::create(['name'=>'V1012 synthetic edge '.$label.$x,'phone'=>'syn-'.bin2hex(random_bytes(7)),'password'=>bin2hex(random_bytes(16)),'is_synthetic'=>true,'verify_status'=>'approved','account_status'=>'active','moderation_status'=>'normal','is_match_eligible'=>true]);app(TrustedIdentityService::class)->register($u->id);
 foreach(QuestionnaireQuestion::where('enabled',true)->get() as $q)QuestionnaireAnswer::create(['user_id'=>$u->id,'questionnaire_question_id'=>$q->id,'answer_payload'=>['value'=>'A','selected_answer'=>['A']],'version'=>1]);
 app(SlowDatingService::class)->participate($u->id,'opt_in',0,'explicit synthetic participation');$ids[]=$u->id;}return $ids;
}
function waiting(array $ids,string $key):object{
 $key=$key.'-attempt03';$rs=app(MatchingRoundService::class);$runs=app(MatchingRunService::class);$r=$rs->prepare('edge-'.$key,'synthetic-'.$key,null,now()->subMinute(),'test',null);
 $run=$runs->request($r,'edge-'.$key,'test',null);$run=$runs->claimNext('edge-worker',120,$run->id);$runs->freezeCandidates($run,User::whereIn('id',$ids)->get(),'edge-worker',$run->fencing_token);
 $runs->finalize($run,'edge-worker',$run->fencing_token,$ids,[['user_a'=>$ids[0],'user_b'=>$ids[1]]]);return $r->fresh();
}
function reveal(object $r):void{app(MatchingRoundService::class)->transition($r,RoundState::Revealed,$r->state_version,'test',null,OperationAction::Reveal);}
$ids=pair('generation');$r=waiting($ids,'generation');check($j->proposal($ids[0])===null,'unrevealed candidate hidden');reveal($r);$p=$j->proposal($ids[0]);
$j->decision($ids[0],$p['id'],'accept',1,'edge-a-accept');$j->participate($ids[0],'pause',1,'pause');$j->participate($ids[0],'opt_in',2,'new generation');
deny(fn()=>$j->decision($ids[1],$p['id'],'accept',2,'edge-b-old-generation'),'peer generation changed');$results['peer_generation_old_accept']='409';
$p=$j->proposal($ids[0]);$j->decision($ids[0],$p['id'],'withdraw',$p['revision'],'withdraw-generation');
$ids2=pair('reveal');$r=waiting($ids2,'reveal');$j->participate($ids2[0],'pause',1,'pause');$j->participate($ids2[0],'opt_in',2,'new generation');deny(fn()=>reveal($r),'frozen generation reveal');check($j->proposal($ids2[0])===null,'no old run proposal');$results['frozen_generation_reveal']='409';
$ids3=pair('one-slot');$r=waiting($ids3,'slot-first');reveal($r);$second=waiting($ids3,'slot-second');deny(fn()=>reveal($second),'single unresolved proposal');check(DB::table('match_proposal_slots')->whereIn('user_id',$ids3)->count()===2,'one slot each');$results['single_unresolved_proposal']='409; two slots total';
$p=$j->proposal($ids3[0]);$expiry=$p['expires_at'];check(Illuminate\Support\Carbon::parse($p['revealed_at'])->diffInHours(Illuminate\Support\Carbon::parse($expiry))===168.0,'168h default');
Illuminate\Support\Carbon::setTestNow(Illuminate\Support\Carbon::parse($expiry)->addSecond());$expired=$j->proposal($ids3[0]);check($expired['state']==='EXPIRED'&&!$expired['showcase'],'expired projection');deny(fn()=>$j->decision($ids3[0],$p['id'],'accept',$p['revision'],'late-accept'),'expired accept');Illuminate\Support\Carbon::setTestNow();check($j->proposal($ids3[0])['state']==='EXPIRED','expiry cannot reopen on clock reset');$results['server_expiry_with_declared_fixture_clock']='EXPIRED persisted; 409; no resurrection';
// A signed one-minute assertion is issued with an explicitly backdated synthetic clock.
$ids4=pair('identity-expiry');$identity=app(TrustedIdentityService::class);Illuminate\Support\Carbon::setTestNow(now()->subSeconds(58));$old=$identity->issue($ids4[0],'edge-expire-a-attempt03',1);Illuminate\Support\Carbon::setTestNow();$identity->issue($ids4[1],'edge-expire-b-attempt03',120);
$s=app(FormalRelationshipService::class);$rel=$s->request($ids4[0],$ids4[1],'edge-expire-request');$rel=$s->action($ids4[0],$rel['id'],'confirm',$rel['revision'],'edge-expire-ca');$rel=$s->action($ids4[1],$rel['id'],'confirm',$rel['revision'],'edge-expire-cb');check($rel['state']==='ACTIVE','active before real clock expiry');
$deadline=microtime(true)+5;while($identity->valid($ids4[0],$old)){check(microtime(true)<$deadline,'wait signed expiry');usleep(50000);}
$identity->issue($ids4[0],'edge-reissued-before-read-attempt03',120);$rel=$s->view($ids4[0],$rel['id']);check($rel['state']==='SUSPENDED_REVERIFY','replacement cannot repair expired binding');$results['expiry_reissue_before_relationship_read']='SUSPENDED_REVERIFY; no automatic reopening';
file_put_contents(__DIR__.'/edges-result.json',json_encode($results,JSON_PRETTY_PRINT));echo json_encode($results,JSON_PRETTY_PRINT);
