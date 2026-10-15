<?php
$root=dirname(__DIR__,3);require $root.'/services/backend-laravel/vendor/autoload.php';$app=require $root.'/services/backend-laravel/bootstrap/app.php';$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();
use Illuminate\Support\Facades\DB;
if(DB::connection()->getDatabaseName()!=='elitesync_v1008_dev'||(int)DB::connection()->getConfig('port')!==43318)throw new RuntimeException('Exact V1008 database required');
$columns=['users'=>['id','name','role','disabled','verify_status','verify_reason','verify_revision','admin_revision','moderation_status','account_status','visibility_scope','is_match_eligible'],
'admin_sanctions'=>['id','user_id','report_id','kind','active','restored_by'],
'admin_operation_audits'=>['id','actor_user_id','action','target_type','target_id','reason','expected_version','before_state','after_state'],
'admin_versions'=>['key','revision'],
'dating_rounds'=>['id','round_key','cadence_key','state','state_version','active_run_id'],
'matching_runs'=>['id','round_id','run_key','attempt_no','state','outcome','error_code','pair_count','candidate_count','supersedes_run_id','fencing_token'],
'dating_matches'=>['id','round_id','matching_run_id','user_a','user_b','drop_released'],
'product_connections'=>['id','match_id','state','revision'],
'messaging_consents'=>['id','connection_id','purpose','state','revision','generation'],
'moderation_reports'=>['id','reporter_id','target_user_id','target_status_post_id','status','admin_revision'],
'status_posts'=>['id','author_user_id','is_deleted'],
'app_release_versions'=>['id','platform','channel','version_name','version_code','min_supported_version_name','is_active'],
'app_notification_items'=>['id','user_id','kind','title','body','payload','read_at']];
$out=['database'=>DB::connection()->getDatabaseName(),'port'=>(int)DB::connection()->getConfig('port')];
foreach($columns as $t=>$c){if(\Illuminate\Support\Facades\Schema::hasTable($t))$out[$t]=DB::table($t)->get($c);}
$out['answers_by_user']=DB::table('questionnaire_answers')->selectRaw('user_id, COUNT(*) AS n')->groupBy('user_id')->get();$out['attempts_count']=DB::table('questionnaire_attempts')->count();$out['tokens_by_user']=DB::table('personal_access_tokens')->selectRaw('tokenable_id,COUNT(*) AS n')->groupBy('tokenable_id')->get();$out['sessions_by_user']=DB::table('sessions')->selectRaw('user_id,COUNT(*) AS n')->groupBy('user_id')->get();$out['readiness']=\App\Models\User::whereIn('id',[2,3,4])->get()->mapWithKeys(fn($u)=>[$u->id=>app(\App\Services\ProfileReadinessService::class)->forUser($u)]);echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
