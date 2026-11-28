<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class RequireVerifiedRegistrationAgreement
{
    public function handle(Request $request, Closure $next): JsonResponse
    {
        // R04-A. Reopening requires a verified version and a server-side acceptance contract.
        return response()->json([
            'code' => 'REGISTRATION_AGREEMENT_UNAVAILABLE',
            'message' => '用户协议与隐私政策尚待核实，暂时无法注册。',
        ], 403);
    }
}
