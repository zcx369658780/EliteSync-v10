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

require '/app/public/index.php';
