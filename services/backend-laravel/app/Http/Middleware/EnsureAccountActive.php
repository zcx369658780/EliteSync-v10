<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\PersonalAccessToken;
use Symfony\Component\HttpFoundation\Response;

final class EnsureAccountActive
{
    public function handle(Request $request, Closure $next): Response
    {
        // Only owner-private writers use this lock. Pair operations retain their
        // ordered two-user locks, rather than acquiring an actor lock first.
        $privateWriter = $request->is('api/v1/profile/*', 'api/v1/questionnaire/*', 'api/v1/questions', 'api/v1/questions/answers', 'api/v1/auth/password')
            && ! $request->is('api/v1/profile/astro/pair');
        $privateWriter = $privateWriter || ($request->isMethod('POST') && $request->is('api/v1/media'));
        if ($privateWriter && $request->user()) {
            return DB::transaction(function () use ($request, $next) {
                $current = User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
                // Preserve Sanctum's token while replacing stale profile facts.
                $request->user()->setRawAttributes($current->getAttributes(), true);

                return $this->checked($request, $next);
            });
        }

        return $this->checked($request, $next);
    }

    private function checked(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if ($user && ($user->disabled || (Schema::hasTable('account_closures')
            && DB::table('account_closures')->where('user_id', $user->id)->exists()))) {
            if ($request->is('api/*')) {
                return response()->json(['ok' => false, 'error' => [
                    'code' => 'account_disabled', 'message' => '账号已被禁用。',
                ]], 403);
            }
            abort(403, '账号已被禁用。');
        }
        $token = $user?->currentAccessToken();
        if ($token instanceof PersonalAccessToken && $token->getKey()) {
            $current = PersonalAccessToken::query()->find($token->getKey());
            abort_unless($current && (int) $current->tokenable_id === (int) $user->id
                && $current->tokenable_type === $user->getMorphClass(), 401, 'SESSION_REVOKED');
            if ($current->device_session_id) {
                abort_unless(Schema::hasTable('device_sessions') && DB::table('device_sessions')
                    ->where('id', $current->device_session_id)->where('user_id', $user->id)->whereNull('revoked_at')->exists(), 401, 'SESSION_REVOKED');
            }
            abort_unless($current->can('*') || ($request->is('api/v1/auth/refresh', 'api/v1/auth/logout')
                && $current->can('session:refresh')), 403, 'TOKEN_PURPOSE_RESTRICTED');
        }

        return $next($request);
    }
}
