<?php

namespace App\Services;

use App\Services\Admin\OperationAudit;
use App\Services\Admin\UserGovernance;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

final class SafetyCaseService
{
    public const RULE_VERSION='DEV_RULES_20261021_1';

    private function sourceHash(object $r): string
    {
        return hash('sha256',json_encode([$r->id,$r->event_id,(int)$r->user_id,$r->state,(int)$r->revision,$r->attendance],JSON_THROW_ON_ERROR));
    }

    public function submit(int $actor,string $eventId,array $d): array
    {
        $candidate=DB::table('platform_event_registrations')->where('id',$d['target_registration_id'])->where('event_id',$eventId)->first(['user_id']);
        abort_unless($candidate,404,'unavailable');
        return app(PlatformEventService::class)->run($actor,$eventId,function($event)use($actor,$d,$candidate){
            $events=app(PlatformEventService::class);
            abort_unless($events->readable($event,$actor),404,'unavailable');
            $own=$events->registration($event,$actor);
            $target=DB::table('platform_event_registrations')->where('id',$d['target_registration_id'])->where('event_id',$event->id)->lockForUpdate()->first();
            abort_unless($own&&in_array($own->state,['APPLIED','WAITLISTED','CONFIRMED'],true)&&$target
                &&(int)$target->user_id===(int)$candidate->user_id&&(int)$target->user_id!==$actor
                &&in_array($target->state,['APPLIED','WAITLISTED','CONFIRMED'],true)
                &&$events->readable($event,(int)$target->user_id)
                &&app(SocialPolicy::class)->pairAllowed($actor,(int)$target->user_id),404,'unavailable');
            $old=DB::table('safety_cases')->where('reporter_id',$actor)->where('idempotency_key',$d['idempotency_key'])->lockForUpdate()->first();
            if($old){
                $report=DB::table('moderation_reports')->where('id',$old->report_id)->lockForUpdate()->first();
                abort_unless($old->event_id===$event->id&&(int)$old->subject_id===(int)$target->user_id
                    &&$old->category===$d['category']&&$report->detail===$d['statement'],409,'report key conflict');
                return $this->ownerShape($old,$actor);
            }
            abort_if(DB::table('safety_cases')->where('reporter_id',$actor)->where('created_at','>',now()->subHour())->count()>=5,429,'report limit');
            $report=DB::table('moderation_reports')->insertGetId(['reporter_id'=>$actor,'target_user_id'=>$target->user_id,
                'category'=>'platform_event','reason_code'=>$d['category'],'detail'=>$d['statement'],'status'=>'new','appeal_status'=>'none',
                'admin_revision'=>0,'created_at'=>now(),'updated_at'=>now()]);
            $id=(string)Str::uuid();
            DB::table('safety_cases')->insert(['id'=>$id,'event_id'=>$event->id,'report_id'=>$report,'reporter_id'=>$actor,
                'subject_id'=>$target->user_id,'reporter_registration_id'=>$own->id,'subject_registration_id'=>$target->id,
                'category'=>$d['category'],'state'=>'OPEN','revision'=>1,'review_due_at'=>now()->addDays(7),
                'idempotency_key'=>$d['idempotency_key'],'created_at'=>now(),'updated_at'=>now()]);
            foreach([$own,$target] as $r)DB::table('safety_case_evidence')->insert(['id'=>(string)Str::uuid(),'case_id'=>$id,
                'source_type'=>'EVENT_REGISTRATION','source_id'=>$r->id,'source_revision'=>$r->revision,
                'source_hash'=>$this->sourceHash($r),'scope'=>'CURRENT_EVENT_PARTICIPANT_FACT_ONLY','created_at'=>now(),'updated_at'=>now()]);
            DB::table('safety_rule_advisories')->insert(['case_id'=>$id,'rule_version'=>self::RULE_VERSION,
                'classification'=>$d['category']==='CONDUCT'?'MANUAL_REVIEW_REQUIRED':'UNVERIFIED_SELF_REPORT',
                'status'=>'ADVISORY_ONLY','uncertainty'=>'参与资格不证明线下行为；陈述、缺席、取消和未回复均非已核实事实。',
                'created_at'=>now(),'updated_at'=>now()]);
            return $this->ownerShape(DB::table('safety_cases')->where('id',$id)->first(),$actor);
        },false,[(int)$candidate->user_id]);
    }

