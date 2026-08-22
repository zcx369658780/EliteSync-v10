<?php

namespace App\Services;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\PairKey;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunOutcome;
use App\Domain\Matching\RunState;
use App\Domain\Matching\UserRoundState;
use App\Models\DatingMatch;
use App\Models\DatingRound;
use App\Models\DatingRoundUserState;
use App\Models\MatchingOperationAudit;
use App\Models\MatchingRun;
use App\Models\MatchingRunCandidate;
use App\Models\User;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\UserAstroProfile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;

class MatchingRunService
{
    public function request(DatingRound $round, string $idempotencyKey, string $actorType, ?int $actorId, string $reasonCode = 'execute'): MatchingRun
    {
        return DB::transaction(function () use ($round, $idempotencyKey, $actorType, $actorId, $reasonCode) {
            $replay = MatchingRun::query()->where('idempotency_key', $idempotencyKey)->first();
            if ($replay) {
                if ((int) $replay->round_id !== (int) $round->id) throw new \DomainException('idempotency_key_conflict');
                return $replay;
            }
            $locked = DatingRound::query()->whereKey($round->id)->lockForUpdate()->firstOrFail();
            if (!in_array($locked->state, [RoundState::Preparing, RoundState::Failed], true)) throw new \DomainException('round_not_executable');
            $attempt = ((int) MatchingRun::query()->where('round_id', $locked->id)->max('attempt_no')) + 1;
            $run = MatchingRun::query()->create([
                'round_id' => $locked->id, 'run_key' => (string) Str::uuid(), 'idempotency_key' => $idempotencyKey,
                'correlation_id' => (string) Str::uuid(), 'attempt_no' => $attempt, 'state' => RunState::Pending,
                'trigger_source' => 'admin', 'actor_type' => $actorType, 'actor_id' => $actorId, 'reason_code' => $reasonCode,
                'eligibility_cutoff_at' => now()->utc(), 'algorithm_version' => (string) config('matching.contract.version', 'v1'),
                'config_version' => (string) config('matching.foundation.config_version', 'c1'),
            ]);
            $locked->forceFill(['active_run_id' => $run->id, 'state_version' => $locked->state_version + 1, 'state' => RoundState::Preparing])->save();
            $this->audit($run, OperationAction::Execute, ['state' => RunState::Pending->value]);
            return $run;
        });
    }

    public function retry(MatchingRun $failed, string $idempotencyKey, string $actorType, ?int $actorId): MatchingRun
    {
        return DB::transaction(function () use ($failed, $idempotencyKey, $actorType, $actorId) {
            $replay = MatchingRun::query()->where('idempotency_key', $idempotencyKey)->first();
            if ($replay) {
                if ((int) $replay->supersedes_run_id !== (int) $failed->id) throw new \DomainException('idempotency_key_conflict');
                return $replay;
            }
            $lockedFailed = MatchingRun::query()->whereKey($failed->id)->lockForUpdate()->firstOrFail();
            $round = DatingRound::query()->whereKey($lockedFailed->round_id)->lockForUpdate()->firstOrFail();
            if ($lockedFailed->state !== RunState::Failed || $round->state !== RoundState::Failed) throw new \DomainException('only_current_failed_run_can_retry');
            $attempt = ((int) MatchingRun::query()->where('round_id', $round->id)->max('attempt_no')) + 1;
            $run = MatchingRun::query()->create([
                'round_id' => $round->id, 'run_key' => (string) Str::uuid(), 'idempotency_key' => $idempotencyKey,
                'correlation_id' => (string) Str::uuid(), 'attempt_no' => $attempt, 'state' => RunState::Pending,
                'trigger_source' => 'admin', 'actor_type' => $actorType, 'actor_id' => $actorId, 'reason_code' => 'retry',
                'eligibility_cutoff_at' => now()->utc(), 'algorithm_version' => (string) config('matching.contract.version', 'v1'),
                'config_version' => (string) config('matching.foundation.config_version', 'c1'), 'supersedes_run_id' => $lockedFailed->id,
            ]);
            $round->forceFill(['active_run_id' => $run->id, 'state' => RoundState::Preparing, 'state_version' => $round->state_version + 1, 'failure_code' => null, 'failure_summary' => null])->save();
            $this->audit($run, OperationAction::Retry, ['state' => RunState::Pending->value, 'supersedes_run_id' => $lockedFailed->id]);
            return $run;
        });
    }

