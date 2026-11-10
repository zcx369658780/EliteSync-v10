<?php

namespace App\Services;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/** TEST_ONLY purpose limit, not an Owner-approved real-world retention policy. */
final class SafetyParticipation
{
    public const POLICY='DEV_SAFETY_HISTORY_7D_V1';
    public const CASE_DAYS=30;
    private const PARTICIPATED=['APPLIED','WAITLISTED','CONFIRMED'];

    /** Under the event lock: reconstruct only server-audited participation, never an invitation or client claim. */
    public function history(object $event,object $r): ?array
    {
        $audits=DB::table('platform_event_audits')->where('event_id',$event->id)->orderBy('id')->lockForUpdate()->get();
        $start=null;$end=null;
        foreach($audits as $a){
            $f=json_decode($a->facts,true,512,JSON_THROW_ON_ERROR);
            if(!$start&&$a->action==='apply'&&(int)$a->actor_id===(int)$r->user_id
                &&($f['registration_id']??null)===$r->id&&in_array($f['registration_state']??null,self::PARTICIPATED,true))$start=$a;
            if(!$start||(int)$a->id<=(int)$start->id)continue;
            $ownCancel=$a->action==='cancel'&&(int)$a->actor_id===(int)$r->user_id&&($f['registration_id']??null)===$r->id;
            $scopedRevoke=($a->action==='SOURCE_REVOKED'&&in_array($r->id,$f['affected_registration_ids']??[],true))
                ||($a->action==='revoke'&&($f['revoked_grant_id']??null)===$r->grant_id);
            // Unscoped legacy pair revokes do not end unrelated people's history.
            // A legacy terminal row without a scoped receipt is bounded by its
            // own terminal timestamp; same-timestamp overlap is not presumed.
            if($ownCancel||$scopedRevoke||in_array($a->action,['CANCELLED','EXPIRED','complete'],true)){$end=$a;break;}
        }
        if(!$start)return null;
        $until=Carbon::parse($event->end_at);
        if($end&&Carbon::parse($end->created_at)->lessThan($until))$until=Carbon::parse($end->created_at);
        $unsequencedEnd=!$end&&!in_array($r->state,self::PARTICIPATED,true);
        if($unsequencedEnd&&Carbon::parse($r->updated_at)->lessThan($until))$until=Carbon::parse($r->updated_at);
        return ['apply_audit_id'=>(int)$start->id,'participated_at'=>$start->created_at,
            'end_audit_id'=>$end?(int)$end->id:null,'until'=>$until,'unsequenced_end'=>$unsequencedEnd];
    }

    public function pair(object $event,object $own,object $target): ?array
    {
        if($own->event_id!==$event->id||$target->event_id!==$event->id||(int)$own->user_id===(int)$target->user_id)return null;
        $a=$this->history($event,$own);$b=$this->history($event,$target);if(!$a||!$b)return null;
        if(($a['end_audit_id']&&$b['apply_audit_id']>=$a['end_audit_id'])
            ||($b['end_audit_id']&&$a['apply_audit_id']>=$b['end_audit_id']))return null;
        if(($a['unsequenced_end']&&Carbon::parse($b['participated_at'])->greaterThanOrEqualTo($a['until']))
            ||($b['unsequenced_end']&&Carbon::parse($a['participated_at'])->greaterThanOrEqualTo($b['until'])))return null;
        if(Carbon::parse($a['participated_at'])->greaterThan($b['until'])||Carbon::parse($b['participated_at'])->greaterThan($a['until']))return null;
        $deadline=$a['until']->copy()->addDays(7);
        if(now()->greaterThan($deadline))return null;
        return ['own'=>$a,'target'=>$b,'report_until'=>$deadline->toIso8601String()];
    }

    public function context(object $event,int $actor): ?array
    {
        abort_unless(app(PlatformAccess::class)->available($actor,true),403);
        $rows=DB::table('platform_event_registrations')->where('event_id',$event->id)->orderBy('id')->lockForUpdate()->get();
        $own=$rows->firstWhere('user_id',$actor);if(!$own)return null;$targets=[];$deadline=null;
        foreach($rows as $target){
            $proof=$this->pair($event,$own,$target);if(!$proof)continue;
            $targets[]=['registration_id'=>$target->id,'label'=>'合成参与者 '.substr($target->id,0,6)];$deadline=$proof['report_until'];
        }
        return $targets?['id'=>$event->id,'scope'=>'REPORT_ONLY','policy'=>self::POLICY,'report_until'=>$deadline,'participants'=>$targets]:null;
    }
}