    private function ownerShape(object $case,int $actor): array
    {
        $subject=(int)$case->subject_id===$actor;
        $result=['id'=>$case->id,'state'=>$case->state,'revision'=>(int)$case->revision,
            'role'=>$subject?'subject':'reporter','notice'=>'内部处理状态；举报不等于已核实，规则提示不等于处罚'];
        if($subject&&$case->sanction_id){
            $s=DB::table('admin_sanctions')->where('id',$case->sanction_id)->where('user_id',$actor)->lockForUpdate()->first();
            if($s){$result['sanction_id']=(int)$s->id;$result['sanction_active']=(bool)$s->active;
                $a=DB::table('sanction_appeals')->where('sanction_id',$s->id)->where('user_id',$actor)->lockForUpdate()->first();
                $result['appeal']=$a?['id'=>$a->id,'status'=>$a->status,'revision'=>(int)$a->revision,'outcome'=>$a->review_outcome]:null;}
        }
        return $result;
    }

    public function own(int $actor): array
    {
        DB::transaction(function()use($actor){app(PlatformAccess::class)->users([$actor]);abort_unless(app(PlatformAccess::class)->available($actor,true),403);});
        $ids=DB::table('safety_cases')->where(fn($q)=>$q->where('reporter_id',$actor)->orWhere('subject_id',$actor))
            ->orderByDesc('created_at')->limit(30)->pluck('id');
        $items=[];foreach($ids as $id){try{$items[]=$this->owner($actor,$id);}catch(HttpException $e){if($e->getStatusCode()!==404)throw $e;}}
        return ['items'=>$items,'sanctions'=>app(SanctionAppeals::class)->forOwner($actor),'notice'=>'仅本人最小状态；不会向其他用户公开Safety负面档案'];
    }

    public function owner(int $actor,string $id): array
    {
        app(PlatformAccess::class)->gate();
        $candidate=DB::table('safety_cases')->where('id',$id)->first(['event_id','subject_id','reporter_id']);
        abort_unless($candidate&&in_array($actor,[(int)$candidate->subject_id,(int)$candidate->reporter_id],true),404,'unavailable');
        // The sanctioned subject retains only the private minimum needed to appeal, even after losing activity access.
        if((int)$candidate->subject_id===$actor){
            return DB::transaction(function()use($actor,$id,$candidate){
                app(PlatformAccess::class)->users([$actor]);abort_unless(app(PlatformAccess::class)->available($actor,true),403);
                $c=DB::table('safety_cases')->where('id',$id)->where('subject_id',$actor)->where('event_id',$candidate->event_id)->lockForUpdate()->first();
                abort_unless($c,404);return $this->ownerShape($c,$actor);
            });
        }
        return app(PlatformEventService::class)->run($actor,$candidate->event_id,function($event)use($actor,$id,$candidate){
            abort_unless(app(PlatformEventService::class)->readable($event,$actor)
                &&app(SocialPolicy::class)->pairAllowed($actor,(int)$candidate->subject_id),404,'unavailable');
            $c=DB::table('safety_cases')->where('id',$id)->where('reporter_id',$actor)->where('subject_id',$candidate->subject_id)->where('event_id',$event->id)->lockForUpdate()->first();
            abort_unless($c,404);return $this->ownerShape($c,$actor);
        },false,[(int)$candidate->subject_id]);
    }

    public function runAdmin(int $actor,string $id,callable $work,?string $corroborating=null): mixed
    {
        app(PlatformAccess::class)->gate();
        $candidate=DB::table('safety_cases')->where('id',$id)->first();abort_unless($candidate,404);
        $other=$corroborating?DB::table('safety_cases')->where('id',$corroborating)->first():null;
        if($corroborating)abort_unless($other&&$other->event_id===$candidate->event_id&&(int)$other->subject_id===(int)$candidate->subject_id
            &&(int)$other->reporter_id!==(int)$candidate->reporter_id,422,'independent same-event corroboration required');
        $extra=[(int)$candidate->reporter_id,(int)$candidate->subject_id];if($other)$extra[]=(int)$other->reporter_id;
        return app(PlatformEventService::class)->run($actor,$candidate->event_id,function($event)use($actor,$id,$work,$candidate,$other){
            $c=DB::table('safety_cases')->where('id',$id)->lockForUpdate()->first();
            abort_unless($c&&$c->event_id===$event->id&&(int)$c->reporter_id===(int)$candidate->reporter_id
                &&(int)$c->subject_id===(int)$candidate->subject_id,404);
            $corroboration=$other?DB::table('safety_cases')->where('id',$other->id)->where('event_id',$event->id)
                ->where('subject_id',$c->subject_id)->where('reporter_id',$other->reporter_id)->lockForUpdate()->first():null;
            return $work($event,$c,$corroboration);
        },true,$extra);
    }

