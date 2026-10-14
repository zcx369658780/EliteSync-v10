<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class EnsureAccountActive
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->disabled) {
            if ($request->is('api/*')) {
                return response()->json(['ok' => false, 'error' => [
                    'code' => 'account_disabled', 'message' => '账号已被禁用。',
                ]], 403);
            }
            abort(403, '账号已被禁用。');
        }
        return $next($request);
    }
}
