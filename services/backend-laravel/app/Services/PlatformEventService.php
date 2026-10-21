<?php

namespace App\Services;

use App\Models\User;
use App\Services\Admin\OperationAudit;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

final class PlatformEventService
{
    public const ACTIVE=['INVITED','APPLIED','WAITLISTED','CONFIRMED'];

    /** Outside-transaction discovery is only a locator; every identity is rechecked under ordered user locks. */
    public function run(int $actor,string $id,callable $work,bool $admin=false,array $extra=[]): mixed
    {
        app(PlatformAccess::class)->gate();
        $candidate=DB::table('platform_events')->where('id',$id)->first(['organizer_id']);
        abort_unless($candidate,404,'unavailable');
        $expired=false;
        $result=DB::transaction(function()use($actor,$id,$work,$admin,$extra,$candidate,&$expired){
            if($admin)app(CurrentQuestionnaire::class)->lock();
            app(PlatformAccess::class)->users(array_merge([$actor,(int)$candidate->organizer_id],$extra));
            if($admin)app(PlatformAccess::class)->admin($actor);
            $event=DB::table('platform_events')->where('id',$id)->lockForUpdate()->first();
            abort_unless($event&&(int)$event->organizer_id===(int)$candidate->organizer_id,404,'unavailable');
            if(in_array($event->state,['DRAFT','OPEN','CLOSED'],true)&&Carbon::parse($event->end_at)->isPast()){
                $this->terminate($event,'EXPIRED',null);
                // Commit the clock-driven terminal fact before rejecting a user's
                // private projection; throwing here would roll expiry back.
                if(!$admin){$expired=true;return null;}
            }
            return $work($event);
        });
        abort_if($expired,404,'unavailable');
        return $result;
    }

    public function registration(object $event,int $user): ?object
    {
        return DB::table('platform_event_registrations')->where('event_id',$event->id)->where('user_id',$user)->lockForUpdate()->first();
    }

    public function readable(object $event,int $actor): bool
    {
        $access=app(PlatformAccess::class);
        if(!$access->available($actor)||!$access->available((int)$event->organizer_id)
            ||!in_array($event->state,['OPEN','CLOSED','COMPLETED'],true)
            ||!app(SocialPolicy::class)->pairAllowed($actor,(int)$event->organizer_id))return false;
        $r=$this->registration($event,$actor);
        return $r&&in_array($r->state,self::ACTIVE,true)&&$this->grant($event,$r)!==null;
    }

    private function grant(object $event,object $registration): ?object
    {
        return DB::table('platform_event_grants')->where('id',$registration->grant_id)->where('event_id',$event->id)
            ->where('recipient_id',$registration->user_id)->whereIn('state',['PENDING','CONSUMED'])
            ->where(fn($q)=>$q->where('state','CONSUMED')->orWhere('expires_at','>',now()))->lockForUpdate()->first();
    }

    public function shape(object $event,int $actor,bool $admin=false): array
    {
        $r=$this->registration($event,$actor);
        if(!$admin)abort_unless($this->readable($event,$actor),404,'unavailable');
        $items=DB::table('platform_event_registrations')->where('event_id',$event->id)->whereIn('state',['APPLIED','WAITLISTED','CONFIRMED'])
            ->orderBy('created_at')->orderBy('id')->lockForUpdate()->get();
        $actions=[];
        if(!$admin&&$r){
            if($event->state==='OPEN'&&$r->state==='INVITED')$actions[]='apply';
            if(in_array($event->state,['OPEN','CLOSED'],true)&&in_array($r->state,self::ACTIVE,true))$actions[]='cancel';
            if($r->state==='CONFIRMED'&&in_array($event->state,['OPEN','CLOSED'],true))$actions[]='attendance';
        }
        $result=['id'=>$event->id,'revision'=>(int)$event->revision,'title'=>$event->title,'city'=>$event->city,
            'venue'=>$event->venue,'venue_status'=>'PUBLIC_VENUE_UNVERIFIED','start_at'=>$event->start_at,'end_at'=>$event->end_at,
            'capacity'=>(int)$event->capacity,'confirmed'=>$items->where('state','CONFIRMED')->count(),'state'=>$event->state,
            'marker'=>'DEV_SYNTHETIC_EVENT','booking'=>'NOT_REAL_BOOKING','allowed_actions'=>$actions,
            'registration'=>$r?['id'=>$r->id,'state'=>$r->state,'revision'=>(int)$r->revision,'wait_order'=>$r->wait_order,'attendance'=>$r->attendance]:null,
            'participants'=>$items->map(fn($x)=>['registration_id'=>$x->id,'label'=>'合成参与者 '.substr($x->id,0,6)])->all()];
        if($admin){
            $result['budget']=DB::table('platform_event_budgets')->where('event_id',$event->id)->lockForUpdate()->first();
            $result['registrations']=$items->map(fn($x)=>(array)$x)->all();
            $result['grants']=DB::table('platform_event_grants')->where('event_id',$event->id)->orderBy('created_at')->lockForUpdate()->get(['id','recipient_id','state','expires_at'])->all();
        }
        return $result;
    }

