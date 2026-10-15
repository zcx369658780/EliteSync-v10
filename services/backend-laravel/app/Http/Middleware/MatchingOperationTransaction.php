<?php
namespace App\Http\Middleware;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
final class MatchingOperationTransaction {
 public function handle(Request $r,Closure $next){
  if(!$r->isMethod('post'))return $next($r);
  return DB::transaction(function()use($r,$next){
   $key='matching-operations';DB::table('admin_versions')->insertOrIgnore(['key'=>$key,'revision'=>0]);DB::table('admin_versions')->where('key',$key)->lockForUpdate()->first();
   if($r->route('roundKey')){$round=\App\Models\DatingRound::where('round_key',$r->route('roundKey'))->lockForUpdate()->firstOrFail();
     $idempotency=trim((string)$r->header('Idempotency-Key'));$replay=$idempotency!==''&&(DB::table('matching_operation_audits')->where('round_id',$round->id)->where('idempotency_key',$idempotency)->exists());
     abort_unless($replay||(int)$r->input('state_version',-1)===(int)$round->state_version,409,'stale state version');
   }
   try{$response=$next($r);}catch(\DomainException|\InvalidArgumentException $e){abort(409,$e->getMessage());}
   if($response->getStatusCode()<300){\App\Services\Admin\OperationAudit::record($r->user()->id,'matching.'.basename($r->path()),'round',$r->route('roundKey')??'new',(string)$r->input('reason_code','prepare'),(int)$r->input('state_version'),[],['status'=>$response->getStatusCode()]);}
   return $response;
  });
 }
}