    private function evidence(object $event,object $case): array
    {
        $events=app(PlatformEventService::class);
        abort_unless($events->readable($event,(int)$case->reporter_id)
            &&app(PlatformAccess::class)->available((int)$case->subject_id,true)
            &&app(SocialPolicy::class)->pairAllowed((int)$case->reporter_id,(int)$case->subject_id),404,'evidence source unavailable');
        $rows=DB::table('safety_case_evidence')->where('case_id',$case->id)->orderBy('id')->lockForUpdate()->get();
        abort_unless($rows->count()===2,404,'evidence unavailable');$result=[];
        foreach($rows as $row){
            $r=DB::table('platform_event_registrations')->where('id',$row->source_id)->where('event_id',$event->id)->lockForUpdate()->first();
            abort_unless($r&&in_array($r->state,['APPLIED','WAITLISTED','CONFIRMED'],true)
                &&in_array((int)$r->user_id,[(int)$case->reporter_id,(int)$case->subject_id],true)
                &&(int)$r->revision===(int)$row->source_revision&&hash_equals($row->source_hash,$this->sourceHash($r)),404,'source changed; historical grant does not authorize current evidence');
            $result[]=['source_type'=>$row->source_type,'source_id'=>$row->source_id,'source_revision'=>$row->source_revision,
                'hash'=>$row->source_hash,'scope'=>$row->scope,'participation_state'=>$r->state,'attendance'=>'UNVERIFIED'];
        }
        return $result;
    }

    public function adminDetail(int $actor,string $id,string $reason): array
    {
        return $this->runAdmin($actor,$id,function($event,$case)use($actor,$reason){
            $evidence=$this->evidence($event,$case);
            $report=DB::table('moderation_reports')->where('id',$case->report_id)->where('reporter_id',$case->reporter_id)
                ->where('target_user_id',$case->subject_id)->lockForUpdate()->first();abort_unless($report,404);
            OperationAudit::record($actor,'safety.evidence.view','safety_case',$case->id,$reason,(int)$case->revision,[],['source_ids'=>array_column($evidence,'source_id'),'fact_verified'=>false]);
            return ['case'=>(array)$case,'claim'=>$report->detail,'evidence'=>$evidence,
                'advisory'=>DB::table('safety_rule_advisories')->where('case_id',$case->id)->lockForUpdate()->first(),
                'decisions'=>DB::table('safety_case_decisions')->where('case_id',$case->id)->orderBy('created_at')->lockForUpdate()->get()->all(),
                'appeals'=>$case->sanction_id?DB::table('sanction_appeals')->where('sanction_id',$case->sanction_id)->where('user_id',$case->subject_id)->lockForUpdate()->get()->all():[],
                'subject_revision'=>(int)\App\Models\User::whereKey($case->subject_id)->lockForUpdate()->value('admin_revision')];
        });
    }

    public function adminListing(int $actor): array
    {
        return DB::transaction(function()use($actor){
            app(PlatformAccess::class)->users([$actor]);app(PlatformAccess::class)->admin($actor);
            // Minimal work queue has no allegation, reporter, evidence or private account profile.
            return DB::table('safety_cases')->orderBy('review_due_at')->orderBy('id')->limit(30)
                ->get(['id','state','revision','review_due_at','created_at'])->map(fn($x)=>(array)$x)->all();
        });
    }

