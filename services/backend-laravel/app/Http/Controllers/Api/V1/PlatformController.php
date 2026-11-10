<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\PlatformEventService;
use App\Services\PlatformInput;
use App\Services\SafetyCaseService;
use Illuminate\Http\Request;

final class PlatformController extends Controller
{
    public function index(Request $r,PlatformEventService $s){return response()->json($s->listing((int)$r->user()->id));}
    public function show(Request $r,string $id,PlatformEventService $s){return response()->json($s->show((int)$r->user()->id,$id));}
    public function redeem(Request $r,PlatformEventService $s,PlatformInput $input){
        $d=$input->validate($r,$input->key()+['token'=>'required|string|size:64|regex:/^[a-f0-9]+$/']);
        return response()->json($s->redeem((int)$r->user()->id,$d['token'],$d['idempotency_key']));
    }
    public function action(Request $r,string $id,PlatformEventService $s,PlatformInput $input){
        $d=$input->validate($r,$input->key()+['action'=>'required|in:apply,cancel,attendance','revision'=>'required|integer|min:1']);
        return response()->json($s->action((int)$r->user()->id,$id,$d));
    }
    public function report(Request $r,string $id,SafetyCaseService $s,PlatformInput $input){
        $d=$input->validate($r,$input->key()+['target_registration_id'=>'required|uuid','category'=>'required|in:CONDUCT,ATTENDANCE,RESOURCE',
            'statement'=>'required|string|min:5|max:500']);
        abort_if(preg_match('/https?:|www\.|@|\d{5,}|微信|手机号|身份证|经纬/iu',$d['statement']),422,'no private contacts or media');
        return response()->json($s->submit((int)$r->user()->id,$id,$d),201);
    }
    public function own(Request $r,SafetyCaseService $s){return response()->json($s->own((int)$r->user()->id));}
    public function ownShow(Request $r,string $id,SafetyCaseService $s){return response()->json($s->owner((int)$r->user()->id,$id));}
}