    public function claimNext(string $leaseOwner, int $leaseSeconds = 60): ?MatchingRun
    {
        return DB::transaction(function () use ($leaseOwner, $leaseSeconds) {
            $run = MatchingRun::query()->where('state', RunState::Pending->value)->orderBy('id')->lockForUpdate()->first();
            if (!$run) return null;
            $run->forceFill(['state' => RunState::Running, 'lease_owner' => $leaseOwner, 'fencing_token' => $run->fencing_token + 1, 'lease_expires_at' => now()->utc()->addSeconds($leaseSeconds), 'heartbeat_at' => now()->utc(), 'started_at' => now()->utc()])->save();
            return $run->fresh();
        });
    }

    public function heartbeat(MatchingRun $run, string $leaseOwner, int $fencingToken, int $leaseSeconds = 60): bool
    {
        return MatchingRun::query()->whereKey($run->id)->where('state', RunState::Running->value)->where('lease_owner', $leaseOwner)->where('fencing_token', $fencingToken)->where('lease_expires_at', '>', now()->utc())->update(['heartbeat_at' => now()->utc(), 'lease_expires_at' => now()->utc()->addSeconds($leaseSeconds)]) === 1;
    }

    public function freezeCandidates(MatchingRun $run, iterable $users, string $leaseOwner, int $fencingToken): void
    {
        DB::transaction(function () use ($run, $users, $leaseOwner, $fencingToken) {
            $locked = MatchingRun::query()->whereKey($run->id)->lockForUpdate()->firstOrFail();
            if ($locked->state !== RunState::Running || $locked->lease_owner !== $leaseOwner || $locked->fencing_token !== $fencingToken || !$locked->lease_expires_at?->isFuture()) throw new \DomainException('stale_lease_or_fence');
            $ids = [];
            foreach ($users as $user) {
                $id = (int) $user->id; $ids[] = $id;
                [$eligibilityVersion, $profileVersion] = $this->sourceVersions($id, $user->updated_at);
                MatchingRunCandidate::query()->updateOrCreate(['matching_run_id' => $locked->id, 'user_id' => $id], ['eligibility_version_at' => $eligibilityVersion, 'profile_version_at' => $profileVersion]);
            }
            sort($ids, SORT_NUMERIC);
            $key = (string) config('matching.foundation.digest_key');
            if ($key === '') throw new \RuntimeException('matching foundation digest key is not configured');
            $locked->forceFill(['eligible_count' => count($ids), 'candidate_count' => count($ids), 'candidate_digest' => hash_hmac('sha256', implode(',', $ids), $key), 'digest_version' => 'hmac-sha256-v1', 'digest_key_version' => (string) config('matching.foundation.digest_key_version', 'local-v1'), 'config_version' => $this->inputFingerprint()])->save();
        });
    }

