<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ModerationReport;
use App\Services\Admin\UserGovernance;
use App\Services\Admin\ReportOperations;
use App\Services\Admin\OperationAudit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
final class AdminOperationsController extends Controller {
 public function user(Request $r,int $id){$user=User::select(['id','name','phone','role','disabled','moderation_status','verify_status','verify_reason','verify_revision','admin_revision'])->findOrFail($id);$sanctions=DB::table('admin_sanctions')->where('user_id',$id)->get(['id','kind','active','report_id']);return view('admin.user',compact('user','sanctions'));}
 public function review(Request $r,int $id,UserGovernance $s){$d=$r->validate(['status'=>'required|in:pending,approved,rejected','reason'=>'required|string|max:1000','expected_revision'=>'required|integer|min:0','confirm'=>'accepted|required']);$s->review($r->user(),$id,$d['status'],$d['reason'],$d['expected_revision']);return back()->with('status','运营审核已保存；不改变历史匹配和同意。');}
 public function punishment(Request $r,int $id,UserGovernance $s){$d=$r->validate(['action'=>'required|in:restrict,banned,restore','reason'=>'required|string|max:1000','expected_revision'=>'required|integer|min:0','sanction_id'=>'nullable|integer','confirm'=>'accepted|required']);if($d['action']==='restore')$s->restore($r->user(),$id,(int)($d['sanction_id']??0),$d['reason'],$d['expected_revision']);else $s->punish($r->user(),$id,$d['action'],$d['reason'],$d['expected_revision']);return back()->with('status','处罚操作已审计提交；不会恢复旧凭据或旧同意。');}
 public function reports(){ $reports=ModerationReport::select(['id','category','target_user_id','status','admin_revision','created_at'])->latest('id')->paginate(20);return view('admin.reports',compact('reports')); }
 public function report(Request $r,int $id){$report=ModerationReport::findOrFail($id);$target=User::select(['id','name','admin_revision','disabled','moderation_status'])->findOrFail($report->target_user_id);$post=$report->target_status_post_id?\App\Models\StatusPost::where('id',$report->target_status_post_id)->whereIn('visibility',['public','square'])->first(['id','author_user_id','title','body','is_deleted']):null;DB::transaction(fn()=>OperationAudit::record($r->user()->id,'report.view','report',$id,'case detail view',null,[],['category'=>$report->category]));$sanctions=DB::table('admin_sanctions')->where('report_id',$id)->where('active',true)->get(['id','kind']);return view('admin.report',compact('report','target','post','sanctions'));}
 public function reportAction(Request $r,int $id,ReportOperations $s){$d=$r->validate(['action'=>'required|in:triage,investigate,dismiss,restrict,banned,restore,close,remove_post','reason'=>'required|string|max:1000','expected_revision'=>'required|integer|min:0','expected_user_revision'=>'required|integer|min:0','sanction_id'=>'nullable|integer','confirm'=>'required|accepted']);$s->act($r->user(),$id,$d);return back()->with('status','举报处理已提交并审计。');}
 public function audits(){ $audits=DB::table('admin_operation_audits')->latest('id')->paginate(30);return view('admin.audits',compact('audits')); }
}
