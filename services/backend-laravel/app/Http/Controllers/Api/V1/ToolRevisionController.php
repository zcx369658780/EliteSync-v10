<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserDynamicChart;
use App\Models\UserNatalProfile;
use App\Models\UserToolRevision;
use App\Services\DynamicChartService;
use App\Services\NatalProfileView;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ToolRevisionController extends Controller
{
    public function natalIndex(Request $request): JsonResponse
    {
        return $this->listing($request, 'natal');
    }

    public function natalShow(Request $request, int $archive): JsonResponse
    {
        $row = $this->query($request, 'natal')->findOrFail($archive);
        $snapshot = (new UserNatalProfile)->forceFill($row->snapshot);
        return response()->json(['historical' => true, 'archived_at' => $row->created_at->toIso8601String(),
            'profile' => app(NatalProfileView::class)->profile($snapshot)])
            ->header('Cache-Control', 'no-store, private');
    }

    public function dynamicIndex(Request $request, int $id): JsonResponse
    {
        $this->ownedChart($request, $id);
        return $this->listing($request, 'dynamic', $id);
    }

    public function dynamicShow(Request $request, int $id, int $archive): JsonResponse
    {
        $this->ownedChart($request, $id);
        $row = $this->query($request, 'dynamic', $id)->findOrFail($archive);
        $snapshot = (new UserDynamicChart)->forceFill($row->snapshot);
        return response()->json(['historical' => true, 'archived_at' => $row->created_at->toIso8601String(),
            'chart' => app(DynamicChartService::class)->view($request->user(), $snapshot)])
            ->header('Cache-Control', 'no-store, private');
    }

    private function ownedChart(Request $request, int $id): void
    {
        UserDynamicChart::where('user_id', $request->user()->id)->findOrFail($id);
    }

    private function query(Request $request, string $tool, ?int $record = null): Builder
    {
        return UserToolRevision::where('user_id', $request->user()->id)->where('tool', $tool)
            ->when($record !== null, fn ($query) => $query->where('record_id', $record));
    }

    private function listing(Request $request, string $tool, ?int $record = null): JsonResponse
    {
        $data = $request->validate(['before_id' => 'sometimes|integer|min:1']);
        $rows = $this->query($request, $tool, $record)
            ->when(isset($data['before_id']), fn ($query) => $query->where('id', '<', $data['before_id']))
            ->orderByDesc('id')->limit(21)->get(['id', 'input_revision', 'created_at']);
        $more = $rows->count() > 20;
        $rows = $rows->take(20);
        return response()->json(['items' => $rows->map(fn ($row) => [
            'id' => $row->id, 'input_revision' => $row->input_revision,
            'status' => 'DETAIL_REVALIDATION_REQUIRED', 'archived_at' => $row->created_at->toIso8601String(),
        ])->values(), 'next_before_id' => $more ? $rows->last()->id : null])
            ->header('Cache-Control', 'no-store, private');
    }
}
