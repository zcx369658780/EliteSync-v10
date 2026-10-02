<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** No trusted live CN/MC source is available for these private v1 routes. */
final class DenyUnverifiedMessagingLiveAccess
{
    public function handle(Request $request, Closure $next): Response
    {
        return response()->json(['message' => 'conversation unavailable'], 404);
    }
}
