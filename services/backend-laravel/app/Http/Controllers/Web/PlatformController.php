<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Services\PlatformEventService;
use App\Services\PlatformInput;
use App\Services\SafetyCaseService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

final class PlatformController extends Controller
{
    public function index(Request $r,PlatformEventService $events,SafetyCaseService $cases){
        return view('admin.platform-events',['events'=>$events->adminListing((int)$r->user()->id),'cases'=>$cases->adminListing((int)$r->user()->id)]);
    }
    public function store(Request $r,PlatformEventService $s,PlatformInput $input){
        $s->create((int)$r->user()->id,$input->create($r));return redirect('/admin/platform-events')->with('status','合成活动草稿已保存，无真实预订或付款。');
    }
    public function action(Request $r,string $id,PlatformEventService $s,PlatformInput $input){
        $result=$s->adminAction((int)$r->user()->id,$id,$input->eventAdmin($r));
        return redirect('/admin/platform-events')->with('status','受控开发操作已记录。')->with('issued_token',$result['issued_token']??null);
    }
    public function detail(Request $r,string $id,SafetyCaseService $s){
        $d=$r->validate(['reason'=>'required|string|min:5|max:500']);
        return view('admin.safety-case',$s->adminDetail((int)$r->user()->id,$id,$d['reason']));
    }
    public function evidence(Request $r,string $id,SafetyCaseService $s){
        $d=$r->validate(['reason'=>'required|string|min:5|max:500']);
        return response()->json($s->adminDetail((int)$r->user()->id,$id,$d['reason']));
    }
    public function appealWorkspace(Request $r,string $id,SafetyCaseService $s){
        $d=$r->validate(['reason'=>'required|string|min:5|max:500']);
        return view('admin.safety-case',$s->appealWorkspace((int)$r->user()->id,$id,$d['reason']));
    }
    public function decide(Request $r,string $id,SafetyCaseService $s,PlatformInput $input){
        $d=$input->validate($r,$input->admin()+['revision'=>'required|integer|min:1','action'=>'required|in:triage,investigate,dismiss,substantiate,restrict,banned,close,due',
            'corroborating_case_id'=>'nullable|uuid','manual_finding'=>'nullable|string|max:400','evidence_checked'=>'accepted_if:action,substantiate',
            'user_revision'=>'required_if:action,restrict,banned|integer|min:0','review_due_at'=>'required_if:action,due|date|after:now|before:+90 days'],true);
        if(isset($d['review_due_at']))$d['review_due_at']=Carbon::parse($d['review_due_at'])->utc()->format('Y-m-d H:i:s');
        $s->decide((int)$r->user()->id,$id,$d);return redirect('/admin/platform-events')->with('status','具名人工处理已记录，规则并非处罚。');
    }
    public function review(Request $r,string $id,SafetyCaseService $s,PlatformInput $input){
        $d=$input->validate($r,$input->admin()+['revision'=>'required|integer|min:1','appeal_id'=>'required|integer|min:1',
            'appeal_revision'=>'required|integer|min:1','outcome'=>'required|in:UPHELD,OVERTURNED,CORRECTED','user_revision'=>'required|integer|min:0'],true);
        $s->review((int)$r->user()->id,$id,$d);return redirect('/admin/platform-events')->with('status','本人申诉已由具名管理员复核，只恢复精确对应的处罚。');
    }
}
