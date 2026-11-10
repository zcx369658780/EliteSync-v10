<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\QuestionnaireQuestion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class QuestionnaireDraftController extends Controller
{
    public function show(Request $r)
    {
        $row = DB::table('questionnaire_drafts')->where('user_id', $r->user()->id)->first();

        return response()->json($row ? json_decode($row->payload, true) : new \stdClass);
    }

    public function save(Request $r)
    {
        $p = $r->validate(['answers' => 'required|array|max:500', 'answers.*' => 'integer|min:0', 'current_index' => 'required|integer|min:0|max:500',
            'version' => 'required|string|max:80', 'bank_version' => 'required|string|max:80']);
        abort_unless($p['version'] === config('questionnaire.version', 'q_v2') && $p['bank_version'] === config('questionnaire.bank_version', 'qb_v1'), 422, 'stale draft version');
        $existing = DB::table('questionnaire_drafts')->where('user_id', $r->user()->id)->first();
        $saved = $existing ? json_decode($existing->payload, true) : [];
        if (isset($saved['question_ids'])) {
            $p['question_ids'] = $saved['question_ids'];
        }
        foreach ($p['answers'] as $id => $index) {
            $q = QuestionnaireQuestion::where('enabled', true)->find((int) $id);
            abort_unless($q && isset($q->options[$index]), 422, 'invalid draft answer');
            if (isset($p['question_ids'])) {
                abort_unless(in_array((int) $id, $p['question_ids'], true), 422, 'question outside current session');
            }
        }
        DB::table('questionnaire_drafts')->updateOrInsert(['user_id' => $r->user()->id], ['payload' => json_encode($p, JSON_UNESCAPED_UNICODE), 'created_at' => now(), 'updated_at' => now()]);

        return response()->json(['ok' => true] + $p);
    }
}
