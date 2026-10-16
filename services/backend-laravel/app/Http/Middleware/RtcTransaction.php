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
        try { return DB::transaction(function () use ($request, $next) {
            $response = $next($request);
            // Routing\Pipeline renders controller errors before returning to us.
            // Recover only database errors so the outer transaction rolls back
            // and owns the bounded retry; ordinary HTTP denials keep their status.
            $error = $response->exception ?? null;
            if ($error instanceof \PDOException) {
                throw $error;
            }
            return $response;
        }, 3); }
        catch (\PDOException) {
            return response()->json(['message'=>'RTC authority unavailable'], 503);
        }
    }
}
