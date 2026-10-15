<?php

namespace App\Http\Middleware;

use App\Services\CurrentQuestionnaire;
use Closure;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class QuestionSnapshotLock
{
    public function handle(Request $r, Closure $next)
    {
        if (! $r->is('api/v1/questionnaire*') && ! $r->is('api/v1/questions*')) {
            return $next($r);
        }
        try {
            return DB::transaction(function () use ($r, $next) {
                app(CurrentQuestionnaire::class)->lock();
                $response = $next($r);
                if ($response->getStatusCode() >= 400) {
                    throw new HttpResponseException($response);
                }

return $response;
            });
        } catch (HttpResponseException $failure) {
            return $failure->getResponse();
        }
    }
}
