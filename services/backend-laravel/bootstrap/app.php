<?php

use App\Http\Middleware\EnsureAccountActive;
use App\Http\Middleware\EnsureAdminPhone;
use App\Http\Middleware\EnsureMatchingOperationPermission;
use App\Http\Middleware\EnsureSecureTransport;
use App\Http\Middleware\ForceJsonResponse;
use App\Http\Middleware\QuestionSnapshotLock;
use App\Http\Middleware\RequestTraceMiddleware;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->append(RequestTraceMiddleware::class);
        $middleware->prependToGroup('api', \App\Http\Middleware\PrivateDynamicCharts::class);
        $middleware->appendToGroup('api', QuestionSnapshotLock::class);
        $middleware->redirectGuestsTo(fn () => route('admin.login'));
        $middleware->prependToGroup('api', ForceJsonResponse::class);
        $middleware->alias([
            'account.active' => EnsureAccountActive::class,
            'admin.phone' => EnsureAdminPhone::class,
            'matching.operation' => EnsureMatchingOperationPermission::class,
            'secure.transport' => EnsureSecureTransport::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (Throwable $e, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            $status = 500;
            $code = 'internal_error';
            $message = 'Server error';
            $details = null;

            if ($e instanceof ValidationException) {
                $status = 422;
                $code = 'validation_error';
                $message = $e->getMessage() ?: 'The given data was invalid.';
                $details = $e->errors();
            } elseif ($request->is('api/v1/admin/matching/*') && ($e instanceof DomainException || $e instanceof InvalidArgumentException)) {
                $status = 409;
                $code = 'matching_conflict';
                $message = $e->getMessage();
            } elseif ($e instanceof AuthenticationException) {
                $status = 401;
                $code = 'unauthenticated';
                $message = 'Unauthenticated.';
            } elseif ($e instanceof AuthorizationException) {
                $status = 403;
                $code = 'forbidden';
                $message = $e->getMessage() ?: 'Forbidden.';
            } elseif ($e instanceof HttpExceptionInterface) {
                $status = $e->getStatusCode();
                $code = 'http_error';
                $message = $e->getMessage() ?: 'HTTP error';
            } else {
                $message = config('app.debug') ? $e->getMessage() : $message;
            }

            $payload = [
                'ok' => false,
                'error' => [
                    'code' => $code,
                    'message' => $message,
                    'details' => $details,
                ],
            ];

            $response = response()->json($payload, $status);
            if ($request->is('api/v1/profile/dynamic', 'api/v1/profile/dynamic/*')) {
                $response->header('Cache-Control', 'private, no-store');
            }
            return $response;
        });
    })->create();
