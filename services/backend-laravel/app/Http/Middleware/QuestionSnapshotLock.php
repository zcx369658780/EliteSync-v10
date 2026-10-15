<?php
namespace App\Http\Middleware;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
final class QuestionSnapshotLock {
 public function handle(Request $r,Closure $next){
  if(!$r->is('api/v1/questionnaire*')&&!$r->is('api/v1/questions*'))return $next($r);
  return DB::transaction(function()use($r,$next){app(\App\Services\CurrentQuestionnaire::class)->lock();return $next($r);});
 }
}