    public function finalize(MatchingRun $run, string $leaseOwner, int $fencingToken, array $candidateUserIds, array $plannedPairs): MatchingRun
    {
        return DB::transaction(function () use ($run, $leaseOwner, $fencingToken, $candidateUserIds, $plannedPairs) {
            $locked = MatchingRun::query()->whereKey($run->id)->lockForUpdate()->firstOrFail();
            if ($locked->state !== RunState::Running || $locked->lease_owner !== $leaseOwner || $locked->fencing_token !== $fencingToken || !$locked->lease_expires_at?->isFuture()) throw new \DomainException('stale_lease_or_fence');
            $frozen = MatchingRunCandidate::query()->where('matching_run_id', $locked->id)->get()->keyBy('user_id');
            $frozenIds = $frozen->keys()->map(fn ($id) => (int) $id)->sort()->values()->all();
            $suppliedIds = collect($candidateUserIds)->map(fn ($id) => (int) $id)->unique()->sort()->values()->all();
            if ($frozenIds !== $suppliedIds) throw new \DomainException('input_changed');
            $key = (string) config('matching.foundation.digest_key');
            if ($key === '' || !hash_equals((string) $locked->candidate_digest, hash_hmac('sha256', implode(',', $frozenIds), $key))) throw new \DomainException('input_changed');
            if (!hash_equals((string) $locked->config_version, $this->inputFingerprint())) throw new \DomainException('input_changed');
            foreach ($candidateUserIds as $userId) {
                $candidate = $frozen->get((int) $userId);
                $currentVersion = User::query()->whereKey((int) $userId)->value('updated_at');
                [$eligibilityVersion, $profileVersion] = $this->sourceVersions((int) $userId, $currentVersion);
                if (!$candidate
                    || !$this->sameTimestamp($candidate->eligibility_version_at, $eligibilityVersion)
                    || !$this->sameTimestamp($candidate->profile_version_at, $profileVersion)) {
                    throw new \DomainException('input_changed');
                }
            }
            $round = DatingRound::query()->whereKey($locked->round_id)->lockForUpdate()->firstOrFail();
            $matchByUser = [];
            $usedUsers = [];
            foreach ($plannedPairs as $pair) {
                $a = (int) $pair['user_a']; $b = (int) $pair['user_b'];
                if ($a === $b || !in_array($a, $frozenIds, true) || !in_array($b, $frozenIds, true)) throw new \DomainException('pair_outside_frozen_candidates');
                if (isset($usedUsers[$a]) || isset($usedUsers[$b])) throw new \DomainException('candidate_used_more_than_once');
                $usedUsers[$a] = true; $usedUsers[$b] = true;
                $match = DatingMatch::query()->create(array_merge($this->matchPayload($pair), ['round_id' => $round->id, 'matching_run_id' => $locked->id, 'pair_key' => PairKey::forUsers($a, $b), 'pair_key_version' => PairKey::VERSION, 'week_tag' => $round->cadence_key, 'user_a' => $a, 'user_b' => $b, 'drop_released' => false]));
                $matchByUser[$a] = $match->id; $matchByUser[$b] = $match->id;
            }
            foreach ($candidateUserIds as $userId) {
                DatingRoundUserState::query()->updateOrCreate(['round_id' => $round->id, 'user_id' => (int) $userId], ['state' => UserRoundState::Waiting, 'dating_match_id' => $matchByUser[(int) $userId] ?? null, 'reason_code' => isset($matchByUser[(int) $userId]) ? 'match_pending_reveal' : 'no_candidate_pending_reveal', 'next_action_code' => 'wait_for_reveal', 'reveal_eligible_at' => $round->reveal_at, 'conversation_eligible' => false]);
            }
            $outcome = count($plannedPairs) > 0 ? RunOutcome::MatchesCreated : RunOutcome::NoCandidate;
            $locked->forceFill(['state' => RunState::Succeeded, 'outcome' => $outcome, 'pair_count' => count($plannedPairs), 'no_candidate_count' => max(0, count($candidateUserIds) - count($matchByUser)), 'finished_at' => now()->utc()])->save();
            $round->forceFill(['state' => RoundState::Waiting, 'state_version' => $round->state_version + 1])->save();
            $this->audit($locked, OperationAction::Execute, ['state' => RunState::Succeeded->value, 'outcome' => $outcome->value, 'pair_count' => count($plannedPairs)]);
            return $locked->fresh();
        });
    }

    public function fail(MatchingRun $run, string $leaseOwner, int $fencingToken, string $code, string $summary): MatchingRun
    {
        return DB::transaction(function () use ($run, $leaseOwner, $fencingToken, $code, $summary) {
            $locked = MatchingRun::query()->whereKey($run->id)->lockForUpdate()->firstOrFail();
            if ($locked->state !== RunState::Running || $locked->lease_owner !== $leaseOwner || $locked->fencing_token !== $fencingToken || !$locked->lease_expires_at?->isFuture()) throw new \DomainException('stale_lease_or_fence');
            $locked->forceFill(['state' => RunState::Failed, 'outcome' => null, 'error_code' => mb_substr($code, 0, 64), 'error_summary' => mb_substr($summary, 0, 255), 'finished_at' => now()->utc()])->save();
            DatingRound::query()->whereKey($locked->round_id)->update(['state' => RoundState::Failed->value, 'failure_code' => mb_substr($code, 0, 64), 'failure_summary' => mb_substr($summary, 0, 255), 'state_version' => DB::raw('state_version + 1')]);
            $this->audit($locked, OperationAction::Execute, ['state' => RunState::Failed->value, 'error_code' => $locked->error_code]);
            return $locked->fresh();
        });
    }