    private function touch(object $event,?int $actor,string $action,array $facts=[]): void
    {
        $event->revision++;
        DB::table('platform_events')->where('id',$event->id)->update(['state'=>$event->state,'revision'=>$event->revision,'updated_at'=>now()]);
        DB::table('platform_event_audits')->insert(['event_id'=>$event->id,'actor_id'=>$actor,'action'=>$action,
            'facts'=>json_encode(['state'=>$event->state,'revision'=>$event->revision]+$facts,JSON_THROW_ON_ERROR),'created_at'=>now(),'updated_at'=>now()]);
    }

    private function terminate(object $event,string $state,?int $actor): void
    {
        $event->state=$state;
        DB::table('platform_event_grants')->where('event_id',$event->id)->whereIn('state',['PENDING','CONSUMED'])->update(['state'=>'REVOKED','updated_at'=>now()]);
        DB::table('platform_event_registrations')->where('event_id',$event->id)->whereIn('state',self::ACTIVE)
            ->update(['state'=>$state==='EXPIRED'?'EXPIRED':'CANCELLED_BY_ORGANIZER','revision'=>DB::raw('revision+1'),'updated_at'=>now()]);
        $this->touch($event,$actor,$state);
    }

    private function command(int $actor,object $event,array $data,callable $work,bool $admin=false): array
    {
        $key=$data['idempotency_key'];$fingerprint=hash('sha256',json_encode([$event->id,$data],JSON_THROW_ON_ERROR));
        $old=DB::table('platform_event_commands')->where('actor_id',$actor)->where('idempotency_key',$key)->lockForUpdate()->first();
        if($old){
            abort_unless($old->fingerprint===$fingerprint&&(int)$old->result_revision===(int)$event->revision,409,'replayed command superseded');
            abort_if(($data['action']??'')==='token',409,'token shown once; issue a new explicitly authorized lifecycle');
            if(($data['action']??'')==='cancel')return ['id'=>$event->id,'revision'=>$event->revision,'state'=>'CANCELLED_BY_USER'];
            return $this->shape($event,$actor,$admin);
        }
        abort_unless((int)$data['revision']===(int)$event->revision,409,'stale event revision');
        $result=$work();
        DB::table('platform_event_commands')->insert(['actor_id'=>$actor,'idempotency_key'=>$key,'fingerprint'=>$fingerprint,
            'event_id'=>$event->id,'result_revision'=>$event->revision,'created_at'=>now(),'updated_at'=>now()]);
        return $result;
    }

    private function notify(object $event,int $to): void
    {
        app(NotificationService::class)->createForUser($to,'platform_event','活动状态已更新','请查看当前有权状态',
            ['platform_event_id'=>$event->id,'revision'=>$event->revision]);
    }

