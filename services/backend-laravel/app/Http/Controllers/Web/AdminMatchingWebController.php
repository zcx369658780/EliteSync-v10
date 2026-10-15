<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use App\Models\DatingRound;
use App\Models\MatchingRun;
use App\Models\MatchingOperationAudit;
use App\Http\Controllers\Api\V1\AdminMatchingController;
use Illuminate\Http\Request;
final class AdminMatchingWebController extends Controller {
 public function index(){return view('admin.matching',['rounds'=>DatingRound::with('activeRun')->latest('id')->paginate(20),'channelRevision'=>(int)(\App\Models\DatingRoundChannel::where('channel_key','v1008')->value('state_version')??1),'runs'=>MatchingRun::latest('id')->limit(30)->get()]);}
 public function action(Request $r){
  $d=$r->validate(['operation'=>'required|in:prepare,executionRequest,reveal,retry,close','round_key'=>'nullable|uuid','idempotency_key'=>'required|string|max:120','confirm'=>'required|accepted','reason_code'=>'required|string|max:64']);
  $key=$d['round_key']??null;$r->headers->set('Idempotency-Key',$d['idempotency_key']);
  if(in_array($d['operation'],['reveal','close'],true))$r->headers->set('X-Matching-Confirmation','confirm:'.$key.':'.$d['operation']);
  $call=fn()=>app()->call([app(AdminMatchingController::class),$d['operation']],array_filter(['request'=>$r,'roundKey'=>$key],fn($v)=>$v!==null));
  $response=\Illuminate\Support\Facades\DB::transaction(function()use($r,$key,$call){$lock='matching-operations';\Illuminate\Support\Facades\DB::table('admin_versions')->insertOrIgnore(['key'=>$lock,'revision'=>0]);\Illuminate\Support\Facades\DB::table('admin_versions')->where('key',$lock)->lockForUpdate()->first();try{if($key){$round=DatingRound::where('round_key',$key)->lockForUpdate()->firstOrFail();$idem=$r->header('Idempotency-Key');$replay=MatchingOperationAudit::where('round_id',$round->id)->where('idempotency_key',$idem)->exists();abort_unless($replay||(int)$r->input('state_version',-1)===(int)$round->state_version,409,'stale state version');}$response=$call();if($response->getStatusCode()<300)\App\Services\Admin\OperationAudit::record($r->user()->id,'matching.'.$r->input('operation'),'round',$key??'new',(string)$r->input('reason_code'),(int)$r->input('state_version'),[],['status'=>$response->getStatusCode()]);return $response;}catch(\DomainException|\InvalidArgumentException $e){abort(409,$e->getMessage());}});
  if($response->getStatusCode()>=300)return response('操作未完成：'.e($response->getContent()),$response->getStatusCode());
  return redirect()->route('admin.matching')->with('status','操作已持久保存；pending不代表执行完毕，请查看run终态与worker。');
 }
}