    public function appealWorkspace(int $actor,string $id,string $reason): array
    {
        return $this->runAdmin($actor,$id,function($event,$case)use($actor,$reason){
            abort_unless($case->sanction_id,404);
            $sanction=DB::table('admin_sanctions')->where('id',$case->sanction_id)->where('user_id',$case->subject_id)
                ->where('report_id',$case->report_id)->lockForUpdate()->first();abort_unless($sanction,404);
            $appeals=DB::table('sanction_appeals')->where('sanction_id',$sanction->id)->where('user_id',$case->subject_id)->lockForUpdate()->get();
            OperationAudit::record($actor,'safety.appeal.view','safety_case',$case->id,$reason,(int)$case->revision,[],['sanction_id'=>$sanction->id,'scope'=>'NAMED_APPEAL_ONLY_NO_ALLEGATION_OR_EVIDENCE']);
            return ['case'=>['id'=>$case->id,'state'=>$case->state,'revision'=>$case->revision,'category'=>'NAMED_SANCTION_APPEAL','review_due_at'=>$case->review_due_at],
                'claim'=>null,'evidence'=>[],'decisions'=>[],'advisory'=>null,'appeals'=>$appeals->all(),'review_only'=>true,
                'subject_revision'=>(int)\App\Models\User::whereKey($case->subject_id)->lockForUpdate()->value('admin_revision')];
        });
    }

    private function notify(object $case,int $to): void
    {
        app(NotificationService::class)->createForUser($to,'safety_case','本人处理状态已更新','请查看本人当前有权状态',
            ['safety_case_id'=>$case->id,'revision'=>$case->revision]);
    }

    public function decide(int $actor,string $id,array $d): void
    {
        $this->runAdmin($actor,$id,function($event,$case,$other)use($actor,$d){
            abort_unless((int)$case->revision===(int)$d['revision'],409,'stale case revision');
            $action=$d['action'];$before=['state'=>$case->state,'revision'=>$case->revision];
            $edges=['triage'=>['OPEN'],'investigate'=>['TRIAGED'],'dismiss'=>['OPEN','TRIAGED','INVESTIGATING'],
                'substantiate'=>['INVESTIGATING'],'restrict'=>['SUBSTANTIATED'],'banned'=>['SUBSTANTIATED'],'close'=>['DISMISSED','ACTIONED'],'due'=>['OPEN','TRIAGED','INVESTIGATING','SUBSTANTIATED','ACTIONED','CLOSED']];
            abort_unless(in_array($case->state,$edges[$action]??[],true),409,'invalid case transition');
            // A current, audited minimum source inspection is necessary; a complaint or rule output alone is never a Finding.
            if(in_array($action,['substantiate','restrict','banned'],true)){
                $this->evidence($event,$case);
                abort_unless(DB::table('admin_operation_audits')->where('actor_user_id',$actor)->where('action','safety.evidence.view')
                    ->where('target_id',$case->id)->where('expected_version',$case->revision)->lockForUpdate()->exists(),409,'view current evidence with a reason first');
            }
            if($action==='substantiate'){
                abort_unless($case->category==='CONDUCT'&&$other&&$other->category==='CONDUCT'
                    &&!in_array($other->state,['DISMISSED','CORRECTED'],true)&&($d['evidence_checked']??false)
                    &&mb_strlen(trim((string)($d['manual_finding']??'')))>=20,422,'independent corroboration and explicit human finding required');
                $this->evidence($event,$other);
                abort_unless(DB::table('admin_operation_audits')->where('actor_user_id',$actor)->where('action','safety.evidence.view')
                    ->where('target_id',$other->id)->where('expected_version',$other->revision)->lockForUpdate()->exists(),409,'inspect corroborating current source first');
            }
            $sanction=$case->sanction_id;
            if(in_array($action,['restrict','banned'],true)){
                $sanction=app(UserGovernance::class)->punish(app(PlatformAccess::class)->admin($actor),(int)$case->subject_id,$action,$d['reason'],(int)$d['user_revision'],(int)$case->report_id);
            }
            $next=match($action){'triage'=>'TRIAGED','investigate'=>'INVESTIGATING','dismiss'=>'DISMISSED','substantiate'=>'SUBSTANTIATED','restrict','banned'=>'ACTIONED','close'=>'CLOSED',default=>$case->state};
            DB::table('safety_case_decisions')->insert(['id'=>(string)Str::uuid(),'case_id'=>$case->id,'reviewer_id'=>$actor,'action'=>strtoupper($action),
                'reason'=>$d['reason'].($action==='substantiate'?' | TEST_ONLY_HUMAN_JUDGMENT: '.$d['manual_finding']:''),
                'expected_revision'=>$case->revision,'corroborating_case_id'=>$other?->id,'rule_version'=>self::RULE_VERSION,
                'rule_class'=>$case->category==='CONDUCT'?'MANUAL_REVIEW_REQUIRED':'UNVERIFIED_SELF_REPORT','rule_status'=>'ADVISORY_ONLY',
                'rule_uncertainty'=>'规则不证明线下事实；取消、缺席、未回复不能单独作为Finding。','created_at'=>now(),'updated_at'=>now()]);
            $update=['state'=>$next,'revision'=>$case->revision+1,'sanction_id'=>$sanction,'updated_at'=>now()];
            if($action==='due')$update['review_due_at']=$d['review_due_at'];
            DB::table('safety_cases')->where('id',$case->id)->update($update);
            DB::table('moderation_reports')->where('id',$case->report_id)->update(['status'=>match($action){'dismiss'=>'dismissed','restrict','banned'=>'action_taken','close'=>'closed',default=>'investigating'},'admin_revision'=>DB::raw('admin_revision+1'),'updated_at'=>now()]);
            OperationAudit::record($actor,'safety.'.$action,'safety_case',$case->id,$d['reason'],(int)$case->revision,$before,['state'=>$next,'revision'=>$case->revision+1,'sanction_id'=>$sanction]);
            $case->state=$next;$case->revision++;
            // No details or finding notices are sent to another participant or public profile.
            $this->notify($case,(int)$case->reporter_id);
            if($sanction)$this->notify($case,(int)$case->subject_id);
        },$d['corroborating_case_id']??null);
    }

