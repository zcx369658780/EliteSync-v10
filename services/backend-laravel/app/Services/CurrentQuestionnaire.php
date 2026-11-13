<?php

namespace App\Services;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Support\Facades\DB;

final class CurrentQuestionnaire
{
    public function lock(): object
    {
        return DB::table('admin_versions')->where('key', 'questionnaire')->lockForUpdate()->firstOrFail();
    }

    public function validCount(int $id): int
    {
        return count($this->answers($id));
    }

    public function answers(int $id): array
    {
        $questions = QuestionnaireQuestion::where('enabled', true)->get()->keyBy('id');
        $goal = User::whereKey($id)->value('relationship_goal');
        $result = [];
        foreach (QuestionnaireAnswer::where('user_id', $id)->get() as $answer) {
            $question = $questions->get($answer->questionnaire_question_id);
            if (! $question) {
                continue;
            }
            $payload = (array) $answer->answer_payload;
            $selected = $answer->selected_answer_json ?: ($payload['selected_answer'] ?? (isset($payload['value']) ? [$payload['value']] : []));
            $acceptable = $answer->acceptable_answers_json ?: ($payload['acceptable_answers'] ?? $selected);
            $options = array_column($question->options ?? [], 'option_id');
            if (! $selected || array_diff($selected, $options) || array_diff($acceptable, $options)) {
                continue;
            }
            // Enable/disable revisions do not rewrite the historical answer. Goal is derived from
            // the explicitly confirmed profile contract, while original answers/attempts are retained.
            if ($question->category === 'relationship_goals') {
                $mapped = ['marriage' => 'marriage', 'dating' => 'long_term'][$goal] ?? null;
                if ($mapped !== null && in_array($mapped, $options, true)) {
                    $selected = [$mapped];
                }
            }
            $result[(int) $question->id] = [
                'selected' => $selected, 'acceptable' => $acceptable,
                'importance' => (int) ($answer->importance ?? $payload['importance'] ?? 2),
                'category' => $question->category,
            ];
        }
        return $result;
    }
}
