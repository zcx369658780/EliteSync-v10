<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserNatalProfile;
use App\Services\NatalCalculationProfile;
use App\Services\NatalCalculationService;
use App\Services\NatalInputContext;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Throwable;

class NatalProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        return $this->response(UserNatalProfile::where('user_id', $request->user()->id)->first());
    }

    public function save(Request $request, NatalInputContext $normalizer,
        NatalCalculationProfile $profiles, NatalCalculationService $calculator): JsonResponse
    {
        $data = $request->validate([
            'input' => 'required|array:civil_date,civil_time,time_precision,timezone,latitude,longitude,fold,utc_offset_seconds,algorithm_sex,time_source,location_label',
            'input.civil_date' => 'required|string|max:10',
            'input.civil_time' => 'nullable|string|max:8',
            'input.time_precision' => 'required|string|max:16',
            'input.timezone' => 'required|string|max:64',
            'input.algorithm_sex' => 'sometimes|string|max:16',
            'input.time_source' => 'sometimes|string|max:64',
            'input.location_label' => 'nullable|string|max:255',
            'settings' => 'present|array', 'expected_revision' => 'required|integer|min:0',
        ]);
        try {
            $settings = $profiles->settings($data['settings']);
            $context = $normalizer->normalize($data['input'], $profiles->make($settings));
            if ($settings['target_year'] !== null && $settings['target_year'] < (int) substr($context['civil_date'], 0, 4)) {
                throw new InvalidArgumentException('target_year_before_birth');
            }
        } catch (InvalidArgumentException $exception) {
            return response()->json(['code' => $exception->getMessage(), 'message' => '请核对出生时间、地点和计算设置。'], 422);
        }
        $userId = (int) $request->user()->id;
        [$row, $cached] = DB::transaction(function () use ($userId, $data, $settings, $context) {
            // Serialize even the first insert on the already-existing owner row.
            User::whereKey($userId)->lockForUpdate()->firstOrFail();
            $row = UserNatalProfile::where('user_id', $userId)->lockForUpdate()->first();
            if ((int) ($row?->input_revision ?? 0) !== (int) $data['expected_revision']) {
                throw new ConflictHttpException('natal_input_revision_conflict');
            }
            if ($row && $row->input_signature === $context['input_signature'] && $row->status === 'COMPUTED_UNVERIFIED') {
                return [$row, true];
            }
            $revision = (int) ($row?->input_revision ?? 0) + 1;
            $row ??= new UserNatalProfile(['user_id' => $userId]);
            $row->fill(['input' => $data['input'], 'settings' => $settings, 'context' => $context,
                'input_signature' => $context['input_signature'], 'input_revision' => $revision,
                'result_revision' => null, 'results' => null, 'status' => 'COMPUTING'])->save();
            return [$row, false];
        });
        if ($cached) {
            return $this->response($row);
        }
        try {
            $results = $calculator->compute($context, $settings);
        } catch (Throwable) {
            UserNatalProfile::whereKey($row->id)->where('input_revision', $row->input_revision)
                ->update(['status' => 'FAILED', 'results' => null, 'result_revision' => null]);
            return response()->json(['code' => 'natal_calculation_unavailable',
                'message' => '本地排盘暂不可用，输入已保留，请重读后重试。'], 503)->header('Cache-Control', 'no-store, private');
        }
        $updated = UserNatalProfile::whereKey($row->id)->where('input_revision', $row->input_revision)
            ->where('input_signature', $context['input_signature'])->update([
                'results' => json_encode($results, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE),
                'status' => 'COMPUTED_UNVERIFIED', 'result_revision' => $row->input_revision,
            ]);
        if ($updated !== 1) {
            throw new ConflictHttpException('natal_result_superseded');
        }
        return $this->response($row->fresh());
    }

    private function response(?UserNatalProfile $row): JsonResponse
    {
        return response()->json(['exists' => $row !== null,
            'profile' => $row ? app(\App\Services\NatalProfileView::class)->profile($row) : null])
            ->header('Cache-Control', 'no-store, private');
    }
}
