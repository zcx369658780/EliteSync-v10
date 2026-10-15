<?php

namespace App\Http\Middleware;

use App\Models\DatingRound;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Admin\OperationAudit;
use App\Services\CurrentQuestionnaire;
use Closure;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class MatchingOperationTransaction
{
    public function handle(Request $r, Closure $next)
    {
        if (! $r->isMethod('post')) {
            return $next($r);
        }
        try {
            return DB::transaction(function () use ($r, $next) {
                app(CurrentQuestionnaire::class)->lock();
                $administrator = User::whereKey($r->user()->id)->lockForUpdate()->first();
                abort_unless(app(AdminAccess::class)->allows($administrator), 403);
                $key = 'matching-operations';
                DB::table('admin_versions')->insertOrIgnore(['key' => $key, 'revision' => 0]);
                DB::table('admin_versions')->where('key', $key)->lockForUpdate()->first();
                if ($r->route('roundKey')) {
                    $round = DatingRound::where('round_key', $r->route('roundKey'))->lockForUpdate()->firstOrFail();
                    $idempotency = trim((string) $r->header('Idempotency-Key'));
                    $replay = $idempotency !== '' && (DB::table('matching_operation_audits')->where('round_id', $round->id)->where('idempotency_key', $idempotency)->exists());
                    abort_unless($replay || (int) $r->input('state_version', -1) === (int) $round->state_version, 409, 'stale state version');
                }
                try {
                    $response = $next($r);
                } catch (\DomainException|\InvalidArgumentException $e) {
                    abort(409, $e->getMessage());
                }
                // Routing may render exceptions into responses before returning through middleware.
                // A rendered failure must roll back this outer business transaction as well.
                if ($response->getStatusCode() >= 400) {
                    throw new HttpResponseException($response);
                }
                if ($response->getStatusCode() < 300) {
                    OperationAudit::record($r->user()->id, 'matching.'.basename($r->path()), 'round', $r->route('roundKey') ?? 'new', (string) $r->input('reason_code', 'prepare'), (int) $r->input('state_version'), [], ['status' => $response->getStatusCode()]);
                }

                return $response;
            });
        } catch (HttpResponseException $failure) {
            return $failure->getResponse();
        }
    }
}
