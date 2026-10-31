<?php
if (PHP_SAPI !== 'cli' || getenv('ELITESYNC_TASK_ID') !== 'V1015_OWNER_STAGED_OCI_L13_MAIN_RUNTIME_INTEGRATION_20261031') {
    throw new RuntimeException('Task CLI identity required.');
}
$root = realpath(dirname(__DIR__, 3).'/storage/l13-http-requests');
$file = realpath($argv[1] ?? '');
if (!$root || !$file || !str_starts_with($file, $root.DIRECTORY_SEPARATOR) || filesize($file) > 3145728) {
    throw new RuntimeException('Only this task request file is allowed.');
}
$r = json_decode(file_get_contents($file), true, flags: JSON_THROW_ON_ERROR);
$path = $r['path'] ?? '';
if (!str_starts_with($path, '/') || str_starts_with($path, '//') || preg_match('/[\r\n]/', $path) || strlen($path) > 2048) {
    throw new RuntimeException('Relative loopback request required.');
}
$method = $r['method'] ?? '';
if (!is_string($method) || !in_array($method, ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'], true)) {
    throw new RuntimeException('Unexpected task HTTP method.');
}
$headers = [];
foreach (($r['headers'] ?? []) as $key => $value) {
    if (preg_match('/[\r\n]/', $key.$value) || !in_array(strtolower($key), ['accept', 'authorization', 'content-type', 'cookie', 'x-csrf-token', 'user-agent'], true)) {
        throw new RuntimeException('Unexpected task HTTP header.');
    }
    $headers[] = $key.': '.$value;
}
$pairs = [];
$c = curl_init('http://127.0.0.1:8080'.$path);
curl_setopt_array($c, [
    CURLOPT_CUSTOMREQUEST => $method, CURLOPT_HTTPHEADER => $headers,
    CURLOPT_RETURNTRANSFER => true, CURLOPT_FOLLOWLOCATION => false,
    CURLOPT_CONNECTTIMEOUT => 5, CURLOPT_TIMEOUT => 45,
    CURLOPT_PROXY => '', CURLOPT_NOPROXY => '*', CURLOPT_PROTOCOLS => CURLPROTO_HTTP,
    CURLOPT_HEADERFUNCTION => static function ($curl, string $line) use (&$pairs): int {
        if (str_contains($line, ':')) {
            [$key, $value] = explode(':', trim($line), 2);
            $pairs[] = [$key, trim($value)];
        }
        return strlen($line);
    },
]);
if (isset($r['body_base64'])) {
    curl_setopt($c, CURLOPT_POSTFIELDS, base64_decode($r['body_base64'], true));
}
$body = curl_exec($c);
echo json_encode(['status' => curl_getinfo($c, CURLINFO_RESPONSE_CODE), 'headers' => $pairs,
    'body_base64' => base64_encode($body === false ? '' : $body), 'error' => curl_error($c)], JSON_THROW_ON_ERROR);