    public function listing(int $actor): array
    {
        DB::transaction(function()use($actor){app(PlatformAccess::class)->users([$actor]);abort_unless(app(PlatformAccess::class)->available($actor,true),403);});
        $ids=DB::table('platform_event_registrations')->where('user_id',$actor)->orderByDesc('created_at')->limit(30)->pluck('event_id');
        $items=[];$tickets=[];
        foreach($ids as $id){try{$items[]=$this->show($actor,$id);}catch(HttpException $e){
            if($e->getStatusCode()!==404)throw $e;
            $ticket=$this->run($actor,$id,function($event)use($actor){
                $a=app(PlatformAccess::class);$r=$this->registration($event,$actor);
                if(!$a->available($actor,true)||$a->available($actor)||!$r||!in_array($r->state,self::ACTIVE,true)
                    ||!in_array($event->state,['OPEN','CLOSED'],true))return null;
                return ['id'=>$event->id,'revision'=>(int)$event->revision,'registration_state'=>$r->state,'allowed_actions'=>['cancel']];
            });
            if($ticket)$tickets[]=$ticket;
        }}
        return ['items'=>$items,'exit_tickets'=>$tickets,'notice'=>'DEV_SYNTHETIC_EVENT / NOT_REAL_BOOKING；无真实费用与出席认定'];
    }

    public function show(int $actor,string $id): array
    {
        return $this->run($actor,$id,fn($e)=>$this->shape($e,$actor));
    }

