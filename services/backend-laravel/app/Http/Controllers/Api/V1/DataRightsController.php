<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\DataPurposeService;
use App\Services\JourneyStore;
use App\Services\ObjectDataRequestService;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class DataRightsController extends Controller
{
    private function authorized(Request $request, callable $work): JsonResponse
    {
        $owner = (int) $request->user()->id;
        $outcome = DB::transaction(function () use ($owner, $work) {
            app(JourneyStore::class)->users([$owner]);

            return $work($owner);
        }, 3);

        return response()->json($outcome)->header('Cache-Control', 'private, no-store');
    }

    public function purpose(Request $request, DataPurposeService $service): JsonResponse
    {
        return $this->authorized($request, function (int $owner) use ($service) {
            $draft = \App\Models\UserProfileShowcaseDraft::where('user_id', $owner)->lockForUpdate()->first();
            $source = $draft ? $service->dependency($owner, $draft->revision) : null;
            return $service->status($owner) + [
                'draft_revision' => (int) ($draft?->revision ?? 0),
                'derivation_state' => $source ? $service->derivationState($owner, $source) : 'INDEPENDENT',
            ];
        });
    }

    public function decide(Request $request, DataPurposeService $service): JsonResponse
    {
        $data = $request->validate(['state' => 'required|in:GRANTED,DECLINED,REVOKED',
            'expected_revision' => 'required|integer|min:0', 'confirm' => 'required|accepted']);

        return $this->authorized($request, fn ($owner) => $service->decide($owner, $data['state'], (int) $data['expected_revision']));
    }

    public function reuseCity(Request $request, ShowcaseWorkflow $workflow): JsonResponse
    {
        $data = $request->validate(['expected_revision' => 'required|integer|min:0', 'confirm' => 'required|accepted']);

        return $this->authorized($request, fn ($owner) => $workflow->reuseCity($owner, (int) $data['expected_revision']));
    }

    private function objectKey(string $type, string $key): string
    {
        abort_unless(match ($type) {
            'work' => preg_match('/^[1-9][0-9]{0,17}$/D', $key),
            'comment' => \Illuminate\Support\Str::isUuid($key),
            default => false,
        }, 404, 'unavailable');

        return strtolower($key);
    }

    public function owned(Request $request): JsonResponse
    {
        $filters = $request->validate(['type' => 'required|in:work,comment', 'page' => 'sometimes|integer|min:1|max:10000']);
        $isWork = $filters['type'] === 'work';

        return $this->authorized($request, function (int $owner) use ($filters, $isWork) {
            $query = DB::table($isWork ? 'status_posts' : 'status_post_comments')
                ->where($isWork ? 'author_user_id' : 'author_id', $owner)
                ->orderByDesc('created_at')->orderByDesc('id');
            $page = (int) ($filters['page'] ?? 1);
            $rows = $query->skip(($page - 1) * 20)->take(21)->get(['id', 'created_at']);

            return [
                'items' => $rows->take(20)->map(fn ($row) => ['key' => (string) $row->id,
                    'created_at' => $row->created_at])->values(),
                'has_more' => $rows->count() > 20,
            ];
        });
    }

    public function object(Request $request, string $type, string $key, ObjectDataRequestService $service): JsonResponse
    {
        $key = $this->objectKey($type, $key);

        return $this->authorized($request, fn ($owner) => $service->capability($owner, $type, $key));
    }

    public function submit(Request $request, string $type, string $key, ObjectDataRequestService $service): JsonResponse
    {
        $key = $this->objectKey($type, $key);
        $data = $request->validate(['request_key' => 'required|uuid', 'expected_version' => 'required|string|max:32',
            'confirm' => 'required|accepted']);
        $data['request_key'] = strtolower($data['request_key']);

        return $this->authorized($request, fn ($owner) => $service->request($owner, $type, $key, $data));
    }

    public function result(Request $request, string $type, string $key, ObjectDataRequestService $service): JsonResponse
    {
        $key = $this->objectKey($type, $key);
        $data = $request->validate(['request_key' => 'required|uuid']);

        return $this->authorized($request, fn ($owner) => $service->result($owner, $type, $key, strtolower($data['request_key'])));
    }
}
