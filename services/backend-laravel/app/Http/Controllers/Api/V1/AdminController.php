<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DatingMatch;
use App\Models\ModerationReport;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\MatchingDebugModeService;
use App\Services\MatchingEngineService;
use App\Services\PersonalityProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AdminController extends Controller
{
    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    /**
     * Build a safe user projection that tolerates older schemas where some
     * 3.1 columns may not exist yet.
     *
     * @param  array<string, mixed>  $fallbacks
     * @return array<int, string|\Illuminate\Database\Query\Expression>
     */
    private function safeUserSelect(array $fallbacks = []): array
    {
        $columns = ['id', 'phone', 'name'];

        foreach ($fallbacks as $column => $fallback) {
            if (Schema::hasColumn('users', $column)) {
                $columns[] = $column;
                continue;
            }

            $columns[] = DB::raw($this->sqlLiteral($fallback).' as '.$column);
        }

        return $columns;
    }

    private function sqlLiteral(mixed $value): string
    {
        if ($value === null) {
            return 'NULL';
        }

        if (is_bool($value)) {
            return $value ? '1' : '0';
        }

        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }

        return DB::connection()->getPdo()->quote((string) $value);
    }

    public function users(Request $request): JsonResponse
    {
        $query = User::query()
            ->orderBy('id')
            ;

        $accountType = trim((string) $request->query('account_type', ''));
        if ($accountType !== '') {
            $query->where('account_type', $accountType);
        }

        $syntheticBatch = trim((string) $request->query('synthetic_batch', ''));
        if ($syntheticBatch !== '') {
            $query->where(function ($inner) use ($syntheticBatch) {
                $inner->where('synthetic_batch', $syntheticBatch);
                if (Schema::hasColumn('users', 'synthetic_batch_id')) {
                    $inner->orWhere('synthetic_batch_id', $syntheticBatch);
                }
            });
        }

        if ($request->filled('is_synthetic')) {
            $query->where('is_synthetic', filter_var((string) $request->query('is_synthetic'), FILTER_VALIDATE_BOOL));
        }

        $accountStatus = trim((string) $request->query('account_status', ''));
        if ($accountStatus !== '' && Schema::hasColumn('users', 'account_status')) {
            $query->where('account_status', $accountStatus);
        }

        $visibilityScope = trim((string) $request->query('visibility_scope', ''));
        if ($visibilityScope !== '' && Schema::hasColumn('users', 'visibility_scope')) {
            $query->where('visibility_scope', $visibilityScope);
        }

        $items = $query
            ->get($this->safeUserSelect([
                'role' => 'user',
                'account_type' => 'normal',
                'disabled' => false,
                'synthetic_batch_id' => null,
                'synthetic_seed' => null,
                'generation_version' => 'v1',
                'account_status' => 'active',
                'visibility_scope' => 'square',
                'cleanup_token' => null,
                'moderation_status' => 'normal',
                'verify_status' => 'pending',
                'is_synthetic' => false,
                'synthetic_batch' => null,
                'is_match_eligible' => true,
                'is_square_visible' => true,
                'exclude_from_metrics' => false,
                'banned_reason' => null,
            ]));

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function verifyQueue(): JsonResponse
    {
        $items = User::query()
            ->where('verify_status', '!=', 'approved')
            ->orderBy('id')
            ->get($this->safeUserSelect([
                'role' => 'user',
                'account_type' => 'normal',
                'verify_status' => 'pending',
                'moderation_status' => 'normal',
            ]));

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function updateVerify(Request $request,int $uid):JsonResponse {
        $d=$request->validate(['status'=>'required|in:pending,approved,rejected','reason'=>'required|string|max:1000','expected_revision'=>'required|integer|min:0','confirm'=>'required|accepted']);
        app(\App\Services\Admin\UserGovernance::class)->review($request->user(),$uid,$d['status'],$d['reason'],$d['expected_revision']);return response()->json(['ok'=>true]);
    }
    public function disable(Request $request,int $uid):JsonResponse {
        $d=$request->validate(['reason'=>'required|string|max:1000','expected_revision'=>'required|integer|min:0','confirm'=>'required|accepted']);
        $id=app(\App\Services\Admin\UserGovernance::class)->punish($request->user(),$uid,'banned',$d['reason'],$d['expected_revision']);return response()->json(['ok'=>true,'sanction_id'=>$id]);
    }
    public function reports(): JsonResponse
    {
        $items = ModerationReport::query()
            ->with([
                'reporter' => function ($query) {
                    $query->select($this->safeUserSelect());
                },
                'targetUser' => function ($query) {
                    $query->select($this->safeUserSelect([
                        'disabled' => false,
                        'moderation_status' => 'normal',
                    ]));
                },
                'resolver' => function ($query) {
                    $query->select($this->safeUserSelect());
                },
            ])
            ->orderByDesc('id')
            ->get()
            ->map(fn (ModerationReport $report) => [
                'id' => $report->id,
                'status' => $report->status,
                'appeal_status' => $report->appeal_status,
                'category' => $report->category,
                'reason_code' => $report->reason_code,
                'detail' => $report->detail,
                'appeal_note' => $report->appeal_note,
                'appealed_at' => optional($report->appealed_at)?->toIso8601String(),
                'resolved_at' => optional($report->resolved_at)?->toIso8601String(),
                'reporter' => [
                    'id' => $report->reporter?->id,
                    'name' => $report->reporter?->name,
                    'phone' => $report->reporter?->phone,
                ],
                'target_user' => [
                    'id' => $report->targetUser?->id,
                    'name' => $report->targetUser?->name,
                    'phone' => $report->targetUser?->phone,
                    'disabled' => (bool) ($report->targetUser?->disabled ?? false),
                    'moderation_status' => (string) ($report->targetUser?->moderation_status ?? 'normal'),
                ],
                'resolver' => [
                    'id' => $report->resolver?->id,
                    'name' => $report->resolver?->name,
                ],
            ])
            ->values();

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function reportDetail(int $reportId): JsonResponse
    {
        $report = ModerationReport::query()
            ->with([
                'reporter' => function ($query) {
                    $query->select($this->safeUserSelect());
                },
                'targetUser' => function ($query) {
                    $query->select($this->safeUserSelect([
                        'disabled' => false,
                        'moderation_status' => 'normal',
                    ]));
                },
                'resolver' => function ($query) {
                    $query->select($this->safeUserSelect());
                },
            ])
            ->find($reportId);

        if (!$report) {
            return response()->json(['message' => 'report not found'], 404);
        }

        return response()->json([
            'id' => $report->id,
            'status' => $report->status,
            'appeal_status' => $report->appeal_status,
            'category' => $report->category,
            'reason_code' => $report->reason_code,
            'detail' => $report->detail,
            'appeal_note' => $report->appeal_note,
            'admin_note' => $report->admin_note,
            'appealed_at' => optional($report->appealed_at)?->toIso8601String(),
            'resolved_at' => optional($report->resolved_at)?->toIso8601String(),
            'reporter' => [
                'id' => $report->reporter?->id,
                'name' => $report->reporter?->name,
                'phone' => $report->reporter?->phone,
            ],
            'target_user' => [
                'id' => $report->targetUser?->id,
                'name' => $report->targetUser?->name,
                'phone' => $report->targetUser?->phone,
                'disabled' => (bool) ($report->targetUser?->disabled ?? false),
                'moderation_status' => (string) ($report->targetUser?->moderation_status ?? 'normal'),
            ],
            'resolver' => [
                'id' => $report->resolver?->id,
                'name' => $report->resolver?->name,
            ],
        ]);
    }

    public function reportAction(Request $request,int $reportId):JsonResponse {
        $d=$request->validate(['action'=>'required|in:triage,investigate,dismiss,restrict,banned,restore,close,remove_post','reason'=>'required|string|max:1000','expected_revision'=>'required|integer|min:0','expected_user_revision'=>'required|integer|min:0','sanction_id'=>'nullable|integer','confirm'=>'required|accepted']);
        app(\App\Services\Admin\ReportOperations::class)->act($request->user(),$reportId,$d);return response()->json(['ok'=>true]);
    }
    public function devRunMatching(
        PersonalityProfileService $profileService,
        MatchingEngineService $matchingEngine,
        MatchingDebugModeService $debugMode
    ): JsonResponse
    {
        abort(403,'Use audited matching round operations');

        // Dev matching may process large synthetic batches; avoid php max_execution_time cutoff.
        @set_time_limit(0);
        @ini_set('max_execution_time', '0');

        $weekTag = $this->weekTag();
        $totalQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();
        $requiredAnswers = max(1, (int) config('questionnaire.required_answer_count', 10));
        $includeSyntheticUsers = $debugMode->includeSyntheticUsers();

        if ($totalQuestions === 0) {
            return response()->json([
                'ok' => true,
                'week_tag' => $weekTag,
                'pairs' => 0,
                'eligible_users' => 0,
                'include_synthetic_users' => $includeSyntheticUsers,
                'message' => 'no enabled questions',
                'match_ids' => [],
            ]);
        }

        $eligibleUserIds = QuestionnaireAnswer::query()
            ->select('user_id')
            ->groupBy('user_id')
            ->havingRaw('COUNT(DISTINCT questionnaire_question_id) >= ?', [$requiredAnswers]);

        $users = User::query()
            ->where('disabled', false)
            ->when(!$includeSyntheticUsers, function ($q) {
                $q->where('is_synthetic', false);
            })
            ->whereIn('id', $eligibleUserIds)
            ->orderBy('id')
            ->get(['id', 'created_at', 'updated_at']);

        $pairs = 0;
        $createdMatchIds = [];
        $profiles = [];
        $usersMeta = [];
        foreach ($users as $u) {
            $profiles[(int) $u->id] = $profileService->buildForUser((int) $u->id);
            $usersMeta[(int) $u->id] = [
                'created_at' => $u->created_at,
                'updated_at' => $u->updated_at,
            ];
        }
        $plannedPairs = $matchingEngine->buildPairs($profiles, $usersMeta);

        foreach ($plannedPairs as $plannedPair) {
            $a = (int) $plannedPair['user_a'];
            $b = (int) $plannedPair['user_b'];

            $exists = DatingMatch::query()
                ->where('week_tag', $weekTag)
                ->where(function ($q) use ($a, $b) {
                    $q->where(function ($pair) use ($a, $b) {
                        $pair->where('user_a', $a)->where('user_b', $b);
                    })->orWhere(function ($pair) use ($a, $b) {
                        $pair->where('user_a', $b)->where('user_b', $a);
                    });
                })
                ->first();

            if ($exists) {
                $createdMatchIds[] = $exists->id;
                continue;
            }

            $match = DatingMatch::create([
                'week_tag' => $weekTag,
                'user_a' => $a,
                'user_b' => $b,
                'highlights' => (string) $plannedPair['highlights'],
                'explanation_tags' => $plannedPair['explanation_tags'] ?? null,
                'score_base' => $plannedPair['score_base'] ?? null,
                'score_final' => $plannedPair['score_final'] ?? null,
                'score_fair' => $plannedPair['score_fair'] ?? null,
                'score_personality_total' => $plannedPair['score_personality_total'] ?? null,
                'score_mbti_total' => $plannedPair['score_mbti_total'] ?? null,
                'score_astro_total' => $plannedPair['score_astro_total'] ?? null,
                'score_overall' => $plannedPair['score_overall'] ?? null,
                'score_bazi' => $plannedPair['score_bazi'] ?? null,
                'score_zodiac' => $plannedPair['score_zodiac'] ?? null,
                'score_constellation' => $plannedPair['score_constellation'] ?? null,
                'score_natal_chart' => $plannedPair['score_natal_chart'] ?? null,
                'match_verdict' => $plannedPair['match_verdict'] ?? null,
                'match_reasons' => $plannedPair['match_reasons'] ?? null,
                'penalty_factors' => $plannedPair['penalty_factors'] ?? null,
                'drop_released' => false,
            ]);
            $pairs++;
            $createdMatchIds[] = $match->id;
        }

        return response()->json([
            'ok' => true,
            'week_tag' => $weekTag,
            'pairs' => $pairs,
            'eligible_users' => $users->count(),
            'include_synthetic_users' => $includeSyntheticUsers,
            'match_ids' => $createdMatchIds,
        ]);
    }

    public function devMatchingDebugStatus(MatchingDebugModeService $debugMode): JsonResponse
    {
        $enabled = $debugMode->includeSyntheticUsers();
        $syntheticUserCount = User::query()->where('is_synthetic', true)->count();

        return response()->json([
            'ok' => true,
            'include_synthetic_users' => $enabled,
            'synthetic_users' => $syntheticUserCount,
        ]);
    }

    public function devMatchingDebugSwitch(Request $request, MatchingDebugModeService $debugMode): JsonResponse
    {
        abort(403,'Use audited matching round operations');

        $data = $request->validate([
            'include_synthetic_users' => ['required', 'boolean'],
        ]);

        $enabled = (bool) $data['include_synthetic_users'];
        $debugMode->setIncludeSyntheticUsers($enabled);

        return response()->json([
            'ok' => true,
            'include_synthetic_users' => $debugMode->includeSyntheticUsers(),
        ]);
    }

    public function devReleaseDrop(): JsonResponse
    {
        abort(403,'Use audited matching round operations');

        $weekTag = $this->weekTag();
        $updated = DatingMatch::query()
            ->where('week_tag', $weekTag)
            ->update(['drop_released' => true]);

        return response()->json([
            'ok' => true,
            'week_tag' => $weekTag,
            'released' => $updated,
        ]);
    }

    public function questionQualityStats(): JsonResponse
    {
        $base = QuestionnaireQuestion::query()->where('enabled', true);

        $totalsByTier = (clone $base)
            ->selectRaw('quality_tier, COUNT(*) as c')
            ->groupBy('quality_tier')
            ->pluck('c', 'quality_tier');

        $totalsByTag = (clone $base)
            ->selectRaw('quality_tag, COUNT(*) as c')
            ->groupBy('quality_tag')
            ->pluck('c', 'quality_tag');

        $reasons = (clone $base)
            ->select(['quality_tier', 'quality_tag', 'quality_reason', DB::raw('COUNT(*) as c')])
            ->groupBy('quality_tier', 'quality_tag', 'quality_reason')
            ->orderByDesc('c')
            ->get()
            ->map(fn ($r) => [
                'quality_tier' => (string) $r->quality_tier,
                'quality_tag' => (string) $r->quality_tag,
                'quality_reason' => (string) $r->quality_reason,
                'count' => (int) $r->c,
            ])
            ->values();

        $dropReasons = $reasons
            ->filter(fn ($r) => $r['quality_tag'] === 'low_drop')
            ->values();

        return response()->json([
            'total' => (int) $base->count(),
            'by_tier' => $totalsByTier,
            'by_tag' => $totalsByTag,
            'reasons' => $reasons,
            'low_drop_reasons' => $dropReasons,
        ]);
    }

    public function pruneLowDropQuestions(Request $request):JsonResponse {
      $d=$request->validate(['dry_run'=>'nullable|boolean','reasons'=>'nullable|array','reasons.*'=>'string|max:64','expected_revision'=>'nullable|integer|min:0','preview_signature'=>'nullable|string','confirm'=>'nullable|accepted','reason'=>'nullable|string|max:1000']);
      $query=QuestionnaireQuestion::where('enabled',true)->where('quality_tag','low_drop');if(!empty($d['reasons']))$query->whereIn('quality_reason',$d['reasons']);$ids=$query->pluck('id')->all();
      if(!$ids)return response()->json(['ok'=>true,'dry_run'=>true,'candidates'=>0,'updated'=>0]);
      $ops=app(\App\Services\Admin\QuestionOperations::class);
      if($d['dry_run']??true)return response()->json(['ok'=>true,'updated'=>0]+$ops->preview($ids,false));
      $request->validate(['expected_revision'=>'required|integer|min:0','preview_signature'=>'required|string','reason'=>'required|string|max:1000','confirm'=>'required|accepted']);
      return response()->json($ops->apply($ids,false,(int)$d['expected_revision'],$d['preview_signature'],$d['reason'],(int)$request->user()->id));
    }
}
