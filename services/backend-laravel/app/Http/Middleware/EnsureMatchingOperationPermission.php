<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureMatchingOperationPermission
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $phones = config('app.admin_phones', []);
        if (!$user || !$user->isAdminRole() || !in_array((string) $user->phone, $phones, true)) {
            return response()->json(['message' => 'matching operation access required'], 403);
        }
        if (!(bool) config('matching.foundation.admin_operations_enabled', false)) {
            return response()->json(['message' => 'matching operations unavailable', 'retry_safe' => true], 503);
        }
        return $next($request);
    }
}
