<?php
require __DIR__.'/runtime_bootstrap.php';
use App\Models\User;use App\Models\QuestionnaireAnswer;use App\Models\QuestionnaireQuestion;use App\Models\DatingMatch;
use App\Services\SlowDatingService;use App\Services\MatchingRoundService;use App\Services\MatchingRunService;use App\Services\TrustedIdentityService;use App\Services\FormalRelationshipService;
use App\Domain\Matching\RoundState;use App\Domain\Matching\OperationAction;use Illuminate\Support\Facades\DB;
set_exception_handler(function(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);});
$batch='attempt02';$results=[];$j=app(SlowDatingService::class);$rs=app(MatchingRoundService::class);$runs=app(MatchingRunService::class);
function check($value,$label){if(!$value)throw new RuntimeException($label);}
function deny(callable $fn,string $label):void{try{$fn();throw new RuntimeException('expected denial:'.$label);}catch(Symfony\Component\HttpKernel\Exception\HttpException $e){check(in_array($e->getStatusCode(),[403,409]),$label);}}
function pair(string $label):array{
 $ids=[];foreach(['a','b'] as $x){$u=User::create(['name'=>'V1012 synthetic edge '.$label.$x,'phone'=>'syn-'.bin2hex(random_bytes(7)),'password'=>bin2hex(random_bytes(16)),'is_synthetic'=>true,'verify_status'=>'approved','account_status'=>'active','moderation_status'=>'normal','is_match_eligible'=>true]);app(TrustedIdentityService::class)->register($u->id);
 foreach(QuestionnaireQuestion::where('enabled',true)->get() as $q)QuestionnaireAnswer::create(['user_id'=>$u->id,'questionnaire_question_id'=>$q->id,'answer_payload'=>['value'=>'A','selected_answer'=>['A']],'version'=>1]);
 app(SlowDatingService::class)->participate($u->id,'opt_in',0,'explicit synthetic participation');$ids[]=$u->id;}return $ids;
}
function waiting(array $ids,string $key):object{
 $key=$key.'-attempt02';$rs=app(MatchingRoundService::class);$runs=app(MatchingRunService::class);$r=$rs->prepare('edge-'.$key,'synthetic-'.$key,null,now()->subMinute(),'test',null);
 $run=$runs->request($r,'edge-'.$key,'test',null);$run=$runs->claimNext('edge-worker',120,$run->id);$runs->freezeCandidates($run,User::whereIn('id',$ids)->get(),'edge-worker',$run->fencing_token);
 $runs->finalize($run,'edge-worker',$run->fencing_token,$ids,[['user_a'=>$ids[0],'user_b'=>$ids[1]]]);return $r->fresh();
}
function reveal(object $r):void{app(MatchingRoundService::class)->transition($r,RoundState::Revealed,$r->state_version,'test',null,OperationAction::Reveal);}

$ids=pair('concurrent-accept');$r=waiting($ids,'concurrent-accept');reveal($r);$p=$j->proposal($ids[0]);
file_put_contents(__DIR__.'/race-proposal.private.json',json_encode(['scenario'=>'proposal','owner'=>['id'=>$ids[0]],'viewer'=>['id'=>$ids[1]],'third'=>['id'=>$ids[1]],'proposal'=>$p]));echo json_encode(['ready'=>true,'proposal_revision'=>$p['revision']]);
