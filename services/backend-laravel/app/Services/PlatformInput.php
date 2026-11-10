<?php

namespace App\Services;

use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

final class PlatformInput
{
    public function validate(Request $r,array $rules,bool $web=false): array
    {
        $keys=array_keys($r->all());
        abort_if(array_diff($keys,array_merge(array_keys($rules),$web?['_token']:[]))!==[],422,'unsupported field');
        return $r->validate($rules);
    }

    public function key(): array {return ['idempotency_key'=>'required|string|max:80'];}
    public function admin(): array {return ['reason'=>'required|string|min:5|max:500','confirm'=>'required|accepted'];}

    public function create(Request $r): array
    {
        $d=$this->validate($r,$this->key()+$this->admin()+['title'=>'required|string|max:100','city'=>'required|string|max:40',
            'venue'=>'required|string|max:100','capacity'=>'required|integer|min:2|max:8',
            'start_at'=>'required|date|after:now','end_at'=>'required|date|after:start_at|before:+90 days'],true);
        foreach(['title','city','venue'] as $f){
            abort_unless(str_starts_with($d[$f],'TEST_ONLY '),422,'synthetic prefix TEST_ONLY required');
            abort_if(preg_match('/https?:|www\.|@|\d{3,}|微信|电话|身份证|[路街巷弄号樓楼室住宅]|坐标|经纬/iu',$d[$f]),422,'contact and precise location unsupported');
        }
        foreach(['start_at','end_at'] as $f)$d[$f]=Carbon::parse($d[$f])->utc()->format('Y-m-d H:i:s');
        return $d;
    }

    public function eventAdmin(Request $r): array
    {
        return $this->validate($r,$this->key()+$this->admin()+['revision'=>'required|integer|min:1',
            'action'=>'required|in:budget,open,close,complete,cancel,invite,token,revoke,confirm,promote',
            'recipient_id'=>'required_if:action,invite|integer|min:1','grant_id'=>'required_if:action,revoke|uuid',
            'registration_id'=>'required_if:action,confirm,promote|uuid','budget_revision'=>'required_if:action,budget|integer|min:1',
            'budget_state'=>'required_if:action,budget|in:DRAFT,REVIEWED,APPROVED_FOR_DEV_SIMULATION,VOID',
            'venue_cost'=>'required_if:action,budget|integer|min:0|max:1000000',
            'materials_cost'=>'required_if:action,budget|integer|min:0|max:1000000',
            'travel_cost'=>'required_if:action,budget|integer|min:0|max:1000000'],true);
    }
}
