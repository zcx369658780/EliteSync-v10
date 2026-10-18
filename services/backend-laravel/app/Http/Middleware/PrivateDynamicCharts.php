<?php

namespace App\Http\Middleware;

use App\Services\DynamicChartService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class PrivateDynamicCharts
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->is('api/v1/profile/dynamic', 'api/v1/profile/dynamic/*')) {
            return $next($request);
        }
        if (DynamicChartService::admissionError() !== null) {
            return response()->json(['code' => 'dynamic_environment_not_admitted'], 403)
                ->header('Cache-Control', 'private, no-store');
        }
        $response = $next($request);
        $response->headers->set('Cache-Control', 'private, no-store');
        return $response;
    }
}
