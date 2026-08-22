<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Matching\OperationAction;
use App\Domain\Matching\RoundState;
use App\Domain\Matching\RunOutcome;
use App\Domain\Matching\RunState;
use App\Http\Controllers\Controller;
use App\Models\DatingRound;
use App\Models\MatchingOperationAudit;
use App\Models\MatchingRun;
use App\Services\MatchingRoundService;
use App\Services\MatchingRunService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminMatchingController extends Controller
{
    public function rounds(): JsonResponse
    {
        $items = DatingRound::query()->with('activeRun')->withCount('userStates')->latest('id')->limit(50)->get();

        return response()->json([
            'data' => $items->map(fn (DatingRound $round) => array_merge($round->toArray(), [
                'operation_capabilities' => $this->operationCapabilities($round),
            ])),
            'meta' => ['consumer_configured' => (bool) config('matching.c2.manual_consumer_configured', false), 'compensation_enabled' => false],
        ]);
    }

    public function round(string $roundKey): JsonResponse
    {
        $round = DatingRound::query()->where('round_key', $roundKey)->firstOrFail();
        $round->load(['activeRun', 'runs']);

        return response()->json(['data' => $round, 'audits' => $this->auditsForRound($round), 'meta' => ['compensation_enabled' => false]]);
    }

    public function run(string $runKey): JsonResponse
    {
        $run = MatchingRun::query()->where('run_key', $runKey)->firstOrFail();

        return response()->json(['data' => $run, 'audits' => $this->serializeAudits(MatchingOperationAudit::query()->where('matching_run_id', $run->id)->orderBy('id')->get())]);
    }

    public function prepare(Request $request, MatchingRoundService $service): JsonResponse
    {
        $idempotencyKey = trim((string) $request->header('Idempotency-Key'));
        if ($idempotencyKey === '' || strlen($idempotencyKey) > 120) {
            return response()->json(['message' => 'valid Idempotency-Key header is required'], 422);
        }
        $data = $request->validate(['channel_key' => ['required', 'string', 'max:64'], 'cadence_key' => ['required', 'string', 'max:120'], 'scheduled_for' => ['nullable', 'date'], 'reveal_at' => ['nullable', 'date'], 'state_version' => ['required', 'integer', 'min:0']]);
        $round = $service->prepare($data['channel_key'], $data['cadence_key'], isset($data['scheduled_for']) ? new \DateTimeImmutable($data['scheduled_for']) : null, isset($data['reveal_at']) ? new \DateTimeImmutable($data['reveal_at']) : null, 'admin', (int) $request->user()->id, 'admin', (int) $data['state_version'], $idempotencyKey);

        return response()->json(['data' => $round], 201);
    }

    public function executionRequest(Request $request, string $roundKey, MatchingRunService $service): JsonResponse
    {
        $round = DatingRound::query()->where('round_key', $roundKey)->firstOrFail();
        $data = $request->validate(['state_version' => ['required', 'integer', 'min:1'], 'reason_code' => ['required', 'string', 'max:64']]);
        $idempotencyKey = $this->idempotencyKey($request);
        if ($replay = $this->runReplay($round, OperationAction::Execute, $idempotencyKey, 202)) {
            return $replay;
        }
        if (! (bool) config('matching.c2.manual_consumer_configured', false)) {
            return response()->json(['message' => 'manual local consumer is not configured', 'error_code' => 'manual_consumer_not_configured', 'retry_safe' => true], 503);
        }
        if ((int) $round->state_version !== (int) $data['state_version']) {
            return $this->stale($round);
        }
        $run = $service->request($round, $idempotencyKey, 'admin', (int) $request->user()->id, $data['reason_code']);

        return response()->json(['data' => $run, 'meta' => ['consumer' => 'manual_cli_once', 'background_started' => false]], 202);
    }

    public function reveal(Request $request, string $roundKey, MatchingRoundService $service): JsonResponse
    {
        $round = DatingRound::query()->where('round_key', $roundKey)->firstOrFail();
        $data = $request->validate(['state_version' => ['required', 'integer', 'min:1'], 'reason_code' => ['required', 'string', 'max:64']]);
        $idempotencyKey = $this->idempotencyKey($request);
        if ($replay = $this->transitionReplay($round, OperationAction::Reveal, $idempotencyKey)) {
            return $replay;
        }
        if ((int) $round->state_version !== (int) $data['state_version']) {
            return $this->stale($round);
        }
        if ((string) $request->header('X-Matching-Confirmation') !== 'confirm:'.$roundKey.':reveal') {
            return response()->json(['message' => 'matching confirmation required'], 422);
        }
        $run = MatchingRun::query()->where('round_id', $round->id)->latest('attempt_no')->firstOrFail();
        $next = $run->outcome === RunOutcome::NoCandidate ? RoundState::NoCandidate : RoundState::Revealed;

        return response()->json(['data' => $service->transition($round, $next, (int) $data['state_version'], 'admin', (int) $request->user()->id, OperationAction::Reveal, $idempotencyKey)]);
    }

    public function retry(Request $request, string $roundKey, MatchingRunService $service): JsonResponse
    {
        $round = DatingRound::query()->where('round_key', $roundKey)->firstOrFail();
        $data = $request->validate(['state_version' => ['required', 'integer', 'min:1'], 'reason_code' => ['required', 'string', 'max:64']]);
        $idempotencyKey = $this->idempotencyKey($request);
        if ($replay = $this->runReplay($round, OperationAction::Retry, $idempotencyKey, 201)) {
            return $replay;
        }
        if ((int) $round->state_version !== (int) $data['state_version']) {
            return $this->stale($round);
        }
        $failed = MatchingRun::query()->where('round_id', $round->id)->where('state', 'failed')->latest('attempt_no')->firstOrFail();

        return response()->json(['data' => $service->retry($failed, $idempotencyKey, 'admin', (int) $request->user()->id)], 201);
    }

    public function close(Request $request, string $roundKey, MatchingRoundService $service): JsonResponse
    {
        $round = DatingRound::query()->where('round_key', $roundKey)->firstOrFail();
        $data = $request->validate(['state_version' => ['required', 'integer', 'min:1'], 'reason_code' => ['required', 'string', 'max:64']]);
        $idempotencyKey = $this->idempotencyKey($request);
        if ($replay = $this->transitionReplay($round, OperationAction::Close, $idempotencyKey)) {
            return $replay;
        }
        if ((int) $round->state_version !== (int) $data['state_version']) {
            return $this->stale($round);
        }
        if ((string) $request->header('X-Matching-Confirmation') !== 'confirm:'.$roundKey.':close') {
            return response()->json(['message' => 'matching confirmation required'], 422);
        }

        return response()->json(['data' => $service->transition($round, RoundState::Closed, (int) $data['state_version'], 'admin', (int) $request->user()->id, OperationAction::Close, $idempotencyKey)]);
    }

    public function compensation(): JsonResponse
    {
        return response()->json(['message' => 'compensation is not authorized'], 403);
    }

    private function idempotencyKey(Request $request): string
    {
        $key = trim((string) $request->header('Idempotency-Key'));
        if ($key === '' || strlen($key) > 120) {
            abort(422, 'valid Idempotency-Key header is required');
        }

        return $key;
    }

    private function stale(DatingRound $round): JsonResponse
    {
        return response()->json(['message' => 'stale state version', 'current_state_version' => (int) $round->state_version], 409);
    }

    private function transitionReplay(DatingRound $round, OperationAction $action, string $key): ?JsonResponse
    {
        $audit = MatchingOperationAudit::query()->where('round_id', $round->id)->where('idempotency_key', $key)->first();
        if (! $audit) {
            return null;
        }
        if ($audit->action !== $action) {
            return response()->json(['message' => 'idempotency key already used for another operation'], 409);
        }
        $after = $audit->after_state['after'] ?? [];

        return response()->json(['data' => ['round_key' => $round->round_key, 'state' => $after['state'] ?? null, 'state_version' => $after['state_version'] ?? null], 'meta' => ['idempotent_replay' => true]]);
    }

    private function runReplay(DatingRound $round, OperationAction $action, string $key, int $status): ?JsonResponse
    {
        $run = MatchingRun::query()->where('idempotency_key', $key)->where('round_id', $round->id)->first();
        if (! $run) {
            return null;
        }
        $matchesAction = MatchingOperationAudit::query()->where('matching_run_id', $run->id)
            ->where('idempotency_key', $key)->where('action', $action->value)->exists();
        if (! $matchesAction) {
            return response()->json(['message' => 'idempotency key already used for another operation'], 409);
        }

        return response()->json(['data' => $run, 'meta' => ['consumer' => 'manual_cli_once', 'background_started' => false, 'idempotent_replay' => true]], $status);
    }

    private function operationCapabilities(DatingRound $round): array
    {
        $run = $round->activeRun;
        $revealEligible = $round->state === RoundState::Waiting
            && $run?->state === RunState::Succeeded
            && in_array($run?->outcome, [RunOutcome::MatchesCreated, RunOutcome::NoCandidate], true)
            && $round->reveal_at?->isPast();

        return [
            'execute' => $round->state === RoundState::Preparing && $run === null,
            'retry' => $round->state === RoundState::Failed && $run?->state === RunState::Failed,
            'reveal' => $revealEligible,
            'close' => in_array($round->state, [RoundState::Revealed, RoundState::NoCandidate, RoundState::Failed], true),
            'compensation' => false,
        ];
    }

    private function auditsForRound(DatingRound $round): array
    {
        return $this->serializeAudits(MatchingOperationAudit::query()->where('round_id', $round->id)->orderBy('id')->get());
    }

    private function serializeAudits($audits): array
    {
        return $audits->map(fn (MatchingOperationAudit $audit) => [
            'action' => $audit->action->value,
            'actor_type' => $audit->actor_type,
            'actor_id' => $audit->actor_id,
            'reason_code' => $audit->reason_code,
            'before_state' => $audit->before_state,
            'after_state' => $audit->after_state,
            'created_at' => $audit->created_at?->toISOString(),
        ])->all();
    }
}
