<?php

namespace App\Services\Admin;

use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class QuestionOperations
{
    public function preview(array $ids, bool $enabled): array
    {
        return DB::transaction(function () use ($ids, $enabled) {
            $revision = $this->lockRevision();
            $questions = $this->questions($ids, $enabled);
            $states = $this->states($questions);

            return [
                'dry_run' => true, 'enabled' => $enabled, 'questions' => $states,
                'candidates' => count($states), 'expected_revision' => $revision,
                'preview_signature' => $this->signature($states, $enabled, $revision),
                'impact' => $this->impact($questions->modelKeys()),
            ];
        });
    }

    public function apply(array $ids, bool $enabled, int $expected, string $signature, string $reason, int $actor): array
    {
        validator(['reason' => trim($reason), 'actor' => $actor], [
            'reason' => 'required|string|max:500', 'actor' => 'required|integer|min:1',
        ])->validate();

        return DB::transaction(function () use ($ids, $enabled, $expected, $signature, $reason, $actor) {
            $revision = $this->lockRevision();
            $administrator = User::query()->lockForUpdate()->find($actor);
            abort_unless(app(AdminAccess::class)->allows($administrator), 403, '当前账号没有题库管理权限。');
            abort_if($revision !== $expected, 409, '题库版本已变化，请重新预览。');
            $questions = $this->questions($ids, $enabled);
            $states = $this->states($questions);
            abort_unless(hash_equals($this->signature($states, $enabled, $revision), $signature), 409, '预览已过期或不匹配，请重新预览。');
            foreach ($questions as $question) {
                $before = ['enabled' => $question->enabled, 'version' => $question->version, 'revision' => $revision];
                $question->enabled = $enabled;
                $question->version = (int) $question->version + 1;
                $question->save();
                app(OperationAudit::class)->record($actor, $enabled ? 'question.enable' : 'question.disable',
                    'questionnaire_question', $question->id, trim($reason), $expected, $before,
                    ['enabled' => $enabled, 'version' => $question->version, 'revision' => $revision + 1]);
            }
            DB::table('admin_versions')->where('key', 'questionnaire')->update(['revision' => $revision + 1]);

            return ['ok' => true, 'dry_run' => false, 'updated' => $questions->count(), 'revision' => $revision + 1];
        });
    }

    private function lockRevision(): int
    {
        $row = DB::table('admin_versions')->where('key', 'questionnaire')->lockForUpdate()->first();
        abort_unless($row, 409, '题库版本尚未初始化。');

        return (int) $row->revision;
    }

    private function questions(array $ids, bool $enabled): Collection
    {
        validator(['ids' => $ids], ['ids' => 'required|array|min:1|max:500', 'ids.*' => 'required|integer|min:1|distinct'])->validate();
        $ids = array_map('intval', $ids);
        $questions = QuestionnaireQuestion::query()->whereIn('id', $ids)->orderBy('id')->lockForUpdate()->get();
        if ($questions->count() !== count($ids)) {
            throw ValidationException::withMessages(['ids' => '存在无效题目ID。']);
        }
        foreach ($questions as $question) {
            if ($question->enabled === $enabled || (! $enabled && $question->quality_tag !== 'low_drop')) {
                throw ValidationException::withMessages(['ids' => '只能停用当前启用的low_drop题，或恢复本版有停用审计的题。']);
            }
            if ($enabled) {
                $audit = DB::table('admin_operation_audits')->where('target_type', 'questionnaire_question')
                    ->where('target_id', (string) $question->id)->where('action', 'question.disable')->orderByDesc('id')->first();
                $after = $audit ? json_decode($audit->after_state, true) : null;
                if (! $after || ($after['enabled'] ?? null) !== false || (int) ($after['version'] ?? 0) !== (int) $question->version) {
                    throw ValidationException::withMessages(['ids' => '此题没有与当前版本一致的本版停用审计，不能恢复。']);
                }
            }
        }

        return $questions;
    }

    private function states(Collection $questions): array
    {
        return $questions->map(fn ($q) => [
            'id' => (int) $q->id, 'key' => $q->question_key, 'enabled' => (bool) $q->enabled,
            'version' => (int) $q->version, 'updated_at' => $q->getRawOriginal('updated_at'),
        ])->all();
    }

    private function signature(array $states, bool $enabled, int $revision): string
    {
        $key = (string) config('app.key');
        abort_if($key === '', 503, '题库预览签名不可用。');

        return hash_hmac('sha256', json_encode([$revision, $enabled, $states], JSON_THROW_ON_ERROR), $key);
    }

    private function impact(array $ids): array
    {
        $attempts = 0;
        DB::table('questionnaire_attempts')->select('id', 'answers_json')->orderBy('id')->chunkById(200, function ($rows) use ($ids, &$attempts) {
            foreach ($rows as $row) {
                $answers = json_decode($row->answers_json, true) ?? [];
                if (array_intersect($ids, array_column($answers, 'question_id'))) { $attempts++; }
            }
        });
        $drafts = 0;
        DB::table('questionnaire_drafts')->select('id', 'payload')->orderBy('id')->chunkById(200, function ($rows) use ($ids, &$drafts) {
            foreach ($rows as $row) {
                $payload = json_decode($row->payload, true) ?? [];
                if (array_intersect($ids, array_merge($payload['question_ids'] ?? [], array_keys($payload['answers'] ?? [])))) { $drafts++; }
            }
        });

        return [
            'answers' => DB::table('questionnaire_answers')->whereIn('questionnaire_question_id', $ids)->count(),
            'attempts' => $attempts, 'drafts' => $drafts,
            // Every active run is conservatively included: changing eligibility can affect any new candidate.
            'active_matching_runs' => DB::table('matching_runs')->whereIn('state', ['pending', 'running'])->count(),
            'active_rounds' => DB::table('dating_rounds')->whereNull('closed_at')->count(),
        ];
    }
}