    public function create(int $actor,array $d): array
    {
        return DB::transaction(function()use($actor,$d){
            app(CurrentQuestionnaire::class)->lock();app(PlatformAccess::class)->users([$actor]);app(PlatformAccess::class)->admin($actor);
            abort_if(DB::table('platform_event_commands')->where('actor_id',$actor)->where('idempotency_key',$d['idempotency_key'])->lockForUpdate()->exists(),409,'create key already used');
            $id=(string)Str::uuid();
            DB::table('platform_events')->insert(['id'=>$id,'organizer_id'=>$actor,'title'=>$d['title'],'city'=>$d['city'],'venue'=>$d['venue'],
                'start_at'=>$d['start_at'],'end_at'=>$d['end_at'],'capacity'=>$d['capacity'],'state'=>'DRAFT','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
            DB::table('platform_event_budgets')->insert(['event_id'=>$id,'currency_code'=>'CNY','venue_cost'=>0,'materials_cost'=>0,'travel_cost'=>0,'total'=>0,'state'=>'DRAFT','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
            DB::table('platform_event_commands')->insert(['actor_id'=>$actor,'idempotency_key'=>$d['idempotency_key'],'fingerprint'=>hash('sha256',json_encode($d)),'event_id'=>$id,'result_revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
            $e=DB::table('platform_events')->where('id',$id)->lockForUpdate()->first();
            OperationAudit::record($actor,'platform_event.create','platform_event',$id,$d['reason'],null,[],['state'=>'DRAFT','marker'=>'DEV_SYNTHETIC_EVENT']);
            return $this->shape($e,$actor,true);
        });
    }

    public function adminListing(int $actor): array
    {
        DB::transaction(function()use($actor){app(PlatformAccess::class)->users([$actor]);app(PlatformAccess::class)->admin($actor);});
        $items=[];
        foreach(DB::table('platform_events')->orderByDesc('created_at')->limit(30)->pluck('id') as $id){
            $items[]=$this->run($actor,$id,fn($e)=>$this->shape($e,$actor,true),true);
        }
        return $items;
    }

    public function adminAction(int $actor,string $id,array $d): array
    {
        $extra=[];
        if(isset($d['recipient_id']))$extra[]=(int)$d['recipient_id'];
        $candidate=null;
        if(isset($d['registration_id'])){
            $candidate=DB::table('platform_event_registrations')->where('id',$d['registration_id'])->where('event_id',$id)->first(['user_id']);
            abort_unless($candidate,404);$extra[]=(int)$candidate->user_id;
        }
        return $this->run($actor,$id,function($event)use($actor,$d,$candidate){
            return $this->command($actor,$event,$d,function()use($actor,$event,$d,$candidate){
                $before=['state'=>$event->state,'revision'=>$event->revision];$action=$d['action'];$token=null;
                $budget=DB::table('platform_event_budgets')->where('event_id',$event->id)->lockForUpdate()->first();
                if($action==='budget')$before['budget']=array_intersect_key((array)$budget,array_flip(['currency_code','venue_cost','materials_cost','travel_cost','total','state','revision']));
                if($action==='budget'){
                    abort_unless($event->state==='DRAFT'&&(int)$budget->revision===(int)$d['budget_revision'],409);
                    $next=$d['budget_state'];$edges=['DRAFT'=>['DRAFT','REVIEWED','VOID'],'REVIEWED'=>['DRAFT','APPROVED_FOR_DEV_SIMULATION','VOID'],'APPROVED_FOR_DEV_SIMULATION'=>['VOID'],'VOID'=>[]];
                    abort_unless(in_array($next,$edges[$budget->state]??[],true),409);
                    $costs=[];foreach(['venue_cost','materials_cost','travel_cost'] as $k)$costs[$k]=(int)$d[$k];
                    if($next!=='DRAFT')foreach($costs as $k=>$v)abort_unless($v===(int)$budget->$k,409,'edit requires DRAFT');
                    DB::table('platform_event_budgets')->where('event_id',$event->id)->update($costs+['total'=>array_sum($costs),'state'=>$next,'revision'=>$budget->revision+1,'updated_at'=>now()]);
                }elseif(in_array($action,['open','close','complete','cancel'],true)){
                    $expected=['open'=>'DRAFT','close'=>'OPEN','complete'=>'CLOSED'];
                    if($action==='cancel')abort_unless(in_array($event->state,['DRAFT','OPEN','CLOSED'],true),409);
                    else abort_unless($event->state===$expected[$action],409);
                    if($action==='open')abort_unless($budget->state==='APPROVED_FOR_DEV_SIMULATION',409,'simulation budget approval required');
                    if($action==='cancel')$this->terminate($event,'CANCELLED',$actor);
                    else $event->state=['open'=>'OPEN','close'=>'CLOSED','complete'=>'COMPLETED'][$action];
                }elseif(in_array($action,['invite','token'],true)){
                    abort_unless($event->state==='OPEN',409);
                    $to=$action==='invite'?(int)$d['recipient_id']:null;
                    if($to){abort_unless($to!==$actor&&app(PlatformAccess::class)->available($to)&&app(SocialPolicy::class)->pairAllowed($actor,$to),404);
                        abort_if($this->registration($event,$to)!==null,409,'one invitation lifecycle per event/user');}
                    $grant=(string)Str::uuid();$token=$action==='token'?bin2hex(random_bytes(32)):null;
                    DB::table('platform_event_grants')->insert(['id'=>$grant,'event_id'=>$event->id,'recipient_id'=>$to,'token_hash'=>$token?hash('sha256',$token):null,'state'=>'PENDING','expires_at'=>now()->addHours(48),'created_at'=>now(),'updated_at'=>now()]);
                    if($to)DB::table('platform_event_registrations')->insert(['id'=>(string)Str::uuid(),'event_id'=>$event->id,'user_id'=>$to,'grant_id'=>$grant,'state'=>'INVITED','revision'=>1,'attendance'=>'UNVERIFIED','created_at'=>now(),'updated_at'=>now()]);
                }elseif($action==='revoke'){
                    $grant=DB::table('platform_event_grants')->where('id',$d['grant_id'])->where('event_id',$event->id)->lockForUpdate()->first();abort_unless($grant&&$grant->state!=='REVOKED',409);
                    DB::table('platform_event_grants')->where('id',$grant->id)->update(['state'=>'REVOKED','updated_at'=>now()]);
                    DB::table('platform_event_registrations')->where('grant_id',$grant->id)->update(['state'=>'CANCELLED_BY_ORGANIZER','revision'=>DB::raw('revision+1'),'updated_at'=>now()]);
                }elseif(in_array($action,['confirm','promote'],true)){
                    abort_unless($event->state==='OPEN',409);
                    $r=DB::table('platform_event_registrations')->where('id',$d['registration_id'])->where('event_id',$event->id)->lockForUpdate()->first();
                    abort_unless($r&&$candidate&&(int)$r->user_id===(int)$candidate->user_id&&app(PlatformAccess::class)->available((int)$r->user_id)
                        &&$this->readable($event,(int)$r->user_id),404);
                    abort_unless($r->state===($action==='promote'?'WAITLISTED':'APPLIED'),409);
                    $reserved=DB::table('platform_event_registrations')->where('event_id',$event->id)->whereIn('state',['APPLIED','CONFIRMED'])->lockForUpdate()->get();
                    if($action==='promote'){
                        abort_if($reserved->count()>=(int)$event->capacity,409,'no capacity');
                        $first=DB::table('platform_event_registrations')->where('event_id',$event->id)->where('state','WAITLISTED')->orderBy('wait_order')->orderBy('id')->lockForUpdate()->first();
                        abort_unless($first&&$first->id===$r->id,409,'oldest waitlisted participant first');
                    }
                    abort_if($reserved->where('state','CONFIRMED')->count()>=(int)$event->capacity,409,'no capacity');
                    DB::table('platform_event_registrations')->where('id',$r->id)->update(['state'=>'CONFIRMED','revision'=>$r->revision+1,'updated_at'=>now()]);
                }else abort(422);
                if($action!=='cancel')$this->touch($event,$actor,$action);
                $after=['state'=>$event->state,'revision'=>$event->revision,'simulation_only'=>true];
                if($action==='budget')$after['budget']=array_intersect_key((array)DB::table('platform_event_budgets')->where('event_id',$event->id)->lockForUpdate()->first(),array_flip(['currency_code','venue_cost','materials_cost','travel_cost','total','state','revision']));
                OperationAudit::record($actor,'platform_event.'.$action,'platform_event',$event->id,$d['reason'],(int)$d['revision'],$before,$after);
                if(isset($to)&&$to)$this->notify($event,$to);
                if(isset($r))$this->notify($event,(int)$r->user_id);
                $result=$this->shape($event,$actor,true);
                if($token)$result['issued_token']=$token;
                return $result;
            },true);
        },true,$extra);
    }

    public function action(int $actor,string $id,array $d): array
    {
        return $this->run($actor,$id,function($event)use($actor,$d){
            $r=$this->registration($event,$actor);abort_unless($r,404);
            $cancel=$d['action']==='cancel';
            if($cancel)abort_unless(app(PlatformAccess::class)->available($actor,true),403);
            else abort_unless($this->readable($event,$actor),404,'unavailable');
            return $this->command($actor,$event,$d,function()use($actor,$event,$d,$r,$cancel){
                if($cancel){
                    abort_unless(in_array($r->state,self::ACTIVE,true)&&in_array($event->state,['OPEN','CLOSED'],true),409);
                    $state='CANCELLED_BY_USER';
                    DB::table('platform_event_grants')->where('id',$r->grant_id)->update(['state'=>'REVOKED','updated_at'=>now()]);
                }elseif($d['action']==='apply'){
                    abort_unless($event->state==='OPEN'&&$r->state==='INVITED',409);
                    $reserved=DB::table('platform_event_registrations')->where('event_id',$event->id)->whereIn('state',['APPLIED','CONFIRMED'])->lockForUpdate()->get();
                    $state=$reserved->count()<(int)$event->capacity?'APPLIED':'WAITLISTED';
                    $grant=$this->grant($event,$r);abort_unless($grant,404);
                    DB::table('platform_event_grants')->where('id',$grant->id)->update(['state'=>'CONSUMED','updated_at'=>now()]);
                }elseif($d['action']==='attendance'){
                    abort_unless($r->state==='CONFIRMED'&&in_array($event->state,['OPEN','CLOSED'],true),409);
                    abort_unless($r->attendance==='UNVERIFIED',409,'already self-reported');
                    DB::table('platform_event_registrations')->where('id',$r->id)->update(['attendance'=>'SELF_REPORTED','revision'=>$r->revision+1,'updated_at'=>now()]);
                    $this->touch($event,$actor,'attendance',['verification'=>'UNVERIFIED']);
                    return $this->shape($event,$actor);
                }else abort(422);
                $order=$state==='WAITLISTED'?((int)DB::table('platform_event_registrations')->where('event_id',$event->id)->max('wait_order')+1):$r->wait_order;
                DB::table('platform_event_registrations')->where('id',$r->id)->update(['state'=>$state,'wait_order'=>$order,'revision'=>$r->revision+1,'updated_at'=>now()]);
                $this->touch($event,$actor,$d['action'],['registration_id'=>$r->id,'registration_state'=>$state]);
                if($cancel)return ['id'=>$event->id,'revision'=>$event->revision,'state'=>$state];
                $this->notify($event,$actor);
                return $this->shape($event,$actor);
            });
        });
    }

    public function redeem(int $actor,string $token,string $key): array
    {
        app(PlatformAccess::class)->gate();
        $candidate=DB::table('platform_event_grants')->where('token_hash',hash('sha256',$token))->first(['id','event_id']);
        abort_unless($candidate,404,'unavailable');
        return $this->run($actor,$candidate->event_id,function($event)use($actor,$candidate,$token,$key){
            abort_unless($event->state==='OPEN'&&app(PlatformAccess::class)->available($actor)
                &&app(PlatformAccess::class)->available((int)$event->organizer_id)
                &&app(SocialPolicy::class)->pairAllowed($actor,(int)$event->organizer_id),404,'unavailable');
            $grant=DB::table('platform_event_grants')->where('id',$candidate->id)->where('event_id',$event->id)->where('token_hash',hash('sha256',$token))->lockForUpdate()->first();
            abort_unless($grant&&$grant->state==='PENDING'&&$grant->recipient_id===null&&$grant->expires_at>now(),404,'unavailable');
            abort_if($this->registration($event,$actor)!==null,409,'already has event lifecycle');
            return $this->command($actor,$event,['action'=>'redeem','revision'=>$event->revision,'idempotency_key'=>$key,'grant_id'=>$grant->id],function()use($event,$actor,$grant){
                DB::table('platform_event_grants')->where('id',$grant->id)->update(['recipient_id'=>$actor,'state'=>'CONSUMED','updated_at'=>now()]);
                DB::table('platform_event_registrations')->insert(['id'=>(string)Str::uuid(),'event_id'=>$event->id,'user_id'=>$actor,'grant_id'=>$grant->id,'state'=>'INVITED','revision'=>1,'attendance'=>'UNVERIFIED','created_at'=>now(),'updated_at'=>now()]);
                $this->touch($event,$actor,'redeem');return $this->shape($event,$actor);
            });
        });
    }

    public function revokePair(int $a,int $b): void
    {
        if(!Schema::hasTable('platform_events'))return;
        $ids=DB::table('platform_event_registrations')->whereIn('user_id',[$a,$b])->pluck('event_id')->unique();
        foreach($ids->sort() as $id){
            $event=DB::table('platform_events')->where('id',$id)->lockForUpdate()->first();
            $shared=DB::table('platform_event_registrations')->where('event_id',$id)->whereIn('user_id',[$a,$b])->lockForUpdate()->get();
            if(!$event||(!in_array((int)$event->organizer_id,[$a,$b],true)&&$shared->pluck('user_id')->unique()->count()!==2))continue;
            DB::table('platform_event_grants')->where('event_id',$id)->whereIn('recipient_id',[$a,$b])->update(['state'=>'REVOKED','updated_at'=>now()]);
            DB::table('platform_event_registrations')->where('event_id',$id)->whereIn('user_id',[$a,$b])->whereIn('state',self::ACTIVE)
                ->update(['state'=>'CANCELLED_BY_ORGANIZER','revision'=>DB::raw('revision+1'),'updated_at'=>now()]);
            $this->touch($event,null,'SOURCE_REVOKED');
        }
    }

    public function revokeUser(int $id): void
    {
        if(!Schema::hasTable('platform_events'))return;
        foreach(DB::table('platform_events')->where('organizer_id',$id)->orderBy('id')->lockForUpdate()->get() as $e){
            if(in_array($e->state,['DRAFT','OPEN','CLOSED'],true))$this->terminate($e,'CANCELLED',null);
        }
        DB::table('platform_event_grants')->where('recipient_id',$id)->update(['state'=>'REVOKED','updated_at'=>now()]);
        DB::table('platform_event_registrations')->where('user_id',$id)->whereIn('state',self::ACTIVE)
            ->update(['state'=>'CANCELLED_BY_ORGANIZER','revision'=>DB::raw('revision+1'),'updated_at'=>now()]);
    }
}
