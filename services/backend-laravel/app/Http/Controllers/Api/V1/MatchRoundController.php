<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\MatchRoundProjectionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MatchRoundController extends Controller
{
    public function current(Request $request, MatchRoundProjectionService $service): JsonResponse
    {
        return response()->json($service->currentForUser((int) $request->user()->id));
    }
}