    public function expireLease(int $runId): MatchingRun
    {
        return DB::transaction(function () use ($runId) {
            $run = MatchingRun::query()->whereKey($runId)->lockForUpdate()->firstOrFail();
            if ($run->state !== RunState::Running || !$run->lease_expires_at?->isPast()) throw new \DomainException('run_lease_not_expired');
            $run->forceFill(['state' => RunState::Failed, 'outcome' => null, 'fencing_token' => $run->fencing_token + 1, 'error_code' => 'lease_expired', 'error_summary' => 'Run lease expired; a new retry attempt is required.', 'finished_at' => now()->utc()])->save();
            DatingRound::query()->whereKey($run->round_id)->update(['state' => RoundState::Failed->value, 'failure_code' => 'lease_expired', 'failure_summary' => 'Run lease expired.', 'state_version' => DB::raw('state_version + 1')]);
            $this->audit($run, OperationAction::Execute, ['state' => RunState::Failed->value, 'error_code' => 'lease_expired']);
            return $run->fresh();
        });
    }

    private function matchPayload(array $pair): array
    {
        return collect(['highlights','explanation_tags','score_base','score_final','score_fair','score_personality_total','score_mbti_total','score_astro_total','score_overall','score_bazi','score_zodiac','score_constellation','score_natal_chart','match_verdict','match_reasons','penalty_factors'])->mapWithKeys(fn ($key) => [$key => $pair[$key] ?? null])->all();
    }

    private function sourceVersions(int $userId, mixed $userUpdatedAt): array
    {
        $answerUpdatedAt = QuestionnaireAnswer::query()->where('user_id', $userId)->max('updated_at');
        $astroUpdatedAt = UserAstroProfile::query()->where('user_id', $userId)->max('updated_at');
        $eligibility = $answerUpdatedAt ? Carbon::parse($answerUpdatedAt) : null;
        $profileCandidates = array_filter([$userUpdatedAt ? Carbon::parse($userUpdatedAt) : null, $eligibility, $astroUpdatedAt ? Carbon::parse($astroUpdatedAt) : null]);
        $profile = empty($profileCandidates) ? null : collect($profileCandidates)->sortByDesc(fn (Carbon $time) => $time->getTimestamp())->first();
        return [$eligibility, $profile];
    }

    private function sameTimestamp(mixed $left, mixed $right): bool
    {
        if ($left === null || $right === null) return $left === null && $right === null;
        return Carbon::parse($left)->equalTo(Carbon::parse($right));
    }

    private function inputFingerprint(): string
    {
        $matching = (array) config('matching', []);
        unset($matching['foundation']['digest_key']);
        $questions = QuestionnaireQuestion::query()->orderBy('id')->get(['id','question_key','category','subtopic','content','question_type','options','sort_order','enabled','version','updated_at'])->map(fn ($question) => $question->toArray())->all();
        $payload = [
            'matching' => $matching,
            'personality' => (array) config('personality', []),
            'match_rules' => (array) config('match_rules', []),
            'confidence_policy' => (array) config('confidence_policy.narrative', []),
            'personality_enabled' => (bool) config('features.personality_test_enabled', false),
            'required_answers' => (int) config('questionnaire.required_answer_count', 10),
            'questions' => $questions,
            'prior_match_version' => DatingMatch::query()->max('updated_at'),
        ];
        return hash('sha256', json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
    }

    private function audit(MatchingRun $run, OperationAction $action, array $after): void
    {
        MatchingOperationAudit::query()->create(['round_id' => $run->round_id, 'matching_run_id' => $run->id, 'action' => $action, 'actor_type' => $run->actor_type, 'actor_id' => $run->actor_id, 'reason_code' => $run->reason_code, 'correlation_id' => $run->correlation_id, 'idempotency_key' => $run->idempotency_key, 'after_state' => $after, 'source_channel' => $run->trigger_source]);
    }
}
