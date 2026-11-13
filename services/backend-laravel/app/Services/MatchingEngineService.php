<?php

namespace App\Services;

use App\Models\DatingMatch;
use App\Models\User;

/** Ordinary matching consumes confirmed private inputs and current questionnaire answers. */
class MatchingEngineService
{
    private const IMPORTANCE_WEIGHT = [0 => 0.0, 1 => 0.33, 2 => 0.66, 3 => 1.0];

    public function buildPairs(array $profiles, array $usersMeta = []): array
    {
        $ids = array_map('intval', array_keys($profiles));
        sort($ids, SORT_NUMERIC);
        $users = User::whereIn('id', $ids)->get()->keyBy('id');
        $answers = [];
        foreach ($ids as $id) {
            $answers[$id] = app(CurrentQuestionnaire::class)->answers($id);
        }
        $recent = $this->recentPairSet($ids);
        $inputs = app(MatchingInputService::class);
        $pairs = [];
        $used = [];
        foreach ($ids as $a) {
            if (isset($used[$a]) || ! $users->has($a)) {
                continue;
            }
            $best = null;
            foreach ($ids as $b) {
                if ($b === $a || isset($used[$b]) || ! $users->has($b)
                    || isset($recent[$this->pairKey($a, $b)])
                    || ! $inputs->pairAllowed($users[$a], $users[$b])
                    || ! app(SocialPolicy::class)->pairAllowed($a, $b)) {
                    continue;
                }
                $ab = $this->questionCompatibilityDirectional($a, $b, $answers)['score'];
                $ba = $this->questionCompatibilityDirectional($b, $a, $answers)['score'];
                $rank = ($ab + $ba) / 2.0;
                // Ascending IDs make ties deterministic. The unrounded score selects and is recorded.
                if ($best === null || $rank > $best['match_reasons']['rank_score']) {
                    $score = (int) round($rank * 100);
                    $best = [
                        'user_a' => $a, 'user_b' => $b, 'score' => $score,
                        'score_base' => $score, 'score_final' => $score, 'score_fair' => $score,
                        'score_overall' => $score, 'match_verdict' => 'questionnaire',
                        'highlights' => '已满足双方填写的基本条件，根据当前有效问卷进行排序',
                        'explanation_tags' => ['bilateral_preferences', 'current_questionnaire'],
                        'penalty_factors' => [],
                        'match_reasons' => [
                            'contract_version' => MatchingInputService::RULE_VERSION,
                            'rank_score' => $rank, 'direction_a' => $ab, 'direction_b' => $ba,
                            'tie_break' => 'ascending_user_id_then_peer_id',
                            'configuration_source' => 'fixed_v1017_questionnaire_rule',
                            'generated_at' => now()->toIso8601String(),
                            'summary' => '根据本人填写的条件与问卷生成有限候选，不保证相处效果',
                        ],
                    ];
                }
            }
            if ($best !== null) {
                $used[$a] = true;
                $used[$best['user_b']] = true;
                $pairs[] = $best;
            }
        }
        return $pairs;
    }

    private function questionCompatibilityDirectional(int $viewer, int $candidate, array $answerIndex): array
    {
        $viewerAnswers = $answerIndex[$viewer] ?? [];
        $candidateAnswers = $answerIndex[$candidate] ?? [];
        if (empty($viewerAnswers) || empty($candidateAnswers)) {
            return ['score' => 0.5, 'by_question' => []];
        }

        $sum = 0.0;
        $den = 0.0;
        $byQuestion = [];

        foreach ($viewerAnswers as $questionId => $rowA) {
            $rowB = $candidateAnswers[$questionId] ?? null;
            if (!$rowB) {
                continue;
            }
            $weight = self::IMPORTANCE_WEIGHT[$rowA['importance'] ?? 2] ?? 0.66;
            if ($weight <= 0) {
                continue;
            }
            $agreement = $this->agreementScore(
                $rowB['selected'] ?? [],
                $rowA['acceptable'] ?? []
            );
            $sum += $agreement * $weight;
            $den += $weight;
            $byQuestion[$questionId] = $agreement;
        }

        return [
            'score' => $den > 0 ? ($sum / $den) : 0.5,
            'by_question' => $byQuestion,
        ];
    }

    /**
     * @param array<int,string> $selectedByCandidate
     * @param array<int,string> $acceptableByViewer
     */
    private function agreementScore(array $selectedByCandidate, array $acceptableByViewer): float
    {
        $selected = array_values(array_unique(array_filter(array_map('strval', $selectedByCandidate))));
        $acceptable = array_values(array_unique(array_filter(array_map('strval', $acceptableByViewer))));
        if (empty($selected) || empty($acceptable)) {
            return 0.0;
        }

        if (count($selected) === 1) {
            return in_array($selected[0], $acceptable, true) ? 1.0 : 0.0;
        }

        $hit = count(array_intersect($selected, $acceptable));
        return max(0.0, min(1.0, $hit / count($selected)));
    }


    private function recentPairSet(array $userIds): array
    {
        $days = max(0, (int) config('matching.hard_filters.exclude_recent_pair_days', 14));
        if ($days <= 0) {
            return [];
        }
        $since = now()->subDays($days);
        $rows = DatingMatch::query()->where('drop_released', true)
            ->where('created_at', '>=', $since)
            ->where(function ($q) use ($userIds) {
                $q->whereIn('user_a', $userIds)->orWhereIn('user_b', $userIds);
            })
            ->get(['user_a', 'user_b']);
        $set = [];
        foreach ($rows as $r) {
            $set[$this->pairKey((int) $r->user_a, (int) $r->user_b)] = true;
        }
        return $set;
    }


    private function pairKey(int $a, int $b): string
    {
        return min($a, $b).':'.max($a, $b);
    }
}
