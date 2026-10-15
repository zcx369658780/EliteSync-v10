<?php
namespace App\Http\Middleware;
use App\Services\RtcAuthorityService;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
final class RtcTransaction
{
    public function handle(Request $request, Closure $next)
    {
        abort_unless(app(RtcAuthorityService::class)->enabled() && $request->user() && !$request->user()->disabled, 404);
        return DB::transaction(fn () => $next($request), 3);
    }
}
