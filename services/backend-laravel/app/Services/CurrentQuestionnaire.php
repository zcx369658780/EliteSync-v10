<?php
namespace App\Services;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use Illuminate\Support\Facades\DB;
final class CurrentQuestionnaire {
 public function lock():object {return DB::table('admin_versions')->where('key','questionnaire')->lockForUpdate()->firstOrFail();}
 public function validCount(int $id):int {
  $qs=QuestionnaireQuestion::where('enabled',true)->get()->keyBy('id');$count=0;
  foreach(QuestionnaireAnswer::where('user_id',$id)->get() as $a){$q=$qs->get($a->questionnaire_question_id);if(!$q)continue;$p=(array)$a->answer_payload;$selected=(array)($p['selected_answer']??(isset($p['value'])?[$p['value']]:[]));$options=array_column($q->options??[],'option_id');
   // Enable/disable revisions do not change historical question content/option identities.
   if($selected&&!array_diff($selected,$options))$count++;
  }return $count;
 }
}
