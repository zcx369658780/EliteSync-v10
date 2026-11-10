<?php

namespace App\Http\Middleware;

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
        $connection = (string) config('database.default');
        $isolated = app()->environment('testing') && $connection === 'sqlite'
            || (app()->environment('local')
                && config("database.connections.$connection.database") === config('dynamic_charts.database')
                && in_array(config("database.connections.$connection.host"), ['127.0.0.1', 'localhost'], true));
        if (! config('dynamic_charts.enabled') || ! $isolated) {
            return response()->json(['code' => 'dynamic_environment_not_admitted'], 403)
                ->header('Cache-Control', 'private, no-store');
        }
        $response = $next($request);
        $response->headers->set('Cache-Control', 'private, no-store');
        return $response;
    }
}
