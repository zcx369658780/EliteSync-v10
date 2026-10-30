<?php
declare(strict_types=1);
use Tests\E2E\RunningDockerEnvironment;
require_once __DIR__.'/RunningDockerEnvironment.php';
try {
    $app=RunningDockerEnvironment::app();
    $app->handleRequest(Illuminate\Http\Request::capture());
} catch (Throwable $error) {
    // No tokens, credentials or caller values are reflected to HTTP clients.
    error_log(get_class($error).': '.$error->getMessage());
    http_response_code(503); header('Content-Type: application/json');
    echo '{"error":"current task runtime qualification failed"}';
}