    public function review(int $actor,string $id,array $d): void
    {
        $this->runAdmin($actor,$id,function($event,$case)use($actor,$d){
            abort_unless((int)$case->revision===(int)$d['revision']&&$case->sanction_id
                &&in_array($case->state,['ACTIONED','CLOSED'],true),409,'case not reviewable');
            $sanction=DB::table('admin_sanctions')->where('id',$case->sanction_id)->where('report_id',$case->report_id)
                ->where('user_id',$case->subject_id)->lockForUpdate()->first();
            $appeal=DB::table('sanction_appeals')->where('id',$d['appeal_id'])->where('sanction_id',$case->sanction_id)->where('user_id',$case->subject_id)->lockForUpdate()->first();
            abort_unless($sanction&&$sanction->active&&$appeal&&(int)$appeal->revision===(int)$d['appeal_revision'],409,'current named appeal and sanction required');
            $outcome=$d['outcome'];
            abort_unless((int)\App\Models\User::whereKey($case->subject_id)->lockForUpdate()->value('admin_revision')===(int)$d['user_revision'],409,'stale subject revision');
            abort_unless($appeal->status==='submitted'||($appeal->review_outcome==='UPHELD'&&in_array($outcome,['OVERTURNED','CORRECTED'],true)),409,'review already completed');
            if(in_array($outcome,['OVERTURNED','CORRECTED'],true)){
                app(UserGovernance::class)->restore(app(PlatformAccess::class)->admin($actor),(int)$case->subject_id,(int)$sanction->id,$d['reason'],(int)$d['user_revision'],(int)$case->report_id);
            }
            DB::table('safety_case_reviews')->insert(['id'=>(string)Str::uuid(),'case_id'=>$case->id,'appeal_id'=>$appeal->id,
                'sanction_id'=>$sanction->id,'reviewer_id'=>$actor,'outcome'=>$outcome,'reason'=>$d['reason'],
                'expected_revision'=>$case->revision,'created_at'=>now(),'updated_at'=>now()]);
            DB::table('sanction_appeals')->where('id',$appeal->id)->update(['status'=>'reviewed','review_outcome'=>$outcome,
                'revision'=>$appeal->revision+1,'reviewed_at'=>now(),'updated_at'=>now()]);
            $next=$outcome==='UPHELD'?'CLOSED':'CORRECTED';
            DB::table('safety_cases')->where('id',$case->id)->update(['state'=>$next,'revision'=>$case->revision+1,'updated_at'=>now()]);
            OperationAudit::record($actor,'safety.appeal_review','safety_case',$case->id,$d['reason'],(int)$case->revision,
                ['state'=>$case->state,'sanction_id'=>$sanction->id,'appeal_id'=>$appeal->id],['state'=>$next,'outcome'=>$outcome,'only_named_sanction'=>$sanction->id]);
            $case->revision++;$this->notify($case,(int)$case->subject_id);
        });
    }
}
