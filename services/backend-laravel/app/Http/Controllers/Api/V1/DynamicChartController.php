<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserDynamicChart;
use App\Services\DynamicChartService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Throwable;

class DynamicChartController extends Controller
{
    public function index(Request $request, DynamicChartService $service): JsonResponse
    {
        return $this->respond(function () use ($request, $service) {
            $user = $this->owner($request);
            $before = $request->query('before_id');
            if ($before !== null && (! ctype_digit((string) $before) || (int) $before < 1)) {
                throw new InvalidArgumentException('invalid_history_cursor');
            }
            // A bounded list carries no birth inputs/results and never starts an
            // engine probe. Opening a detail always revalidates its live identity.
            $rows = UserDynamicChart::where('user_id', $user->id)
                ->when($before !== null, fn ($query) => $query->where('id', '<', (int) $before))
                ->orderByDesc('id')->limit(21)->get(['id', 'chart_type', 'input_revision']);
            $more = $rows->count() > 20;
            $rows = $rows->take(20);
            return ['charts' => $rows->map(fn ($row) => [
                'id' => $row->id, 'chart_type' => $row->chart_type, 'input_revision' => $row->input_revision,
                'status' => 'DETAIL_REVALIDATION_REQUIRED',
            ])->values()->all(), 'next_before_id' => $more ? $rows->last()->id : null];
        });
    }

    public function show(Request $request, DynamicChartService $service, int $id): JsonResponse
    {
        return $this->respond(function () use ($request, $service, $id) {
            $user = $this->owner($request);
            return ['chart' => $service->view($user, $this->row($user, $id))];
        });
    }

    public function save(Request $request, DynamicChartService $service, ?int $id = null): JsonResponse
    {
        return $this->respond(function () use ($request, $service, $id) {
            $body = $request->json()->all();
            [$row, $prepared, $cached] = DB::transaction(function () use ($request, $service, $id, $body) {
                $user = $this->owner($request, true);
                $row = $id === null ? null : $this->row($user, $id, true);
                $prepared = $service->prepare($user, $body);
                if (($row?->input_revision ?? 0) !== $body['expected_revision']) {
                    throw new HttpException(409, 'dynamic_input_revision_conflict');
                }
                if ($row && hash_equals($row->input_signature, $prepared['input_signature'])
                    && $row->status === 'COMPUTED_UNVERIFIED' && $row->result_revision === $row->input_revision) {
                    if (array_key_exists('selected_event_index', $body)) {
                        $selection = $service->selectEvent($row->results, $body['selected_event_index']);
                        if ($selection !== $row->selected_event_index) {
                            $row->selected_event_index = $selection;
                            // Selection is a workspace edit too. Reuse the numeric
                            // result, but advance CAS so a late choice cannot win.
                            $row->input_revision++;
                            $row->result_revision = $row->input_revision;
                            $row->save();
                        }
                    }
                    return [$row, $prepared, true];
                }
                // Trusted persisted first chart only: user-supplied caches are never admitted.
                if ($row && $row->status === 'COMPUTED_UNVERIFIED'
                    && $row->result_revision === $row->input_revision
                    && ($row->prepared['_first_context_signature'] ?? null) === $prepared['first_context_signature']
                    && is_array($row->results['first'] ?? null)) {
                    $prepared['payload']['first_calculated'] = $row->results['first'];
                }
                $revision = ($row?->input_revision ?? 0) + 1;
                $row ??= new UserDynamicChart(['user_id' => $user->id]);
                $storedPrepared = $prepared['payload'];
                unset($storedPrepared['first_calculated']);
                $storedPrepared['_first_context_signature'] = $prepared['first_context_signature'];
                $row->fill(['chart_type' => $body['chart_type'], 'request' => $prepared['request'],
                    'settings' => $prepared['settings'], 'prepared' => $storedPrepared,
                    'input_signature' => $prepared['input_signature'], 'input_revision' => $revision,
                    'selected_event_index' => null, 'result_revision' => null, 'results' => null, 'status' => 'COMPUTING'])->save();
                return [$row, $prepared, false];
            });
            if (! $cached) {
                try {
                    $results = $service->compute($prepared);
                } catch (Throwable) {
                    UserDynamicChart::whereKey($row->id)->where('input_revision', $row->input_revision)
                        ->where('input_signature', $row->input_signature)
                        ->update(['status' => 'FAILED', 'results' => null, 'result_revision' => null]);
                    throw new HttpException(503, 'dynamic_calculation_unavailable');
                }
                try {
                    $selection = $service->selectEvent($results, $body['selected_event_index'] ?? null);
                } catch (InvalidArgumentException $exception) {
                    UserDynamicChart::whereKey($row->id)->where('input_revision', $row->input_revision)
                        ->where('input_signature', $row->input_signature)
                        ->update(['status' => 'FAILED', 'results' => null, 'result_revision' => null]);
                    throw $exception;
                }
                DB::transaction(function () use ($request, $service, $row, $body, $prepared, $results, $selection) {
                    // The same owner lock serializes both natal and derived writes, including first inserts.
                    $user = $this->owner($request, true);
                    $current = $this->row($user, $row->id, true);
                    if ($current->input_revision !== $row->input_revision
                        || ! hash_equals($current->input_signature, $prepared['input_signature'])) {
                        throw new HttpException(409, 'dynamic_result_superseded');
                    }
                    try {
                        $latest = $service->prepare($user, $body);
                        $same = hash_equals($latest['input_signature'], $prepared['input_signature']);
                    } catch (Throwable) {
                        $same = false;
                    }
                    if (! $same) {
                        // Persist no old result; the view will expose this generation as stale.
                        $current->fill(['status' => 'STALE_RECALCULATION_REQUIRED', 'results' => null,
                            'result_revision' => null])->save();
                        return;
                    }
                    $current->fill(['results' => $results, 'status' => 'COMPUTED_UNVERIFIED',
                        'selected_event_index' => $selection,
                        'result_revision' => $current->input_revision])->save();
                });
            }
            $user = $this->owner($request);
            return ['chart' => $service->view($user, $this->row($user, $row->id))];
        });
    }

    private function owner(Request $request, bool $lock = false): User
    {
        $query = User::whereKey($request->user()?->id);
        $user = ($lock ? $query->lockForUpdate() : $query)->first();
        if (! $user) {
            throw new HttpException(401, 'unauthenticated');
        }
        if ($user->disabled) {
            throw new HttpException(403, 'account_disabled');
        }
        return $user;
    }

    private function row(User $user, int $id, bool $lock = false): UserDynamicChart
    {
        $query = UserDynamicChart::where('user_id', $user->id)->whereKey($id);
        $row = ($lock ? $query->lockForUpdate() : $query)->first();
        if (! $row) {
            throw new HttpException(404, 'dynamic_chart_not_found');
        }
        return $row;
    }

    private function respond(callable $action): JsonResponse
    {
        try {
            $payload = $action();
            $status = 200;
        } catch (InvalidArgumentException $exception) {
            $payload = ['code' => $exception->getMessage()];
            $status = 422;
        } catch (HttpException $exception) {
            $payload = ['code' => $exception->getMessage()];
            $status = $exception->getStatusCode();
        } catch (Throwable) {
            $payload = ['code' => 'dynamic_chart_unavailable'];
            $status = 503;
        }
        return response()->json($payload, $status)->header('Cache-Control', 'no-store, private');
    }
}
