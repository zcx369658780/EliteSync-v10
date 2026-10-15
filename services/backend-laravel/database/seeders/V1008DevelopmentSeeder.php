<?php
namespace Database\Seeders;
use App\Models\User;
use App\Models\QuestionnaireQuestion;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireAttempt;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
final class V1008DevelopmentSeeder extends Seeder {
 public function run():void {
  $db=DB::connection();if(!app()->environment('local')||$db->getDatabaseName()!=='elitesync_v1008_dev'||$db->getConfig('host')!=='127.0.0.1'||(int)$db->getConfig('port')!==43318)throw new \RuntimeException('Exact V1008 database required');
  if(User::count())throw new \RuntimeException('Refuse reseed of persisted evidence database');
  $this->call(QuestionnaireQuestionSeeder::class);
  $data=json_decode(file_get_contents(env('V1008_CREDENTIALS_FILE')),true,flags:JSON_THROW_ON_ERROR);
  foreach($data['accounts'] as $name=>$a){$u=User::create(['phone'=>$a['phone'],'password'=>Hash::make($a['password']),'name'=>'V1008 Fictional '.$name,'role'=>in_array($name,['admin','roleonly'],true)?'admin':'user','verify_status'=>in_array($name,['alice','bob','admin'],true)?'approved':'pending','gender'=>$name==='alice'?'female':'male','city'=>'V1008 Development City','birthday'=>'1994-03-18','relationship_goal'=>'long_term','account_type'=>'test','generation_version'=>'v10.0.8','is_synthetic'=>false,'realname_verified'=>false,'disabled'=>$name==='disabled']);
   if(in_array($name,['alice','bob'],true)){
    $qs=QuestionnaireQuestion::where('enabled',true)->where('quality_tag','!=','low_drop')->orderBy('id')->limit(20)->get();$answers=[];
    foreach($qs as $i=>$q){if($i===0){$q->quality_tag='low_drop';$q->quality_tier='low';$q->quality_reason='v1008_controlled_retirement';$q->save();}$opt=$q->options[0]['option_id'];$answer=['question_id'=>$q->id,'selected_answer'=>[$opt],'acceptable_answers'=>[$opt],'importance'=>1,'version'=>$q->version];$answers[]=$answer;QuestionnaireAnswer::create(['user_id'=>$u->id,'questionnaire_question_id'=>$q->id,'answer_payload'=>['value'=>$opt,'selected_answer'=>[$opt],'acceptable_answers'=>[$opt],'version'=>$q->version],'selected_answer_json'=>[$opt],'acceptable_answers_json'=>[$opt],'importance'=>1,'version'=>$q->version]);}
    QuestionnaireAttempt::create(['user_id'=>$u->id,'questionnaire_version'=>'q_v2','bank_version'=>'qb_v1','attempt_version'=>'qa_v1','answers_count'=>20,'total_count'=>QuestionnaireQuestion::where('enabled',true)->count(),'answers_json'=>$answers,'profile_json'=>['complete'=>true],'completed_at'=>now()]);
   }
  }
  $this->command->info('V1008 fictional accounts, original questions and explicitly seeded historical answer fixtures created; no prior-version database accessed.');
 }
}
