<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\SanctionAppeals;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class SanctionAppealController extends Controller
{
    public function index(Request $request, SanctionAppeals $service): JsonResponse
    {
        return response()->json(['items' => $service->forOwner((int) $request->user()->id),
            'notice' => '申诉仅登记，不自动解除处罚或恢复任何私密互动权限。请勿填写密码、私信或他人隐私。']);
    }

    public function store(Request $request, int $sanctionId, SanctionAppeals $service): JsonResponse
    {
        $data = $request->validate(['note' => 'required|string|max:1000',
            'user_id' => 'prohibited', 'sanction_id' => 'prohibited', 'status' => 'prohibited']);
        $result = $service->submit((int) $request->user()->id, $sanctionId, $data['note']);
        $created = $result['created'];
        unset($result['created']);

        return response()->json($result, $created ? 201 : 200);
    }
}
