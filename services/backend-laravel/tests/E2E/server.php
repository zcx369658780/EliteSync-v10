<?php
declare(strict_types=1);
/** Explicit future php -S router. Not public/index.php and never starts a server. */
require_once __DIR__.'/MainlineEnvironment.php';
try {
    $path=getenv('ELITESYNC_MAINLINE_CONTEXT');
    $root=getenv('ELITESYNC_MAINLINE_TASK_ROOT');
    if(!$path || !$root)throw new RuntimeException('Runtime context/root required');
    MainlineEnvironment::path($path,$root);
    $bytes=file_get_contents($path);
    if(!$bytes || !hash_equals((string)getenv('ELITESYNC_MAINLINE_CONTEXT_SHA256'),hash('sha256',$bytes)))throw new RuntimeException('Context identity changed');
    $ctx=json_decode($bytes,true,512,JSON_THROW_ON_ERROR);
    MainlineEnvironment::path($path,$ctx['config']['task_root']);
    $app=MainlineEnvironment::boot($ctx);
    $kernel=$app->make(Illuminate\Contracts\Http\Kernel::class);
    $request=Illuminate\Http\Request::capture();$response=$kernel->handle($request);
    $response->send();$kernel->terminate($request,$response);
} catch(Throwable $e) {
    error_log('MAINLINE_E2E_GATE: '.$e->getMessage());
    http_response_code(503);header('Content-Type: application/json');
    echo '{"error":"MAINLINE_E2E_QUALIFICATION_FAILED"}';
}
