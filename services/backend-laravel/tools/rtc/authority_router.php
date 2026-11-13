<?php

// The private worker pool serves only existing guarded authority operations.
$path = parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH);
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST'
    || ! in_array($path, ['/api/v1/rtc-guard/authorize', '/api/v1/rtc-guard/sweep', '/api/v1/rtc-guard/audit'], true)) {
    http_response_code(404);
    header('Content-Type: application/json');
    echo '{"message":"Not found"}';
    return;
}

$diagnosticUntil = (float) getenv('RTC_DIAGNOSTIC_UNTIL');
if (microtime(true) >= $diagnosticUntil) {
    require '/app/public/index.php';
    return;
}

// The diagnostic path mirrors public/index.php and retains its kernel and guard.
$started = hrtime(true);
$attempt = $_SERVER['HTTP_X_RTC_ATTEMPT'] ?? '';
$stats = [
    'event' => 'rtc_authority_request',
    'attempt_id' => preg_match('/\A[0-9]{1,10}-[a-f0-9]{12}\z/D', $attempt) ? $attempt : 'unlinked',
    'worker_pid' => getmypid(),
    'action' => basename($path),
    'clock' => 'PHP hrtime durations',
    'query_count' => 0,
    'query_completed' => 0,
    'query_ms' => 0.0,
    'max_query_ms' => 0.0,
];
register_shutdown_function(function () use (&$stats, $started) {
    $stats['total_ms'] = round((hrtime(true) - $started) / 1e6, 3);
    $stats['response_status'] = http_response_code();
    error_log(json_encode($stats, JSON_UNESCAPED_SLASHES));
});
define('LARAVEL_START', microtime(true));
if (file_exists($maintenance = '/app/storage/framework/maintenance.php')) {
    require $maintenance;
}
require '/app/vendor/autoload.php';
$stats['vendor_ms'] = round((hrtime(true) - $started) / 1e6, 3);
$app = require_once '/app/bootstrap/app.php';
$stats['application_created_ms'] = round((hrtime(true) - $started) / 1e6, 3);
$app->booted(function () use (&$stats, $started) {
    $stats['booted_ms'] = round((hrtime(true) - $started) / 1e6, 3);
    $connection = app('db')->connection();
    $connection->beforeExecuting(function () use (&$stats, $connection) {
        $stats['query_count']++;
        if (! isset($stats['db_connection_id'])) {
            $connectStarted = hrtime(true);
            $pdo = $connection->getPdo();
            $stats['pdo_connect_ms'] = round((hrtime(true) - $connectStarted) / 1e6, 3);
            $stats['db_connection_id'] = (int) $pdo->query('SELECT CONNECTION_ID()')->fetchColumn();
        }
    });
    $connection->listen(function ($event) use (&$stats) {
        $stats['query_completed']++;
        $stats['query_ms'] = round($stats['query_ms'] + $event->time, 3);
        $stats['max_query_ms'] = max($stats['max_query_ms'], round($event->time, 3));
    });
    app('events')->listen(\Illuminate\Foundation\Http\Events\RequestHandled::class, function () use (&$stats, $started) {
        $stats['handled_ms'] = round((hrtime(true) - $started) / 1e6, 3);
    });
});
$app->terminating(function () use (&$stats, $started) {
    $stats['terminating_ms'] = round((hrtime(true) - $started) / 1e6, 3);
});
$app->handleRequest(\Illuminate\Http\Request::capture());
