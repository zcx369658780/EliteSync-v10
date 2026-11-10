<?php
namespace App\Http\Middleware;
use App\Services\Accounts\AdminAccess;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
class EnsureAdminPhone
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! app(AdminAccess::class)->allows($request->user())) {
            if ($request->is('api/*')) {
                return response()->json(['message' => 'admin access required'], 403);
            }
            abort(403, '管理员权限无效。');
        }
        return $next($request);
    }
}
